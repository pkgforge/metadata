#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Sync All Packages to https://huggingface.co/datasets/pkgforge/pkgcache
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/scripts/sync_r2_mirror.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/scripts/sync_r2_mirror.sh") "${REPO}"
#-------------------------------------------------------#

#-------------------------------------------------------#
##Sanity
#mirror
if [[ -z "${R2_MIRROR+x}" ]]; then
  echo -e "[-] FATAL: Failed to get R2_MIRROR '\${R2_MIRROR}'\n"
 exit 1
fi
#repo
 if [[ -z "${UPSTREAM_REPO+x}" ]]; then
   echo -e "[-] FATAL: Repository '\${UPSTREAM_REPO}' is NOT Set\n"
  exit 1
 fi
#rclone
if ! command -v rclone &> /dev/null; then
  echo -e "[-] Failed to find rclone\n"
 exit 1
fi
#rclone
if command -v rclone &> /dev/null; then
 if [ -s "${HOME}/.rclone.conf" ] && [ ! -s "${HOME}/.config/rclone/rclone.conf" ]; then
    echo -e "\n[+] Setting Default rClone Config --> "${HOME}/.config/rclone/rclone.conf"\n"
     mkdir -p "${HOME}/.config/rclone" && touch "${HOME}/.config/rclone/rclone.conf"
     cat "${HOME}/.rclone.conf" > "${HOME}/.config/rclone/rclone.conf"
     dos2unix --quiet "${HOME}/.config/rclone/rclone.conf"
 elif [ -s "${HOME}/.config/rclone/rclone.conf" ]; then
    echo -e "\n[+] Using Default rClone Config --> "${HOME}/.config/rclone/rclone.conf"\n"
    dos2unix --quiet "${HOME}/.config/rclone/rclone.conf"
 else
   echo -e "\n[-] rClone Config Not Found\n"      
 fi
 export RCLONE_STATS="5s"
else
 echo -e "\n[-] rclone is NOT Installed"
  if [ -s "${HOME}/.rclone.conf" ]; then
    echo -e "rClone Config --> "${HOME}/.rclone.conf"\n"
  elif [ -s "${HOME}/.config/rclone/rclone.conf" ]; then
    echo -e "rClone Config --> "${HOME}/.config/rclone/rclone.conf"\n"
  else
    echo -e "[-] rClone Config Not Found\n"
  fi
  exit 1
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
if [[ -z "${USER_AGENT+x}" ]]; then
 USER_AGENT="$(curl -qfsSL 'https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Misc/User-Agents/ua_firefox_macos_latest.txt')"
fi
##Host
HOST_TRIPLET="$(uname -m)-$(uname -s)"
export HOST_TRIPLET="$(echo "${HOST_TRIPLET}" | tr -d '[:space:]')"
export HOST_TRIPLET_L="${HOST_TRIPLET,,}"
##Metadata
curl -qfsSL "https://meta.pkgforge.dev/${UPSTREAM_REPO}/${HOST_TRIPLET}.json" -o "${TMPDIR}/METADATA.json"
if [[ "$(cat "${TMPDIR}/METADATA.json" | jq -r '.[] | .ghcr_blob' | wc -l)" -le 20 ]]; then
  echo -e "\n[-] FATAL: Failed to Fetch ${UPSTREAM_REPO} (${HOST_TRIPLET}) Metadata\n"
 exit 1
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Main
sync_to_r2()
{
 ##Chdir
  pushd "${TMPDIR}" &>/dev/null
 ##Enable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set -x
  fi
 ##Input
  unset GHCR_BLOB R2_INPUT R2_PKGID R2_PKGNAME
  local INPUT="${1:-$(cat)}"
  export R2_INPUT="$(echo "${INPUT}" | tr -d '[:space:]')"
  if [ -z "${R2_INPUT+x}" ] || [ -z "${R2_INPUT##*[[:space:]]}" ]; then
     echo -e "[-] FATAL: Failed to get Package ID <== (${INPUT})"
   return 1
  else
     echo -e "\n[+] Processing: ${R2_INPUT}"
     export R2_PKGID="$(echo "${R2_INPUT}" | awk -F'[:#]' '{print $2}' | tr -d '[:space:]')"
     export R2_PKGNAME="$(echo "${R2_INPUT}" | awk -F'[#]' '{print $1}' | tr -d '[:space:]')"
     if [ -z "${R2_PKGNAME+x}" ] || [ -z "${R2_PKGNAME##*[[:space:]]}" ]; then
       echo -e "[-] FATAL: Failed to get Package Name <== (${R2_PKGNAME})"
      return 1
     else
       echo -e "[+] PKG_ID: ${R2_PKGID}"
       echo -e "[+] PKG_NAME: ${R2_PKGNAME} [${R2_PKGID}]"
     fi
  fi
 ##Get needed vars
  GHCR_BLOB="$(cat "${TMPDIR}/METADATA.json" | jq -r '.[] | select((.pkg_id | ascii_downcase) == (env.R2_PKGID | ascii_downcase) and .pkg_name == env.R2_PKGNAME) | .ghcr_blob' | grep -im1 "${UPSTREAM_REPO}" | tr -d '[:space:]')"
  export GHCR_BLOB
  if [ -z "${GHCR_BLOB+x}" ] || [ -z "${GHCR_BLOB##*[[:space:]]}" ]; then
    echo -e "[-] FATAL: Failed to get GHCR Blob <== [${R2_PKGID}]"
   return 1
  else
    echo -e "[+] GHCR_BLOB: ${GHCR_BLOB} [${R2_PKGID}]"
  fi
 ##Download/Upload
  pushd "$(mkdir -p "${TMPDIR}/${R2_PKGNAME}")" &>/dev/null &&\
   oras blob fetch "${GHCR_BLOB}" --output "${TMPDIR}/${R2_PKGNAME}/${R2_PKGNAME}"
   if [[ -s "${TMPDIR}/${R2_PKGNAME}/${R2_PKGNAME}" && $(stat -c%s "${TMPDIR}/${R2_PKGNAME}/${R2_PKGNAME}") -gt 10 ]]; then
     #Chmod
      chmod 'a+x' "${TMPDIR}/${R2_PKGNAME}/${R2_PKGNAME}"
     #Upload
      {
        rclone copyto "${TMPDIR}/${R2_PKGNAME}/${R2_PKGNAME}" "r2:${R2_MIRROR}/${R2_PKGNAME}" \
       --user-agent="${USER_AGENT}" --buffer-size="10M" --s3-upload-concurrency="50" --s3-chunk-size="10M" \
       --multi-thread-streams="50" --checkers="2000" --transfers="100" --retries="10" --check-first \
       --checksum --copy-links --fast-list --progress
       rm -rf "${TMPDIR}/${R2_PKGNAME}" 2>/dev/null && pushd "${TMPDIR}" &>/dev/null
      } &
   else
     echo -e "[-] FATAL: Failed to Download GHCR Blob <== [${R2_INPUT}]"
   fi
 ##Disable Debug 
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set +x
  fi
}
export -f sync_to_r2
#-------------------------------------------------------#

#-------------------------------------------------------#
##Run
pushd "${TMPDIR}" &>/dev/null
 unset R2_PKG_INPUT ; readarray -t "R2_PKG_INPUT" < <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/r2/data/PKG_LIST.txt" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | grep -v '^#' | grep -i ":${UPSTREAM_REPO}" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | sort -u)
 if [[ -n "${R2_PKG_INPUT[*]}" && "${#R2_PKG_INPUT[@]}" -le 1 ]]; then
   echo -e "\n[+] Total Packages: ${#R2_PKG_INPUT[@]}\n"
  exit 0
 else
   echo -e "\n[+] Total Packages: ${#R2_PKG_INPUT[@]}\n"
   printf '%s\n' "${R2_PKG_INPUT[@]}" | xargs -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" -I "{}" bash -c 'sync_to_r2 "$@"' _ "{}"
 fi
popd &>/dev/null
#-------------------------------------------------------#