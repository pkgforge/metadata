#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Generate AM Json
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/cargo-bins/scripts/gen_meta.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/cargo-bins/scripts/gen_meta.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
export HOST_TRIPLET="$(uname -m)-$(uname -s)"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
mkdir -pv "${TMPDIR}/assets" "${TMPDIR}/data" "${TMPDIR}/src" "${TMPDIR}/tmp"
rm -rvf "${SYSTMP}/${HOST_TRIPLET}.json" 2>/dev/null
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
 REL_REPO="cargo-bins/cargo-quickinstall"
 CUTOFF_DATE="$(date --utc -d '24 months ago' '+%Y-%m-%d' | tr -d '[:space:]')"
 export REL_REPO CUTOFF_DATE
 for i in {1..5}; do
   gh api "repos/${REL_REPO}/releases" --paginate 2>/dev/null |& cat - > "${TMPDIR}/tmp/RELEASES.json"
   if [[ $(stat -c%s "${TMPDIR}/tmp/RELEASES.json" | tr -d '[:space:]') -lt 10000 ]]; then
     echo "Retrying... ${i}/5"
     sleep 2
   elif [[ $(stat -c%s "${TMPDIR}/tmp/RELEASES.json" | tr -d '[:space:]') -gt 10000 ]]; then
     jq -nr --stream 'fromstream(1|truncate_stream(inputs))? | 
       select((.published_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) >= ($cutoff | strptime("%Y-%m-%d") | mktime)) | 
       .tag_name' --arg cutoff "${CUTOFF_DATE}" "${TMPDIR}/tmp/RELEASES.json" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' |\
     sort -u -o "${TMPDIR}/tmp/TAGS.txt"
     sed -E 's/^[[:space:]]+|[[:space:]]+$//g' -i "${TMPDIR}/tmp/TAGS.txt"
     unset REPO_TAGS ; readarray -t "REPO_TAGS" < <(cat "${TMPDIR}/tmp/TAGS.txt" | awk 'function extract_version(s){match(s,/[0-9]+(\.[0-9]+)+/);return substr(s,RSTART,RLENGTH)} function pkg_name(s){match(s,/^[^0-9]*/);return substr(s,RSTART,RLENGTH-1)} function compare_versions(v1,v2){split(v1,a,".");split(v2,b,".");for(i=1;i<=length(a)&&i<=length(b);i++){if(a[i]+0<b[i]+0)return -1;if(a[i]+0>b[i]+0)return 1}if(length(a)<length(b))return -1;if(length(a)>length(b))return 1;return 0}{p=pkg_name($0);v=extract_version($0);if(!(p in latest)||compare_versions(latest_ver[p],v)<0){latest[p]=$0;latest_ver[p]=v}}END{for(p in latest)print latest[p]}' | sort -u | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | sort -u)
     break
   fi
 done
#Sanity check
  if [[ -n "${REPO_TAGS[*]}" && "${#REPO_TAGS[@]}" -ge 2 ]]; then
    echo -e "\n[+] Total Tags: ${#REPO_TAGS[@]}"
    echo -e "[+] Tags: ${REPO_TAGS[*]}"
  else
    echo -e "\n[X] FATAL: Failed to Fetch needed Tags\n"
    echo -e "[+] Tags: ${REPO_TAGS[*]}"
   exit 1
  fi
popd &>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Loop & Generate Meta
generate_meta()
{
 ##Chdir
  pushd "${TMPDIR}" &>/dev/null
 ##Enable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set -x
  fi
 ##Main
  export PKG_NAME_TAG="$1"
  echo -e "\n[+] Processing ${PKG_NAME_TAG##*[[:space:]]}\n"
  unset BUILD_DATE BUILD_DATE_TMP CRATE_NAME CRATE_VERSION_TMP PKG_BIN_ASSETS PKG_APP_ENTRY PKG_ASSET PKG_DOWNLOAD_URL PKG_LICENSE PKG_NAME PKG_TAGS PKG_SIZE PKG_SIZE_RAW PKG_SRC_URL PKG_VERSION PKG_VERSION_TMP PKG_VERSION_UPSTREAM
  #Get GH Metadata
   curl -qfsSl "https://api.gh.pkgforge.dev/repos/${REL_REPO}/releases/tags/${PKG_NAME_TAG}" | jq . > "${TMPDIR}/assets/${PKG_NAME_TAG}.gh.json"
   unset REL_COUNT ; REL_COUNT="$(jq -r '.. | objects | select(has("browser_download_url")) | .browser_download_url' "${TMPDIR}/assets/${PKG_NAME_TAG}.gh.json" | grep -iv 'null' | grep -i 'http' | grep -i 'linux' | sort -u | wc -l | tr -d '[:space:]')"
    #Sanity Check Releases
     if [[ "${REL_COUNT}" -le 1 ]]; then
        echo -e "\n[X] ${PKG_NAME_TAG} has No Entry (Linux) ==> https://github.com/${REL_REPO}/releases/tag/${PKG_NAME_TAG} (skipping ...)\n"
       return
     else
       PKG_SRC_URL="https://github.com/${REL_REPO}/releases/tag/${PKG_NAME_TAG}"
       PKG_VERSION="$(echo "${PKG_NAME_TAG}" | awk -F'-' '{print $NF}' | awk '{gsub(/^-+|-+$/,""); print}' | tr -d '[:space:]')"
     fi
    #Parse
     PKG_BIN_ASSETS=()
     readarray -t "PKG_BIN_ASSETS" < <(jq -r '.. | objects | select(has("browser_download_url")) | .browser_download_url' "${TMPDIR}/assets/${PKG_NAME_TAG}.gh.json" | grep -iv 'null' | grep -i 'http' | grep -i 'linux' | grep -v '^[[:space:]]*$' | grep -Eiv "\.sig$" | sort -u)
     for PKG_ASSET in "${PKG_BIN_ASSETS[@]}"; do
       if echo "${PKG_ASSET}" | grep -qi "http"; then
         ARCH="$(uname -m | tr -d '[:space:]')"
         case "${ARCH}" in
           aarch64)
             if echo "${PKG_ASSET}" | grep -qiE "aarch|arm64"; then
               if echo "${PKG_ASSET}" | grep -qi "musl"; then
                 PKG_DOWNLOAD_URL="$(echo "${PKG_ASSET}" | grep -Ei "aarch|arm64" | grep -Ei "musl" | head -n 1 | tr -d '[:space:]')"
                 break
               elif echo "${PKG_ASSET}" | grep -qi "gnu"; then
                 PKG_DOWNLOAD_URL="$(echo "${PKG_ASSET}" | grep -Ei "aarch|arm64" | grep -Ei "gnu" | head -n 1 | tr -d '[:space:]')"
                 break
               fi
             fi
             ;;
           x86_64)
             if echo "${PKG_ASSET}" | grep -qiE "amd64|x86_64"; then
               if echo "${PKG_ASSET}" | grep -qi "musl"; then
                 PKG_DOWNLOAD_URL="$(echo "${PKG_ASSET}" | grep -Ei "amd64|x86_64" | grep -Ei "musl" | head -n 1 | tr -d '[:space:]')"
                 break
               elif ! echo "${PKG_ASSET}" | grep -qi "gnu"; then
                 PKG_DOWNLOAD_URL="$(echo "${PKG_ASSET}" | grep -Ei "amd64|x86_64" | grep -Ei "gnu" | head -n 1 | tr -d '[:space:]')"
                 break
               fi
             fi
             ;;
         esac
       fi
     done
    #Check Download URL
     if echo "${PKG_DOWNLOAD_URL}" | grep -qiE 'http'; then
       echo -e "[+] Download URL ==> ${PKG_DOWNLOAD_URL}"
       PKG_SIZE_RAW="$(jq --arg DL_URL "${PKG_DOWNLOAD_URL}" -r '.. | objects | select(.browser_download_url? == $DL_URL) | .size' "${TMPDIR}/assets/${PKG_NAME_TAG}.gh.json")"
       PKG_SIZE="$(echo "${PKG_SIZE_RAW}" | awk '{byte=$1; if (byte<1024) printf "%.2f B\n", byte; else if (byte<1024**2) printf "%.2f KB\n", byte/1024; else if (byte<1024**3) printf "%.2f MB\n", byte/(1024**2); else printf "%.2f GB\n", byte/(1024**3)}')"
       echo -e "[+] Size ==> ${PKG_SIZE}"
       echo -e "[+] Size (RAW) ==> ${PKG_SIZE_RAW}"
     else
       echo -e "[-] FATAL: Failed to find Any Github Release <== ${PKG_DOWNLOAD_URL}"
       return
     fi
    #Check Build Date
     BUILD_DATE_TMP="$(jq --arg "tag" "${PKG_NAME_TAG}" -r '.. | objects | select(.tag_name? == $tag) | .published_at' "${TMPDIR}/assets/${PKG_NAME_TAG}.gh.json" | grep -iv 'null' | tr -d '[:space:]')"
     if [[ "${BUILD_DATE_TMP}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
       BUILD_DATE="${BUILD_DATE_TMP}"
       echo -e "[+] Build Date ==> ${BUILD_DATE}"
     else
       BUILD_DATE="$(date --utc -u +"%Y-%m-%dT%H:%M:%SZ" | tr -d '[:space:]')"
       echo -e "[+] Build Date ==> ${BUILD_DATE}"
     fi
  #Get Crates Metadata
   CRATE_NAME="$(echo "${PKG_NAME_TAG}" | awk -F'-[0-9]+[0-9.]*$' '{print $1}' | tr -d '[:space:]')"
   CRATE_VERSION_TMP="$(echo "${PKG_NAME_TAG}" | awk '{match($0, /[0-9]+[0-9.]*$/); print substr($0, RSTART)}')"
   echo -e "[+] Crate ==> ${CRATE_NAME} (${CRATE_VERSION_TMP})"
   curl -qfsSL "https://crates.io/api/v1/crates/${CRATE_NAME}" | jq . > "${TMPDIR}/tmp/${PKG_NAME_TAG}.crates.json"
   cat "${TMPDIR}/tmp/${PKG_NAME_TAG}.crates.json" | jq \
     '
     (.. | objects | select(has("name") and has("description"))) | {
       pkg: .name?,
       pkg_family: .name?,
       description: .description?,
       version: (.newest_version? // .max_version? // .version?),
       homepage: (.repository? // .homepage? // .documentation?)
     }' > "${TMPDIR}/assets/${PKG_NAME_TAG}.crates.json"
   if jq --arg "C_N" "${CRATE_NAME}" '.pkg == $C_N and .version and .version != ""' "${TMPDIR}/assets/${PKG_NAME_TAG}.crates.json" | grep -qi 'true'; then
    #Name
     PKG_NAME="${CRATE_NAME##*[[:space:]]}"
    #Version 
     PKG_VERSION_UPSTREAM="$(jq -r '.version' "${TMPDIR}/assets/${PKG_NAME_TAG}.crates.json" 2>/dev/null | grep -iv 'null' | tr -d '[:space:]')"
    #Description 
     PKG_DESCRIPTION="$(jq -r '.description' "${TMPDIR}/assets/${PKG_NAME_TAG}.crates.json" 2>/dev/null | grep -iv 'null' | sed 's/`//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed ':a;N;$!ba;s/\r\n//g; s/\n//g' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g')"
     if [[ "$(echo "${PKG_DESCRIPTION}" | tr -d '[:space:]' | wc -c)" -ge 5 ]]; then
       echo "[+] Description: ${PKG_DESCRIPTION}"
     else
       PKG_DESCRIPTION="No Description Provided"
     fi
    #Download Count
     PKG_DOWNLOAD_COUNT="$(jq -r '.. | objects | select(has("recent_downloads")) | .recent_downloads' "${TMPDIR}/tmp/${PKG_NAME_TAG}.crates.json" | grep -iv 'null' | head -n 1 | tr -cd '[:digit:]')"
     if [[ "$(echo "${PKG_DOWNLOAD_COUNT}" | tr -d '[:space:]')" -ge 5 ]]; then
       echo "[+] Download Count: ${PKG_DOWNLOAD_COUNT}"
     else
       PKG_DOWNLOAD_COUNT="-1"
     fi
    #Homepage 
     PKG_HOMEPAGE="$(jq -r '.homepage' "${TMPDIR}/assets/${PKG_NAME_TAG}.crates.json" 2>/dev/null | grep -iv 'null' | grep -i 'http' | tr -d '[:space:]')"
     if [[ "$(echo "${PKG_HOMEPAGE}" | tr -d '[:space:]' | wc -c)" -ge 5 ]]; then
       echo "[+] Homepage: ${PKG_HOMEPAGE}"
     else
       PKG_HOMEPAGE="https://crates.io/crates/${CRATE_NAME}"
     fi
    #ID
     PKG_ID="cargo-bins.${PKG_NAME_TAG}.${PKG_NAME}"
    #License
     PKG_LICENSE="$(jq -r '.. | objects | select(has("license")) | .license' "${TMPDIR}/tmp/${PKG_NAME_TAG}.crates.json" | grep -iv 'null' | head -n 1 | sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g' | sed 's/^, //; s/, $//')"
     if [[ "$(echo "${PKG_LICENSE}" | tr -d '[:space:]' | wc -c)" -ge 2 ]]; then
       echo "[+] License: ${PKG_LICENSE}"
     else
       PKG_LICENSE="Blessing"
     fi
    #Provides
     PKG_PROVIDES="$(jq -r '.. | objects | select(has("bin_names")) | .bin_names' | jq -r 'if type == "array" then .[] else . end' | tr -d '[]' | sort -u | grep -v '^null$' | grep -v '^$' | sort -u | paste -sd, - |  tr -d '[:space:]' | sed 's/^,\+//; s/,\+$//; s/,\+/,/g; s/,/, /g')"
               
     if [[ "$(echo "${PKG_PROVIDES}" | tr -d '[:space:]' | wc -c)" -ge 2 ]]; then
       echo "[+] Provides: ${PKG_PROVIDES}"
     else
       PKG_PROVIDES="${PKG_NAME}"
     fi
    #Tags
     PKG_TAGS="$(jq -r '.. | objects | select(has("keyword")) | .keyword' "${TMPDIR}/tmp/${PKG_NAME_TAG}.crates.json" | tr -d '[]' | sort -u | grep -iv 'null' | paste -sd, - | tr -d '[:space:]' | sed 's/, /, /g' | sed 's/,/, /g' | sed 's/|//g' | sed 's/"//g' | sed 's/^, //; s/, $//')" 
     if [[ "$(echo "${PKG_TAGS}" | tr -d '[:space:]' | wc -c)" -ge 3 ]]; then
       echo "[+] Tags: ${PKG_TAGS}"
     else
       PKG_TAGS="Utility"
     fi
   else
      echo -e "\n[X] ${CRATE_NAME} has No Entry ==> https://crates.io/crates/${CRATE_NAME} (skipping ...)\n"
     return
   fi
  #Generate Json
    jq -n --arg HOST "${HOST_TRIPLET}" \
       --arg PKG_NAME "${PKG_NAME}" \
       --arg PKG_ID "${PKG_ID}" \
       --arg PKG_WEBPAGE "${PKG_HOMEPAGE}" \
       --arg BUILD_DATE "${BUILD_DATE}" \
       --arg DESCRIPTION "${PKG_DESCRIPTION}" \
       --arg DOWNLOAD_COUNT "${PKG_DOWNLOAD_COUNT}" \
       --arg DOWNLOAD_URL "${PKG_DOWNLOAD_URL}" \
       --arg LICENSE "${PKG_LICENSE}" \
       --arg PROVIDES "${PKG_PROVIDES}" \
       --arg RANK "${RANK}" \
       --arg SIZE "${PKG_SIZE}" \
       --arg SIZE_RAW "${PKG_SIZE_RAW}" \
       --arg SRC_URL "${PKG_SRC_URL}" \
       --arg TAGS "${PKG_TAGS}" \
       --arg VERSION "${PKG_VERSION}" \
       --arg VERSION_UPSTREAM "${PKG_VERSION_UPSTREAM}" \
     '
      {
        _disabled: ("false"),
        host: ($HOST | tostring),
        pkg: ($PKG_NAME | tostring),
        pkg_id: ($PKG_ID | gsub("[[:space:]]"; "") | gsub("^\\.+|\\.+$"; "")),
        pkg_name: ($PKG_NAME | ascii_downcase | gsub("[[:space:]]"; "")),
        pkg_type: ("archive"),
        pkg_webpage: ($PKG_WEBPAGE | tostring),
        build_date: ($BUILD_DATE | tostring),
        category: (.categories // []),
        description: ($DESCRIPTION 
          | gsub("<[^>]*>"; "") | gsub("\\s+"; " ") 
          | gsub("^\\s+|\\s+$"; "") | gsub("^\\.+|\\.+$"; "")),
        download_count: ($DOWNLOAD_COUNT | tostring),
        download_url: ($DOWNLOAD_URL | tostring),
        homepage: [($PKG_WEBPAGE | tostring)],
        license: ($LICENSE | split(",") | map(gsub("^\\s+|\\s+$"; "")) | unique | sort),
        maintainer: [
        "cargo-bins (https://github.com/cargo-bins/cargo-quickinstall)"
        ],
        note: [
        "[NO_BUNDLE] (This is an archive only with no SOAR_SYMS)",
        "[EXTERNAL] (This is an unofficial, third-party repository)",
        "This data was autogenerated & is likely inaccurate",
        "Data used: https://github.com/cargo-bins/cargo-quickinstall/releases",
        "Provided by: https://github.com/cargo-bins/cargo-quickinstall",
        "Learn More: https://docs.pkgforge.dev/repositories/external/cargo-bins",
        "Please create an Issue or send a PR for an official Package"
        ],
        provides: ($PROVIDES | split(",") | map(gsub("^\\s+|\\s+$"; "")) | unique | sort),
        rank: ($RANK | tostring),
        size: ($SIZE | tostring),
        size_raw: ($SIZE_RAW | tostring),
        src_url: [($SRC_URL | tostring)],
        tag: ($TAGS | split(",") | map(gsub("^\\s+|\\s+$"; "")) | unique | sort),
        version: ($VERSION | tostring),
        version_upstream: ($VERSION_UPSTREAM | tostring)
      }
     ' | jq . > "${TMPDIR}/data/${PKG_NAME_TAG}.json.raw"
 #Sanity Check   
   if jq -r '.pkg' "${TMPDIR}/data/${PKG_NAME_TAG}.json.raw" | grep -iv 'null' | tr -d '[:space:]' | grep -Eiq "^${PKG_NAME}$"; then
     mv -fv "${TMPDIR}/data/${PKG_NAME_TAG}.json.raw" "${TMPDIR}/data/${PKG_NAME_TAG}.json"
   else
     mv -fv "${TMPDIR}/data/${PKG_NAME_TAG}.json.raw" "${TMPDIR}/tmp/${PKG_NAME_TAG}.json.raw"
   fi
 ##Disable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set +x
  fi
}
export -f generate_meta
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate
pushd "${TMPDIR}" &>/dev/null
 printf '%s\n' "${REPO_TAGS[@]}" | xargs -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" -I "{}" timeout -k 10s 180s bash -c 'generate_meta "$@"' _ "{}"
popd &>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Merge
echo -e "\n[+] Merging ...\n"
find "${TMPDIR}/data/" -type f -name '*.json' ! -iname "*.raw" -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | jq -s 'sort_by(.pkg)' > "${TMPDIR}/cargo-bins.json.raw"
##Sort Rank
jq '
 def compute_ranks:
    map(select(.rank == "" and .download_count != "" and .pkg != null)) |
    map({
      pkg: (.pkg // "unknown"),
      download_count: (try (.download_count | tonumber) catch 0)
    }) |
    sort_by([ - .download_count, .pkg_name ]) |
    to_entries |
    map({
      key: .value.pkg,
      value: (.key + 1 | tostring)
    }) |
    from_entries;

  . as $original |
  compute_ranks as $ranks |
  map(
    if .rank == "" and .download_count != "" and .pkg != null then
      .rank = ($ranks[.pkg] // .rank)
    else
      .
    end
  )' "${TMPDIR}/cargo-bins.json.raw" | jq 'map(if .rank == "" then .rank = null else .rank = (.rank | tonumber) end) |
  map(.download_count = (.download_count | tonumber)) |
  (map(select(.download_count != "")) | sort_by(.rank, .pkg)) as $valid_entries |
  (map(select(.download_count == "")) | sort_by(.pkg)) as $invalid_entries |
  ($valid_entries + $invalid_entries) | to_entries | map(.value.rank = (.key + 1 | tostring)) |
  map(.value) | sort_by(.pkg)' | jq . > "${TMPDIR}/cargo-bins.json.tmp"
#sanity check urls
sed -E 's~\bhttps?:/{1,2}\b~https://~g' -i "${TMPDIR}/cargo-bins.json.tmp"
cat "${TMPDIR}/cargo-bins.json.tmp" | jq \
   'map(
    . + {
      external: (if (.note // [] | any(test("\\[EXTERNAL\\]"))) then "true" else "false" end),
      bundle: "false",
      soar_syms: "false",
      deprecated: (if (.note // [] | any(test("\\[DEPRECATED\\]"))) then "true" else "false" end),
      desktop_integration: "false",
      installable: (if (.note // [] | any(test("\\[NO_INSTALL\\]"))) then "false" else "true" end),
      portable: (if (.note // [] | any(test("\\[PORTABLE\\]"))) then "true" else "false" end),
      recurse_provides: (if (.note // [] | any(test("\\[NO_RECURSE_PROVIDES\\]"))) then "false" else "true" end),
      trusted: "true"
    })' | jq 'map(to_entries | sort_by(.key) | from_entries)' |\
 jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | jq 'if type == "array" then . else [.] end' | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "")) | select(length > 0) elif type == "array" then map(select(. != null and . != "")) | select(length > 0) else . end)' |\
 jq 'map(select(
    .pkg != null and .pkg != "" and
    .pkg_id != null and .pkg_id != "" and
    .pkg_name != null and .pkg_name != "" and
    .description != null and .description != "" and
    .download_url != null and .download_url != "" and
    .version != null and .version != ""
 ))' | jq 'unique_by(.download_url) | sort_by(.pkg)' | jq . > "${TMPDIR}/cargo-bins.json.final"
##Check
unset PKG_COUNT; PKG_COUNT="$(jq -r '.[] | .pkg_id' "${TMPDIR}/cargo-bins.json.final" | sort -u | wc -l | tr -d '[:space:]')"
if [[ "${PKG_COUNT}" -le 20 ]]; then
 echo -e "\n[X] FATAL: Final Package Count is < 20, Parsing Failed?\n"
 echo "[-] Count: ${PKG_COUNT}"
 exit 1
else
 echo -e "\n[+] Packages: ${PKG_COUNT}"
 mv -fv "${TMPDIR}/cargo-bins.json.final" "${SYSTMP}/cargo-bins.json"
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/external/cargo-bins/data"
if [ -s "${SYSTMP}/cargo-bins.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  mkdir -pv "${GITHUB_WORKSPACE}/main/external/cargo-bins/data"
  cd "${GITHUB_WORKSPACE}/main/external/cargo-bins/data"
  [[ ! -f "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.json" ]] &&\
   echo '[]' > "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.json"
  jq -s 'map(.[]) | group_by(.pkg_id) | map(if length > 1 then .[1] + .[0] else .[0] end) | unique_by(.pkg_id) | sort_by(.pkg)' \
  "${SYSTMP}/cargo-bins.json" "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.json" | jq . > "${SYSTMP}/merged.json"
  if [[ "$(jq -r '.[] | .pkg_id' "${SYSTMP}/merged.json" | sort -u | wc -l | tr -d '[:space:]')" -gt 20 ]]; then
   if [[ "${HOST_TRIPLET//[[:space:]]/}" == "aarch64-Linux" ]]; then
     cat "${SYSTMP}/merged.json" | jq 'del(.[] | select(.download_url | test("amd64|i686|x86_64"; "i")))' |\
       jq . > "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.json"
   elif [[ "${HOST_TRIPLET//[[:space:]]/}" == "x86_64-Linux" ]]; then
     cat "${SYSTMP}/merged.json" | jq 'del(.[] | select(.download_url | test("aarch64|armhf|arm64"; "i")))' |\
       jq . > "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.json"
   fi
  fi
  #Checksum
  generate_checksum()
  {
    b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
  }
  generate_checksum "${HOST_TRIPLET}.json"
 #To SDB
  soarql --repo "cargo-bins" --input "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.json" --output "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.sdb"
  generate_checksum "${HOST_TRIPLET}.sdb"
   if [[ $(stat -c%s "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.sdb") -le 1024 ]] || file -i "${GITHUB_WORKSPACE}/main/external/cargo-bins/data/${HOST_TRIPLET}.sdb" | grep -qiv 'sqlite'; then
     echo -e "\n[✗] FATAL: Failed to generate Soar DB...\n"
     echo "META_GEN=FAILED" >> "${GITHUB_ENV}"
   exit 1
   fi
 #To Xz 
  xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "${HOST_TRIPLET}.json" ; generate_checksum "${HOST_TRIPLET}.json.xz"
  xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "${HOST_TRIPLET}.sdb" ; generate_checksum "${HOST_TRIPLET}.sdb.xz"
 #To ZSTD
  zstd --ultra -22 --force "${HOST_TRIPLET}.json" -o "${HOST_TRIPLET}.json.zstd" ; generate_checksum "${HOST_TRIPLET}.json.zstd"
  zstd --ultra -22 --force "${HOST_TRIPLET}.sdb" -o "${HOST_TRIPLET}.sdb.zstd" ; generate_checksum "${HOST_TRIPLET}.sdb.zstd"
fi
#-------------------------------------------------------#
