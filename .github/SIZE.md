```mathematica
258M └─┬ main
170M   ├─┬ misc
170M   │ ├─┬ data
 69M   │ │ ├── ARCHLINUX.json
 35M   │ │ ├── FLATPAK_APPSTREAM.xml
 23M   │ │ ├── DEBIAN.json
 10M   │ │ ├── ALPINE_PKG.json
 10M   │ │ ├── NIXPKGS.json
9.0M   │ │ ├── PKGSRC.json
5.0M   │ │ ├── ALPINE_GIT.json
2.7M   │ │ ├── BREW_FORMULA.json
1.5M   │ │ ├── BREW_CASK.json
996K   │ │ ├── PPKG_RAW.json
448K   │ │ ├── FLATPAK_APPS_INFO.json
416K   │ │ ├── FLATPAK_APPS_INFO.txt
288K   │ │ ├── PPKG.json
244K   │ │ ├── FLATPAK_POPULAR.json
228K   │ │ ├── FLATPAK_TRENDING.json
 72K   │ │ ├── FLATPAK_APP_IDS.txt
 20K   │ │ ├── CATEGORY.json
4.0K   │ │ └── CATEGORY.md
 88K   │ └─┬ scripts
 12K   │   ├── fetch_flatpak.sh
 12K   │   ├── fetch_alpine_pkg.sh
8.0K   │   ├── fetch_homebrew.sh
8.0K   │   ├── fetch_gh_logs.sh
8.0K   │   ├── fetch_debian_src.sh
8.0K   │   ├── fetch_archlinux_src.sh
8.0K   │   ├── fetch_alpine_git.sh
4.0K   │   ├── fetch_ppkg.sh
4.0K   │   ├── fetch_pkgsrc.sh
4.0K   │   ├── fetch_nixpkgs.sh
4.0K   │   ├── fetch_debian_docker.sh
4.0K   │   └── fetch_archlinux_docker.sh
 78M   ├─┬ bincache
 78M   │ ├─┬ data
 14M   │ │ ├── x86_64-Linux.json
 13M   │ │ ├── aarch64-Linux.json
 11M   │ │ ├── x86_64-Linux.db
 11M   │ │ ├── aarch64-Linux.db
7.7M   │ │ ├── x86_64-Linux.sdb
7.2M   │ │ ├── aarch64-Linux.sdb
900K   │ │ ├── x86_64-Linux.db.cba
872K   │ │ ├── x86_64-Linux.sdb.cba
848K   │ │ ├── aarch64-Linux.db.cba
824K   │ │ ├── aarch64-Linux.sdb.cba
812K   │ │ ├── x86_64-Linux.json.cba
748K   │ │ ├── aarch64-Linux.json.cba
648K   │ │ ├── x86_64-Linux.sdb.zstd
628K   │ │ ├── x86_64-Linux.db.zstd
608K   │ │ ├── x86_64-Linux.db.xz
608K   │ │ ├── aarch64-Linux.sdb.zstd
596K   │ │ ├── x86_64-Linux.sdb.xz
588K   │ │ ├── aarch64-Linux.db.zstd
572K   │ │ ├── aarch64-Linux.db.xz
556K   │ │ ├── x86_64-Linux.json.zstd
556K   │ │ ├── aarch64-Linux.sdb.xz
536K   │ │ ├── x86_64-Linux.json.xz
520K   │ │ ├── aarch64-Linux.json.zstd
504K   │ │ ├── aarch64-Linux.json.xz
4.0K   │ │ ├── x86_64-Linux.sdb.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.sdb.xz.bsum
4.0K   │ │ ├── x86_64-Linux.sdb.bsum
4.0K   │ │ ├── x86_64-Linux.json.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.json.xz.bsum
4.0K   │ │ ├── x86_64-Linux.json.bsum
4.0K   │ │ ├── x86_64-Linux.db.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.db.xz.bsum
4.0K   │ │ ├── x86_64-Linux.db.bsum
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
 68K   │ └─┬ scripts
 28K   │   ├── gen_meta_x86_64-Linux.sh
 28K   │   ├── gen_meta_aarch64-Linux.sh
8.0K   │   └── sync_hf_mirror.sh
6.9M   ├─┬ soarpkgs
6.5M   │ ├─┬ data
1.6M   │ │ ├── INDEX.json
1.2M   │ │ ├── BACKAGE.json
848K   │ │ ├── INDEX.db
784K   │ │ ├── pub_issues_binaries.txt
312K   │ │ ├── DIFF_bincache_aarch64-Linux.json
304K   │ │ ├── pub_issues_packages.txt
288K   │ │ ├── DIFF_bincache_x86_64-Linux.json
240K   │ │ ├── INDEX.json.cba
152K   │ │ ├── INDEX.json.zstd
152K   │ │ ├── INDEX.json.xz
148K   │ │ ├── INDEX.db.cba
144K   │ │ ├── GH_REPO.md
120K   │ │ ├── INDEX.db.zstd
112K   │ │ ├── INDEX.db.xz
 40K   │ │ ├── DIFF_pkgcache_x86_64-Linux.json
 32K   │ │ ├── URLS.txt
 28K   │ │ ├── GH_REPO_ARCHIVED.md
 28K   │ │ ├── DIFF_pkgcache_aarch64-Linux.json
 28K   │ │ ├── DIFF_bincache.json
8.0K   │ │ ├── DIFF_pkgcache.json
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
2.6M   ├─┬ pkgcache
2.5M   │ ├─┬ data
528K   │ │ ├── x86_64-Linux.sdb
504K   │ │ ├── x86_64-Linux.db
452K   │ │ ├── x86_64-Linux.json
156K   │ │ ├── aarch64-Linux.sdb
116K   │ │ ├── aarch64-Linux.db
104K   │ │ ├── aarch64-Linux.json
 60K   │ │ ├── x86_64-Linux.sdb.cba
 52K   │ │ ├── x86_64-Linux.sdb.zstd
 52K   │ │ ├── x86_64-Linux.db.cba
 48K   │ │ ├── x86_64-Linux.sdb.xz
 48K   │ │ ├── x86_64-Linux.json.cba
 48K   │ │ ├── x86_64-Linux.db.zstd
 44K   │ │ ├── x86_64-Linux.db.xz
 40K   │ │ ├── x86_64-Linux.json.zstd
 40K   │ │ ├── x86_64-Linux.json.xz
 20K   │ │ ├── aarch64-Linux.sdb.cba
 16K   │ │ ├── aarch64-Linux.sdb.zstd
 16K   │ │ ├── aarch64-Linux.sdb.xz
 16K   │ │ ├── aarch64-Linux.json.cba
 16K   │ │ ├── aarch64-Linux.db.zstd
 16K   │ │ ├── aarch64-Linux.db.xz
 16K   │ │ ├── aarch64-Linux.db.cba
 12K   │ │ ├── aarch64-Linux.json.zstd
 12K   │ │ ├── aarch64-Linux.json.xz
4.0K   │ │ ├── x86_64-Linux.sdb.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.sdb.xz.bsum
4.0K   │ │ ├── x86_64-Linux.sdb.bsum
4.0K   │ │ ├── x86_64-Linux.json.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.json.xz.bsum
4.0K   │ │ ├── x86_64-Linux.json.bsum
4.0K   │ │ ├── x86_64-Linux.db.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.db.xz.bsum
4.0K   │ │ ├── x86_64-Linux.db.bsum
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
120K   │ └─┬ scripts
 52K   │   ├─┬ archived
 48K   │   │ └── healthchecks.yaml
 28K   │   ├── gen_meta_x86_64-Linux.sh
 28K   │   ├── gen_meta_aarch64-Linux.sh
8.0K   │   └── sync_hf_mirror.sh
280K   ├─┬ web
152K   │ ├─┬ assets
 40K   │ │ ├── icon_package_multi.png
 36K   │ │ ├── icon_server.png
 28K   │ │ ├── icon_database.png
 24K   │ │ ├── icon_config_multi.png
 20K   │ │ └── icon_json.png
124K   │ └─┬ cloudflare
 64K   │   ├─┬ src
 24K   │   │ ├── config.ts
 16K   │   │ ├── static.ts
 12K   │   │ ├── render.ts
4.0K   │   │ ├── types.ts
4.0K   │   │ └── index.ts
 36K   │   ├── package-lock.json
 12K   │   ├── tsconfig.json
4.0K   │   ├── wrangler.toml
4.0K   │   └── package.json
 16K   ├─┬ workers
 12K   │ └─┬ omni-redirector-pkgforge-dev
8.0K   │   └── worker.js
4.0K   ├── README.md
4.0K   └── LICENSE
```
