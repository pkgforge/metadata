#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## FILES:
# "${SYSTMP}/BACKAGE.json" --> The main json
## Source: 
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_ghcr_backage.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_ghcr_backage.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#-------------------------------------------------------#

#-------------------------------------------------------#
##Fetch Backage
#pushd "${TMPDIR}" >/dev/null 2>&1 && git clone --filter="blob:none" --depth="1" --branch="index" "https://github.com/pkgforge-dev/backage" && cd "./backage"
curl -qfsSL "https://raw.githubusercontent.com/pkgforge-dev/backage/refs/heads/index/pkgforge/bincache/.json" | jq -c '.[]' > "${TMPDIR}/bincache.json"
curl -qfsSL "https://raw.githubusercontent.com/pkgforge-dev/backage/refs/heads/index/pkgforge/pkgcache/.json" | jq -c '.[]' > "${TMPDIR}/pkgcache.json"
##Merge
#find "./pkgforge" -type f -iregex '.*\.json$' -print0 | xargs -0 jq -s '.' | sed -z 's/  }\n]\n\[\n  {/},{/g' |\
 cat "${TMPDIR}/bincache.json" "${TMPDIR}/pkgcache.json" | jq -s '.' |\
 jq 'sort_by(.package | gsub("%2F"; "/") | ("ghcr.io/pkgforge/" + .)) | .[] | {
  ghcr_pkg: ("ghcr.io/pkgforge/" + (.package // "" | gsub("%2F"; "/"))),
  download_count: (.downloads // ""),
  download_count_month: (.downloads_month // ""),
  download_count_week: (.downloads_week // ""),
  download_count_day: (.downloads_day // "")
 }' | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "" and .value != [] and .value != {})) else . end)' | jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | jq -s 'if type == "array" then . else [.] end' | jq 'unique | sort_by(.ghcr_pkg)' > "${TMPDIR}/BACKAGE.json.tmp"
##Sanity Check
if [[ "$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/BACKAGE.json.tmp" | grep -iv 'null' | wc -l)" -le 3000 ]]; then
   echo -e "\n[-] FATAL: Failed to Generate Backage MetaData\n"
   exit 1
else
   cp -fv "${TMPDIR}/BACKAGE.json.tmp" "${SYSTMP}/BACKAGE.json"
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/soarpkgs/data"
if [ -s "${SYSTMP}/BACKAGE.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  cd "${GITHUB_WORKSPACE}/main/soarpkgs/data"
  cp -fv "${SYSTMP}/BACKAGE.json" "${GITHUB_WORKSPACE}/main/soarpkgs/data/BACKAGE.json"
fi
#-------------------------------------------------------#
