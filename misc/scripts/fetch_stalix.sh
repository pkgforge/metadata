#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Fetch Stal/IX data
## Files:
#   "${SYSTMP}/STALIX.json"
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_stalix.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_stalix.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#Cleanup
rm -rvf "${SYSTMP}/STALIX.json" 2>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate Data
#Fetch repo
pushd "${TMPDIR}" >/dev/null 2>&1
#https://github.com/repology/repology-updater/blob/master/repos.d/stalix.yaml
#curl -qfsSL "https://raw.githubusercontent.com/stal-ix/ix/refs/heads/main/pkgs/die/scripts/dump.json" | jq \
curl -qfsSL "https://raw.githubusercontent.com/pg83/ix/refs/heads/main/pkgs/die/scripts/dump.json" | jq \
 '
  def safe_extract(field_name):
    [.. | objects | select(has(field_name)) | .[field_name]] | first // null;
  
  def safe_extract_all(field_name):
    [.. | objects | select(has(field_name)) | .[field_name]] | flatten // null;
  
  def extract_pkg_name(full_path):
    if full_path and full_path != "" and full_path != null then
      (full_path | split("/") | last | ascii_downcase)
    else
      null
    end;
  
  def generate_pkg_id(pkg_name):
    if pkg_name and pkg_name != "" and pkg_name != null then
      "stalix." + (pkg_name | gsub("[^a-zA-Z0-9]"; "_")) + ".stable"
    else
      null
    end;
  
  {
    pkg: (safe_extract("pkg_name") | if . then ascii_downcase else null end),
    pkg_family: (safe_extract("pkg_name") | if . then ascii_downcase else null end),
    pkg_id: generate_pkg_id(safe_extract("ix_pkg_full_name")),
    pkg_name: (safe_extract("pkg_name") | if . then ascii_downcase else null end),
    pkg_path: safe_extract("ix_pkg_full_name"),
    pkg_type:(safe_extract("category") | if . then ascii_downcase else null end),
    build_script: safe_extract("recipe"),    
    src_url: safe_extract("upstream_urls"),
    version: safe_extract("pkg_ver")
  }
 ' | jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' |\
  jq -s 'if type == "array" then . else [.] end' |\
  jq 'map(select(
     .pkg != null and .pkg != "" and
     .pkg_id != null and .pkg_id != "" and
     .pkg_name != null and .pkg_name != "" and
     .pkg_path != null and .pkg_path != "" and
     .version != null and .version != ""
  ))' | jq 'unique_by(.pkg_id) | sort_by(.pkg)' > "${TMPDIR}/STALIX.json.tmp"
if jq --exit-status . "${TMPDIR}/STALIX.json.tmp" >/dev/null 2>&1; then
 cp -fv "${TMPDIR}/STALIX.json.tmp" "${TMPDIR}/STALIX.json"
fi
#Copy
if [[ "$(jq -r '.[] | .pkg' "${TMPDIR}/STALIX.json" | wc -l)" -gt 1000 ]]; then
  cp -fv "${TMPDIR}/STALIX.json" "${SYSTMP}/STALIX.json"
else
  echo -e "\n[-] FATAL: Failed to Generate Stal/IX Metadata\n"
fi
popd >/dev/null 2>&1
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/misc/data"
if [ -s "${SYSTMP}/STALIX.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy (GitHub)
  cp -fv "${SYSTMP}/STALIX.json" "${GITHUB_WORKSPACE}/main/misc/data/STALIX.json"
 ##rClone
  #rclone copyto "${GITHUB_WORKSPACE}/main/misc/data/STALIX.json" "r2:/meta/misc/STALIX.json" --checksum --check-first --user-agent="${USER_AGENT}"
fi
#-------------------------------------------------------#