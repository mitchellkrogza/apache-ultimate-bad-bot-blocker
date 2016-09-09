# The Apache Ultimate Bad Bot and Referer Blocker
##The Ultimate Bad Bot and Referer Blocker for Apache Web Servers

### Created by: https://github.com/mitchellkrogza

### Recommend to saved as: /etc/apache2/custom.d/globalblacklist.conf

### WHY BLOCK BAD BOTS ?
#####Bad bots are:

-    Bad Referers
-    Spam Referers
-    Spam bots
-    Vulnerability scanners
-    E-mail harvesters
-    Content scrapers
-    Aggressive bots that scrape content
-    Bots or Servers linked to viruses or malware
-    Government surveillance bots

Bots attempt to make themselves look like other software or web sites by disguising their user agent. 
Their user agent names may look harmless, perfectly legitimate even. 

For example, "^Java" but according to Project Honeypot, it's actually one of the most dangerous BUT a lot of
legitimate bots out there have "Java" in their user agent string so the approach taken by many to block is 
not only ignorant but also blocking out very legitimate crawlers including some of Google's and Bing's.

# Welcome to the Ultimate Bad Bot and Referer Blocker for Apache Web Server 2.4.x

### THE METHOD IN MY MADNESS

This bot blocker list is designed to be an Apache include file and uses the apache
BrowserMatchNoCase directive. This way the .conf file can be loaded 
once into memory by Apache and be available to all web sites that you operate.
You simply need to use an Include statement (example below)

I personally find the BrowserMatchNoCase Directive to be more accurate than using 
SetEnvIfNoCase User-Agent because BrowserMatchNoCase is not case sensitive and
from my tests is more accurate that SetEnvIfNoCase.

My method also results in a cleaner file to maintain that requires no complex regex
other than the Name of the Bot. BrowserMatchNoCase will do the rest. You can use Regex
if you like but it's NOT needed and I proved it by testing with the Chrome extension
User-Agent Switcher for Chrome. 

- The user agent "Aboundex" is found without using "^Aboundex" ... much simpler for anyone 
to maintain than other lists using Regex.

- Likewise it is unnecessary to have "Download\ Demon" instead you now just have
"Download Demon". 

- Additionally if we have a rule, like below "Image Stripper" and a bot
decides to change its User-Agent string to "NOT Image Stripper I Promise" he is picked
up regardless and blocked immediately. 

I only capitalise bot names in my list for ease of reading and maintenance, remember its 
not case-sensitive so will catch any combination like "Bot" "bOt" and "bOT".

So for those of you who SUCK with Regex this may just be your saviour !!!

### IT'S CENTRALISED:

The beauty of this is that it is one central file used by all your web sites.
This means there is only place to make amendments ie. adding new bots that you
discover in your log files. Any changes are applied immediately to all sites after
a simple "sudo service apache2 reload". 

### NO COMPLICATED REWRITE RULES:

This also does not use ReWrite Rules and Conditions which also put overhead onto
Apache, this sends a simple 403 Forbidden Response and DONE !!!

### APACHE WILL LOVE YOU FOR IT !!!!

This approach also makes this very lightweight on Apache versus the usual .htaccess
approach that many choose. The .htaccess approach is a little clumsy because every site
has to have its own one and every time someone requests your web site the .htaccess gets
hit and has to be checked, this is unnecessary overhead for Apache and not to mention
a pain when it comes to maintenance and updating your ruleset.

.htaccess just sucks full stop. One reason after 9 years I have moved everything to
Nginx but will continue to keep this file updated as it is solid and it works.

## FEATURES:

- Extensive Lists of Bad and Known Bad Bots and Scrapers (updated almost daily)
- Alphabetically ordered for easier maintenance
- Commented sections of certain important bots to be sure of before blocking
- Includes the IP range of Cyveillance who are known to ignore robots.txt rules
  and snoop around all over the Internet.
- Your own IP Ranges that you want to block can be easily added.

Usage: recommended to be saved as /etc/apache2/custom.d/globalblacklist.conf 
       - us an Include as per the example below to load the file into any host

## WARNING:

 Please understand why you are using this before you even use this.
 Please do not simply copy and paste without understanding what this is doing.
 Do not become a copy and paste Linux "Guru", learn things properly before you use them
 and always test everything you do one step at a time.

## MONITOR WHAT YOU ARE DOING:

 MAKE SURE to monitor your web site logs after implementing this. I suggest you first
 load this into one site and monitor it for any possible false positives before putting
 this into production on all your web sites.
 
 Also monitor your logs daily for new bad referers and user-agent strings that you
 want to block. Your best source of adding to this list is your own server logs, not mine.

## CONFIGURATION EXAMPLE:

 Include this in the beginning of a directory block just after your opening
 Options statements and before the rest of your host config example below

```
 <VirtualHost *:443>
 .....
 .....
<Directory "/var/www/mywebsite/htdocs/">
Options +Includes
Options +FollowSymLinks -Indexes
Include /etc/apache2/custom.d/globalblacklist.conf <<<<<< This needs to be added
 ......
 ......
 BEGIN WordPress
<IfModule mod_rewrite.c>
```

- This is free to use and modify as you wish. 
- No warranties are express or implied.
- You use this entirely at your own Risk.
- Fork your own copy from this repo and feel free to change it to your needs or contribute to it.

##### Why not visit me?

https://mitchellkrog.com is what I do full time, playing with servers and security is another
passion of mine. I love Apache but have recently fallen head over heels with Nginx
I write rules like these for my own servers and make them available to you all for free.
After 9 years of running Apache servers I have moved everything to Nginx which is the most solid
stable and reliable web server I have ever used. I will however keep this Apache Bad Bot Blocker
regularly updated (almost daily) as it is based on the samebad bots and bad referers that are 
extracted from my Nginx logs.

##### Some other free projects

- https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
- https://github.com/mitchellkrogza/Fail2Ban-Blacklist-JAIL-for-Repeat-Offenders-with-Perma-Extended-Banning
- https://github.com/mitchellkrogza/fail2ban-useful-scripts
- https://github.com/mariusv/nginx-badbot-blocker
