#!/usr/bin/env bash
## <DO NOT RUN STANDALONE, meant for CI Only>
## Self: https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_diff.sh
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/gen_diff.sh")
#-------------------------------------------------------#
##Generate Diff
#Bincache
if [ -d "${GITHUB_WORKSPACE}" ] && [ "$(find "${GITHUB_WORKSPACE}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
  curl -qfsSL "https://meta.pkgforge.dev/soarpkgs/INDEX.json" | jq '[.[] | select((.build_script | contains("https://github.com/pkgforge/soarpkgs/blob/main/binaries")) and (.bincache | not)) | {
    _disabled: (.["_disabled"] | test("false") | not),
    rebuild: false,
    pkg_family: .pkg_family,
    description: (if (.description | type) == "object" then .description._default else .description end),
    ghcr_pkg: ("ghcr.io/pkgforge/bincache/" + .pkg + "/" + (.build_script | split(".")[-3])), 
    build_script: .build_script
  }]' > "${GITHUB_WORKSPACE}/main/soarpkgs/data/DIFF_bincache.json"
  #Pkgcache
  curl -qfsSL "https://meta.pkgforge.dev/soarpkgs/INDEX.json" | jq '[.[] | select((.build_script | contains("https://github.com/pkgforge/soarpkgs/blob/main/packages")) and (.pkgcache | not)) | {
    _disabled: (.["_disabled"] | test("false") | not),
    rebuild: false,
    pkg_family: .pkg_family,
    description: .description,
    ghcr_pkg: ("ghcr.io/pkgforge/pkgcache/" + .pkg + "/" + .pkg_type + "/" + (.build_script | split(".")[-3]) + "/" + (.build_script | split(".")[-2])),
    build_script: .build_script
  }]' > "${GITHUB_WORKSPACE}/main/soarpkgs/data/DIFF_pkgcache.json"
fi
#-------------------------------------------------------#
