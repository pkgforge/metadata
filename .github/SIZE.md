```mathematica
 436M └─┬ main
 176M   ├─┬ misc
 176M   │ ├─┬ data
  71M   │ │ ├── ARCHLINUX.json
  37M   │ │ ├── FLATPAK_APPSTREAM.xml
  23M   │ │ ├── DEBIAN.json
  11M   │ │ ├── ALPINE_PKG.json
  10M   │ │ ├── NIXPKGS.json
 9.0M   │ │ ├── PKGSRC.json
 5.1M   │ │ ├── ALPINE_GIT.json
 2.8M   │ │ ├── BREW_FORMULA.json
 1.6M   │ │ ├── BREW_CASK.json
 1.1M   │ │ ├── PPKG_RAW.json
 540K   │ │ ├── STALIX.json
 464K   │ │ ├── FLATPAK_APPS_INFO.json
 432K   │ │ ├── FLATPAK_APPS_INFO.txt
 312K   │ │ ├── PPKG.json
 236K   │ │ ├── FLATPAK_POPULAR.json
 228K   │ │ ├── FLATPAK_TRENDING.json
  76K   │ │ ├── FLATPAK_APP_IDS.txt
  20K   │ │ ├── CATEGORY.json
 4.0K   │ │ └── CATEGORY.md
  88K   │ └─┬ scripts
  12K   │   ├── fetch_flatpak.sh
  12K   │   ├── fetch_alpine_pkg.sh
 8.0K   │   ├── fetch_homebrew.sh
 8.0K   │   ├── fetch_gh_logs.sh
 8.0K   │   ├── fetch_debian_src.sh
 8.0K   │   ├── fetch_archlinux_src.sh
 4.0K   │   ├── fetch_stalix.sh
 4.0K   │   ├── fetch_ppkg.sh
 4.0K   │   ├── fetch_pkgsrc.sh
 4.0K   │   ├── fetch_nixpkgs.sh
 4.0K   │   ├── fetch_debian_docker.sh
 4.0K   │   ├── fetch_archlinux_docker.sh
 4.0K   │   └── fetch_alpine_git.sh
 140M   ├─┬ bincache
 140M   │ ├─┬ data
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
 956K   │ │ ├── x86_64-Linux.sdb.zstd
 920K   │ │ ├── aarch64-Linux.sdb.zstd
 908K   │ │ ├── x86_64-Linux.db.zstd
 888K   │ │ ├── x86_64-Linux.db.xz
 876K   │ │ ├── x86_64-Linux.sdb.xz
 872K   │ │ ├── aarch64-Linux.db.zstd
 852K   │ │ ├── aarch64-Linux.db.xz
 844K   │ │ ├── aarch64-Linux.sdb.xz
 840K   │ │ ├── x86_64-Linux.json.zstd
 808K   │ │ ├── x86_64-Linux.json.xz
 804K   │ │ ├── aarch64-Linux.json.zstd
 772K   │ │ ├── aarch64-Linux.json.xz
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
  52M   ├── GHCR_PKGS.json
  34M   ├─┬ external
  12M   │ ├─┬ am
  12M   │ │ ├─┬ data
 4.1M   │ │ │ ├── x86_64-Linux.json
 3.2M   │ │ │ ├── x86_64-Linux.db
 1.1M   │ │ │ ├── x86_64-Linux.AM.txt
 1.0M   │ │ │ ├── aarch64-Linux.AM.txt
 524K   │ │ │ ├── x86_64-Linux.db.cba
 488K   │ │ │ ├── x86_64-Linux.json.cba
 432K   │ │ │ ├── x86_64-Linux.db.zstd
 424K   │ │ │ ├── x86_64-Linux.db.xz
 400K   │ │ │ ├── x86_64-Linux.json.zstd
 392K   │ │ │ ├── x86_64-Linux.json.xz
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
 3.8M   │ │ │ ├── x86_64-Linux.json
 3.0M   │ │ │ ├── x86_64-Linux.db
 1.6M   │ │ │ ├── aarch64-Linux.json
 1.2M   │ │ │ ├── aarch64-Linux.db
 328K   │ │ │ ├── x86_64-Linux.db.cba
 304K   │ │ │ ├── x86_64-Linux.json.cba
 264K   │ │ │ ├── x86_64-Linux.db.zstd
 252K   │ │ │ ├── x86_64-Linux.db.xz
 232K   │ │ │ ├── x86_64-Linux.json.zstd
 220K   │ │ │ ├── x86_64-Linux.json.xz
 136K   │ │ │ ├── aarch64-Linux.db.cba
 132K   │ │ │ ├── aarch64-Linux.json.cba
 116K   │ │ │ ├── aarch64-Linux.db.zstd
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
 5.7M   │ ├─┬ appimagehub
 5.7M   │ │ ├─┬ data
 2.1M   │ │ │ ├── x86_64-Linux.json
 1.9M   │ │ │ ├── x86_64-Linux.db
 284K   │ │ │ ├── x86_64-Linux.json.cba
 264K   │ │ │ ├── x86_64-Linux.db.cba
 228K   │ │ │ ├── x86_64-Linux.db.zstd
 220K   │ │ │ ├── x86_64-Linux.json.zstd
 216K   │ │ │ ├── x86_64-Linux.db.xz
 208K   │ │ │ ├── x86_64-Linux.json.xz
  92K   │ │ │ ├── aarch64-Linux.db
  88K   │ │ │ ├── aarch64-Linux.json
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
 4.8M   │ └─┬ appimage.github.io
 4.8M   │   ├─┬ data
 1.8M   │   │ ├── x86_64-Linux.json
 1.5M   │   │ ├── x86_64-Linux.db
 216K   │   │ ├── x86_64-Linux.db.cba
 192K   │   │ ├── x86_64-Linux.json.cba
 184K   │   │ ├── aarch64-Linux.json
 172K   │   │ ├── aarch64-Linux.db
 168K   │   │ ├── x86_64-Linux.db.zstd
 164K   │   │ ├── x86_64-Linux.db.xz
 148K   │   │ ├── x86_64-Linux.json.zstd
 144K   │   │ ├── x86_64-Linux.json.xz
  28K   │   │ ├── aarch64-Linux.db.cba
  24K   │   │ ├── aarch64-Linux.json.cba
  24K   │   │ ├── aarch64-Linux.db.zstd
  24K   │   │ ├── aarch64-Linux.db.xz
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
  20M   ├─┬ soarpkgs
  20M   │ ├─┬ data
 2.5M   │ │ ├── INDEX.json
 2.0M   │ │ ├── OLD_bincache_x86_64-Linux.json
 2.0M   │ │ ├── OLD_bincache_aarch64-Linux.json
 1.7M   │ │ ├── BACKAGE.json
 1.7M   │ │ ├── COMP_VER_CACHE.json
 1.4M   │ │ ├── INDEX.db
 1.1M   │ │ ├── DIFF_bincache_aarch64-Linux.json
 1.1M   │ │ ├── DIFF_bincache_x86_64-Linux.json
 1.0M   │ │ ├── COMP_VER_CACHE_OLD.json
1004K   │ │ ├── COMP_VER_CACHE.md
 728K   │ │ ├── pub_issues_binaries.txt
 636K   │ │ ├── COMP_VER_bincache_x86_64-Linux.json
 616K   │ │ ├── COMP_VER_bincache_aarch64-Linux.json
 376K   │ │ ├── INDEX.json.cba
 304K   │ │ ├── pub_issues_packages.txt
 288K   │ │ ├── OLD_pkgcache_x86_64-Linux.json
 240K   │ │ ├── INDEX.db.cba
 236K   │ │ ├── GH_REPO.md
 228K   │ │ ├── INDEX.json.xz
 224K   │ │ ├── INDEX.json.zstd
 192K   │ │ ├── OLD_pkgcache_aarch64-Linux.json
 188K   │ │ ├── INDEX.db.zstd
 176K   │ │ ├── INDEX.db.xz
 124K   │ │ ├── DIFF_pkgcache_x86_64-Linux.json
  72K   │ │ ├── DIFF_pkgcache_aarch64-Linux.json
  52K   │ │ ├── URLS.txt
  48K   │ │ ├── COMP_VER_pkgcache_x86_64-Linux.json
  28K   │ │ ├── COMP_VER_pkgcache_aarch64-Linux.json
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
 7.3M   ├─┬ pkgcache
 7.2M   │ ├─┬ data
 1.2M   │ │ ├── x86_64-Linux.db
 1.2M   │ │ ├── x86_64-Linux.json
 1.1M   │ │ ├── x86_64-Linux.sdb
 708K   │ │ ├── aarch64-Linux.db
 664K   │ │ ├── aarch64-Linux.json
 612K   │ │ ├── aarch64-Linux.sdb
 156K   │ │ ├── x86_64-Linux.sdb.cba
 144K   │ │ ├── x86_64-Linux.db.cba
 136K   │ │ ├── x86_64-Linux.json.cba
 124K   │ │ ├── x86_64-Linux.sdb.zstd
 120K   │ │ ├── x86_64-Linux.db.zstd
 116K   │ │ ├── x86_64-Linux.sdb.xz
 112K   │ │ ├── x86_64-Linux.db.xz
 108K   │ │ ├── x86_64-Linux.json.zstd
 104K   │ │ ├── x86_64-Linux.json.xz
  92K   │ │ ├── aarch64-Linux.sdb.cba
  92K   │ │ ├── aarch64-Linux.db.cba
  80K   │ │ ├── aarch64-Linux.json.cba
  72K   │ │ ├── aarch64-Linux.sdb.zstd
  72K   │ │ ├── aarch64-Linux.db.zstd
  68K   │ │ ├── aarch64-Linux.sdb.xz
  68K   │ │ ├── aarch64-Linux.db.xz
  64K   │ │ ├── aarch64-Linux.json.zstd
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
 576K   │ ├── ALL_aarch64-Linux.txt
 516K   │ ├── PKG_NAME_ONLY_x86_64-Linux.txt
 244K   │ └── PKG_NAME_ONLY_aarch64-Linux.txt
 952K   ├── PKG_STATUS.md
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
 268K   ├── GHCR_PKGS.json.zstd
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
