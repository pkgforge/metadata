#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Sync All Packages to https://huggingface.co/datasets/pkgforge/pkgcache
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/scripts/sync_hf_mirror.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/scripts/sync_hf_mirror.sh") "${REPO}"
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
 USER_AGENT="$(curl -qfsSL 'https://pub.ajam.dev/repos/Azathothas/Wordlists/Misc/User-Agents/ua_chrome_macos_latest.txt')"
fi
##Host
HOST_TRIPLET="$(uname -m)-$(uname -s)"
HOST_TRIPLET_L="${HOST_TRIPLET,,}"
export HOST_TRIPLET HOST_TRIPLET_L
##Metadata
curl -qfsSL "https://meta.pkgforge.dev/pkgcache/${HOST_TRIPLET}.json" -o "${TMPDIR}/METADATA.json"
if [[ "$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/METADATA.json" | wc -l)" -le 20 ]]; then
  echo -e "\n[-] FATAL: Failed to Fetch Pkgcache (${HOST_TRIPLET}) Metadata\n"
 exit 1
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Main
sync_to_hf() 
{
 ##Chdir
  pushd "${TMPDIR}" >/dev/null 2>&1
 ##Enable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set -x
  fi
 ##Input
  local INPUT="${1:-$(cat)}"
  export GHCR_PKG="$(echo ${INPUT} | tr -d '[:space:]')"
  export GHCR_PKGNAME="$(echo ${INPUT} | awk -F'[:]' '{print $1}' | tr -d '[:space:]')"
  export GHCR_PKGVER="$(echo ${INPUT} | awk -F'[:]' '{print $2}' | tr -d '[:space:]')"
  export GHCR_PKGPATH="$(echo ${INPUT} | sed -n 's/.*\/pkgcache\/\(.*\):.*/\1/p' | tr -d '[:space:]')"
  export PKG_DIR="$(mktemp -d)"
 ##Sync
  echo -e "\n[+] Syncing ${GHCR_PKGNAME} (${GHCR_PKGVER})\n"
  pushd "${PKG_DIR}" >/dev/null 2>&1 && \
   git clone --depth="1" --filter="blob:none" --no-checkout "https://huggingface.co/datasets/pkgforge/pkgcache" && \
   cd "./pkgcache" && export HF_REPO_DIR="$(realpath .)"
   git lfs install &>/dev/null ; huggingface-cli lfs-enable-largefiles "." &>/dev/null
   [[ -d "${HF_REPO_DIR}" ]] || echo -e "\n[-] FATAL: Failed to create ${HF_REPO_DIR}\n $(exit 1)"
   export HF_PKGPATH="${HF_REPO_DIR}/${GHCR_PKGPATH}/${GHCR_PKGVER}"
   mkdir -pv "${HF_PKGPATH}" ; git fetch origin main ; git lfs track "./${GHCR_PKGPATH}/${GHCR_PKGVER}/**"
   git sparse-checkout set "" ; git sparse-checkout set --no-cone --sparse-index ".gitattributes"
   git checkout ; ls -lah "." "./${GHCR_PKGPATH}/${GHCR_PKGVER}" ; git sparse-checkout list
  #Fetch Package
   pushd "${HF_PKGPATH}" >/dev/null 2>&1 && oras pull "${GHCR_PKG}" ; unset GHCR_FILE GHCR_FILES
    #Ensure all files were fetched
     readarray -t "GHCR_FILES" < <(jq -r --arg GHCR_PKG "$GHCR_PKG" '.[] | select(.ghcr_pkg == $GHCR_PKG) | .ghcr_files[]' "${TMPDIR}/METADATA.json")
     for GHCR_FILE in "${GHCR_FILES[@]}"; do
      if [ ! -s "${HF_PKGPATH}/${GHCR_FILE}" ]; then
       echo -e "\n[-] Missing/Empty: ${HF_PKGPATH}/${GHCR_FILE}\n(Retrying ...)\n"
       oras pull "${GHCR_PKG}"
       if [ ! -s "${HF_PKGPATH}/${GHCR_FILE}" ]; then
         echo -e "\n[-] FATAL: Failed to Fetch ${HF_PKGPATH}/${GHCR_FILE}\n"
         return 1
       fi
      fi
     done
    #Push
     pushd "${HF_REPO_DIR}" >/dev/null 2>&1 && \
       git pull origin main --ff-only ; git merge --no-ff -m "Merge & Sync"
       git lfs track "./${GHCR_PKGPATH}/${GHCR_PKGVER}/**"
       if [ -d "${HF_PKGPATH}" ] && [ "$(du -s "${HF_PKGPATH}" | cut -f1)" -gt 100 ]; then
         find "${HF_PKGPATH}" -type f -size -3c -delete
         git sparse-checkout add "${GHCR_PKGPATH}/${GHCR_PKGVER}"
         git sparse-checkout list
         git add --all --verbose && git commit -m "[+] PKG [${GHCR_PKGNAME}] (${GHCR_PKGVER})"
         git pull origin main ; git push origin main #&& sleep "$(shuf -i 500-4500 -n 1)e-3"
         git --no-pager log '-1' --pretty="format:'%h - %ar - %s - %an'"
         if ! git ls-remote --heads origin | grep -qi "$(git rev-parse HEAD)"; then
          echo -e "\n[-] WARN: Failed to push ==> ${GHCR_PKGNAME}/${GHCR_PKGVER}\n(Retrying ...)\n"
          git pull origin main ; git push origin main #&& sleep "$(shuf -i 500-4500 -n 1)e-3"
          git --no-pager log '-1' --pretty="format:'%h - %ar - %s - %an'"
          if ! git ls-remote --heads origin | grep -qi "$(git rev-parse HEAD)"; then
            echo -e "\n[-] FATAL: Failed to push ==> ${GHCR_PKGNAME}/${GHCR_PKGVER}\n"
          fi
         fi
         du -sh "${HF_PKGPATH}" && realpath "${HF_PKGPATH}"
       fi
   pushd "${TMPDIR}" >/dev/null 2>&1
 ##Cleanup
   rm -rf "${PKG_DIR}" 2>/dev/null && popd >/dev/null 2>&1
   unset GHCR_FILE GHCR_FILES GHCR_PKG GHCR_PKGNAME GHCR_PKGVER GHCR_PKGPATH HF_PKGPATH HF_REPO_DIR INPUT PKG_DIR
 ##Disable Debug 
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set +x
  fi
}
export -f sync_to_hf
#-------------------------------------------------------#

#-------------------------------------------------------#
##Run
pushd "${TMPDIR}" >/dev/null 2>&1
 unset HF_PKG_INPUT ; readarray -t "HF_PKG_INPUT" < <( jq -r '.[] | .ghcr_pkg' "${TMPDIR}/METADATA.json" | sort -u)
  if [[ -n "${PARALLEL_LIMIT}" ]]; then
   printf '%s\n' "${HF_PKG_INPUT[@]}" | xargs -P "${PARALLEL_LIMIT}" -I "{}" bash -c 'sync_to_hf "$@" 2>/dev/null' _ "{}"
  else
  #Not safe, lot's of conflict
   printf '%s\n' "${HF_PKG_INPUT[@]}" | xargs -P "$(($(nproc)+1))" -I "{}" bash -c 'sync_to_hf "$@" 2>/dev/null' _ "{}"
  fi
popd >/dev/null 2>&1
#-------------------------------------------------------# 