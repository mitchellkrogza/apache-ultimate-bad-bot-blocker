#CPANEL user instructions for the Apache Ultimate Bad Bot Blocker

For people wanting to run this bad bot blocker on Cpanel systems, here is a sample configuration excerpt for a single vhost. This came from a user who I helped to get the Apache Bad Bot Blocker working on CPanel.

The configuration below is for an SSL site and includes the very important http (port 80) redirect to https (Port 443) which a lot of people tend to forget about.

Once you have modified your httpd.conf file as below on CPanel you will of course do a restart of apache.

Then you must test by doing the following from the command line of another unix machine.

`curl -I https://yourdomain.com -e http://100dollars-seo.com`

You will get a 403 forbidden response meaning the Apache Bad Bot Blocker is working.

Then try

`curl -I http://yourdomain.com -e http://100dollars-seo.com`

You should see the response first give you a 301 redirect to https://yourdomain.com and then a 403 forbidden response from the https version of your site meaning its redirecting to https and also the bad bot blocker is working.

To test further, install User-Agent Switcher for Chrome, set up a few bad bots like 80legs, masscan, AhrefsBot and switch to them while viewing your site in Chrome and you will see 403 Forbidden errors meaning the Bad Bot Blocker is working.

##EXAMPLE Virtualhost configuration on CPanel (excerpt)

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
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteCond %{HTTP_HOST} ^(?:www\.)?(.*)$ [NC]
        RewriteRule (.*) https://yourdomain.com%{REQUEST_URI} [END,QSA,R=permanent]
</VirtualHost>
```