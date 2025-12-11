#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Generate AM Json
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/am/scripts/gen_meta.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/am/scripts/gen_meta.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
export HOST_TRIPLET="$(uname -m)-$(uname -s)"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
mkdir -pv "${TMPDIR}/src" "${TMPDIR}/tmp" "${TMPDIR}/data"
rm -rvf "${SYSTMP}/AM.json" 2>/dev/null
#Get HF Repo Remotes
 unset AM_REMOTES ; readarray -t "AM_REMOTES" < <(git ls-remote --heads "https://huggingface.co/datasets/pkgforge/AMcache" | sed -E 's|^[0-9a-f]+[[:space:]]+refs/heads/||' | grep -i "${HOST_TRIPLET}" | sort -u | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
 if [[ -n "${AM_REMOTES[*]}" && "${#AM_REMOTES[@]}" -gt 200 ]]; then
   echo -e "\n[+] Total Branches: ${#AM_REMOTES[@]}\n"
   fix_gitattributes()
    {
     if [[ -n "${REMOTE+x}" ]] && [[ -n "${REMOTE##*[[:space:]]}" ]]; then
      pushd "$(mktemp -d)" &>/dev/null && \
       git clone --branch "${REMOTE}" --depth="1" --filter="blob:none" --no-checkout \
        "https://huggingface.co/datasets/pkgforge/AMcache" "./TEMPREPO" &>/dev/null &&\
         cd "./TEMPREPO" && git checkout "${REMOTE}"
       if [[ "$(git rev-parse --abbrev-ref HEAD | head -n 1 | tr -d '[:space:]')" == "${REMOTE}" ]]; then
        git rm --cached --ignore-unmatch '.gitattributes'
        git sparse-checkout init --cone
        git sparse-checkout set ".gitattributes"
        git lfs uninstall 2>/dev/null
        git lfs untrack '.gitattributes' 2>/dev/null
        #git checkout HEAD^ -- '.gitattributes'
        #git restore --staged --worktree "."
        echo '*/* filter=lfs diff=lfs merge=lfs -text' > "./.gitattributes"
        echo '* filter=lfs diff=lfs merge=lfs -text' >> "./.gitattributes"
        sed '/^[[:space:]]*[^*]/d' -i "./.gitattributes"
        git add --all --renormalize --verbose
        git commit -m "Fix (GitAttributes)"
        git push origin "${REMOTE}"
       fi
      [[ -d "$(realpath .)/TEMPREPO" ]] && rm -rf "$(realpath .)" &>/dev/null && popd &>/dev/null
     fi
    }
   export -f fix_gitattributes
   get_remote_json()
   {
    local REMOTE=$1
    #echo -e "[+] Fixing ${REMOTE} $(fix_gitattributes &>/dev/null)"
    echo -e "[+] Fetching ${REMOTE}"
    pushd "$(mktemp -d)" >/dev/null 2>&1 && T_WDIR="$(realpath .)" &&\
    git clone --branch "${REMOTE}" "https://huggingface.co/datasets/pkgforge/AMcache" \
     --filter="blob:none" --depth="1" --no-checkout --quiet "./TEMPREPO" &>/dev/null &&\
     cd "./TEMPREPO" && HF_REPO_LOCAL="$(realpath .)" && export HF_REPO_LOCAL="${HF_REPO_LOCAL}"
    if [[ -d "${HF_REPO_LOCAL}" ]] && [[ "$(du -s "${HF_REPO_LOCAL}" | cut -f1)" -gt 100 ]]; then
     pushd "${HF_REPO_LOCAL}" &>/dev/null
       git lfs install &>/dev/null ; huggingface-cli lfs-enable-largefiles "." &>/dev/null
       git config "lfs.fetchinclude" "*.json"
       git sparse-checkout set --no-cone "*.json" && git checkout &>/dev/null
       git fetch origin "${REMOTE}" &>/dev/null ; git pull origin "${REMOTE}" --ff-only &>/dev/null
       git lfs ls-files --size -I "*.json"
       git lfs fetch origin "origin/${REMOTE}" -I "*.json" &>/dev/null
       git lfs pull -I "*.json" &>/dev/null
       GIT_LFS_SKIP_SMUDGE="1" git lfs migrate export --include-ref="${REMOTE}" -I "*.json" --verbose --yes &>/dev/null
       find "${HF_REPO_LOCAL}" -type f -iname '*.json' -exec bash -c 'cp -fv "{}" "${TMPDIR}/src/$(basename $(mktemp -u)).json"' \;
     popd &>/dev/null
    fi
    rm -rf "${T_WDIR}" && pushd "${TMPDIR}" &>/dev/null
   }
   export -f get_remote_json
   printf '%s\n' "${AM_REMOTES[@]}" | xargs -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" -I "{}" bash -c 'get_remote_json "$@" 2>/dev/null' _ "{}"
   #printf '%s\n' "${AM_REMOTES[@]}" | xargs -P "10" -I "{}" bash -c 'get_remote_json "$@"' _ "{}"
 else
   echo -e "\n[X] FATAL: Failed to Fetch needed Branches\n"
  exit 1
 fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Merge
 find "${TMPDIR}/src" -type f -iregex '.*\.json$' -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | \
   jq --arg host "${HOST_TRIPLET}" 'select(.host | ascii_downcase == ($host | ascii_downcase))' | \
   jq -s 'sort_by(.pkg) | unique_by(.pkg_id)' > "${TMPDIR}/AM.json.tmp"
#sanity check urls
 sed -E 's~\bhttps?:/{1,2}\b~https://~g' -i "${TMPDIR}/AM.json.tmp"
 cat "${TMPDIR}/AM.json.tmp" | jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | jq 'if type == "array" then . else [.] end' | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "")) | select(length > 0) elif type == "array" then map(select(. != null and . != "")) | select(length > 0) else . end)' |\
 jq 'map(select(
    .pkg != null and .pkg != "" and
    .pkg_id != null and .pkg_id != "" and
    .pkg_name != null and .pkg_name != "" and
    .description != null and .description != "" and
    .download_url != null and .download_url != "" and
    .version != null and .version != ""
 ))' | jq 'unique_by(.pkg_id) | sort_by(.pkg)' | jq . > "${TMPDIR}/AM.json"
##Sanity Check
 PKG_COUNT="$(jq -r '.[] | .pkg_id' "${TMPDIR}/AM.json" | grep -iv 'null' | wc -l | tr -d '[:space:]')"
 if [[ "${PKG_COUNT}" -le 20 ]]; then
    echo -e "\n[-] FATAL: Failed to Generate AM MetaData\n"
    echo "[-] Count: ${PKG_COUNT}"
    exit 1
 else
    echo -e "\n[+] Packages: ${PKG_COUNT}"
    cp -fv "${TMPDIR}/AM.json" "${SYSTMP}/AM.json"
 fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/external/am/data"
if command -v rclone &> /dev/null &&\
 [ -s "${HOME}/.rclone.conf" ] &&\
 [ -s "${SYSTMP}/AM.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  mkdir -pv "${GITHUB_WORKSPACE}/main/external/am/data"
  cd "${GITHUB_WORKSPACE}/main/external/am/data"
  jq -s 'map(.[]) | group_by(.pkg_id) | map(if length > 1 then .[1] + .[0] else .[0] end) | unique_by(.download_url) | sort_by(.pkg)' "${SYSTMP}/AM.json" "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json" | jq . > "${SYSTMP}/merged.json"
  if [[ "$(jq -r '.[] | .pkg_id' "${SYSTMP}/merged.json" | sort -u | wc -l | tr -d '[:space:]')" -gt 50 ]]; then
   cp -fv "${SYSTMP}/merged.json" "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json"
  fi
  #Checksum
  generate_checksum()
  {
      b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
  }
  generate_checksum "${HOST_TRIPLET}.json"
 #To Bita
  bita compress --input "${HOST_TRIPLET}.json" --compression "zstd" --compression-level "21" --force-create "${HOST_TRIPLET}.json.cba"
 #To xz
  xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "${HOST_TRIPLET}.json" ; generate_checksum "${HOST_TRIPLET}.json.xz"
 #To Zstd
  zstd --ultra -22 --force "${HOST_TRIPLET}.json" -o "${HOST_TRIPLET}.json.zstd" ; generate_checksum "${HOST_TRIPLET}.json.zstd"
 #Upload (Json)
  rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json" "r2:/meta/external/am/${HOST_TRIPLET}.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json.bsum" "r2:/meta/external/am/${HOST_TRIPLET}.json.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json.cba" "r2:/meta/external/am/${HOST_TRIPLET}.json.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json.xz" "r2:/meta/external/am/${HOST_TRIPLET}.json.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json.xz.bsum" "r2:/meta/external/am/${HOST_TRIPLET}.json.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json.zstd" "r2:/meta/external/am/${HOST_TRIPLET}.json.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json.zstd.bsum" "r2:/meta/external/am/${HOST_TRIPLET}.json.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  #Upload (SDB)
  wait ; echo
fi
#-------------------------------------------------------#
