#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Generate Primary Metadata for bincache:: "${SYSTMP}/bincache_aarch64-Linux.json"
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/scripts/gen_meta_aarch64-Linux.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/scripts/gen_meta_aarch64-Linux.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
rm -rvf "${SYSTMP}/bincache_aarch64-Linux.json" 2>/dev/null
unset PKG_COUNT PKG_COUNT_TMP SBUILD_COUNT
#-------------------------------------------------------#

#-------------------------------------------------------#
##Get All Pkgs
echo -e "\n[+] Fetching Package List <== https://github.com/orgs/pkgforge/packages\n"
gh api "/orgs/pkgforge/packages?package_type=container" --paginate | jq -r '.[] | select(.visibility=="public") | .name' | grep -i 'bincache' | sort -u -o "${TMPDIR}/ghcr_pkgs.tmp"
PKG_COUNT_TMP="$(wc -l < "${TMPDIR}/ghcr_pkgs.tmp" | tr -d '[:space:]')" ; export PKG_COUNT_TMP
if [[ "${PKG_COUNT_TMP}" -le 3000 ]]; then
 echo -e "\n[X] FATAL: Package Count is < 3000, API Failed?\n"
 exit 1
else
 echo -e "[+] Packages (ALL): ${PKG_COUNT_TMP} <== https://github.com/orgs/pkgforge/packages?visibility=public"
fi
##Get SBUILD.json
curl -qfsSL "https://raw.githubusercontent.com/pkgforge/bincache/refs/heads/main/SBUILD_LIST.json" -o "${TMPDIR}/sbuilds.json"
jq -r '.[] | .ghcr_pkg' "${TMPDIR}/sbuilds.json" | sed 's/^ghcr\.io\/pkgforge\///' | sort -u -o "${TMPDIR}/sbuild_list.tmp"
SBUILD_COUNT="$(wc -l < "${TMPDIR}/sbuild_list.tmp" | tr -d '[:space:]')" ; export SBUILD_COUNT
if [[ "${SBUILD_COUNT}" -le 200 ]]; then
 echo -e "\n[X] FATAL: Sbuild Count is < 200, Parsing Failed?\n"
 exit 1
else
 echo -e "[+] SBUILDs: ${SBUILD_COUNT} <== https://github.com/pkgforge/bincache/blob/main/SBUILD_LIST.json"
fi
##Get Input
grep -Ff "${TMPDIR}/sbuild_list.tmp" "${TMPDIR}/ghcr_pkgs.tmp" | sort -u -o "${TMPDIR}/ghcr_pkgs.txt"
#readarray -t pkgs < "${TMPDIR}/ghcr_pkgs.tmp"
#readarray -t sbuilds < "${TMPDIR}/sbuild_list.tmp"
#export SBUILDS="${sbuilds[*]}"
#{
# printf '%s\n' "${pkgs[@]}" | xargs -P 4 -n 1 bash -c '
#    pkg=$(echo "$1" | xargs)
#    for sbuild in ${SBUILDS}; do
#        sbuild_clean=$(echo "$sbuild" | sed "s|^ghcr.io/pkgforge/||")
#        if [[ "$pkg" == *"$sbuild_clean"* ]] || [[ "$sbuild_clean" == *"$pkg"* ]]; then
#            echo "$pkg"
#            break
#        fi
#    done
#  ' _
#} 2>/dev/null | sort -u -o "${TMPDIR}/ghcr_pkgs.txt"
PKG_COUNT="$(wc -l < "${TMPDIR}/ghcr_pkgs.txt" | tr -d '[:space:]')" ; export PKG_COUNT
if [[ "${PKG_COUNT}" -le 200 ]]; then
 echo -e "\n[X] FATAL: Matched Package Count is < 200, Parsing Failed?\n"
 exit 1
else
 echo -e "[+] Packages (Bincache): ${PKG_COUNT} <== https://github.com/orgs/pkgforge/packages?repo_name=bincache&visibility=public"
fi
unset pkg PKG_COUNT PKG_COUNT_TMP pkgs SBUILD_COUNT sbuilds SBUILDS
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate Meta funcs
generate_meta()
{
 #Get SBUILD Json 
  local PKG="$1"
  echo -e "\n[+] Processing ${PKG##*[[:space:]]}\n"
  TMPJSON="$(basename $(mktemp -u)).json"
  MANIFEST_JSON="$(basename $(mktemp -u --suffix=-manifest)).json"
  METADATA_JSON="$(basename $(mktemp -u --suffix=-metadata)).json"
  jq --arg pkg "${PKG%/*}" 'map(select(.ghcr_pkg | contains($pkg | gsub(" "; ""))))' "${TMPDIR}/sbuilds.json" > "${TMPDIR}/${TMPJSON}"
 #Check if contains needed fields
  if jq -e 'map(select(.ghcr_pkg != null and .ghcr_pkg != "")) | length > 0' "${TMPDIR}/${TMPJSON}" > /dev/null; then
   #Get Tag
     PKG_TAG="$(oras repo tags "ghcr.io/pkgforge/${PKG}" | grep -i "aarch64-Linux" | head -n 1 | tr -d '[:space:]')"
   #Check Tag 
     if [ -n "${PKG_TAG+x}" ] && [ -n "${PKG_TAG##*[[:space:]]}" ]; then
     #Fetch Manifest
       oras manifest fetch "ghcr.io/pkgforge/${PKG}:${PKG_TAG}" | jq . > "${TMPDIR}/${MANIFEST_JSON}"
     #Check Manifest 
       if jq -r '.annotations["dev.pkgforge.soar.ghcr_pkg"]' "${TMPDIR}/${MANIFEST_JSON}" | grep -q "${PKG}"; then
         #Get Main Json
          jq '.annotations["dev.pkgforge.soar.json"] | fromjson' "${TMPDIR}/${MANIFEST_JSON}" > "${TMPDIR}/${METADATA_JSON}.tmp01"
         #Check Main Json
          if jq -r '.ghcr_pkg' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -q "${PKG}"; then
           #func to validate updated json
           validate_json()
           {
            if [ -s "${TMPDIR}/${METADATA_JSON}.tmp02" ] && jq empty "${TMPDIR}/${METADATA_JSON}.tmp02" > /dev/null 2>&1; then
              mv "${TMPDIR}/${METADATA_JSON}.tmp02" "${TMPDIR}/${METADATA_JSON}.tmp01"
            else
              echo -e "\n[X] FATAL: Validation Failed\n"
              return 1 || exit 1
            fi
           }
           #Add/update rank
            jq --arg rank "$(jq -r '.[0].rank // ""' "${TMPDIR}/${TMPJSON}")" '.rank = (if $rank and ($rank | length > 0) then $rank else "9999999999" end)' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; validate_json
           #Add/Update pkg_family
            jq --arg pkg_family "$(jq -r '.[0].pkg_family // ""' "${TMPDIR}/${TMPJSON}")" '.pkg_family = if $pkg_family == "" then .pkg else $pkg_family end' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; validate_json
           #Add/Update build_ghactions
            jq --slurpfile manifest "${TMPDIR}/${MANIFEST_JSON}" '
             to_entries | 
             map(
               if .key == "build_log" then
                 [{
                   key: "build_ghactions",
                   value: ($manifest[0].annotations["dev.pkgforge.soar.build_ghactions"] // "")
                 }, .]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; validate_json
           #Add/Update build_id
            jq --slurpfile manifest "${TMPDIR}/${MANIFEST_JSON}" '
             to_entries | 
             map(
               if .key == "build_log" then
                 [{
                   key: "build_id",
                   value: ($manifest[0].annotations["dev.pkgforge.soar.build_id"] // "")
                 }, .]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; validate_json
           #Add/Update ghcr_files
            jq --slurpfile manifest "${TMPDIR}/${MANIFEST_JSON}" 'to_entries |
             map(
               if .key == "ghcr_pkg" then
                 [{
                   key: "ghcr_files",
                   value: ($manifest[0].layers | map(.annotations["org.opencontainers.image.title"]) | sort | unique)
                 }, .]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; validate_json
           #Add/Update ghcr_size & ghcr_size_raw
            jq --arg ghcr_size "$(jq '[.layers[].size] | add' "${TMPDIR}/${MANIFEST_JSON}")" '
             def bytes:
               def _bytes(v; u):
                 if (u | length) == 1 or (u[0] == "" and v < 10240) or v < 1024 then
                   "\(v *100 | round /100) \(u[0])B"
                 else
                   _bytes(v/1024; u[1:])
                 end;
                _bytes(.; ":K:M:G:T:P:E:Z:Y" / ":");
             . | to_entries | map(
               if .key == "ghcr_pkg" then 
                 [., {
                   key: "ghcr_size", 
                   value: ($ghcr_size|tostring)
                 }, {
                   key: "ghcr_size_raw",
                   value: ($ghcr_size|tonumber|bytes)
                 }]
               else [.] 
               end
             ) | flatten | from_entries' \
             "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; validate_json
           #Cleanup & Finalize
             jq 'walk(if type == "object" then with_entries(select(.value != "" and .value != [] and .value != {})) else . end)' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; validate_json
             mv -fv "${TMPDIR}/${METADATA_JSON}.tmp01" "${TMPDIR}/${METADATA_JSON}"
          fi
       fi
     fi
  fi
}
export -f generate_meta
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate
pushd "${TMPDIR}" >/dev/null 2>&1
 unset GHCR_PKG ; readarray -t "GHCR_PKG" < "${TMPDIR}/ghcr_pkgs.txt"
  if [[ -n "${PARALLEL_LIMIT}" ]]; then
   printf '%s\n' "${GHCR_PKG[@]}" | xargs -P "${PARALLEL_LIMIT}" -I "{}" bash -c 'generate_meta "$@" 2>/dev/null' _ "{}"
  else 
   printf '%s\n' "${GHCR_PKG[@]}" | xargs -P "$(($(nproc)+1))" -I "{}" bash -c 'generate_meta "$@" 2>/dev/null' _ "{}"
  fi
popd >/dev/null 2>&1
#-------------------------------------------------------#


#-------------------------------------------------------#
##Merge
find "${TMPDIR}" -type f -name '*-metadata.json' -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | jq -s 'sort_by(.pkg)' > "${TMPDIR}/bincache_aarch64-Linux.json"
##Check
unset PKG_COUNT; PKG_COUNT="$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/bincache_aarch64-Linux.json" | sort -u | wc -l | tr -d '[:space:]')"
if [[ "${PKG_COUNT}" -le 200 ]]; then
 echo -e "\n[X] FATAL: Final Package Count is < 200, Parsing Failed?\n"
 exit 1
else
 echo -e "\n[+] Packages (Bincache): ${PKG_COUNT}"
 mv -fv "${TMPDIR}/bincache_aarch64-Linux.json" "${SYSTMP}/bincache_aarch64-Linux.json"
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/bincache/data"
if command -v rclone &> /dev/null &&\
 [ -s "${HOME}/.rclone.conf" ] &&\
 [ -s "${SYSTMP}/bincache_aarch64-Linux.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  cd "${GITHUB_WORKSPACE}/main/bincache/data"
  cp -fv "${SYSTMP}/bincache_aarch64-Linux.json" "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json"
  #Checksum
  generate_checksum() 
  {
      b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
  }
  generate_checksum "aarch64-Linux.json"
 #To xz
  7z a -t7z -mx=9 -mmt="$(($(nproc)+1))" -bsp1 -bt "aarch64-Linux.json.xz" "aarch64-Linux.json" 2>/dev/null ; generate_checksum "aarch64-Linux.json.xz"
 #To Zstd
  zstd --ultra -22 --force "aarch64-Linux.json" -o "aarch64-Linux.json.zstd" ; generate_checksum "aarch64-Linux.json.zstd"
 #Upload
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json" "r2:/meta/bincache/aarch64-Linux.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json" "r2:/meta/bincache/aarch64-linux.json" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.bsum" "r2:/meta/bincache/aarch64-Linux.json.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.bsum" "r2:/meta/bincache/aarch64-linux.json.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.xz" "r2:/meta/bincache/aarch64-Linux.json.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.xz" "r2:/meta/bincache/aarch64-linux.json.xz" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.xz.bsum" "r2:/meta/bincache/aarch64-Linux.json.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.xz.bsum" "r2:/meta/bincache/aarch64-linux.json.xz.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.zstd" "r2:/meta/bincache/aarch64-Linux.json.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.zstd" "r2:/meta/bincache/aarch64-linux.json.zstd" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.zstd.bsum" "r2:/meta/bincache/aarch64-Linux.json.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  rclone copyto "${GITHUB_WORKSPACE}/main/bincache/data/aarch64-Linux.json.zstd.bsum" "r2:/meta/bincache/aarch64-linux.json.zstd.bsum" --checksum --check-first --user-agent="${USER_AGENT}" &
  wait ; echo
fi
#-------------------------------------------------------#