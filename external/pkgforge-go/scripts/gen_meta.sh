#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Generate Json
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/pkgforge-go/scripts/gen_meta.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/pkgforge-go/scripts/gen_meta.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#-------------------------------------------------------#

#-------------------------------------------------------#
pushd "${TMPDIR}" &>/dev/null
#Get Assets
 export O_D="${GITHUB_WORKSPACE}/main/external/pkgforge-go/data"
 HOST_TRIPLETS=("aarch64-Linux" "loongarch64-Linux" "riscv64-Linux" "x86_64-Linux")
 for HOST_TRIPLET in "${HOST_TRIPLETS[@]}"; do
    echo -e "\n[+] Processing ${HOST_TRIPLET}..."
    #Download
     curl -w "(DL) <== %{url}\n" -qfsSL "https://raw.githubusercontent.com/pkgforge-go/builder/refs/heads/main/data/${HOST_TRIPLET}.json" -o "${TMPDIR}/${HOST_TRIPLET}.json"
    #Sanity Check
     PKG_COUNT="$(jq -r '.[] | .pkg_id' "${TMPDIR}/${HOST_TRIPLET}.json" | grep -iv 'null' | wc -l | tr -d '[:space:]')"
     if [[ "${PKG_COUNT}" -le 20 ]]; then
        echo -e "\n[-] FATAL: Failed to Fetch MetaData\n"
        echo "[-] Count: ${PKG_COUNT}"
        continue
     else
        echo -e "\n[+] Packages: ${PKG_COUNT}"
        cp -fv "${TMPDIR}/${HOST_TRIPLET}.json" "${SYSTMP}/${HOST_TRIPLET}.json"
     fi
    #Copy
     if [[ -s "${SYSTMP}/${HOST_TRIPLET}.json" ]] &&\
      [[ -d "${GITHUB_WORKSPACE}" ]] &&\
      [[ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
      #chdir to Repo
       cd "${GITHUB_WORKSPACE}/main"
      #Git pull
       git pull origin main --no-edit 2>/dev/null
      #Merge
       mkdir -pv "${O_D}" ; cd "${O_D}"
       [[ ! -f "${O_D}/${HOST_TRIPLET}.json" ]] &&\
        echo '[]' > "${O_D}/${HOST_TRIPLET}.json"
       jq -s \
        '
         (.[1] // []) as $old |
         (.[0] // []) as $new |
         ($old | map({(.pkg_id): .}) | add) as $old_by_id |
         ($new | map({(.pkg_id): .}) | add) as $new_by_id |
         ($old_by_id + $new_by_id) | to_entries | map(.value) | sort_by(.pkg)
        ' "${SYSTMP}/${HOST_TRIPLET}.json" "${O_D}/${HOST_TRIPLET}.json" > "${SYSTMP}/merged-${HOST_TRIPLET}.json"
      #Copy
       if [[ "$(jq -r '.[] | .pkg_id' "${SYSTMP}/merged-${HOST_TRIPLET}.json" | sort -u | wc -l | tr -d '[:space:]')" -gt 20 ]]; then
          cp -fv "${SYSTMP}/merged-${HOST_TRIPLET}.json" "${O_D}/${HOST_TRIPLET}.json"
       fi
      #Fix ID
       sed -E \
        '
         /^[[:space:]]*"pkg_id"[[:space:]]*:[[:space:]]*"[^"]*#[^"]*"/ {
         s/("pkg_id"[[:space:]]*:[[:space:]]*"[[:space:]]*)[^#]*#/\1/
        }' "${O_D}/${HOST_TRIPLET}.json" > "${SYSTMP}/${HOST_TRIPLET}.json.in"
       #Checksum
       generate_checksum()
       {
         b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
       }
       generate_checksum "${SYSTMP}/${HOST_TRIPLET}.json.in"
      #To Sqlite
       if command -v "qsv" &>/dev/null; then
         jq -c '.[]' "${SYSTMP}/${HOST_TRIPLET}.json.in" > "${TMPDIR}/${HOST_TRIPLET}.jsonl"
         qsv jsonl "${TMPDIR}/${HOST_TRIPLET}.jsonl" > "${TMPDIR}/${HOST_TRIPLET}.csv"
         qsv to sqlite "${TMPDIR}/${HOST_TRIPLET}.db" "${TMPDIR}/${HOST_TRIPLET}.csv"
         if [[ -s "${TMPDIR}/${HOST_TRIPLET}.db" && $(stat -c%s "${TMPDIR}/${HOST_TRIPLET}.db") -gt 1024 ]]; then
           cp -fv "${TMPDIR}/${HOST_TRIPLET}.db" "${O_D}/${HOST_TRIPLET}.db" ; generate_checksum "${HOST_TRIPLET}.db"
           zstd --ultra -22 --force "${O_D}/${HOST_TRIPLET}.db" -o "${O_D}/${HOST_TRIPLET}.db.zstd" ; generate_checksum "${HOST_TRIPLET}.db.zstd"
         fi
       fi
      #To xz
       xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "${SYSTMP}/${HOST_TRIPLET}.json.in" ; generate_checksum "${HOST_TRIPLET}.json.xz"
      #To Zstd
       zstd --ultra -22 --force "${SYSTMP}/${HOST_TRIPLET}.json.in" -o "${HOST_TRIPLET}.json.zstd" ; generate_checksum "${HOST_TRIPLET}.json.zstd"
     fi
 done
popd &>/dev/null
##Copy
if [[ -d "${SYSTMP}/_META" ]]; then
  cp -rv "${O_D}/." "${SYSTMP}/_META"
fi
#-------------------------------------------------------#
