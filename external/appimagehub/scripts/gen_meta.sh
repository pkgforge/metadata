#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Convert https://api.appimagehub.com/ocs/v1/content/data to a more useful data
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimagehub/scripts/gen_meta.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimagehub/scripts/gen_meta.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
export HOST_TRIPLET="$(uname -m)-$(uname -s)"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
mkdir -pv "${TMPDIR}/data" "${TMPDIR}/processed" "${TMPDIR}/tmp"
if [[ -z "${USER_AGENT}" ]]; then
 USER_AGENT="$(curl -qfsSL 'https://pub.ajam.dev/repos/Azathothas/Wordlists/Misc/User-Agents/ua_chrome_macos_latest.txt')"
fi
rm -rvf "${SYSTMP}/appimagehub.json" 2>/dev/null
##Install Requirements
#-------------------------------------------------------#

#-------------------------------------------------------#
##Get Data
pushd "${TMPDIR}" &>/dev/null
export BATCH_SIZE="2"
export TOTAL="5000"
export SHOULD_EXIT="0"
for ((i=1; i<=${TOTAL}; i+=${BATCH_SIZE})); do
  [[ "${SHOULD_EXIT}" -eq 1 ]] && break
   echo -e "\n[+] Processing batch starting at ${i} [Max: ${BATCH_SIZE}]"
    for ((j=0; j<${BATCH_SIZE} && i+j<=${TOTAL}; j++)); do
     unset M_FILE PAGE
     PAGE="$((i+j))"
     M_FILE="${TMPDIR}/data/${PAGE}.json"
     (
      curl -A "${USER_AGENT}" -qfsSL "https://api.appimagehub.com/ocs/v1/content/data?page=${PAGE}&format=json" > "${M_FILE}"
      if [[ "$(stat -c%s "${M_FILE}" 2>/dev/null)" -gt 100 ]]; then
       echo "[+] AppImageHub (${PAGE}/${TOTAL}) ["$(du -sh ${M_FILE})"]"
      fi
     ) &
    done
   wait &>/dev/null
    for ((j=0; j<${BATCH_SIZE} && i+j<=${TOTAL}; j++)); do
     unset C_FILE PAGE
     PAGE="$((i+j))"
     C_FILE="${TMPDIR}/data/${PAGE}.json"
     #Check for "out of range" in file content
      if [ "$(stat -c%s "${C_FILE}" 2>/dev/null)" -lt 100 ] &&\
       grep -Eqi "out[[:space:]]*of[[:space:]]*range" "${C_FILE}" 2>/dev/null; then
         echo -e "[-] Out of range error detected at page ${PAGE}. Stopping ..."
         export SHOULD_EXIT="1"
        break
      fi
    done
done
popd &>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Check Data
find "${TMPDIR}/data/" -type f -name '*.json' -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | jq -c '[recurse | objects | select(has("id"))] | if length > 0 then .[] else {} end' | jq -s 'sort_by(.detailpage)' > "${TMPDIR}/data/appimagehub.json.tmp"
AI_COUNT="$(jq -r '.. | .detailpage? // empty' "${TMPDIR}/data/appimagehub.json.tmp" | wc -l | tr -d '[:space:]')" ; export AI_COUNT
if [[ "${AI_COUNT}" -le 500 ]]; then
 echo -e "\n[X] FATAL: AppImage Count is < 500, Parsing Failed?\n"
 exit 1
else
 echo -e "[+] AppImages: ${AI_COUNT} <== https://appimagehub.com"
fi
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
  export PKG_PAGE="$1"
  echo -e "\n[+] Processing ${PKG_PAGE##*[[:space:]]}\n"
  unset PKG_BUILD_DATE PKG_BUILD_DATE_TMP PKG_DESCRIPTION_TMP PKG_DOWNLOAD_COUNT PKG_DL_URL PKG_DL_URL_TMP PKG_DOWNLOAD_URL PKG_ID PKG_ID_AIH PKG_ID_BASE PKG_ID_TMP PKG_MDSUM PKG_MDSUM_TMP PKG_SCREENSHOTS PKG_SIZE PKG_SIZE_RAW PKG_SIZE_TMP PKG_VERSION PKG_VERSION_TMP T_ID
   #Sanity Check
     PKG_ID_BASE="$(basename "${PKG_PAGE}" | tr -d '[:space:]')"
     PKG_ID_AIH="$(echo "${PKG_ID_BASE}" | tr -cd '0-9' | tr -d '[:space:]')"
     jq --arg P_PAGE "${PKG_PAGE}" '.[] | select(.detailpage == $P_PAGE)' "${TMPDIR}/data/appimagehub.json.tmp" | jq . > "${TMPDIR}/tmp/${PKG_ID_BASE}.json"
     if [[ ! -s "${TMPDIR}/tmp/${PKG_ID_BASE}.json" || $(stat -c%s "${TMPDIR}/tmp/${PKG_ID_BASE}.json") -le 10 ]]; then
       echo -e "[-] FATAL: Failed to fetch JSON <== [${PKG_NAME}] (${PKG_ID_BASE})"
       return 1
     fi
    #Fetch Needed vars
     #Name
       PKG_NAME="$(jq -r '.. | .name? // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | grep -iv 'null' |\
         sed 's/[[:space:]]\+\([[:alnum:]]\)/\-\1/g' | sed 's/`//g' | sed 's/^[ \t]*//;s/[ \t]*$//' |\
         sed ':a;N;$!ba;s/\r\n//g; s/\n//g' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g' |\
         sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | sed 's/\.$//' | tr -d '[:space:]')"
       if [[ "$(echo "${PKG_NAME}" | tr -d '[:space:]' | wc -c)" -lt 1 ]]; then
         echo -e "[-] FATAL: Failed to fetch Name <== [${PKG_NAME}] (${PKG_ID_BASE})"
         return
       else
         PKG_NAME="${PKG_NAME,,}"
         echo -e "[+] Name ==> ${PKG_NAME}"
       fi
     #ID
       PKG_ID_TMP="appimagehub.${PKG_ID_AIH}.${PKG_NAME}"
       PKG_ID="$(echo "${PKG_ID_TMP}" | tr -d '[:space:]')"
       if echo "${PKG_ID_AIH}" | grep -qi '^[0-9]\+$'; then
         echo -e "[+] ID ==> ${PKG_ID_AIH} [${PKG_NAME}] (${PKG_ID_BASE})"
       else
         echo -e "[-] FATAL: Failed to fetch ID <== [${PKG_NAME}] (${PKG_ID_BASE})"
         return 1
       fi
     #Checksum
       PKG_MDSUM_TMP="$(jq -r '[ .. | objects | .downloadmd5sum?, .downloadmd5sum1?, .downloadmd5sum2?, .downloadmd5sum3? ] | flatten | map(select(. != null and . != "")) | first // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | grep -v 'null' | tr -d '[:space:]')"
        if echo "${PKG_MDSUM_TMP}" | grep -Eqi '^[a-f0-9]{32}'; then
         PKG_MDSUM="$(echo "${PKG_MDSUM_TMP}" | grep -oE '^[a-f0-9]{32}')"
         echo -e "[+] MD5SUM ==> ${PKG_MDSUM} [${PKG_NAME}] (${PKG_ID_BASE})"
        else
         unset PKG_MDSUM
        fi
     #Download URL
       PKG_DL_URL_TMP="$(jq -r '[ .. | objects | .downloadlink?, .downloadlink1?, .downloadlink2?, .downloadlink3? ] | flatten | map(select(. != null and . != "")) | first // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | tr -d '[:space:]')"
       if ! echo "${PKG_DL_URL_TMP}" | grep -qiE '^https?://'; then
         echo -e "[-] FATAL: Failed to fetch Download URL <== [${PKG_NAME}] (${PKG_ID_BASE})"
         return 1
       else
         if [[ "$(uname -m | tr -d '[:space:]')" == "aarch64" ]]; then
           if echo "${PKG_DL_URL_TMP}" | grep -qiE "aarch|arm64"; then
             PKG_DOWNLOAD_URL="$(echo "${PKG_DL_URL_TMP}" | grep -v '^[[:space:]]*$' | head -n 1 | tr -d '[:space:]')"
           fi
         elif [[ "$(uname -m | tr -d '[:space:]')" == "x86_64" ]]; then
           if echo "${PKG_DL_URL_TMP}" | grep -qiEv "aarch|arm64|armhf|i386|i686"; then
             PKG_DOWNLOAD_URL="$(echo "${PKG_DL_URL_TMP}" | grep -v '^[[:space:]]*$' | head -n 1 | tr -d '[:space:]')"
           fi
         fi
         if [ -z "${PKG_DOWNLOAD_URL+x}" ] || [ -z "${PKG_DOWNLOAD_URL##*[[:space:]]}" ]; then
           echo -e "[-] FATAL: No Download URL found for "${HOST_TRIPLET}" <== [${PKG_NAME}] (${PKG_ID_BASE})"
           return 1
         fi
         #PKG_DL_URL="${PKG_DOWNLOAD_URL}"
         PKG_DL_URL="https://dl.aih.pkgforge.dev/${PKG_ID_AIH}"
         echo -e "[+] Download URL ==> ${PKG_DL_URL} [${PKG_NAME}] (${PKG_ID_BASE})"
       fi
     #Date
       PKG_BUILD_DATE_TMP="$(jq -r '[ .. | objects | .changed?, .created? ] | flatten | map(select(. != null and . != "")) | first // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | grep -v 'null' | sed 's/+.*//; s/$/Z/' | tr -d '[:space:]')"
        if [[ "${PKG_BUILD_DATE_TMP}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}([+-][0-9]{2}:[0-9]{2}|Z)?$ ]]; then
          PKG_BUILD_DATE="${PKG_BUILD_DATE_TMP}"
        else
          PKG_BUILD_DATE="$(date --utc +'%Y-%m-%dT%H:%M:%SZ')"
        fi
       echo -e "[+] Build Date ==> ${PKG_BUILD_DATE} [${PKG_NAME}] (${PKG_ID_BASE})"
     #Description
       PKG_DESCRIPTION_TMP="$(jq -r '.. | .description? // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | grep -iv 'null' |\
         sed 's/`//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed ':a;N;$!ba;s/\r\n//g; s/\n//g' | sed 's/["'\'']//g' |\
         sed 's/|//g' | sed 's/`//g' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | sed 's/\.$//')"
         if echo "${PKG_DESCRIPTION_TMP}" | grep -qiE '<p>'; then
           PKG_DESCRIPTION="$(echo "${PKG_DESCRIPTION_TMP}" | sed -n 's/<p>[[:space:]]*\([^<]*\)[[:space:]]*<\/p>.*/\1/p' |\
            sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/<[^>]*>//g' | sed 's/\.$//' | head -n 1)"
         else
           PKG_DESCRIPTION="$(echo "${PKG_DESCRIPTION_TMP}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/<[^>]*>//g' | sed 's/\.$//' | head -n 1)"
         fi
       if [[ "$(echo "${PKG_DESCRIPTION}" | tr -d '[:space:]' | wc -c)" -lt 5 ]]; then
         PKG_DESCRIPTION="No Valid Description was Provided"
       fi
       echo -e "[+] Description ==> ${PKG_DESCRIPTION} [${PKG_NAME}] (${PKG_ID_BASE})"
     #Download Count
       PKG_DOWNLOAD_COUNT="$(jq -r '.. | .downloads? // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | grep -iv 'null' | tr -cd '0-9' | tr -d '[:space:]')"
       if ! echo "${PKG_DOWNLOAD_COUNT}" | grep -qi '^[0-9]\+$'; then
         PKG_DOWNLOAD_COUNT="1"
       fi
       echo -e "[+] Download Count ==> ${PKG_DOWNLOAD_COUNT} [${PKG_NAME}] (${PKG_ID_BASE})"
     #Homepage
      PKG_WEBPAGE="${PKG_PAGE}"  
     #Screenshot
       PKG_SCREENSHOTS="$(jq . "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | grep -o 'https[^"]*\.\(jpeg\|jpg\|png\|svg\)[^"]*' | sort -u | paste -sd, - | tr -d '[:space:]' | sed 's/, /, /g' | sed 's/,/, /g' | sed 's/|//g' | sed 's/"//g')"
     #Size
       PKG_SIZE_TMP="$(jq -r '[ .. | objects | .downloadsize?, .downloadsize1?, .downloadsize2?, .downloadsize3? ] | flatten | map(select(. != null and . != "")) | first // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | tr -cd '0-9' | tr -d '[:space:]')"
       if echo "${PKG_SIZE_TMP}" | grep -qi '^[0-9]\+$'; then
         PKG_SIZE_RAW="$((${PKG_SIZE_TMP} * 1000))"
       else
         PKG_SIZE_TMP="$(curl -A "${USER_AGENT}" -qfsSL "${PKG_DL_URL}" -o '/dev/null' -w "%{size_download}\n" | tr -cd '0-9' | tr -d '[:space:]')"
         if ! echo "${PKG_SIZE_TMP}" | grep -qi '^[0-9]\+$'; then
           PKG_SIZE_RAW="${PKG_SIZE_TMP}"
         else
           unset PKG_SIZE_TMP
         fi
       fi
       if echo "${PKG_SIZE_RAW}" | grep -qi '^[0-9]\+$'; then
         PKG_SIZE="$(echo "${PKG_SIZE_RAW}" | awk '{byte=$1; if (byte<1024) printf "%.2f B\n", byte; else if (byte<1024**2) printf "%.2f KB\n", byte/1024; else if (byte<1024**3) printf "%.2f MB\n", byte/(1024**2); else printf "%.2f GB\n", byte/(1024**3)}')"
         echo -e "[+] Size ==> ${PKG_SIZE} [${PKG_NAME}] (${PKG_ID_BASE})"
         echo -e "[+] Size (RAW) ==> ${PKG_SIZE_RAW} [${PKG_NAME}] (${PKG_ID_BASE})"
       fi
     #Tags
       PKG_TAGS="$(cat "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | jq -c -r '.. | .tags? // ""' | tr -d '[]' | tr -d '[:space:]' | sed 's/, /, /g' | sed 's/,/, /g' | sed 's/|//g' | sed 's/"//g')"
     #Version
       PKG_VERSION_TMP="$(jq -r '[ .. | objects | .version?, .download_version?, .download_version1?, .download_version2?, .download_version3?] | flatten | map(select(. != null and . != "")) | first // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | tr -d '[:space:]')"
       if [ -z "${PKG_VERSION_TMP+x}" ] || [ -z "${PKG_VERSION_TMP##*[[:space:]]}" ]; then
         T_ID="$(jq -r '.id // ""' "${TMPDIR}/tmp/${PKG_ID_BASE}.json" | tr -d -c '0-9')"
         if [[ "${#T_ID}" -gt 2 ]]; then
           PKG_VERSION="${T_ID}-latest+${PKG_MDSUM:0:6}aih"
         else
           PKG_VERSION="latest+${PKG_MDSUM:0:6}aih"
         fi
       else
         PKG_VERSION="${PKG_VERSION_TMP}+${PKG_MDSUM:0:6}aih"
       fi
       echo -e "[+] Version ==> ${PKG_VERSION} [${PKG_NAME}] (${PKG_ID_BASE})"
  #Generate Json
    jq -n --arg HOST "${HOST_TRIPLET}" \
       --arg PKG_NAME "${PKG_NAME}" \
       --arg PKG_ID "${PKG_ID}" \
       --arg PKG_WEBPAGE "${PKG_WEBPAGE}" \
       --arg BUILD_DATE "${PKG_BUILD_DATE}" \
       --arg DESCRIPTION "${PKG_DESCRIPTION}" \
       --arg DESKTOP "${PKG_DESKTOP}" \
       --arg DOWNLOAD_COUNT "${PKG_DOWNLOAD_COUNT}" \
       --arg DOWNLOAD_URL "${PKG_DL_URL}" \
       --arg LICENSE "${PKG_LICENSE}" \
       --arg MDSUM "${PKG_MDSUM}" \
       --arg RANK "${RANK}" \
       --arg SCREENSHOT "${PKG_SCREENSHOTS}" \
       --arg SIZE "${PKG_SIZE}" \
       --arg SIZE_RAW "${PKG_SIZE_RAW}" \
       --arg TAGS "${PKG_TAGS}" \
       --arg VERSION "${PKG_VERSION}" \
     '
      {
        _disabled: ("false"),
        host: ($HOST | tostring),
        pkg: ($PKG_NAME | tostring),
        pkg_id: ($PKG_ID | gsub("[[:space:]]"; "") | gsub("^\\.+|\\.+$"; "")),
        pkg_name: ($PKG_NAME | ascii_downcase | gsub("[[:space:]]"; "")),
        pkg_type: ("appimage"),
        pkg_webpage: ($PKG_WEBPAGE | tostring),
        build_date: ($BUILD_DATE | tostring),
        category: (.categories // []),
        description: ($DESCRIPTION 
          | gsub("<[^>]*>"; "") | gsub("\\s+"; " ") 
          | gsub("^\\s+|\\s+$"; "") | gsub("^\\.+|\\.+$"; "")),
        desktop: ($DESKTOP | tostring),
        download_count: ($DOWNLOAD_COUNT | tostring),
        download_url: ($DOWNLOAD_URL | tostring),
        homepage: [($PKG_WEBPAGE | tostring)],
        license: ($LICENSE | split(", ")),
        maintainer: [
        "AppImageHub (https://www.appimagehub.com)"
        ],
        mdsum: ($MDSUM | tostring),
        note: [
        "[NOT-RECOMMENDED] We CAN NOT guarantee the authenticity, validity or security",
        "This data was autogenerated & is likely inaccurate",
        "Data used: https://api.appimagehub.com/ocs/v1/content/data",
        "Provided by: https://www.appimagehub.com/",
        "Learn More: https://docs.pkgforge.dev/repositories/external/appimagehub",
        "Please create an Issue or send a PR for an official Package"
        ],
        provides: [($PKG_NAME | ascii_downcase | gsub("[[:space:]]"; ""))],
        rank: ($RANK | tostring),
        screenshot: ($SCREENSHOT | split(", ")),
        size: ($SIZE | tostring),
        size_raw: ($SIZE_RAW | tostring),
        src_url: [($PKG_WEBPAGE | tostring)],
        tag: ($TAGS | split(", ")),
        version: $VERSION
      }
     ' | jq . > "${TMPDIR}/processed/${PKG_ID_BASE}.json.raw"
 #Sanity Check   
   if jq -r '.pkg' "${TMPDIR}/processed/${PKG_ID_BASE}.json.raw" | grep -iv 'null' | tr -d '[:space:]' | grep -Eiq "^${PKG_NAME}$"; then
     mv -fv "${TMPDIR}/processed/${PKG_ID_BASE}.json.raw" "${TMPDIR}/processed/${PKG_ID_BASE}.json"
   else
     echo -e "[-] FATAL: ${PKG_NAME} (${PKG_ID_BASE}) failed Validation [${TMPDIR}/tmp/${PKG_ID_BASE}.json.raw]"
     rm -rvf "${TMPDIR}/processed/${PKG_ID_BASE}.json.raw"
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
 jq -r '.. | .detailpage? // ""' "${TMPDIR}/data/appimagehub.json.tmp" | sort -uo "${TMPDIR}/pkg_pages.txt"
 unset PKG_PAGES ; readarray -t "PKG_PAGES" < "${TMPDIR}/pkg_pages.txt"
 printf '%s\n' "${PKG_PAGES[@]}" | xargs -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" -I "{}" bash -c 'generate_meta "$@" 2>/dev/null' _ "{}"
popd &>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Merge
find "${TMPDIR}/processed/" -type f -name '*.json' ! -iname "*.raw" -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | jq -s 'sort_by(.pkg)' > "${TMPDIR}/appimagehub.json.raw"
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
  )' "${TMPDIR}/appimagehub.json.raw" | jq 'map(if .rank == "" then .rank = null else .rank = (.rank | tonumber) end) |
  map(.download_count = (.download_count | tonumber)) |
  (map(select(.download_count != "")) | sort_by(.rank, .pkg)) as $valid_entries |
  (map(select(.download_count == "")) | sort_by(.pkg)) as $invalid_entries |
  ($valid_entries + $invalid_entries) | to_entries | map(.value.rank = (.key + 1 | tostring)) |
  map(.value) | sort_by(.pkg)' | jq . > "${TMPDIR}/appimagehub.json.tmp"
#sanity check urls
sed -E 's~\bhttps?:/{1,2}\b~https://~g' -i "${TMPDIR}/appimagehub.json.tmp"
cat "${TMPDIR}/appimagehub.json.tmp" | jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | jq 'if type == "array" then . else [.] end' | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "")) | select(length > 0) elif type == "array" then map(select(. != null and . != "")) | select(length > 0) else . end)' |\
 jq 'map(select(
    .pkg != null and .pkg != "" and
    .pkg_id != null and .pkg_id != "" and
    .pkg_name != null and .pkg_name != "" and
    .description != null and .description != "" and
    .download_url != null and .download_url != "" and
    .version != null and .version != ""
 ))' | jq 'unique_by(.pkg_id) | sort_by(.pkg)' | jq . > "${TMPDIR}/appimagehub.json.final"
##Check
unset PKG_COUNT; PKG_COUNT="$(jq -r '.[] | .pkg_id' "${TMPDIR}/appimagehub.json.final" | sort -u | wc -l | tr -d '[:space:]')"
if [[ "${PKG_COUNT}" -le 20 ]]; then
 echo -e "\n[X] FATAL: Final Package Count is < 20, Parsing Failed?\n"
 echo "[-] Count: ${PKG_COUNT}"
 exit 1
else
 echo -e "\n[+] Packages: ${PKG_COUNT}"
 mv -fv "${TMPDIR}/appimagehub.json.final" "${SYSTMP}/appimagehub.json"
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/external/appimagehub/data"
if command -v rclone &> /dev/null &&\
 [ -s "${HOME}/.rclone.conf" ] &&\
 [ -s "${SYSTMP}/appimagehub.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  mkdir -pv "${GITHUB_WORKSPACE}/main/external/appimagehub/data"
  cd "${GITHUB_WORKSPACE}/main/external/appimagehub/data"
  [[ ! -f "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json" ]] &&\
   echo '[]' > "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json"
  jq -s 'map(.[]) | group_by(.pkg_id) | map(if length > 1 then .[1] + .[0] else .[0] end) | unique_by(.pkg_id) | sort_by(.pkg)' \
  "${SYSTMP}/appimagehub.json" "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json" | jq . > "${SYSTMP}/merged.json"
  if [[ "$(jq -r '.[] | .pkg_id' "${SYSTMP}/merged.json" | sort -u | wc -l | tr -d '[:space:]')" -gt 20 ]]; then
   cp -fv "${SYSTMP}/merged.json" "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json"
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
  if command -v "qsv" &>/dev/null; then
    jq -c '.[]' "${HOST_TRIPLET}.json" > "${TMPDIR}/${HOST_TRIPLET}.jsonl"
    qsv jsonl "${TMPDIR}/${HOST_TRIPLET}.jsonl" > "${TMPDIR}/${HOST_TRIPLET}.csv"
    qsv to sqlite "${TMPDIR}/${HOST_TRIPLET}.db" "${TMPDIR}/${HOST_TRIPLET}.csv"
    if [[ -s "${TMPDIR}/${HOST_TRIPLET}.db" && $(stat -c%s "${TMPDIR}/${HOST_TRIPLET}.db") -gt 1024 ]]; then
     cp -fv "${TMPDIR}/${HOST_TRIPLET}.db" "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db" ; generate_checksum "${HOST_TRIPLET}.db"
     bita compress --input "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db" --compression "zstd" --compression-level "21" --force-create "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.cba"
     7z a -t7z -mx="9" -mmt="$(($(nproc)+1))" -bsp1 -bt "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.xz" "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db" 2>/dev/null ; generate_checksum "${HOST_TRIPLET}.db.xz"
     zstd --ultra -22 --force "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db" -o "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.zstd" ; generate_checksum "${HOST_TRIPLET}.db.zstd"
     #Upload
      rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.db" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.bsum" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.db.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.cba" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.db.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.xz" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.db.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.xz.bsum" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.db.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.zstd" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.db.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
      rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.db.zstd.bsum" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.db.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
    fi
  fi
 #To xz
  xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "${HOST_TRIPLET}.json" ; generate_checksum "${HOST_TRIPLET}.json.xz"
 #To Zstd
  zstd --ultra -22 --force "${HOST_TRIPLET}.json" -o "${HOST_TRIPLET}.json.zstd" ; generate_checksum "${HOST_TRIPLET}.json.zstd"
 #Upload (Json)
  rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json.bsum" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.json.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json.cba" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.json.cba" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json.xz" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.json.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json.xz.bsum" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.json.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json.zstd" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.json.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/external/appimagehub/data/${HOST_TRIPLET}.json.zstd.bsum" "r2:/meta/external/appimagehub/${HOST_TRIPLET}.json.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  #Upload (SDB)
  wait ; echo
fi
#-------------------------------------------------------#