#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Fetch ppkg data
## Files:
#   ${SYSTMP}/PPKG.json
#
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_ppkg.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_ppkg.sh")
#-------------------------------------------------------#


#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#cleanup
rm -rvf "${SYSTMP}/PPKG.json" "${SYSTMP}/PPKG/" 2>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Setup
sudo curl -qfsSL "https://raw.githubusercontent.com/leleliu008/ppkg/master/ppkg" -o "/usr/local/bin/ppkg"
sudo chmod -v 'a+x' "/usr/local/bin/ppkg"
ppkg setup ; ppkg update ; ppkg sysinfo
ppkg formula-repo-list ; ppkg formula-repo-sync "official-core"
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate
ppkg ls-available -v --json | jq 'sort_by(.pkgname)' > "${TMPDIR}/PPKG_RAW.json"
#Copy
if [[ "$(jq -r '.[] | .pkgname' "${TMPDIR}/PPKG_RAW.json" | wc -l)" -gt 1000 ]]; then
  cp -fv "${TMPDIR}/PPKG_RAW.json" "${SYSTMP}/PPKG_RAW.json"
else
  echo -e "\n[-] FATAL: Failed to Generate PPKG Formulae (Raw)\n"
 exit 1
fi
#Generate Minimal
jq '[.[] | {
  pkg: .pkgname,
  pkg_type: .pkgtype,
  homepage: .["web-url"],
  license: (if (.license | type) == "string" then .license | split(" ") else [] end),
  src_url: (.["git-url"] // .["src-url"]),
  version: .version
}]' "${SYSTMP}/PPKG_RAW.json" | jq . > "${TMPDIR}/PPKG.json"
#Copy
if [[ "$(jq -r '.[] | .pkg' "${TMPDIR}/PPKG.json" | wc -l)" -gt 1000 ]]; then
  cp -fv "${TMPDIR}/PPKG.json" "${SYSTMP}/PPKG.json"
else
  echo -e "\n[-] FATAL: Failed to Generate PPKG Formulae (Main)\n"
 exit 1
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/misc/data"
if [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  if [[ -s "${SYSTMP}/PPKG.json" ]] && [[ $(stat -c%s "${SYSTMP}/PPKG.json") -gt 1000 ]]; then
   cp -fv "${SYSTMP}/PPKG.json" "${GITHUB_WORKSPACE}/main/misc/data/PPKG.json"
   #rclone copyto "${GITHUB_WORKSPACE}/main/misc/data/PPKG.json" "r2:/meta/misc/PPKG.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  fi
  if [[ -s "${SYSTMP}/PPKG_RAW.json" ]] && [[ $(stat -c%s "${SYSTMP}/PPKG_RAW.json") -gt 1000 ]]; then
   cp -fv "${SYSTMP}/PPKG_RAW.json" "${GITHUB_WORKSPACE}/main/misc/data/PPKG_RAW.json"
   #rclone copyto "${GITHUB_WORKSPACE}/main/misc/data/PPKG_RAW.json" "r2:/meta/misc/PPKG_RAW.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  fi
 wait ; echo
fi
#-------------------------------------------------------#