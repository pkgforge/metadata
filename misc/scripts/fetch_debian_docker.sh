#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_debian_docker.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_debian_docker.sh")

#-------------------------------------------------------#
##Generate
if [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
   pushd "$(mktemp -d)" >/dev/null 2>&1
    chmod +xwr "${GITHUB_WORKSPACE}/main/misc/scripts/fetch_debian_src.sh"
    docker run --privileged --name "debian" -v "${GITHUB_WORKSPACE}:/workspace" "debian:latest" bash -l -c '"/workspace/main/misc/scripts/fetch_debian_src.sh"'
    docker cp "debian:/tmp/DEBIAN.json" "$(realpath . | tr -d '[:space:]')/DEBIAN.json"
    cp -fv "./DEBIAN.json" "${SYSTMP}/DEBIAN.json"
    if [[ -s "${SYSTMP}/DEBIAN.json" ]] && [[ $(stat -c%s "${SYSTMP}/DEBIAN.json") -gt 1000 ]]; then
     cp -fv "${SYSTMP}/DEBIAN.json" "${GITHUB_WORKSPACE}/main/misc/data/DEBIAN.json"
     #rclone copyto "${GITHUB_WORKSPACE}/main/misc/data/DEBIAN.json" "r2:/meta/misc/DEBIAN.json" --checksum --check-first --user-agent="${USER_AGENT}"
    fi
   popd >/dev/null 2>&1
fi
#-------------------------------------------------------#