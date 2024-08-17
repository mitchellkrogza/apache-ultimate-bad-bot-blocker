#!/home/travis/.phpenv/shims/php
<?php
    /* .htaccess File Generator Script for the Apache Ultimate Bad Bot Blocker
     * Adapted from Original Script Copyright (c) 2017 Stevie-Ray - https://github.com/Stevie-Ray
     * Adapted by: Mitchell Krog (mitchellkrog@gmail.com) - https://github.com/mitchellkrogza
     * With Contributions by: Nissar Chababy - https://github.com/funilrys
     * Repo Url: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker
     */
namespace mitchellkrogza;

use Mso\IdnaConvert\IdnaConvert;

class Generator
{

    private $projectUrl = "https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker";
    public function generateFiles()
    {
        date_default_timezone_set('Africa/Johannesburg');
        $date = date('Y-m-d H:i:s');
        $lines = $this->domainWorker();
        $lines2 = $this->domainWorker2();
        $this->createApache1($date, $lines, $lines2);
        $this->createApache2($date, $lines, $lines2);
        $this->createOLS($date, $lines, $lines2);
    }

    /**
     * @return array for bad referrers
     */
    public function domainWorker()
    {
        $domainsFile = "./_generator_lists/bad-referrers.list";

        $handle = fopen($domainsFile, "r");
        if (!$handle) {
            throw new \RuntimeException('Error opening file ' . $domainsFile);
        }
        $lines = array();
        while (($line = fgets($handle)) !== false) {
            $line = trim(preg_replace('/\s\s+/', ' ', $line));

            // convert internationalized domain names
            if (preg_match('/[А-Яа-яЁёɢ]/u', $line)) {

                $IDN = new IdnaConvert();

                $line = $IDN->encode($line);

            }

            if (empty($line)) {
                continue;
            }
            $lines[] = $line;
        }
        fclose($handle);
        $uniqueLines = array_unique($lines, SORT_STRING);
        sort($uniqueLines, SORT_STRING);
        if (is_writable($domainsFile)) {
            file_put_contents($domainsFile, implode("\n", $uniqueLines));
        } else {
            trigger_error("Permission denied");
        }

        return $lines;
    }

    /**
     * @return array for bad user-agents
     */
    public function domainWorker2()
    {
        $domainsFile = "./dev-tools/_htaccess_generator_files/bad-user-agents.list";

        $handle = fopen($domainsFile, "r");
        if (!$handle) {
            throw new \RuntimeException('Error opening file ' . $domainsFile);
        }
        $lines2 = array();
        while (($line = fgets($handle)) !== false) {
                $line = trim($line);
            if (empty($line)) {
                continue;
            }
            $lines2[] = $line;
        }
        fclose($handle);
        $uniqueLines = array_unique($lines2, SORT_STRING);
        sort($uniqueLines, SORT_STRING);
        return $lines2;
    }

    /**
     * @param $file
     * @param $data
     */
    protected function writeToFile($file, $data)
    {
        if (is_writable($file)) {
            file_put_contents($file, $data);
            if (!chmod($file, 0755)) {
                trigger_error("Couldn't not set " . basename($file) . " permissions to 755");
            }
        } else {
            trigger_error("Permission denied");
        }
    }


    /**
     * @param string $date
     * @param array $lines
     */
    public function createApache1($date, array $lines, array $lines2)
    {
        $file = "./_htaccess_versions//htaccess-mod_rewrite.txt";
        $data = "## Apache Spam Referer Blocker .htaccess version for mod_rewrite.c\n##################################################################\n## Rename this file to .htaccess\n##################################################################\n# " . $this->projectUrl . "\n\n### Version Information #\n### Version Information ##\n\n" .
            "<IfModule mod_rewrite.c>\nRewriteEngine On\nRewriteCond %{HTTP_USER_AGENT} ^\W [OR]\n";
        foreach ($lines2 as $line) {
            $data .= "RewriteCond %{HTTP_USER_AGENT} \b" . $line . "\b [NC,OR]\n";
        }
        foreach ($lines as $line) {
            if ($line === end($lines)) {
                $data .= "RewriteCond %{HTTP_REFERER} ^http(s)?://(www.)?.*" . preg_quote($line) . ".*$ [NC]\n";
                break;
            }

            $data .= "RewriteCond %{HTTP_REFERER} ^http(s)?://(www.)?.*" . preg_quote($line) . ".*$ [NC,OR]\n";
        }
        $data .= "RewriteRule ^(.*)$ – [F,L]\n</IfModule>\n\n\n# For Apache 2.2 Use\n<IfModule !mod_authz_core.c>\n\t<IfModule mod_authz_host.c>\n\t\t" .
            "Order allow,deny\n\t\tAllow from all\n\t\tDeny from env=spambot\n\t</IfModule>\n</IfModule>\n\n\n# " .
            "For Apache 2.4 Use\n<IfModule mod_authz_core.c>\n\t<RequireAll>" .
            "\n\t\tRequire all granted\n\t\tRequire not env spambot\n\t</RequireAll>\n</IfModule>";
      $this->writeToFile($file, $data);
    }
    /**
     * @param string $date
     * @param array $lines
     */
    public function createApache2($date, array $lines, array $lines2)
    {
        $file = "./_htaccess_versions/htaccess-mod_setenvif.txt";
        $data = "##Apache Spam Referer Blocker .htaccess version for mod_senenvif.c\n##################################################################\n## Rename this file to .htaccess\n##################################################################\n# " . $this->projectUrl . "\n\n### Version Information #\n### Version Information ##\n\n";
        $data .= "<IfModule mod_setenvif.c>\n\nSetEnvIfNoCase User-Agent ^\W spambot=yes\n";
        foreach ($lines2 as $line) {
            $data .= "SetEnvIfNoCase User-Agent \b" . $line . "\b spambot=yes\n";
        }
        foreach ($lines as $line) {
            $data .= "SetEnvIfNoCase Referer " . preg_quote($line) . " spambot=yes\n";
        }
        $data .= "</IfModule>\n\n\n# For Apache 2.2 Use\n<IfModule !mod_authz_core.c>\n\t<IfModule mod_authz_host.c>\n\t\t" .
            "Order allow,deny\n\t\tAllow from all\n\t\tDeny from env=spambot\n\t</IfModule>\n</IfModule>\n\n\n# " .
            "For Apache 2.4 Use\n<IfModule mod_authz_core.c>\n\t<RequireAll>" .
            "\n\t\tRequire all granted\n\t\tRequire not env spambot\n\t</RequireAll>\n</IfModule>";
      $this->writeToFile($file, $data);
    }

    /**
     * @param string $date
     * @param array $lines
     */
    public function createOLS($date, array $lines, array $lines2)
    {
        $file = "./OpenLitespeed_htaccess/.htaccess";
        $data = "## Bad Bot and Spam Referer Blocker .htaccess version for OpenLiteSpeed \n##################################################################\n### ADD this section to the TOP of your .htaccess file on OpenLitespeed\n### Graceful restart the server for the rules to take effect\n### Do not overwrite your whole .htaccess with this only place at the beginning\n##########################################################################\n## REPO: https://github.com/mitchellkrogza/apache-ultimate-bad-bot-blocker\n## MIT Licence: Mitchell Krog - mitchellkrog@gmail.com\n########################################################################## " . $this->projectUrl . "\n\n### Version Information #\n### Version Information ##\n\n" .
            "<IfModule LiteSpeed>\nRewriteEngine On\n";
        foreach ($lines2 as $line) {
            $data .= "RewriteCond %{HTTP_USER_AGENT} \b" . $line . "\b [NC,OR]\n";
        }
        foreach ($lines as $line) {
            if ($line === end($lines)) {
                $data .= "RewriteCond %{HTTP_REFERER} ^http(s)?://(www.)?.*" . preg_quote($line) . ".*$ [NC]\n";
                break;
            }

            $data .= "RewriteCond %{HTTP_REFERER} ^http(s)?://(www.)?.*" . preg_quote($line) . ".*$ [NC,OR]\n";
        }
        $data .= "RewriteRule ^(.*)$ - [F,L]\n</IfModule>";
      $this->writeToFile($file, $data);
    }


}
$generator = new Generator();
$generator->generateFiles();
