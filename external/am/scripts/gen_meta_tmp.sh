#!/usr/bin/env bash
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
export HOST_TRIPLET="$(uname -m)-$(uname -s)"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/external/am/data"
if command -v rclone &> /dev/null &&\
 [ -s "${HOME}/.rclone.conf" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  mkdir -pv "${GITHUB_WORKSPACE}/main/external/am/data"
  cd "${GITHUB_WORKSPACE}/main/external/am/data"
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