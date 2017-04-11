# CONFIGURATION APACHE BAD BOT BLOCKER FOR CENTOS 6.8 and APACHE 2.2.15:
### PLEASE READ CONFIGURATION INSTRUCTIONS BELOW THOROUGHLY

##### Created by: https://github.com/mitchellkrogza
##### Copyright Mitchell Krog <mitchellkrog@gmail.com>
### Version 2.2017.04

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

# CONFIGURATION OF THE APACHE BAD BOT BLOCKER FOR CENTOS 6.8 and APACHE 2.2.15:

##Step 1:

**CREATE THE conf.d folder needed for Apache on CENTOS 6.8**

**You must create this folder.**

Open Terminal

`su`

`mkdir /etc/httpd/conf.d`

##Step 2:

**COPY THE GLOBALBLACKLIST.CONF FILE FROM THE REPO**

Copy the contents of **globalblacklist.conf** into your /etc/httpd/conf/conf.d folder. 

`cd /etc/httpd/conf.d`

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS6/conf.d/globalblacklist.conf -O globalblacklist.conf`

##Step 3:

**WHITELIST ALL YOUR OWN DOMAIN NAMES AND IP ADDRESSES**

Whitelist all your own domain names and IP addresses. **Please note important changes**, this is now done using include files so that you do not have to keep reinserting your whitelisted domains and IP addresses every time you update.

`cd /etc/httpd/conf.d`

- copy the whitelist-ips.conf file into that folder

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS6/conf.d/whitelist-ips.conf -O whitelist-ips.conf`


- copy the whitelist-domains.conf file into the same folder

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS6/conf.d/whitelist-domains.conf -O whitelist-domains.conf`

Use nano, vim or any other text editor to edit both whitelist-ips.conf and whitelist-domains.conf to include all your own domain names and IP addresses that you want to specifically whitelist from the blocker script. 

When pulling any future updates now you can simply pull the latest globalblacklist.conf file and it will automatically include your whitelisted domains and IP addresses. No more remembering having to do this yourself.

##Step 4:

**INCLUDE THE GLOBALBLACKLIST.CONF FILE INTO A VIRTUALHOST**

 Include the globalblacklist.conf file within a `<Directory>` block just after your opening Options statements and before the rest of your host config example below. 
 
 On CentOS to do this, open your httpd.conf file
 
 `nano /etc/httpd/httpd.conf`
 
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
    Include /etc/httpd/conf.d/globalblacklist.conf
    </Directory>
</VirtualHost>
```

##Step 5:

**RELOAD YOUR APACHE CONFIGURATION**

`service httpd reload`

If you get no errors you followed my instructions properly.

The blocker is now active and working so now you can run some simple tests from another linux machine to make sure it's working.

##Step 6:

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

##Step 7:

**UPDATING THE APACHE BAD BOT BLOCKER** is now easy thanks to the automatic includes for whitelisting your own domain names.

Updating to the latest version is now as simple as:

`cd /etc/httpd/conf.d`

`su`

`wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS6/conf.d/globalblacklist.conf -O globalblacklist.conf`

`service httpd reload` 

And you will be up to date with all your whitelisted domains included automatically for you now. 

# AUTO UPDATING:

See my latest auto updater bash script at:

https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/CentOS6/updateapacheblocker.sh

Relax now and sleep better at night knowing your site is telling all those baddies FORBIDDEN !!!

### Coding makes me very thirsty [Why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.