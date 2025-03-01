import { svgs, cssStyle, defaultFavicon } from './static';
import { SiteConfig } from './types';

export var renderTemplFull = (files: R2Object[], folders: string[], path: string, config: SiteConfig) => {
    return `<!DOCTYPE html>
    <html>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500&display=swap" rel="stylesheet">
    <head>
        <link rel="icon" href="${config.favicon ?? defaultFavicon}" type="image/png">
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${renderTemplTitle(config.name, path)}</title>
        ${cssStyle}
    </head>
    <body>
    ${svgs}
    <header>
        <h1>
            
                <a href="/">${config.name}</a> /
                <!-- breadcrumbs start -->${renderTemplBreadcrumbs(path)}
        </h1>
    </header>
    <main>
            <div class="listing">
                <table aria-describedby="summary">
                    <thead>
                    <tr>
                        <th class="hideable"></th>
                        <th class="name">Name</th>
                        <th class="description">Description</th>
                        <th class="size">Size</th>
                        <th class="date hideable">Modified</th>
                        <th class="hideable"></th>
                    </tr>
                    </thead>
                    <tbody>
                    ${path === '/' ? '' : renderGoUp(path)}
    <!-- folders start -->${renderTemplFolders(folders, config)}
    <!-- files start -->${renderTemplFiles(files, config)}
    </tbody>
                </table>
            </div>
        </main>
        <footer>
            ${generateFooter(config, path)}
        </footer>
    </body>
</html>
    `;
};

var renderGoUp = (path: string) => {
    if(path !== '') {
         return `
         <tr>
                        <td class="hideable"></td>
                        <td class="goup">
                            <a href="..">
                                Go up
                            </a>
                        </td>
                        <td class="description">&mdash;</td>
                        <td class="size">&mdash;</td>
                        <td class="date hideable">&mdash;</td>
                        <td class="hideable"></td>
                    </tr>`;
    }
    return '';
};

var renderTemplTitle = (siteTitle:string, path: string) => {
    if(path === '/') {
        return siteTitle
    }
    path = path.slice(0, -1);
    return `${siteTitle} | ${cleanTitle(path)}`;
};

var cleanTitle = (path: string) => {
    var parts = path.split('/')
    // remove the empty strings
    parts = parts.filter((part) => part !== '')
    return parts[parts.length - 1];
};

var renderTemplBreadcrumbs = (path: string) => {
    const parts = path.split('/');
    var output = '';
    var currentPath = '/';
    for (var i = 0; i < parts.length; i++) {
        if (parts[i] === '') continue;
        currentPath += parts[i] + '/';
        output += `<a href="${currentPath}">${parts[i]}</a> / `;
    }
    console.log(output);
    return output;
};

var renderTemplFolders = (folders: string[], siteConfig: SiteConfig) => {
    if (typeof folders === 'undefined') return '';
    var output = '';
    for (var i = 0; i < folders.length; i++) {
        output += `<tr class="file ">
                            <td class="hideable"></td>
                            <td class="name"><a href="/${folders[i]}"><svg width="1.5em" height="1em" version="1.1" viewBox="0 0 317 259"><use xlink:href="#folder"></use></svg><span class="name">${cleanFolderName(folders[i])}</span></a></td>
                            <td class="description">${findDesp(siteConfig, '/' + folders[i].slice(0, -1), true) ?? '&mdash;'}</td>
                            <td class="size">&mdash;</td>
                            <td class="date hideable">&mdash;</td>
                            <td class="hideable"></td>
                        </tr>`;
    }
    return output;
};

var renderTemplFiles = (files: R2Object[], siteConfig: SiteConfig) => {
    if (typeof files === 'undefined') return '';
    var output = '';
    for (var i = 0; i < files.length; i++) {
       // Trim any leading/trailing whitespace just in case 
        let fileKey = files[i].key.trim();
       //Hide logfiles, dotfiles & upx
        //if (files[i].key.endsWith('log.txt') ||
        //    /\/\.[^/]+$/.test(files[i].key) ||
        //   files[i].key.endsWith('AM.txt') || 
        //   files[i].key.endsWith('APPS_INFO.txt') ||
        //   files[i].key.endsWith('APP_IDS.txt') ||
        //   files[i].key.endsWith('LATEST.json') ||
        //   files[i].key.endsWith('POPULAR.json') ||
        //   files[i].key.endsWith('TRENDING.json') ||
        //   files[i].key.endsWith('.bsum') ||
        //   files[i].key.endsWith('.capnp') ||
        //   files[i].key.endsWith('.db') ||
        //   files[i].key.endsWith('.gif') ||
        //   files[i].key.endsWith('.jpeg') ||
        //   files[i].key.endsWith('.jpg') ||
        //   files[i].key.endsWith('.md') ||
        //   files[i].key.endsWith('.png') ||
        //   files[i].key.endsWith('.shasum') ||
        //   files[i].key.endsWith('.svg') ||
        //   files[i].key.endsWith('.upx') ||
        //   files[i].key.endsWith('.webp') ||
        //   files[i].key.endsWith('.xml') ||
        //   files[i].key.endsWith('.xz') ||
        //   files[i].key.endsWith('.zstd')) {
        //continue;
        //}
       //Set Icons 
        let icon;
        if (files[i].key.endsWith('.AppImage') || files[i].key.endsWith('.FlatImage') || files[i].key.endsWith('.RunImage') || files[i].key.endsWith('.no_strip')) {    
            icon = '📀';
        } else if (files[i].key.endsWith('.json') || files[i].key.endsWith('.toml') || files[i].key.endsWith('.yaml') || files[i].key.endsWith('.yml')) {
            icon = '🧬';
        } else if (files[i].key.endsWith('.txt')) {
            icon = '📄';
        } else if (files[i].key.endsWith('.7z') || files[i].key.endsWith('.tar') || files[i].key.endsWith('.rar')) {
            icon = '🧰';
        } else {
            icon = '📦';
        }
        output += `<tr class="file">
            <td class="hideable"></td>
            <td class="name"><a href="/${files[i].key}">${icon}<span class="name">${cleanFileName(files[i].key)}</span></a></td>
            <td class="description">${findDesp(siteConfig, '/' + files[i].key, true) ?? "&mdash;"}</td>
            <td class="size">${humanFileSize(files[i].size)}</td>
            <td class="date hideable"><time datetime="${files[i].uploaded.toUTCString()}">${files[i].uploaded.toJSON()}</time></td>
            <td class="actions">
                <div class="action-buttons">
                    <a class="download-button" href="/${files[i].key}" download title="Download Raw File">⬇️</a>
                </div>
            </td>
        </tr>`;
    };
    return output;
}

var cleanFileName = (name: string) => {
    return name.split('/').slice(-1).pop()!;
};

var cleanFolderName = (name: string) => {
    return name.slice(0, -1).split('/').slice(-1).pop()!;
};

// taken from https://stackoverflow.com/questions/10420352/converting-file-size-in-bytes-to-human-readable-string
var humanFileSize = (bytes: number, si = false, dp = 1) => {
  const thresh = si ? 1000 : 1024;

  if (Math.abs(bytes) < thresh) {
    return bytes + ' B';
  }

  const units = si ? ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'] : ['KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];
    let u = -1;
    const r = 10 ** dp;

  do {
    bytes /= thresh;
    ++u;
  } while (Math.round(Math.abs(bytes) * r) / r >= thresh && u < units.length - 1);


  return bytes.toFixed(dp) + ' ' + units[u];
};

function findDesp(siteConfig: SiteConfig, path: string, exact: boolean): string | undefined {
    if (exact) {
        return siteConfig.desp[path];
    }
    const keys = Object.keys(siteConfig.desp);
    // find the longest match
    let longestMatch = '/';
    for (const key of keys) {
        if (path.startsWith(key) && key.length > longestMatch.length) {
            longestMatch = key;
        }
    }
    const desp = siteConfig.desp[longestMatch];
    return desp;
}

function generateFooter(siteConfig: SiteConfig, path: string): string {
    /// Footer includes:
    /// - desp of current path, use the most specific entry
    /// - legal info, if any
    /// - reference to gitea download site code, as the inspiration of this project
    
    let contents: string[] = [];
    const desp = findDesp(siteConfig, path, false);
    if (desp) {
        contents.push(`<p>${desp}</p>`);
    }
    if (siteConfig.legalInfo) {
        contents.push(`<p>${siteConfig.legalInfo}</p>`);
    }
    if (siteConfig.showPoweredBy) {
        contents.push(`<p>Powered by <a href="https://github.com/cmj2002/r2-dir-list">r2-dir-list</a></p>`);
    }
    return contents.join('');
}
