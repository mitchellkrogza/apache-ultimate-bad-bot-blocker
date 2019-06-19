# Fail2Ban Blacklist for Repeat Offenders of Apache (action.d)

************************************************
# Add on for Apache Ultimate Bad Bot and Spam Referrer Blocker
GitHub: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker
************************************************

************************************************
- Created by: https://github.com/mitchellkrogza for use on Nginx Web Server https://www.nginx.com/
- Copyright Mitchell Krog <mitchellkrog@gmail.com>

************************************************
- Tested On: Fail2Ban 0.9.3 > 0.10.2
- Server: Ubuntu 16.04.2 / Ubuntu 18.04.2
- Firewall: IPTables
************************************************

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.
************************************************

## Also follow me on twitter @ubuntu101za for update notifications

## Help Support This Project 

[<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/kofi4.png" alt="Buy me Coffee" width="300"/>](https://ko-fi.com/mitchellkrog)

************************************************
## Dependancies: 
##### requires apacherepeatoffender.conf in /etc/fail2ban/filter.d folder
##### requires apacherepeatoffender.conf in /etc/fail2ban/action.d folder
##### requires jail settings called [apacherepeatoffender]
##### requires apache.repeatoffender file in /etc/fail2ban

Create With:

`sudo touch /etc/fail2ban/apache.repeatoffender`

`sudo chmod +x /etc/fail2ban/apache.repeatoffender`

************************************************
## Drawbacks: 
Only works with IPTables

************************************************
:exclamation::exclamation::exclamation:
## Important Configuration Notes:

**You MUST have your file paths and default status for "enabled" declared by means of the recommended include in your [INCLUDES] section of your jail.conf or jail.local otherwise fail2ban will fail reloading when it cannot find the location `apache_access_log` or `nginx_access_log` you can also hard code log locations in your jail settings but this NOT a recommended or good practice. Your jail.local or jail.conf should have the includes as below.**

```
[INCLUDES]
before = paths-common.conf
enabled - false
```
or
```
[INCLUDES]
before = paths-debian.conf
enabled - false
```

**Please Note:**

Above we have the recommended default of "enabled = false" this is recommended good practice. 
It disables all jails until you enable each one manually. 

**To DEBUG Fail2Ban when it will not reload PLEASE follow the following commands in this exact order. Then post your error messages in a NEW ISSUE. ONLY post the last 3-4 lines where the error starts NOT the whole log message.**

`sudo service fail2ban stop`

`sudo fail2ban-client -vvv -x stop`

`sudo fail2ban-client -vvv -x start`

The 3rd step runs fail2ban in verbose client mode and will point you to the exact location where Fail2Ban stopped loading. Once you have this error message copy ONLY the last 3-4 lines and post them in a new ISSUE although if you read the message you shold quickly understand why you broke Fail2Ban and why it is not loading.

Once you have the error message or have fixed your error you just restart Fail2Ban as follows:

`sudo service fail2ban restart`

************************************************
## DOES NOT WORK - MY FAIL2BAN WON'T RESTART???

**Yes it does work**, if you followed the instructions that is. It works and has been tested on almost every version of Fail2Ban.
The most IMPORTANT steps of DEBUGGING Fail2Ban and why it fails reloading are posted just above this message. 
For your convenience I will post them again as they are extremely important steps for debugging Fail2Ban not only for this jail but any jail.

`sudo service fail2ban stop`

`sudo fail2ban-client -vvv -x stop`

`sudo fail2ban-client -vvv -x start`


************************************************
## Based on: 
The Recidive Jail from Fail2Ban

This custom filter and action for Fail2Ban will monitor your Apache logs and perma-ban
any IP address that has generated far too many 403 errors over a 1 week period
and ban them for 1 day. This works like a charm as an add-on for my Apache Bad
Bot Blocker which takes care of generating the 403 errors based on the extensive
list of Bad Referers, Bots, Scrapers and IP addresses that it covers. This provides short
block periods of one day which is enough to keep agressive bots from filling up your log files.
See - https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker for more info on the Apache Bad Bot and Spam Referrer Blocker

This custom action requires a custom jail in your jail.local file for Fail2Ban

Your jail file would be configured as follows

```
[apacherepeatoffender]
enabled = true
logpath = %(apache_access_log)s
filter = apacherepeatoffender
banaction = apacherepeatoffender
bantime  = 86400   ; 1 day
findtime = 604800   ; 1 week
maxretry = 20
```

************************************************
## Help Support This Project 

[<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/kofi4.png" alt="Buy me Coffee" width="300"/>](https://ko-fi.com/mitchellkrog)

************************************************
## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

### Writing Code like this takes lots of time !!

## Help Support This Project 

[<img src="https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/.assets/kofi4.png" alt="Buy me Coffee" width="300"/>](https://ko-fi.com/mitchellkrog)

<img src="https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/.assets/zuko.png"/>

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