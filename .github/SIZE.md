```mathematica
234M └─┬ main
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
984K   │ │ ├── PPKG_RAW.json
448K   │ │ ├── FLATPAK_APPS_INFO.json
416K   │ │ ├── FLATPAK_APPS_INFO.txt
284K   │ │ ├── PPKG.json
244K   │ │ ├── FLATPAK_POPULAR.json
228K   │ │ ├── FLATPAK_TRENDING.json
 72K   │ │ ├── FLATPAK_APP_IDS.txt
 20K   │ │ ├── CATEGORY.json
4.0K   │ │ └── CATEGORY.md
 72K   │ └─┬ scripts
 12K   │   ├── fetch_alpine_pkg.sh
8.0K   │   ├── fetch_homebrew.sh
8.0K   │   ├── fetch_gh_logs.sh
8.0K   │   ├── fetch_flatpak.sh
8.0K   │   ├── fetch_debian.sh
8.0K   │   ├── fetch_archlinux.sh
4.0K   │   ├── fetch_ppkg.sh
4.0K   │   ├── fetch_pkgsrc.sh
4.0K   │   ├── fetch_nixpkgs.sh
4.0K   │   └── fetch_alpine_git.sh
 55M   ├─┬ bincache
 55M   │ ├─┬ data
 13M   │ │ ├── x86_64-Linux.json
 13M   │ │ ├── aarch64-Linux.json
 11M   │ │ ├── x86_64-Linux.db
 10M   │ │ ├── aarch64-Linux.db
828K   │ │ ├── x86_64-Linux.db.cba
800K   │ │ ├── aarch64-Linux.db.cba
752K   │ │ ├── x86_64-Linux.json.cba
692K   │ │ ├── aarch64-Linux.json.cba
580K   │ │ ├── x86_64-Linux.db.zstd
564K   │ │ ├── x86_64-Linux.db.xz
552K   │ │ ├── x86_64-Linux.json.xz
548K   │ │ ├── aarch64-Linux.db.zstd
532K   │ │ ├── aarch64-Linux.db.xz
520K   │ │ ├── aarch64-Linux.json.xz
516K   │ │ ├── x86_64-Linux.json.zstd
484K   │ │ ├── aarch64-Linux.json.zstd
4.0K   │ │ ├── x86_64-Linux.json.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.json.xz.bsum
4.0K   │ │ ├── x86_64-Linux.json.bsum
4.0K   │ │ ├── x86_64-Linux.db.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.db.xz.bsum
4.0K   │ │ ├── x86_64-Linux.db.bsum
4.0K   │ │ ├── aarch64-Linux.json.zstd.bsum
4.0K   │ │ ├── aarch64-Linux.json.xz.bsum
4.0K   │ │ ├── aarch64-Linux.json.bsum
4.0K   │ │ ├── aarch64-Linux.db.zstd.bsum
4.0K   │ │ ├── aarch64-Linux.db.xz.bsum
4.0K   │ │ ├── aarch64-Linux.db.bsum
4.0K   │ │ └── TOTAL.json
 56K   │ └─┬ scripts
 28K   │   ├── gen_meta_aarch64-Linux.sh
 24K   │   └── gen_meta_x86_64-Linux.sh
6.7M   ├─┬ soarpkgs
6.3M   │ ├─┬ data
1.5M   │ │ ├── INDEX.json
1.1M   │ │ ├── BACKAGE.json
780K   │ │ ├── pub_issues_binaries.txt
776K   │ │ ├── INDEX.db
364K   │ │ ├── DIFF_bincache_aarch64-Linux.json
332K   │ │ ├── DIFF_bincache_x86_64-Linux.json
292K   │ │ ├── pub_issues_packages.txt
224K   │ │ ├── INDEX.json.cba
144K   │ │ ├── INDEX.json.xz
140K   │ │ ├── INDEX.json.zstd
140K   │ │ ├── GH_REPO.md
136K   │ │ ├── INDEX.db.cba
112K   │ │ ├── INDEX.db.zstd
108K   │ │ ├── INDEX.db.xz
 48K   │ │ ├── DIFF_pkgcache_x86_64-Linux.json
 36K   │ │ ├── DIFF_pkgcache_aarch64-Linux.json
 32K   │ │ ├── URLS.txt
 28K   │ │ ├── GH_REPO_ARCHIVED.md
 28K   │ │ ├── DIFF_bincache.json
4.0K   │ │ ├── TOTAL_CACHE.txt
4.0K   │ │ ├── TOTAL_CACHE.json
4.0K   │ │ ├── TOTAL.json
4.0K   │ │ ├── INDEX.json.zstd.bsum
4.0K   │ │ ├── INDEX.json.xz.bsum
4.0K   │ │ ├── INDEX.json.bsum
4.0K   │ │ ├── INDEX.db.zstd.bsum
4.0K   │ │ ├── INDEX.db.xz.bsum
4.0K   │ │ ├── INDEX.db.bsum
4.0K   │ │ └── DIFF_pkgcache.json
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
1.3M   ├─┬ pkgcache
1.1M   │ ├─┬ data
356K   │ │ ├── x86_64-Linux.db
316K   │ │ ├── x86_64-Linux.json
 92K   │ │ ├── aarch64-Linux.db
 80K   │ │ ├── aarch64-Linux.json
 40K   │ │ ├── x86_64-Linux.db.cba
 36K   │ │ ├── x86_64-Linux.db.zstd
 32K   │ │ ├── x86_64-Linux.json.zstd
 32K   │ │ ├── x86_64-Linux.json.xz
 32K   │ │ ├── x86_64-Linux.json.cba
 32K   │ │ ├── x86_64-Linux.db.xz
 12K   │ │ ├── aarch64-Linux.json.zstd
 12K   │ │ ├── aarch64-Linux.json.xz
 12K   │ │ ├── aarch64-Linux.json.cba
 12K   │ │ ├── aarch64-Linux.db.zstd
 12K   │ │ ├── aarch64-Linux.db.xz
 12K   │ │ ├── aarch64-Linux.db.cba
4.0K   │ │ ├── x86_64-Linux.json.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.json.xz.bsum
4.0K   │ │ ├── x86_64-Linux.json.bsum
4.0K   │ │ ├── x86_64-Linux.db.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.db.xz.bsum
4.0K   │ │ ├── x86_64-Linux.db.bsum
4.0K   │ │ ├── aarch64-Linux.json.zstd.bsum
4.0K   │ │ ├── aarch64-Linux.json.xz.bsum
4.0K   │ │ ├── aarch64-Linux.json.bsum
4.0K   │ │ ├── aarch64-Linux.db.zstd.bsum
4.0K   │ │ ├── aarch64-Linux.db.xz.bsum
4.0K   │ │ ├── aarch64-Linux.db.bsum
4.0K   │ │ └── TOTAL.json
108K   │ └─┬ scripts
 52K   │   ├─┬ archived
 48K   │   │ └── healthchecks.yaml
 28K   │   ├── gen_meta_aarch64-Linux.sh
 24K   │   └── gen_meta_x86_64-Linux.sh
120K   ├─┬ web
116K   │ └─┬ cloudflare
 56K   │   ├─┬ src
 16K   │   │ ├── static.ts
 16K   │   │ ├── config.ts
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
