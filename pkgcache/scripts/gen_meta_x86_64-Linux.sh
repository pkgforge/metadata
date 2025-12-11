#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Generate Primary Metadata for pkgcache:: "${SYSTMP}/pkgcache_x86_64-Linux.json"
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/scripts/gen_meta_x86_64-Linux.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/scripts/gen_meta_x86_64-Linux.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
#export HOST_TRIPLET="$(uname -m)-$(uname -s)"
export HOST_TRIPLET="x86_64-Linux"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
rm -rvf "${SYSTMP}/pkgcache_x86_64-Linux.json" 2>/dev/null
unset PKG_COUNT PKG_COUNT_TMP SBUILD_COUNT
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
##Get All Pkgs
echo -e "\n[+] Fetching Package List <== https://github.com/orgs/pkgforge/packages\n"
 for i in {1..5}; do
   curl -w "(DL) <== %{url}\n" -fSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/GHCR_PKGS.json.zstd" \
     --retry 3 --retry-all-errors -o "${TMPDIR}/ghcr_pkgs.tmp.json.zstd"
     zstd --decompress --force "${TMPDIR}/ghcr_pkgs.tmp.json.zstd" -o "${TMPDIR}/ghcr_pkgs.tmp.json"
   unset PKG_GH_TMP; PKG_GH_TMP="$(jq -r '.[] | select(.visibility=="public") | .name' "${TMPDIR}/ghcr_pkgs.tmp.json" 2>/dev/null | grep -iv 'null' | sort -u | wc -l | tr -cd '0-9')"
   if [[ "${PKG_GH_TMP}" -lt 50 ]]; then
     echo "Retrying... ${i}/5"
     sleep 2
   elif [[ "${PKG_GH_TMP}" -gt 50 ]]; then
     jq -r '.[] | select(.visibility=="public") | .name' "${TMPDIR}/ghcr_pkgs.tmp.json" | grep -Eiv '.*-srcbuild(-.*|$)' | grep -i 'pkgcache' | sort -u -o "${TMPDIR}/ghcr_pkgs.tmp"
     unset PKG_GH_TMP
     break
   fi
 done
PKG_COUNT_TMP="$(wc -l < "${TMPDIR}/ghcr_pkgs.tmp" | tr -d '[:space:]')" ; export PKG_COUNT_TMP
if [[ "${PKG_COUNT_TMP}" -le 50 ]]; then
 echo -e "\n[X] FATAL: Package Count is < 50, API Failed?\n"
 exit 1
else
 echo -e "[+] Packages (ALL): ${PKG_COUNT_TMP} <== https://github.com/orgs/pkgforge/packages?visibility=public"
fi
##Get BACKAGE.json
curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/data/BACKAGE.json" -o "${TMPDIR}/BACKAGE.json"
if [[ "$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/BACKAGE.json" | grep -iv 'null' | wc -l | tr -cd '0-9')" -lt 10 ]]; then
 echo -e "\n[X] FATAL: GHCR PKG is < 10, Parsing Failed?\n"
 exit 1
fi
##Get COMP_CACHE.json
curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/data/COMP_VER_CACHE.json" -o "${TMPDIR}/COMP_CACHE.json"
if [[ "$(jq -r '.[] | .build_script' "${TMPDIR}/COMP_CACHE.json" | grep -iv 'null' | wc -l | tr -cd '0-9')" -lt 10 ]]; then
 echo -e "\n[X] FATAL: COMP_PKG is < 10, Parsing Failed?\n"
 exit 1
fi
##Get SBUILD.json
curl -qfsSL "https://raw.githubusercontent.com/pkgforge/pkgcache/refs/heads/main/SBUILD_LIST.json" -o "${TMPDIR}/sbuilds.json"
jq -r '.[] | .ghcr_pkg' "${TMPDIR}/sbuilds.json" | sed 's/^ghcr\.io\/pkgforge\///' | sort -u -o "${TMPDIR}/sbuild_list.tmp"
SBUILD_COUNT="$(wc -l < "${TMPDIR}/sbuild_list.tmp" | tr -d '[:space:]')" ; export SBUILD_COUNT
if [[ "${SBUILD_COUNT}" -le 20 ]]; then
 echo -e "\n[X] FATAL: Sbuild Count is < 20, Parsing Failed?\n"
 exit 1
else
 echo -e "[+] SBUILDs: ${SBUILD_COUNT} <== https://github.com/pkgforge/pkgcache/blob/main/SBUILD_LIST.json"
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
if [[ "${PKG_COUNT}" -le 20 ]]; then
 echo -e "\n[X] FATAL: Matched Package Count is < 200, Parsing Failed?\n"
 exit 1
else
 echo -e "[+] Packages (pkgcache): ${PKG_COUNT} <== https://github.com/orgs/pkgforge/packages?repo_name=pkgcache&visibility=public"
fi
unset pkg PKG_COUNT PKG_COUNT_TMP pkgs SBUILD_COUNT sbuilds SBUILDS
#Get HF Repo
pushd "$(mktemp -d)" >/dev/null 2>&1 && git clone --filter="blob:none" --depth="1" --no-checkout "https://huggingface.co/datasets/pkgforge/pkgcache" && cd "./pkgcache"
 git sparse-checkout set "" && git checkout
 unset HF_REPO_LOCAL ; HF_REPO_LOCAL="$(realpath .)" && export HF_REPO_LOCAL="${HF_REPO_LOCAL}"
 if [ ! -d "${HF_REPO_LOCAL}" ] || [ $(du -s "${HF_REPO_LOCAL}" | cut -f1) -le 100 ]; then
   echo -e "\n[X] FATAL: Failed to clone HF Repo\n"
  exit 1
 fi
popd >/dev/null 2>&1
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
  if [[ "$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/${TMPJSON}" | tr -d '[:space:]' | wc -l)" -gt 1 ]]; then
    jq --arg pkg "${PKG}" 'map(select(.ghcr_pkg | ascii_downcase | gsub("\\s+"; "") == ($pkg | ascii_downcase | gsub("\\s+"; ""))))' "${TMPDIR}/sbuilds.json" > "${TMPDIR}/${TMPJSON}"
  fi
 #Check if contains needed fields
  if jq -e 'map(select(.ghcr_pkg != null and .ghcr_pkg != "")) | length > 0' "${TMPDIR}/${TMPJSON}" > /dev/null; then
   #Get Tag
     PKG_TAG="$(oras repo tags "ghcr.io/pkgforge/${PKG}" | grep -viE '^\s*(latest|srcbuild)[.-][0-9]{6}T[0-9]{6}[.-]' | grep -i "x86_64-Linux" | tail -n 1 | tr -d '[:space:]')"
   #Check Tag 
     if [ -n "${PKG_TAG+x}" ] && [[ "${PKG_TAG}" =~ ^[^[:space:]]+$ ]]; then
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
              echo -e "\n[X] FATAL: Validation Failed --> ${STEP}"
              echo -e "[+] Package: ${PKG}"
              jq . "${TMPDIR}/${METADATA_JSON}.tmp01"
              jq . "${TMPDIR}/${METADATA_JSON}.tmp02"
              return 1 || exit 1
            fi
           }
           #Add/update rank
            echo -e "[+] Adding/Updating [${PKG}] ('.rank')"
            jq --arg rank "$(jq -r '.[0].rank // ""' "${TMPDIR}/${TMPJSON}")" '.rank = (if $rank and ($rank | length > 0) then $rank else "-1" end)' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="RANK" validate_json
           #Add/Update pkg_family
            echo -e "[+] Adding/Updating [${PKG}] ('.pkg_family')"
            jq --arg pkg_family "$(jq -r '.[0].pkg_family // ""' "${TMPDIR}/${TMPJSON}")" '.pkg_family = if $pkg_family == "" then .pkg else $pkg_family end' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="PKG_FAMILY" validate_json
           #Add/Update build_ghactions
            echo -e "[+] Adding/Updating [${PKG}] ('build_ghactions')"
            jq --slurpfile manifest "${TMPDIR}/${MANIFEST_JSON}" '
              def get_build_gha:
                try ($manifest[0].annotations["dev.pkgforge.soar.build_gha"] // "")
                catch "";
              . as $parent |
              to_entries |
              map(
                if .key == "build_log" and ($parent | has("build_gha") | not) then
                  [{
                    key: "build_gha",
                    value: get_build_gha
                  }, .]
                else [.]
                end
              ) | flatten | from_entries
            ' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="build_ghactions" validate_json
           #Add/Update build_id
            echo -e "[+] Adding/Updating [${PKG}] ('build_id')"
            jq --slurpfile manifest "${TMPDIR}/${MANIFEST_JSON}" '
              def get_build_id:
                try ($manifest[0].annotations["dev.pkgforge.soar.build_id"] // "")
                catch "";
              . as $parent |
              to_entries |
              map(
                if .key == "build_log" and ($parent | has("build_id") | not) then
                  [{
                    key: "build_id",
                    value: get_build_id
                  }, .]
                else [.]
                end
              ) | flatten | from_entries
            ' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="build_id" validate_json
           #Add/Update download_count
            echo -e "[+] Adding/Updating [${PKG}] ('download_count')"
            unset DL_COUNT DL_COUNT_MONTH DL_COUNT_WEEK
            if [ -s "${TMPDIR}/BACKAGE.json" ]; then
             DL_COUNT="$(jq -r --arg ghcr_pkg "$(jq -r '.ghcr_pkg | split(":")[0]' "${TMPDIR}/${METADATA_JSON}.tmp01")" 'map(select(.ghcr_pkg | contains($ghcr_pkg))) | .[].download_count' "${TMPDIR}/BACKAGE.json" | tr -cd '0-9' | tr -d '[:space:]')"
             [[ -z "${DL_COUNT}" || "${DL_COUNT}" == "0" || "${DL_COUNT}" == "-1" || ${#DL_COUNT} -gt 12 ]] && unset DL_COUNT
             DL_COUNT_MONTH="$(jq -r --arg ghcr_pkg "$(jq -r '.ghcr_pkg | split(":")[0]' "${TMPDIR}/${METADATA_JSON}.tmp01")" 'map(select(.ghcr_pkg | contains($ghcr_pkg))) | .[].download_count_month' "${TMPDIR}/BACKAGE.json" | tr -cd '0-9' | tr -d '[:space:]')"
             [[ -z "${DL_COUNT_MONTH}" || "${DL_COUNT_MONTH}" == "0" || "${DL_COUNT_MONTH}" == "-1" || ${#DL_COUNT_MONTH} -gt 12 ]] && unset DL_COUNT
             DL_COUNT_WEEK="$(jq -r --arg ghcr_pkg "$(jq -r '.ghcr_pkg | split(":")[0]' "${TMPDIR}/${METADATA_JSON}.tmp01")" 'map(select(.ghcr_pkg | contains($ghcr_pkg))) | .[].download_count_week' "${TMPDIR}/BACKAGE.json" | tr -cd '0-9' | tr -d '[:space:]')"
             [[ -z "${DL_COUNT_WEEK}" || "${DL_COUNT_WEEK}" == "0" || "${DL_COUNT_WEEK}" == "-1" || ${#DL_COUNT_WEEK} -gt 12 ]] && unset DL_COUNT
            else
             DL_COUNT="$(curl -A "${USER_AGENT}" -qfsSL "$(jq -r '.ghcr_url' "${TMPDIR}/${METADATA_JSON}.tmp01")" | grep -i -A 5 'Total downloads' | grep -oP '<h3 title="\K[0-9]+' | tr -cd '0-9' | tr -d '[:space:]')"
             [[ -z "${DL_COUNT}" || "${DL_COUNT}" == "0" || "${DL_COUNT}" == "-1" || ${#DL_COUNT} -gt 12 ]] && unset DL_COUNT
            fi
            [[ $(echo "${DL_COUNT}" | grep -E '^[0-9]+$') ]] || DL_COUNT="-1"
            jq --arg DL_COUNT "${DL_COUNT}" --arg DL_COUNT_MONTH "${DL_COUNT_MONTH}" --arg DL_COUNT_WEEK "${DL_COUNT_WEEK}" '
             to_entries | map(
               if .key == "download_url" then
                 [{
                   key: "download_count",
                   value: ($DL_COUNT | tostring)
                 },
                 {
                   key: "download_count_month",
                   value: ($DL_COUNT_MONTH | tostring)
                 },
                 {
                   key: "download_count_week",
                   value: ($DL_COUNT_WEEK | tostring)
                 },
                .]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="download_count" validate_json
           ##Add/Update gh_pkg
           # echo -e "[+] Adding/Updating [${PKG}] ('gh_pkg')"
           # unset GH_PKG GH_PKG_STATUS
           # GH_PKG="$(jq -r '.download_url // ""' "${TMPDIR}/${METADATA_JSON}.tmp01" | tr -d '[:space:]' | sed -E "s|https://api\.ghcr\.pkgforge\.dev/pkgforge/pkgcache/(.*)\?tag=(.*)\&download=(.*)$|https://github.com/pkgforge/pkgcache/releases/tag/\1/\2|g")"
           # GH_PKG_STATUS="$(curl -X "HEAD" -qfsSL "${GH_PKG}" -I | sed -n 's/^[[:space:]]*HTTP\/[0-9.]*[[:space:]]\+\([0-9]\+\).*/\1/p' | tail -n1 | tr -d '[:space:]')"
           # if echo "${GH_PKG_STATUS}" | grep -qiv '200$'; then
           #   GH_PKG=""
           # fi
           # jq --arg GH_PKG "${GH_PKG}" \
           # '
           #  to_entries | map(
           #    if .key == "ghcr_pkg" then
           #      [{
           #        key: "gh_pkg",
           #        value: ($GH_PKG | tostring)
           #      }, .]
           #    else [.]
           #    end
           #  ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="gh_pkg" validate_json
           #Add/Update ghcr_blob
            echo -e "[+] Adding/Updating [${PKG}] ('ghcr_blob')"
            jq --arg PKG "$(jq -r '.download_url | split("&")[] | select(startswith("download=")) | split("=")[1]' "${TMPDIR}/${METADATA_JSON}.tmp01" | tr -d '[:space:]')" \
             --slurpfile manifest "${TMPDIR}/${MANIFEST_JSON}" \
             'to_entries |
             map(
               if .key == "ghcr_pkg" then
                 [{
                   key: "ghcr_blob",
                   value: ((.value | split(":")[0]) as $name | ($manifest[0].layers[] | select(.annotations["org.opencontainers.image.title"] == $PKG) | .digest) as $digest | $name + "@" + $digest)
                 }, .]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="ghcr_blob" validate_json
           #Add/Update ghcr_files
            echo -e "[+] Adding/Updating [${PKG}] ('ghcr_files')"
            jq --slurpfile manifest "${TMPDIR}/${MANIFEST_JSON}" 'to_entries |
             map(
               if .key == "ghcr_pkg" then
                 [{
                   key: "ghcr_files",
                   value: ($manifest[0].layers | map(.annotations["org.opencontainers.image.title"]) | sort | unique)
                 }, .]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="ghcr_files" validate_json
           #Add/Update ghcr_size & ghcr_size_raw
            echo -e "[+] Adding/Updating [${PKG}] ('ghcr_size', '.ghcr_size_raw')"
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
                   value: ($ghcr_size|tonumber|bytes)
                 }, {
                   key: "ghcr_size_raw",
                   value: ($ghcr_size|tostring)
                 }]
               else [.] 
               end
             ) | flatten | from_entries' \
             "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="ghcr_size" validate_json
           ##Add/Update hf_pkg
           # echo -e "[+] Adding/Updating [${PKG}] ('hf_pkg')"
           # unset HF_PKG HF_PKG_NAME HF_PKG_PATH HF_PKG_SNAP HF_PKG_STATUS
           # HF_PKG="$(jq -r '.download_url // ""' "${TMPDIR}/${METADATA_JSON}.tmp01" | tr -d '[:space:]' | sed -E "s|https://api\.ghcr\.pkgforge\.dev/pkgforge/pkgcache/(.*)\?tag=(.*)\&download=(.*)$|https://hf.co/datasets/pkgforge/pkgcache/tree/main/\1/\2|g")"
           # HF_PKG_NAME="$(jq -r '.pkg_name' "${TMPDIR}/${METADATA_JSON}.tmp01" | tr -d '[:space:]')"
           # ##Slow & Expensive
           # #HF_PKG_STATUS="$(curl -X "HEAD" -kqfsSL "${HF_PKG}" -I | sed -n 's/^[[:space:]]*HTTP\/[0-9.]*[[:space:]]\+\([0-9]\+\).*/\1/p' | tail -n1 | tr -d '[:space:]')"
           # #if echo "${HF_PKG_STATUS}" | grep -qiv '200$'; then
           # #  HF_PKG=""
           # #fi
           # HF_PKG_PATH="$(echo "${HF_PKG}" | sed -E 's|.*/tree/main/||' | tr -d '[:space:]')"
           # echo -e "[+] HF: ${HF_PKG_PATH}/${HF_PKG_NAME}"
           # if [[ "$(git -C "${HF_REPO_LOCAL}" ls-tree --name-only 'HEAD' -- "${HF_PKG_PATH}/${HF_PKG_NAME}" 2>/dev/null)" == "${HF_PKG_PATH}/${HF_PKG_NAME}" ]]; then
           #  #Reset Path as PKG
           #   HF_PKG="https://hf.co/datasets/pkgforge/pkgcache/tree/main/${HF_PKG_PATH}"
           # else
           #  #retry with a snapshot tag
           #   HF_PKG_SNAP="$(jq -r '.snapshots[-1] // "" | split("[")[0]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -iv 'null' | tr -d '[:space:]')"
           #   if [[ "$(git -C "${HF_REPO_LOCAL}" ls-tree --name-only 'HEAD' -- "${HF_PKG_PATH%/*}/${HF_PKG_SNAP}/${HF_PKG_NAME}" 2>/dev/null)" == "${HF_PKG_PATH%/*}/${HF_PKG_SNAP}/${HF_PKG_NAME}" ]]; then
           #     HF_PKG="https://hf.co/datasets/pkgforge/pkgcache/tree/main/${HF_PKG_PATH%/*}/${HF_PKG_SNAP}"
           #   else
           #     HF_PKG=""
           #   fi
           # fi
           # jq --arg HF_PKG "${HF_PKG}" \
           # '
           #  to_entries | map(
           #    if .key == "manifest_url" then
           #      [{
           #        key: "hf_pkg",
           #        value: ($HF_PKG | tostring)
           #      }, .]
           #    else [.]
           #    end
           #  ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="hf_pkg" validate_json
           #Add/Update replaces
            echo -e "[+] Adding/Updating [${PKG}] ('replaces')"
            jq --arg ghcr_pkg "$(jq -r '.ghcr_pkg | split(":")[0]' "${TMPDIR}/${METADATA_JSON}.tmp01")" \
              --slurpfile replaces "${TMPDIR}/${TMPJSON}" '
              to_entries |
              map(
                if .key == "shasum" then
                  [
                    {
                      key: "replaces",
                      value: ($replaces[0] | map(select(.ghcr_pkg as $pkg | $ghcr_pkg | contains($pkg))) | .[0].replaces // [])
                    },
                    .
                  ]
                else [.] end
              ) | flatten | from_entries
            ' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="replaces" validate_json
           #Add/Update version comparison
            echo -e "[+] Adding/Updating [${PKG}] ('version_latest')"
            unset VER_LATEST VER_OUTDATED
            rm -rf "${TMPDIR}/${METADATA_JSON}.tmpxx" 2>/dev/null
            jq --argjson target "$(jq '.build_script' "${TMPDIR}/${METADATA_JSON}.tmp01")" \
               --arg HOST_TRIPLET "${HOST_TRIPLET}" --arg REPO "pkgcache" \
               '[.[] | select(.build_script == $target and .host == $HOST_TRIPLET and .repo == $REPO )] | first' "${TMPDIR}/COMP_CACHE.json" > "${TMPDIR}/${METADATA_JSON}.tmpxx"
            if jq -e '.upver != null and .upver != ""' "${TMPDIR}/${METADATA_JSON}.tmpxx" &>/dev/null; then
              VER_LATEST="$(jq -r '.upver' "${TMPDIR}/${METADATA_JSON}.tmpxx" | grep -iv 'null' | tr -d '[:space:]')"
              if jq -e '.pkgver == .upver' "${TMPDIR}/${METADATA_JSON}.tmpxx" &>/dev/null; then
                VER_OUTDATED="false"
              else
                VER_OUTDATED="true"
              fi
            else
              VER_LATEST="$(jq -r '.version' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -iv 'null' | tr -d '[:space:]')"
              VER_OUTDATED="false"
            fi
            jq --arg VER_LATEST "${VER_LATEST}" --arg VER_OUTDATED "${VER_OUTDATED}" \
            'to_entries | map(
               if .key == "version" then
                 [., {
                   key: "version_latest",
                   value: ($VER_LATEST | tostring)
                 },
                 {
                   key: "version_outdated", 
                   value: ($VER_OUTDATED | tostring)
                 }]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="ver_comp" validate_json
           #Add/Update Notes Parsers
            echo -e "[+] Adding/Updating [${PKG}] ('notes*')"
            unset PKG_DEPRECATED PKG_EXTERNAL PKG_DESKTOP_INTEGRATION PKG_INSTALLABLE PKG_PORTABLE PKG_BUNDLE PKG_BUNDLE_TYPE PKG_TRUSTED RECURSE_PROVIDES SOAR_SYMS
            rm -rf "${TMPDIR}/${METADATA_JSON}.tmpxx" 2>/dev/null
           #Archive
            if [[ "$(jq -r '.pkg_type' "${TMPDIR}/${METADATA_JSON}.tmp01")" == "archive" ]]; then
             #bundle 
              if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[BUNDLE]" ; then
                PKG_BUNDLE="true"
                SOAR_SYMS="true"
              elif jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[NO_BUNDLE]" ; then
                PKG_BUNDLE="true"
                SOAR_SYMS="false"
              else
                PKG_BUNDLE="false"
              fi
             #bundle type
              if [[ "${PKG_BUNDLE}" == "true" ]]; then
               if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "tar.gz" ; then
                 PKG_BUNDLE_TYPE="tar+gz"
               elif jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "tar.xz" ; then
                 PKG_BUNDLE_TYPE="tar+xz"
               elif jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "tar.zst" ; then
                 PKG_BUNDLE_TYPE="tar+zstd"
               else
                 PKG_BUNDLE_TYPE="tar"
               fi
              fi
            fi
           #deprecated
            if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[DEPRECATED]" ; then
              PKG_DEPRECATED="true"
            else
              PKG_DEPRECATED="false"
            fi
           #external
            if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[EXTERNAL]" ; then
              PKG_EXTERNAL="true"
            else
              PKG_EXTERNAL="false"
            fi
           #no desktop integration
            if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[NO_DESKTOP_INTEGRATION]" ; then
              PKG_DESKTOP_INTEGRATION="false"
            else
              PKG_DESKTOP_INTEGRATION="true"
            fi
           #no install
            if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[NO_INSTALL]" ; then
              PKG_INSTALLABLE="false"
            else
              PKG_INSTALLABLE="true"
            fi
           #Portable
            if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[PORTABLE]" ; then
              PKG_PORTABLE="true"
            else
              PKG_PORTABLE="false"
            fi
           #Provides
            if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[NO_RECURSE_PROVIDES]" ; then
              RECURSE_PROVIDES="false"
            else
              #RECURSE_PROVIDES="true"
              RECURSE_PROVIDES="false"
            fi
           #untrusted
            if jq -r '.note[]' "${TMPDIR}/${METADATA_JSON}.tmp01" | grep -qiF "[UNTRUSTED]" ; then
              PKG_TRUSTED="false"
            else
              PKG_TRUSTED="true"
            fi
            jq --arg PKG_DEPRECATED "${PKG_DEPRECATED}" --arg PKG_EXTERNAL "${PKG_EXTERNAL}" \
            --arg PKG_DESKTOP_INTEGRATION "${PKG_DESKTOP_INTEGRATION}" --arg PKG_INSTALLABLE "${PKG_INSTALLABLE}" \
            --arg PKG_PORTABLE "${PKG_PORTABLE}" --arg PKG_BUNDLE "${PKG_BUNDLE}" \
            --arg PKG_BUNDLE_TYPE "${PKG_BUNDLE_TYPE}" --arg PKG_TRUSTED "${PKG_TRUSTED}" \
            --arg RECURSE_PROVIDES "${RECURSE_PROVIDES}" --arg SOAR_SYMS "${SOAR_SYMS}" \
            'to_entries | map(
               if .key == "note" then
                 [., {
                   key: "deprecated",
                   value: ($PKG_DEPRECATED | tostring)
                 },
                 {
                   key: "external", 
                   value: ($PKG_EXTERNAL | tostring)
                 },
                 {
                   key: "desktop_integration", 
                   value: ($PKG_DESKTOP_INTEGRATION | tostring)
                 },
                 {
                   key: "installable", 
                   value: ($PKG_INSTALLABLE | tostring)
                 },
                 {
                   key: "portable", 
                   value: ($PKG_PORTABLE | tostring)
                 },
                 {
                   key: "bundle", 
                   value: ($PKG_BUNDLE | tostring)
                 },
                 {
                   key: "bundle_type", 
                   value: ($PKG_BUNDLE_TYPE | tostring)
                 },
                 {
                   key: "trusted", 
                   value: ($PKG_TRUSTED | tostring)
                 },
                 {
                   key: "recurse_provides", 
                   value: ($RECURSE_PROVIDES | tostring)
                 },
                 {
                   key: "soar_syms",
                   value: ($SOAR_SYMS | tostring)
                 }]
               else [.]
               end
             ) | flatten | from_entries' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="ver_comp" validate_json
           #Cleanup & Finalize
             echo -e "[+] Cleaning Up..."
             jq 'walk(if type == "object" then with_entries(select(.value != "" and .value != [] and .value != {})) else . end)' "${TMPDIR}/${METADATA_JSON}.tmp01" > "${TMPDIR}/${METADATA_JSON}.tmp02" ; STEP="cleanup" validate_json
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
 printf '%s\n' "${GHCR_PKG[@]}" | xargs -P "${PARALLEL_LIMIT:-$(($(nproc)+1))}" -I "{}" bash -c 'generate_meta "$@"' _ "{}"
popd >/dev/null 2>&1
#-------------------------------------------------------#


#-------------------------------------------------------#
##Merge
find "${TMPDIR}" -type f -name '*-metadata.json' -exec bash -c 'jq empty "{}" 2>/dev/null && cat "{}"' \; | jq -s 'sort_by(.pkg)' > "${TMPDIR}/pkgcache_x86_64-Linux.json.tmp"
#Check missing (pkg_id)
  jq '.[] | select(.pkg_id == null or .pkg_id == "" or .pkg_id == "null") | {pkg, build_script}' "${TMPDIR}/pkgcache_x86_64-Linux.json.tmp" > "${SYSTMP}/MISSING_PKG_ID.json"
#Check dupes (pkg_webpage)
  jq 'group_by(.pkg_webpage) | map(select(length > 1)) | flatten | map({pkg_webpage: .pkg_webpage,build_script: .build_script})' "${TMPDIR}/pkgcache_x86_64-Linux.json.tmp" > "${SYSTMP}/DUPES_PKG_WEBPAGE.json"
##Sort Rank
jq '
 def compute_ranks:
    map(select(.rank == "-1" and .download_count != "-1" and .pkg != null)) |
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
    if .rank == "-1" and .download_count != "-1" and .pkg != null then
      .rank = ($ranks[.pkg] // .rank)
    else
      .
    end
  )' "${TMPDIR}/pkgcache_x86_64-Linux.json.tmp" | jq '
  map(if .rank == "-1" then .rank = null else .rank = (.rank | tonumber) end) |
  map(.download_count = (.download_count | tonumber)) |
  (map(select(.download_count != -1)) | sort_by(.rank, .pkg)) as $valid_entries |
  (map(select(.download_count == -1)) | sort_by(.pkg)) as $invalid_entries |
  ($valid_entries + $invalid_entries) | to_entries | map(.value.rank = (.key + 1 | tostring)) |
  map(.value) | sort_by(.pkg)' | jq '.[] | .download_count |= tostring' | jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | jq -s 'if type == "array" then . else [.] end' | jq 'map(to_entries | sort_by(.key) | from_entries)' |\
  jq 'map(select(
     .pkg != null and .pkg != "" and
     .pkg_id != null and .pkg_id != "" and
     .pkg_name != null and .pkg_name != "" and
     .description != null and .description != "" and
     .ghcr_pkg != null and .download_url != "" and
     .version != null and .version != ""
  ))' | jq 'unique_by(.ghcr_pkg) | sort_by(.pkg)' > "${TMPDIR}/pkgcache_x86_64-Linux.json"
#sanity check: jq 'sort_by(.rank | tonumber) | map({pkg_name, rank, download_count})'
#sanity check urls
sed -E 's~\bhttps?:/{1,2}\b~https://~g' -i "${TMPDIR}/pkgcache_x86_64-Linux.json"
##Check
unset PKG_COUNT; PKG_COUNT="$(jq -r '.[] | .ghcr_pkg' "${TMPDIR}/pkgcache_x86_64-Linux.json" | sort -u | wc -l | tr -d '[:space:]')"
if [[ "${PKG_COUNT}" -le 20 ]]; then
 echo -e "\n[X] FATAL: Final Package Count is < 200, Parsing Failed?\n"
 exit 1
else
 echo -e "\n[+] Packages (Pkgcache): ${PKG_COUNT}"
 mv -fv "${TMPDIR}/pkgcache_x86_64-Linux.json" "${SYSTMP}/pkgcache_x86_64-Linux.json"
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/pkgcache/data"
if [ -s "${SYSTMP}/pkgcache_x86_64-Linux.json" ] &&\
 [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy
  cd "${GITHUB_WORKSPACE}/main/pkgcache/data"
  cp -fv "${SYSTMP}/pkgcache_x86_64-Linux.json" "${GITHUB_WORKSPACE}/main/pkgcache/data/x86_64-Linux.json"
  #Checksum
  generate_checksum() 
  {
      b3sum "$1" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "$1.bsum"
  }
  generate_checksum "x86_64-Linux.json"
 #To SDB
  soarql --repo "pkgcache" --input "${GITHUB_WORKSPACE}/main/pkgcache/data/x86_64-Linux.json" --output "${GITHUB_WORKSPACE}/main/pkgcache/data/x86_64-Linux.sdb"
  generate_checksum "x86_64-Linux.sdb"
   if [[ $(stat -c%s "${GITHUB_WORKSPACE}/main/pkgcache/data/x86_64-Linux.sdb") -le 1024 ]] || file -i "${GITHUB_WORKSPACE}/main/pkgcache/data/x86_64-Linux.sdb" | grep -qiv 'sqlite'; then
     echo -e "\n[✗] FATAL: Failed to generate Soar DB...\n"
   exit 1
   fi
 #To Bita
  bita compress --input "x86_64-Linux.json" --compression "zstd" --compression-level "21" --force-create "x86_64-Linux.json.cba"
  bita compress --input "x86_64-Linux.sdb" --compression "zstd" --compression-level "21" --force-create "x86_64-Linux.sdb.cba"
 #To xz
  xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "x86_64-Linux.json" ; generate_checksum "x86_64-Linux.json.xz"
  xz -9 -T"$(($(nproc) + 1))" --compress --extreme --keep --force --verbose "x86_64-Linux.sdb" ; generate_checksum "x86_64-Linux.sdb.xz"
 #To Zstd
  zstd --ultra -22 --force "x86_64-Linux.json" -o "x86_64-Linux.json.zstd" ; generate_checksum "x86_64-Linux.json.zstd"
  zstd --ultra -22 --force "x86_64-Linux.sdb" -o "x86_64-Linux.sdb.zstd" ; generate_checksum "x86_64-Linux.sdb.zstd"
  wait ; echo
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Generate Diff
cd "${GITHUB_WORKSPACE}/main" && git pull origin main --no-edit 2>/dev/null
bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_diff.sh")
#-------------------------------------------------------#
