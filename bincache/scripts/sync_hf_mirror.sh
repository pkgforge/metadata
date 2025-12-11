#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Sync All Packages to https://huggingface.co/datasets/pkgforge/bincache
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/scripts/sync_hf_mirror.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/scripts/sync_hf_mirror.sh") "${REPO}"
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
##Host
HOST_TRIPLET="$(uname -m)-$(uname -s)"
HOST_TRIPLET_L="${HOST_TRIPLET,,}"
export HOST_TRIPLET HOST_TRIPLET_L
##Metadata
curl -qfsSL "https://meta.pkgforge.dev/bincache/${HOST_TRIPLET}.json" -o "${TMPDIR}/METADATA.json"
if [[ "$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/METADATA.json" | wc -l)" -le 20 ]]; then
  echo -e "\n[-] FATAL: Failed to Fetch Bincache (${HOST_TRIPLET}) Metadata\n"
 exit 1 
fi
#Get HF Repo
pushd "$(mktemp -d)" &>/dev/null && git clone --filter="blob:none" --depth="1" --no-checkout "https://huggingface.co/datasets/pkgforge/bincache" && cd "./bincache"
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
sync_to_hf() 
{
 ##Chdir
  pushd "${TMPDIR}" &>/dev/null
 ##Enable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set -x
  fi
 ##Cleanup
  cleanup_func()
  {
    rm -rf "${PKG_DIR}" 2>/dev/null && popd &>/dev/null
    unset COMMIT_MSG GHCR_FILE GHCR_FILES GHCR_PKG GHCR_PKGNAME GHCR_PKGVER GHCR_PKGPATH HF_PKG_NAME HF_PKGPATH HF_REPO_DIR INPUT PKG_DIR
  }
  export -f cleanup_func
 ##Input
  local INPUT="${1:-$(cat)}"
  export GHCR_PKG="$(echo ${INPUT} | tr -d '[:space:]')"
  export GHCR_PKGNAME="$(echo ${INPUT} | awk -F'[:]' '{print $1}' | tr -d '[:space:]')"
  export GHCR_PKGVER="$(echo ${INPUT} | awk -F'[:]' '{print $2}' | tr -d '[:space:]')"
  export GHCR_PKGPATH="$(echo ${INPUT} | sed -n 's/.*\/bincache\/\(.*\):.*/\1/p' | tr -d '[:space:]')"
  export PKG_DIR="$(mktemp -d)"
 ##Sync
  HF_PKG_NAME="$(cat "${TMPDIR}/METADATA.json" | jq -r 'map(select(type == "object")) | .[] | select((.ghcr_pkg // "" | ascii_downcase) == (env.GHCR_PKG | ascii_downcase)) | .pkg_name' | tr -d '[:space:]')"
  export HF_PKG_NAME
  echo -e "\n[+] Syncing ${GHCR_PKGPATH}/${GHCR_PKGVER}/${HF_PKG_NAME}\n"
  #Check
   if [[ "$(git -C "${HF_REPO_LOCAL}" ls-tree --name-only 'HEAD' -- "${GHCR_PKGPATH}/${GHCR_PKGVER}/${HF_PKG_NAME}" 2>/dev/null)" == "${GHCR_PKGPATH}/${GHCR_PKGVER}/${HF_PKG_NAME}" ]]; then
     if [[ "${FORCE_REUPLOAD}" != "YES" ]]; then
       echo "[+] Skipping ==> ${GHCR_PKGPATH}/${GHCR_PKGVER}/${HF_PKG_NAME} [Exists]"
       cleanup_func
       return 0 || exit 0
     else
       echo "[+] Force Reuploading ==> ${GHCR_PKGPATH}/${GHCR_PKGVER}/${HF_PKG_NAME} [Exists]"
     fi
   else
     echo -e "[+] Uploading ${GHCR_PKGPATH}/${GHCR_PKGVER}/${HF_PKG_NAME}\n"
   fi
  #Proceed
   pushd "${PKG_DIR}" &>/dev/null && \
    git clone --depth="1" --filter="blob:none" --no-checkout "https://huggingface.co/datasets/pkgforge/bincache" && \
    cd "./bincache" && export HF_REPO_DIR="$(realpath .)"
    git lfs install &>/dev/null ; huggingface-cli lfs-enable-largefiles "." &>/dev/null
    [[ -d "${HF_REPO_DIR}" ]] || echo -e "\n[-] FATAL: Failed to create ${HF_REPO_DIR}\n $(exit 1)"
    export HF_PKGPATH="${HF_REPO_DIR}/${GHCR_PKGPATH}/${GHCR_PKGVER}"
    mkdir -pv "${HF_PKGPATH}" ; git fetch origin main ; git lfs track "./${GHCR_PKGPATH}/${GHCR_PKGVER}/**"
    git sparse-checkout set "" ; git sparse-checkout set --no-cone --sparse-index ".gitattributes"
    git checkout ; ls -lah "." "./${GHCR_PKGPATH}/${GHCR_PKGVER}" ; git sparse-checkout list
   #Fetch Package
    pushd "${HF_PKGPATH}" &>/dev/null && oras pull "${GHCR_PKG}" ; unset GHCR_FILE GHCR_FILES
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
     #Edit json
      find "${HF_PKGPATH}" -type f -iname "*.json" -type f -print0 | xargs -0 -I "{}" sed -E "s|https://api\.ghcr\.pkgforge\.dev/pkgforge/bincache/(.*)\?tag=(.*)\&download=(.*)$|https://hf.bincache.pkgforge.dev/\1/\2/\3|g" -i "{}"
     #Push
      pushd "${HF_REPO_DIR}" &>/dev/null && \
        git remote -v
        COMMIT_MSG="[+] PKG [${GHCR_PKGNAME}] (${GHCR_PKGVER})"
        git pull origin main
        git pull origin main --ff-only || git pull --rebase origin main
        git merge --no-ff -m "Merge & Sync"
        git lfs track "./${GHCR_PKGPATH}/${GHCR_PKGVER}/**" 2>/dev/null
        git lfs untrack '.gitattributes' 2>/dev/null
        sed '/\*/!d' -i '.gitattributes'
        if [ -d "${HF_PKGPATH}" ] && [ "$(du -s "${HF_PKGPATH}" | cut -f1)" -gt 100 ]; then
          find "${HF_PKGPATH}" -type f -size -3c -delete
          git sparse-checkout add "${GHCR_PKGPATH}/${GHCR_PKGVER}"
          git sparse-checkout list
          pushd "${HF_PKGPATH}" &>/dev/null && \
           find "." -maxdepth 1 -type f -not -path "*/\.*" | xargs -I "{}" git add "{}" --verbose
           git add --all --renormalize --verbose
           git commit -m "${COMMIT_MSG}"
          pushd "${HF_REPO_DIR}" &>/dev/null
           retry_git_push()
            {
             for i in {1..5}; do
              #Generic Merge
               git pull origin main --ff-only || git pull --rebase origin main
               git merge --no-ff -m "${COMMIT_MSG}"
              #Push
               git pull origin main 2>/dev/null
               if git push -u origin main; then
                  echo -e "\n[+] Pushed ==> ${GHCR_PKGNAME}/${GHCR_PKGVER}\n"
                  #echo "PUSH_SUCCESSFUL=YES" >> "${GITHUB_ENV}"
                  break
               fi
              #Sleep randomly 
               sleep "$(shuf -i 500-4500 -n 1)e-3"
             done
            }
            export -f retry_git_push
            retry_git_push
            git --no-pager log '-1' --pretty="format:'%h - %ar - %s - %an'"
            if ! git ls-remote --heads origin | grep -qi "$(git rev-parse HEAD)"; then
             echo -e "\n[-] WARN: Failed to push ==> ${GHCR_PKGNAME}/${GHCR_PKGVER}\n(Retrying ...)\n"
             retry_git_push
             git --no-pager log '-1' --pretty="format:'%h - %ar - %s - %an'"
             if ! git ls-remote --heads origin | grep -qi "$(git rev-parse HEAD)"; then
               echo -e "\n[-] FATAL: Failed to push ==> ${GHCR_PKGNAME}/${GHCR_PKGVER}\n"
               retry_git_push
             fi
            fi
           du -sh "${HF_PKGPATH}" && realpath "${HF_PKGPATH}"
        fi
    pushd "${TMPDIR}" &>/dev/null
    cleanup_func
 ##Disable Debug 
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set +x
  fi
}
export -f sync_to_hf
#-------------------------------------------------------#

#-------------------------------------------------------#
##Run
pushd "${TMPDIR}" &>/dev/null
 unset HF_PKG_INPUT ; readarray -t "HF_PKG_INPUT" < <( jq -r '.[] | .ghcr_pkg' "${TMPDIR}/METADATA.json" | sort -u)
 printf '%s\n' "${HF_PKG_INPUT[@]}" | xargs -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" -I "{}" timeout -k 10s 120s bash -c 'sync_to_hf "$@"' _ "{}"
popd &>/dev/null
#-------------------------------------------------------#