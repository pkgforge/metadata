```mathematica
188M └─┬ main
168M   ├─┬ misc
168M   │ ├─┬ data
 69M   │ │ ├── ARCHLINUX.json
 35M   │ │ ├── FLATPAK_APPSTREAM.xml
 23M   │ │ ├── DEBIAN.json
 10M   │ │ ├── ALPINE_PKG.json
 10M   │ │ ├── NIXPKGS.json
8.9M   │ │ ├── PKGSRC.json
4.9M   │ │ ├── ALPINE_GIT.json
2.7M   │ │ ├── BREW_FORMULA.json
1.5M   │ │ ├── BREW_CASK.json
444K   │ │ ├── FLATPAK_APPS_INFO.json
412K   │ │ ├── FLATPAK_APPS_INFO.txt
240K   │ │ ├── FLATPAK_POPULAR.json
228K   │ │ ├── FLATPAK_TRENDING.json
 72K   │ │ ├── FLATPAK_APP_IDS.txt
 20K   │ │ ├── CATEGORY.json
4.0K   │ │ └── CATEGORY.md
 68K   │ └─┬ scripts
 12K   │   ├── fetch_alpine_pkg.sh
8.0K   │   ├── fetch_homebrew.sh
8.0K   │   ├── fetch_gh_logs.sh
8.0K   │   ├── fetch_flatpak.sh
8.0K   │   ├── fetch_debian.sh
8.0K   │   ├── fetch_archlinux.sh
4.0K   │   ├── fetch_pkgsrc.sh
4.0K   │   ├── fetch_nixpkgs.sh
4.0K   │   └── fetch_alpine_git.sh
 15M   ├─┬ bincache
 14M   │ ├─┬ data
3.6M   │ │ ├── x86_64-Linux.json
3.0M   │ │ ├── x86_64-Linux.db
2.8M   │ │ ├── aarch64-Linux.json
2.4M   │ │ ├── aarch64-Linux.db
356K   │ │ ├── x86_64-Linux.db.cba
312K   │ │ ├── x86_64-Linux.json.cba
300K   │ │ ├── aarch64-Linux.db.cba
280K   │ │ ├── x86_64-Linux.db.zstd
272K   │ │ ├── x86_64-Linux.db.xz
268K   │ │ ├── aarch64-Linux.json.cba
264K   │ │ ├── x86_64-Linux.json.xz
252K   │ │ ├── x86_64-Linux.json.zstd
236K   │ │ ├── aarch64-Linux.db.zstd
228K   │ │ ├── aarch64-Linux.db.xz
220K   │ │ ├── aarch64-Linux.json.xz
208K   │ │ ├── aarch64-Linux.json.zstd
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
4.1M   ├─┬ soarpkgs
3.8M   │ ├─┬ data
820K   │ │ ├── INDEX.json
820K   │ │ ├── BACKAGE.json
792K   │ │ ├── pub_issues_binaries.txt
444K   │ │ ├── INDEX.db
300K   │ │ ├── pub_issues_packages.txt
124K   │ │ ├── INDEX.json.cba
 92K   │ │ ├── GH_REPO.md
 88K   │ │ ├── INDEX.json.zstd
 88K   │ │ ├── INDEX.json.xz
 84K   │ │ ├── INDEX.db.cba
 72K   │ │ ├── INDEX.db.zstd
 68K   │ │ ├── INDEX.db.xz
 28K   │ │ ├── GH_REPO_ARCHIVED.md
 20K   │ │ ├── URLS.txt
 20K   │ │ ├── DIFF_bincache.json
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
324K   │ └─┬ scripts
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
8.0K   │   ├── scrape_pub_issues_packages.sh
8.0K   │   ├── scrape_pub_issues_binaries.sh
8.0K   │   ├── repology_fetcher.sh
4.0K   │   ├── gen_ghcr_backage.sh
4.0K   │   └── gen_diff.sh
520K   ├─┬ pkgcache
404K   │ ├─┬ data
116K   │ │ ├── x86_64-Linux.db
100K   │ │ ├── x86_64-Linux.json
 20K   │ │ ├── aarch64-Linux.db
 16K   │ │ ├── x86_64-Linux.db.cba
 12K   │ │ ├── x86_64-Linux.json.zstd
 12K   │ │ ├── x86_64-Linux.json.xz
 12K   │ │ ├── x86_64-Linux.json.cba
 12K   │ │ ├── x86_64-Linux.db.zstd
 12K   │ │ ├── x86_64-Linux.db.xz
 12K   │ │ ├── aarch64-Linux.json
4.0K   │ │ ├── x86_64-Linux.json.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.json.xz.bsum
4.0K   │ │ ├── x86_64-Linux.json.bsum
4.0K   │ │ ├── x86_64-Linux.db.zstd.bsum
4.0K   │ │ ├── x86_64-Linux.db.xz.bsum
4.0K   │ │ ├── x86_64-Linux.db.bsum
4.0K   │ │ ├── aarch64-Linux.json.zstd.bsum
4.0K   │ │ ├── aarch64-Linux.json.zstd
4.0K   │ │ ├── aarch64-Linux.json.xz.bsum
4.0K   │ │ ├── aarch64-Linux.json.xz
4.0K   │ │ ├── aarch64-Linux.json.cba
4.0K   │ │ ├── aarch64-Linux.json.bsum
4.0K   │ │ ├── aarch64-Linux.db.zstd.bsum
4.0K   │ │ ├── aarch64-Linux.db.zstd
4.0K   │ │ ├── aarch64-Linux.db.xz.bsum
4.0K   │ │ ├── aarch64-Linux.db.xz
4.0K   │ │ ├── aarch64-Linux.db.cba
4.0K   │ │ ├── aarch64-Linux.db.bsum
4.0K   │ │ └── TOTAL.json
112K   │ └─┬ scripts
 52K   │   ├─┬ archived
 48K   │   │ └── healthchecks.yaml
 28K   │   ├── gen_meta_x86_64-Linux.sh
 28K   │   └── gen_meta_aarch64-Linux.sh
196K   ├─┬ web
192K   │ └─┬ cloudflare
112K   │   ├── package-lock.json
 56K   │   ├─┬ src
 16K   │   │ ├── static.ts
 16K   │   │ ├── config.ts
 12K   │   │ ├── render.ts
4.0K   │   │ ├── types.ts
4.0K   │   │ └── index.ts
 12K   │   ├── tsconfig.json
4.0K   │   ├── wrangler.toml
4.0K   │   └── package.json
 16K   ├─┬ workers
 12K   │ └─┬ omni-redirector-pkgforge-dev
8.0K   │   └── worker.js
4.0K   ├── README.md
4.0K   └── LICENSE
```
