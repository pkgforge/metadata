```mathematica
 422M └─┬ main
 175M   ├─┬ misc
 175M   │ ├─┬ data
  71M   │ │ ├── ARCHLINUX.json
  37M   │ │ ├── FLATPAK_APPSTREAM.xml
  23M   │ │ ├── DEBIAN.json
  10M   │ │ ├── ALPINE_PKG.json
  10M   │ │ ├── NIXPKGS.json
 9.0M   │ │ ├── PKGSRC.json
 5.1M   │ │ ├── ALPINE_GIT.json
 2.8M   │ │ ├── BREW_FORMULA.json
 1.6M   │ │ ├── BREW_CASK.json
 1.1M   │ │ ├── PPKG_RAW.json
 460K   │ │ ├── FLATPAK_APPS_INFO.json
 428K   │ │ ├── FLATPAK_APPS_INFO.txt
 312K   │ │ ├── PPKG.json
 236K   │ │ ├── FLATPAK_POPULAR.json
 224K   │ │ ├── FLATPAK_TRENDING.json
  76K   │ │ ├── FLATPAK_APP_IDS.txt
  20K   │ │ ├── CATEGORY.json
 4.0K   │ │ └── CATEGORY.md
  84K   │ └─┬ scripts
  12K   │   ├── fetch_flatpak.sh
  12K   │   ├── fetch_alpine_pkg.sh
 8.0K   │   ├── fetch_homebrew.sh
 8.0K   │   ├── fetch_gh_logs.sh
 8.0K   │   ├── fetch_debian_src.sh
 8.0K   │   ├── fetch_archlinux_src.sh
 4.0K   │   ├── fetch_ppkg.sh
 4.0K   │   ├── fetch_pkgsrc.sh
 4.0K   │   ├── fetch_nixpkgs.sh
 4.0K   │   ├── fetch_debian_docker.sh
 4.0K   │   ├── fetch_archlinux_docker.sh
 4.0K   │   └── fetch_alpine_git.sh
 139M   ├─┬ bincache
 139M   │ ├─┬ data
  25M   │ │ ├── x86_64-Linux.json
  25M   │ │ ├── aarch64-Linux.json
  19M   │ │ ├── x86_64-Linux.db
  18M   │ │ ├── aarch64-Linux.db
  13M   │ │ ├── x86_64-Linux.sdb
  13M   │ │ ├── aarch64-Linux.sdb
 4.1M   │ │ ├── x86_64-Linux.json.cba
 4.0M   │ │ ├── aarch64-Linux.json.cba
 1.4M   │ │ ├── x86_64-Linux.db.cba
 1.3M   │ │ ├── x86_64-Linux.sdb.cba
 1.3M   │ │ ├── aarch64-Linux.db.cba
 1.3M   │ │ ├── aarch64-Linux.sdb.cba
 948K   │ │ ├── x86_64-Linux.sdb.zstd
 912K   │ │ ├── aarch64-Linux.sdb.zstd
 900K   │ │ ├── x86_64-Linux.db.zstd
 880K   │ │ ├── x86_64-Linux.db.xz
 868K   │ │ ├── x86_64-Linux.sdb.xz
 864K   │ │ ├── aarch64-Linux.db.zstd
 844K   │ │ ├── aarch64-Linux.db.xz
 836K   │ │ ├── aarch64-Linux.sdb.xz
 832K   │ │ ├── x86_64-Linux.json.zstd
 800K   │ │ ├── x86_64-Linux.json.xz
 796K   │ │ ├── aarch64-Linux.json.zstd
 768K   │ │ ├── aarch64-Linux.json.xz
 4.0K   │ │ ├── x86_64-Linux.sdb.zstd.bsum
 4.0K   │ │ ├── x86_64-Linux.sdb.xz.bsum
 4.0K   │ │ ├── x86_64-Linux.sdb.bsum
 4.0K   │ │ ├── x86_64-Linux.json.zstd.bsum
 4.0K   │ │ ├── x86_64-Linux.json.xz.bsum
 4.0K   │ │ ├── x86_64-Linux.json.bsum
 4.0K   │ │ ├── x86_64-Linux.db.zstd.bsum
 4.0K   │ │ ├── x86_64-Linux.db.xz.bsum
 4.0K   │ │ ├── x86_64-Linux.db.bsum
 4.0K   │ │ ├── minisign.pub
 4.0K   │ │ ├── aarch64-Linux.sdb.zstd.bsum
 4.0K   │ │ ├── aarch64-Linux.sdb.xz.bsum
 4.0K   │ │ ├── aarch64-Linux.sdb.bsum
 4.0K   │ │ ├── aarch64-Linux.json.zstd.bsum
 4.0K   │ │ ├── aarch64-Linux.json.xz.bsum
 4.0K   │ │ ├── aarch64-Linux.json.bsum
 4.0K   │ │ ├── aarch64-Linux.db.zstd.bsum
 4.0K   │ │ ├── aarch64-Linux.db.xz.bsum
 4.0K   │ │ ├── aarch64-Linux.db.bsum
 4.0K   │ │ └── TOTAL.json
  80K   │ └─┬ scripts
  32K   │   ├── gen_meta_x86_64-Linux.sh
  32K   │   ├── gen_meta_aarch64-Linux.sh
  12K   │   └── sync_hf_mirror.sh
  50M   ├── GHCR_PKGS.json
  33M   ├─┬ external
  11M   │ ├─┬ am
  11M   │ │ ├─┬ data
 3.9M   │ │ │ ├── x86_64-Linux.json
 3.1M   │ │ │ ├── x86_64-Linux.db
 1.1M   │ │ │ ├── x86_64-Linux.AM.txt
 1.0M   │ │ │ ├── aarch64-Linux.AM.txt
 508K   │ │ │ ├── x86_64-Linux.db.cba
 480K   │ │ │ ├── x86_64-Linux.json.cba
 420K   │ │ │ ├── x86_64-Linux.db.zstd
 412K   │ │ │ ├── x86_64-Linux.db.xz
 388K   │ │ │ ├── x86_64-Linux.json.zstd
 380K   │ │ │ ├── x86_64-Linux.json.xz
 4.0K   │ │ │ ├── x86_64-Linux.json.zstd.bsum
 4.0K   │ │ │ ├── x86_64-Linux.json.xz.bsum
 4.0K   │ │ │ ├── x86_64-Linux.json.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.zstd.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.xz.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.bsum
 4.0K   │ │ │ └── TOTAL.json
  40K   │ │ └─┬ scripts
  16K   │ │   ├── gen_meta.sh
  12K   │ │   ├── gen_meta_old.sh
 8.0K   │ │   └── gen_meta_tmp.sh
  11M   │ ├─┬ cargo-bins
  11M   │ │ ├─┬ data
 3.7M   │ │ │ ├── x86_64-Linux.json
 2.7M   │ │ │ ├── x86_64-Linux.db
 1.5M   │ │ │ ├── aarch64-Linux.json
 1.1M   │ │ │ ├── aarch64-Linux.db
 320K   │ │ │ ├── x86_64-Linux.db.cba
 304K   │ │ │ ├── x86_64-Linux.json.cba
 260K   │ │ │ ├── x86_64-Linux.db.zstd
 248K   │ │ │ ├── x86_64-Linux.db.xz
 232K   │ │ │ ├── x86_64-Linux.json.zstd
 220K   │ │ │ ├── x86_64-Linux.json.xz
 136K   │ │ │ ├── aarch64-Linux.db.cba
 132K   │ │ │ ├── aarch64-Linux.json.cba
 112K   │ │ │ ├── aarch64-Linux.db.zstd
 108K   │ │ │ ├── aarch64-Linux.db.xz
 100K   │ │ │ ├── aarch64-Linux.json.zstd
  96K   │ │ │ ├── aarch64-Linux.json.xz
 4.0K   │ │ │ ├── x86_64-Linux.json.zstd.bsum
 4.0K   │ │ │ ├── x86_64-Linux.json.xz.bsum
 4.0K   │ │ │ ├── x86_64-Linux.json.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.zstd.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.xz.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.bsum
 4.0K   │ │ │ ├── aarch64-Linux.json.zstd.bsum
 4.0K   │ │ │ ├── aarch64-Linux.json.xz.bsum
 4.0K   │ │ │ ├── aarch64-Linux.json.bsum
 4.0K   │ │ │ ├── aarch64-Linux.db.zstd.bsum
 4.0K   │ │ │ ├── aarch64-Linux.db.xz.bsum
 4.0K   │ │ │ ├── aarch64-Linux.db.bsum
 4.0K   │ │ │ └── TOTAL.json
  28K   │ │ └─┬ scripts
  24K   │ │   └── gen_meta.sh
 5.5M   │ ├─┬ appimagehub
 5.5M   │ │ ├─┬ data
 2.0M   │ │ │ ├── x86_64-Linux.json
 1.8M   │ │ │ ├── x86_64-Linux.db
 280K   │ │ │ ├── x86_64-Linux.json.cba
 268K   │ │ │ ├── x86_64-Linux.db.cba
 224K   │ │ │ ├── x86_64-Linux.db.zstd
 216K   │ │ │ ├── x86_64-Linux.json.zstd
 216K   │ │ │ ├── x86_64-Linux.db.xz
 208K   │ │ │ ├── x86_64-Linux.json.xz
  84K   │ │ │ ├── aarch64-Linux.json
  84K   │ │ │ ├── aarch64-Linux.db
  12K   │ │ │ ├── aarch64-Linux.json.zstd
  12K   │ │ │ ├── aarch64-Linux.json.xz
  12K   │ │ │ ├── aarch64-Linux.json.cba
  12K   │ │ │ ├── aarch64-Linux.db.zstd
  12K   │ │ │ ├── aarch64-Linux.db.xz
  12K   │ │ │ ├── aarch64-Linux.db.cba
 4.0K   │ │ │ ├── x86_64-Linux.json.zstd.bsum
 4.0K   │ │ │ ├── x86_64-Linux.json.xz.bsum
 4.0K   │ │ │ ├── x86_64-Linux.json.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.zstd.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.xz.bsum
 4.0K   │ │ │ ├── x86_64-Linux.db.bsum
 4.0K   │ │ │ ├── aarch64-Linux.json.zstd.bsum
 4.0K   │ │ │ ├── aarch64-Linux.json.xz.bsum
 4.0K   │ │ │ ├── aarch64-Linux.json.bsum
 4.0K   │ │ │ ├── aarch64-Linux.db.zstd.bsum
 4.0K   │ │ │ ├── aarch64-Linux.db.xz.bsum
 4.0K   │ │ │ ├── aarch64-Linux.db.bsum
 4.0K   │ │ │ └── TOTAL.json
  32K   │ │ └─┬ scripts
  28K   │ │   └── gen_meta.sh
 4.6M   │ └─┬ appimage.github.io
 4.6M   │   ├─┬ data
 1.7M   │   │ ├── x86_64-Linux.json
 1.4M   │   │ ├── x86_64-Linux.db
 216K   │   │ ├── x86_64-Linux.db.cba
 192K   │   │ ├── x86_64-Linux.json.cba
 176K   │   │ ├── aarch64-Linux.json
 168K   │   │ ├── x86_64-Linux.db.zstd
 164K   │   │ ├── x86_64-Linux.db.xz
 156K   │   │ ├── aarch64-Linux.db
 148K   │   │ ├── x86_64-Linux.json.zstd
 144K   │   │ ├── x86_64-Linux.json.xz
  24K   │   │ ├── aarch64-Linux.json.cba
  24K   │   │ ├── aarch64-Linux.db.zstd
  24K   │   │ ├── aarch64-Linux.db.xz
  24K   │   │ ├── aarch64-Linux.db.cba
  20K   │   │ ├── aarch64-Linux.json.zstd
  20K   │   │ ├── aarch64-Linux.json.xz
 4.0K   │   │ ├── x86_64-Linux.json.zstd.bsum
 4.0K   │   │ ├── x86_64-Linux.json.xz.bsum
 4.0K   │   │ ├── x86_64-Linux.json.bsum
 4.0K   │   │ ├── x86_64-Linux.db.zstd.bsum
 4.0K   │   │ ├── x86_64-Linux.db.xz.bsum
 4.0K   │   │ ├── x86_64-Linux.db.bsum
 4.0K   │   │ ├── aarch64-Linux.json.zstd.bsum
 4.0K   │   │ ├── aarch64-Linux.json.xz.bsum
 4.0K   │   │ ├── aarch64-Linux.json.bsum
 4.0K   │   │ ├── aarch64-Linux.db.zstd.bsum
 4.0K   │   │ ├── aarch64-Linux.db.xz.bsum
 4.0K   │   │ ├── aarch64-Linux.db.bsum
 4.0K   │   │ └── TOTAL.json
  32K   │   └─┬ scripts
  28K   │     └── gen_meta.sh
  14M   ├─┬ soarpkgs
  13M   │ ├─┬ data
 2.5M   │ │ ├── INDEX.json
 1.7M   │ │ ├── OLD_bincache_x86_64-Linux.json
 1.7M   │ │ ├── OLD_bincache_aarch64-Linux.json
 1.5M   │ │ ├── BACKAGE.json
 1.3M   │ │ ├── INDEX.db
 1.0M   │ │ ├── DIFF_bincache_aarch64-Linux.json
1008K   │ │ ├── DIFF_bincache_x86_64-Linux.json
 712K   │ │ ├── pub_issues_binaries.txt
 368K   │ │ ├── INDEX.json.cba
 304K   │ │ ├── pub_issues_packages.txt
 260K   │ │ ├── OLD_pkgcache_x86_64-Linux.json
 240K   │ │ ├── INDEX.db.cba
 232K   │ │ ├── GH_REPO.md
 228K   │ │ ├── INDEX.json.xz
 220K   │ │ ├── INDEX.json.zstd
 184K   │ │ ├── INDEX.db.zstd
 176K   │ │ ├── INDEX.db.xz
 168K   │ │ ├── OLD_pkgcache_aarch64-Linux.json
  72K   │ │ ├── DIFF_pkgcache_x86_64-Linux.json
  52K   │ │ ├── URLS.txt
  44K   │ │ ├── DIFF_pkgcache_aarch64-Linux.json
  20K   │ │ ├── DIFF_bincache.json
 8.0K   │ │ ├── DIFF_pkgcache.json
 4.0K   │ │ ├── minisign.pub
 4.0K   │ │ ├── TOTAL_CACHE.txt
 4.0K   │ │ ├── TOTAL_CACHE.json
 4.0K   │ │ ├── TOTAL.json
 4.0K   │ │ ├── INDEX.json.zstd.bsum
 4.0K   │ │ ├── INDEX.json.xz.bsum
 4.0K   │ │ ├── INDEX.json.bsum
 4.0K   │ │ ├── INDEX.db.zstd.bsum
 4.0K   │ │ ├── INDEX.db.xz.bsum
 4.0K   │ │ ├── INDEX.db.bsum
 4.0K   │ │ └── GH_REPO_ARCHIVED.md
 356K   │ └─┬ scripts
 204K   │   ├─┬ archived
  52K   │   │ ├── pkgcache_.github_scripts.7z
  36K   │   │ ├── sbuild_runner.sh
  24K   │   │ ├── upload_to_r2.sh
  20K   │   │ ├── sbuild_linter.sh
  16K   │   │ ├── gen_meta_aio_x86_64-Linux_web.sh
  16K   │   │ ├── gen_meta_aio_aarch64-Linux_web.sh
  12K   │   │ ├── gen_meta_aio_x86_64-Linux.sh
  12K   │   │ ├── gen_meta_aio_aarch64-Linux.sh
  12K   │   │ └── add_to_ghcr.sh
  28K   │   ├── sbuild_creator.sh
  28K   │   ├── github_fetcher.sh
  28K   │   ├── gen_meta.sh
  20K   │   ├── gen_meta_index.sh
  12K   │   ├── gen_meta_docker.sh
 8.0K   │   ├── scrape_pub_issues_packages.sh
 8.0K   │   ├── scrape_pub_issues_binaries.sh
 8.0K   │   ├── repology_fetcher.sh
 4.0K   │   ├── gen_ghcr_backage.sh
 4.0K   │   └── gen_diff.sh
 7.1M   ├─┬ pkgcache
 7.0M   │ ├─┬ data
 1.2M   │ │ ├── x86_64-Linux.db
 1.1M   │ │ ├── x86_64-Linux.json
 1.1M   │ │ ├── x86_64-Linux.sdb
 692K   │ │ ├── aarch64-Linux.db
 636K   │ │ ├── aarch64-Linux.json
 592K   │ │ ├── aarch64-Linux.sdb
 148K   │ │ ├── x86_64-Linux.sdb.cba
 140K   │ │ ├── x86_64-Linux.db.cba
 132K   │ │ ├── x86_64-Linux.json.cba
 124K   │ │ ├── x86_64-Linux.sdb.zstd
 116K   │ │ ├── x86_64-Linux.db.zstd
 112K   │ │ ├── x86_64-Linux.sdb.xz
 108K   │ │ ├── x86_64-Linux.db.xz
 104K   │ │ ├── x86_64-Linux.json.zstd
 100K   │ │ ├── x86_64-Linux.json.xz
  88K   │ │ ├── aarch64-Linux.sdb.cba
  88K   │ │ ├── aarch64-Linux.db.cba
  76K   │ │ ├── aarch64-Linux.json.cba
  72K   │ │ ├── aarch64-Linux.sdb.zstd
  68K   │ │ ├── aarch64-Linux.sdb.xz
  68K   │ │ ├── aarch64-Linux.db.zstd
  64K   │ │ ├── aarch64-Linux.db.xz
  60K   │ │ ├── aarch64-Linux.json.zstd
  60K   │ │ ├── aarch64-Linux.json.xz
 4.0K   │ │ ├── x86_64-Linux.sdb.zstd.bsum
 4.0K   │ │ ├── x86_64-Linux.sdb.xz.bsum
 4.0K   │ │ ├── x86_64-Linux.sdb.bsum
 4.0K   │ │ ├── x86_64-Linux.json.zstd.bsum
 4.0K   │ │ ├── x86_64-Linux.json.xz.bsum
 4.0K   │ │ ├── x86_64-Linux.json.bsum
 4.0K   │ │ ├── x86_64-Linux.db.zstd.bsum
 4.0K   │ │ ├── x86_64-Linux.db.xz.bsum
 4.0K   │ │ ├── x86_64-Linux.db.bsum
 4.0K   │ │ ├── minisign.pub
 4.0K   │ │ ├── aarch64-Linux.sdb.zstd.bsum
 4.0K   │ │ ├── aarch64-Linux.sdb.xz.bsum
 4.0K   │ │ ├── aarch64-Linux.sdb.bsum
 4.0K   │ │ ├── aarch64-Linux.json.zstd.bsum
 4.0K   │ │ ├── aarch64-Linux.json.xz.bsum
 4.0K   │ │ ├── aarch64-Linux.json.bsum
 4.0K   │ │ ├── aarch64-Linux.db.zstd.bsum
 4.0K   │ │ ├── aarch64-Linux.db.xz.bsum
 4.0K   │ │ ├── aarch64-Linux.db.bsum
 4.0K   │ │ └── TOTAL.json
 132K   │ └─┬ scripts
  52K   │   ├─┬ archived
  48K   │   │ └── healthchecks.yaml
  32K   │   ├── gen_meta_x86_64-Linux.sh
  32K   │   ├── gen_meta_aarch64-Linux.sh
  12K   │   └── sync_hf_mirror.sh
 2.5M   ├─┬ completions
 1.2M   │ ├── ALL_x86_64-Linux.txt
 572K   │ ├── ALL_aarch64-Linux.txt
 512K   │ ├── PKG_NAME_ONLY_x86_64-Linux.txt
 240K   │ └── PKG_NAME_ONLY_aarch64-Linux.txt
 320K   ├─┬ web
 164K   │ ├─┬ cloudflare
  88K   │ │ ├─┬ src
  48K   │ │ │ ├── config.ts
  16K   │ │ │ ├── static.ts
  12K   │ │ │ ├── render.ts
 4.0K   │ │ │ ├── types.ts
 4.0K   │ │ │ └── index.ts
  52K   │ │ ├── package-lock.json
  12K   │ │ ├── tsconfig.json
 4.0K   │ │ ├── wrangler.toml
 4.0K   │ │ └── package.json
 152K   │ └─┬ assets
  40K   │   ├── icon_package_multi.png
  36K   │   ├── icon_server.png
  28K   │   ├── icon_database.png
  24K   │   ├── icon_config_multi.png
  20K   │   └── icon_json.png
 256K   ├── GHCR_PKGS.json.zstd
  28K   ├─┬ r2
  12K   │ ├─┬ scripts
 8.0K   │ │ └── sync_r2_mirror.sh
  12K   │ └─┬ data
 8.0K   │   └── PKG_LIST.txt
  16K   ├─┬ workers
  12K   │ └─┬ omni-redirector-pkgforge-dev
 8.0K   │   └── worker.js
  12K   ├── README.md
 4.0K   ├── TOTAL_INSTALLABLE.json
 4.0K   ├── TOTAL_ALL.json
 4.0K   └── LICENSE
```
