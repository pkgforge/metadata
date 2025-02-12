// Domains
const SOAR_DEFAULT = 'https://soar.qaidvoid.dev';
const BINCACHE_DEFAULT = 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main';
const PKGCACHE_DEFAULT = 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main';
const SOARPKGS_DEFAULT = 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main';

// Pre-compile domain regex patterns and their configurations
const DOMAIN_CONFIG = new Map([
  [
    /^https?:\/\/hf\.bincache\.pkgforge\.dev/i,
    {
      defaultTarget: BINCACHE_DEFAULT,
      pathMappings: new Map([
        //['aarch64', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/aarch64-Linux'],
        ['aarch64-linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/aarch64-Linux'],
        ['aarch64-Linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/aarch64-Linux'],
        ['arm64_linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/aarch64-Linux'],
        ['arm64_Linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/aarch64-Linux'],
        //['x86_64', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/x86_64-Linux'],
        ['x86_64-linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/x86_64-Linux'],
        ['x86_64-Linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/x86_64-Linux'],
        ['amd64_linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/x86_64-Linux'],
        ['amd64_Linux', 'https://huggingface.co/datasets/pkgforge/bincache/resolve/main/x86_64-Linux']
      ])
    }
  ],
  [
    /^https?:\/\/hf\.pkgcache\.pkgforge\.dev/i,
    {
      defaultTarget: PKGCACHE_DEFAULT,
      pathMappings: new Map([
        //['aarch64', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/aarch64-Linux'],
        ['aarch64-linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/aarch64-Linux'],
        ['aarch64-Linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/aarch64-Linux'],
        ['arm64_linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/aarch64-Linux'],
        ['arm64_Linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/aarch64-Linux'],
        //['x86_64', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/x86_64-Linux'],
        ['x86_64-linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/x86_64-Linux'],
        ['x86_64-Linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/x86_64-Linux'],
        ['amd64_linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/x86_64-Linux'],
        ['amd64_Linux', 'https://huggingface.co/datasets/pkgforge/pkgcache/resolve/main/x86_64-Linux']
      ])
    }
  ],
  [
    /^https?:\/\/soarpkgs\.pkgforge\.dev/i,
    {
      defaultTarget: SOARPKGS_DEFAULT,
      pathMappings: new Map([
        ['dummy-dummy', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/dummy-dummy']
      //  ['aarch64', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/aarch64-Linux'],
      //  ['aarch64-linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/aarch64-Linux'],
      //  ['aarch64-Linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/aarch64-Linux'],
      //  ['arm64_linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/aarch64-Linux'],
      //  ['arm64_Linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/aarch64-Linux'],
      //  ['x86_64', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/x86_64-Linux'],
      //  ['x86_64-linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/x86_64-Linux'],
      //  ['x86_64-Linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/x86_64-Linux'],
      //  ['amd64_linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/x86_64-Linux'],
      //  ['amd64_Linux', 'https://raw.githubusercontent.com/pkgforge/soarpkgs/refs/heads/main/x86_64-Linux']     
      ])
    }
  ],
  [
    /^https?:\/\/soar\.pkgforge\.dev/i,
    {
      defaultTarget: SOAR_DEFAULT,
      pathMappings: new Map([
        ['docs', 'https://soar.qaidvoid.dev'],
       //soar list | wc -l 
        ['gif', 'https://meta.pkgforge.dev/misc/list.gif'],
       // soar list $repo + soar list wc -l
       ['detailed', 'https://meta.pkgforge.dev/misc/list_detailed.gif'],
       // soar --version
       ['version', 'https://meta.pkgforge.dev/misc/version.gif']
      ])
    }
  ]
]);

// Generate a random string
function generateRandomString(length = 16) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// Check if URL is a raw download request
function isRawDownloadRequest(url) {
  return url.hostname === 'pkgs.pkgforge.dev' && url.pathname.endsWith('/raw.dl');
}

// Extract redirect URL from HTML content
async function extractRedirectUrl(html) {
  const match = html.match(/content="0;url=([^"]+)"/);
  if (match && match[1]) {
    return match[1].replace(/&#38;/g, '&'); // Replace HTML entity with &
  }
  return null;
}

// Unified handler for all domains
function handleDomain(pathname, search, config) {
  const { defaultTarget, pathMappings } = config;

  // Check for specific path matches first
  for (const [prefix, target] of pathMappings) {
    if (pathname.startsWith('/' + prefix + '/')) {
      const remainingPath = pathname.slice(prefix.length + 2); // +2 for both slashes
      const baseUrl = target.endsWith('/') ? target.slice(0, -1) : target;
      return `${baseUrl}/${remainingPath}${search}`;
    }
    
    // Special handling for 'gif' path
    if ((prefix === 'gif' || prefix === 'detailed' || prefix === 'version') && pathname === '/' + prefix) {
      const randomStr = generateRandomString();
      return `${target}?${randomStr}=${randomStr}`;
    }
  }
  
  // Default fallback
  return `${defaultTarget}${pathname}${search}`;
}

// Handle Incoming Requests
async function handleRequest(request) {
  const url = new URL(request.url);
  
  // Check for raw download requests first
  if (isRawDownloadRequest(url)) {
    try {
      // Fetch the original URL
      const response = await fetch(url);
      const html = await response.text();
      
      // Extract the redirect URL
      const redirectUrl = await extractRedirectUrl(html);
      if (redirectUrl) {
        return Response.redirect(redirectUrl, 302);
      }
    } catch (error) {
      // If there's an error, return a 500
      return new Response('Internal Server Error', {
        status: 500,
        statusText: 'Internal Server Error',
        headers: {
          'Content-Type': 'text/plain'
        }
      });
    }
  }
  
  // Find matching domain configuration
  for (const [pattern, config] of DOMAIN_CONFIG) {
    if (pattern.test(url.href)) {
      const redirectUrl = handleDomain(url.pathname, url.search, config);
      return Response.redirect(redirectUrl, 301);
    }
  }
  
  // Return 404 if none match
  return new Response('Not Found', {
    status: 404,
    statusText: 'Not Found',
    headers: {
      'Content-Type': 'text/plain'
    }
  });
}

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});