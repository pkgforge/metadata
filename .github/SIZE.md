```mathematica
187M └─┬ main
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
220K   │ │ ├── FLATPAK_TRENDING.json
 72K   │ │ ├── FLATPAK_APP_IDS.txt
 20K   │ │ ├── CATEGORY.json
4.0K   │ │ └── CATEGORY.md
 60K   │ └─┬ scripts
 12K   │   ├── fetch_alpine_pkg.sh
8.0K   │   ├── fetch_homebrew.sh
8.0K   │   ├── fetch_flatpak.sh
8.0K   │   ├── fetch_debian.sh
8.0K   │   ├── fetch_archlinux.sh
4.0K   │   ├── fetch_pkgsrc.sh
4.0K   │   ├── fetch_nixpkgs.sh
4.0K   │   └── fetch_alpine_git.sh
 10M   ├─┬ bincache
 10M   │ ├─┬ data
2.4M   │ │ ├── x86_64-Linux.json
2.1M   │ │ ├── x86_64-Linux.db
2.0M   │ │ ├── aarch64-Linux.json
1.6M   │ │ ├── aarch64-Linux.db
236K   │ │ ├── x86_64-Linux.db.cba
200K   │ │ ├── aarch64-Linux.db.cba
196K   │ │ ├── x86_64-Linux.json.cba
184K   │ │ ├── x86_64-Linux.db.zstd
180K   │ │ ├── x86_64-Linux.db.xz
172K   │ │ ├── x86_64-Linux.json.xz
172K   │ │ ├── aarch64-Linux.json.cba
164K   │ │ ├── x86_64-Linux.json.zstd
160K   │ │ ├── aarch64-Linux.db.zstd
156K   │ │ ├── aarch64-Linux.db.xz
148K   │ │ ├── aarch64-Linux.json.xz
144K   │ │ ├── aarch64-Linux.json.zstd
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
8.8M   ├─┬ soarpkgs
8.6M   │ ├─┬ data
2.8M   │ │ ├── INDEX.json
1.7M   │ │ ├── INDEX.db
780K   │ │ ├── pub_issues_binaries.txt
752K   │ │ ├── BACKAGE.json
420K   │ │ ├── INDEX.json.cba
376K   │ │ ├── GH_REPO.md
360K   │ │ ├── INDEX.db.cba
300K   │ │ ├── pub_issues_packages.txt
284K   │ │ ├── INDEX.json.xz
276K   │ │ ├── INDEX.json.zstd
276K   │ │ ├── INDEX.db.zstd
264K   │ │ ├── INDEX.db.xz
 76K   │ │ ├── URLS.txt
 28K   │ │ ├── GH_REPO_ARCHIVED.md
4.0K   │ │ ├── TOTAL.json
4.0K   │ │ ├── INDEX.json.zstd.bsum
4.0K   │ │ ├── INDEX.json.xz.bsum
4.0K   │ │ ├── INDEX.json.bsum
4.0K   │ │ ├── INDEX.db.zstd.bsum
4.0K   │ │ ├── INDEX.db.xz.bsum
4.0K   │ │ └── INDEX.db.bsum
176K   │ └─┬ scripts
 60K   │   ├─┬ archived
 36K   │   │ ├── sbuild_runner.sh
 20K   │   │ └── sbuild_linter.sh
 28K   │   ├── sbuild_creator.sh
 28K   │   ├── github_fetcher.sh
 28K   │   ├── gen_meta.sh
8.0K   │   ├── scrape_pub_issues_packages.sh
8.0K   │   ├── scrape_pub_issues_binaries.sh
8.0K   │   ├── repology_fetcher.sh
4.0K   │   └── gen_ghcr_backage.sh
128K   ├─┬ web
124K   │ └─┬ cloudflare
 56K   │   ├─┬ src
 16K   │   │ ├── static.ts
 16K   │   │ ├── config.ts
 12K   │   │ ├── render.ts
4.0K   │   │ ├── types.ts
4.0K   │   │ └── index.ts
 44K   │   ├── package-lock.json
 12K   │   ├── tsconfig.json
4.0K   │   ├── wrangler.toml
4.0K   │   └── package.json
 16K   ├─┬ workers
 12K   │ └─┬ omni-redirector-pkgforge-dev
8.0K   │   └── worker.js
 12K   ├─┬ aarch64-Linux
4.0K   │ ├── x86_64-Linux.db.xz
4.0K   │ └── aarch64-Linux.db.xz
8.0K   ├─┬ pkgcache
4.0K   │ └── data
4.0K   ├── README.md
4.0K   └── LICENSE
```
