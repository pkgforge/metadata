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
mkdir -pv "${TMPDIR}/tmp" "${TMPDIR}/data"
rm -rvf "${SYSTMP}/AM.json" 2>/dev/null
#Get HF Repo
pushd "$(mktemp -d)" >/dev/null 2>&1 && git clone --filter="blob:none" --depth="1" --no-checkout "https://huggingface.co/datasets/pkgforge/AMcache" && cd "./AMcache"
 git sparse-checkout set --no-cone "*.json" && git checkout
 git pull origin main --ff-only
 unset HF_REPO_LOCAL ; HF_REPO_LOCAL="$(realpath .)" && export HF_REPO_LOCAL="${HF_REPO_LOCAL}"
 if [ ! -d "${HF_REPO_LOCAL}" ] || [ $(du -s "${HF_REPO_LOCAL}" | cut -f1) -le 100 ]; then
   echo -e "\n[X] FATAL: Failed to clone HF Repo\n"
  exit 1 
 else
   if [[ "$(find "${HF_REPO_LOCAL}" -type f -iregex '.*\.json$' -print | sort -u | wc -l | tr -d '[:space:]')" -le 200 ]]; then
     echo -e "\n[X] FATAL: Failed to Get ALL JSON\n"
    exit 1 
   fi
 fi
popd >/dev/null 2>&1
#-------------------------------------------------------#

#-------------------------------------------------------#
##Merge
 find "${HF_REPO_LOCAL}" -type f -iregex '.*\.json$' -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | \
   jq --arg host "${HOST_TRIPLET}" 'select(.host | ascii_downcase == ($host | ascii_downcase))' | \
   jq -s 'sort_by(.pkg) | unique_by(.pkg_id)' > "${TMPDIR}/AM.json.tmp"
#sanity check urls
 sed -E 's~\bhttps?:/{1,2}\b~https://~g' -i "${TMPDIR}/AM.json.tmp"
 cat "${TMPDIR}/AM.json.tmp" | jq 'walk(if type == "boolean" then tostring else . end)' | jq 'if type == "array" then . else [.] end' | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "")) | select(length > 0) elif type == "array" then map(select(. != null and . != "")) | select(length > 0) else . end)' |\
 jq 'map(select(
    .pkg != null and .pkg != "" and
    .pkg_id != null and .pkg_id != "" and
    .pkg_name != null and .pkg_name != "" and
    .description != null and .description != "" and
    .download_url != null and .download_url != "" and
    .version != null and .version != ""
 ))' | jq 'unique_by(.pkg_id) | sort_by(.pkg)' | jq . > "${TMPDIR}/AM.json"
##Sanity Check
 if [[ "$(jq -r '.[] | .pkg_id' "${TMPDIR}/AM.json" | grep -iv 'null' | wc -l | tr -d '[:space:]')" -le 200 ]]; then
    echo -e "\n[-] FATAL: Failed to Generate AM MetaData\n"
    exit 1
 else
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
  jq -s 'map(.[]) | group_by(.pkg_id) | map(add)' "${SYSTMP}/AM.json" "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json" | jq 'unique_by(.download_url) | sort_by(.pkg)' | jq . > "${SYSTMP}/merged.json"
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
 #To Sqlite
  if command -v "qsv" >/dev/null 2>&1; then
    jq -c '.[]' "${HOST_TRIPLET}.json" > "${TMPDIR}/${HOST_TRIPLET}.jsonl"
    qsv jsonl "${TMPDIR}/${HOST_TRIPLET}.jsonl" > "${TMPDIR}/${HOST_TRIPLET}.csv"
    qsv to sqlite "${TMPDIR}/${HOST_TRIPLET}.db" "${TMPDIR}/${HOST_TRIPLET}.csv"
    if [[ -s "${TMPDIR}/${HOST_TRIPLET}.db" && $(stat -c%s "${TMPDIR}/${HOST_TRIPLET}.db") -gt 1024 ]]; then
     cp -fv "${TMPDIR}/${HOST_TRIPLET}.db" "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db" ; generate_checksum "${HOST_TRIPLET}.db"
     bita compress --input "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db" --compression "zstd" --compression-level "21" --force-create "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.cba"
     7z a -t7z -mx="9" -mmt="$(($(nproc)+1))" -bsp1 -bt "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.xz" "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db" 2>/dev/null ; generate_checksum "${HOST_TRIPLET}.db.xz"
     zstd --ultra -22 --force "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db" -o "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.zstd" ; generate_checksum "${HOST_TRIPLET}.db.zstd"
     #Upload
      rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db" "r2:/meta/external/am/${HOST_TRIPLET}.db" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.bsum" "r2:/meta/external/am/${HOST_TRIPLET}.db.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.cba" "r2:/meta/external/am/${HOST_TRIPLET}.db.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.xz" "r2:/meta/external/am/${HOST_TRIPLET}.db.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.xz.bsum" "r2:/meta/external/am/${HOST_TRIPLET}.db.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.zstd" "r2:/meta/external/am/${HOST_TRIPLET}.db.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.db.zstd.bsum" "r2:/meta/external/am/${HOST_TRIPLET}.db.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
    fi
  fi
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