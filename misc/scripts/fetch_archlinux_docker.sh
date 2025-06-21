#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_archlinux_docker.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/misc/scripts/fetch_archlinux_docker.sh")

#-------------------------------------------------------#
##Generate
if [ -d "${GITHUB_WORKSPACE}" ] &&\
 [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
   pushd "$(mktemp -d)" >/dev/null 2>&1
    chmod +xwr "${GITHUB_WORKSPACE}/main/misc/scripts/fetch_archlinux_src.sh"
    docker run --privileged --name "archlinux" -v "${GITHUB_WORKSPACE}:/workspace" "ghcr.io/pkgforge/devscripts/archlinux-builder:$(uname -m)" bash -l -c '"/workspace/main/misc/scripts/fetch_archlinux_src.sh"'
    docker cp "archlinux:/tmp/ARCHLINUX.json" "$(realpath . | tr -d '[:space:]')/ARCHLINUX.json"
    cp -fv "./ARCHLINUX.json" "${SYSTMP}/ARCHLINUX.json"
    if [[ -s "${SYSTMP}/ARCHLINUX.json" ]] && [[ $(stat -c%s "${SYSTMP}/ARCHLINUX.json") -gt 1000 ]]; then
    #chdir to Repo
     cd "${GITHUB_WORKSPACE}/main"
    #Git pull
     git pull origin main --no-edit 2>/dev/null
     git pull origin main --ff-only ; git merge --no-ff -m "Merge & Sync"
    #Copy
     cp -fv "${SYSTMP}/ARCHLINUX.json" "${GITHUB_WORKSPACE}/main/misc/data/ARCHLINUX.json"
     #rclone copyto "${GITHUB_WORKSPACE}/main/misc/data/ARCHLINUX.json" "r2:/meta/misc/ARCHLINUX.json" --checksum --check-first --user-agent="${USER_AGENT}"
    fi
   popd >/dev/null 2>&1
fi
#-------------------------------------------------------#