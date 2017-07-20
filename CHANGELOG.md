# CHANGELOG - Apache Bad Bot Blocker

### 2017-07-20
- Please not existing version in conf.d folder in root of repo has been deprecated and will no longer be updated
- Existing users please update your servers to pull updates from the Apache_2.2/conf.d folder which is the same original version.
- A new Apache 2.4 version using the new Apache 2.4 Access control structures is still in Beta testing phase.
- Travis CI generator scripts brought online so that Travis generates the blacklist files during it's building and testing.
- Lots of other updates currently still in progress and should be finished by 2017-07-21 (tomorrow)
- Please read the notes about the deprecated version and download the latest update-apacheblocker.sh from the Apache_2.2 folder.
- If you fail to download the new updater you will simply be pulling the old version which is not longer updated anymore.

### 2017-07-19
- Renamed some folder names.
- Update Travis build scripts to new folder naming.
- Update readme and configuration files to new folder naming.

### 2017-07-13
- Configuration Instructions Updated.
- Moved google-exclude and google-disavow files into appropriate folders.
- Added visual instructions for how to use google-exclude files in Google Analytics.

### 2017-06-26
- Better Regex Pattern Matching for BrowserMatchNoCase statements - Exact matching of User-Agent names inside strings using word boundaries without creating false positives. Reported in Issue https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/issues/30
- Old regex `BrowserMatchNoCase "^Spbot" bad_bot` now becomes `BrowserMatchNoCase "^(.*?)(\bSpbot\b)(.*)$" bad_bot`

### 2017-04-19 (MAJOR VERSION UPDATE) - V2.2017.05
- New include files introduced - blacklist-ips.conf, bad-referrer-words.conf and blacklist-user-agents.conf
- New include file bad-referrer-words.conf allows total control and customization of scanning for bad referrer words
- New include file blacklist-ips.conf allows total control and customization over which IP addresses and IP Ranges you want to block
- New include file blacklist-user-agents.conf allows adding own custom user-agents you wish to block.
- Cyveillance and Berkeley Scanner Blocks have been moved into blacklist-ips.conf
- VERY IMPORTANT - Without the existence of blacklist-ips.conf, bad-referrer-words.conf and blacklist-user-agents.conf include files Apache will FAIL RELOAD
- PLEASE READ UPDATED CONFIGURATION INSTRUCTIONS
- AUTO UPDATE SCRIPT WILL FAIL APACHE RELOAD WITHOUT THE NEW INCLUDE FILES !!!!
- Introduced better Regex patterns for escaping dots in domain names of bad referrers to prevent false positives as per ISSUE: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/issues/22
- Regex Change on Bots Sections to Exact Matching
- Fixed some Duplicated Bots Issues
- Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes like this take place.
- Also follow me on twitter @ubuntu101za for update notifications
- All Users please update your custom include files to fall into line with the new regex patterns.

### 2017-04-11
- Introduced Repo Email Notification Mailing List
- Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.
- Also follow me on twitter @ubuntu101za for update notifications

### 2017-02-26
- Added bash script for those wanting hassle free auto updating of the blocker.

### 2017-02-16 (MAJOR VERSION UPDATE) - V2.2017.04
- V2.2017.04 - Introduce new Whitelisting of Domain names and IP addresses using an Include file. This means you no longer have to remember to insert your whitelisted IP's and domains with each update. Now you can simply pull the updated globalblacklist.conf to your server, reload Apache and it will automatically include your whitelisted IP ranges and domains. **[Please read updated configuration instructions](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/CONFIGURATION.md)**

### 2017-02-07 (MAJOR VERSION UPDATE) - V2.2017.03
- V2.2017.03 - Introduced .htaccess versions of the spam referrer blocker for users without root access to their Apache Server or unable to run the full bot blocker for some or other reason

### 2017-02-06 (MAJOR VERSION UPDATE) - V2.2017.02
- V2.2017.02 - Added WhiteListing of CloudFlare IP Ranges

### 2017-01-29
- Changed formatting of globalblacklist.conf, some sections like semalt and miraibot merged into other sections for easier maintenance.
- Additional notes, testing instructions and commenting added in globalblacklist.conf file

### 2016-12-17
- Removed "CPython" from bad bots list. This user agent string "python-requests/2.5.3 CPython/2.7.9 Linux/3.16.0-4-amd64" is used by a valid Google Feed Parser called "UniversalFeedParser/5.2.1 +https://code.google.com/p/feedparser/"

### 2016-12-14
- Removed "python-requests" from bad bots list. This user agent string "python-requests/2.5.3 CPython/2.7.9 Linux/3.16.0-4-amd64" is used by a valid Google Feed Parser called "UniversalFeedParser/5.2.1 +https://code.google.com/p/feedparser/"

### 2016-12-11
- Added some repetitively bad IP's
- Added extensive blocking for builtwith.com SEO analysis company that scrapes, accumulates and sells SEO web data. Have blocked all their domains and IP's including other domains linked to the owner. Also spent hours digging for IP's linked to this site that were very nicely hidden but through some research I uncovered them. www.builtwith.com DOES obey removal instructions at https://builtwith.com/removals and it is immediate BUT for those who have never heard of builtwith.com or even know their sites are indexed and new sites are being indexed and used by your competitors to outrank you, I have sufficient blocks in place to prevent them ever accessing your Nginx/Apache server. I suggest you FIRST see if your site is indexed, then request removal of each site which requires you to place a simple .html file in your webroot and once that is done, then update to the latest version of the script which will block them indexing new sites from thereon out. I will keep a watch on them and add new IP's as they change.
- In progress on growing the BAD IP block list which will be based off repetetive 444 errors from the bad referer domains in the blocker. These bad IP's will be auto added into the blocker and I will generate plain text IP lists and IP tables rules too which can be updated frequently to block them at firewall level and keep your web logs even cleaner.

### 2016-12-04
- Added creation of a Google Disavow File - google-disavow.txt
- New Bad Referers Added

### 2016-12-03
- Added Over 205 New Bad Referer Domains
- Added google-exclude.txt file for stopping Ghost Spam on your Google Analytics
- Readme Updated with Instructions on using google-exclude.txt

### 2016-12-02 	
- Added Block List for Nibble SEO
- Added Block List for Wordpress Theme Detectors
