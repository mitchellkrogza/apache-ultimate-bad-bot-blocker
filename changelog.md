# The Apache Ultimate Bot Blocker
- The Ultimate Bad Bot Blocker for Apache Web Servers
- Created by: https://github.com/mitchellkrogza
- https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/

#### CHANGELOG

##### 2016-07-23
- Added more image hotlinking web sites to referers - gallerily.com, curatorimages.com
and decorationspcs.com
- Modified checking of Referer URL's to check for http or https or the lack thereof.
- Added whitelist for official Google Java Client Github Project and changed checking of
  Java string to User Agents beginning with Java ie. ^Java
  see - https://github.com/google/google-http-java-client
  
##### 2016-07-22
- Added Referer Checking for blocking out spam referer domains and domain hijackers.
- Added new spam referer domains found in recent logs.
- Added Semalt Referers to Referer Checking (comments added in conf file)

##### 2016-07-21
- First commit of this project. Extensively tested now on 2 heavy traffic web sites and
not one false positive or valid browser or crawler has been blocked out only the baddies.