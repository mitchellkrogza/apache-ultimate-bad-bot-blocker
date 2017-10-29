<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-ultimate-bad-bot-referrer-blocker-script.png" alt="Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker - Apache Block Bad Bots, User-Agents, Vulnerability Scanners, Malware, Adware, Ransomware, Malicious Sites, Spam Referrers, Bad Referrers, Spam Blocker, Porn Blocker, Gambling Blocker,  Wordpress Theme Detector Blocking and Fail2Ban Jail for Repeat Offenders"/><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/LICENSE.md)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![GitHub release](https://img.shields.io/github/release/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/releases/latest)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![Build Status](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg?branch=master)](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![GitHub Stats](https://img.shields.io/badge/github-stats-ff5500.svg)](http://githubstats.com/mitchellkrogza/apache-ultimate-bad-bot-blocker)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/><a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

************************************************
# PLESK ONYX CONFIGURATION FOR THE ULTIMATE APACHE BAD BOT BLOCKER

This guide is for configuring the Apache Ultimate Bad Bot Blocker on Plesk Onyx 17.x Running on CentOS 7.4.x

This guide ONLY applies to Plesk Onyx Server Configurations where Apache is the main web server and the Nginx Reverse Proxy Function is turned off. A guide for configuring Plesk Servers running with the Nginx Reverse Proxy system will be added as a separate guide.

This guide is for implementing the Blocker on a global level for Plesk meaning the blocker will be applied to ALL web sites configured and running from the Plesk System.

> You CAN implement this on a site by site basis only by paying special attention to the command line we run in **Step 5**

**MAKE SURE you have enabled all required modules on Apache in the Plesk Configuration for Apache - See Step 8**

If this guide helps you why not

[![Help me out with a mug of beer](https://img.shields.io/badge/Help%20-%20me%20out%20with%20a%20mug%20of%20%F0%9F%8D%BA-blue.svg)](https://paypal.me/mitchellkrog/) or [![Help me feed my cat](https://img.shields.io/badge/Help%20-%20me%20feed%20my%20hungry%20cat%20%F0%9F%98%B8-blue.svg)](https://paypal.me/mitchellkrog/)


<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/plesk-onyx-web-host-edition-apache-bad-bot-referrer-blocker-setup.jpg" alt="Plesk Onyx Web Host Edition Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker Configuration and Customizing Plesk Apache Vhost Templates"/>


This guide was created using a trial version of Plesk installed with their [all in one ISO](https://autoinstall.plesk.com/iso/plesk-17.0-centos7-x86_64.iso) - [Thank you Plesk](https://www.plesk.com/)
************************************************
## Step 1

Create a custom directory for your Apache vhost configurations. 

`sudo mkdir /usr/local/psa/admin/conf/templates/custom/domain`

************************************************
## Step 2

Copy the default .php template that Plesk uses to create Apache vhosts to this custom folder.

`sudo cp /usr/local/psa/admin/conf/default/domain/domainVirtualHost.php /usr/local/psa/admin/conf/templates/custom/domain/`

************************************************
## Step 3

Edit the custom version of domainVirtualHost.php

`sudo nano /usr/local/psa/admin/conf/templates/custom/domain/domainVirtualHost.php`

Scroll to Line 210 which you will see is an ending `</Directory>` statement.

The section looks like this:

```
Options <?php echo $VAR->domain->physicalHosting->ssi ? '+' : '-' ?>Includes <?php echo $VAR->domain->physicalHosting->cgi && $webuser->cgi ? '+' : '-' ?>ExecCGI
</Directory>
```

Modify this section as follows:

```
Options <?php echo $VAR->domain->physicalHosting->ssi ? '+' : '-' ?>Includes <?php echo $VAR->domain->physicalHosting->cgi && $webuser->cgi ? '+' : '-' ?>ExecCGI
Include /etc/apache2/custom.d/globalblacklist.conf
</Directory>
```

Now CTRL+X and Save the file.

************************************************
## Step 4

Download all the required Apache Bad Bot Blocker Files as follows:

```
sudo mkdir /etc/apache2

sudo mkdir /etc/apache2/custom.d

sudo wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/Apache_2.2/custom.d/bad-referrer-words.conf -O /etc/apache2/custom.d/bad-referrer-words.conf

sudo wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/Apache_2.2/custom.d/blacklist-ips.conf -O /etc/apache2/custom.d/bad-referrer-words.conf

sudo wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/Apache_2.2/custom.d/blacklist-user-agents.conf -O /etc/apache2/custom.d/blacklist-user-agents.conf

sudo wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/Apache_2.2/custom.d/globalblacklist.conf -O /etc/apache2/custom.d/globalblacklist.conf

sudo wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/Apache_2.2/custom.d/whitelist-domains.conf -O /etc/apache2/custom.d/whitelist-domains.conf

sudo wget https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/raw/master/Apache_2.2/custom.d/whitelist-ips.conf -O /etc/apache2/custom.d/whitelist-ips.conf

```

************************************************
## Step 5

Tell Plesk to reconfigure all domains on the server using our new customized version of domainVirtualHost.php

`sudo /usr/local/psa/admin/sbin/httpdmng --reconfigure-all`

### OR if you only want to activate and test it on one domain you can do the following instead.

`sudo /usr/local/psa/admin/sbin/httpdmng --reconfigure-domain mydomain1.com`

************************************************
## Step 6

If either of the above commands returned no errors the bot blocker should be running on all or just the one site you made the change on.

You can confirm this by looking at the httpd.conf file for a vhost. In this case we use an example domain name of mydomain1.com

`sudo nano /var/www/vhosts/system/mydomain1.com/conf/httpd.conf`

Scroll down in the file and you will see the Include as below.

```
Include /etc/apache2/custom.d/globalblacklist.conf
</Directory>
```

************************************************
## Step 7

Test the curl commands against the site to confirm the blocker is working. Once again we use the example domain name of mydomain1.com

From the command line run the following:

`curl -I http://mydomain1.com -e http://www.google.com`

and you will get a 200 OK response.

Now run

`curl -I http://mydomain1.com -e http://www.zx6.ru`

and you will get a 403 Forbidden response.

This means the blocker is active and working.

************************************************
## Step 8 

If you encounter any problems make sure all the following Apache modules are loaded on your Plesk System.

From the command line run.

`sudo httpd -M` and you will see the following

<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/plesk-onyx-apache-modules.jpg" alt="Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker for Plesk Onyx Apache Web Server"/>

************************************************
## Step 9

Enjoy !!! and Please Help Support This Project 

[![Help me out with a mug of beer](https://img.shields.io/badge/Help%20-%20me%20out%20with%20a%20mug%20of%20%F0%9F%8D%BA-blue.svg)](https://paypal.me/mitchellkrog/) or [![Help me feed my cat](https://img.shields.io/badge/Help%20-%20me%20feed%20my%20hungry%20cat%20%F0%9F%98%B8-blue.svg)](https://paypal.me/mitchellkrog/)


<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/plesk-control-panel.jpg" alt="Plesk Onyx Web Host Edition Admin Interface Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker Configuration and Customizing Plesk Apache Vhost Templates"/>

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