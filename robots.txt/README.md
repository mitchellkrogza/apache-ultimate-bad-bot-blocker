# Robots.txt Directives ONLY for People unable to use the Apache Bot and Spam Referrer Blocker
### If this helps you [why not buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:
## DO NOT use this on any of your sites if you are running the Bad Bot and Spam Referrer Blocker (not needed)

_______________
#### Version: V3.2021.05.1208
#### Bad Referrer Count: 7051
#### Bad Bot Count: 610
____________________

The robots.txt file residing in this directory can be used to ADD onto your existing robots.txt file by placing this after anything you already have in your robots.txt file.

## Do NOT make this file the only contents of your robots.txt file !!!

##### 1. Click on the robots.txt file in this directory
##### 2. Then click on the button that says RAW, this will give you clear unformatted code
##### 3. Then copy those contents to paste into your robots.txt file

If your existing robots.txt file looks like this:

    User-agent: *
    Allow: /wp-admin/admin-ajax.php

Then your new file will look like this:

    User-agent: *
    Allow: /wp-admin/admin-ajax.php
    User-agent: Acunetix
    Disallow:/
    User-agent: FHscan
    Disallow:/
    User-agent: masscan
    Disallow:/
    ........ rest of file contents

# You use this at your own risk

This will only help stop some bad bots from gaining access to your site
this certainly does not provide nearly as much protection as the full
Apache Bad Bot and Spam Referrer Blocker

### If this helped you [buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer:

## Update Notification System
Please subscribe your email address to the mailing list at **https://groups.google.com/forum/#!forum/apache-ultimate-bad-bot-blocker**
or simply send a blank email to **apache-ultimate-bad-bot-blocker+subscribe@googlegroups.com** to subscribe.
**Please make sure you are subscribed to notifications** to be notified when the blocker is updated and also to be notified when any important or mission critical changes take place.

## Also follow me on twitter @ubuntu101za for update notifications
