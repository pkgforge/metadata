#!/usr/bin/env bash
#
# REQUIRES: awk + coreutils + curl + grep + jq + sed + yq
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/sbuild_creator.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##Enable Debug 
 if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
    set -x
 fi
 SBG_VERSION="0.0.3" && echo -e "[+] SBUILD Generator Version: ${SBG_VERSION}" ; unset SBG_VERSION
#-------------------------------------------------------#

#-------------------------------------------------------#
##CLEAR_ENV
unset APP_ID BUILD_TYPE CATEGORY GH_FETCH PKG_DESCR PKG_ID PKG_MAINTAINER PKG_NAME PKG_TYPE RELEASE_TAG REPOLOGY SRC_URL
##Set ENV
SELF_NAME="${ARGV0:-${0##*/}}" ; export SELF_NAME
SYSTMP="$(dirname $(mktemp -u))"
#User (For Maintainer)
case "${USER}" in
  "" )
    echo "WARNING: \$USER is Unknown"
    USER="$(whoami)"
    export USER
    if [ -z "${USER}" ]; then
      echo -e "[-] INFO: Setting USER --> ${USER}"
    else
      echo -e "[-] WARNING: FAILED to find \$USER"
    fi
    ;;
esac
#TMPDIR
mkdir -p "$(dirname $(mktemp -u))"
SYSTMP="$(dirname $(realpath $(mktemp -u)))"
mkdir -p "${SYSTMP}" 2>/dev/null
#-------------------------------------------------------#

#-------------------------------------------------------#
##Help
show_help() 
 {
    echo "Usage: $0 [-p|--pkg PKG_NAME] [-s|--srcurl SRC_URL] [-r|--repology REPOLOGY_PROJECT_NAME]"
    echo
    echo "Required Options:"
    echo "  -p,  --pkg         Package name (.pkg)"
    echo "  -b,  --buildtype       Build Mode [Values: cargo,go,guix,nix,soar-dl]"
    echo "  -s,  --srcurl      Source URL (.src_url)"
    echo
    echo "Additional Options:"
    echo "  -appid,   --appid         Application ID (.app_id)"
    echo "  -c,       --category      Category (.category) [Single Value OR Comma Separated]"
    echo "  -d,       --desc          Package description (.description) [Otherwise AutoGen from Github/RepoLogy]"
    echo "            --debug         Runs with Set -x [Equal to: DEBUG=1|ON]"
    echo "            --force-cleanup Remove \$TMPDIR|\$TMPFILES without Prompting [Equal to: FORCE_CLEANUP=1|ON]"
    echo "  -m,       --maintainer    Package maintainer (.maintainer) [Otherwise AutoGen from your \$USER]"
    echo "            --no-buildutil  Skip Adding 'build_util' [Equal to: BUILD_UTIL=0|OFF]"
    echo "            --no-linter     Skip Linting [Equal to: LINTER=0|OFF]"
    echo "            --no-shellcheck Skip Shellcheck [Equal to: SHELLCHECK=0|OFF]"
    echo "  -pkgid,   --pkgid         Package ID (.pkg_id) [Otherwise AutoGen from .src_url]"
    echo "  -pkgtype, --pkgtype       Package Type (.pkg_type) [Otherwise 'appimage' by Default]"
    echo "  -r,       --repology      Repology Project Name (.repology) [Otherwise Lot's of Missing/Empty Fields]"
    echo "  -t,       --tag           Release tag (Exact Github Release Tag) [Otherwise Latest/Latest-PreRelease]"
    echo
    echo "ENV VARS:"
    echo "  DEBUG=1|ON              Runs with Set -x"
    echo "  BUILD_UTIL=0|OFF        Skip Adding build_util"
    echo "  FORCE_CLEANUP=1|ON      Remove \$TMPDIR|\$TMPFILES without Prompting"
    echo "  INSTALL_DEPS=1|ON       Attempt to AutoInstall Missing Dependencies using Soar"
    echo "  LINTER=0|OFF            Skip Linting the Generated SBUILD"
    echo "  SHELLCHECK=0|OFF        Skip Shellcheck"
    exit 1
 }
##ARGS
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--pkg)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: Package name cannot be empty or start with -"
                show_help
            fi
            PKG_NAME="$2"
            shift 2
            ;;
        -s|--srcurl)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: Source URL cannot be empty or start with -"
                show_help
            fi
            SRC_URL="$2"
            shift 2
            ;;
        -b|--buildtype)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: Build value cannot be empty or start with -"
                show_help
            fi
            case "$2" in
                cargo|go|guix|nix|soar-dl)
                    BUILD_TYPE="$2"
                    ;;
                *)
                    echo "Error: Invalid build type. Allowed values are: cargo, go, guix, nix, soar-dl"
                    show_help
                    ;;
            esac
            shift 2
            ;;
        -appid|--appid)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                APP_ID="$2"
                shift 2
            else
                echo "Error: Invalid value for APP_ID"
                show_help
            fi
            ;;
        -c|--category)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                CATEGORY="$2"
                shift 2
            else
                echo "Error: Invalid value for CATEGORY"
                show_help
            fi
            ;;
        --debug)
            export DEBUG="ON"
            shift
            ;;
        -d|--desc)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                PKG_DESCR="$2"
                shift 2
            else
                echo "Error: Invalid value for PKG_DESCR"
                show_help
            fi
            ;;
        --force-cleanup)
            export FORCE_CLEANUP="ON"
            shift
            ;;
        -m|--maintainer)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                PKG_MAINTAINER="$2"
                shift 2
            else
                echo "Error: Invalid value for PKG_MAINTAINER"
                show_help
            fi
            ;;
        --no-buildutil)
            export BUILD_UTIL="OFF"
            shift
            ;;
        --no-linter)
            export LINTER="OFF"
            shift
            ;;
        --no-shellcheck)
            export SHELLCHECK="OFF"
            shift
            ;;            
        -pkgid|--pkgid)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                PKG_ID="$2"
                shift 2
            else
                echo "Error: Invalid value for PKG_ID"
                show_help
            fi
            ;;
        -pkgtype|--pkgtype)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                PKG_TYPE="$2"
                shift 2
            else
                echo "Error: Invalid value for PKG_TYPE"
                show_help
            fi
            ;;
        -r|--repology)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                REPOLOGY="$2"
                shift 2
            else
                echo "Error: Invalid value for REPOLOGY"
                show_help
            fi
            ;;
        -t|--tag)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                RELEASE_TAG="$2"
                shift 2
            else
                echo "Error: Invalid value for RELEASE_TAG"
                show_help
            fi
            ;;
        *)
            echo -e "\n[✗] FATAL: Unknown option $1"
            show_help
            ;;
    esac
done
#-------------------------------------------------------#


#-------------------------------------------------------#
##Sanity Checks
#Required
PKG_NAME="$(echo "${PKG_NAME}" | tr -d '[:space:]')"
 if [[ -z "${PKG_NAME// }" ]]; then
    echo -e "\n[✗] FATAL: A Valid Package name (-p|--pkg) is Required\n"
    show_help
 fi
SRC_URL="$(echo "${SRC_URL}" | tr -d '[:space:]')"
 if [[ -z "${SRC_URL// }" ]]; then
    echo -e "\n[✗] FATAL: A Valid Source URL (-s|--srcurl) is Required\n"
    show_help
 elif [[ ! "${SRC_URL}" == http://* && ! "${SRC_URL}" == https://* ]]; then
    echo -e "\n[✗] FATAL: A Valid Source URL (https://) (-s|--srcurl) is Required\n"
    show_help
 else
    if echo "${SRC_URL}" | grep -Eqi "github.com"; then
     export GH_FETCH="YES"
    fi
 fi
##CMD
 #b3sum: Needed for Checksums
 #jq: Needed for some validators, yq's json support is limited (https://github.com/jqlang/jq)
 #Shellcheck: Needed for checking x_exec.run (https://github.com/koalaman/shellcheck)
 #Yj: Needed to convert Yaml <--> Json (https://github.com/sclevine/yj)
 #Yq: The main parser & validator (https://github.com/mikefarah/yq)
 if [ "${INSTALL_DEPS}" = "1" ] || [ "${INSTALL_DEPS}" = "ON" ]; then
   if ! command -v "soar" >/dev/null 2>&1; then
     echo -e "\n[✗] FATAL: soar is NOT INSTALLED\nInstall: https://github.com/pkgforge/soar#-installation\n"
     export CONTINUE_SBUILD="NO"
     return 1
   else
     soar env
     soar add 'b3sum#bin' 'curl#bin' 'grep/grep#base' 'jq#bin' 'sed#bin' 'shellcheck#bin' 'yj#bin' 'yq#bin' --yes
   fi
 fi
 for DEP_CMD in awk b3sum curl find grep jq sed xargs yj yq; do
    case "$(command -v "${DEP_CMD}" 2>/dev/null)" in
        "") echo -e "\n[✗] FATAL: ${DEP_CMD} is NOT INSTALLED\nInstall: soar add \"${DEP_CMD}#bin\" --yes\n"
            export CONTINUE_SBUILD="NO"
            return 1 ;;
    esac
 done
 if [ "${SHELLCHECK}" != "0" ] && [ "${SHELLCHECK}" != "OFF" ]; then
   if ! command -v "shellcheck" >/dev/null 2>&1; then
     echo -e "\n[✗] FATAL: shellcheck is NOT INSTALLED\nInstall: soar add shellcheck --yes\n"
     export CONTINUE_SBUILD="NO"
     return 1
   fi
 fi
##Docs
 show_docs(){
  echo -e "[+] Build Docs: https://github.com/pkgforge/soarpkgs/blob/main/SBUILD.md"
  echo -e "[+] Spec Docs: https://github.com/pkgforge/soarpkgs/blob/main/SBUILD_SPEC.md\n"
 }
 export -f show_docs
#Fill in defaults
if [ -z "${PKG_TYPE+x}" ] || [ -z "${PKG_TYPE##*[[:space:]]}" ]; then
  echo -e "[-] --pkgtype was NOT Used (Default: appimage)"
  PKG_TYPE="appimage"
fi
#Export Everything
export APP_ID BUILD_TYPE CATEGORY PKG_DESCR PKG_MAINTAINER PKG_ID PKG_NAME PKG_TYPE RELEASE_TAG REPOLOGY SRC_URL
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
#Gh
if [ "${GH_FETCH}" == "YES" ]; then
 curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/github_fetcher.sh" -o "${TMPDIR}/github-fetcher"
 if [[ ! -s "${TMPDIR}/github-fetcher" || $(stat -c%s "${TMPDIR}/github-fetcher") -le 10 ]]; then
   echo -e "\n[✗] FATAL: github-fetcher could NOT BE Found\n"
  exit 1
 else
   chmod +x "${TMPDIR}/github-fetcher"
   echo -e "[+] Fetched github-fetcher ..."
 fi
fi
#Repology
curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/repology_fetcher.sh" -o "${TMPDIR}/repology-fetcher"
 if [[ ! -s "${TMPDIR}/repology-fetcher" || $(stat -c%s "${TMPDIR}/repology-fetcher") -le 10 ]]; then
   echo -e "\n[✗] FATAL: repology-fetcher could NOT BE Found\n"
  exit 1
 else
   chmod +x "${TMPDIR}/repology-fetcher"
   echo -e "[+] Fetched repology-fetcher ..."
 fi
#Get Linter
 if [ "${LINTER}" != "0" ] && [ "${LINTER}" != "OFF" ]; then
   curl -qfsSL "https://api.gh.pkgforge.dev/repos/pkgforge/sbuilder/releases?per_page=100" | jq -r '.. | objects | .browser_download_url? // empty' | grep -Ei "$(uname -m)" | grep -Eiv "tar\.gz|\.b3sum" | grep -Ei "sbuild-linter" | sort --version-sort | tail -n 1 | tr -d '[:space:]' | xargs -I "{}" curl -qfsSL "{}" -o "${TMPDIR}/sbuild-linter"
   if [[ ! -s "${TMPDIR}/sbuild-linter" || $(stat -c%s "${TMPDIR}/sbuild-linter") -le 1024 ]]; then
     echo -e "\n[✗] FATAL: sbuild-linter could NOT BE Found\n"
    exit 1
   else
     chmod +x "${TMPDIR}/sbuild-linter"
      if ! command -v "sbuild-linter" >/dev/null 2>&1; then
       echo -e "\n[✗] FATAL: Failed to Add ${TMPDIR} to \$PATH\n"
      exit 1
      else
       echo -e "[+] Fetched sbuild-linter ..."
      fi
   fi
 fi
#Override PATH Temporarily
export PATH="${TMPDIR}:${PATH}"
if command -v awk >/dev/null 2>&1 && command -v sed >/dev/null 2>&1; then
 PATH="$(echo "${PATH}" | awk 'BEGIN{RS=":";ORS=":"}{gsub(/\n/,"");if(!a[$0]++)print}' | sed 's/:*$//')" ; export PATH
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
pushd "${TMPDIR}" >/dev/null 2>&1
##Github Fetcher
 if [ "${GH_FETCH}" == "YES" ]; then
   RELEASE_TAG="$(echo "${RELEASE_TAG}" | tr -d '[:space:]')"
   echo "[+] Running github-fetcher --> \"${SRC_URL}\""
   {
    github-fetcher "${SRC_URL}"
   } >/dev/null 2>&1
   if [[ -s "$(realpath './SBUILD.gh.yaml')" && $(stat -c%s "$(realpath './SBUILD.gh.yaml')") -gt 10 ]]; then
     mv -f "$(realpath './SBUILD.gh.yaml')" "${TMPDIR}/${PKG_NAME}.gh.yaml"
     GH_DESCR="$(yq e '.description' ${TMPDIR}/${PKG_NAME}.gh.yaml)"
     GH_HOMEPAGE="$(yq e '.homepage[]' ${TMPDIR}/${PKG_NAME}.gh.yaml)"
     HAS_GHFETCH="YES"
   else
     echo -e "\n[✗] FATAL: github-fetcher Failed\n"
     HAS_GHFETCH="NO"
   fi
 fi
##Repology Fetcher
 REPOLOGY="$(echo "${REPOLOGY}" | tr -d '[:space:]')"
 if [[ -n "${REPOLOGY}" ]]; then
   echo "[+] Running repology-fetcher --> \"${REPOLOGY}\""
   {
    repology-fetcher "${REPOLOGY}"
   } >/dev/null 2>&1
   if [[ -s "$(realpath './SBUILD.rl.yaml')" && $(stat -c%s "$(realpath './SBUILD.rl.yaml')") -gt 10 ]]; then
     mv -f "$(realpath './SBUILD.rl.yaml')" "${TMPDIR}/${PKG_NAME}.rl.yaml"
     readarray -t "RL_DESCR" < <(sed -n 's/^description: //p' "${TMPDIR}/${PKG_NAME}.rl.yaml")
     HAS_REPOLOGY="YES"
   else
     echo -e "\n[✗] FATAL: repology-fetcher Failed\n"
     HAS_REPOLOGY="NO"
   fi
 fi
##Create
if [ "${HAS_GHFETCH}" == "YES" ]; then
 #Touch
  touch "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
 #Shebang
  echo "[+] Appending SBUILD Shebang ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
  echo '#!/SBUILD ver @v1.0.0' > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
 #self
  if [[ "${BUILD_TYPE}" == "appimage" ]]; then
   echo "#SELF: https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/packages/${PKG_NAME}/appimage.official.stable.yaml" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  elif [[ "${BUILD_TYPE}" == "soar-dl" ]]; then
   echo "#SELF: https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/binaries/${PKG_NAME}/static.official.stable.yaml" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  elif [[ "${BUILD_TYPE}" =~ (cargo|go) ]]; then
   echo "#SELF: https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/binaries/${PKG_NAME}/static.official.source.yaml" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  elif [[ "${BUILD_TYPE}" == "guix" ]]; then
   echo "#SELF: https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/binaries/${PKG_NAME}/static.gnuguix.sable.yaml" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  elif [[ "${BUILD_TYPE}" == "nix" ]]; then
   echo "#SELF: https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/binaries/${PKG_NAME}/static.nixpkgs.sable.yaml" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #Disabled 
  echo "[+] Appending 'disabled: false' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
  echo -e "_disabled: false\n" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
 #pkg 
  echo "[+] Appending 'pkg: \"${PKG_NAME}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
  echo -e "pkg: \"${PKG_NAME}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
 #pkg_id 
  if [[ -n "${PKG_ID}" ]]; then
   echo "[+] Appending 'pkg_id: \"${PKG_ID}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "pkg_id: \"${PKG_ID}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #pkg_type (Default: appimage) 
  if [[ -n "${PKG_TYPE}" ]]; then
   echo "[+] Appending 'pkg_type: \"${PKG_TYPE}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "pkg_type: \"${PKG_TYPE}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  else
   echo "[+] Appending 'pkg_type: \"appimage\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "pkg_type: \"appimage\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #app_id
  if [[ -n "${APP_ID}" ]]; then
   echo "[+] Appending 'app_id: \"${APP_ID}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "app_id: \"${APP_ID}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #build_util
  if [ "${BUILD_UTIL}" != "0" ] && [ "${BUILD_UTIL}" != "OFF" ]; then
   echo "[+] Appending Common Build Utils (.build_util) ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e 'build_util:\n  - "curl#bin"\n  - "jq#bin"\n  - "squishy-cli#bin"' >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #Category
  if [[ -n "${CATEGORY}" ]]; then
   echo "[+] Appending (Provided) Categories (\${CATEGORY}) ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo "${CATEGORY}" | tr ',' '\n' | awk 'NF { printf "  - \"%s\"\n", $0 } BEGIN { print "category:" }' >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  else
   echo "[+] Appending (Default) Categories (\${CATEGORY}) ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e 'category:\n  - "ConsoleOnly"\n  - "Utility"' >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #Description
  if [[ -n "${DESCRIPTION}" ]]; then
   echo "[+] Appending 'description: \"${DESCRIPTION}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "description: \"${DESCRIPTION}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  elif [[ -n "${GH_DESCR}" ]]; then
   echo "[+] Appending 'description: \"${GH_DESCR}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "description: \"${GH_DESCR}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  elif [[ -n "${RL_DESCR}" ]]; then
   PS3="Please choose a description (1-${#RL_DESCR[@]}): "
   select CHOSEN in "${RL_DESCR[@]}"; do
       if [[ -n "${CHOSEN}" ]]; then
           echo "You selected: ${CHOSEN}"
           export DESCRIPTION="${CHOSEN}"
           break
       else
           echo "Invalid selection. Please try again."
       fi
   done
   if [[ -n "${DESCRIPTION}" ]]; then
     echo "[+] Appending 'description: \"${DESCRIPTION}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
     echo -e "description: \"${DESCRIPTION}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   else
     echo -e "[-] FAILED to Fetch A Valid Description (Setting it to Empty)"
     echo -e "description: \"${DESCRIPTION}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   fi
  fi
 #Distro PKG
  if [ "${HAS_REPOLOGY}" == "YES" ]; then
   echo "[+] Appending 'distro_pkg' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   yq eval-all 'select(fileIndex == 0) * {"distro_pkg": (select(fileIndex == 1).distro_pkg)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.rl.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #HomePage 
  if [[ -n "${GH_HOMEPAGE}" ]]; then
   echo "[+] Appending 'homepage' (Github) ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "homepage:\n  - \"${GH_HOMEPAGE}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   echo -e "  - \"${SRC_URL}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   if [ "${HAS_REPOLOGY}" == "YES" ]; then
    echo "[+] Appending 'homepage' (Repology) ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
    yq eval-all 'select(fileIndex == 0) + {"homepage": (select(fileIndex == 1).homepage)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.rl.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
    yq eval '.homepage |= unique | .homepage |= sort' -i "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   fi
  fi
 #License
  echo "[+] Appending 'license' (Github) ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
  echo -e "license:\n  - \"\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  yq eval-all 'select(fileIndex == 0) + {"license": (select(fileIndex == 1).license)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.gh.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  if [ "${HAS_REPOLOGY}" == "YES" ]; then
    echo "[+] Appending 'license' (Repology) ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
    yq eval-all 'select(fileIndex == 0) + {"license": (select(fileIndex == 1).license)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.rl.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
  yq eval '.license |= unique | .license |= sort' -i "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
 #Maintainer
  if [[ -n "${PKG_MAINTAINER}" ]]; then
   echo "[+] Appending 'maintainer: \"${PKG_MAINTAINER}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "maintainer:\n  - \"${PKG_MAINTAINER}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  else
   echo "[+] Appending 'maintainer: \"${USER}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "maintainer:\n  - \"${USER}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #Note
   echo "[+] Appending 'note' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "note:\n  - \"[DO NOT RUN] (Meant for pkgforge CI Only)\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   if [[ "${BUILD_TYPE}" == "appimage" ]]; then
    echo -e "  - \"Officially Created AppImage. Check/Report @ ${SRC_URL}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   elif [[ "${BUILD_TYPE}" == "soar-dl" ]]; then
    echo -e "  - \"Pre Built Binary Fetched from Upstream. Check/Report @ ${SRC_URL}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   elif [[ "${BUILD_TYPE}" =~ (cargo|go) ]]; then
    echo -e "  - \"Built From Source (Latest Git HEAD). Check/Report @ ${SRC_URL}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   elif [[ "${BUILD_TYPE}" == "guix" ]]; then
    echo -e "  - \"Built Using Guix. Check/Report @ https://issues.guix.gnu.org/search?query=${PKG_NAME}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   elif [[ "${BUILD_TYPE}" == "nix" ]]; then
    echo -e "  - \"Built Using Nix. Check/Report @ https://github.com/NixOS/nixpkgs\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
   fi
 #Repology
  if [ "${HAS_REPOLOGY}" == "YES" ]; then
   echo "[+] Appending 'repology: \"${REPOLOGY}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
   echo -e "repology:\n  - \"${REPOLOGY}\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
 #Src URl
  echo "[+] Appending 'src_url:' \"${SRC_URL}\"' ... [$(wc -l < ${TMPDIR}/${PKG_NAME}.SBUILD.yaml)]"
  echo -e "src_url:\n  - \"\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  yq eval-all 'select(fileIndex == 0) + {"src_url": (select(fileIndex == 1).src_url)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.gh.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  yq eval '.src_url |= unique | .src_url |= sort' -i "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
 #Tag
  echo "[+] Appending 'tag' (Github) ..."
  echo -e "tag:\n  - \"\"" >> "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  yq eval-all 'select(fileIndex == 0) + {"tag": (select(fileIndex == 1).tag)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.gh.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  if [ "${HAS_REPOLOGY}" == "YES" ]; then
    echo "[+] Appending 'tag' (Repology) ..."
    yq eval-all 'select(fileIndex == 0) + {"tag": (select(fileIndex == 1).tag)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.rl.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
  fi
  yq eval '.tag |= unique | .tag |= sort' -i "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
 #X_exec
  echo "[+] Appending 'x_exec' (Repology) ..."
  yq eval-all 'select(fileIndex == 0) + {"x_exec": (select(fileIndex == 1).x_exec)}' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "${TMPDIR}/${PKG_NAME}.gh.yaml" > "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" && [[ $(wc -l < "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp") -gt 4 ]] && mv "${TMPDIR}/${PKG_NAME}.SBUILD.yaml.tmp" "${TMPDIR}/${PKG_NAME}.SBUILD.yaml"
fi
popd >/dev/null 2>&1
#-------------------------------------------------------#

#-------------------------------------------------------#
##END
if ! yq eval . <(sed 's/[[:space:]]*$//' "${TMPDIR}/${PKG_NAME}.SBUILD.yaml") >/dev/null 2>&1; then
   echo -e "\n[✗] ERROR (Generation Failed) Incorrect SBUILD File, Please Check the Logs"
   echo -e "[+] Re Run: DEBUG="1" \"${SELF_NAME}\" {OPTIONS}"
   echo -e "[+] Build Docs: https://github.com/pkgforge/soarpkgs/blob/main/SBUILD.md"
   echo -e "[+] Spec Docs: https://github.com/pkgforge/soarpkgs/blob/main/SBUILD_SPEC.md"
   echo -e "[+] Inspect: \"${TMPDIR}\""
  if [ "${FORCE_CLEANUP}" = "1" ] || [ "${FORCE_CLEANUP}" = "ON" ]; then 
   rm -rf "${TMPDIR:?}"
  else
   read -t 10 -p "Remove ${TMPDIR}? [y/N] " r || r=y
   [[ ${r,,} =~ ^(n|no)$ ]] || rm -rf "${TMPDIR:?}"
  fi
 exit 1
else
   mv -f "${TMPDIR}/${PKG_NAME}.SBUILD.yaml" "$(realpath .)/${PKG_NAME}.SBUILD.yaml"
   echo -e "\n[✓] AutoGenerated SBUILD ==> $(realpath .)/${PKG_NAME}.SBUILD.yaml"
   if [ "${LINTER}" != "0" ] && [ "${LINTER}" != "OFF" ]; then 
     echo -e "[+] Linting $(realpath .)/${PKG_NAME}.SBUILD.yaml ...\n"
     sbuild-linter "$(realpath .)/${PKG_NAME}.SBUILD.yaml" --pkgver
     echo -e "\n" && yq eval . "$(realpath .)/${PKG_NAME}.SBUILD.yaml.validated" && echo -e "\n"
   else
     echo -e "\n" && yq eval . "$(realpath .)/${PKG_NAME}.SBUILD.yaml" && echo -e "\n"
   fi
  if [ "${FORCE_CLEANUP}" = "1" ] || [ "${FORCE_CLEANUP}" = "ON" ]; then 
   rm -rf "${TMPDIR:?}"
  else
   read -t 10 -p "Remove ${TMPDIR}? [y/N] " r || r=y
   [[ ${r,,} =~ ^(n|no)$ ]] || rm -rf "${TMPDIR:?}"
  fi
fi
##DEBUG
 if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
    set +x
 fi
#-------------------------------------------------------#