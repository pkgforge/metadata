```mathematica
269M └─┬ main
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
292K   │ │ ├── PPKG.json
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
 84M   ├─┬ bincache
 83M   │ ├─┬ data
 15M   │ │ ├── x86_64-Linux.json
 14M   │ │ ├── aarch64-Linux.json
 13M   │ │ ├── x86_64-Linux.db
 12M   │ │ ├── aarch64-Linux.db
7.8M   │ │ ├── x86_64-Linux.sdb
7.5M   │ │ ├── aarch64-Linux.sdb
976K   │ │ ├── x86_64-Linux.db.cba
920K   │ │ ├── aarch64-Linux.db.cba
916K   │ │ ├── x86_64-Linux.json.cba
876K   │ │ ├── x86_64-Linux.sdb.cba
852K   │ │ ├── aarch64-Linux.sdb.cba
832K   │ │ ├── aarch64-Linux.json.cba
660K   │ │ ├── x86_64-Linux.db.zstd
656K   │ │ ├── x86_64-Linux.sdb.zstd
648K   │ │ ├── x86_64-Linux.db.xz
632K   │ │ ├── aarch64-Linux.db.zstd
628K   │ │ ├── aarch64-Linux.sdb.zstd
616K   │ │ ├── aarch64-Linux.db.xz
600K   │ │ ├── x86_64-Linux.sdb.xz
584K   │ │ ├── x86_64-Linux.json.zstd
576K   │ │ ├── aarch64-Linux.sdb.xz
564K   │ │ ├── x86_64-Linux.json.xz
556K   │ │ ├── aarch64-Linux.json.zstd
536K   │ │ ├── aarch64-Linux.json.xz
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
6.6M   │ ├─┬ data
1.6M   │ │ ├── INDEX.json
1.2M   │ │ ├── BACKAGE.json
848K   │ │ ├── INDEX.db
776K   │ │ ├── pub_issues_binaries.txt
328K   │ │ ├── DIFF_bincache_aarch64-Linux.json
308K   │ │ ├── DIFF_bincache_x86_64-Linux.json
304K   │ │ ├── pub_issues_packages.txt
240K   │ │ ├── INDEX.json.cba
152K   │ │ ├── INDEX.json.zstd
152K   │ │ ├── INDEX.json.xz
144K   │ │ ├── INDEX.db.cba
144K   │ │ ├── GH_REPO.md
120K   │ │ ├── INDEX.db.zstd
112K   │ │ ├── INDEX.db.xz
 56K   │ │ ├── DIFF_pkgcache_x86_64-Linux.json
 32K   │ │ ├── URLS.txt
 28K   │ │ ├── GH_REPO_ARCHIVED.md
 28K   │ │ ├── DIFF_pkgcache_aarch64-Linux.json
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
4.5M   ├─┬ external
4.5M   │ └─┬ appimage.github.io
4.5M   │   ├─┬ data
1.7M   │   │ ├── x86_64-Linux.json
1.3M   │   │ ├── x86_64-Linux.db
212K   │   │ ├── x86_64-Linux.db.cba
188K   │   │ ├── x86_64-Linux.json.cba
180K   │   │ ├── aarch64-Linux.json
168K   │   │ ├── x86_64-Linux.db.zstd
164K   │   │ ├── x86_64-Linux.db.xz
156K   │   │ ├── aarch64-Linux.db
148K   │   │ ├── x86_64-Linux.json.zstd
144K   │   │ ├── x86_64-Linux.json.xz
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
4.0K   │   │ └── aarch64-Linux.db.bsum
 32K   │   └─┬ scripts
 28K   │     └── gen_meta.sh
2.6M   ├─┬ pkgcache
2.5M   │ ├─┬ data
528K   │ │ ├── x86_64-Linux.sdb
504K   │ │ ├── x86_64-Linux.db
484K   │ │ ├── x86_64-Linux.json
156K   │ │ ├── aarch64-Linux.sdb
116K   │ │ ├── aarch64-Linux.db
112K   │ │ ├── aarch64-Linux.json
 60K   │ │ ├── x86_64-Linux.sdb.cba
 56K   │ │ ├── x86_64-Linux.db.cba
 52K   │ │ ├── x86_64-Linux.sdb.zstd
 52K   │ │ ├── x86_64-Linux.json.cba
 48K   │ │ ├── x86_64-Linux.sdb.xz
 48K   │ │ ├── x86_64-Linux.db.zstd
 48K   │ │ ├── x86_64-Linux.db.xz
 44K   │ │ ├── x86_64-Linux.json.zstd
 44K   │ │ ├── x86_64-Linux.json.xz
 16K   │ │ ├── aarch64-Linux.sdb.zstd
 16K   │ │ ├── aarch64-Linux.sdb.xz
 16K   │ │ ├── aarch64-Linux.sdb.cba
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
288K   ├─┬ web
152K   │ ├─┬ assets
 40K   │ │ ├── icon_package_multi.png
 36K   │ │ ├── icon_server.png
 28K   │ │ ├── icon_database.png
 24K   │ │ ├── icon_config_multi.png
 20K   │ │ └── icon_json.png
132K   │ └─┬ cloudflare
 72K   │   ├─┬ src
 32K   │   │ ├── config.ts
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
