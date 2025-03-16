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
  readarray -t RUN_IDS < <(gh api "/repos/${REPO}/actions/runs" --paginate \
    -q '[.workflow_runs[] | select(.name | ascii_downcase | test("build|pkg")) | select(.status == "completed")] | sort_by(.created_at) | reverse | .[:300] | .[].id')
 ##Check if there are any workflow runs
  if [ ${#RUN_IDS[@]} -eq 0 ]; then
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
    gh api "/repos/${REPO}/actions/jobs/${JOB_ID}/logs" > "${LOGS_DIR}/${JOB_LOGS}"
    du -sh "${LOGS_DIR}/${JOB_LOGS}"
  done
 '
 ##Archive
   RUN_IDS=()
   mapfile -t RUN_IDS < <(find "${LOGS_DIR}" -maxdepth 1 -name "logs-*.txt" -printf "%f\n" | awk -F'-' '{print $3}' | sed '/^$/d; s/\.txt$//' | sort -u)
   if [ ${#RUN_IDS[@]} -eq 0 ]; then
    echo -e "\n[-] No Logs found\n"
    return 1
   else
     for RUN_ID in "${RUN_IDS[@]}"; do
       C_RUN_ID=()
       mapfile -t C_RUN_ID < <(find "${LOGS_DIR}" -maxdepth 1 -name "logs-*${RUN_ID}*.txt")
       if [ ${#C_RUN_ID[@]} -eq 0 ]; then
         echo -e "\n[-] No logs found for Run ID (${RUN_ID}) <== [${RUN_ID}]\n"
         continue
       else
         echo -e "\nCompressing logs for Run ID [${RUN_ID}] ==> [${RUN_ID}.log.xz]"
         7z a -t7z -mx=9 -mmt="$(($(nproc)+1))" -bsp1 -bt "${LOGS_DIR}/${RUN_ID}.log.xz" "${C_RUN_ID[@]}"
         rm -rvf "${C_RUN_ID[@]}" 2>/dev/null
       fi
     done
   fi
 ##Upload
   LOG_IDS=()
   mapfile -t "LOG_IDS" < <(find "${LOGS_DIR}" -type f -name '*.log.xz' -exec basename "{}" .log.xz \; | sort -u)
   if [ ${#LOG_IDS[@]} -eq 0 ]; then
    echo -e "\n[-] No XZ Archives Found"
    return 1
   else
    pushd "${LOGS_DIR}" >/dev/null 2>&1
     #Upload to GHCR
      for LOG_ID in "${LOG_IDS[@]}"; do
       if echo "${REPO}" | grep -qi 'bincache'; then
        ##Github Releases
        # echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://github.com/pkgforge/metadata/releases/download/build-log-bincache/${LOG_ID}.log.xz]"
        # gh release upload "build-log-bincache" --repo "https://github.com/pkgforge/metadata" "${LOGS_DIR}/${LOG_ID}.log.xz" & #--clobber
        #ghcr
         echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://github.com/pkgforge/metadata/pkgs/container/build-log] (bincache-${LOG_ID})"
         [[ -f "./${LOG_ID}.log.xz" && -s "./${LOG_ID}.log.xz" ]] && oras push --disable-path-validation \
        --config "/dev/null:application/vnd.oci.empty.v1+json" "ghcr.io/pkgforge/metadata/build-logs:bincache-${LOG_ID}" "./${LOG_ID}.log.xz"
       elif echo "${REPO}" | grep -qi 'pkgcache'; then
        # echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://github.com/pkgforge/metadata/releases/download/build-log-pkgcache/${LOG_ID}.log.xz]"
        # gh release upload "build-log-pkgcache" --repo "https://github.com/pkgforge/metadata" "${LOGS_DIR}/${LOG_ID}.log.xz" & #--clobber
        echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://github.com/pkgforge/metadata/pkgs/container/build-log] (pkgcache-${LOG_ID})"
        [[ -f "./${LOG_ID}.log.xz" && -s "./${LOG_ID}.log.xz" ]] && oras push --disable-path-validation \
        --config "/dev/null:application/vnd.oci.empty.v1+json" "ghcr.io/pkgforge/metadata/build-logs:pkgcache-${LOG_ID}" "./${LOG_ID}.log.xz"
       fi
      done
     #Upload to HF
       huggingface-cli upload "pkgforge/build-logs" "${LOGS_DIR}" --include "*.log.xz" --repo-type "dataset" --commit-message "[+] Build Log (${LOG_ID})"
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
