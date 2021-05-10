<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-ultimate-bad-bot-referrer-blocker-script.png" alt="Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker - Apache Block Bad Bots, User-Agents, Vulnerability Scanners, Malware, Adware, Ransomware, Malicious Sites, Spam Referrers, Bad Referrers, Spam Blocker, Porn Blocker, Gambling Blocker,  Wordpress Theme Detector Blocking and Fail2Ban Jail for Repeat Offenders"/>

| REPO | INFO |
| :--: | :--: |
| [![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/LICENSE.md) | [![GitHub release](https://img.shields.io/github/release/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/releases/latest) |
| [![Build Status](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg?branch=master)](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker) | [![GitHub Stats](https://img.shields.io/badge/github-stats-ff5500.svg)](http://githubstats.com/mitchellkrogza/apache-ultimate-bad-bot-blocker) |

<a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

# Apache Bad Bot and User-Agent Blocker, Spam Referrer Blocker, Bad IP Blocker and Wordpress Theme Detector Blocker
##### The Ultimate Apache (2.2 > 2.4+) Bad Bot, User-Agent, Spam Referrer Blocker, Adware, Malware and Ransomware Blocker, Clickjacking Blocker, Click Re-Directing Blocker, SEO Companies and Bad IP Blocker with Anti DDOS System, Nginx Rate Limiting and Wordpress Theme Detector Blocking. Stop and Block all kinds of bad internet traffic from ever reaching your web sites. [PLEASE SEE: Definition of Bad Bots](#define-bad-bots)

_______________
#### Version: V3.2021.05.1207
#### Bad Referrer Count: [7035](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list)
#### Bad Bot Count: [608](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)
#### Fake Googlebots: [217](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list)
____________________

- Created by: https://github.com/mitchellkrogza
- Copyright Mitchell Krog <mitchellkrog@gmail.com>

****************************************************************
## Two Versions of the Blocker ? PLEASE TAKE NOTE :exclamation:

:exclamation:**There are now two distinctly different versions of this blocker.**:exclamation:

**<a href="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/tree/master/Apache_2.2">Apache 2.2 > 2.4+ (access_compat)</a>  [  TESTED ON APACHE 2.2 > 2.4.27  ]**
****************************************************************
```
A Version for Apache 2.2 > 2.4 + which requires the module access_compat and uses the older 
Order Allow,Deny Access Control Methods. 

This is the ORIGINAL VERSION of the blocker and is now located in the folder Apache_2.2 at:
https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/tree/master/Apache_2.2
```
****************************************************************

**<a href="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/tree/master/Apache_2.4">Apache 2.4+ ONLY</a>  [  TESTED ON APACHE 2.4 > 2.4.34  ]**
****************************************************************
``` 
A new version for Apache 2.4+ only which uses new the Access Control Structures of 
<RequireAll> and <RequireAny>. 

Anyone using Apache 2.4 should be using this new version as it fully complies with the new Access 
Control Methods of Apache and does not require the access_compat module to be loaded. 

This new version is at: 
https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/tree/master/Apache_2.4
```
****************************************************************

### For Support, Contributions & Idea Sharing

Please make sure you are subscribed to Github Notifications to be notified when the blocker is updated or when any important or mission critical (potentially breaking) changes may take place.

##### Also follow me on twitter @ubuntu101za 

<a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

## Help Support This Project 

[<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/kofi4.png" alt="Buy me Coffee" width="300"/>](https://ko-fi.com/mitchellkrog)

****************************************************************

# CONFIGURATION OF THE APACHE BAD BOT BLOCKER:

- CPANEL Users read - https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/_CPanel_Instructions/README.md
- Users Unable to run the full Bot Blocker read - https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/_htaccess_versions/README.md
- Includes the creation of a google-exclude.txt file for creating filters / segments in Google Analytics (see instructions lower down)
- Includes the creation of a google-disavow.txt file for use in Google Webmaster Tools (see instructions lower down)
- Includes .htaccess and robots.txt files for users without root access to their Apache Servers.

<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-2-2.jpg" alt="Apache Bad Bot Blocker"/>

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-1.png"/>

**COPY THE GLOBALBLACKLIST.CONF FILE FROM THE REPO**
$APACHE_CONF is generally located at /etc/apache2 or /etc/httpd depending on OS

Copy the contents of **globalblacklist.conf** into your $APACHE_CONF/custom.d folder. 
e.g. /etc/apache2/custom.d on Ubuntu/Debian
     /etc/httpd on RHEL/centos
**You need to create this folder.**

The following directions use /etc/apache2 as an example.

`sudo mkdir /etc/apache2/custom.d`

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf`

If your Linux distribution does not have wget you can replace the wget commands using curl as follows:

`curl -sL https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/globalblacklist.conf -o /etc/apache2/custom.d/globalblacklist.conf`

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-2.png"/>

**WHITELIST ALL YOUR OWN DOMAIN NAMES AND IP ADDRESSES**

Whitelist all your own domain names and IP addresses. **Please note important changes**, this is now done using include files so that you do not have to keep reinserting your whitelisted domains and IP addresses every time you update.

:exclamation: :exclamation: :exclamation: WARNING: Please do NOT ever use 127.0.0.1 as a whitelisted IP address in whitelist-ips.conf it will cause the blocker to stop functioning.

- copy the whitelist-ips.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-ips.conf -O /etc/apache2/custom.d/whitelist-ips.conf`


- copy the whitelist-domains.conf file into the same folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/whitelist-domains.conf -O /etc/apache2/custom.d/whitelist-domains.conf`

Use nano, vim or any other text editor to edit both whitelist-ips.conf and whitelist-domains.conf to include all your own domain names and IP addresses that you want to specifically whitelist from the blocker script. 

When pulling any future updates now you can simply pull the latest globalblacklist.conf file and it will automatically include your whitelisted domains and IP addresses. No more remembering having to do this yourself.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-3.png"/>

**DOWNLOAD CUSTOM BLACKLIST INCLUDE FILE FOR IP ADDRESS AND IP RANGE BLOCKING**

Blacklist any IP addresses or Ranges you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

- copy the blacklist-ips.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-ips.conf -O /etc/apache2/custom.d/blacklist-ips.conf`


Use nano, vim or any other text editor to edit the blacklist-ips.conf file as you like. 

When pulling any future updates now your custom IP blacklist will not be overwritten.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-4.png"/>

**DOWNLOAD CUSTOM BAD REFERRER WORDS INCLUDE FILE FOR CUSTOMIZED SCANNING OF BAD WORDS**

Scan for any bad referrer words you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

- copy the bad-referrer-words.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/bad-referrer-words.conf -O /etc/apache2/custom.d/bad-referrer-words.conf`


Use nano, vim or any other text editor to edit the bad-referrer-words.conf file as you like. 

When pulling any future updates now your custom bad referrer words list will not be overwritten.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-5.png"/>

**DOWNLOAD CUSTOM BLACKLIST USER-AGENTS INCLUDE FILE FOR CUSTOMIZED BLOCKING OF USER AGENTS**

Allows you to add your own custom list of user agents with this new include file.

- copy the blacklist-user-agents.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/blacklist-user-agents.conf -O /etc/apache2/custom.d/blacklist-user-agents.conf`

**NOTE:** On the Apache Blocker if you want to over-ride any of the whitelisted bots you can add them to this include file and the previously whitelisted bots in the blocker will be over-ridden by this include file. So let's say for some "obscure" reason you really do not want any search engines like Googlebot or Bingbot to ever access or index your site, you add them to your blacklist-user-agents.conf and they will be over-ridden from the earlier whitelisting in the blocker. This now gives users total control over the blocker without every having to try and modify the globalblacklist.conf file. So now you can customize all your include files and you can still pull the daily updates of globalblacklist.conf and it will not touch any of your custom include files.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-6.png"/>

**INCLUDE THE GLOBALBLACKLIST.CONF**

Include the globalblacklist.conf file in the beginning of a directory block just after your opening Options statements and before the rest of your host config example below. **Remove the "<<<<<< This needs to be added" part**

```
<VirtualHost *:80>
	ServerName local.dev
	DocumentRoot /var/www/html
	ErrorLog /tmp/error.log

	<Directory "/var/www/html">
	Options +Includes
	Options +FollowSymLinks -Indexes
	Include custom.d/globalblacklist.conf
	</Directory>
</VirtualHost>
```

You can include globalblacklist.conf globally (for all virtual hosts) if you put the following configuration after virtual host configuration.

```
# ######################################
# GLOBAL! deny bad bots and IP addresses
# ######################################
#
# should be set after <VirtualHost>s see https://httpd.apache.org/docs/2.4/sections.html#merging
<Location "/">
	# AND-combine with preceding configuration sections  
	AuthMerging And
	# include black list
	Include custom.d/globalblacklist.conf
</Location>
```

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-7.png"/>

**TEST YOUR APACHE CONFIGURATION**

Do an Apache2 Config Test

`sudo apache2ctl configtest`

If you get no errors then you followed my instructions so now you can make the blocker go live with a simple.

`sudo service apache2 reload`

or

`sudo service httpd reload`

The blocker is now active and working so now you can run some simple tests from another linux machine to make sure it's working.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-8.png"/>

*TESTING**

Run the following commands one by one from a terminal on another linux machine against your own domain name. 
**substitute yourdomain.com in the examples below with your REAL domain name**

`curl -A "googlebot" http://yourdomain.com`

Should respond with 200 OK

`curl -A "80legs" http://yourdomain.com`

`curl -A "masscan" http://yourdomain.com`

Should respond with 403 Forbidden

`curl -I http://yourdomain.com -e http://100dollars-seo.com`

`curl -I http://yourdomain.com -e http://zx6.ru`

Should respond with 403 Forbidden

The Apache Ultimate Bot Blocker is now WORKING and PROTECTING your web sites !!!

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-9.png"/>

**UPDATING THE APACHE BAD BOT BLOCKER** is now easy thanks to the automatic includes for whitelisting your own domain names.

Updating to the latest version is now as simple as:

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.2/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf`

`sudo apache2ctl configtest`

`sudo service apache2 reload` 

And you will be up to date with all your whitelisted domains included automatically for you now. 

************************************************
# AUTO UPDATING WITH CRON:

See the latest auto updater bash script for Apache 2.2 and 2.4 contributed by Luke Taylor @lutaylor at:

https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/update-apacheblocker.sh

Relax now and sleep better at night knowing your site is telling all those baddies FORBIDDEN !!!

<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-2-4.jpg" alt="Apache 2.4 Bad Bot Blocker"/>

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-1.png"/>

**COPY THE GLOBALBLACKLIST.CONF FILE FROM THE REPO**
$APACHE_CONF is generally located at /etc/apache2 or /etc/httpd depending on OS

Copy the contents of **globalblacklist.conf** into your $APACHE_CONF/custom.d folder. 
e.g. /etc/apache2/custom.d on Ubuntu/Debian
     /etc/httpd on RHEL/centos
**You need to create this folder.**

The following directions use /etc/apache2 as an example.

`sudo mkdir /etc/apache2/custom.d`

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf`

If your Linux distribution does not have wget you can replace the wget commands using curl as follows:

`curl -sL https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/globalblacklist.conf -o /etc/apache2/custom.d/globalblacklist.conf`

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-2.png"/>

**WHITELIST ALL YOUR OWN DOMAIN NAMES AND IP ADDRESSES**

Whitelist all your own domain names and IP addresses. **Please note important changes**, this is now done using include files so that you do not have to keep reinserting your whitelisted domains and IP addresses every time you update.

:exclamation: :exclamation: :exclamation: WARNING: Please do NOT ever use 127.0.0.1 as a whitelisted IP address in whitelist-ips.conf it will cause the blocker to stop functioning.

- copy the whitelist-ips.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/whitelist-ips.conf -O /etc/apache2/custom.d/whitelist-ips.conf`


- copy the whitelist-domains.conf file into the same folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/whitelist-domains.conf -O /etc/apache2/custom.d/whitelist-domains.conf`

Use nano, vim or any other text editor to edit both whitelist-ips.conf and whitelist-domains.conf to include all your own domain names and IP addresses that you want to specifically whitelist from the blocker script. 

When pulling any future updates now you can simply pull the latest globalblacklist.conf file and it will automatically include your whitelisted domains and IP addresses. No more remembering having to do this yourself.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-3.png"/>

**DOWNLOAD CUSTOM BLACKLIST INCLUDE FILE FOR IP ADDRESS AND IP RANGE BLOCKING**

Blacklist any IP addresses or Ranges you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

- copy the blacklist-ips.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/blacklist-ips.conf -O /etc/apache2/custom.d/blacklist-ips.conf`


Use nano, vim or any other text editor to edit the blacklist-ips.conf file as you like. 

When pulling any future updates now your custom IP blacklist will not be overwritten.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-4.png"/>

**DOWNLOAD CUSTOM BAD REFERRER WORDS INCLUDE FILE FOR CUSTOMIZED SCANNING OF BAD WORDS**

Scan for any bad referrer words you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

- copy the bad-referrer-words.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/bad-referrer-words.conf -O /etc/apache2/custom.d/bad-referrer-words.conf`


Use nano, vim or any other text editor to edit the bad-referrer-words.conf file as you like. 

When pulling any future updates now your custom bad referrer words list will not be overwritten.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-5.png"/>

**DOWNLOAD CUSTOM BLACKLIST USER-AGENTS INCLUDE FILE FOR CUSTOMIZED BLOCKING OF USER AGENTS**

Allows you to add your own custom list of user agents with this new include file.

- copy the blacklist-user-agents.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/blacklist-user-agents.conf -O /etc/apache2/custom.d/blacklist-user-agents.conf`

**NOTE:** On the Apache Blocker if you want to over-ride any of the whitelisted bots you can add them to this include file and the previously whitelisted bots in the blocker will be over-ridden by this include file. So let's say for some "obscure" reason you really do not want any search engines like Googlebot or Bingbot to ever access or index your site, you add them to your blacklist-user-agents.conf and they will be over-ridden from the earlier whitelisting in the blocker. This now gives users total control over the blocker without every having to try and modify the globalblacklist.conf file. So now you can customize all your include files and you can still pull the daily updates of globalblacklist.conf and it will not touch any of your custom include files.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-6.png"/>

**INCLUDE THE GLOBALBLACKLIST.CONF**

Include the globalblacklist.conf file in the beginning of a directory block just after your opening Options statements and before the rest of your host config example below. **Remove the "<<<<<< This needs to be added" part**

```
<VirtualHost *:80>

	ServerName local.dev
    ServerAlias www.local.dev
	DocumentRoot /var/www/html
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

		<Directory "/var/www/html">
    		AllowOverride All
    		Options FollowSymLinks
			Include custom.d/globalblacklist.conf
  		</Directory>

</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```

You can include globalblacklist.conf globally (for all virtual hosts) if you put the following configuration after virtual host configuration.

```
# ######################################
# GLOBAL! deny bad bots and IP addresses
# ######################################
#
# should be set after <VirtualHost>s see https://httpd.apache.org/docs/2.4/sections.html#merging
<Location "/">
	# AND-combine with preceding configuration sections  
	AuthMerging And
	# include black list
	Include custom.d/globalblacklist.conf
</Location>
```

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-7.png"/>

**TEST YOUR APACHE CONFIGURATION**

Do an Apache2 Config Test

`sudo apache2ctl configtest`

If you get no errors then you followed my instructions so now you can make the blocker go live with a simple.

`sudo service apache2 reload`

or

`sudo service httpd reload`

The blocker is now active and working so now you can run some simple tests from another linux machine to make sure it's working.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-8.png"/>

*TESTING**

Run the following commands one by one from a terminal on another linux machine against your own domain name. 
**substitute yourdomain.com in the examples below with your REAL domain name**

`curl -A "googlebot" http://yourdomain.com`

Should respond with 200 OK

`curl -A "80legs" http://yourdomain.com`

`curl -A "masscan" http://yourdomain.com`

Should respond with 403 Forbidden

`curl -I http://yourdomain.com -e http://100dollars-seo.com`

`curl -I http://yourdomain.com -e http://zx6.ru`

Should respond with 403 Forbidden

The Apache Ultimate Bot Blocker is now WORKING and PROTECTING your web sites !!!

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-9.png"/>

**UPDATING THE APACHE BAD BOT BLOCKER** is now easy thanks to the automatic includes for whitelisting your own domain names.

Updating to the latest version is now as simple as:

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/Apache_2.4/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf`

`sudo apache2ctl configtest`

`sudo service apache2 reload` 

And you will be up to date with all your whitelisted domains included automatically for you now. 

************************************************
# AUTO UPDATING WITH CRON:

See the latest auto updater bash script for Apache 2.2 and 2.4 contributed by Luke Taylor @lutaylor at:

https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/update-apacheblocker.sh

Relax now and sleep better at night knowing your site is telling all those baddies FORBIDDEN !!!


************************************************
# WHY BLOCK BAD BOTS ?

<h4 id="define-bad-bots">
Definition of Bad Bots
</h4>

##### Bad bots are:

-    Bad Referrers 
-    Bad User-Agent Strings
-    Spam Referrers
-    Spam Bots and Bad Bots
-    Nuisance or Unwanted Bots
-    Sites Linked to Lucrative Malware, Adware and Ransomware Clickjacking Campaigns
-    Vulnerability scanners
-    Gambling and Porn Web Sites
-    E-mail harvesters
-    Content scrapers
-    Link Ranking Bots
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

************************************************
### To contribute your own bad referers 

please add them into the
https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/Pull%20Requests%20Here%20Please/badreferers.list
file and then send a Pull Request (PR). 
All additions will be checked for accuracy before being merged.

************************************************
### Issues:

Log any issues regarding incorrect listings on the issues system and they will be investigated
and removed if necessary.

************************************************
### No root access to your Apache server and Unable to run this blocker?

Version 2.2017.03 introduced .htaccess versions of the spam referrer for those unable to run the full Apache Bad Bot Blocker look inside the https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/tree/master/_htaccess_versions folder in this repo for instructions.

************************************************
## Help Support This Project 

[<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/kofi4.png" alt="Buy me Coffee" width="300"/>](https://ko-fi.com/mitchellkrog)

Bots attempt to make themselves look like other software or web sites by disguising their user agent. 
Their user agent names may look harmless, perfectly legitimate even. 

For example, "^Java" but according to Project Honeypot, it's actually one of the most dangerous BUT a lot of
legitimate bots out there have "Java" in their user agent string so the approach taken by many to block is 
not only ignorant but also blocking out very legitimate crawlers including some of Google's and Bing's.

# Welcome to the Ultimate Bad Bot and Referer Blocker for Apache Web Server 2.4.x

************************************************
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

************************************************
### IT'S CENTRALISED:

The beauty of this is that it is one central file used by all your web sites.
This means there is only place to make amendments ie. adding new bots that you
discover in your log files. Any changes are applied immediately to all sites after
a simple "sudo service apache2 reload". 

************************************************
### IT IS TINY AND LIGHTWEIGHT

The file is tiny in size. At the time of this writing and the first public commit of this
the file size including all the commenting "which Apache ignores" is a mere 212 kb in size.
It is so lightweight that Apache does not even know it's there. It already contains thousands
of entries.

************************************************
### NO COMPLICATED REWRITE RULES:

This also does not use ReWrite Rules and Conditions which also put overhead onto
Apache, this sends a simple 403 Forbidden Response and DONE !!!

************************************************
### APACHE WILL LOVE YOU FOR IT !!!!

This approach also makes this very lightweight on Apache versus the usual .htaccess
approach that many choose. The .htaccess approach is a little clumsy because every site
has to have its own one and every time someone requests your web site the .htaccess gets
hit and has to be checked, this is unnecessary overhead for Apache and not to mention
a pain when it comes to maintenance and updating your ruleset.

.htaccess just sucks full stop. One reason after 9 years I have moved everything to
Nginx but will continue to keep this file updated as it is solid and it works.

************************************************
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

************************************************
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

************************************************
## WARNING:

 Please understand why you are using the Apache Bad Bot Blocker before you even use this.
 Please do not simply copy and paste without understanding what this is doing.
 Do not become a copy and paste Linux "Guru", learn things properly before you use them
 and always test everything you do one step at a time.

************************************************
## MONITOR WHAT YOU ARE DOING:

 MAKE SURE to monitor your web site logs after implementing this. I suggest you first
 load this into one site and monitor it for any possible false positives before putting
 this into production on all your web sites.
 
 Also monitor your logs daily for new bad referers and user-agent strings that you
 want to block. Your best source of adding to this list is your own server logs, not mine.

************************************************
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

`00 08 * * * tail -10000 /var/log/apache/mydomain-access.log | awk '$11 !~ /google|bing|yahoo|yandex|mywebsite.com/' | awk '{print $11}' | tr -d '"' | sort | uniq -c | sort -rn | head -1000 | mail -s "Top 1000 Referers for Mydomain.com" me@mydomain.com`

##### Cron for Monitoring Daily User Agents on Apache

`00 08 * * * tail -50000 /var/log/apache/mydomain-access.log | awk '{print $12}' | tr -d '"' | sort | uniq -c | sort -rn | head -1000 | mail -s "Top 1000 Agents for Mydomain.com" me@mydomain.com`


************************************************
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

************************************************
## Blocking Spam Referrer Domains Using Google Webmaster Tools (How to use google-disavow.txt file)

I have added the creation of a Google Disavow text file called google-disavow.txt. This file can be used in Google's Webmaster Tools to block all these domains out as spammy or bad links. Use with caution.

************************************************
## Blocking Agressive Bots at Firewall Level Using Fail2Ban

I have added a custom Fail2Ban filter and action that I have written which monitors your Apache logs for bots that generate
a large number of 403 errors. This custom jail for Fail2Ban will scan logs over a 1 week period and ban the offender for 24 hours.
It helps a great deal in keeping out some repeat offenders and preventing them from filling up your log files with 403 errors.
See the Fail2Ban folder for instructions on configuring this great add on for the Apache Bad Bot Blocker.

## Help Support This Project 

[<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/kofi4.png" alt="Buy me Coffee" width="300"/>](https://ko-fi.com/mitchellkrog)

************************************************
### Also Checkout The Big List of Hacked Malware Web Sites

This repository contains a list of all web sites I come across that are hacked with malware. 
Most site owners are unaware their sites have been hacked and are being used to plant malware.

Check it out at: https://github.com/mitchellkrogza/The-Big-List-of-Hacked-Malware-Web-Sites

************************************************
### Some other free projects

- https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
- https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker
- https://github.com/mitchellkrogza/Badd-Boyz-Hosts
- https://github.com/mitchellkrogza/Ultimate.Hosts.Blacklist
- https://github.com/mitchellkrogza/Stop.Google.Analytics.Ghost.Spam.HOWTO
- https://github.com/mitchellkrogza/The-Big-List-of-Hacked-Malware-Web-Sites
- https://github.com/mitchellkrogza/fail2ban-useful-scripts
- https://github.com/mitchellkrogza/linux-server-administration-scripts
- https://github.com/mitchellkrogza/Travis-CI-Nginx-for-Testing-Nginx-Configuration
- https://github.com/mitchellkrogza/Travis-CI-for-Apache-For-Testing-Apache-and-PHP-Configurations
- https://github.com/mitchellkrogza/Fail2Ban-Blacklist-JAIL-for-Repeat-Offenders-with-Perma-Extended-Banning
- https://github.com/funilrys/PyFunceble
- https://github.com/funilrys/dead-hosts
- https://github.com/mitchellkrogza/The-Big-List-of-Hacked-Malware-Web-Sites
- https://github.com/mitchellkrogza/Suspicious.Snooping.Sniffing.Hacking.IP.Addresses
- https://github.com/mitchellkrogza/Fail2Ban.WebExploits

************************************************
### Acknowledgements & Contributors:

Many parts of the generator scripts and code running behind this project have been adapted from multiple sources. In fact it's so hard to mention everyone but here are a few key people whose little snippets of code have helped me introduce new features all the time. Show them some love and check out some of their projects too

- Luke Taylor @lutaylor (Improvements to the install and update scripts and fixing paths for Apache 2.2, 2.4 and CentOS Versions)
- Konstantin Goretzki @konstantingoretzki https://github.com/konstantingoretzki (Improved Regex on Fail2Ban Filter)
- Stevie-Ray Hartog https://github.com/Stevie-Ray
- Nissar Chababy @funilrys - https://github.com/funilrys/funceble (Excellent script for checking ACTIVE, INACTIVE and EXPIRED Domain Names)
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

************************************************
### INTO PHOTOGRAPHY?

Come drop by and visit me at [mitchellkrog.com](https://mitchellkrog.com) or [Facebook](https://www.facebook.com/MitchellKrogPhotography) or Follow Me on Twitter <a href='https://twitter.com/MitchellKrog'><img src='https://img.shields.io/twitter/follow/MitchellKrog.svg?style=social&label=Follow' alt='Follow @MitchellKrog'></a>

************************************************
## Help Support This Project 

[<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/kofi4.png" alt="Buy me Coffee" width="300"/>](https://ko-fi.com/mitchellkrog)

<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/zuko.png"/>

************************************************

## Update Notification System

Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

************************************************

## Also follow me on twitter <a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

************************************************
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
