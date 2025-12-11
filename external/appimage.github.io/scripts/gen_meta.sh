#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Convert https://appimage.github.io/feed.json to a more useful data
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimage.github.io/scripts/gen_meta.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimage.github.io/scripts/gen_meta.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
export HOST_TRIPLET="$(uname -m)-$(uname -s)"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
mkdir -pv "${TMPDIR}/tmp" "${TMPDIR}/data"
rm -rvf "${SYSTMP}/appimage.json" 2>/dev/null
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
##Get feed.json
curl -qfsSL "https://appimage.github.io/feed.json" -o "${TMPDIR}/appimage.json"
AI_COUNT="$(jq -r '.. | .name? // empty' "${TMPDIR}/appimage.json" | wc -l | tr -d '[:space:]')" ; export AI_COUNT
if [[ "${AI_COUNT}" -le 500 ]]; then
 echo -e "\n[X] FATAL: AppImage Count is < 200, Parsing Failed?\n"
 exit 1
else
 echo -e "[+] AppImages: ${AI_COUNT} <== https://appimage.github.io/feed.json"
fi
##Get Repo
pushd "$(mktemp -d)" >/dev/null 2>&1 && git clone --filter="blob:none" --depth="1" --quiet "https://github.com/AppImage/appimage.github.io" && cd "./appimage.github.io"
 unset AI_REPO_LOCAL ; AI_REPO_LOCAL="$(realpath .)" && export AI_REPO_LOCAL="${AI_REPO_LOCAL}"
 if [ ! -d "${AI_REPO_LOCAL}" ] || [ $(du -s "${AI_REPO_LOCAL}" | cut -f1) -le 100 ]; then
   echo -e "\n[X] FATAL: Failed to clone AppImage Repo\n"
  exit 1 
 fi
popd >/dev/null 2>&1
#-------------------------------------------------------#

#-------------------------------------------------------#
##Loop & Generate Meta
generate_meta()
{
 ##Chdir
  pushd "${TMPDIR}" >/dev/null 2>&1
 ##Enable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set -x
  fi
 ##Main
  export PKG_NAME="$1"
  echo -e "\n[+] Processing ${PKG_NAME##*[[:space:]]}\n"
  unset BUILD_DATE MATCHES PKG_AI_ASSETS PKG_APP_ENTRY PKG_ASSET PKG_DATA_ENTRY PKG_DB_ENTRY PKG_REPO_DESCRIPTION PKG_DOWNLOAD_URL PKG_REPO_LICENSE PKG_REPO_NAME PKG_REPO_TAGS PKG_SCREENSHOT_FILE PKG_SIZE PKG_SIZE_RAW PKG_VERSION PKG_VERSION_TMP SCREENSHOT
  #Check PKG_DB array (Mandatory)
   printf '%s\n' "${PKG_DB[@]}" 2>/dev/null | grep -qi "/${PKG_NAME}" && {
     MATCHES="$(printf '%s\n' "${PKG_DB[@]}" 2>/dev/null | grep -i "/${PKG_NAME}")"
     if [[ "$(echo "${MATCHES}" | wc -l | tr -d '[:space:]')" -gt 1 ]]; then
       PKG_DB_ENTRY="$(echo "${MATCHES}" | grep -i "/${PKG_NAME}$")"
     elif [[ "$(echo "${MATCHES}" | wc -l | tr -d '[:space:]')" == "1" ]]; then
       PKG_DB_ENTRY="$(echo "${MATCHES}" | tr -d '[:space:]')"
     fi
   }
   if [ -n "${PKG_DB_ENTRY+x}" ] && [[ "${PKG_DB_ENTRY}" =~ ^[^[:space:]]+$ ]]; then
     echo -e "[+] ${PKG_NAME} ==> ${PKG_DB_ENTRY} [Database]"
   else
     echo -e "[X] ${PKG_NAME} has No Entry [Database] (skipping ...)"
     return
   fi
  #Check PKG_APPS array (Optional)
   printf '%s\n' "${PKG_APPS[@]}" 2>/dev/null | grep -qi "/${PKG_NAME}" && {
     MATCHES="$(printf '%s\n' "${PKG_APPS[@]}" 2>/dev/null | grep -i "/${PKG_NAME}")"
     if [[ "$(echo "${MATCHES}" | wc -l | tr -d '[:space:]')" -gt 1 ]]; then
       PKG_APP_ENTRY="$(echo "${MATCHES}" | grep -i "/${PKG_NAME}$" | tr -d '[:space:]')"
     elif [[ "$(echo "${MATCHES}" | wc -l | tr -d '[:space:]')" == "1" ]]; then
       PKG_APP_ENTRY="$(echo "${MATCHES}" | tr -d '[:space:]')"
     fi
   }
   if [ -n "${PKG_APP_ENTRY+x}" ] && [[ "${PKG_APP_ENTRY}" =~ ^[^[:space:]]+$ ]]; then
     echo -e "[+] ${PKG_NAME} ==> ${PKG_APP_ENTRY} [APP YAML]"
   fi
  #Check PKG_DATA array (Optional)
   printf '%s\n' "${PKG_DATA[@]}" 2>/dev/null | grep -qi "/${PKG_NAME}" && {
     MATCHES="$(printf '%s\n' "${PKG_DATA[@]}" 2>/dev/null | grep -i "/${PKG_NAME}")"
     if [[ "$(echo "${MATCHES}" | wc -l | tr -d '[:space:]')" -gt 1 ]]; then
       PKG_DATA_ENTRY="$(echo "${MATCHES}" | grep -i "/${PKG_NAME}$")"
     elif [[ "$(echo "${MATCHES}" | wc -l | tr -d '[:space:]')" == "1" ]]; then
       PKG_DATA_ENTRY="$(echo "${MATCHES}" | tr -d '[:space:]')"
     fi
   }
   if [ -n "${PKG_DATA_ENTRY+x}" ] && [[ "${PKG_DATA_ENTRY}" =~ ^[^[:space:]]+$ ]]; then
     echo -e "[+] ${PKG_NAME} ==> ${PKG_DATA_ENTRY} [RAW DL]"
   fi
   #Sanity Check
     PKG_DB_BASE="$(basename "${PKG_DB_ENTRY}")"
     jq --arg P_NAME "${PKG_DB_BASE}" '.items[] | select(.name == $P_NAME)' "${TMPDIR}/appimage.json" | jq . > "${TMPDIR}/tmp/${PKG_DB_BASE}.json"
     if [[ ! -s "${TMPDIR}/tmp/${PKG_DB_BASE}.json" || $(stat -c%s "${TMPDIR}/tmp/${PKG_DB_BASE}.json") -le 10 ]]; then
       echo -e "[-] FATAL: Failed to fetch JSON <== ${PKG_DB_BASE}"
       return
     fi
    #Fetch Needed vars
     #Desktop
       PKG_DESKTOP_FILE="$(find "${PKG_DB_ENTRY}" -type f -iname "*.desktop" | sort -u | head -n 1 | tr -d '[:space:]')"
       if [ -s "${PKG_DESKTOP_FILE}" ]; then
         DESKTOP="https://raw.githubusercontent.com/AppImage/appimage.github.io/refs/heads/master/database/${PKG_DESKTOP_FILE##*/database/}"
         echo -e "[+] Desktop ==> ${DESKTOP}"
       else
         DESKTOP=""
       fi
     #Download URL
       PKG_DL_URL="$(jq -r '.links[]? | select(.type? | ascii_downcase == "download") | .url // ""' "${TMPDIR}/tmp/${PKG_DB_BASE}.json" | tr -d '[:space:]')"
       if ! echo "${PKG_DL_URL}" | grep -qiE '^https?://'; then
         echo -e "[-] FATAL: Failed to fetch Download URL <== ${PKG_DB_BASE}"
         return
       else
         echo -e "[+] Download URL ==> ${PKG_DL_URL}"
       fi
       #If Github
        if echo "${PKG_DL_URL}" | grep -qiE 'github.com'; then
         #Fetch Metadata
          PKG_REPO_NAME="$(echo ${PKG_DL_URL} | sed -E 's|^https://github.com/||; s|/releases.*||; s|^/*||; s|/*$||' | sed 's/\s//g' | sed 's/|//g' | tr -d '[:space:]')"
          curl -qfsSL "https://api.gh.pkgforge.dev/repos/${PKG_REPO_NAME}" 2>/dev/null | jq . > "${TMPDIR}/tmp/${PKG_DB_BASE}.gh.json"
          if [[ ! -s "${TMPDIR}/tmp/${PKG_DB_BASE}.gh.json" || $(stat -c%s "${TMPDIR}/tmp/${PKG_DB_BASE}.gh.json") -le 10 ]]; then
            echo -e "[-] FATAL: Failed to fetch Github Metadata <== ${PKG_DL_URL}"
            return
          fi
          curl -qfsSL "https://api.gh.pkgforge.dev/repos/${PKG_REPO_NAME}/releases?per_page=100" 2>/dev/null | jq . > "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json"
          if [[ ! -s "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json" || $(stat -c%s "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json") -le 10 ]]; then
            echo -e "[-] FATAL: Failed to fetch Github Release Metadata <== ${PKG_DL_URL}"
            return
          fi
          PKG_AI_ASSETS=()
          readarray -t "PKG_AI_ASSETS" < <(jq -r '.[] | .assets |= sort_by(.created_at) | .assets[] | select(.browser_download_url | test("appimage"; "i") and (test("zsync"; "i") | not)) | .browser_download_url' "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json")
          for PKG_ASSET in "${PKG_AI_ASSETS[@]}"; do
           if echo "${PKG_ASSET}" | grep -qi "appimage"; then
             ARCH="$(uname -m | tr -d '[:space:]')"
             case "${ARCH}" in
               aarch64)
                 if echo "${PKG_ASSET}" | grep -qiE "aarch|arm64"; then
                   PKG_DOWNLOAD_URL="$(echo "${PKG_ASSET}" | grep -v '^[[:space:]]*$' | head -n 1 | tr -d '[:space:]')"
                   break
                 fi
                 ;;
               x86_64)
                 if ! echo "${PKG_ASSET}" | grep -qiE "aarch|arm64|armhf|i386|i686"; then
                   PKG_DOWNLOAD_URL="$(echo "${PKG_ASSET}" | grep -v '^[[:space:]]*$' | head -n 1 | tr -d '[:space:]')"
                   break
                 fi
                 ;;
             esac
           fi
          done
          if echo "${PKG_DOWNLOAD_URL}" | grep -qiE 'appimage'; then
            echo -e "[+] Download URL ==> ${PKG_DOWNLOAD_URL}"
            PKG_VERSION="$(echo "${PKG_DOWNLOAD_URL}" | sed -E 's#.*/download/([^/]+)/.*#\1#' | tr -d '[:space:]')"
            PKG_SIZE_RAW="$(jq --arg DL_URL "${PKG_DOWNLOAD_URL}" -r '.. | objects | select(.browser_download_url? == $DL_URL) | .size' "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json")"
            PKG_SIZE="$(echo "${PKG_SIZE_RAW}" | awk '{byte=$1; if (byte<1024) printf "%.2f B\n", byte; else if (byte<1024**2) printf "%.2f KB\n", byte/1024; else if (byte<1024**3) printf "%.2f MB\n", byte/(1024**2); else printf "%.2f GB\n", byte/(1024**3)}')"
            echo -e "[+] Size ==> ${PKG_SIZE}"
            echo -e "[+] Size (RAW) ==> ${PKG_SIZE_RAW}"
          else
            echo -e "[-] FATAL: Failed to find Any Github Release <== ${PKG_DL_URL}"
            return
          fi
         #Get Version
         if [ -z "${PKG_VERSION+x}" ] || [ -z "${PKG_VERSION##*[[:space:]]}" ]; then
            PKG_VERSION_TMP="$(jq -r '.[] | .assets |= sort_by(.created_at) | .assets[] | select(.browser_download_url | test("appimage"; "i")) | .browser_download_url | capture("/download/(?<tag>[^/]+)/") | .tag' "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json" | head -n 1 | tr -d '[:space:]')"
            if [ -n "${PKG_VERSION_TMP+x}" ] && [[ "${PKG_VERSION_TMP}" =~ ^[^[:space:]]+$ ]]; then
               PKG_VERSION="${PKG_VERSION_TMP}"
               PKG_VERSION_TMP_DATE="$(jq --arg version "${PKG_VERSION:-${PKG_VERSION_TMP}}" -r '.. | objects | select(.tag_name? == $version) | .published_at' "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json")"
               if [[ "${PKG_VERSION_TMP_DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
                BUILD_DATE="${PKG_VERSION_TMP_DATE}"
                echo -e "[+] Build Date ==> ${BUILD_DATE}"
                PKG_SIZE_RAW="$(jq --arg DL_URL "${PKG_DOWNLOAD_URL}" -r '.. | objects | select(.browser_download_url? == $DL_URL) | .size' "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json")"
                PKG_SIZE="$(echo "${PKG_SIZE_RAW}" | awk '{byte=$1; if (byte<1024) printf "%.2f B\n", byte; else if (byte<1024**2) printf "%.2f KB\n", byte/1024; else if (byte<1024**3) printf "%.2f MB\n", byte/(1024**2); else printf "%.2f GB\n", byte/(1024**3)}')"
                 echo -e "[+] Size ==> ${PKG_SIZE}"
                 echo -e "[+] Size (RAW) ==> ${PKG_SIZE_RAW}"
               fi
            else
              PKG_VERSION="$(curl -qfsSL "https://api.gh.pkgforge.dev/repos/${PKG_REPO_NAME}/tags" 2>/dev/null | jq -r '.[0].name' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g' | tr -d '[:space:]')"
              echo -e "[+] Version ==> ${PKG_VERSION}"
              BUILD_DATE="$(curl -qfsSL "https://api.gh.pkgforge.dev/repos/${PKG_REPO_NAME}/git/refs/tags/${PKG_VERSION}" 2>/dev/null | jq '.object.url' | xargs curl -qfsSL 2>/dev/null | jq -r '.committer.date' | sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g' | tr -d '[:space:]')"
              echo -e "[+] Build Date ==> ${BUILD_DATE}"
            fi
         else
            echo -e "[+] Version ==> ${PKG_VERSION}"
            PKG_VERSION_TMP_DATE="$(jq --arg version "${PKG_VERSION:-${PKG_VERSION_TMP}}" -r '.. | objects | select(.tag_name? == $version) | .published_at' "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json")"
            if [[ "${PKG_VERSION_TMP_DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
               BUILD_DATE="${PKG_VERSION_TMP_DATE}"
               echo -e "[+] Build Date ==> ${BUILD_DATE}"
               if [ -z "${PKG_SIZE_RAW+x}" ] || [ -z "${PKG_SIZE_RAW##*[[:space:]]}" ]; then
                 PKG_SIZE_RAW="$(jq --arg DL_URL "${PKG_DOWNLOAD_URL}" -r '.. | objects | select(.browser_download_url? == $DL_URL) | .size' "${TMPDIR}/tmp/${PKG_DB_BASE}.gh_rel.json")"
                 PKG_SIZE="$(echo "${PKG_SIZE_RAW}" | awk '{byte=$1; if (byte<1024) printf "%.2f B\n", byte; else if (byte<1024**2) printf "%.2f KB\n", byte/1024; else if (byte<1024**3) printf "%.2f MB\n", byte/(1024**2); else printf "%.2f GB\n", byte/(1024**3)}')"
                 echo -e "[+] Size ==> ${PKG_SIZE}"
                 echo -e "[+] Size (RAW) ==> ${PKG_SIZE_RAW}"
               fi
            else
               BUILD_DATE="$(curl -qfsSL "https://api.gh.pkgforge.dev/repos/${PKG_REPO_NAME}/git/refs/tags/${PKG_VERSION}" 2>/dev/null | jq '.object.url' | xargs curl -qfsSL 2>/dev/null | jq -r '.committer.date' | sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g' | tr -d '[:space:]')"
               echo -e "[+] Build Date ==> ${BUILD_DATE}"
            fi
         fi
         #Parse Metadata (Main)
          if [[ "$(jq -r '.description? // ""' "${TMPDIR}/tmp/${PKG_DB_BASE}.json" | grep -iv 'null' | tr -d '[:space:]' | wc -c)" -lt 5 ]]; then
           PKG_REPO_DESCRIPTION="$(cat ${TMPDIR}/tmp/${PKG_DB_BASE}.gh.json | jq -r '.description' | sed 's/`//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed ':a;N;$!ba;s/\r\n//g; s/\n//g' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g')"
          fi
          if [[ "$(jq -r '[.license? | if type == "string" then . else . // "" end] // ""' "${TMPDIR}/tmp/${PKG_DB_BASE}.json" | grep -iv 'null' | tr -d '[:space:]' | wc -c)" -lt 7 ]]; then
           PKG_REPO_LICENSE="$(cat ${TMPDIR}/tmp/${PKG_DB_BASE}.gh.json | jq -r '.license.name' | sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g')"
          fi
         #Parse Metadata (Tags)
          PKG_REPO_TAGS="$(cat ${TMPDIR}/tmp/${PKG_DB_BASE}.gh.json | jq -c -r '.topics' | tr -d '[]' | sed 's/, /, /g' | sed 's/,/, /g' | sed 's/|//g' | sed 's/"//g')"
        fi
     #Screenshot
       PKG_SCREENSHOT_FILE="$(find "${PKG_DB_ENTRY}" -type f -iname "*screenshot*" | sort -u | head -n 1 | tr -d '[:space:]')"
       if [ -s "${PKG_SCREENSHOT_FILE}" ]; then
         SCREENSHOT="https://raw.githubusercontent.com/AppImage/appimage.github.io/refs/heads/master/database/${PKG_SCREENSHOT_FILE##*/database/}"
         echo -e "[+] Screenshot ==> ${SCREENSHOT}"
       else
         SCREENSHOT=""
       fi
  #Generate Json
    jq --arg DESCRIPTION "${PKG_REPO_DESCRIPTION}" \
       --arg DOWNLOAD_URL "${PKG_DOWNLOAD_URL}" \
       --arg DESKTOP "${DESKTOP}" \
       --arg HOST "${HOST_TRIPLET}" \
       --arg LICENSE "${PKG_REPO_LICENSE}" \
       --arg VERSION "${PKG_VERSION}" \
       --arg TAGS "${PKG_REPO_TAGS}" \
       --arg SCREENSHOT "${SCREENSHOT}" \
       --arg SIZE "${PKG_SIZE}" \
       --arg SIZE_RAW "${PKG_SIZE_RAW}" \
     '
      {
        _disabled: ("false"),
        host: $HOST,
        pkg: (.name // ""),
        pkg_id: (
          ("appimage.github.io." + (.name // "") + "." + (([.authors[]?.name?] // []) | join(".")))
          | gsub("[[:space:]]"; "")
          | gsub("^\\.+|\\.+$"; "")
        ),
        pkg_name: ((.name // "") | ascii_downcase | gsub("[[:space:]]"; "")),
        pkg_type: ("appimage"),
        category: (.categories // []),
        description: (
         if (.description // "") == "" 
         then $DESCRIPTION | gsub("<[^>]*>"; "") | gsub("\\s+"; " ") | gsub("^\\s+|\\s+$"; "") | gsub("^\\.+|\\.+$"; "") 
         else .description | gsub("<[^>]*>"; "") | gsub("\\s+"; " ") | gsub("^\\s+|\\s+$"; "") | gsub("^\\.+|\\.+$"; "") 
         end
        ),
        desktop: $DESKTOP,
        download_url: (if $DOWNLOAD_URL == "" then ((.links[]? | select(.type? | ascii_downcase == "download") | .url) // "") else $DOWNLOAD_URL end),
        homepage: ([.authors[]?.url?] // []) | unique,
        icon: (if (.icons // []) | length > 0 then "https://raw.githubusercontent.com/AppImage/appimage.github.io/refs/heads/master/database/icons/" + .icons[0] else "" end),
        license: (if $LICENSE != "" then [$LICENSE] else (if .license? then (if .license | type == "string" then [.license] else [.license // ""] end) else [] end) end),
        maintainer: [
        "AppImage (https://github.com/AppImage/appimage.github.io)"
        ],
        note: [
        "[EXTERNAL] (This is an unofficial, third-party repository)",
        "[UNTRUSTED] (We CAN NOT guarantee the authenticity, validity or security)",
        "This data was autogenerated & is likely inaccurate",
        "Data used: https://appimage.github.io/feed.json",
        "Provided by: https://github.com/AppImage/appimage.github.io",
        "Learn More: https://docs.pkgforge.dev/repositories/external/appimage.github.io",
        "Please create an Issue or send a PR for an official Package"
        ],
        provides: [((.name // "") | ascii_downcase)],
        screenshot: ($SCREENSHOT | split(", ")),
        size: $SIZE,
        size_raw: $SIZE_RAW,
        src_url: ([.links[]? | select(.type? | ascii_downcase == "download") | .url] // []),
        tag: ($TAGS | split(", ")),
        version: $VERSION
      }
     ' "${TMPDIR}/tmp/${PKG_DB_BASE}.json" | jq . > "${TMPDIR}/tmp/${PKG_DB_BASE}.json.raw"
 #Sanity Check   
   if jq -r '.pkg' "${TMPDIR}/tmp/${PKG_DB_BASE}.json.raw" | grep -iv 'null' | tr -d '[:space:]' | grep -Eiq "^${PKG_NAME}$"; then
     mv -fv "${TMPDIR}/tmp/${PKG_DB_BASE}.json.raw" "${TMPDIR}/data/${PKG_DB_BASE}.json"
   fi
 ##Disable Debug
  if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
     set +x
  fi
}
export -f generate_meta
#-------------------------------------------------------#

#-------------------------------------------------------#
##Set Vars
pushd "${TMPDIR}" >/dev/null 2>&1
 jq -r '.. | .name? // empty' "${TMPDIR}/appimage.json" | sort -o "${TMPDIR}/pkg_names.txt"
 unset PKG_NAMES ; readarray -t "PKG_NAMES" < "${TMPDIR}/pkg_names.txt"
 #markdown, contains yaml like entries
 find "${AI_REPO_LOCAL}/apps" -maxdepth 1 -type f -exec realpath "{}" \; | sort -u -o "${TMPDIR}/pkg_apps.txt"
 unset PKG_APPS ; readarray -t "PKG_APPS" < "${TMPDIR}/pkg_apps.txt"
 #contains raw download links
 find "${AI_REPO_LOCAL}/data" -maxdepth 1 -type f -exec realpath "{}" \; | sort -u -o "${TMPDIR}/pkg_data.txt"
 unset PKG_DATA ; readarray -t "PKG_DATA" < "${TMPDIR}/pkg_data.txt"
 #Directory, contains icons, desktop, appstream, screenshot etc
 find "${AI_REPO_LOCAL}/database" -maxdepth 1 -type d -exec realpath "{}" \; | sort -u -o "${TMPDIR}/pkg_db.txt"
 unset PKG_DB ; readarray -t "PKG_DB" < "${TMPDIR}/pkg_db.txt"
##Generate
  PKG_APPS_STR="${PKG_APPS[*]}"
  PKG_DATA_STR="${PKG_DATA[*]}"
  PKG_DB_STR="${PKG_DB[*]}"
  PKG_NAMES_STR="${PKG_NAMES[*]}"
  export PKG_APPS_STR PKG_DATA_STR PKG_DB_STR PKG_NAMES_STR
  printf '%s\n' "${PKG_NAMES[@]}" | xargs -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" -I "{}" \
     timeout -k 10s 180s bash -c '
        PKG_APPS=(${PKG_APPS_STR})
        PKG_DATA=(${PKG_DATA_STR})
        PKG_DB=(${PKG_DB_STR})
        PKG_NAMES=(${PKG_NAMES_STR})
        generate_meta "$@"
     ' _ "{}"
popd >/dev/null 2>&1
#-------------------------------------------------------#

#-------------------------------------------------------#
##Merge
find "${TMPDIR}/data/" -type f -name '*.json' -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | jq -s 'sort_by(.pkg)' > "${TMPDIR}/appimage.json.raw"
#sanity check urls
sed -E 's~\bhttps?:/{1,2}\b~https://~g' -i "${TMPDIR}/appimage.json.raw"
cat "${TMPDIR}/appimage.json.raw" | jq \
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
 ))' | jq 'unique_by(.download_url) | sort_by(.pkg)' | jq . > "${TMPDIR}/appimage.json.final"
##Check
unset PKG_COUNT; PKG_COUNT="$(jq -r '.[] | .pkg_id' "${TMPDIR}/appimage.json.final" | sort -u | wc -l | tr -d '[:space:]')"
if [[ "${PKG_COUNT}" -le 20 ]]; then
 echo -e "\n[X] FATAL: Final Package Count is < 20, Parsing Failed?\n"
 echo "[-] Count: ${PKG_COUNT}"
 exit 1
else
 echo -e "\n[+] Packages: ${PKG_COUNT}"
 mv -fv "${TMPDIR}/appimage.json.final" "${SYSTMP}/appimage.json"
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data"
if [ -s "${SYSTMP}/appimage.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  mkdir -pv "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data"
  cd "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data"
  [[ ! -f "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.json" ]] &&\
   echo '[]' > "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.json"
  jq -s 'map(.[]) | group_by(.pkg_id) | map(if length > 1 then .[1] + .[0] else .[0] end) | unique_by(.download_url) | sort_by(.pkg)' \
  "${SYSTMP}/appimage.json" "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.json" | jq . > "${SYSTMP}/merged.json"
  if [[ "$(jq -r '.[] | .pkg_id' "${SYSTMP}/merged.json" | sort -u | wc -l | tr -d '[:space:]')" -gt 50 ]]; then
   if [[ "${HOST_TRIPLET//[[:space:]]/}" == "aarch64-Linux" ]]; then
     cat "${SYSTMP}/merged.json" | jq 'del(.[] | select(.download_url | test("amd64|i686|x86_64"; "i")))' |\
       jq . > "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.json"
   elif [[ "${HOST_TRIPLET//[[:space:]]/}" == "x86_64-Linux" ]]; then
     cat "${SYSTMP}/merged.json" | jq 'del(.[] | select(.download_url | test("aarch64|armhf|arm64"; "i")))' |\
       jq . > "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.json"
   fi
  fi
  #Checksum
  generate_checksum()
  {
      b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
  }
  generate_checksum "${HOST_TRIPLET}.json"
 #To SDB
  soarql --repo "appimage-github-io" --input "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.json" --output "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.sdb"
  generate_checksum "${HOST_TRIPLET}.sdb"
   if [[ $(stat -c%s "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.sdb") -le 1024 ]] || file -i "${GITHUB_WORKSPACE}/main/external/appimage.github.io/data/${HOST_TRIPLET}.sdb" | grep -qiv 'sqlite'; then
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
#-------------------------------------------------------#
