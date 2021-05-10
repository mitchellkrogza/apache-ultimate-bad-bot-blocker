<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-ultimate-bad-bot-referrer-blocker-script.png" alt="Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker - Apache Block Bad Bots, User-Agents, Vulnerability Scanners, Malware, Adware, Ransomware, Malicious Sites, Spam Referrers, Bad Referrers, Spam Blocker, Porn Blocker, Gambling Blocker,  Wordpress Theme Detector Blocking and Fail2Ban Jail for Repeat Offenders"/><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/LICENSE.md)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![GitHub release](https://img.shields.io/github/release/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/releases/latest)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![Build Status](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg?branch=master)](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/><a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

# CONFIGURATION INSTRUCTIONS FOR THE APACHE BAD BOT BLOCKER:
### PLEASE READ CONFIGURATION INSTRUCTIONS BELOW THOROUGHLY

##### Created by: https://github.com/mitchellkrogza
##### Copyright Mitchell Krog <mitchellkrog@gmail.com>

_______________
#### Version: V3.2021.05.1207
#### Bad Referrer Count: [7035](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list)
#### Bad Bot Count: [608](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)
#### Fake Googlebots: [217](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list)
____________________

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

## Also follow me on twitter <a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-1.png"/>

**COPY THE GLOBALBLACKLIST.CONF FILE FROM THE REPO**

Copy the contents of **globalblacklist.conf** into your /etc/apache2/custom.d folder. 
**You need to create this folder.**

`sudo mkdir /etc/apache2/custom.d`

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/globalblacklist.conf -O globalblacklist.conf`

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-2.png"/>

**WHITELIST ALL YOUR OWN DOMAIN NAMES AND IP ADDRESSES**

Whitelist all your own domain names and IP addresses. **Please note important changes**, this is now done using include files so that you do not have to keep reinserting your whitelisted domains and IP addresses every time you update.

`cd /etc/apache2/custom.d`

- copy the whitelist-ips.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/whitelist-ips.conf -O whitelist-ips.conf`


- copy the whitelist-domains.conf file into the same folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/whitelist-domains.conf -O whitelist-domains.conf`

Use nano, vim or any other text editor to edit both whitelist-ips.conf and whitelist-domains.conf to include all your own domain names and IP addresses that you want to specifically whitelist from the blocker script. 

When pulling any future updates now you can simply pull the latest globalblacklist.conf file and it will automatically include your whitelisted domains and IP addresses. No more remembering having to do this yourself.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-3.png"/>

**DOWNLOAD CUSTOM BLACKLIST INCLUDE FILE FOR IP ADDRESS AND IP RANGE BLOCKING**

Blacklist any IP addresses or Ranges you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

`cd /etc/apache2/custom.d`

- copy the blacklist-ips.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/blacklist-ips.conf -O blacklist-ips.conf`


Use nano, vim or any other text editor to edit the blacklist-ips.conf file as you like. 

When pulling any future updates now your custom IP blacklist will not be overwritten.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-4.png"/>

**DOWNLOAD CUSTOM BAD REFERRER WORDS INCLUDE FILE FOR CUSTOMIZED SCANNING OF BAD WORDS**

Scan for any bad referrer words you wish to keep out of your servers. **Please note important changes**, this is now done using include files so that you have full control over what IP addresses and IP Ranges and blocked from your Apache Server.

`cd /etc/apache2/custom.d`

- copy the bad-referrer-words.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/bad-referrer-words.conf -O bad-referrer-words.conf`


Use nano, vim or any other text editor to edit the bad-referrer-words.conf file as you like. 

When pulling any future updates now your custom bad referrer words list will not be overwritten.


************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-5.png"/>

**DOWNLOAD CUSTOM BLACKLIST USER-AGENTS INCLUDE FILE FOR CUSTOMIZED BLOCKING OF USER AGENTS**

Allows you to add your own custom list of user agents with this new include file.

`cd /etc/apache2/custom.d`

- copy the blacklist-user-agents.conf file into that folder

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/blacklist-user-agents.conf -O blacklist-user-agents.conf`


Use nano, vim or any other text editor to edit the blacklist-user-agents.conf file as you like. 

When pulling any future updates now your custom bad referrer words list will not be overwritten.

**NOTE:** On the Apache Blocker if you want to over-ride any of the whitelisted bots you can add them to this include file and the previously whitelisted bots in the blocker will be over-ridden by this include file. So let's say for some "obscure" reason you really do not want any search engines like Googlebot or Bingbot to ever access or index your site, you add them to your blacklist-user-agents.conf and they will be over-ridden from the earlier whitelisting in the blocker. This now gives users total control over the blocker without every having to try and modify the globalblacklist.conf file. So now you can customize all your include files and you can still pull the daily updates of globalblacklist.conf and it will not touch any of your custom include files.

************************************************
<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/step-6.png"/>

**INCLUDE THE GLOBALBLACKLIST.CONF FILE INTO A VIRTUALHOST**

 Include the globalblacklist.conf file in the beginning of a directory block just after your opening Options statements and before the rest of your host config example below. **Remove the "<<<<<< This needs to be added" part**

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

`cd /etc/apache2/custom.d`

`sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/globalblacklist.conf -O globalblacklist.conf`

`sudo apache2ctl configtest`

`sudo service apache2 reload` 

And you will be up to date with all your whitelisted domains included automatically for you now. 

************************************************
# AUTO UPDATING:

See my latest auto updater bash script at:

https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/update-apacheblocker.sh

Relax now and sleep better at night knowing your site is telling all those baddies FORBIDDEN !!!

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
### Acknowledgements:

Many parts of the generator scripts and code running behind this project have been adapted from multiple sources. In fact it's so hard to mention everyone but here are a few key people whose little snippets of code have helped me introduce new features all the time. Show them some love and check out some of their projects too

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
Thousand of hours of programming and testing have gone into this project, show some love

[![Help me out with a mug of beer](https://img.shields.io/badge/Help%20-%20me%20out%20with%20a%20mug%20of%20%F0%9F%8D%BA-blue.svg)](https://paypal.me/mitchellkrog/) or [![Help me feed my cat](https://img.shields.io/badge/Help%20-%20me%20feed%20my%20hungry%20cat%20%F0%9F%98%B8-blue.svg)](https://paypal.me/mitchellkrog/)

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
