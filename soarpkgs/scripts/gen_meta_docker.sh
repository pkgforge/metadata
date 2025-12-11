#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## FILES:
# "${SYSTMP}/INDEX.json" --> The main json
# "${SYSTMP}/INVALID_BINARIES.txt" --> code blocks containing raw sbuild-linter output for binaries
# "${SYSTMP}/INVALID_PACKAGES.txt" --> code blocks containing raw sbuild-linter output for packages
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_meta_docker.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_meta_docker.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#-------------------------------------------------------#

#-------------------------------------------------------#
pushd "${TMPDIR}"
##Run Docker
 docker stop "debian-guix" 2>/dev/null ; docker rm "debian-guix" 2>/dev/null
 docker run --privileged --net="host" --name "debian-guix" -e GITHUB_TOKEN="${GITHUB_TOKEN}" -e PARALLEL_LIMIT="${PARALLEL_LIMIT}" "ghcr.io/pkgforge/devscripts/debian-guix:$(uname -m)" \
 bash -l -c 'bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_meta_index.sh")'
##Copy to ${SYSTMP}
 docker cp "debian-guix:/tmp/INDEX.json" "${TMPDIR}/."
 sudo chown -Rv "$(whoami):$(whoami)" "${TMPDIR}" && chmod -Rv 755 "${TMPDIR}"
##Check 
 if [[ "$(jq -r '.[] | .build_script' "${TMPDIR}/INDEX.json" | grep -iv 'null' | wc -l)" -le 500 ]]; then
    echo -e "\n[-] FATAL: Failed to Generate Soarpkgs MetaData\n"
    exit 1
 else
    cp -fv "${TMPDIR}/INDEX.json" "${SYSTMP}/INDEX.json"
 fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/soarpkgs/data"
if [ -s "${SYSTMP}/INDEX.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  cd "${GITHUB_WORKSPACE}/main/soarpkgs/data"
  cp -fv "${SYSTMP}/INDEX.json" "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json"
  #Checksum
  generate_checksum() 
  {
      b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
  }
  generate_checksum "INDEX.json"
 #To Bita
  bita compress --input "INDEX.json" --compression "zstd" --compression-level "21" --force-create "INDEX.json.cba"
 #To Sqlite
  if command -v "qsv" >/dev/null 2>&1; then
    jq -c '.[]' "INDEX.json" > "${TMPDIR}/INDEX.jsonl"
    qsv jsonl "${TMPDIR}/INDEX.jsonl" > "${TMPDIR}/INDEX.csv"
    qsv to sqlite "${TMPDIR}/INDEX.db" "${TMPDIR}/INDEX.csv"
    if [[ -s "${TMPDIR}/INDEX.db" && $(stat -c%s "${TMPDIR}/INDEX.db") -gt 1024 ]]; then
     cp -fv "${TMPDIR}/INDEX.db" "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db" ; generate_checksum "INDEX.db"
     bita compress --input "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db" --compression "zstd" --compression-level "21" --force-create "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.cba"
     7z a -t7z -mx="9" -mmt="$(($(nproc)+1))" -bsp1 -bt "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.xz" "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db" 2>/dev/null ; generate_checksum "INDEX.db.xz"
     zstd --ultra -22 --force "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db" -o "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.zstd" ; generate_checksum "INDEX.db.zstd"
     ##Upload
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db" "r2:/meta/soarpkgs/INDEX.db" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db" "r2:/meta/soarpkgs/INDEX.db" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.bsum" "r2:/meta/soarpkgs/INDEX.db.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.bsum" "r2:/meta/soarpkgs/INDEX.db.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.cba" "r2:/meta/soarpkgs/INDEX.db.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.cba" "r2:/meta/soarpkgs/INDEX.db.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.xz" "r2:/meta/soarpkgs/INDEX.db.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.xz" "r2:/meta/soarpkgs/INDEX.db.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.xz.bsum" "r2:/meta/soarpkgs/INDEX.db.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.xz.bsum" "r2:/meta/soarpkgs/INDEX.db.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.zstd" "r2:/meta/soarpkgs/INDEX.db.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.zstd" "r2:/meta/soarpkgs/INDEX.db.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.zstd.bsum" "r2:/meta/soarpkgs/INDEX.db.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.db.zstd.bsum" "r2:/meta/soarpkgs/INDEX.db.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
    fi
  fi
 #To xz
  7z a -t7z -mx=9 -mmt="$(($(nproc)+1))" -bsp1 -bt "INDEX.json.xz" "INDEX.json" 2>/dev/null ; generate_checksum "INDEX.json.xz"
 #To Zstd
  zstd --ultra -22 --force "INDEX.json" -o "INDEX.json.zstd" ; generate_checksum "INDEX.json.zstd"
 ##Upload
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json" "r2:/meta/soarpkgs/INDEX.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json" "r2:/meta/soarpkgs/INDEX.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.bsum" "r2:/meta/soarpkgs/INDEX.json.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.bsum" "r2:/meta/soarpkgs/INDEX.json.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.cba" "r2:/meta/soarpkgs/INDEX.json.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.cba" "r2:/meta/soarpkgs/INDEX.json.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.xz" "r2:/meta/soarpkgs/INDEX.json.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.xz" "r2:/meta/soarpkgs/INDEX.json.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.xz.bsum" "r2:/meta/soarpkgs/INDEX.json.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.xz.bsum" "r2:/meta/soarpkgs/INDEX.json.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.zstd" "r2:/meta/soarpkgs/INDEX.json.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.zstd" "r2:/meta/soarpkgs/INDEX.json.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.zstd.bsum" "r2:/meta/soarpkgs/INDEX.json.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  #rclone copyto "${GITHUB_WORKSPACE}/main/soarpkgs/data/INDEX.json.zstd.bsum" "r2:/meta/soarpkgs/INDEX.json.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  wait ; echo
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate Diff
cd "${GITHUB_WORKSPACE}/main" && git pull origin main --no-edit 2>/dev/null
bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_diff.sh")
#-------------------------------------------------------#
