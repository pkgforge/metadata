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
mkdir -pv "${TMPDIR}/assets" "${TMPDIR}/data" "${TMPDIR}/src" "${TMPDIR}/tmp"
rm -rvf "${SYSTMP}/AM.json" 2>/dev/null
##Get Descr
 curl -qfsSL "https://github.com/pkgforge-community/AM-HF-SYNC/raw/main/.github/PKGS.json" -o "${SYSTMP}/DESCR.json"
 [[ -s "${SYSTMP}/DESCR.json" ]] || exit 1
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
#Get Repo Tags
 META_REPO="pkgforge-community/AM-HF-SYNC"
 CUTOFF_DATE="$(date --utc -d '7 days ago' '+%Y-%m-%d' | tr -d '[:space:]')" ; unset META_TAGS
 export META_REPO CUTOFF_DATE
 for i in {1..5}; do
   #gh api "repos/${META_REPO}/releases" --paginate 2>/dev/null |& cat - > "${TMPDIR}/tmp/RELEASES.json"
   gh api "repos/${META_REPO}/releases" 2>/dev/null |& cat - > "${TMPDIR}/tmp/RELEASES.json"
   if [[ $(stat -c%s "${TMPDIR}/tmp/RELEASES.json" | tr -d '[:space:]') -le 1000 ]]; then
     echo "Retrying... ${i}/5"
     sleep 2
   elif [[ $(stat -c%s "${TMPDIR}/tmp/RELEASES.json" | tr -d '[:space:]') -gt 1000 ]]; then
     readarray -t "META_TAGS" < <(cat "${TMPDIR}/tmp/RELEASES.json" | jq -r --arg cutoff "${CUTOFF_DATE}" \
       '.[] | select(.tag_name | test("METADATA-[0-9]{4}_[0-9]{2}_[0-9]{2}")) | select((.published_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) >= ($cutoff | strptime("%Y-%m-%d") | mktime)) | .tag_name' |\
       grep -i "METADATA-[0-9]\{4\}_[0-9]\{2\}_[0-9]\{2\}" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | sort -u)
     break
   fi
 done
 if [[ -n "${META_TAGS[*]}" && "${#META_TAGS[@]}" -ge 2 ]]; then
   echo -e "\n[+] Total Tags: ${#META_TAGS[@]}"
   echo -e "[+] Tags: ${META_TAGS[*]}"
 else
   echo -e "\n[X] FATAL: Failed to Fetch needed Tags\n"
   echo -e "[+] Tags: ${META_TAGS[*]}"
  exit 1
  fi
#Download Assets
 unset REL_TAG
  for REL_TAG in "${META_TAGS[@]}"; do
   REL_DATE="$(echo "${REL_TAG}" | grep -o '[0-9]\{4\}_[0-9]\{2\}_[0-9]\{2\}' | tr -d '[:space:]')"
   echo -e "[+] Fetching ${REL_TAG} ==> ${TMPDIR}/assets/${REL_DATE}"
   gh release download --repo "${META_REPO}" "${REL_TAG}" --dir "${TMPDIR}/assets/${REL_DATE}" --clobber
   realpath "${TMPDIR}/assets/${REL_DATE}" && du -sh "${TMPDIR}/assets/${REL_DATE}"
  done
#Rename Assets
 find "${TMPDIR}/assets/" -mindepth 1 -type f -exec bash -c \
  '
   for file; do
    dir=$(dirname "$file")
    base=$(basename "$dir")
    mv -fv "$file" "${file%.*}_${base}.${file##*.}"
   done
  ' _ {} +
#Copy Valid Assets
 find "${TMPDIR}/assets/" -type f -iregex '.*\.json$' -exec bash -c 'jq empty "{}" 2>/dev/null && cp -f "{}" ${TMPDIR}/src/' \;
#Copy Newer Assets 
 find "${TMPDIR}/src" -type f -iregex '.*\.json$' | sort -u | awk -F'[_-]' '{base=""; for(i=1;i<=NF-1;i++) base=base (i>1?"_":"") $i; date=$(NF); file[base]=(file[base]==""||date>file[base])?date:file[base]; path[base,date]=$0} END {for(b in file) print path[b,file[b]]}' | xargs -I "{}" cp -fv "{}" "${TMPDIR}/data"
#-------------------------------------------------------#

#-------------------------------------------------------#
##Merge
 find "${TMPDIR}/data" -type f -iregex '.*\.json$' -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | \
   jq --arg host "${HOST_TRIPLET}" 'select(.host | ascii_downcase == ($host | ascii_downcase))' | \
   jq -s 'sort_by(.pkg) | unique_by(.pkg_id)' > "${TMPDIR}/AM.json.tmp"
#sanity check urls
 sed -E 's~\bhttps?:/{1,2}\b~https://~g' -i "${TMPDIR}/AM.json.tmp"
 cat "${TMPDIR}/AM.json.tmp" | jq \
   'map(
    . + {
      external: (if (.note // [] | any(test("\\[EXTERNAL\\]"))) then "true" else "false" end),
      bundle: (if (.pkg_type == "archive" and (.note // [] | any(test("\\[BUNDLE\\]")))) then "true" else "false" end),
      soar_syms: (if (.pkg_type == "archive" and (.note // [] | any(test("\\[BUNDLE\\]")))) then "true" else "false" end),
      bundle_type: (
        if (.pkg_type == "archive" and (.note // [] | any(test("tar\\.gz")))) then "tar+gz"
        elif (.pkg_type == "archive" and (.note // [] | any(test("tar\\.xz")))) then "tar+xz"
        elif (.pkg_type == "archive" and (.note // [] | any(test("tar\\.zst")))) then "tar+zstd"
        elif (.pkg_type == "archive" and (.note // [] | any(test("\\[BUNDLE\\]"))) and (.note // [] | any(test("tar\\.(gz|xz|zst)")) | not)) then "tar"
        else ""
        end
      ),
      deprecated: (if (.note // [] | any(test("\\[DEPRECATED\\]"))) then "true" else "false" end),
      desktop_integration: (if (.note // [] | any(test("\\[NO_DESKTOP_INTEGRATION\\]"))) then "false" else "true" end),
      installable: (if (.note // [] | any(test("\\[NO_INSTALL\\]"))) then "false" else "true" end),
      portable: (if (.note // [] | any(test("\\[PORTABLE\\]"))) then "true" else "false" end),
      recurse_provides: (if (.note // [] | any(test("\\[NO_RECURSE_PROVIDES\\]"))) then "false" else "false" end),
      trusted: "false"
    })' | jq 'map(to_entries | sort_by(.key) | from_entries)' |\
 jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | jq 'if type == "array" then . else [.] end' | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "")) | select(length > 0) elif type == "array" then map(select(. != null and . != "")) | select(length > 0) else . end)' |\
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
 if [[ "${PKG_COUNT}" -le 5 ]]; then
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
if [ -s "${SYSTMP}/AM.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  mkdir -pv "${GITHUB_WORKSPACE}/main/external/am/data"
  cd "${GITHUB_WORKSPACE}/main/external/am/data"
  [[ ! -f "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json" ]] &&\
   echo '[]' > "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json"
  jq -s 'map(.[]) | group_by(.pkg_id) | map(if length > 1 then .[1] + .[0] else .[0] end) | unique_by(.download_url) | sort_by(.pkg)' "${SYSTMP}/AM.json" "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json" | jq . > "${SYSTMP}/merged.json.tmp"
 #Fix Descr
  jq -s '
    (.[1] | map({(.pkg): .description}) | add) as $descs |
    .[1] as $descr_array |
    .[0] | map(
      if .description | contains("------") then
        . as $am |
        ($descr_array[] | select(.pkg == $am.pkg)) as $desc |
        if ($am.build_script == $desc.source_blob or $am.build_script == $desc.source_raw) then
          .description = ($descs[.pkg] // "No Description Provided")
        else
          .description = "No Description Provided"
        end
      else
        .
      end
    )
  ' "${SYSTMP}/merged.json.tmp" "${SYSTMP}/DESCR.json" | jq . > "${SYSTMP}/merged.json"
 #Copy
  if [[ "$(jq -r '.[] | .pkg_id' "${SYSTMP}/merged.json" | sort -u | wc -l | tr -d '[:space:]')" -gt 50 ]]; then
    #cat "${SYSTMP}/merged.json" | jq '[ .[] | select(.pkg_type? and (.pkg_type | test("appimage"; "i"))) ]' |\
    cat "${SYSTMP}/merged.json" | jq '[ .[] | select(.pkg_type? and (.pkg_type | test("^(appimage|archive)$"; "i"))) ]' |\
     jq . > "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json"
  fi
  #Checksum
  generate_checksum()
  {
      b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
  }
  generate_checksum "${HOST_TRIPLET}.json"
 #To SDB
  soarql --repo "ivan-hc-am" --input "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.json" --output "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.sdb"
  generate_checksum "${HOST_TRIPLET}.sdb"
   if [[ $(stat -c%s "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.sdb") -le 1024 ]] || file -i "${GITHUB_WORKSPACE}/main/external/am/data/${HOST_TRIPLET}.sdb" | grep -qiv 'sqlite'; then
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
 #Gen & Upload AM (HF-Mirror-Only) [aarch64-Linux]
  #curl -qfsSL "https://hf.bincache.pkgforge.dev/aarch64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' > "${SYSTMP}/aarch64-Linux.AM.txt"
  curl -qfsSL "https://github.com/pkgforge/bincache/releases/download/metadata/aarch64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' > "${SYSTMP}/aarch64-Linux.AM.txt"
  #curl -qfsSL "https://hf.pkgcache.pkgforge.dev/aarch64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' >> "${SYSTMP}/aarch64-Linux.AM.txt"
  curl -qfsSL "https://github.com/pkgforge/pkgcache/releases/download/metadata/aarch64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' >> "${SYSTMP}/aarch64-Linux.AM.txt"
  sed '/ghcr.io/!d' -i "${SYSTMP}/x86_64-Linux.AM.txt"
  sort -u "${SYSTMP}/aarch64-Linux.AM.txt" -o "${SYSTMP}/aarch64-Linux.AM.txt"
  sed '/|[[:space:]]*|/d' -i "${SYSTMP}/aarch64-Linux.AM.txt"
  if [[ "$(wc -l < "${SYSTMP}/aarch64-Linux.AM.txt" | tr -d '[:space:]')" -ge 100 ]]; then
    sort -u "${SYSTMP}/aarch64-Linux.AM.txt" -o "${GITHUB_WORKSPACE}/main/external/am/data/aarch64-Linux.AM.txt"
    sed '/|[[:space:]]*|/d' -i "${GITHUB_WORKSPACE}/main/external/am/data/aarch64-Linux.AM.txt"
  fi
 #Gen & Upload AM (HF-Mirror-Only) [x86_64-Linux]
  #curl -qfsSL "https://hf.bincache.pkgforge.dev/x86_64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' > "${SYSTMP}/x86_64-Linux.AM.txt"
  curl -qfsSL "https://github.com/pkgforge/bincache/releases/download/metadata/x86_64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' > "${SYSTMP}/x86_64-Linux.AM.txt"
  #curl -qfsSL "https://hf.pkgcache.pkgforge.dev/x86_64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' >> "${SYSTMP}/x86_64-Linux.AM.txt"
  curl -qfsSL "https://github.com/pkgforge/pkgcache/releases/download/metadata/x86_64-Linux.json" | jq -r '.[] | "| \(.pkg_name)#\(.pkg_id) | \(.description) | \(((.src_url[0] // .homepage[0]) // "N/A")) | \(.ghcr_blob) | \((if .version then .version else (.bsum // "latest")[:12] end)) |"' >> "${SYSTMP}/x86_64-Linux.AM.txt"
  sed '/ghcr.io/!d' -i "${SYSTMP}/x86_64-Linux.AM.txt"
  sort -u "${SYSTMP}/x86_64-Linux.AM.txt" -o "${SYSTMP}/x86_64-Linux.AM.txt"
  sed '/|[[:space:]]*|/d' -i "${SYSTMP}/x86_64-Linux.AM.txt"
  if [[ "$(wc -l < "${SYSTMP}/x86_64-Linux.AM.txt" | tr -d '[:space:]')" -ge 100 ]]; then
    sort -u "${SYSTMP}/x86_64-Linux.AM.txt" -o "${GITHUB_WORKSPACE}/main/external/am/data/x86_64-Linux.AM.txt"
    sed '/|[[:space:]]*|/d' -i "${GITHUB_WORKSPACE}/main/external/am/data/x86_64-Linux.AM.txt"
  fi
  wait ; echo
fi
#-------------------------------------------------------#
