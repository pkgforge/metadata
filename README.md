<div align="center">

[discord-shield]: https://img.shields.io/discord/1313385177703256064?logo=%235865F2&label=Discord
[discord-url]: https://discord.gg/djJUs48Zbu
[stars-url]: https://github.com/pkgforge/soar/stargazers
[issues-shield]: https://img.shields.io/github/issues/pkgforge/metadata.svg
[issues-url]: https://github.com/pkgforge/metadata/issues
[license-shield]: https://img.shields.io/github/license/pkgforge/metadata.svg
[license-url]: https://github.com/pkgforge/metadata/blob/main/LICENSE
[doc-shield]: https://img.shields.io/badge/docs.pkgforge.dev-blue
[doc-url]: https://docs.pkgforge.dev/repositories

[![Discord][discord-shield]][discord-url]
[![Documentation][doc-shield]][doc-url]
[![Issues][issues-shield]][issues-url]
[![License: MIT][license-shield]][license-url]
</div>

<p align="center">
    <a href="https://github.com/pkgforge/soar">
        <img src="https://soar.pkgforge.dev/gif?tmp.uCv7fjCuxO=tmp.NBMWcSgODK" alt="soar-list" width="650">
    </a><br> 
    <b><strong> <a href="https://meta.pkgforge.dev">Package Forge Metadata</a></code></strong></b>
    <br>
</p>

---
> [!WARNING]
> This repo is 100% Automated & too many commits happen too often, this is intentional<br>
> Use Sparse Checkout & Blob Filter while cloning this Repo<br>
> We store data here as blob rather than Github Release to avoid rate limits, this is intentional<br>
> Every 5000 commits, we [hard reset](https://github.com/pkgforge/metadata/actions/workflows/reset_commits.yaml) this repo, to checkout previous code, please check the [releases](https://github.com/pkgforge/metadata/tags)<br>

#### Counts
> - <img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/TOTAL_INSTALLABLE.json&query=$[6].total&label=Total (Prebuilt)&labelColor=orange&style=flat" alt="Total" />
> - <img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/TOTAL_ALL.json&query=$[7].total&label=Total (Prebuilt|SBUILD)&labelColor=orange&style=flat" alt="Total" />
> - [Official Repos](https://github.com/pkgforge/soarpkgs)
> > - <a href="https://pkgs.pkgforge.dev/?repo=bincache_arm64"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/data/TOTAL.json&query=$[1].total&label=Bincache (aarch64-Linux)&labelColor=orange&style=flat&link=https://pkgs.pkgforge.dev/?repo=bincache_arm64" alt="Binaries" /></a>
> > - <a href="https://pkgs.pkgforge.dev"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/data/TOTAL.json&query=$[0].total&label=Bincache (x86_64-Linux)&labelColor=orange&style=flat&link=https://pkgs.pkgforge.dev" alt="Binaries" /></a> 
> > - <a href="https://pkgs.pkgforge.dev"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/bincache/data/TOTAL.json&query=$[2].total&label=Bincache (Total)&labelColor=orange&style=flat&link=https://pkgs.pkgforge.dev" alt="Binaries" /></a>
> > - <a href="https://pkgs.pkgforge.dev/?repo=pkgcache_arm64"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/data/TOTAL.json&query=$[1].total&label=Pkgcache (aarch64-Linux)&labelColor=orange&style=flat&link=https://pkgs.pkgforge.dev/?repo=pkgcache_arm64" alt="Packages" /></a>
> > - <a href="https://pkgs.pkgforge.dev/?repo=pkgcache_amd64"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/data/TOTAL.json&query=$[0].total&label=Pkgcache (x86_64-Linux)&labelColor=orange&style=flat&link=https://pkgs.pkgforge.dev/?repo=pkgcache_amd64" alt="Packages" /></a> 
> > - <a href="https://pkgs.pkgforge.dev"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/pkgcache/data/TOTAL.json&query=$[2].total&label=Pkgcache (Total)&labelColor=orange&style=flat&link=https://pkgs.pkgforge.dev" alt="Packages" /></a>
> - [External Repos](https://docs.pkgforge.dev/repositories/external)
> > - <a href="https://meta.pkgforge.dev/external/am/aarch64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/am/data/TOTAL.json&query=$[1].total&label=AM (aarch64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/am/aarch64-Linux.json" alt="am" /></a>
> > - <a href="https://meta.pkgforge.dev/external/am/x86_64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/am/data/TOTAL.json&query=$[0].total&label=AM (x86_64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/am/x86_64-Linux.json" alt="am" /></a>
> > - <a href="https://meta.pkgforge.dev/external/am/"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/am/data/TOTAL.json&query=$[2].total&label=AM (Total)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/am/" alt="am" /></a>
> > - <a href="https://meta.pkgforge.dev/external/cargo-bins/aarch64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/cargo-bins/data/TOTAL.json&query=$[1].total&label=cargo-bins (aarch64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/cargo-bins/aarch64-Linux.json" alt="cargo-bins" /></a>
> > - <a href="https://meta.pkgforge.dev/external/cargo-bins/x86_64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/cargo-bins/data/TOTAL.json&query=$[0].total&label=cargo-bins (x86_64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/cargo-bins/x86_64-Linux.json" alt="cargo-bins" /></a>
> > - <a href="https://meta.pkgforge.dev/external/cargo-bins/"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/cargo-bins/data/TOTAL.json&query=$[2].total&label=cargo-bins (Total)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/cargo-bins/" alt="cargo-bins" /></a>
> > - <a href="https://meta.pkgforge.dev/external/appimage.github.io/aarch64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimage.github.io/data/TOTAL.json&query=$[1].total&label=appimage.github.io (aarch64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/appimage.github.io/aarch64-Linux.json" alt="appimage.github.io" /></a>
> > - <a href="https://meta.pkgforge.dev/external/appimage.github.io/x86_64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimage.github.io/data/TOTAL.json&query=$[0].total&label=appimage.github.io (x86_64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/appimage.github.io/x86_64-Linux.json" alt="appimage.github.io" /></a>
> > - <a href="https://meta.pkgforge.dev/external/appimage.github.io/"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimage.github.io/data/TOTAL.json&query=$[2].total&label=appimage.github.io (Total)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/appimage.github.io/" alt="appimage.github.io" /></a>
> > - <a href="https://meta.pkgforge.dev/external/appimagehub/aarch64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimagehub/data/TOTAL.json&query=$[1].total&label=appimagehub (aarch64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/appimagehub/aarch64-Linux.json" alt="appimagehub" /></a>
> > - <a href="https://meta.pkgforge.dev/external/appimagehub/x86_64-Linux.json"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimagehub/data/TOTAL.json&query=$[0].total&label=appimagehub (x86_64-Linux)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/appimagehub/x86_64-Linux.json" alt="appimagehub" /></a>
> > - <a href="https://meta.pkgforge.dev/external/appimagehub/"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/external/appimagehub/data/TOTAL.json&query=$[2].total&label=appimagehub (Total)&labelColor=orange&style=flat&link=https://meta.pkgforge.dev/external/appimagehub/" alt="appimagehub" /></a>
> - [SBUILDS](https://github.com/pkgforge/soarpkgs)
> > - <a href="https://github.com/pkgforge/soarpkgs/tree/main/binaries"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/data/TOTAL.json&query=$[0].total&label=Binaries&labelColor=orange&style=flat&link=https://github.com/pkgforge/soarpkgs/tree/main/binaries" alt="Binaries" /></a>
> > - <a href="https://github.com/pkgforge/soarpkgs/tree/main/packages"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/data/TOTAL.json&query=$[1].total&label=Packages&labelColor=orange&style=flat&link=https://github.com/pkgforge/soarpkgs/tree/main/packages" alt="Packages" /></a> 
> > - <a href="https://github.com/pkgforge/soarpkgs/tree/main"><img src="https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/data/TOTAL.json&query=$[2].total&label=Total&labelColor=orange&style=flat&link=https://github.com/pkgforge/soarpkgs/tree/main" alt="Total" /></a>
