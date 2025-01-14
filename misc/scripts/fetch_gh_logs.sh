#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Fetch & Upload GH Workflow Logs
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_gh_logs.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_gh_logs.sh") "${REPO}"
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
if [[ -z "${USER_AGENT}" ]]; then
 USER_AGENT="$(curl -qfsSL 'https://pub.ajam.dev/repos/Azathothas/Wordlists/Misc/User-Agents/ua_chrome_macos_latest.txt')"
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
  local REPO="$(echo ${INPUT} | sed -E 's|^(https://github.com/)?([^/]+/[^/]+).*|\2|' | tr -d '[:space:]')"
  local LOGS_DIR="$(mktemp -d)"
  local JOB_FILE="${LOGS_DIR}/jobID.txt"
  local RUN_IDS=()
 ##Tmpdir
  pushd "${LOGS_DIR}" >/dev/null 2>&1
 ##Get Run IDs 
  readarray -t RUN_IDS < <(gh api "/repos/${REPO}/actions/runs" --paginate \
    -q '[.workflow_runs[] | select(.name | ascii_downcase | test("bincache.*linux|pkgcache.*linux")) | select(.status == "completed")] | sort_by(.created_at) | reverse | .[:10] | .[].id')
 ##Check if there are any workflow runs
  if [ ${#RUN_IDS[@]} -eq 0 ]; then
   echo -e "\n[-] No workflow runs found\n"
   return 1
  fi
 ##Download logs for each job
  echo -e "\n [+] Downloading logs...\n"
  for RUN_ID in "${RUN_IDS[@]}"; do
   JOB_IDS=($(gh api "/repos/${REPO}/actions/runs/${RUN_ID}/jobs" -q '.jobs[].id'))
   #Check if we found any jobs
    if [ ${#JOB_IDS[@]} -eq 0 ]; then
     echo -e "No jobs found for Workflow Run ID (${RUN_ID}) <== [${RUN_ID}]"
     continue
    fi
   #Download
    for JOB_ID in "${JOB_IDS[@]}"; do
     echo -e "Writing logs for job ${JOB_ID} [${RUN_ID}]"
     JOB_LOGS="logs-${JOB_ID}-${RUN_ID}.txt"
     gh api "/repos/${REPO}/actions/jobs/${JOB_ID}/logs" > "${LOGS_DIR}/${JOB_LOGS}"
     du -sh "${LOGS_DIR}/${JOB_LOGS}"
    done
  done
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
       fi
     done
   fi
 ##Upload
   LOG_IDS=()
   mapfile -t "LOG_IDS" < <(find "${LOGS_DIR}" -type f -name '*.log.xz' -exec basename "{}" .log.xz \; | sort -u)
   if [ ${#JOB_IDS[@]} -eq 0 ]; then
    echo -e "\n[-] No XZ Archives Found"
    return 1
   else
    for LOG_ID in "${LOG_IDS[@]}"; do
     #aarch64-Linux
      if gh api "/repos/${REPO}/actions/runs/${LOG_ID}" --jq '.name' | tr -d '[:space:]' | grep -qi 'aarch64-Linux'; then
        if echo "${REPO}" | grep -qi 'bincache'; then
          echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://meta.pkgforge.dev/bincache/logs/aarch64-Linux.gh.${LOG_ID}.log.xz]"
          rclone copyto "${LOGS_DIR}/${LOG_ID}.log.xz" "r2:/meta/bincache/logs/aarch64-Linux.gh.${LOG_ID}.log.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
        elif echo "${REPO}" | grep -qi 'pkgcache'; then
          echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://meta.pkgforge.dev/pkgcache/logs/aarch64-Linux.gh.${LOG_ID}.log.xz]"
          rclone copyto "${LOGS_DIR}/${LOG_ID}.log.xz" "r2:/meta/pkgcache/logs/aarch64-Linux.gh.${LOG_ID}.log.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
        fi
     #x86_64-Linux   
      elif gh api "/repos/${REPO}/actions/runs/${LOG_ID}" --jq '.name' | tr -d '[:space:]' | grep -qi 'x86_64-Linux'; then
        if echo "${REPO}" | grep -qi 'bincache'; then
          echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://meta.pkgforge.dev/bincache/logs/x86_64-Linux.gh.${LOG_ID}.log.xz]"
          rclone copyto "${LOGS_DIR}/${LOG_ID}.log.xz" "r2:/meta/bincache/logs/x86_64-Linux.gh.${LOG_ID}.log.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
        elif echo "${REPO}" | grep -qi 'pkgcache'; then
          echo -e "[+] Uploading [${LOGS_DIR}/${LOG_ID}.log.xz] ==> [https://meta.pkgforge.dev/pkgcache/logs/x86_64-Linux.gh.${LOG_ID}.log.xz]"
          rclone copyto "${LOGS_DIR}/${LOG_ID}.log.xz" "r2:/meta/pkgcache/logs/x86_64-Linux.gh.${LOG_ID}.log.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
        fi
      fi
    done
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