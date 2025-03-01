#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## FILES:
# "${SYSTMP}/INDEX.json" --> The main json
# "${SYSTMP}/INVALID_BINARIES.txt" --> code blocks containing raw sbuild-linter output for binaries
# "${SYSTMP}/INVALID_PACKAGES.txt" --> code blocks containing raw sbuild-linter output for packages
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_meta_index.sh
# PARALLEL_LIMIT="20" bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_meta_index.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
##Install Requirements
#Linter
curl -qfsSL "https://api.gh.pkgforge.dev/repos/pkgforge/sbuilder/releases?per_page=100" | jq -r '.. | objects | .browser_download_url? // empty' | grep -Ei "$(uname -m)" | grep -Eiv "tar\.gz|\.b3sum" | grep -Ei "sbuild-linter" | sort --version-sort | tail -n 1 | tr -d '[:space:]' | xargs -I "{}" curl -qfsSL "{}" -o "${TMPDIR}/sbuild-linter"
chmod +x "${TMPDIR}/sbuild-linter"
 if [[ ! -s "${TMPDIR}/sbuild-linter" || $(stat -c%s "${TMPDIR}/sbuild-linter") -le 1024 ]]; then
   echo -e "\n[✗] FATAL: sbuild-linter Appears to be NOT INSTALLED...\n"
  exit 1
 else
   timeout 10 "${TMPDIR}/sbuild-linter" --help
 fi
#Guix
  "/root/.config/guix/current/bin/guix-daemon" --build-users-group="guixbuild" &
#Nix
  "/nix/nix-installer" uninstall --no-confirm 2>/dev/null
  curl -qfsSL "https://install.determinate.systems/nix" | bash -s -- install linux --init none --extra-conf "filter-syscalls = false" --no-confirm
  source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  sudo chown --recursive "$(whoami)" "/nix"
  echo "root    ALL=(ALL:ALL) ALL" | sudo tee -a "/etc/sudoers"
  #Test
  if ! command -v nix &> /dev/null; then
     echo -e "\n[-] nix NOT Found\n"
     export CONTINUE="NO"
     return 1 || exit 1
  else
     nix --version && nix-channel --list && nix-channel --update
     nix derivation show "nixpkgs#hello" --impure --refresh --quiet >/dev/null 2>&1
  fi
##Sanity Check
if [ -n "${GITHUB_TOKEN+x}" ] && [ -n "${GITHUB_TOKEN##*[[:space:]]}" ]; then
  #Write to nix.conf
   echo "access-tokens = github.com=${GITHUB_TOKEN}" | sudo tee -a "/etc/nix/nix.conf" >/dev/null 2>&1
else
  #60 req/hr
   echo -e "\n[-] GITHUB_TOKEN is NOT Exported"  
   exit 1
fi
if [ -n "${PARALLEL_LIMIT+x}" ] && [[ "${PARALLEL_LIMIT}" =~ ^[^[:space:]]+$ ]]; then
  echo "[+] PARALLEL_LIMIT=${PARALLEL_LIMIT}"
else
  unset PARALLEL_LIMIT
fi
##Get Files
#Bincache
curl -qfsSL "https://meta.pkgforge.dev/bincache/aarch64-Linux.json" | jq -c '.[] | {pkg_family: .pkg_family, ghcr_pkg: (.ghcr_pkg | split(":")[0]), build_script: .build_script}' > "${TMPDIR}/bincache.json.tmp"
curl -qfsSL "https://meta.pkgforge.dev/bincache/x86_64-Linux.json" | jq -c '.[] | {pkg_family: .pkg_family, ghcr_pkg: (.ghcr_pkg | split(":")[0]), build_script: .build_script}' >> "${TMPDIR}/bincache.json.tmp"
jq -s 'unique' "${TMPDIR}/bincache.json.tmp" | jq . > "${TMPDIR}/bincache.json"
if [[ "$(jq -r '.[] | .pkg_family' "${TMPDIR}/bincache.json" | grep -iv 'null' | wc -l)" -le 400 ]]; then
   echo -e "\n[-] FATAL: Failed to Generate Bincache Input\n"
   exit 1
fi
##Pkgcache
curl -qfsSL "https://meta.pkgforge.dev/pkgcache/aarch64-Linux.json" | jq -c '.[] | {pkg_family: .pkg_family, ghcr_pkg: (.ghcr_pkg | split(":")[0]), build_script: .build_script}' > "${TMPDIR}/pkgcache.json.tmp"
curl -qfsSL "https://meta.pkgforge.dev/pkgcache/x86_64-Linux.json" | jq -c '.[] | {pkg_family: .pkg_family, ghcr_pkg: (.ghcr_pkg | split(":")[0]), build_script: .build_script}' >> "${TMPDIR}/pkgcache.json.tmp"
jq -s 'unique' "${TMPDIR}/pkgcache.json.tmp" | jq . > "${TMPDIR}/pkgcache.json"
if [[ "$(jq -r '.[] | .pkg_family' "${TMPDIR}/pkgcache.json" | grep -iv 'null' | wc -l)" -le 20 ]]; then
   echo -e "\n[-] FATAL: Failed to Generate Pkgcache Input\n"
   exit 1
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Repo
 pushd "$(mktemp -d)" >/dev/null 2>&1 && git clone --filter="blob:none" --depth="1" "https://github.com/pkgforge/soarpkgs" && cd "./soarpkgs"
 find . -type f ! -path "./.git/*" -exec dos2unix --quiet "{}" \; 2>/dev/null
 GH_REPO_PATH="$(realpath .)" ; export GH_REPO_PATH
 popd >/dev/null 2>&1
 if [ ! -d "${GH_REPO_PATH}" ] || [ $(du -s "${GH_REPO_PATH}" | cut -f1) -le 100 ]; then
  echo -e "\n[✗] FATAL: Could NOT Clone https://github.com/pkgforge/soarpkgs...\n"
  exit 1
 fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Validate everything (binaries)
pushd "${TMPDIR}"
#First Run
 find "${GH_REPO_PATH}/binaries" -type f -iregex '.*\.\(yml\|yaml\)$' -print0 | xargs -0 "${TMPDIR}/sbuild-linter" --parallel "${PARALLEL_LIMIT:-$(($(nproc)+1))}" --fail "${TMPDIR}/INVALID_BINARIES_01.txt" --timeout "120" --pkgver
#Retry
 if [ -s "${TMPDIR}/INVALID_BINARIES_01.txt" ]; then
   cat "${TMPDIR}/INVALID_BINARIES_01.txt" | xargs "${TMPDIR}/sbuild-linter" --parallel "${PARALLEL_LIMIT:-$(($(nproc)+1))}" --fail "${TMPDIR}/INVALID_BINARIES_02.txt" --timeout "120" --pkgver
  #Retry without --pkgver
   if [ -s "${TMPDIR}/INVALID_BINARIES_02.txt" ]; then
     cat "${TMPDIR}/INVALID_BINARIES_02.txt" | xargs "${TMPDIR}/sbuild-linter" --parallel "${PARALLEL_LIMIT:-$(($(nproc)+1))}" --fail "${TMPDIR}/INVALID_BINARIES_03.txt"
    #Log Output for Issue 
     if [ -s "${TMPDIR}/INVALID_BINARIES_03.txt" ]; then
       readarray -t "FAILED_SBUILD" < "${TMPDIR}/INVALID_BINARIES_03.txt"
       {
         for F_SBUILD in "${FAILED_SBUILD[@]}"; do
         echo '```bash'
          "${TMPDIR}/sbuild-linter" "${F_SBUILD}"
         echo '```'
         done
       } >> "${TMPDIR}/INVALID_BINARIES_log.txt" 2>&1
       sed 's|.*/binaries|https://github.com/pkgforge/soarpkgs/blob/main/binaries|' "${TMPDIR}/INVALID_BINARIES_log.txt" | ansi2txt | tee "${SYSTMP}/INVALID_BINARIES.txt"
     fi
   fi
 fi
##Store Validated files
find "${GH_REPO_PATH}/binaries" -type f -iregex '.*\.validated$' | sort -u -o "${TMPDIR}/valid_bins.txt"
readarray -t "VALID_BINS" < "${TMPDIR}/valid_bins.txt"
##Loop & Generate Meta
for SBUILD in "${VALID_BINS[@]}"; do
    #VALID_BINSRC="$(echo "${SBUILD}" | sed -E 's|.*/binaries/||; s|\.validated$||' | tr -d '[:space:]')"
    VALID_BINSRC="$(echo "${SBUILD##*/binaries/}" | sed -E 's|\.validated$||' | tr -d '[:space:]')"
    BINCACHE="$(jq --arg VALID_BINSRC "${VALID_BINSRC}" -r '.[] | select(.build_script | test($VALID_BINSRC+"$")) | .ghcr_pkg' "${TMPDIR}/bincache.json" | head -n 1 | awk -F'/' '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}' | tr -d '[:space:]')"
    BUILD_SCRIPT="https://github.com/pkgforge/soarpkgs/blob/main/binaries/${VALID_BINSRC}"
    PKG_FAMILY="$(basename $(dirname "${SBUILD}") | tr -d '[:space:]')"
    PKG_VERSION="$(echo "${SBUILD}" | sed 's/\.validated$/.pkgver/' | xargs cat 2>/dev/null | tr -d '[:space:]')"
    if [ -s "$(dirname ${SBUILD})/assets/$(basename ${SBUILD}).png" ]; then
       ICON="https://soarpkgs.pkgforge.dev/binaries/$(basename $(dirname ${SBUILD}))/assets/$(basename ${SBUILD}).png"
    elif [ -s "$(dirname ${SBUILD})/assets/$(basename ${SBUILD}).svg" ]; then
       ICON="https://soarpkgs.pkgforge.dev/binaries/$(basename $(dirname ${SBUILD}))/assets/$(basename ${SBUILD}).svg"
    elif [ -s "$(dirname ${SBUILD})/assets/default.png" ]; then
       ICON="https://soarpkgs.pkgforge.dev/binaries/$(basename $(dirname ${SBUILD}))/assets/default.png"
    elif [ -s "$(dirname ${SBUILD})/assets/default.svg" ]; then
       ICON="https://soarpkgs.pkgforge.dev/binaries/$(basename $(dirname ${SBUILD}))/assets/default.svg"   
    else
       ICON=""
    fi
    echo -e "\n[+] SBUILD: ${VALID_BINSRC}"
    echo -e "[+] BUILD_SCRIPT: ${BUILD_SCRIPT}"
    echo -e "[+] BINCACHE: ${BINCACHE}"
    echo -e "[+] ICON: ${ICON}"
    echo -e "[+] PKG_FAMILY: ${PKG_FAMILY}"
    echo -e "[+] PKG_VERSION: ${PKG_VERSION}"
    yq . "${SBUILD}" | yj -yj | jq --arg VALID_BINSRC "${VALID_BINSRC:-}" \
    --arg BINCACHE "${BINCACHE:-}" --arg ICON "${ICON:-}" --arg PKG_FAMILY "${PKG_FAMILY:-}" \
    --arg PKG_VERSION "${PKG_VERSION:-}" --arg ICON "${ICON:-}"  \
  '{
   "_disabled": (._disabled | tostring // "unknown"),
   "_disabled_reason": ._disabled_reason,
   "pkg": .pkg,
   "pkg_family": $PKG_FAMILY,
   "pkg_id": .pkg_id,
   "pkg_type": .pkg_type,
   "pkg_webpage": ("https://pkgs.pkgforge.dev/repo/soarpkgs/" + (.pkg_id | ascii_downcase | gsub("\\.";"-") | split("-") | .[-2:] | join("-")) + "/" + $PKG_FAMILY + "/" + .pkg),
   "app_id": .app_id,
   "bincache": $BINCACHE,
   "build_script": ("https://github.com/pkgforge/soarpkgs/blob/main/binaries/" + $VALID_BINSRC),
   "category": .category,
   "description": .description,
   "distro_pkg": .distro_pkg,
   "download_url": ("https://soarpkgs.pkgforge.dev/binaries/" + $VALID_BINSRC),
   "homepage": .homepage,
   "host": (if .x_exec.host? and (.x_exec.host | type == "array") then .x_exec.host else ["x86_64-Linux"] end),
   "icon": (
    if (.icon | type == "object" and .icon.url and (.icon.url | length > 0)) then
      .icon.url
    elif (.icon | type == "string" and length > 0) then
      .icon
    elif ($ICON | length > 0) then
      $ICON
    else
      null
    end),
   "license": (
     if (.license | type == "array" and length > 0 and (.[0] | type == "object" and has("id"))) then
       [.license[].id] 
     elif (.license | type == "array") then
       .license
     elif (.license | type == "string") then
       [.license]
     else 
       null
     end),
   "maintainer": .maintainer,
   "note": .note,
   "provides": .provides,
   "repology": .repology,
   "src_url": .src_url,
   "tag": .tag,
   "version": $PKG_VERSION
  }' | jq -c 'if type == "array" then .[] else . end' > "${SBUILD}.json"
  if [ "$(jq -r '.pkg_family' "${SBUILD}.json" | grep -iv 'null' | tr -d '[:space:]')" != "${PKG_FAMILY}" ]; then
    echo -e "[-] FATAL: Failed to Generate Json ==> ${SBUILD}"
  fi
done
##Merge
find "${GH_REPO_PATH}/binaries" -type f -iregex '.*\.validated.json$' -print0 | xargs -0 jq -s '.' | sed -z 's/  }\n]\n\[\n  {/},{/g' | jq 'sort_by(.pkg_family)' > "${TMPDIR}/BINARIES.json.tmp"
##Sanity Check
if [[ "$(jq -r '.[] | .build_script' "${TMPDIR}/BINARIES.json.tmp" | grep -iv 'null' | wc -l)" -le 400 ]]; then
   echo -e "\n[-] FATAL: Failed to Generate Bincache MetaData\n"
   exit 1
else
   cp -fv "${TMPDIR}/BINARIES.json.tmp" "${TMPDIR}/BINARIES.json"
fi
popd >/dev/null 2>&1
#-------------------------------------------------------#

#-------------------------------------------------------#
##Validate everything (packages)
pushd "${TMPDIR}"
#First Run
 find "${GH_REPO_PATH}/packages" -type f -iregex '.*\.\(yml\|yaml\)$' -print0 | xargs -0 "${TMPDIR}/sbuild-linter" --parallel "${PARALLEL_LIMIT:-$(($(nproc)+1))}" --fail "${TMPDIR}/INVALID_PACKAGES_01.txt" --timeout "120" --pkgver
#Retry
 if [ -s "${TMPDIR}/INVALID_PACKAGES_01.txt" ]; then
   cat "${TMPDIR}/INVALID_PACKAGES_01.txt" | xargs "${TMPDIR}/sbuild-linter" --parallel "${PARALLEL_LIMIT:-$(($(nproc)+1))}" --fail "${TMPDIR}/INVALID_PACKAGES_02.txt" --timeout "120" --pkgver
  #Retry without --pkgver
   if [ -s "${TMPDIR}/INVALID_PACKAGES_02.txt" ]; then
     cat "${TMPDIR}/INVALID_PACKAGES_02.txt" | xargs "${TMPDIR}/sbuild-linter" --parallel "${PARALLEL_LIMIT:-$(($(nproc)+1))}" --fail "${TMPDIR}/INVALID_PACKAGES_03.txt"
    #Log Output for Issue 
     if [ -s "${TMPDIR}/INVALID_PACKAGES_03.txt" ]; then
       readarray -t "FAILED_SBUILD" < "${TMPDIR}/INVALID_PACKAGES_03.txt"
       {
         for F_SBUILD in "${FAILED_SBUILD[@]}"; do
         echo '```bash'
          "${TMPDIR}/sbuild-linter" "${F_SBUILD}"
         echo '```'
         done
       } >> "${TMPDIR}/INVALID_PACKAGES_log.txt" 2>&1
       sed 's|.*/packages|https://github.com/pkgforge/soarpkgs/blob/main/packages|' "${TMPDIR}/INVALID_PACKAGES_log.txt" | ansi2txt | tee "${SYSTMP}/INVALID_PACKAGES.txt"
     fi
   fi
 fi
##Store Validated files
find "${GH_REPO_PATH}/packages" -type f -iregex '.*\.validated$' | sort -u -o "${TMPDIR}/valid_pkgs.txt"
readarray -t "VALID_PKGS" < "${TMPDIR}/valid_pkgs.txt"
##Loop & Generate Meta
for SBUILD in "${VALID_PKGS[@]}"; do
    #VALID_PKGSRC="$(echo "${SBUILD}" | sed -E 's|.*/packages/||; s|\.validated$||' | tr -d '[:space:]')"
    VALID_PKGSRC="$(echo "${SBUILD##*/packages/}" | sed -E 's|\.validated$||' | tr -d '[:space:]')"
    PKGCACHE="$(jq --arg VALID_PKGSRC "${VALID_PKGSRC}" -r '.[] | select(.build_script | test($VALID_PKGSRC+"$")) | .ghcr_pkg' "${TMPDIR}/pkgcache.json" | head -n 1 | awk -F'/' '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6}' | tr -d '[:space:]')"
    BUILD_SCRIPT="https://github.com/pkgforge/soarpkgs/blob/main/packages/${VALID_PKGSRC}"
    PKG_FAMILY="$(basename $(dirname "${SBUILD}") | tr -d '[:space:]')"
    PKG_VERSION="$(echo "${SBUILD}" | sed 's/\.validated$/.pkgver/' | xargs cat 2>/dev/null | tr -d '[:space:]')"
    if [ -s "$(dirname ${SBUILD})/assets/$(basename ${SBUILD}).png" ]; then
       ICON="https://soarpkgs.pkgforge.dev/packages/$(basename $(dirname ${SBUILD}))/assets/$(basename ${SBUILD}).png"
    elif [ -s "$(dirname ${SBUILD})/assets/$(basename ${SBUILD}).svg" ]; then
       ICON="https://soarpkgs.pkgforge.dev/packages/$(basename $(dirname ${SBUILD}))/assets/$(basename ${SBUILD}).svg"
    elif [ -s "$(dirname ${SBUILD})/assets/default.png" ]; then
       ICON="https://soarpkgs.pkgforge.dev/packages/$(basename $(dirname ${SBUILD}))/assets/default.png"
    elif [ -s "$(dirname ${SBUILD})/assets/default.svg" ]; then
       ICON="https://soarpkgs.pkgforge.dev/packages/$(basename $(dirname ${SBUILD}))/assets/default.svg"   
    else
       ICON=""
    fi
    echo -e "\n[+] SBUILD: ${VALID_PKGSRC}"
    echo -e "[+] BUILD_SCRIPT: ${BUILD_SCRIPT}"
    echo -e "[+] PKGCACHE: ${PKGCACHE}"
    echo -e "[+] ICON: ${ICON}"
    echo -e "[+] PKG_FAMILY: ${PKG_FAMILY}"
    echo -e "[+] PKG_VERSION: ${PKG_VERSION}"
    yq . "${SBUILD}" | yj -yj | jq --arg VALID_PKGSRC "${VALID_PKGSRC:-}" \
    --arg PKGCACHE "${PKGCACHE:-}" --arg ICON "${ICON:-}" --arg PKG_FAMILY "${PKG_FAMILY:-}" \
    --arg PKG_VERSION "${PKG_VERSION:-}" --arg ICON "${ICON:-}"  \
  '{
   "_disabled": (._disabled | tostring // "unknown"),
   "_disabled_reason": ._disabled_reason,
   "pkg": .pkg,
   "pkg_family": $PKG_FAMILY,
   "pkg_id": .pkg_id,
   "pkg_type": .pkg_type,
   "pkg_webpage": ("https://pkgs.pkgforge.dev/repo/soarpkgs/" + (.pkg_id | ascii_downcase | gsub("\\.";"-") | split("-") | .[-2:] | join("-")) + "/" + $PKG_FAMILY + "/" + .pkg),
   "app_id": .app_id,
   "build_script": ("https://github.com/pkgforge/soarpkgs/blob/main/packages/" + $VALID_PKGSRC),
   "category": .category,
   "description": .description,
   "distro_pkg": .distro_pkg,
   "download_url": ("https://soarpkgs.pkgforge.dev/packages/" + $VALID_PKGSRC),
   "homepage": .homepage,
   "host": (if .x_exec.host? and (.x_exec.host | type == "array") then .x_exec.host else ["x86_64-Linux"] end),
   "icon": (
    if (.icon | type == "object" and .icon.url and (.icon.url | length > 0)) then
      .icon.url
    elif (.icon | type == "string" and length > 0) then
      .icon
    elif ($ICON | length > 0) then
      $ICON
    else
      null
    end),
   "license": (
     if (.license | type == "array" and length > 0 and (.[0] | type == "object" and has("id"))) then
       [.license[].id] 
     elif (.license | type == "array") then
       .license
     elif (.license | type == "string") then
       [.license]
     else 
       null
     end),
   "maintainer": .maintainer,
   "note": .note,
   "pkgcache": $PKGCACHE,
   "provides": .provides,
   "repology": .repology,
   "src_url": .src_url,
   "tag": .tag,
   "version": $PKG_VERSION
  }' | jq -c 'if type == "array" then .[] else . end' > "${SBUILD}.json"
  if [ "$(jq -r '.pkg_family' "${SBUILD}.json" | grep -iv 'null' | tr -d '[:space:]')" != "${PKG_FAMILY}" ]; then
    echo -e "[-] FATAL: Failed to Generate Json ==> ${SBUILD}"
  fi
done
##Merge
find "${GH_REPO_PATH}/packages" -type f -iregex '.*\.validated.json$' -print0 | xargs -0 jq -s '.' | sed -z 's/  }\n]\n\[\n  {/},{/g' | jq 'unique | sort_by(.pkg_family)' > "${TMPDIR}/PACKAGES.json.tmp"
##Sanity Check
if [[ "$(jq -r '.[] | .build_script' "${TMPDIR}/PACKAGES.json.tmp" | grep -iv 'null' | wc -l)" -le 10 ]]; then
   echo -e "\n[-] FATAL: Failed to Generate Pkgcache MetaData\n"
   exit 1
else
   cp -fv "${TMPDIR}/PACKAGES.json.tmp" "${TMPDIR}/PACKAGES.json"
fi
popd >/dev/null 2>&1
#-------------------------------------------------------#

#-------------------------------------------------------#
##Copy to ${SYSTMP}
jq -s add "${TMPDIR}/BINARIES.json" "${TMPDIR}/PACKAGES.json" | jq 'sort_by(.pkg)' | jq 'walk(if type == "object" then with_entries(select(.value != null and .value != "" and .value != [] and .value != {})) else . end)' | jq 'walk(if type == "boolean" or type == "number" then tostring else . end)' | jq 'if type == "array" then . else [.] end' | jq 'unique | sort_by(.pkg)' > "${TMPDIR}/INDEX.json"
if [[ "$(jq -r '.[] | .build_script' "${TMPDIR}/INDEX.json" | grep -iv 'null' | wc -l)" -le 100 ]]; then
   echo -e "\n[-] FATAL: Failed to Generate Soarpkgs MetaData\n"
   exit 1   
else
   cp -fv "${TMPDIR}/INDEX.json" "${SYSTMP}/INDEX.json"
fi
#-------------------------------------------------------#
