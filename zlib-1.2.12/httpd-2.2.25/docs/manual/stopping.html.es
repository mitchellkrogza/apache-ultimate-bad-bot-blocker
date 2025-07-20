<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"><head><!--
        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
              This file is generated from xml source: DO NOT EDIT
        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      -->
<title>Iniciar y Parar el servidor Apache - Servidor HTTP Apache</title>
<link href="./style/css/manual.css" rel="stylesheet" media="all" type="text/css" title="Main stylesheet" />
<link href="./style/css/manual-loose-100pc.css" rel="alternate stylesheet" media="all" type="text/css" title="No Sidebar - Default font size" />
<link href="./style/css/manual-print.css" rel="stylesheet" media="print" type="text/css" /><link rel="stylesheet" type="text/css" href="./style/css/prettify.css" />
<script src="./style/scripts/prettify.js" type="text/javascript">
</script>

<link href="./images/favicon.ico" rel="shortcut icon" /></head>
<body id="manual-page"><div id="page-header">
<p class="menu"><a href="./mod/">M�dulos</a> | <a href="./mod/directives.html">Directivas</a> | <a href="http://wiki.apache.org/httpd/FAQ">Preguntas Frecuentes</a> | <a href="./glossary.html">Glosario</a> | <a href="./sitemap.html">Mapa de este sitio web</a></p>
<p class="apache">Versi�n 2.2 del Servidor HTTP Apache</p>
<img alt="" src="./images/feather.gif" /></div>
<div class="up"><a href="./"><img title="&lt;-" alt="&lt;-" src="./images/left.gif" /></a></div>
<div id="path">
<a href="http://www.apache.org/">Apache</a> &gt; <a href="http://httpd.apache.org/">Servidor HTTP</a> &gt; <a href="http://httpd.apache.org/docs/">Documentaci�n</a> &gt; <a href="./">Versi�n 2.2</a></div><div id="page-content"><div id="preamble"><h1>Iniciar y Parar el servidor Apache</h1>
<div class="toplang">
<p><span>Idiomas disponibles: </span><a href="./de/stopping.html" hreflang="de" rel="alternate" title="Deutsch">&nbsp;de&nbsp;</a> |
<a href="./en/stopping.html" hreflang="en" rel="alternate" title="English">&nbsp;en&nbsp;</a> |
<a href="./es/stopping.html" title="Espa�ol">&nbsp;es&nbsp;</a> |
<a href="./fr/stopping.html" hreflang="fr" rel="alternate" title="Fran�ais">&nbsp;fr&nbsp;</a> |
<a href="./ja/stopping.html" hreflang="ja" rel="alternate" title="Japanese">&nbsp;ja&nbsp;</a> |
<a href="./ko/stopping.html" hreflang="ko" rel="alternate" title="Korean">&nbsp;ko&nbsp;</a> |
<a href="./tr/stopping.html" hreflang="tr" rel="alternate" title="T�rk�e">&nbsp;tr&nbsp;</a></p>
</div>
<div class="outofdate">Esta traducci�n podr�a estar
            obsoleta. Consulte la versi�n en ingl�s de la
            documentaci�n para comprobar si se han producido cambios
            recientemente.</div>

    <p>Este documento explica como iniciar y parar el servidor Apache
     en sistemas tipo Unix. Los usuarios de Windows NT, 2000 y XP
     deben consultar la secci�n <a href="platform/windows.html#winsvc">Ejecutar Apache como un
     servicio</a> y los usuario de Windows 9x y ME deben consultar <a href="platform/windows.html#wincons">Ejecutar Apache como una
     Aplicaci�n de Consola</a> para obtener informaci�n
     sobre como controlar Apache en esas plataformas.</p>
</div>
<div id="quickview"><ul id="toc"><li><img alt="" src="./images/down.gif" /> <a href="#introduction">Introducci�n</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#term">Parar Apache</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#graceful">Reinicio Graceful</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#hup">Reiniciar Apache</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#race">Ap�ndice: se�ales y race conditions</a></li>
</ul><h3>Consulte tambi�n</h3><ul class="seealso"><li><a href="programs/httpd.html">httpd</a></li><li><a href="programs/apachectl.html">apachectl</a></li></ul><ul class="seealso"><li><a href="#comments_section">Comentarios</a></li></ul></div>
<div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="introduction" id="introduction">Introducci�n</a></h2>

    <p>Para parar y reiniciar Apache, hay que enviar la se�al
    apropiada al proceso padre <code>httpd</code> que se est�
    ejecutando.  Hay dos maneras de enviar estas se�ales.  En
    primer lugar, puede usar el comando de Unix <code>kill</code> que
    env�a se�ales directamente a los procesos. Puede que
    tenga varios procesos <code>httpd</code> ejecutandose en su
    sistema, pero las se�ales deben enviarse solamente al proceso
    padre, cuyo pid est� especificado en la directiva <code class="directive"><a href="./mod/mpm_common.html#pidfile">PidFile</a></code>. Esto quiere decir que no
    debe necesitar enviar se�ales a ning�n proceso excepto
    al proceso padre. Hay tres se�ales que puede enviar al
    proceso padre: <code><a href="#term">TERM</a></code>, <code><a href="#hup">HUP</a></code>, y <code><a href="#graceful">USR1</a></code>, que van a ser descritas a
    continuaci�n.</p>

    <p>Para enviar una se�al al proceso padre debe escribir un
    comando como el que se muestra en el ejemplo:</p>

<div class="example"><p><code>kill -TERM `cat /usr/local/apache2/logs/httpd.pid`</code></p></div>

    <p>La segunda manera de enviar se�ales a los procesos
    <code>httpd</code> es usando las opciones de l�nea de
    comandos <code>-k</code>: <code>stop</code>, <code>restart</code>,
    y <code>graceful</code>, como se muestra m�s abajo.  Estas
    opciones se le pueden pasar al binario <a href="programs/httpd.html">httpd</a>, pero se recomienda que se
    pasen al script de control <a href="programs/apachectl.html">apachectl</a>, que a su vez los
    pasar� a <code>httpd</code>.</p>

    <p>Despu�s de haber enviado las se�ales que desee a
    <code>httpd</code>, puede ver como progresa el proceso
    escribiendo:</p>

<div class="example"><p><code>tail -f /usr/local/apache2/logs/error_log</code></p></div>

    <p>Modifique estos ejemplos para que coincidan con la
    configuraci�n que tenga especificada en las directivas
    <code class="directive"><a href="./mod/core.html#serverroot">ServerRoot</a></code> y <code class="directive"><a href="./mod/mpm_common.html#pidfile">PidFile</a></code> en su fichero principal de
    configuraci�n.</p>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="term" id="term">Parar Apache</a></h2>

<dl><dt>Se�al: TERM</dt>
<dd><code>apachectl -k stop</code></dd>
</dl>

    <p>Enviar las se�ales <code>TERM</code> o <code>stop</code>
    al proceso padre hace que se intenten eliminar todos los procesos
    hijo inmediatamente. Esto puede tardar algunos minutos. Una vez
    que hayan terminado todos los procesos hijo, terminar� el
    proceso padre. Cualquier petici�n en proceso terminar�
    inmediatanmente, y ninguna petici�n posterior ser�
    atendida.</p>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="graceful" id="graceful">Reinicio Graceful</a></h2>

<dl><dt>Se�al: USR1</dt>
<dd><code>apachectl -k graceful</code></dd>
</dl>

    <p>Las se�ales <code>USR1</code> o <code>graceful</code>
    hacen que el proceso padre <em>indique</em> a sus hijos que
    terminen despu�s de servir la petici�n que est�n
    atendiendo en ese momento (o de inmediato si no est�n
    sirviendo ninguna petici�n). El proceso padre lee de nuevo
    sus ficheros de configuraci�n y vuelve a abrir sus ficheros
    log. Conforme cada hijo va terminando, el proceso padre lo va
    sustituyendo con un hijo de una nueva <em>generaci�n</em> con
    la nueva configuraci�n, que empeciezan a servir peticiones
    inmediatamente.</p>

    <div class="note">En algunas plataformas que no permiten usar
    <code>USR1</code> para reinicios graceful, puede usarse una
    se�al alternativa (como <code>WINCH</code>). Tambien puede
    usar <code>apachectl graceful</code> y el script de control
    enviar� la se�al adecuada para su plataforma.</div>

    <p>Apache est� dise�ado para respetar en todo momento la
    directiva de control de procesos de los MPM, as� como para
    que el n�mero de procesos y hebras disponibles para servir a
    los clientes se mantenga en los valores adecuados durante el
    proceso de reinicio.  A�n m�s, est� dise�ado
    para respetar la directiva <code class="directive"><a href="./mod/mpm_common.html#startservers">StartServers</a></code> de la siguiente
    manera: si despu�s de al menos un segundo el nuevo hijo de la
    directiva <code class="directive"><a href="./mod/mpm_common.html#startservers">StartServers</a></code>
    no ha sido creado, entonces crea los suficientes para se atienda
    el trabajo que queda por hacer. As�, se intenta mantener
    tanto el n�mero de hijos adecuado para el trabajo que el
    servidor tenga en ese momento, como respetar la configuraci�n
    determinada por los par�metros de la directiva
    <code class="directive">StartServers</code>.</p>

    <p>Los usuarios del m�dulo <code class="module"><a href="./mod/mod_status.html">mod_status</a></code>
    notar�n que las estad�sticas del servidor
    <strong>no</strong> se ponen a cero cuando se usa la se�al
    <code>USR1</code>. Apache fue escrito tanto para minimizar el
    tiempo en el que el servidor no puede servir nuevas peticiones
    (que se pondr�n en cola por el sistema operativo, de modo que
    se no se pierda ning�n evento), como para respetar sus
    par�metros de ajuste. Para hacer esto, tiene que guardar el
    <em>scoreboard</em> usado para llevar el registro de los procesos
    hijo a trav�s de las distintas generaciones.</p>

    <p>El mod_status tambi�n usa una <code>G</code> para indicar
    que esos hijos est�n todav�a sirviendo peticiones
    previas al reinicio graceful.</p>

    <p>Actualmente no existe ninguna manera de que un script con un
    log de rotaci�n usando <code>USR1</code> sepa con seguridad
    que todos los hijos que se registraron en el log con anterioridad
    al reinicio han terminado. Se aconseja que se use un retardo
    adecuado despu�s de enviar la se�al <code>USR1</code>
    antes de hacer nada con el log antiguo. Por ejemplo, si la mayor
    parte las visitas que recibe de usuarios que tienen conexiones de
    baja velocidad tardan menos de 10 minutos en completarse, entoces
    espere 15 minutos antes de hacer nada con el log antiguo.</p>

    <div class="note">Si su fichero de configuraci�n tiene errores cuando
    haga el reinicio, entonces el proceso padre no se reinciciar�
    y terminar� con un error. En caso de un reinicio graceful,
    tambi�n dejar� a los procesos hijo ejecutandose mientras
    existan.  (Estos son los hijos de los que se est� saliendo de
    forma graceful y que est�n sirviendo sus �ltimas
    peticiones.) Esto provocar� problemas si intenta reiniciar el
    servidor -- no ser� posible conectarse a la lista de puertos
    de escucha. Antes de reiniciar, puede comprobar que la sintaxis de
    sus ficheros de configuracion es correcta con la opci�n de
    l�nea de comandos <code>-t</code> (consulte <a href="programs/httpd.html">httpd</a>). No obstante, esto no
    garantiza que el servidor se reinicie correctamente. Para
    comprobar que no hay errores en los ficheros de
    configuraci�n, puede intentar iniciar <code>httpd</code> con
    un usuario diferente a root. Si no hay errores, intentar�
    abrir sus sockets y logs y fallar� porque el usuario no es
    root (o porque el <code>httpd</code> que se est� ejecutando
    en ese momento ya est� conectado a esos puertos). Si falla
    por cualquier otra raz�n, entonces casi seguro que hay
    alg�n error en alguno de los ficheros de configuraci�n y
    debe corregir ese o esos errores antes de hacer un reinicio
    graceful.</div>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="hup" id="hup">Reiniciar Apache</a></h2>

<dl><dt>Se�al: HUP</dt>
<dd><code>apachectl -k restart</code></dd>
</dl>

    <p>El env�o de las se�ales <code>HUP</code> o
    <code>restart</code> al proceso padre hace que los procesos hijo
    terminen como si le envi� ramos la se�al
    <code>TERM</code>, para eliminar el proceso padre. La diferencia
    est� en que estas se�ales vuelven a leer los archivos de
    configuraci�n y vuelven a abrir los ficheros log. Se genera
    un nuevo conjunto de hijos y se contin�a sirviendo
    peticiones.</p>

    <p>Los usuarios del m�dulo <code class="module"><a href="./mod/mod_status.html">mod_status</a></code>
    notar�n que las estad�sticas del servidor se ponen a
    cero cuando se env�a la se�al <code>HUP</code>.</p>

<div class="note">Si su fichero de configuraci�n contiene errores, cuando
intente reiniciar, el proceso padre del servidor no se
reiniciar�, sino que terminar� con un error. Consulte
m�s arriba c�mo puede solucionar este problema.</div>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="race" id="race">Ap�ndice: se�ales y race conditions</a></h2>

    <p>Con anterioridad a la versi�n de Apache 1.2b9 hab�a
    varias <em>race conditions</em> implicadas en las se�ales
    para parar y reiniciar procesos (una descripci�n sencilla de
    una race condition es: un problema relacionado con el momento en
    que suceden las cosas, como si algo sucediera en momento en que no
    debe, y entonces el resultado esperado no se corresponde con el
    obtenido). Para aquellas arquitecturas que tienen el conjunto de
    caracter�sticas "adecuadas", se han eliminado tantas race
    conditions como ha sido posible. Pero hay que tener en cuenta que
    todav�a existen race conditions en algunas arquitecturas.</p>

    <p>En las arquitecturas que usan un <code class="directive"><a href="./mod/mpm_common.html#scoreboardfile">ScoreBoardFile</a></code> en disco, existe la
    posibilidad de que se corrompan los scoreboards. Esto puede hacer
    que se produzca el error "bind: Address already in use"
    (despu�s de usar<code>HUP</code>) o el error "long lost child
    came home!"  (despu�s de usar <code>USR1</code>). En el
    primer caso se trata de un error irrecuperable, mientras que en el
    segundo, solo ocurre que el servidor pierde un slot del
    scoreboard. Por lo tanto, ser�a aconsejable usar reinicios
    graceful, y solo hacer reinicios normales de forma
    ocasional. Estos problemas son bastante complicados de solucionar,
    pero afortunadamente casi ninguna arquitectura necesita un fichero
    scoreboard. Consulte la documentaci�n de la directiva
    <code class="directive"><a href="./mod/mpm_common.html#scoreboardfile">ScoreBoardFile</a></code> para ver
    las arquitecturas que la usan.</p>

    <p>Todas las arquitecturas tienen una peque�a race condition
    en cada proceso hijo implicada en la segunda y subsiguientes
    peticiones en una conexi�n HTTP persistente
    (KeepAlive). Puede ser que el servidor termine despu�s de
    leer la l�nea de petici�n pero antes de leer cualquiera
    de las cebeceras de petici�n. Hay una soluci�n que fue
    descubierta demasiado tarde para la incluirla en versi�n
    1.2. En teoria esto no debe suponer ning�n problema porque el
    cliente KeepAlive ha de esperar que estas cosas pasen debido a los
    retardos de red y a los timeouts que a veces dan los
    servidores. En la practica, parece que no afecta a nada m�s
    -- en una sesi�n de pruebas, un servidor se reinici�
    veinte veces por segundo y los clientes pudieron navegar sin
    problemas por el sitio web sin encontrar problemas ni para
    descargar una sola imagen ni encontrar un solo enlace roto. </p>
</div></div>
<div class="bottomlang">
<p><span>Idiomas disponibles: </span><a href="./de/stopping.html" hreflang="de" rel="alternate" title="Deutsch">&nbsp;de&nbsp;</a> |
<a href="./en/stopping.html" hreflang="en" rel="alternate" title="English">&nbsp;en&nbsp;</a> |
<a href="./es/stopping.html" title="Espa�ol">&nbsp;es&nbsp;</a> |
<a href="./fr/stopping.html" hreflang="fr" rel="alternate" title="Fran�ais">&nbsp;fr&nbsp;</a> |
<a href="./ja/stopping.html" hreflang="ja" rel="alternate" title="Japanese">&nbsp;ja&nbsp;</a> |
<a href="./ko/stopping.html" hreflang="ko" rel="alternate" title="Korean">&nbsp;ko&nbsp;</a> |
<a href="./tr/stopping.html" hreflang="tr" rel="alternate" title="T�rk�e">&nbsp;tr&nbsp;</a></p>
</div><div class="top"><a href="#page-header"><img src="./images/up.gif" alt="top" /></a></div><div class="section"><h2><a id="comments_section" name="comments_section">Comentarios</a></h2><div class="warning"><strong>Notice:</strong><br />This is not a Q&amp;A section. Comments placed here should be pointed towards suggestions on improving the documentation or server, and may be removed again by our moderators if they are either implemented or considered invalid/off-topic. Questions on how to manage the Apache HTTP Server should be directed at either our IRC channel, #httpd, on Freenode, or sent to our <a href="http://httpd.apache.org/lists.html">mailing lists</a>.</div>
<script type="text/javascript"><!--//--><![CDATA[//><!--
var comments_shortname = 'httpd';
var comments_identifier = 'http://httpd.apache.org/docs/2.2/stopping.html';
(function(w, d) {
    if (w.location.hostname.toLowerCase() == "httpd.apache.org") {
        d.write('<div id="comments_thread"><\/div>');
        var s = d.createElement('script');
        s.type = 'text/javascript';
        s.async = true;
        s.src = 'https://comments.apache.org/show_comments.lua?site=' + comments_shortname + '&page=' + comments_identifier;
        (d.getElementsByTagName('head')[0] || d.getElementsByTagName('body')[0]).appendChild(s);
    }
    else { 
        d.write('<div id="comments_thread">Comments are disabled for this page at the moment.<\/div>');
    }
})(window, document);
//--><!]]></script></div><div id="footer">
<p class="apache">Copyright 2013 The Apache Software Foundation.<br />Licencia bajo los t�rminos de la <a href="http://www.apache.org/licenses/LICENSE-2.0">Apache License, Version 2.0</a>.</p>
<p class="menu"><a href="./mod/">M�dulos</a> | <a href="./mod/directives.html">Directivas</a> | <a href="http://wiki.apache.org/httpd/FAQ">Preguntas Frecuentes</a> | <a href="./glossary.html">Glosario</a> | <a href="./sitemap.html">Mapa de este sitio web</a></p></div><script type="text/javascript"><!--//--><![CDATA[//><!--
if (typeof(prettyPrint) !== 'undefined') {
    prettyPrint();
}
//--><!]]></script>
</body></html>