#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Generate Json
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/pkgforge-cargo/scripts/gen_meta.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/pkgforge-cargo/scripts/gen_meta.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
##Install Requirements
curl -qfsSL "https://api.gh.pkgforge.dev/repos/pkgforge/soarql/releases?per_page=100" | jq -r '.. | objects | .browser_download_url? // empty' | grep -Ei "$(uname -m)" | grep -Eiv "tar\.gz|\.b3sum" | grep -Ei "soarql" | sort --version-sort | tail -n 1 | tr -d '[:space:]' | xargs -I "{}" sudo curl -qfsSL "{}" -o "/usr/local/bin/soarql"
sudo chmod -v 'a+x' "/usr/local/bin/soarql"
 if [[ ! -s "/usr/local/bin/soarql" || $(stat -c%s "/usr/local/bin/soarql") -le 1024 ]]; then
   echo -e "\n[✗] FATAL: soarql Appears to be NOT INSTALLED...\n"
  exit 1
 else
   timeout 10 "/usr/local/bin/soarql" --help
 fi
#-------------------------------------------------------#

#-------------------------------------------------------#
pushd "${TMPDIR}" &>/dev/null
#Get Assets
 export O_D="${GITHUB_WORKSPACE}/main/external/pkgforge-cargo/data"
 HOST_TRIPLETS=("aarch64-Linux" "loongarch64-Linux" "riscv64-Linux" "x86_64-Linux")
 for HOST_TRIPLET in "${HOST_TRIPLETS[@]}"; do
    echo -e "\n[+] Processing ${HOST_TRIPLET}..."
    #Download
     curl -w "(DL) <== %{url}\n" -qfsSL "https://raw.githubusercontent.com/pkgforge-cargo/builder/refs/heads/main/data/${HOST_TRIPLET}.json" -o "${TMPDIR}/${HOST_TRIPLET}.json"
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
       mkdir -pv "${O_D}" ; cd "${O_D}" || exit 1
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
       #Checksum
       generate_checksum()
       {
         b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
       }
       generate_checksum "${HOST_TRIPLET}.json"
       #To SDB
       soarql --repo "pkgforge-cargo" --input "${HOST_TRIPLET}.json" --output "${HOST_TRIPLET}.sdb"
       generate_checksum "${HOST_TRIPLET}.sdb"
        if [[ $(stat -c%s "${HOST_TRIPLET}.sdb") -le 1024 ]] || file -i "${HOST_TRIPLET}.sdb" | grep -qiv 'sqlite'; then
          echo -e "\n[✗] FATAL: Failed to generate Soar DB...\n"
          echo "META_GEN=FAILED" >> "${GITHUB_ENV}"
        exit 1
        fi
      #To xz
       xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "${HOST_TRIPLET}.json" ; generate_checksum "${HOST_TRIPLET}.json.xz"
       xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "${HOST_TRIPLET}.sdb" ; generate_checksum "${HOST_TRIPLET}.sdb.xz"
      #To Zstd
       zstd --ultra -22 --force "${HOST_TRIPLET}.json" -o "${HOST_TRIPLET}.json.zstd" ; generate_checksum "${HOST_TRIPLET}.json.zstd"
       zstd --ultra -22 --force "${HOST_TRIPLET}.sdb" -o "${HOST_TRIPLET}.sdb.zstd" ; generate_checksum "${HOST_TRIPLET}.sdb.zstd"
     fi
 done
popd &>/dev/null
##Copy
if [[ -d "${SYSTMP}/_META" ]]; then
  cp -rv "${O_D}/." "${SYSTMP}/_META"
fi
#-------------------------------------------------------#
