#!/usr/bin/env bash
# DO NOT RUN DIRECTLY
# export GITHUB_TOKEN="NON_PRIVS_READ_ONLY_TOKEN"
# bash <(curl -qfsSL "https://raw.githubusercontent.com/pkgforge/metadata/refs/heads/main/soarpkgs/scripts/scrape_pub_issues_binaries.sh")
#-------------------------------------------------------#

#-------------------------------------------------------#
##Sanity Checks
if [[ -z "${OUTDIR// }" ]]; then
 export OUTDIR="${GITHUB_WORKSPACE}/main/soarpkgs/data"
 #mkdir -p "${OUTDIR}"
 if [ ! -d "${OUTDIR}" ]; then
    echo -e "\n[-] FATAL: Are you sure ${OUTDIR} Exists...? (Maybe not inside Github CI...?)\n"
   exit 1
 fi
else
 OUTDIR="$(realpath ${OUTDIR})" ; export OUTDIR
 mkdir -pv "${OUTDIR}"
fi
#-------------------------------------------------------#


#-------------------------------------------------------#
##ENV
#https://docs.github.com/en/rest/issues/issues
export DATE_CUTOFF="2024-00-00T00:00:00Z"
export GH_APIURL="api.gh.pkgforge.dev"
# export GH_APIURL="api.github.com" , append -H "Authorization: Bearer ${GITHUB_TOKEN}"
TEMP_ISSUES="$(mktemp -d)" && export TEMP_ISSUES="${TEMP_ISSUES}"
USER_AGENT="$(curl -qfsSL 'https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Misc/User-Agents/ua_firefox_macos_latest.txt')" && export USER_AGENT="${USER_AGENT}"
echo -e "\n[+] Using Temp Dir : ${TEMP_ISSUES}"
#-------------------------------------------------------#

#-------------------------------------------------------#
#Fetch: `static binary`
(for page in {1..10}; do
    echo -e "\n[+] GH API: Static Binary ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=static+binary:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `static build`
(for page in {1..10}; do
    echo -e "\n[+] GH API: Static Build ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=static+build+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `static compile`
(for page in {1..10}; do
    echo -e "\n[+] GH API: Static Compile ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=static+compile+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `musl binary`
(for page in {1..10}; do
    echo -e "\n[+] GH API: MUSL Binary ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=musl+binary+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `musl build`
(for page in {1..10}; do
    echo -e "\n[+] GH API: MUSL Build ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=musl+build+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `musl compile`
(for page in {1..10}; do
    echo -e "\n[+] GH API: MUSL Compile ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=musl+compile+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `release binary`
(for page in {1..10}; do
    echo -e "\n[+] GH API: Release Binary ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=release+binary+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `release static`
(for page in {1..10}; do
    echo -e "\n[+] GH API: Release Static ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=release+static+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Fetch: `package manager`
(for page in {1..10}; do
    echo -e "\n[+] GH API: Package Manager ($page/10)\n"
     curl -qfsSL "https://${GH_APIURL}/search/issues?q=package+manager+state:open+is:issue&filter=all&since=${DATE_CUTOFF}&sort=created&direction=desc&per_page=100&page=$page" | jq -r '.items | sort_by(.created_at)[] | "\(.created_at // "NA") \(.title // "NA") --> \(.html_url // "NA") (\(.user.login // "NA"))"' | tee -a "${TEMP_ISSUES}/$(basename $(mktemp -u)).txt"
     #sleep 2
done) &
#wait ; echo
#Sort
wait ; echo
find "${TEMP_ISSUES}" -name "*.txt" -exec cat {} + | grep '^[0-9]' | grep -v '\[bot\])' | sort --unique --reverse -o "${OUTDIR}/pub_issues_binaries.txt"
#find "${TEMP_ISSUES}" -name "*.txt" -exec cat {} + | grep '^[0-9]' | grep -v '\[bot\])' | sort --numeric-sort --reverse --unique -o "${OUTDIR}/pub_issues_binaries.txt"
#find "${TEMP_ISSUES}" -name "*.txt" -exec cat {} + | grep '^[0-9]' | grep -v '\[bot\])' | sort --version-sort --reverse --unique -o "${OUTDIR}/pub_issues_binaries.txt"
echo -e "\n[+] Saved Output ==> ${OUTDIR}/pub_issues_binaries.txt"
#-------------------------------------------------------#
