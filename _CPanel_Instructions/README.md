<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/apache-ultimate-bad-bot-referrer-blocker-script.png" alt="Apache Ultimate Bad Bot, User-Agent and Spam Referrer Blocker - Apache Block Bad Bots, User-Agents, Vulnerability Scanners, Malware, Adware, Ransomware, Malicious Sites, Spam Referrers, Bad Referrers, Spam Blocker, Porn Blocker, Gambling Blocker,  Wordpress Theme Detector Blocking and Fail2Ban Jail for Repeat Offenders"/><img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![DUB](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/LICENSE.md)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![GitHub release](https://img.shields.io/github/release/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg)](https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/releases/latest)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/>[![Build Status](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker.svg?branch=master)](https://travis-ci.org/mitchellkrogza/apache-ultimate-bad-bot-blocker)<img src="https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/blob/master/.assets/spacer.jpg"/><a href='https://twitter.com/ubuntu101za'><img src='https://img.shields.io/twitter/follow/ubuntu101za.svg?style=social&label=Follow' alt='Follow @ubuntu101za'></a>

### If this helps you [You can buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

# CPANEL user instructions for the Apache Ultimate Bad Bot, User-Agent and Spam Referrer  Blocker

_______________
#### Version: V3.2021.06.1210
#### Bad Referrer Count: [7060](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list)
#### Bad Bot Count: [615](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)
#### Fake Googlebots: [217](https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list)
____________________

- Created by: https://github.com/mitchellkrogza
- Copyright Mitchell Krog <mitchellkrog@gmail.com>
## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

## Also follow me on twitter @ubuntu101za for update notifications

For people wanting to run this bad bot and spam referrer blocker on Cpanel systems, here is a sample configuration excerpt for a single vhost. This came from a user who I helped to get the Apache Bad Bot Blocker working on CPanel.

The configuration below is for an SSL site and includes the very important http (port 80) redirect to https (Port 443) which a lot of people tend to forget about.

Once you have modified your httpd.conf file as below on CPanel you will of course do a restart of apache.

## To Test Bad Referers

Then you must test running the following from the command line of another unix machine.

`curl -I https://yourdomain.com -e http://100dollars-seo.com`

`curl -I https://yourdomain.com -e http://xxxrus.org`

`curl -I https://yourdomain.com -e https://100dollars-seo.com`

`curl -I https://yourdomain.com -e https://sexobzor.info`

`curl -I https://yourdomain.com -e ftp://sexobzor.info`

You will get a 403 forbidden response meaning the Apache Bad Bot Blocker is working. You will also notice if a bad referer comes from http://, https:// or even ftp:// it is blocked due to the special regex in this blocker which ignores whether it comes from http://, https:// or even ftp:// it is detected and BLOCKED !!!

Then try the following commands against your http site

`curl -I http://yourdomain.com -e http://100dollars-seo.com`

`curl -I http://yourdomain.com -e http://xxxrus.org`

`curl -I http://yourdomain.com -e https://100dollars-seo.com`

`curl -I http://yourdomain.com -e https://sexobzor.info`

You should see the response give you a 301 redirect:

```
HTTP/1.1 301 Moved Permanently
Location: https://yourdomain.com/
```

This means it is redirecting all http traffic (port 80) to https (port 443). At this point most bad bots and bad referrers give up and will not even bother to follow the redirect. If they do however they will get blocked. 

You can change this behavior however by also adding the `Include /etc/apache2/custom.d/globalblacklist.conf` into the `<VirtualHost 1.2.3.4:80>` section of your config below before the ReWrite conditions take effect. Which means bots and bad referers hitting your http site will get blocked and will not even be shown the redirect to your https site. (see in config example below)

## To Test Bad User Agents

To test further, install User-Agent Switcher for Chrome, set up a few bad bots like 80legs, masscan, AhrefsBot and switch to them while viewing your site in Chrome and you will see 403 Forbidden errors meaning the Bad Bot Blocker is working.

Or again using for those who love the command line. On another unix machine try some of these.

`curl -A "80Legs" https://yourdomain.com`

`curl -A "websucker" https://yourdomain.com`

`curl -A "masscan" https://yourdomain.com`

`curl -A "WeBsuCkEr" https://yourdomain.com`

`curl -A "WeB suCkEr" https://yourdomain.com`

`curl -A "Exabot" https://yourdomain.com`

You will get 403 forbidden responses on all of them meaning the Apache Bad Bot Blocker is working 100%. You will also notice if a bot like websucker changes it's name to WeBsuCkEr it is detected regardless due to the wonderful case insensitive matching regex of this blocker. Test against any bot or referrer string in the bot blocker and you will always get a 403 forbidden. 

## To Test Good User Agents

Try some of these from the command line of another unix machine and you will see that good bots specified in the Bad Bot blocker are granted access.

`curl -A "GoogleBot" https://yourdomain.com`

`curl -A "BingBot" https://yourdomain.com`

Now you can rest knowing your site is protected against over 4000 and growing bad bots and spam referrers and allowing all the good one's through. 

Enjoy it and what this will do for your web site.
 
## Make sure to keep your globalblacklist.conf file up to date 
New referrers and bots are added every other day. Each time you update **MAKE SURE** to copy your whitelist section of IP addresses into the new file. A set of generator scripts are coming soon which will ease this burden for you allowing you to pull from the GIT repo and compile the scripts on your server automatically including your whitelisted IP's each time. These generator scripts are coming soon so please be patient as they have to be thoroughly tested for public use before I release them. 

(See at very bottom of this page for all the Cloudflare IP ranges you should be whitelisting if you are on Cloudflare)

#EXAMPLE Virtualhost configuration on CPanel (excerpt)

```
##################################################
##################################################
#
# Define the virtual host configuration for user domains
#
##################################################
##################################################

### BEGIN: HTTP vhosts list
### CHANGE 1.2.3.4 to your IP address

<VirtualHost 1.2.3.4:443>
  ServerName yourdomain.com
  ServerAlias www.yourdomain.com
  DocumentRoot /home/yourusername/public_html
  ServerAdmin webmaster@yourdomain.com
  UseCanonicalName Off
  CustomLog /etc/apache2/logs/domlogs/yourdomain.com combined
  <IfModule log_config_module>
    <IfModule logio_module>
      CustomLog /etc/apache2/logs/domlogs/yourdomain.com-bytes_log "%{%s}t %I .\n%{%s}t %O ."
    </IfModule>
  </IfModule>
  ## User yourusername # Needed for Cpanel::ApacheConf
  <IfModule userdir_module>
    <IfModule !mpm_itk.c>
      <IfModule !ruid2_module>
        UserDir disabled
        UserDir enabled yourusername 
      </IfModule>
    </IfModule>
  </IfModule>

  # Enable backwards compatible Server Side Include expression parser for Apache versions >= 2.4.
  # To selectively use the newer Apache 2.4 expression parser, disable SSILegacyExprParser in
  # the user's .htaccess file.  For more information, please read:
  #    http://httpd.apache.org/docs/2.4/mod/mod_include.html#ssilegacyexprparser
  <IfModule mod_include.c>
    <Directory "/home/yourusername/public_html">
      SSILegacyExprParser On

      ### INCLUDE THE APACHE ULTIMATE BAD BOT BLOCKER HERE 
      ### make the folder custom.d and place globalblacklist.conf into that folder
	  Include /etc/apache2/custom.d/globalblacklist.conf

    </Directory>
  </IfModule>

  <IfModule mod_suphp.c>
    suPHP_UserGroup yourusername yourusername
  </IfModule>
  <IfModule suexec_module>
    <IfModule !mod_ruid2.c>
      SuexecUserGroup yourusername yourusername
    </IfModule>
  </IfModule>
  <IfModule ruid2_module>
    RMode config
    RUidGid yourusername yourusername
  </IfModule>
  <IfModule mpm_itk.c>
    # For more information on MPM ITK, please read:
    #   http://mpm-itk.sesse.net/
    AssignUserID yourusername yourusername
  </IfModule>

  <IfModule alias_module>
    ScriptAlias /cgi-bin/ /home/yourusername/public_html/cgi-bin/
  </IfModule>
  <IfModule ssl_module>
    SSLEngine on
    
    SSLCertificateFile /var/cpanel/ssl/installed/certs/yourdomain.crt
    SSLCertificateKeyFile /var/cpanel/ssl/installed/keys/yourdomain.key
    SSLCACertificateFile /var/cpanel/ssl/installed/cabundles/cPanel.cabundle
    CustomLog /etc/apache2/logs/domlogs/yourdomain.com-ssl_log combined
    SetEnvIf User-Agent ".*MSIE.*" nokeepalive ssl-unclean-shutdown
    <Directory "/home/yourusername/public_html/cgi-bin">
      SSLOptions +StdEnvVars
    </Directory>
  </IfModule>
    <IfModule proxy_fcgi_module>
        <FilesMatch \.(phtml|php[0-9]*)$>
            SetHandler proxy:unix:/opt/cpanel/ea-php56/root/usr/var/run/php-fpm/044b9a0c70e67fcbb74788ebe4a282b485f743cf.sock|fcgi://yourdomain.com/
        </FilesMatch>
    </IfModule>
</VirtualHost>

### MAKE SURE TO REDIRECT ALL PORT 80 TRAFFIC TO THE SSL HOST ABOVE
### CHANGE 1.2.3.4 to your IP address

<VirtualHost 1.2.3.4:80>
  ServerName yourdomain.com
  ServerAlias www.yourdomain.com

      ### INCLUDE THE APACHE ULTIMATE BAD BOT BLOCKER HERE AGAIN
      ### This will block bots before your server even issues the redirect to port 443
      ### UnComment the include line below if you want this functionality.
	    ###Include /etc/apache2/custom.d/globalblacklist.conf

        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteCond %{HTTP_HOST} ^(?:www\.)?(.*)$ [NC]
        RewriteRule (.*) https://yourdomain.com%{REQUEST_URI} [END,QSA,R=permanent]
</VirtualHost>
```

### If this helped you [You can buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

## CLOUDFLARE CPanel Users
If you are running a CPanel system that is running through Cloudflare (quite likely) you should whitelist all the following ranges including of course your own IP(s). Considering adding this as a permament whitelist in the bot blocker by default.

```
127.0.0.1/32;
YOUR.OWN.IP.ADDR;
103.21.244.0/22;
103.22.200.0/22;
103.31.4.0/22;
104.16.0.0/13.
104.24.0.0/14;
108.162.192.0/18;
131.0.72.0/22;
141.101.64.0/18;
162.158.0.0/15;
172.64.0.0/13;
173.245.48.0/20;
188.114.96.0/20;
190.93.240.0/20;
197.234.240.0/22;
198.41.128.0/17;
199.27.128.0/21;
2400:cb00::/32;
2606:4700::/32;
2803:f800::/32;
2405:b500::/32;
2405:8100::/32;
2c0f:f248::/32
2a06:98c0::/29
```

### Writing code makes me thirsty [Why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

## Also follow me on twitter @ubuntu101za for update notifications
