#!/usr/bin/env bash
# DO NOT USE (MEANT FOR @Azathothas ONLY)
# REQUIRES: awk + coreutils + curl + grep + jq + sed + yq
# source <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/github_fetcher.sh")
#set -x
#-------------------------------------------------------#

#-------------------------------------------------------#
##Main
github_fetcher()
{

#-------------------------------------------------------#
##Enable Debug 
 if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
    set -x
 fi
#-------------------------------------------------------#

#-------------------------------------------------------#
#ENV  
 local INPUT="${1:-$(cat)}"
 local REPO_NAME="$(echo ${INPUT} | sed -E 's|^(https://github.com/)?([^/]+/[^/]+).*|\2|' | tr -d '[:space:]')"
 SYSTMP="$(dirname $(mktemp -u))"
 TMP_JSON="${SYSTMP}/github.tmp.json"
 #if [[ -z "${USER_AGENT}" ]]; then
 #  USER_AGENT="$(curl -qfsSL 'https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Misc/User-Agents/ua_firefox_macos_latest.txt')"
 #fi
#Sanity
if [ -z "${REPO_NAME##*[[:space:]]}" ] || \
   [ -z "${PKG_NAME##*[[:space:]]}" ] || \
   [ -z "${BUILD_TYPE##*[[:space:]]}" ]; then
   echo -e "\n[X] FATAL: Required ENV Vars are NOT set"
   echo "REPO_NAME=${REPO_NAME}"
   echo "PKG_NAME=${PKG_NAME}"
   echo "BUILD_TYPE=${BUILD_TYPE}"
   echo -e "\n"
  return 1 || exit 1
fi
#-------------------------------------------------------#

#-------------------------------------------------------# 
##Fetch Metadata
 rm -rf "${TMP_JSON}" 2>/dev/null
 echo -e "\n[+] URL: https://github.com/${REPO_NAME} (${TMP_JSON})"
 curl -qfsSL "https://api.gh.pkgforge.dev/repos/${REPO_NAME}" -o "${TMP_JSON}" || curl -qfsSL "https://api.github.com/repos/${REPO_NAME}" -o "${TMP_JSON}"
#-------------------------------------------------------#


#-------------------------------------------------------#
##Common funcs
#appimage
x_exec_pkgver_appimage_tag()
{
if jq -r '.assets[].browser_download_url' "${TMP_JSON}" | grep -Eiv "\.zsync$" | grep -Eiq 'appimage'; then
  echo -e "[+] Using PreDefined Release Tag: ${RELEASE_TAG}"
  export HAS_RELEASE="YES" ; unset HAS_AARCH64
  if jq -r '.assets[].browser_download_url' "${TMP_JSON}" | grep -Eiq 'aarch64|arm64'; then
    HAS_AARCH64="YES"
  fi
 #x_exec.pkgver 
  echo -e "x_exec:\n  shell: "bash"\n  pkgver: |" >> "${SYSTMP}/github.tmp.yaml"
  echo "    curl -qfsSL \"https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases?per_page=100\" | jq -r '[.[] | select(.draft == false and .prerelease == true and (.name | test(\"(?i)${RELEASE_TAG}\")))] | .[0].tag_name | select(. != null)' | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
fi
}
export -f x_exec_pkgver_appimage_tag
x_exec_pkgver_appimage()
{
if jq -r '.assets[].browser_download_url' "${TMP_JSON}" | grep -Eiv "\.zsync$" | grep -Eiq 'appimage'; then
  echo -e "[+] Using Latest Stable-Release Tag: ${RELEASE_TAG}"
   export HAS_RELEASE="YES" ; unset HAS_AARCH64
   if jq -r '.assets[].browser_download_url' "${TMP_JSON}" | grep -Eiq 'aarch64|arm64'; then
     HAS_AARCH64="YES"
   fi
  #x_exec.pkgver 
   echo -e "x_exec:\n  host:\n    - \"aarch64-Linux\"\n    - \"x86_64-Linux\"\n  shell: \"bash\"\n  pkgver: |" >> "${SYSTMP}/github.tmp.yaml"
   if [[ "${RELEASE_TAG}" =~ ^[a-zA-Z]+$ ]]; then
     echo "    curl -qfsSL \"https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases/latest?per_page=100\" | jq -r '.. | objects | .browser_download_url? // empty' | sed -E 's/(x86_64|aarch64)//' | tr -d '[:alpha:]' | sed 's/^[^0-9]*//; s/[^0-9]*$//' | sort --version-sort | tail -n 1 | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
   else
     echo "    curl -qfsSL \"https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases?per_page=100\" | jq -r '[.[] | select(.draft == false and .prerelease == false)] | .[0].tag_name | gsub(\"\\\\s+\"; \"\")' | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
   fi
fi
}
export -f x_exec_pkgver_appimage
#x_exec.run
x_exec_run_appimage()
{
 echo -e "  run: |" >> "${SYSTMP}/github.tmp.yaml"
 #if [[ "${RELEASE_TAG}" =~ ^[a-zA-Z]+$ ]]; then
 if cat "${SYSTMP}/github.tmp.yaml" | grep -q -e "'s/(x86_64|aarch64)//'" -e "\.name | test(\"(?i\")"; then
  echo '    #Tag' >> "${SYSTMP}/github.tmp.yaml"
  echo '    RELEASE_TAG="$(cat ./${SBUILD_PKG}.version)"' >> "${SYSTMP}/github.tmp.yaml"
 fi
 echo '    #Download' >> "${SYSTMP}/github.tmp.yaml"
 echo '    case "$(uname -m)" in' >> "${SYSTMP}/github.tmp.yaml"
 if [ "${HAS_AARCH64}" == "YES" ]; then
  echo '      aarch64)' >> "${SYSTMP}/github.tmp.yaml"
  #if [[ "${RELEASE_TAG}" =~ ^[a-zA-Z]+$ ]]; then
  if cat "${SYSTMP}/github.tmp.yaml" | grep -q -e "'s/(x86_64|aarch64)//'" -e "\.name | test(\"(?i\")"; then
    echo "        soar dl \"https://github.com/${REPO_NAME}@\${RELEASE_TAG}\" --match \"appimage\" --exclude \"x86,x64,arm,zsync\" -o \"./\${SBUILD_PKG}\" --yes" >> "${SYSTMP}/github.tmp.yaml"
  else
    echo "        soar dl \"https://github.com/${REPO_NAME}\" --match \"appimage\" --exclude \"x86,x64,arm,zsync\" -o \"./\${SBUILD_PKG}\" --yes" >> "${SYSTMP}/github.tmp.yaml"
  fi
 else
  echo '      aarch64)' >> "${SYSTMP}/github.tmp.yaml"
  echo '        echo -e "\n[✗] aarch64 is Not Yet Supported\n"' >> "${SYSTMP}/github.tmp.yaml"
  echo '       exit 1' >> "${SYSTMP}/github.tmp.yaml"
 fi
 echo '        ;;' >> "${SYSTMP}/github.tmp.yaml"
 echo '      x86_64)' >> "${SYSTMP}/github.tmp.yaml"
  #if [[ "${RELEASE_TAG}" =~ ^[a-zA-Z]+$ ]]; then
  if cat "${SYSTMP}/github.tmp.yaml" | grep -q -e "'s/(x86_64|aarch64)//'" -e "\.name | test(\"(?i\")"; then
    echo "        soar dl \"https://github.com/${REPO_NAME}@\${RELEASE_TAG}\" --match \"appimage\" --exclude \"aarch64,arm,zsync\" -o \"./\${SBUILD_PKG}\" --yes" >> "${SYSTMP}/github.tmp.yaml"
  else
    echo "        soar dl \"https://github.com/${REPO_NAME}\" --match \"appimage\" --exclude \"aarch64,arm,zsync\" -o \"./\${SBUILD_PKG}\" --yes" >> "${SYSTMP}/github.tmp.yaml"
  fi
 echo '        ;;' >> "${SYSTMP}/github.tmp.yaml"
 echo '    esac' >> "${SYSTMP}/github.tmp.yaml"
 export HAS_RELEASE="YES" 
}
export -f x_exec_run_appimage
#-------------------------------------------------------#

#-------------------------------------------------------#
#cargo
x_exec_run_cargo()
{
#x_exec.run
 echo -e "  run: |" >> "${SYSTMP}/github.tmp.yaml"
 echo '    #Build' >> "${SYSTMP}/github.tmp.yaml"
 echo '     docker stop "alpine-builder" >/dev/null 2>&1 ; docker rm "alpine-builder" >/dev/null 2>&1' >> "${SYSTMP}/github.tmp.yaml"
 echo '     docker run --privileged --net="host" --name "alpine-builder" --pull="always" "ghcr.io/pkgforge/devscripts/alpine-builder:latest" \' >> "${SYSTMP}/github.tmp.yaml"
 echo "       bash -l -c '" >> "${SYSTMP}/github.tmp.yaml"
 echo '       #Setup ENV' >> "${SYSTMP}/github.tmp.yaml"
 echo '        set -x ; mkdir -p "/build-bins" && pushd "$(mktemp -d)" >/dev/null 2>&1' >> "${SYSTMP}/github.tmp.yaml"
 echo '        source "${HOME}/.cargo/env"' >> "${SYSTMP}/github.tmp.yaml"
 echo '        export RUST_TARGET="$(uname -m)-unknown-linux-musl"' >> "${SYSTMP}/github.tmp.yaml"
 echo '        rustup target add "${RUST_TARGET}"' >> "${SYSTMP}/github.tmp.yaml"
 echo '        export RUSTFLAGS="-C target-feature=+crt-static -C default-linker-libraries=yes -C link-self-contained=yes -C prefer-dynamic=no -C embed-bitcode=yes -C lto=yes -C opt-level=z -C debuginfo=none -C strip=symbols -C linker=clang -C link-arg=-fuse-ld=$(which mold) -C link-arg=-Wl,--Bstatic -C link-arg=-Wl,--static -C link-arg=-Wl,-S -C link-arg=-Wl,--build-id=none"' >> "${SYSTMP}/github.tmp.yaml"
 echo '       #Build' >> "${SYSTMP}/github.tmp.yaml"
 echo "        git clone --filter \"blob:none\" --quiet \"https://github.com/${REPO_NAME}\" \"./TEMPREPO\" && cd \"./TEMPREPO\"" >> "${SYSTMP}/github.tmp.yaml"
 echo '        echo -e "\n[+] Target: ${RUST_TARGET}"' >> "${SYSTMP}/github.tmp.yaml"
 echo '        echo -e "[+] Flags: ${RUSTFLAGS}\n"' >> "${SYSTMP}/github.tmp.yaml"
 echo '        sed "/^\[profile\.release\]/,/^$/d" -i "./Cargo.toml" ; echo -e "\n[profile.release]\nstrip = true\nopt-level = 3\nlto = true" >> "./Cargo.toml"' >> "${SYSTMP}/github.tmp.yaml"
 echo '        rm rust-toolchain* 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
 echo '        cargo build --target "${RUST_TARGET}" --release --jobs="$(($(nproc)+1))" --keep-going --verbose' >> "${SYSTMP}/github.tmp.yaml"
 echo '        find -L "./target/${RUST_TARGET}/release" -maxdepth 1 -type f 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
 echo '       #Copy' >> "${SYSTMP}/github.tmp.yaml"
 echo '        find "./target/${RUST_TARGET}/release" -maxdepth 1 -type f -exec file -i "{}" \; | grep "application/.*executable" | cut -d":" -f1 | xargs realpath | xargs -I "{}" rsync -achvL "{}" "/build-bins/"' >> "${SYSTMP}/github.tmp.yaml"
 echo '        ( askalono --format "json" crawl --follow "$(realpath .)" | jq -r ".. | objects | .path? // empty" | head -n 1 | xargs -I "{}" cp -fv "{}" "/build-bins/LICENSE" ) 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
 echo '       #Strip' >> "${SYSTMP}/github.tmp.yaml" 
 echo '        find "/build-bins/" -type f -exec objcopy --remove-section=".comment" --remove-section=".note.*" "{}" \; 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
 echo '        find "/build-bins/" -type f ! -name "*.no_strip" -exec strip --strip-debug --strip-dwo --strip-unneeded "{}" \; 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
 echo '        file "/build-bins/"* && du -sh "/build-bins/"*' >> "${SYSTMP}/github.tmp.yaml"
 echo '        popd >/dev/null 2>&1' >> "${SYSTMP}/github.tmp.yaml"
 echo "       '" >> "${SYSTMP}/github.tmp.yaml"
 echo '    #Copy & Meta' >> "${SYSTMP}/github.tmp.yaml"
 echo '     docker cp "alpine-builder:/build-bins/." "${SBUILD_TMPDIR}/"' >> "${SYSTMP}/github.tmp.yaml"
 echo '     [ -s "${SBUILD_TMPDIR}/LICENSE" ] && cp -fv "${SBUILD_TMPDIR}/LICENSE" "${SBUILD_OUTDIR}/LICENSE"' >> "${SYSTMP}/github.tmp.yaml"
 echo '     find "${SBUILD_TMPDIR}" -maxdepth 1 -type f -exec file -i "{}" \; | grep "application/.*executable" | cut -d":" -f1 | xargs realpath | xargs -I "{}" rsync -achvL "{}" "${SBUILD_OUTDIR}"' >> "${SYSTMP}/github.tmp.yaml"
 export HAS_RELEASE="YES"
}
export -f x_exec_run_cargo
#-------------------------------------------------------#

#-------------------------------------------------------#
#go
x_exec_run_go()
{
#x_exec.run 
  echo -e "  run: |" >> "${SYSTMP}/github.tmp.yaml"
  echo '    #Build' >> "${SYSTMP}/github.tmp.yaml"
  echo '     docker stop "alpine-builder" >/dev/null 2>&1 ; docker rm "alpine-builder" >/dev/null 2>&1' >> "${SYSTMP}/github.tmp.yaml"
  echo '     docker run --privileged --net="host" --name "alpine-builder" --pull="always" "ghcr.io/pkgforge/devscripts/alpine-builder:latest" \' >> "${SYSTMP}/github.tmp.yaml"
  echo "       bash -l -c '" >> "${SYSTMP}/github.tmp.yaml"
  echo '       #Setup ENV' >> "${SYSTMP}/github.tmp.yaml"
  echo '        set -x ; mkdir -p "/build-bins" && pushd "$(mktemp -d)" >/dev/null 2>&1' >> "${SYSTMP}/github.tmp.yaml"
  echo '        CGO_ENABLED="1"' >> "${SYSTMP}/github.tmp.yaml" 
  echo '        CGO_CFLAGS="-O2 -flto=auto -fPIE -fpie -static -w -pipe"' >> "${SYSTMP}/github.tmp.yaml"
  echo '        GOARCH="$(uname -m | sed "s/x86_64/amd64/;s/aarch64/arm64/")"' >> "${SYSTMP}/github.tmp.yaml"
  echo '        GOOS="linux"' >> "${SYSTMP}/github.tmp.yaml"
  echo '        export CGO_ENABLED CGO_CFLAGS GOARCH GOOS' >> "${SYSTMP}/github.tmp.yaml"
  echo '       #Build' >> "${SYSTMP}/github.tmp.yaml"
  echo "        git clone --filter \"blob:none\" --quiet \"https://github.com/${REPO_NAME}\" \"./TEMPREPO\" && cd \"./TEMPREPO\"" >> "${SYSTMP}/github.tmp.yaml"
  echo '        echo -e "\n[+] Target: \"${GOARCH}/${GOOS}\""' >> "${SYSTMP}/github.tmp.yaml"
  echo '        echo -e "[+] Flags: CGO_ENABLED=\"${CGO_ENABLED}\" CGO_CFLAGS=\"${CGO_CFLAGS}\"\n"' >> "${SYSTMP}/github.tmp.yaml"
  echo "        go build -x -v -trimpath -buildmode=\"pie\" -ldflags=\"-s -w -buildid= -linkmode=external -extldflags '\\''-s -w -static-pie -Wl,--build-id=none'\\''\" -o \"/build-bins/${PKG_NAME}\"" >> "${SYSTMP}/github.tmp.yaml"
  echo '       #Copy' >> "${SYSTMP}/github.tmp.yaml"
  echo '        ( askalono --format "json" crawl --follow "$(realpath .)" | jq -r ".. | objects | .path? // empty" | head -n 1 | xargs -I "{}" cp -fv "{}" "/build-bins/LICENSE" ) 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
  echo '       #Strip' >> "${SYSTMP}/github.tmp.yaml" 
  echo '        find "/build-bins/" -type f -exec objcopy --remove-section=".comment" --remove-section=".note.*" "{}" \; 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
  echo '        find "/build-bins/" -type f ! -name "*.no_strip" -exec strip --strip-debug --strip-dwo --strip-unneeded "{}" \; 2>/dev/null' >> "${SYSTMP}/github.tmp.yaml"
  echo '        file "/build-bins/"* && du -sh "/build-bins/"*' >> "${SYSTMP}/github.tmp.yaml"
  echo '        popd >/dev/null 2>&1' >> "${SYSTMP}/github.tmp.yaml"
  echo "       '" >> "${SYSTMP}/github.tmp.yaml"
  echo '    #Copy & Meta' >> "${SYSTMP}/github.tmp.yaml"
  echo '     docker cp "alpine-builder:/build-bins/." "${SBUILD_TMPDIR}/"' >> "${SYSTMP}/github.tmp.yaml"
  echo '     [ -s "${SBUILD_TMPDIR}/LICENSE" ] && cp -fv "${SBUILD_TMPDIR}/LICENSE" "${SBUILD_OUTDIR}/LICENSE"' >> "${SYSTMP}/github.tmp.yaml"
  echo '     find "${SBUILD_TMPDIR}" -maxdepth 1 -type f -exec file -i "{}" \; | grep "application/.*executable" | cut -d":" -f1 | xargs realpath | xargs -I "{}" rsync -achvL "{}" "${SBUILD_OUTDIR}"' >> "${SYSTMP}/github.tmp.yaml"
  export HAS_RELEASE="YES"
}
export -f x_exec_run_go
#-------------------------------------------------------#

#-------------------------------------------------------#
#guix
x_exec_pkgver_guix()
{
 #x_exec.pkgver 
  echo -e "x_exec:\n  host:\n    - \"aarch64-Linux\"\n    - \"x86_64-Linux\"\n  shell: \"bash\"\n  pkgver: |" >> "${SYSTMP}/github.tmp.yaml"
  echo -e "    guix package --show=\"${PKG_NAME}\" 2>/dev/null | grep -oP 'version:\s*\K[\S]+' | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
 export HAS_RELEASE="YES" 
}
export -f x_exec_pkgver_guix
x_exec_run_guix()
{
 #x_exec.run 
  echo "todo"
 export HAS_RELEASE="YES" 
}
export -f x_exec_run_guix
#-------------------------------------------------------#

#-------------------------------------------------------#
#nix
x_exec_pkgver_nix()
{
#x_exec.pkgver 
 echo -e "x_exec:\n  host:\n    - \"aarch64-Linux\"\n    - \"x86_64-Linux\"\n  shell: \"bash\"\n  pkgver: |" >> "${SYSTMP}/github.tmp.yaml"
 echo -e "    nix derivation show \"nixpkgs#${PKG_NAME}\" --impure --refresh --quiet 1>&1 2>/dev/null | sed -n '/^[[:space:]]*{/,$p' | jq -r '.. | objects | (select(has(\"version\")).version, (select(has(\"env\")) | select(.env.__json != null) | .env.__json | fromjson | select(has(\"version\")).version) | select(.))' | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
 export HAS_RELEASE="YES"
}
export -f x_exec_pkgver_nix
x_exec_run_nix()
{
 #x_exec.run 
  echo "todo"
 export HAS_RELEASE="YES" 
}
export -f x_exec_run_nix
#-------------------------------------------------------#

#-------------------------------------------------------#
#src (version only)
x_exec_pkgver_github_src()
{
 #x_exec.pkgver  
  echo -e "x_exec:\n  host:\n    - \"aarch64-Linux\"\n    - \"x86_64-Linux\"\n  shell: \"bash\"\n  pkgver: |" >> "${SYSTMP}/github.tmp.yaml"
  echo -e "    pushd \"\$(mktemp -d)\" >/dev/null 2>&1 && \\" >> "${SYSTMP}/github.tmp.yaml"
  echo -e "    git clone --depth=\"1\" --filter=\"blob:none\" --no-checkout --single-branch --quiet \"https://github.com/${REPO_NAME}\" \"./TEMPREPO\" >/dev/null 2>&1 && \\" >> "${SYSTMP}/github.tmp.yaml"
  echo -e "    git --git-dir=\"./TEMPREPO/.git\" --no-pager log -1 --pretty=format:'HEAD-%h-%cd' --date=format:'%y%m%dT%H%M%S' && \\" >> "${SYSTMP}/github.tmp.yaml"
  echo -e "    [ -d \"\$(realpath .)/TEMPREPO\" ] && rm -rf \"\$(realpath .)\" >/dev/null 2>&1 && popd >/dev/null 2>&1" >> "${SYSTMP}/github.tmp.yaml"
  export HAS_RELEASE="YES"
}
export -f x_exec_pkgver_github_src
#-------------------------------------------------------#

#-------------------------------------------------------#
##soar dl
x_exec_pkgver_soar-dl()
{
 #x_exec.pkgver 
  echo -e "x_exec:\n  host:\n    - \"aarch64-Linux\"\n    - \"x86_64-Linux\"\n  shell: \"bash\"\n  pkgver: |" >> "${SYSTMP}/github.tmp.yaml"
  echo "    curl -qfsSL \"https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases?per_page=100\" | jq -r '[.[] | select(.draft == false and .prerelease == false)] | .[0].tag_name | gsub(\"\\\\s+\"; \"\")' | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
  export HAS_RELEASE="YES"
}
export -f x_exec_pkgver_soar-dl
x_exec_run_soar-dl()
{
#x_exec.run 
 echo -e "  run: |" >> "${SYSTMP}/github.tmp.yaml"
 echo '    #Tag' >> "${SYSTMP}/github.tmp.yaml"
 echo '    RELEASE_TAG="$(cat ./${SBUILD_PKG}.version)"' >> "${SYSTMP}/github.tmp.yaml"
 echo '    #Download' >> "${SYSTMP}/github.tmp.yaml"
 echo '    case "$(uname -m)" in' >> "${SYSTMP}/github.tmp.yaml"
 echo '      aarch64)' >> "${SYSTMP}/github.tmp.yaml"
 echo "        soar dl \"https://github.com/${REPO_NAME}@\${RELEASE_TAG}\" --match \"linux,musl,aarch64,tar\" --exclude \"amd,x86,x64\" -o \"\${SBUILD_TMPDIR}/\${SBUILD_PKG}.archive\" --yes" >> "${SYSTMP}/github.tmp.yaml"
 echo '        ;;' >> "${SYSTMP}/github.tmp.yaml"
 echo '      x86_64)' >> "${SYSTMP}/github.tmp.yaml"
 echo "        soar dl \"https://github.com/${REPO_NAME}@\${RELEASE_TAG}\" --match \"linux,musl,x86_64,tar\" --exclude \"aarch,arm\" -o \"\${SBUILD_TMPDIR}/\${SBUILD_PKG}.archive\" --yes" >> "${SYSTMP}/github.tmp.yaml"
 echo '        ;;' >> "${SYSTMP}/github.tmp.yaml"
 echo '    esac' >> "${SYSTMP}/github.tmp.yaml"
 echo '    #Extract' >> "${SYSTMP}/github.tmp.yaml"
 echo '    while ARCHIVE_EXT="$(find "${SBUILD_TMPDIR}" -type f -print0 | xargs -0 file | grep -E "archive|compressed" | cut -d: -f1 | head -n1)"; [ -n "${ARCHIVE_EXT}" ]; do 7z e "${ARCHIVE_EXT}" -o"${SBUILD_TMPDIR}/." -y && rm "${ARCHIVE_EXT}"; done' >> "${SYSTMP}/github.tmp.yaml"
 echo '    #Copy' >> "${SYSTMP}/github.tmp.yaml"
 echo '    find "${SBUILD_TMPDIR}" -maxdepth 1 -type f -exec file -i "{}" \; | grep "application/.*executable" | cut -d":" -f1 | xargs realpath | xargs -I "{}" rsync -achvL "{}" "${SBUILD_OUTDIR}"' >> "${SYSTMP}/github.tmp.yaml"
 export HAS_RELEASE="YES"
}
export -f x_exec_run_soar-dl
#-------------------------------------------------------#


#-------------------------------------------------------#
##Generate 
if [[ -s "${TMP_JSON}" ]] && [[ $(stat -c%s "${TMP_JSON}") -gt 100 ]]; then
  rm -rf "${SYSTMP}/github.tmp.yaml" 2>/dev/null
  #Description
  {
   jq -r '.description // ""' "${TMP_JSON}" | sed 's/`//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed ':a;N;$!ba;s/\r\n//g; s/\n//g' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g' | awk '{print "description: \"" $0 "\""}' | awk '{ print length(), $0 }' | sort -n | awk '{sub(/^[0-9]+ /,""); print}'
  } 2>/dev/null > "${SYSTMP}/github.tmp.yaml"
  #HomePage
  {
   echo "https://github.com/${REPO_NAME}" | awk 'BEGIN {print "homepage:"} {print "  - \"" $1 "\""}' | yq 'del(.. | select(tag == "!!seq" and length == 0))' -P -oyaml | sed 's/- \(.*\)/- "\1"/'
  } 2>/dev/null >> "${SYSTMP}/github.tmp.yaml"
  #license
  {
   jq -r '.license.name // ""' "${TMP_JSON}" | sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/["'\'']//g' | sed 's/|//g' | sed 's/`//g' | sed -e 's/["'\''`|]//g' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/(.*)//g' | sort -u | awk '{print "  - \"" $0 "\""}' | awk 'BEGIN {print "license:"} {print}'
  } 2>/dev/null >> "${SYSTMP}/github.tmp.yaml"
  #Src_url
   echo -e "src_url:\n" >> "${SYSTMP}/github.tmp.yaml"
   echo "  - \"https://github.com/${REPO_NAME}\"" >> "${SYSTMP}/github.tmp.yaml"
  #tag
  {
   jq -r '.topics[]' "${TMP_JSON}" | sed 's/, /, /g' | sed 's/,/, /g' | sed 's/|//g' | sed 's/"//g' | sed -e 's/["'\''`|]//g' -e 's/^[ \t]*//;s/[ \t]*$//' | sort -u | grep -viE 'hackathon|hacktober' | awk 'BEGIN {print "tag:"} {print "  - \"" $1 "\""}'
  } 2>/dev/null >> "${SYSTMP}/github.tmp.yaml"
 #Fetch Release
  if [ -n "${RELEASE_TAG}" ]; then
    #Fixed Release
     curl -qfsSL "https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases/tags/${RELEASE_TAG}" -o "${TMP_JSON}" || curl -qfsSL "https://api.github.com/repos/${REPO_NAME}/releases/tags/${RELEASE_TAG}" -o "${TMP_JSON}"
     if [[ -s "${TMP_JSON}" ]] && [[ $(stat -c%s "${TMP_JSON}") -gt 100 ]]; then
      if [[ "${BUILD_TYPE}" == "appimage" ]]; then
       x_exec_pkgver_appimage_tag
      elif [[ "${BUILD_TYPE}" == "soar-dl" ]]; then
       x_exec_pkgver_soar-dl
      elif [[ "${BUILD_TYPE}" =~ (cargo|go) ]]; then
        x_exec_pkgver_github_src 
      elif [[ "${BUILD_TYPE}" == "guix" ]]; then
        x_exec_pkgver_guix
      elif [[ "${BUILD_TYPE}" == "nix" ]]; then
        x_exec_pkgver_nix
      fi
     fi
  else
    #Latest Release
     RELEASE_TAG="$(curl -qfsSL "https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases?per_page=100" | jq -r '[.[] | select(.draft == false and .prerelease == false)] | .[0].tag_name | gsub("\\s+"; "")' | tr -d '[:space:]')" ; unset HAS_RELEASE
     if [ -n "${RELEASE_TAG}" ]; then
       curl -qfsSL "https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases/tags/${RELEASE_TAG}" -o "${TMP_JSON}" || curl -qfsSL "https://api.github.com/repos/${REPO_NAME}/releases/tags/${RELEASE_TAG}" -o "${TMP_JSON}"
       if [[ -s "${TMP_JSON}" ]] && [[ $(stat -c%s "${TMP_JSON}") -gt 100 ]]; then
        if [[ "${BUILD_TYPE}" == "appimage" ]]; then
         x_exec_pkgver_appimage
       elif [[ "${BUILD_TYPE}" == "soar-dl" ]]; then
         x_exec_pkgver_soar-dl
       elif [[ "${BUILD_TYPE}" =~ (cargo|go) ]]; then
         x_exec_pkgver_github_src 
       elif [[ "${BUILD_TYPE}" == "guix" ]]; then
         x_exec_pkgver_guix
       elif [[ "${BUILD_TYPE}" == "nix" ]]; then
         x_exec_pkgver_nix
       fi
     fi
    #Latest Pre-Release
     if [ "${HAS_RELEASE}" != "YES" ]; then
       RELEASE_TAG="$(curl -qfsSL "https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases?per_page=100" | jq -r '[.[] | select(.draft == false and .prerelease == true)] | .[0].tag_name | gsub("\\s+"; "")' | tr -d '[:space:]')" ; unset HAS_RELEASE
       if [ -n "${RELEASE_TAG}" ]; then
         curl -qfsSL "https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases/tags/${RELEASE_TAG}" -o "${TMP_JSON}" || curl -qfsSL "https://api.github.com/repos/${REPO_NAME}/releases/tags/${RELEASE_TAG}" -o "${TMP_JSON}" 
         if [[ -s "${TMP_JSON}" ]] && [[ $(stat -c%s "${TMP_JSON}") -gt 100 ]]; then
           if jq -r '.assets[].browser_download_url' "${TMP_JSON}" | grep -Eiv "\.zsync$" | grep -Eiq 'appimage'; then
             echo -e "[+] Using PreDefined Pre-Release Tag: ${RELEASE_TAG}"
             HAS_RELEASE="YES" ; export HAS_RELEASE
             if jq -r '.assets[].browser_download_url' "${TMP_JSON}" | grep -Eiq 'aarch64|arm64'; then
               HAS_AARCH64="YES"
             fi
             echo -e "x_exec:\n  shell: "bash"\n  pkgver: |" >> "${SYSTMP}/github.tmp.yaml"
             if [[ "${RELEASE_TAG}" =~ ^[a-zA-Z]+$ ]]; then
               echo "    curl -qfsSL \"https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases/latest?per_page=100\" | jq -r '.. | objects | .browser_download_url? // empty' | sed -E 's/(x86_64|aarch64)//' | tr -d '[:alpha:]' | sed 's/^[^0-9]*//; s/[^0-9]*$//' | sort --version-sort | tail -n 1 | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
             else
               echo "    curl -qfsSL \"https://api.gh.pkgforge.dev/repos/${REPO_NAME}/releases?per_page=100\" | jq -r '[.[] | select(.draft == false and .prerelease == true)] | .[0].tag_name | gsub(\"\\\\s+\"; \"\")' | tr -d '[:space:]'" >> "${SYSTMP}/github.tmp.yaml"
             fi
           fi
         fi
       fi
     fi
   fi
   #Append x_exec.run
   if [ "${HAS_RELEASE}" == "YES" ]; then
     if [[ "${BUILD_TYPE}" == "appimage" ]]; then
       x_exec_run_appimage
     elif [[ "${BUILD_TYPE}" == "soar-dl" ]]; then
       x_exec_run_soar-dl
     elif [[ "${BUILD_TYPE}" == "cargo" ]]; then
       x_exec_run_cargo
     elif [[ "${BUILD_TYPE}" == "go" ]]; then
       x_exec_run_go
     elif [[ "${BUILD_TYPE}" == "guix" ]]; then
       x_exec_run_guix 
     elif [[ "${BUILD_TYPE}" == "nix" ]]; then
       x_exec_run_nix
     fi
    #Print ReleaseUrl
     echo -e "\n[+] REPO: https://github.com/${REPO_NAME}"
     echo -e "[+] TAG: ${RELEASE_TAG}"
     sed 's/[[:space:]]*$//' "${SYSTMP}/github.tmp.yaml" | yq 'del(.. | select(. == "" or . == []))' | yq eval 'del(.[] | select(. == null or . == ""))' | yq . > "$(realpath .)/SBUILD.gh.yaml"
     if [[ -s "$(realpath .)/SBUILD.gh.yaml" ]] && [[ $(stat -c%s "$(realpath .)/SBUILD.gh.yaml") -gt 100 ]]; then
       cat "$(realpath .)/SBUILD.gh.yaml" | yj -yj | jq . > "$(realpath .)/SBUILD.gh.json"
     fi
     #cat "$(realpath './SBUILD.gh.yaml')" && echo -e "\n"
     echo -e "\n" && yq . "$(realpath './SBUILD.gh.yaml')" && echo -e "\n"
     echo -e "[+] SBUILD (TEMP): $(realpath './SBUILD.gh.yaml')\n"     
   else
      echo "[-] FATAL: Couldn't Determine Release Tags"
   fi
  fi
 fi
#-------------------------------------------------------#

#-------------------------------------------------------# 
##Disable Debug 
 if [ "${DEBUG}" = "1" ] || [ "${DEBUG}" = "ON" ]; then
    set +x
 fi
#-------------------------------------------------------# 
}
export -f github_fetcher
alias github-fetcher="github_fetcher"
#Call func directly if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
   github_fetcher "$@" <&0
fi
#-------------------------------------------------------#