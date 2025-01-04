import { Env, SiteConfig } from './types';

const commonDescriptions = {
    // Description For Footer on main Page
    '/': "📦 <a href='https://github.com/pkgforge/soar'><b>🤖 Automated Metadata Files</b></a> 🧬 : <a href='https://github.com/pkgforge/soar'><b>Repo</b></a> <a href='https://github.com/pkgforge/metadata'>Source</a>",
    // bincache
    '/bincache': "<a href='https://docs.pkgforge.dev/repositories/bincache/metadata'>🧬 JSON Metadata For Bincache</a>",
    //aarch64-Linux
    '/bincache/aarch64-Linux.json': "🧬 JSON Metadata For 📦 Package Managers & 🗿 Humans (aarch64-Linux)",
    '/bincache/aarch64-Linux.json.bsum': "🔐 B3SUM (aarch64-Linux)",
    '/bincache/aarch64-Linux.json.cba': "🗃️ Compressed Bita JSON Metadata (aarch64-Linux)",
    '/bincache/aarch64-Linux.json.xz': "🗃️ Compressed LZMA JSON Metadata (aarch64-Linux)",
    '/bincache/aarch64-Linux.json.xz.bsum': "🔐 B3SUM (aarch64-Linux)",
    '/bincache/aarch64-Linux.json.zstd': "🗃️ Compressed ZSTD JSON Metadata (aarch64-Linux)",
    '/bincache/aarch64-Linux.json.zstd.bsum': "🔐 B3SUM (aarch64-Linux)",
    //x86_64-Linux
    '/bincache/x86_64-Linux.json': "🧬 JSON Metadata For 📦 Package Managers & 🗿 Humans (x86_64-Linux)",
    '/bincache/x86_64-Linux.json.bsum': "🔐 B3SUM (x86_64-Linux)",
    '/bincache/x86_64-Linux.json.cba': "🗃️ Compressed Bita JSON Metadata (x86_64-Linux)",
    '/bincache/x86_64-Linux.json.xz': "🗃️ Compressed LZMA JSON Metadata (x86_64-Linux)",
    '/bincache/x86_64-Linux.json.xz.bsum': "🔐 B3SUM (x86_64-Linux)",
    '/bincache/x86_64-Linux.json.zstd': "🗃️ Compressed ZSTD JSON Metadata (x86_64-Linux)",
    '/bincache/x86_64-Linux.json.zstd.bsum': "🔐 B3SUM (x86_64-Linux)",
};

const baseConfig: Omit<SiteConfig, 'name' | 'bucket'> = {
    desp: commonDescriptions,
    showPoweredBy: false, // Set to false to hide the "Powered by" information at footer
    /// Decode URI when listing objects, useful when you have space or special characters in object key
    /// Recommended to enable it for new installations, but default to false for backward compatibility
    decodeURI: false, 
    /// [Optional] Legal information of your website
    /// Your local government (for example Mainland China) may requires you to put some legal info at footer
    /// and you can put it here.
    /// It will be treated as raw HTML.
    // legalInfo: "Legal information of your website",

    /// [Optional] **Dangerous**: Enabling it may disrupte the normal reading of existing object
    /// By default, r2-dir-list will not list directory if the request path is a object to prevent disrupting
    /// the normal reading of existing object.
    /// Enabling this will allow r2-dir-list to list directory even if the request path is a 0-byte object.
    /// Do not use them unless you know what you are doing!
    // dangerousOverwriteZeroByteObject: false,

    /// [Optional] favicon, should be a URL to **PNG IMAGE**. Default to Cloudflare R2's logo
    favicon: 'https://pub.ajam.dev/images/favicons/cf_r2_favicon.png',
};

export function getSiteConfig(env: Env, domain: string): SiteConfig | undefined {
    const configs: {[domain: string]: SiteConfig} = {
        'bin.ajam.dev': {
            ...baseConfig,
            name: "bin",
            bucket: env.BUCKET_bucketname,
        },
        'bin.pkgforge.dev': {
            ...baseConfig,
            name: "bin",
            bucket: env.BUCKET_bucketname,
        },
    };
    return configs[domain];
}
