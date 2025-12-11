#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Meant to Fetch Conda data
## Files:
#   "${SYSTMP}/CONDA.json"
#  "${SYSTMP}/CONDA_RAW.json"
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_conda.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_conda.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#cleanup
rm -rvf "${SYSTMP}/CONDA.json" "${SYSTMP}/CONDA_RAW.json" 2>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Install
sudo curl -w "(DL) <== %{url}\n" -qfsSL "https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-linux-64" -o "/usr/local/bin/micromamba" ||\
sudo curl -w "(DL) <== %{url}\n" -qfsSL "https://github.com/mamba-org/micromamba-releases/releases/download/2.2.0-0/micromamba-linux-x86_64" -o "/usr/local/bin/micromamba"
sudo chmod +x "/usr/local/bin/micromamba" ; hash -r &>/dev/null
if ! command -v micromamba &>/dev/null; then
  echo -e "\n[✗] FATAL: micromamba Appears to be NOT INSTALLED...\n"
 exit 1 
else
  micromamba search jq --channel "anaconda" --quiet --yes
  micromamba search jq --channel "bioconda" --quiet --yes
  micromamba search jq --channel "conda-forge" --quiet --yes
fi
##Fetch
pushd "${TMPDIR}" &>/dev/null
 #Anaconda
   micromamba search "*" --channel "anaconda" --json 2>/dev/null 1>"${TMPDIR}/ANACONDA.json.tmp"
   jq -c '.. | select(type == "array") | select(length > 0) | select(.[0] | type == "object") | select(.[0] | has("build_string")) | .[]' "${TMPDIR}/ANACONDA.json.tmp" 2>/dev/null 1>"${TMPDIR}/ANACONDA.jsonl.tmp"
   jq -c 'del(.build_number, .build_string, .constrains, .depends, .fn, .md5, .md5sum, .noarch, .subdir, .track_features)' "${TMPDIR}/ANACONDA.jsonl.tmp" 2>/dev/null 1>"${TMPDIR}/ANACONDA.jsonl"
   cat "${TMPDIR}/ANACONDA.jsonl" | jq -s \
    '
      def normalize_version(v):
        v | tostring | split(".") | map(tonumber? // 0) | 
        . + [0,0,0,0] | .[0:4];  # Pad to 4 elements for consistent comparison
      group_by(.name) | 
      map(sort_by(.timestamp) | sort_by(normalize_version(.version)) | last) | 
      .[]
    ' -c 2>/dev/null 1>"${TMPDIR}/ANACONDA.jsonl.tmp"
   if [[ -s "${TMPDIR}/ANACONDA.jsonl.tmp" ]] && [[ $(stat -c%s "${TMPDIR}/ANACONDA.jsonl.tmp") -gt 100000 ]]; then
     cp -fv "${TMPDIR}/ANACONDA.jsonl.tmp" "${TMPDIR}/ANACONDA.jsonl"
     du -bh "${TMPDIR}/ANACONDA.jsonl"
   fi
 #Bioconda
   micromamba search "*" --channel "bioconda" --json 2>/dev/null 1>"${TMPDIR}/BIOCONDA.json.tmp"
   jq -c '.. | select(type == "array") | select(length > 0) | select(.[0] | type == "object") | select(.[0] | has("build_string")) | .[]' "${TMPDIR}/BIOCONDA.json.tmp" 2>/dev/null 1>"${TMPDIR}/BIOCONDA.jsonl.tmp"
   jq -c 'del(.build_number, .build_string, .constrains, .depends, .fn, .md5, .md5sum, .noarch, .subdir, .track_features)' "${TMPDIR}/BIOCONDA.jsonl.tmp" 2>/dev/null 1>"${TMPDIR}/BIOCONDA.jsonl"
   cat "${TMPDIR}/BIOCONDA.jsonl" | jq -s \
    '
      def normalize_version(v):
        v | tostring | split(".") | map(tonumber? // 0) | 
        . + [0,0,0,0] | .[0:4];  # Pad to 4 elements for consistent comparison
      group_by(.name) | 
      map(sort_by(.timestamp) | sort_by(normalize_version(.version)) | last) | 
      .[]
    ' -c 2>/dev/null 1>"${TMPDIR}/BIOCONDA.jsonl.tmp"
   if [[ -s "${TMPDIR}/BIOCONDA.jsonl.tmp" ]] && [[ $(stat -c%s "${TMPDIR}/BIOCONDA.jsonl.tmp") -gt 100000 ]]; then
     cp -fv "${TMPDIR}/BIOCONDA.jsonl.tmp" "${TMPDIR}/BIOCONDA.jsonl"
     du -bh "${TMPDIR}/BIOCONDA.jsonl"
   fi
 #conda-forge
   micromamba search "*" --channel "conda-forge" --json 2>/dev/null 1>"${TMPDIR}/CONDA_FORGE.json.tmp"
   jq -c '.. | select(type == "array") | select(length > 0) | select(.[0] | type == "object") | select(.[0] | has("build_string")) | .[]' "${TMPDIR}/CONDA_FORGE.json.tmp" 2>/dev/null 1>"${TMPDIR}/CONDA_FORGE.jsonl.tmp"
   jq -c 'del(.build_number, .build_string, .constrains, .depends, .fn, .md5, .md5sum, .noarch, .subdir, .track_features)' "${TMPDIR}/CONDA_FORGE.jsonl.tmp" 2>/dev/null 1>"${TMPDIR}/CONDA_FORGE.jsonl"
   cat "${TMPDIR}/CONDA_FORGE.jsonl" | jq -s \
    '
      def normalize_version(v):
        v | tostring | split(".") | map(tonumber? // 0) | 
        . + [0,0,0,0] | .[0:4];  # Pad to 4 elements for consistent comparison
      group_by(.name) | 
      map(sort_by(.timestamp) | sort_by(normalize_version(.version)) | last) | 
      .[]
    ' -c 2>/dev/null 1>"${TMPDIR}/CONDA_FORGE.jsonl.tmp"
   if [[ -s "${TMPDIR}/CONDA_FORGE.jsonl.tmp" ]] && [[ $(stat -c%s "${TMPDIR}/CONDA_FORGE.jsonl.tmp") -gt 100000 ]]; then
     cp -fv "${TMPDIR}/CONDA_FORGE.jsonl.tmp" "${TMPDIR}/CONDA_FORGE.jsonl"
     du -bh "${TMPDIR}/CONDA_FORGE.jsonl"
   fi
 #Merge
  if [[ -s "${TMPDIR}/ANACONDA.jsonl" ]] &&\
     [[ -s "${TMPDIR}/BIOCONDA.jsonl" ]] &&\
     [[ -s "${TMPDIR}/CONDA_FORGE.jsonl" ]]; then
    cat "${TMPDIR}/ANACONDA.jsonl" "${TMPDIR}/BIOCONDA.jsonl" "${TMPDIR}/CONDA_FORGE.jsonl" 2>/dev/null |\
     jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | \
     jq 'select(.name | startswith("_") | not) | .timestamp |= (tonumber | strftime("%Y-%m-%dT%H:%M:%SZ"))' | \
     jq -s 'if type == "array" then . else [.] end' |\
     jq 'map(to_entries | sort_by(.key) | from_entries)' 2>/dev/null 1>"${TMPDIR}/CONDA_RAW.json"
     du -bh "${TMPDIR}/CONDA_RAW.json"
  else
     echo -e "\n[✗] FATAL: Failed to generate Initial Data\n"
    exit 1
  fi
 #Parse & Generate
  if [[ "$(jq -r '.[] | .url' "${TMPDIR}/CONDA_RAW.json" 2>/dev/null | wc -l | tr -cd '0-9')" -gt 10000 ]]; then
    mv -fv "${TMPDIR}/CONDA_RAW.json" "${SYSTMP}/CONDA_RAW.json"
    cat "${SYSTMP}/CONDA_RAW.json" | jq \
    'map({
     pkg: (.name // ""),
     pkg_family: (.name // ""),
     build_date: (.timestamp // ""),
     build_id: (.build // ""),
     build_recipe: (
       if (.channel // "") == "conda-forge" then
         "https://raw.githubusercontent.com/conda-forge/" + (.name // "") + "-feedstock/main/recipe/meta.yaml"
       elif (.channel // "") == "bioconda" then
         "https://raw.githubusercontent.com/bioconda/bioconda-recipes/master/recipes/" + (.name // "") + "/meta.yaml"
       else
         ""
       end
     ),
     build_script: (
       if (.channel // "") == "conda-forge" then
         "https://raw.githubusercontent.com/conda-forge/" + (.name // "") + "-feedstock/main/recipe/build.sh"
       elif (.channel // "") == "bioconda" then
         "https://raw.githubusercontent.com/bioconda/bioconda-recipes/master/recipes/" + (.name // "") + "/build.sh"
       else
         ""
       end
     ),
     channel: (.channel // ""),
     download_url: (.url // ""),
     license: (.license // ""),
     shasum: (.sha256 // ""),
     size: (
       (.size | tonumber) as $size_num |
       if $size_num >= 1073741824 then
         (($size_num / 1073741824 * 100 | floor) / 100 | tostring) + " GB"
       elif $size_num >= 1048576 then
         (($size_num / 1048576 * 100 | floor) / 100 | tostring) + " MB"
       elif $size_num >= 1024 then
         (($size_num / 1024 * 100 | floor) / 100 | tostring) + " KB"
       elif $size_num > 0 then
         ($size_num | tostring) + " Bytes"
       else
         ""
       end
     ),
     size_raw: (.size // ""),
     src_url: (
       if (.channel // "") == "conda-forge" then
         "https://github.com/conda-forge/" + (.name // "") + "-feedstock"
       elif (.channel // "") == "bioconda" then
         "https://github.com/bioconda/bioconda-recipes"
       else
         ""
       end
     ),
     version: (.version // "")
   })' 2>/dev/null 1>"${TMPDIR}/CONDA.json"

   cat "${TMPDIR}/CONDA.json" | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "")) | select(length > 0) elif type == "array" then map(select(. != null and . != "")) | select(length > 0) else . end)' |\
     jq 'map(select(
        .pkg != null and .pkg != "" and
        .build_id != null and .build_id != "" and
        .channel != null and .channel != "" and
        .download_url != null and .download_url != "" and
        .shasum != null and .shasum != "" and
        .version != null and .version != ""
     ))' | jq 'unique_by(.download_url) | sort_by(.pkg)' | jq . 2>/dev/null 1>"${TMPDIR}/CONDA.json.tmp"
  fi
 #Copy
  if [[ "$(jq -r '.[] | .pkg' "${TMPDIR}/CONDA.json.tmp" 2>/dev/null | wc -l | tr -cd '0-9')" -gt 10000 ]]; then 
     cp -fv "${TMPDIR}/CONDA.json.tmp" "${SYSTMP}/CONDA.json"
     du -bh "${SYSTMP}/CONDA.json"
  else
     echo -e "\n[✗] FATAL: Failed to generate Merged Data\n"
    exit 1
  fi
popd &>/dev/null  
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to "${GITHUB_WORKSPACE}/main/misc/data"
if [[ -s "${SYSTMP}/CONDA.json" ]] &&\
 [[ -s "${SYSTMP}/CONDA_RAW.json" ]] &&\
 [[ -d "${GITHUB_WORKSPACE}" ]] &&\
 [[ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
 #chdir to Repo
  cd "${GITHUB_WORKSPACE}/main"
 #Git pull
  git pull origin main --no-edit 2>/dev/null
 #Copy (GitHub)
  cp -fv "${SYSTMP}/CONDA.json" "${GITHUB_WORKSPACE}/main/misc/data/CONDA.json"
  cp -fv "${SYSTMP}/CONDA_RAW.json" "${GITHUB_WORKSPACE}/main/misc/data/CONDA_RAW.json"
fi
#-------------------------------------------------------#