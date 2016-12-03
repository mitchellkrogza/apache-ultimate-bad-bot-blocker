# Apache Bad Bot Blocker, Referer Blocker, Bad IP Blocker and Wordpress Theme Detector Blocker
## The Ultimate Bad Bot and Referer Blocker for Apache Web Servers

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
-    Botnet Attack Networks (Mirai)
-    Known Wordpress Theme Detectors (Updated Regularly)
-    SEO companies that your competitors use to try improve their SEO
-    Link Research and Backlink Testing Tools
-    Stopping Google Analytics Ghost Spam

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

So for those of you who SUCK with Regex my Apache Bad Bot Blocker is your saviour !!!

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


## CONFIGURATION EXAMPLE OF APACHE BAD BOT BLOCKER:

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

##Finally - Stopping Google Analytics 'ghost' spam
Simply using the Apache blocker does not stop Google Analytics ghost referral spam 
because they are hitting Analytics directly and not always necessarily touching your website. 
You should use regex filters in Analytics to prevent ghost referral spam.
For this a simple google-exclude.txt file has been created for you and it is updated at the same time
when the Nginx Blocker is updated.

###To stop Ghost Spam on On Analytics
Navigate to your Google Analytics Admin panel and add a Segment. This will need to be done on each and every site
where you want this filter to be in effect.

| Filter          | Session       | Include                                  |
| :-------------: |:-------------:|:----------------------------------------:|
| Hostname        | matches regex | your-website\.com|www\.your-website\.com |

| Filter          | Session       | Exclude                                                       |
| :-------------: |:-------------:|:-------------------------------------------------------------:|
| Hostname        | matches regex | Copy the entire contents from [google-exclude.txt](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/google-exclude.txt) to this field |


- This is free to use and modify as you wish. 
- No warranties are express or implied.
- You use this entirely at your own Risk.
- Fork your own copy from this repo and feel free to change it to your needs or contribute to it.
- If you break it yourself, you fix it yourself.

### If this helped you why not buy me a beer?
<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="XP2AZ4S5HNAWQ">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>


##### Some other free projects

- https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
- https://github.com/mitchellkrogza/Fail2Ban-Blacklist-JAIL-for-Repeat-Offenders-with-Perma-Extended-Banning
- https://github.com/mitchellkrogza/fail2ban-useful-scripts
- https://github.com/mariusv/nginx-badbot-blocker
