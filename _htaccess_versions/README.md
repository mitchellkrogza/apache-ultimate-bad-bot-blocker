<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-ultimate-bad-bot-referrer-blocker-script.png" alt="Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker - Apache Block Bad Bots, User-Agents, Vulnerability Scanners, Malware, Adware, Ransomware, Malicious Sites, Spam Referrers, Bad Referrers, Spam Blocker, Porn Blocker, Gambling Blocker,  Wordpress Theme Detector Blocking and Fail2Ban Jail for Repeat Offenders"/><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/LICENSE.md)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![GitHub release](https://img.shields.io/github/release/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/releases/latest)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![Build Status](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg?branch=master)](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/><a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

# Apache Spam Referrer Blocker .htaccess versions
## Copyright - https://github.com/mitchellkrogza

_______________
#### Version: V3.2021.05.1208
#### Bad Referrer Count: 7051
#### Bad Bot Count: 610
____________________

### for mod_rewrite.c and mod_setenvif.c modules

These .htaccess files are provided for users who do not have root access to their Apache servers and are unable to run the Apache Bad Bot and Spam Referrer Blocker script. 

By using one of the .htaccess file versions in your root directory in conjunction with the robots.txt file also provided in this repository this should cover your site from most bad bots and spam referrers.

### If this helps you [why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer: 

####There are two versions - you choose which one works for you

- One using the mod_rewrite.c module
- One using the mod_setenvif.c module

##### For Apache 2.2 Users - You Will Need the Following:

```
<IfModule !mod_authz_core.c>
	<IfModule mod_authz_host.c>
		Order allow,deny
		Allow from all
		Deny from env=spambot
	</IfModule>
</IfModule>
```

###### For Apache 2.4 Users - You Will Need the Following

```
<IfModule mod_authz_core.c>
	<RequireAll>
		Require all granted
		Require not env spambot
	</RequireAll>
</IfModule>
```

### If this helped you [why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer: 

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.
