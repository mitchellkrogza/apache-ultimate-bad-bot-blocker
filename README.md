# The Apache Ultimate Bot Blocker
##The Ultimate Bad Bot Blocker for Apache Web Servers

### Created by: https://github.com/mitchellkrogza

### Recommend to saved as: /etc/apache2/custom.d/globalblacklist.conf

### WHY BLOCK BAD BOTS ?
#####Bad bots are defined as:

-    E-mail harvesters
-    Content scrapers
-    Spam bots
-    Vulnerability scanners
-    Aggressive bots that provide little value
-    Bots linked to viruses or malware
-    Government surveillance bots

In short ... Bots try to make themselves look like other software by disguising their useragent. 
Their useragents may look harmless, perfectly legitimate even. 
For example, "^Java" but according to Project Honeypot, it's actually one of the most dangerous.

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

## FEATURES:
- Extensive Lists of Bad and Known Bad Bots and Scrapers
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

## MONITOR WHAT YOU ARE DOING:

 MAKE SURE to monitor your web site logs after implementing this. I suggest you first
 load this into one site and monitor it for any possible false positives before putting
 this into production on all your web sites.

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
- Fork your own copy from this repo and feel free to contribute to it.

##### Why not visit me?
https://mitchellkrog.com is what I do full time, playing with servers is another
passion of mine. I love Apache but have recently fallen head over heels with Nginx
I write rules like these for my own servers and make them available to you all for free.