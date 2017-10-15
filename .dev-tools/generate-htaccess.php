#!/home/travis/.phpenv/shims/php
<?php
    /* .htaccess File Generator Script for the Apache Ultimate Bad Bot Blocker
     * Adapted from Script Copyright (c) 2017 Stevie-Ray - https://github.com/Stevie-Ray
     * Adapted by: Mitchell Krog (mitchellkrog@gmail.com) - https://github.com/mitchellkrogza
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
    }

    /**
     * @return array for bad referrers
     */
    public function domainWorker()
    {
        $domainsFile = "/home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_generator_lists/bad-referrers.list";

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
        $domainsFile = "/home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/.dev-tools/_htaccess_generator_files/bad-user-agents.list";
        //$domainsFile = "/home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_generator_lists/bad-user-agents.list";
        

        $handle = fopen($domainsFile, "r");
        if (!$handle) {
            throw new \RuntimeException('Error opening file ' . $domainsFile);
        }
        $lines2 = array();
        while (($line = fgets($handle)) !== false) {
                //$line = trim(preg_replace('/\s/', '\s', $line)); // We replace space with '\s'
    			//$line = str_replace('/', '\/',$line); // We replace '/' with '\/' 
            
            
            // convert internationalized domain names
            //if (preg_match('/[А-Яа-яЁёɢ]/u', $line)) {

                //$IDN = new IdnaConvert();

                //$line = $IDN->encode($line);

            //}

            if (empty($line)) {
                continue;
            }
            $lines2[] = $line;
        }
        //fclose($handle);
        //$uniqueLines = array_unique($lines2, SORT_STRING);
        //sort($uniqueLines, SORT_STRING);
        //if (is_writable($domainsFile)) {
        //    file_put_contents($domainsFile, implode("\n", $uniqueLines));
        //} else {
        //    trigger_error("Permission denied");
        //}

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
        $file = "/home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_htaccess_versions//htaccess-mod_rewrite.txt";
        $data = "## Apache Spam Referer Blocker .htaccess version for mod_rewrite.c\n##################################################################\n## Rename this file to .htaccess\n##################################################################\n# " . $this->projectUrl . "\n\n### Version Information #\n### Version Information ##\n\n" .
            "<IfModule mod_rewrite.c>\nRewriteEngine On\n";
        //foreach ($lines2 as $line) {
            //if ($line === end($lines2)) {
                //$data .= "RewriteCond %{HTTP_USER_AGENT} ^" . $line . ".* [NC]\n";
                //break;
            //}

            $data .= "RewriteCond %{HTTP_USER_AGENT} ^" . $line . ".* [NC,OR]\n";
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
        $file = "/home/travis/build/mitchellkrogza/apache-ultimate-bad-bot-blocker/_htaccess_versions/htaccess-mod_setenvif.txt";
        $data = "##Apache Spam Referer Blocker .htaccess version for mod_senenvif.c\n##################################################################\n## Rename this file to .htaccess\n##################################################################\n# " . $this->projectUrl . "\n\n### Version Information #\n### Version Information ##\n\n";
        $data .= "<IfModule mod_setenvif.c>\n";
        foreach ($lines2 as $line) {
            $data .= "SetEnvIfNoCase User-Agent ^" . preg_quote($line) . ".* spambot=yes\n";
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

}
$generator = new Generator();
$generator->generateFiles();