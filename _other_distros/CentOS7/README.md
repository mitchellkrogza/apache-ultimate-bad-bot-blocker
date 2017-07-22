<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-bad-bot-referrer-spam-blocker-centos-7-apache.png" alt="Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker for CentOS 7 and Apache 2.4.6 - Apache Block Bad Bots, User-Agents, Vulnerability Scanners, Malware, Adware, Ransomware, Malicious Sites, Spam Referrers, Bad Referrers, Spam Blocker, Porn Blocker, Gambling Blocker,  Wordpress Theme Detector Blocking and Fail2Ban Jail for Repeat Offenders"/><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/LICENSE.md)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![GitHub release](https://img.shields.io/github/release/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/releases/latest)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![Build Status](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg?branch=master)](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/><a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

### If this helps you [why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

# Apache Bad Bot and User-Agent Blocker, Spam Referrer Blocker, Bad IP Blocker and Wordpress Theme Detector Blocker
## The Ultimate Bad Bot, User-Agent and Spam Referrer Blocker for CentOS and Apache Web Servers

##### Version Information #
********************************************
#### Version: V3.2017.07.523
#### Bad Referrer Count: 5436
#### Bad Bot Count: 498
********************************************
##### Version Information ##

# For CentOS 7 and Apache 2.4.6 ONLY !!!

### Created by: https://github.com/mitchellkrogza
### Copyright Mitchell Krog <mitchellkrog@gmail.com>

# [Configuration instructions are here](#configuration-of-the-apache-bad-bot-blocker)

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

## Also follow me on twitter @ubuntu101za for update notifications

<a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

#### Users Unable to run the full Bot Blocker read - https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/tree/master/.htaccess

#### Includes the creation of a google-exclude.txt file for creating filters / segments in Google Analytics (see instructions lower down)
#### Includes the creation of a google-disavow.txt file for use in Google Webmaster Tools (see instructions lower down)
#### Includes .htaccess and robots.txt files for users without root access to their Apache Servers.

### WHY BLOCK BAD BOTS ?
##### Bad bots are:

-    Bad Referrers 
-    Bad User-Agent Strings
-    Spam Referrers
-    Spam Bots and Bad Bots
-    Sites Linked to Lucrative Malware, Adware and Ransomware Clickjacking Campaigns
-    Vulnerability scanners
-    Gambling and Porn Web Sites
-    E-mail harvesters
-    Content scrapers
-    Aggressive bots that scrape content
-    Image Hotlinking Sites and Image Thieves
-    Bots or Servers linked to viruses or malware
-    Government surveillance bots
-    Botnet Attack Networks (Mirai)
-    Known Wordpress Theme Detectors (Updated Regularly)
-    SEO companies that your competitors use to try improve their SEO
-    Link Research and Backlink Testing Tools
-    Stopping Google Analytics Ghost Spam
-    Browser Adware and Malware (Yontoo etc)

(Over 4000 bad referrers, bots, seo companies and counting)

### To contribute your own bad referers 
please add them into the
https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/Pull%20Requests%20Here%20Please/badreferers.list
file and then send a Pull Request (PR). 
All additions will be checked for accuracy before being merged.

### Issues:
Log any issues regarding incorrect listings on the issues system and they will be investigated
and removed if necessary.

### No root access to your Apache server and Unable to run this blocker?
Version 2.2017.03 introduced .htaccess versions of the spam referrer for those unable to run the full Apache Bad Bot Blocker look inside the .htaccess folder in this repo for instructions.

### If this helps you [You can buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

Bots attempt to make themselves look like other software or web sites by disguising their user agent. 
Their user agent names may look harmless, perfectly legitimate even. 

For example, "^Java" but according to Project Honeypot, it's actually one of the most dangerous BUT a lot of
legitimate bots out there have "Java" in their user agent string so the approach taken by many to block is 
not only ignorant but also blocking out very legitimate crawlers including some of Google's and Bing's.

# Welcome to the Ultimate Bad Bot and Referer Blocker for CentOS 6.8 and Apache Web Server 2.2.x

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

So for those of you who SUCK with Regex my Apache Bad Bot Blocker is your saviour !!!

### IT'S CENTRALISED:

The beauty of this is that it is one central file used by all your web sites.
This means there is only place to make amendments ie. adding new bots that you
discover in your log files. Any changes are applied immediately to all sites after
a simple "sudo service apache2 reload". 

### IT IS TINY AND LIGHTWEIGHT

The file is tiny in size. At the time of this writing and the first public commit of this
the file size including all the commenting "which Apache ignores" is a mere 212 kb in size.
It is so lightweight that Apache does not even know it's there. It already contains thousands
of entries.

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

## FEATURES OF THE APACHE ULTIMATE BAD BOT BLOCKER:

- Extensive Lists of Bad and Known Bad Bots and Scrapers (updated almost daily)
- Blocking of Spam Referrer Domains and Web Sites
- Blocking of SEO data collection companies like Semalt.com, Builtwith.com, WooRank.com and many others (updated regularly)
- Blocking of clickjacking Sites linked to Adware, Malware and Ransomware
- Blocking of Porn and Gambling Web Sites who use Lucrative Ways to Earn Money through Serving Ads by hopping off your domain names and web sites.
- Blocking of Bad Domains and IP's that you cannot even see in your Nginx Logs. Thanks to the Content Security Policy (CSP) on all my SSL sites I can see things trying to pull resources off my sites before they even get to Nginx and get blocked by the CSP.
- Anti DDOS Filter and Rate Limiting of Agressive Bots
- Alphabetically ordered for easier maintenance (Pull Requests Welcomed)
- Commented sections of certain important bots to be sure of before blocking
- Includes the IP range of Cyveillance who are known to ignore robots.txt rules
  and snoop around all over the Internet.
- Whitelisting of Google, Bing and Cloudflare IP Ranges
- Whitelisting of your own IP Ranges that you want to avoid blocking by mistake.
- Ability to add other IP ranges and IP blocks that you want to block out.
- If its out there and it's bad it's already in here and BLOCKED !!

### UNDERSTANDS PUNYCODE / IDN DOMAIN NAMES
A lot of lists out there put funny domains into their hosts file. Your hosts file and DNS will not understand this. This list uses converted domains which are in the correct DNS format to be understood by any operating system. **Avoid using lists** that do not put the correctly formatted domain structure into their lists.

For instance
The domain:

`lifehacĸer.com` (note the K)

actually translates to:

`xn--lifehacer-1rb.com`

You can do an nslookup on any operating system and it will resolve correctly.

`nslookup xn--lifehacer-1rb.com`

```xn--lifehacer-1rb.com
	origin = dns1.yandex.net
	mail addr = iskalko.yandex.ru
	serial = 2016120703
	refresh = 14400
	retry = 900
	expire = 1209600
	minimum = 14400
xn--lifehacer-1rb.com	mail exchanger = 10 mx.yandex.net.
Name:	xn--lifehacer-1rb.com
Address: 78.110.60.230
xn--lifehacer-1rb.com	nameserver = dns2.yandex.net.
xn--lifehacer-1rb.com	text = "v=spf1 redirect=_spf.yandex.net"
xn--lifehacer-1rb.com	nameserver = dns1.yandex.net.
```

- Look at: https://www.charset.org/punycode for more info on this.

## WARNING:

 Please understand why you are using the Apache Bad Bot Blocker before you even use this.
 Please do not simply copy and paste without understanding what this is doing.
 Do not become a copy and paste Linux "Guru", learn things properly before you use them
 and always test everything you do one step at a time.

## MONITOR WHAT YOU ARE DOING:

 MAKE SURE to monitor your web site logs after implementing this. I suggest you first
 load this into one site and monitor it for any possible false positives before putting
 this into production on all your web sites.
 
 Also monitor your logs daily for new bad referers and user-agent strings that you
 want to block. Your best source of adding to this list is your own server logs, not mine.

## HOW TO MONITOR YOUR APACHE LOGS DAILY (The Easy Way):

With great thanks and appreciation to https://blog.nexcess.net/2011/01/21/one-liners-for-apache-log-files/

To monitor your top referer's for a web site's log file's on a daily basis use the following simple
cron jobs which will email you a list of top referer's / user agents every morning from a particular web site's log
files. This is an example for just one cron job for one site. Set up multiple one's for each one you
want to monitor. Here is a cron that runs at 8am every morning and emails me the stripped down log of
referers. When I say stripped down, the domain of the site and other referers like Google and Bing are
stripped from the results. Of course you must change the log file name, domain name and your email address in
the examples below. The second cron for collecting User agents does not do any stripping out of any referers but you
can add that functionality if you like copying the awk statement !~ from the first example.

##### Cron for Monitoring Daily Referers on Apache

`00 08 * * * tail -10000 /var/log/apache/mydomain-access.log | awk '$11 !~ /google|bing|yahoo|yandex|mywebsite.com/' | awk '{print $11}' | tr -d '"' | sort | uniq -c | sort -rn | head -1000 | mail - s "Top 1000 Referers for Mydomain.com" me@mydomain.com`

##### Cron for Monitoring Daily User Agents on Apache

`00 08 * * * tail -50000 /var/log/apache/mydomain-access.log | awk '{print $12}' | tr -d '"' | sort | uniq -c | sort -rn | head -1000 | mail -s "Top 1000 Agents for Mydomain.com" me@mydomain.com`


# CONFIGURATION OF THE APACHE BAD BOT BLOCKER:

## FOR CENTOS 7 and APACHE 2.4.6 ONLY

## Step 1:

**CREATE THE custom.d folder needed for Apache on CENTOS 7**

**You must create this folder.**

Open Terminal

`su`

`mkdir /etc/httpd/custom.d`

## Step 2:

**COPY THE GLOBALBLACKLIST.CONF FILE FROM THE REPO**

Copy the contents of **globalblacklist.conf** into your /etc/httpd/custom.d folder. 

`cd /etc/httpd/custom.d`

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/custom.d/globalblacklist.conf -O globalblacklist.conf`

## Step 3:

**WHITELIST ALL YOUR OWN DOMAIN NAMES AND IP ADDRESSES**

Whitelist all your own domain names and IP addresses. **Please note important changes**, this is now done using include files so that you do not have to keep reinserting your whitelisted domains and IP addresses every time you update.

`cd /etc/httpd/custom.d`

- copy the whitelist-ips.conf file into that folder

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/custom.d/whitelist-ips.conf -O whitelist-ips.conf`


- copy the whitelist-domains.conf file into the same folder

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/custom.d/whitelist-domains.conf -O whitelist-domains.conf`

Use nano, vim or any other text editor to edit both whitelist-ips.conf and whitelist-domains.conf to include all your own domain names and IP addresses that you want to specifically whitelist from the blocker script. 

When pulling any future updates now you can simply pull the latest globalblacklist.conf file and it will automatically include your whitelisted domains and IP addresses. No more remembering having to do this yourself.

## Step 4:

**DOWNLOAD CUSTOM BLACKLIST INCLUDE FILE FOR IP ADDRESS AND IP RANGE BLOCKING**

Blacklist any IP addresses or Ranges you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

`cd /etc/apache2/custom.d`

- copy the blacklist-ips.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/custom.d/blacklist-ips.conf -O blacklist-ips.conf`


Use nano, vim or any other text editor to edit the blacklist-ips.conf file as you like. 

When pulling any future updates now your custom IP blacklist will not be overwritten.

## Step 5:

**DOWNLOAD CUSTOM BAD REFERRER WORDS INCLUDE FILE FOR CUSTOMIZED SCANNING OF BAD WORDS**

Scan for any bad referrer words you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

`cd /etc/apache2/custom.d`

- copy the bad-referrer-words.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/custom.d/bad-referrer-words.conf -O bad-referrer-words.conf`


Use nano, vim or any other text editor to edit the bad-referrer-words.conf file as you like. 

When pulling any future updates now your custom bad referrer words list will not be overwritten.

## Step 6:

**DOWNLOAD CUSTOM BLACKLIST USER-AGENTS INCLUDE FILE FOR CUSTOMIZED BLOCKING OF USER AGENTS**

Allows you to add your own custom list of user agents with this new include file.

`cd /etc/apache2/custom.d`

- copy the blacklist-user-agents.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/custom.d/blacklist-user-agents.conf -O blacklist-user-agents.conf`

## Step 7:

**INCLUDE THE GLOBALBLACKLIST.CONF FILE INTO A VIRTUALHOST**

 Include the globalblacklist.conf file within a `<Directory>` block just after your opening Options statements and before the rest of your host config example below. 
 
 On CentOS to do this, open your httpd.conf file
 
 `nano /etc/httpd/conf/httpd.conf`
 
 At the very bottom where you configure your Virtualhosts you will configure one like this example.
 You will need to do this for each Virtualhost you have set up.
 ** VERY IMPORTANT: The Include Statement MUST be located within a `<Directory></Directory>` Block**
 
```
<VirtualHost *:80>
    ServerAdmin webmaster@wherever.com
    DocumentRoot /var/www/html/mywebsite.com
    ServerName mywebsite.com
    ErrorLog logs/mywebsite.com-error_log
    CustomLog logs/mywebsite.com-access_log common
    <Directory "/var/www/html/mywebsite.com">
    Include /etc/httpd/custom.d/globalblacklist.conf
    </Directory>
</VirtualHost>
```

## Step 8:

**RELOAD YOUR APACHE CONFIGURATION**

`service httpd reload`

If you get no errors you followed my instructions properly.

The blocker is now active and working so now you can run some simple tests from another linux machine to make sure it's working.

## Step 9:

*TESTING**

Run the following commands one by one from a terminal on another linux machine against your own domain name. 
**substitute yourdomain.com in the examples below with your REAL domain name**

`curl -A "googlebot" http://yourdomain.com`

Should respond with 200 OK

`curl -A "80legs" http://yourdomain.com`

`curl -A "masscan" http://yourdomain.com`

Should respond with 403 Forbidden

`curl -I http://yourdomain.com -e http://100dollars-seo.com`

`curl -I http://yourdomain.com -e http://zyzzcentral.ru`

Should respond with 403 Forbidden

The Apache Ultimate Bot Blocker is now WORKING and PROTECTING your web sites !!!

## Step 10:

**UPDATING THE APACHE BAD BOT BLOCKER** is now easy thanks to the automatic includes for whitelisting your own domain names.

Updating to the latest version is now as simple as:

`cd /etc/httpd/custom.d`

`su`

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/custom.d/globalblacklist.conf -O globalblacklist.conf`

`service httpd reload` 

And you will be up to date with all your whitelisted domains included automatically for you now. 

# AUTO UPDATING:

See my latest auto updater bash script at:

https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS7/updateapacheblocker.sh


Relax now and sleep better at night knowing your site is telling all those baddies FORBIDDEN !!!

# EASY CONFIGURATION INSTRUCTIONS FOR STOPPING GOOGLE ANALYTICS "GHOST" SPAM

Simply using the Apache blocker does not stop Google Analytics ghost referral spam because they are hitting Analytics directly and not always necessarily touching your website. 

You should use regex filters in Analytics to prevent ghost referral spam.

For this there are several google-exclude-0*.txt files which have been created for you and they are updated at the same time when the Nginx Blocker is updated. As the list grows there will be more exclude files created.

## To stop Ghost Spam on On Analytics

Follow the step by step visual instructions below to add these google-exclude files as segments to your web site.

<table style="width:100%;margin:0;">
  <tr>
    <td align="left"><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/google-analytics-ghost-spam-01.jpg" alt="Google Analytics - Adding Segments to Stop Ghost Spam"/></td>
  </tr>
  <tr>
    <td align="left"><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/google-analytics-ghost-spam-02.jpg" alt="Google Analytics - Adding Segments to Stop Ghost Spam"/></td>
  </tr>
  <tr>
    <td align="left"><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/google-analytics-ghost-spam-03.jpg" alt="Google Analytics - Adding Segments to Stop Ghost Spam"/></td>
  </tr>
  <tr>
    <td align="left"><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/google-analytics-ghost-spam-04.jpg" alt="Google Analytics - Adding Segments to Stop Ghost Spam"/></td>
  </tr>
  <tr>
    <td align="left"><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/google-analytics-ghost-spam-05.jpg" alt="Google Analytics - Adding Segments to Stop Ghost Spam"/></td>
  </tr>
  <tr>
    <td align="left"><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/google-analytics-ghost-spam-06.jpg" alt="Google Analytics - Adding Segments to Stop Ghost Spam"/></td>
  </tr>
  <tr>
    <td align="left"><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/google-analytics-ghost-spam-07.jpg" alt="Google Analytics - Adding Segments to Stop Ghost Spam"/></td>
  </tr>
</table>

## Blocking Spam Referrer Domains Using Google Webmaster Tools (How to use google-disavow.txt file)

I have added the creation of a Google Disavow text file called google-disavow.txt. This file can be used in Google's Webmaster Tools to block all these domains out as spammy or bad links. Use with caution.

## Blocking Agressive Bots at Firewall Level Using Fail2Ban

I have added a custom Fail2Ban filter and action that I have written which monitors your Apache logs for bots that generate
a large number of 403 errors. This custom jail for Fail2Ban will scan logs over a 1 week period and ban the offender for 24 hours.
It helps a great deal in keeping out some repeat offenders and preventing them from filling up your log files with 403 errors.
See the Fail2Ban folder for instructions on configuring this great add on for the Apache Bad Bot Blocker.

### If this helped you [Why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

# MIT License

## Copyright (c) 2017 Mitchell Krog - mitchellkrog@gmail.com
## https://github.com/mitchellkrogza

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

### Also Checkout The Big List of Hacked Malware Web Sites

This repository contains a list of all web sites I come across that are hacked with malware. 
Most site owners are unaware their sites have been hacked and are being used to plant malware.

Check it out at: https://github.com/mitchellkrogza/The-Big-List-of-Hacked-Malware-Web-Sites

### Into Photography?

Come drop by and visit me at https://mitchellkrog.com or <a href='https://twitter.com/MitchellKrog'><img src='https://img.shields.io/twitter/follow/MitchellKrog.svg?style=social&label=Follow' alt='Follow @MitchellKrog'></a>

### Some other free projects

- https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
- https://github.com/mitchellkrogza/Badd-Boyz-Hosts
- https://github.com/mitchellkrogza/fail2ban-useful-scripts
- https://github.com/mitchellkrogza/linux-server-administration-scripts
- https://github.com/mitchellkrogza/Travis-CI-Nginx-for-Testing-Nginx-Configuration
- https://github.com/mitchellkrogza/Travis-CI-for-Apache-For-Testing-Apache-and-PHP-Configurations
- https://github.com/mitchellkrogza/Fail2Ban-Blacklist-JAIL-for-Repeat-Offenders-with-Perma-Extended-Banning
- https://github.com/funilrys/funceble
- https://github.com/mariusv/nginx-badbot-blocker

### Acknowledgements:

Many parts of the generator scripts and code running behind this project have been adapted from multiple sources. In fact it's so hard to mention everyone but here are a few key people whose little snippets of code have helped me introduce new features all the time. Show them some love and check out some of their projects too

- Stevie-Ray Hartog https://github.com/Stevie-Ray
- Nissar Chababy - https://github.com/funilrys/funceble (Excellent script for checking ACTIVE, INACTIVE and EXPIRED Domain Names)
- Marius Voila https://github.com/mariusv
- Cătălin Mariș https://github.com/alrra
- deformhead https://github.com/deformhead
- bluedragonz https://github.com/bluedragonz
- Alexander https://github.com/shoonois
- Steven Black https://github.com/StevenBlack
- Fail2Ban - https://github.com/fail2ban
- Sir Athos from StackOverFlow - http://stackoverflow.com/users/2245910/sir-athos (help with Travis Build Tagging and Committing)
- StackOverflow - http://stackoverflow.com/ (bash scripts from hundreds of questions and answers)
- SuperUser - http://superuser.com/ (snippets from various questions and answers)

If you believe your name should be here, drop me a line.

### And remember [Coding make me thirsty so why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

## Also follow me on twitter @ubuntu101za for update notifications

<a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>
