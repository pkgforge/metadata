```mathematica
 309M └─┬ main
 171M   ├─┬ misc
 171M   │ ├─┬ data
  69M   │ │ ├── ARCHLINUX.json
  35M   │ │ ├── FLATPAK_APPSTREAM.xml
  23M   │ │ ├── DEBIAN.json
  10M   │ │ ├── ALPINE_PKG.json
  10M   │ │ ├── NIXPKGS.json
 9.0M   │ │ ├── PKGSRC.json
 5.0M   │ │ ├── ALPINE_GIT.json
 2.7M   │ │ ├── BREW_FORMULA.json
 1.5M   │ │ ├── BREW_CASK.json
 1.0M   │ │ ├── PPKG_RAW.json
 448K   │ │ ├── FLATPAK_APPS_INFO.json
 420K   │ │ ├── FLATPAK_APPS_INFO.txt
 300K   │ │ ├── PPKG.json
 240K   │ │ ├── FLATPAK_POPULAR.json
 224K   │ │ ├── FLATPAK_TRENDING.json
  72K   │ │ ├── FLATPAK_APP_IDS.txt
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
  94M   ├─┬ bincache
  94M   │ ├─┬ data
  17M   │ │ ├── x86_64-Linux.json
  16M   │ │ ├── aarch64-Linux.json
  14M   │ │ ├── x86_64-Linux.db
  14M   │ │ ├── aarch64-Linux.db
 8.8M   │ │ ├── x86_64-Linux.sdb
 8.5M   │ │ ├── aarch64-Linux.sdb
 1.1M   │ │ ├── x86_64-Linux.db.cba
 1.0M   │ │ ├── aarch64-Linux.db.cba
 1.0M   │ │ ├── x86_64-Linux.sdb.cba
 1.0M   │ │ ├── x86_64-Linux.json.cba
1012K   │ │ ├── aarch64-Linux.sdb.cba
 956K   │ │ ├── aarch64-Linux.json.cba
 776K   │ │ ├── x86_64-Linux.sdb.zstd
 752K   │ │ ├── x86_64-Linux.db.zstd
 740K   │ │ ├── x86_64-Linux.db.xz
 740K   │ │ ├── aarch64-Linux.sdb.zstd
 720K   │ │ ├── aarch64-Linux.db.zstd
 708K   │ │ ├── x86_64-Linux.sdb.xz
 708K   │ │ ├── aarch64-Linux.db.xz
 688K   │ │ ├── x86_64-Linux.json.zstd
 676K   │ │ ├── aarch64-Linux.sdb.xz
 668K   │ │ ├── x86_64-Linux.json.xz
 656K   │ │ ├── aarch64-Linux.json.zstd
 636K   │ │ ├── aarch64-Linux.json.xz
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
  29M   ├─┬ external
  11M   │ ├─┬ am
  11M   │ │ ├─┬ data
 3.9M   │ │ │ ├── x86_64-Linux.json
 3.1M   │ │ │ ├── x86_64-Linux.db
 924K   │ │ │ ├── x86_64-Linux.AM.txt
 860K   │ │ │ ├── aarch64-Linux.AM.txt
 500K   │ │ │ ├── x86_64-Linux.db.cba
 468K   │ │ │ ├── x86_64-Linux.json.cba
 420K   │ │ │ ├── x86_64-Linux.db.zstd
 408K   │ │ │ ├── x86_64-Linux.db.xz
 384K   │ │ │ ├── x86_64-Linux.json.zstd
 376K   │ │ │ ├── x86_64-Linux.json.xz
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
 8.3M   │ ├─┬ cargo-bins
 8.3M   │ │ ├─┬ data
 2.7M   │ │ │ ├── x86_64-Linux.json
 1.9M   │ │ │ ├── x86_64-Linux.db
 1.1M   │ │ │ ├── aarch64-Linux.json
 812K   │ │ │ ├── aarch64-Linux.db
 264K   │ │ │ ├── x86_64-Linux.db.cba
 244K   │ │ │ ├── x86_64-Linux.json.cba
 212K   │ │ │ ├── x86_64-Linux.db.zstd
 204K   │ │ │ ├── x86_64-Linux.db.xz
 192K   │ │ │ ├── x86_64-Linux.json.zstd
 184K   │ │ │ ├── x86_64-Linux.json.xz
 108K   │ │ │ ├── aarch64-Linux.db.cba
 100K   │ │ │ ├── aarch64-Linux.json.cba
  92K   │ │ │ ├── aarch64-Linux.db.zstd
  88K   │ │ │ ├── aarch64-Linux.db.xz
  80K   │ │ │ ├── aarch64-Linux.json.zstd
  76K   │ │ │ ├── aarch64-Linux.json.xz
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
 4.0K   │ │ │ └── aarch64-Linux.db.bsum
  28K   │ │ └─┬ scripts
  24K   │ │   └── gen_meta.sh
 5.5M   │ ├─┬ appimagehub
 5.4M   │ │ ├─┬ data
 2.0M   │ │ │ ├── x86_64-Linux.json
 1.8M   │ │ │ ├── x86_64-Linux.db
 276K   │ │ │ ├── x86_64-Linux.json.cba
 268K   │ │ │ ├── x86_64-Linux.db.cba
 220K   │ │ │ ├── x86_64-Linux.db.zstd
 216K   │ │ │ ├── x86_64-Linux.json.zstd
 212K   │ │ │ ├── x86_64-Linux.db.xz
 204K   │ │ │ ├── x86_64-Linux.json.xz
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
 4.5M   │   ├─┬ data
 1.7M   │   │ ├── x86_64-Linux.json
 1.4M   │   │ ├── x86_64-Linux.db
 212K   │   │ ├── x86_64-Linux.db.cba
 192K   │   │ ├── x86_64-Linux.json.cba
 168K   │   │ ├── x86_64-Linux.db.zstd
 168K   │   │ ├── aarch64-Linux.json
 164K   │   │ ├── x86_64-Linux.db.xz
 148K   │   │ ├── x86_64-Linux.json.zstd
 148K   │   │ ├── aarch64-Linux.db
 144K   │   │ ├── x86_64-Linux.json.xz
  24K   │   │ ├── aarch64-Linux.db.zstd
  24K   │   │ ├── aarch64-Linux.db.cba
  20K   │   │ ├── aarch64-Linux.json.zstd
  20K   │   │ ├── aarch64-Linux.json.xz
  20K   │   │ ├── aarch64-Linux.json.cba
  20K   │   │ ├── aarch64-Linux.db.xz
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
 7.8M   ├─┬ soarpkgs
 7.5M   │ ├─┬ data
 2.1M   │ │ ├── INDEX.json
 1.3M   │ │ ├── BACKAGE.json
 1.1M   │ │ ├── INDEX.db
 788K   │ │ ├── pub_issues_binaries.txt
 304K   │ │ ├── pub_issues_packages.txt
 304K   │ │ ├── INDEX.json.cba
 272K   │ │ ├── DIFF_bincache_aarch64-Linux.json
 208K   │ │ ├── DIFF_bincache_x86_64-Linux.json
 192K   │ │ ├── INDEX.db.cba
 188K   │ │ ├── INDEX.json.xz
 184K   │ │ ├── INDEX.json.zstd
 172K   │ │ ├── GH_REPO.md
 152K   │ │ ├── INDEX.db.zstd
 144K   │ │ ├── INDEX.db.xz
  64K   │ │ ├── DIFF_pkgcache_x86_64-Linux.json
  40K   │ │ ├── URLS.txt
  40K   │ │ ├── DIFF_pkgcache_aarch64-Linux.json
  28K   │ │ ├── GH_REPO_ARCHIVED.md
  24K   │ │ ├── DIFF_bincache.json
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
 4.0K   │ │ └── INDEX.db.bsum
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
 5.5M   ├─┬ pkgcache
 5.4M   │ ├─┬ data
 988K   │ │ ├── x86_64-Linux.db
 920K   │ │ ├── x86_64-Linux.json
 864K   │ │ ├── x86_64-Linux.sdb
 496K   │ │ ├── aarch64-Linux.db
 444K   │ │ ├── aarch64-Linux.json
 392K   │ │ ├── aarch64-Linux.sdb
 120K   │ │ ├── x86_64-Linux.sdb.cba
 116K   │ │ ├── x86_64-Linux.db.cba
 104K   │ │ ├── x86_64-Linux.json.cba
  96K   │ │ ├── x86_64-Linux.sdb.zstd
  92K   │ │ ├── x86_64-Linux.db.zstd
  88K   │ │ ├── x86_64-Linux.sdb.xz
  88K   │ │ ├── x86_64-Linux.db.xz
  84K   │ │ ├── x86_64-Linux.json.zstd
  80K   │ │ ├── x86_64-Linux.json.xz
  60K   │ │ ├── aarch64-Linux.sdb.cba
  60K   │ │ ├── aarch64-Linux.db.cba
  56K   │ │ ├── aarch64-Linux.json.cba
  52K   │ │ ├── aarch64-Linux.sdb.zstd
  48K   │ │ ├── aarch64-Linux.sdb.xz
  48K   │ │ ├── aarch64-Linux.db.zstd
  48K   │ │ ├── aarch64-Linux.db.xz
  44K   │ │ ├── aarch64-Linux.json.zstd
  44K   │ │ ├── aarch64-Linux.json.xz
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
