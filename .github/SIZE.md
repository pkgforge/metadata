```mathematica
 196M └─┬ main
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
 444K   │ │ ├── FLATPAK_APPS_INFO.json
 416K   │ │ ├── FLATPAK_APPS_INFO.txt
 284K   │ │ ├── PPKG.json
 240K   │ │ ├── FLATPAK_POPULAR.json
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
  18M   ├─┬ bincache
  18M   │ ├─┬ data
 4.3M   │ │ ├── x86_64-Linux.json
 3.6M   │ │ ├── aarch64-Linux.json
 3.6M   │ │ ├── x86_64-Linux.db
 3.1M   │ │ ├── aarch64-Linux.db
 464K   │ │ ├── x86_64-Linux.db.cba
 412K   │ │ ├── x86_64-Linux.json.cba
 408K   │ │ ├── aarch64-Linux.db.cba
 364K   │ │ ├── aarch64-Linux.json.cba
 360K   │ │ ├── x86_64-Linux.db.zstd
 344K   │ │ ├── x86_64-Linux.db.xz
 336K   │ │ ├── x86_64-Linux.json.xz
 328K   │ │ ├── aarch64-Linux.db.zstd
 324K   │ │ ├── x86_64-Linux.json.zstd
 312K   │ │ ├── aarch64-Linux.db.xz
 304K   │ │ ├── aarch64-Linux.json.xz
 292K   │ │ ├── aarch64-Linux.json.zstd
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
  60K   │ └─┬ scripts
  28K   │   ├── gen_meta_x86_64-Linux.sh
  28K   │   └── gen_meta_aarch64-Linux.sh
 6.3M   ├─┬ soarpkgs
 6.0M   │ ├─┬ data
 1.5M   │ │ ├── INDEX.json
 1.0M   │ │ ├── BACKAGE.json
 796K   │ │ ├── pub_issues_binaries.txt
 744K   │ │ ├── INDEX.db
 304K   │ │ ├── pub_issues_packages.txt
 276K   │ │ ├── DIFF_bincache_aarch64-Linux.json
 260K   │ │ ├── DIFF_bincache_x86_64-Linux.json
 212K   │ │ ├── INDEX.json.cba
 140K   │ │ ├── INDEX.json.xz
 140K   │ │ ├── GH_REPO.md
 136K   │ │ ├── INDEX.json.zstd
 132K   │ │ ├── INDEX.db.cba
 108K   │ │ ├── INDEX.db.zstd
 104K   │ │ ├── INDEX.db.xz
  60K   │ │ ├── DIFF_pkgcache_x86_64-Linux.json
  36K   │ │ ├── DIFF_pkgcache_aarch64-Linux.json
  28K   │ │ ├── URLS.txt
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
 1.1M   ├─┬ pkgcache
1004K   │ ├─┬ data
 308K   │ │ ├── x86_64-Linux.db
 268K   │ │ ├── x86_64-Linux.json
  80K   │ │ ├── aarch64-Linux.db
  68K   │ │ ├── aarch64-Linux.json
  32K   │ │ ├── x86_64-Linux.db.cba
  28K   │ │ ├── x86_64-Linux.json.zstd
  28K   │ │ ├── x86_64-Linux.json.xz
  28K   │ │ ├── x86_64-Linux.json.cba
  28K   │ │ ├── x86_64-Linux.db.zstd
  28K   │ │ ├── x86_64-Linux.db.xz
  12K   │ │ ├── aarch64-Linux.db.cba
 8.0K   │ │ ├── aarch64-Linux.json.zstd
 8.0K   │ │ ├── aarch64-Linux.json.xz
 8.0K   │ │ ├── aarch64-Linux.json.cba
 8.0K   │ │ ├── aarch64-Linux.db.zstd
 8.0K   │ │ ├── aarch64-Linux.db.xz
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
