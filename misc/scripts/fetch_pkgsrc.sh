#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Fetch FlatPak data
## Files:
#   "${SYSTMP}/PKGSRC.json"
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_pkgsrc.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_pkgsrc.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#Cleanup
rm -rvf "${SYSTMP}/PKGSRC.json" 2>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate Data
# https://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/10.0/All/
# https://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/10.0/All/pkg_summary.gz
#Fetch repo
pushd "${TMPDIR}" >/dev/null 2>&1
git clone --filter="blob:none" --depth="1" "https://github.com/NetBSD/pkgsrc"
git clone --filter="blob:none" --depth="1" "git://wip.pkgsrc.org/pkgsrc-wip.git" "./pkgsrc/wip-repo"
find "./pkgsrc" -type f -name "DESCR" | xargs -P "$(($(nproc)+1))" -I {} sh -c '
    PKG=$(basename "$(dirname "{}")");
    DESCR=$(jq -aRs '"'"'gsub("\n";"<br>")'"'"' "{}");
    printf '"'"'{"pkg":"%s","description":%s}\n'"'"' "$PKG" "$DESCR"
' | jq -s '.' > "${TMPDIR}/PKGSRC.json.tmp"
if jq --exit-status . "${TMPDIR}/PKGSRC.json.tmp" >/dev/null 2>&1; then
 cat "${TMPDIR}/PKGSRC.json.tmp" | jq '
 [.[] | {
   pkg: (.pkg // ""),
   description: (
     .description // "" 
     | gsub("\\n[ \t]+"; "<br>")
     | gsub("<br>$"; "")
     | gsub("<br>\\s*<br>"; "<br>")
     | gsub("<br>\\s*<br>+"; "<br>")
     | gsub("\".*?\""; "")
     | gsub("\\s{2,}"; " ")
     | gsub("//"; "")
     | gsub("\\t"; " ")
   ),
 }] | sort_by(.pkg)' | jq . > "${TMPDIR}/PKGSRC.json"
fi
#Copy
if [[ "$(jq -r '.[] | .pkg' "${TMPDIR}/PKGSRC.json" | wc -l)" -gt 10000 ]]; then
  cp -fv "${TMPDIR}/PKGSRC.json" "${SYSTMP}/PKGSRC.json"
else
  echo -e "\n[-] FATAL: Failed to Generate Pkgsrc Metadata\n"
fi
popd >/dev/null 2>&1
#-------------------------------------------------------#


#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/misc/data"
if command -v rclone &> /dev/null &&\
 [ -s "${HOME}/.rclone.conf" ] &&\
 [ -s "${SYSTMP}/PKGSRC.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy (GitHub)
  cp -fv "${SYSTMP}/PKGSRC.json" "${GITHUB_WORKSPACE}/main/misc/data/PKGSRC.json"
 #rClone
  rclone copyto "${GITHUB_WORKSPACE}/main/misc/data/PKGSRC.json" "r2:/meta/misc/PKGSRC.json" --checksum --check-first --user-agent="${USER_AGENT}"
fi
#-------------------------------------------------------#