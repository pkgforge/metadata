#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Fetch & Upload GH Workflow Logs
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_gh_logs.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_gh_logs.sh") "${REPO}"
#-------------------------------------------------------#

#-------------------------------------------------------#
##Sanity
if ! command -v huggingface-cli &> /dev/null; then
  echo -e "[-] Failed to find huggingface-cli\n"
 exit 1 
fi
if [ -z "${HF_TOKEN+x}" ] || [ -z "${HF_TOKEN##*[[:space:]]}" ]; then
  echo -e "\n[-] FATAL: Failed to Find HF Token (\${HF_TOKEN}\n"
 exit 1
else
  export GIT_TERMINAL_PROMPT="0"
  export GIT_ASKPASS="/bin/echo"
  git config --global "credential.helper" store
  git config --global "user.email" "AjamX101@gmail.com"
  git config --global "user.name" "Azathothas"
  huggingface-cli login --token "${HF_TOKEN}" --add-to-git-credential
fi
if ! command -v oras &> /dev/null; then
  echo -e "[-] Failed to find oras\n"
 exit 1
else
  oras login --username "Azathothas" --password "${GHCR_TOKEN}" "ghcr.io"
fi
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
if [[ -z "${USER_AGENT}" ]]; then
 USER_AGENT="$(curl -qfsSL 'https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Misc/User-Agents/ua_firefox_macos_latest.txt')"
fi
GHCRPKG_URL="ghcr.io/pkgforge/metadata/build-logs"
export GHCRPKG_URL USER_AGENT
##Repo
if echo "${REPO}" | grep -qi 'pkgforge-cargo'; then
  pushd "$(mktemp -d)" &>/dev/null && git clone --filter="blob:none" --depth="1" --no-checkout "https://huggingface.co/datasets/pkgforge-cargo/build-logs" && cd "./build-logs"
elif echo "${REPO}" | grep -qi 'pkgforge-go'; then
  pushd "$(mktemp -d)" &>/dev/null && git clone --filter="blob:none" --depth="1" --no-checkout "https://huggingface.co/datasets/pkgforge-go/build-logs" && cd "./build-logs"
else
  pushd "$(mktemp -d)" &>/dev/null && git clone --filter="blob:none" --depth="1" --no-checkout "https://huggingface.co/datasets/pkgforge/build-logs" && cd "./build-logs"
fi
git sparse-checkout set "" && git checkout
unset HF_REPO_LOCAL ; HF_REPO_LOCAL="$(realpath .)" && export HF_REPO_LOCAL="${HF_REPO_LOCAL}"
if [ ! -d "${HF_REPO_LOCAL}" ] || [ $(du -s "${HF_REPO_LOCAL}" | cut -f1) -le 100 ]; then
  echo -e "\n[X] FATAL: Failed to clone HF Repo\n"
 exit 1
fi
popd &>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Main
download_action_logs() 
{
 ##Enable Debug 
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set -x
  fi
 ##Input 
  local INPUT="${1:-$(cat)}"
  export REPO="$(echo ${INPUT} | sed -E 's|^(https://github.com/)?([^/]+/[^/]+).*|\2|' | tr -d '[:space:]')"
  export LOGS_DIR="$(mktemp -d)"
  export JOB_FILE="${LOGS_DIR}/jobID.txt"
  export RUN_IDS=()
 ##Tmpdir
  pushd "${LOGS_DIR}" >/dev/null 2>&1
 ##Get Run IDs 
  rm "${TMPDIR}/RUN_IDS.txt" 2>/dev/null
  for page in {1..50}; do
    echo -e "\n[+] Fetching https://github.com/${REPO}/actions [Page=${page}/50]\n"
    #gh api "/repos/${REPO}/actions/runs?per_page=100&page=${page}" 2>/dev/null |\
    #  jq -r '.workflow_runs[] | select(.name | ascii_downcase | test("build|pkg")) | select(.status == "completed") | .id' 2>/dev/null |\
    gh api "/repos/${REPO}/actions/runs?per_page=100&page=${page}" 2>/dev/null |\
      jq -r '.workflow_runs[] | select(.status == "completed") | .id' 2>/dev/null |\
      grep -oP '^\s*\d+\s*$' | tr -d ' ' >> "${TMPDIR}/RUN_IDS.txt"
  done
  RUN_IDS_TMP=() ; readarray -t RUN_IDS_TMP < <(cat "${TMPDIR}/RUN_IDS.txt" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | sort -u)
  #IDS_EXIST=() ; readarray -t "IDS_EXIST" < <(oras repo tags "${GHCRPKG_URL}" 2>/dev/null | grep -i "${REPO}" | awk -F'[-]' '{print $2}' | grep -oP '^\s*\d+\s*$' | sort -u)
  IDS_EXIST=() ; readarray -t "IDS_EXIST" < <(git -C "${HF_REPO_LOCAL}" ls-tree --name-only 'HEAD' | xargs -I "{}" basename "{}" | sort -u | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | grep -Eiv '\.(git|md|txt)' | grep -oP '^\s*\d+\s*' | sort -u)
  RUN_IDS=() ; readarray -t RUN_IDS < <(printf "%s\n" "${RUN_IDS_TMP[@]}" | grep -Fxv -f <(printf "%s\n" "${IDS_EXIST[@]}" | grep -oP '^\s*\d+\s*$') | sort -u | sed -e '/^[[:space:]]*$/d;200q')
 ##Check if there are any workflow runs
  if [ ${#RUN_IDS[@]} -le 1 ]; then
   echo -e "\n[-] No workflow runs found\n"
   return 1
  fi
 ##Download logs for each job
  echo -e "\n [+] Downloading logs...\n"
  printf "%s\n" "${RUN_IDS[@]}" | xargs -I "{}" -n 1 -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" bash -c '
  RUN_ID="{}" ; export RUN_ID
  echo "ID: ${RUN_ID}"
  JOB_IDS=($(gh api "/repos/${REPO}/actions/runs/${RUN_ID}/jobs" -q ".jobs[].id"))
  if [ ${#JOB_IDS[@]} -eq 0 ]; then
    echo -e "No jobs found for Workflow Run ID (${RUN_ID}) <== [${RUN_ID}]"
    exit 0
  fi
  for JOB_ID in "${JOB_IDS[@]}"; do
    echo "[${RUN_ID}] ==> ${JOB_ID}"
    JOB_LOGS="logs-${JOB_ID}-${RUN_ID}.txt"
    gh api "/repos/${REPO}/actions/jobs/${JOB_ID}/logs" 2>/dev/null > "${LOGS_DIR}/${JOB_LOGS}"
    du -sh "${LOGS_DIR}/${JOB_LOGS}"
  done
 '
 ##Archive
   RUN_IDS=()
   mapfile -t RUN_IDS < <(find "${LOGS_DIR}" -maxdepth 1 -name "logs-*.txt" -printf "%f\n" | awk -F'-' '{print $3}' | sed '/^$/d; s/\.txt$//' | sort -u)
   if [ ${#RUN_IDS[@]} -le 0 ]; then
    echo -e "\n[-] No Logs found\n"
    return 1
   else
     for RUN_ID in "${RUN_IDS[@]}"; do
       C_RUN_ID=()
       mapfile -t C_RUN_ID < <(find "${LOGS_DIR}" -maxdepth 1 -name "logs-*${RUN_ID}*.txt")
       if [ ${#C_RUN_ID[@]} -le 0 ]; then
         echo -e "\n[-] No logs found for Run ID (${RUN_ID}) <== [${RUN_ID}]\n"
         continue
       else
         echo -e "\nCompressing logs for Run ID [${RUN_ID}] ==> [${RUN_ID}.log.7z]"
         7z a -t7z -mx=9 -mmt="$(($(nproc)+1))" -bsp1 -bt "${LOGS_DIR}/${RUN_ID}.log.7z" "${C_RUN_ID[@]}"
         rm -rvf "${C_RUN_ID[@]}" 2>/dev/null
       fi
     done
   fi
 ##Upload
   LOG_IDS=()
   mapfile -t "LOG_IDS" < <(find "${LOGS_DIR}" -type f -name '*.log.7z' -exec basename "{}" .log.7z \; | sort -u)
   if [ ${#LOG_IDS[@]} -le 0 ]; then
    echo -e "\n[-] No 7Z Archives Found"
    return 1
   else
    pushd "${LOGS_DIR}" >/dev/null 2>&1
     #Upload to GHCR
      for LOG_ID in "${LOG_IDS[@]}"; do
       if echo "${REPO}" | grep -qi 'bincache'; then
        ##Github Releases
        # echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.7z] ==> [https://github.com/pkgforge/metadata/releases/download/build-log-bincache/${LOG_ID}.log.7z]"
        # gh release upload "build-log-bincache" --repo "https://github.com/pkgforge/metadata" "${LOGS_DIR}/${LOG_ID}.log.7z" & #--clobber
        #ghcr
         echo -e "[+] Uploading [${LOG_ID}] ==> [https://github.com/pkgforge/metadata/pkgs/container/metadata%2Fbuild-logs/] (bincache-${LOG_ID})"
         [[ -f "./${LOG_ID}.log.7z" && -s "./${LOG_ID}.log.7z" ]] && oras push --disable-path-validation \
        --config "/dev/null:application/vnd.oci.empty.v1+json" "${GHCRPKG_URL}:bincache-${LOG_ID}" "./${LOG_ID}.log.7z"
       elif echo "${REPO}" | grep -qi 'pkgcache'; then
        # echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.7z] ==> [https://github.com/pkgforge/metadata/releases/download/build-log-pkgcache/${LOG_ID}.log.7z]"
        # gh release upload "build-log-pkgcache" --repo "https://github.com/pkgforge/metadata" "${LOGS_DIR}/${LOG_ID}.log.7z" & #--clobber
        echo -e "[+] Uploading [${LOG_ID}] ==> [https://github.com/pkgforge/metadata/pkgs/container/metadata%2Fbuild-logs/] (pkgcache-${LOG_ID})"
        [[ -f "./${LOG_ID}.log.7z" && -s "./${LOG_ID}.log.7z" ]] && oras push --disable-path-validation \
        --config "/dev/null:application/vnd.oci.empty.v1+json" "${GHCRPKG_URL}:pkgcache-${LOG_ID}" "./${LOG_ID}.log.7z"
       elif echo "${REPO}" | grep -qi 'pkgforge-cargo'; then
        echo -e "[+] Uploading [${LOG_ID}] ==> [https://github.com/pkgforge/metadata/pkgs/container/metadata%2Fbuild-logs/] (pkgforge-cargo-${LOG_ID})"
        [[ -f "./${LOG_ID}.log.7z" && -s "./${LOG_ID}.log.7z" ]] && oras push --disable-path-validation \
        --config "/dev/null:application/vnd.oci.empty.v1+json" "${GHCRPKG_URL}:pkgforge-cargo-${LOG_ID}" "./${LOG_ID}.log.7z"
       elif echo "${REPO}" | grep -qi 'pkgforge-go'; then
        echo -e "[+] Uploading [${LOG_ID}] ==> [https://github.com/pkgforge/metadata/pkgs/container/metadata%2Fbuild-logs/] (pkgforge-go-${LOG_ID})"
        [[ -f "./${LOG_ID}.log.7z" && -s "./${LOG_ID}.log.7z" ]] && oras push --disable-path-validation \
        --config "/dev/null:application/vnd.oci.empty.v1+json" "${GHCRPKG_URL}:pkgforge-go-${LOG_ID}" "./${LOG_ID}.log.7z"
       fi
      done
     #Upload to HF
      if echo "${REPO}" | grep -qi 'bincache'; then
        huggingface-cli upload "pkgforge/build-logs" "${LOGS_DIR}" --include "*.log.7z" --repo-type "dataset" --commit-message "[+] Build Log (${LOG_ID})"
      elif echo "${REPO}" | grep -qi 'pkgcache'; then
        huggingface-cli upload "pkgforge/build-logs" "${LOGS_DIR}" --include "*.log.7z" --repo-type "dataset" --commit-message "[+] Build Log (${LOG_ID})"
      elif echo "${REPO}" | grep -qi 'pkgforge-cargo'; then
        huggingface-cli upload "pkgforge-cargo/build-logs" "${LOGS_DIR}" --include "*.log.7z" --repo-type "dataset" --commit-message "[+] Build Log (${LOG_ID})"
      elif echo "${REPO}" | grep -qi 'pkgforge-go'; then
        huggingface-cli upload "pkgforge-go/build-logs" "${LOGS_DIR}" --include "*.log.7z" --repo-type "dataset" --commit-message "[+] Build Log (${LOG_ID})"
      fi
   fi
 ##Exit
  wait ; popd >/dev/null 2>&1
 ##Disable Debug 
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
   set +x
  fi
}
export -f download_action_logs
#-------------------------------------------------------#

#-------------------------------------------------------#
#Sanity Check Input
if [ "$#" -ne 1 ]; then
 echo -e "Usage: $0 owner/repo"
 return 1 || exit 1
fi
#Call func directly if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
 download_action_logs "$@" <&0
fi
#-------------------------------------------------------#
