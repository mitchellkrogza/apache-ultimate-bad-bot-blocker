[![gitcheese.com](https://api.gitcheese.com/v1/projects/bc50574f-b6dc-4f08-80d4-f6ba5baf0d43/badges)](https://www.gitcheese.com/app/#/projects/bc50574f-b6dc-4f08-80d4-f6ba5baf0d43/pledges/create)

# Apache Spam Referrer Blocker .htaccess versions
## Copyright - https://github.com/mitchellkrogza

### for mod_rewrite.c and mod_setenvif.c modules

These .htaccess files are provided for users who do not have root access to their Apache servers and are unable to run the Apache Bad Bot and Spam Referrer Blocker script. 

By using one of the .htaccess file versions in your root directory in conjunction with the robots.txt file also provided in this repository this should cover your site from most bad bots and spam referrers.

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

### If this helped you [You can buy me a beer](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TNCNMH8QVM78J):beer: or send some cheese for my mouse [![gitcheese.com](https://api.gitcheese.com/v1/projects/bc50574f-b6dc-4f08-80d4-f6ba5baf0d43/badges)](https://www.gitcheese.com/app/#/projects/bc50574f-b6dc-4f08-80d4-f6ba5baf0d43/pledges/create)