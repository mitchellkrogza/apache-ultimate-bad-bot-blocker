<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"><head><!--
        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
              This file is generated from xml source: DO NOT EDIT
        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      -->
<title>Compilaci�n e Instalaci�n - Servidor HTTP Apache</title>
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
<a href="http://www.apache.org/">Apache</a> &gt; <a href="http://httpd.apache.org/">Servidor HTTP</a> &gt; <a href="http://httpd.apache.org/docs/">Documentaci�n</a> &gt; <a href="./">Versi�n 2.2</a></div><div id="page-content"><div id="preamble"><h1>Compilaci�n e Instalaci�n</h1>
<div class="toplang">
<p><span>Idiomas disponibles: </span><a href="./de/install.html" hreflang="de" rel="alternate" title="Deutsch">&nbsp;de&nbsp;</a> |
<a href="./en/install.html" hreflang="en" rel="alternate" title="English">&nbsp;en&nbsp;</a> |
<a href="./es/install.html" title="Espa�ol">&nbsp;es&nbsp;</a> |
<a href="./fr/install.html" hreflang="fr" rel="alternate" title="Fran�ais">&nbsp;fr&nbsp;</a> |
<a href="./ja/install.html" hreflang="ja" rel="alternate" title="Japanese">&nbsp;ja&nbsp;</a> |
<a href="./ko/install.html" hreflang="ko" rel="alternate" title="Korean">&nbsp;ko&nbsp;</a> |
<a href="./tr/install.html" hreflang="tr" rel="alternate" title="T�rk�e">&nbsp;tr&nbsp;</a></p>
</div>
<div class="outofdate">Esta traducci�n podr�a estar
            obsoleta. Consulte la versi�n en ingl�s de la
            documentaci�n para comprobar si se han producido cambios
            recientemente.</div>


    <p>Este documento explica c�mo compilar e instalar Apache en
    sistemas Unix y tipo Unix. Para obtener informaci�n sobre
    c�mo compilar e instalar en Windows, consulte la secci�n
    <a href="platform/windows.html">Usar Apache en Microsoft
    Windows</a>. Para otras plataformas, consulte la
    documentaci�n sobre <a href="platform/">plataformas</a>.</p>

    <p>El entorno de configuraci�n e instalaci�n de Apache
    2.0 ha cambiado completamente respecto al de Apache 1.3. Apache
    1.3 usaba un conjunto de scripts a medida para conseguir una
    instalaci�n f�cil. Apache 2.0 usa <code>libtool</code> y
    <code>autoconf</code> para crear un entorno m�s parecido al
    de muchos otros proyectos Open Source.</p>
    
    <p>Si lo que quiere hacer es actualizar su servidor Apache desde
    una versi�n menor (por ejemplo, desde la 2.0.50 a la 2.0.51),
    pase directamente a la secci�n de <a href="#upgrading">actualizaci�n</a>.</p>

</div>
<div id="quickview"><ul id="toc"><li><img alt="" src="./images/down.gif" /> <a href="#overview">Visi�n general del proceso para
    impacientes</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#requirements">Requisitos</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#download">Descargar</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#extract">Descomprimir</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#configure">Configuraci�n de la estructura de
directorios</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#compile">Compilar</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#install">Instalar</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#customize">Personalizar</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#test">Comprobar que la instalaci�n
funciona</a></li>
<li><img alt="" src="./images/down.gif" /> <a href="#upgrading">Actualizar una instalaci�n
previa</a></li>
</ul><h3>Consulte tambi�n</h3><ul class="seealso"><li><a href="programs/configure.html">Configuraci�n de la
estructura de directorios</a></li><li><a href="invoking.html">Iniciar Apache</a></li><li><a href="stopping.html">Parar y reiniciar Apache</a></li></ul><ul class="seealso"><li><a href="#comments_section">Comentarios</a></li></ul></div>
<div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="overview" id="overview">Visi�n general del proceso para
    impacientes</a></h2>

    <table>
      
      <tr>
        <td><a href="#download">Descargar</a></td>

        <td><code>$ lynx http://httpd.apache.org/download.cgi</code>
        </td>
      </tr>

      <tr>
        <td><a href="#extract">Descomprimir</a></td>

        <td><code>$ gzip -d httpd-2_1_<em>NN</em>.tar.gz<br />
         $ tar xvf httpd-2_1_<em>NN</em>.tar</code> </td>
      </tr>

      <tr>
        <td><a href="#configure">Ejecutar el script configure</a></td>

        <td><code>$ ./configure --prefix=<em>PREFIX</em></code>
        </td>
      </tr>

      <tr>
        <td><a href="#compile">Compilar</a></td>

        <td><code>$ make</code> </td>
      </tr>

      <tr>
        <td><a href="#install">Instalar</a></td>

        <td><code>$ make install</code> </td>
      </tr>

      <tr>
        <td><a href="#customize">Personalizar</a></td>

        <td><code>$ vi <em>PREFIX</em>/conf/httpd.conf</code> </td>
      </tr>

      <tr>
        <td><a href="#test">Comprobar que la instalaci�n
        funciona</a></td>

        <td><code>$ <em>PREFIX</em>/bin/apachectl start</code>
        </td>
      </tr>
    </table>

    <p><em>NN</em> hay que reemplazarlo por el n�mero de la
    versi�n menor, y <em>PREFIX</em> hay que reemplazarlo por la
    ruta en la que se va a instalar Apache. Si no especifica
    ning�n valor en <em>PREFIX</em>, el valor por defecto que se
    toma es <code>/usr/local/apache2</code>.</p>

    <p>Cada parte del proceso de configuraci�n e instalaci�n
    se describe detalladamente m�s abajo, empezando por los
    requisitos para compilar e instalar Apache.</p>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="requirements" id="requirements">Requisitos</a></h2>

    <p>Estos son los requisitos necesarios para compilar Apache:</p>
  
    <dl>
      <dt>Espacio en disco</dt> <dd>Compruebe que tiene disponibles al
      menos 50 MB de espacio libre en disco. Despu�s de la
      instalaci�n, Apache ocupa aproximadamente 10 MB. No
      obstante, la necesidad real de espacio en disco var�a
      considerablemente en funci�n de las opciones de
      configuraci�n que elija y de los m�dulos externos que
      use.</dd>

      <dt>Compilador ANSI-C y Build System</dt> <dd>Compruebe que
      tiene instalado un compilador de ANSI-C. Se recomienda el <a href="http://www.gnu.org/software/gcc/gcc.html">Compilador GNU C
      (GCC)</a> de la <a href="http://www.gnu.org/">Free Software
      Foundation (FSF)</a> (con la versi�n 2.7.2 es
      suficiente). Si no tiene instaldo el GCC, entonces compruebe que
      el compilador que va a utilizar cumple con los est�ndares
      ANSI. Adem�s, su <code>PATH</code> debe contener la
      ubicaci�n donde de encuentran las herramientas b�sicas
      para compilar tales como <code>make</code>.</dd>

      <dt>Ajuste exacto del reloj del sistema</dt> <dd>Los elementos
      del protocolo HTTP est�n expresados seg�n la hora del
      dia. Por eso, si quiere puede investigar como instalar alguna
      utilidad para sincronizar la hora de su sistema. Para esto,
      normalmente, se usan los programas <code>ntpdate</code> o
      <code>xntpd</code>, que est�n basados en el protocolo
      Network Time Protocol (NTP). Consulte el grupo de noticias <a href="news:comp.protocols.time.ntp">comp.protocols.time.ntp</a>
      y el <a href="http://www.eecis.udel.edu/~ntp/">sitio web de NTP
      </a> para obtener m�s informaci�n sobre NTP y los
      servidores p�blicos de tiempo.</dd>

      <dt><a href="http://www.perl.org/">Perl 5</a> [OPCIONAL]</dt>
      <dd>Para algunos de los scripts de soporte como <a href="programs/apxs.html">apxs</a> o <a href="programs/dbmmanage.html">dbmmanage</a> (que est�n
      escritos en Perl) es necesario el int�rprete de Perl 5 (las
      versiones 5.003 o posteriores son suficientes). Si el script
      `<code>configure</code>' no encuentra ese int�rprete
      tampoco pasa nada. A�n puede compilar e instalar Apache
      2.0. Lo �nico que ocurrir� es que esos scripts de
      soporte no podr�n ser usados. Si usted tiene varios
      interpretes de Perl instalados (quiz�s Perl 4 porque estaba
      ya incluido en su distribuci�n de Linux y Perl 5 porque lo
      ha instalado usted), entonces se recomienda usar la opci�n
      <code>--with-perl</code> para asegurarse de que
      <code>./configure</code> usa el int�rprete correcto.</dd>
    </dl>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="download" id="download">Descargar</a></h2>

    <p>Puede descargar Apache desde <a href="http://httpd.apache.org/download.cgi">la secci�n de
    descargas del sitio web de Apache</a> el cual tiene varios
    mirrors. Para la mayor�a de los usuarios de Apache que tienen
    sistemas tipo Unix, se recomienda que se descarguen y compilen el
    c�digo fuente. El proceso de compilaci�n (descrito
    m�s abajo) es f�cil, y permite adaptar el servidor
    Apache a sus necesidades. Adem�s, las versiones de
    disponibles en archivos binarios no est�n siempre actulizadas
    con las �ltimas modificaciones en el codigo fuente. Si se
    descarga un binario, siga las instrucciones contenidas en el
    archivo <code>INSTALL.bindist</code> incluido en la
    distribuci�n</p>

    <p>Despu�s de la descarga, es importante que verifique que el
    archivo descargado del servidor HTTP Apache est� completo y
    sin modificaciones.  Esto puede hacerlo comparando el archivo
    descargado (.tgz) con su firma PGP. Instrucciones detalladas de
    c�mo hacer esto est�n disponibles en <a href="http://httpd.apache.org/download.cgi#verify"> la
    secci�n de descargas</a> junto con un ejemplo de c�mo <a href="http://httpd.apache.org/dev/verification.html">usar
    PGP</a>.</p>
 
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="extract" id="extract">Descomprimir</a></h2>

    <p>Extraer el c�digo fuente del archivo .tgz que acabada de
    descargar es muy f�cil. Ejecute los siguientes comandos:</p>

<div class="example"><p><code>
      $ gzip -d httpd-2_1_<em>NN</em>.tar.gz<br />
       $ tar xvf httpd-2_1_<em>NN</em>.tar
</code></p></div>

    <p>Estos comandos crear�n un nuevo directorio dentro del
    directorio en el que se encuentra y que contendr� el
    c�digo fuente de la distribuci�n. Debe cambiarse a ese
    directorio con <code>cd</code> para proceder a compilar el
    servidor Apache.</p>

</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="configure" id="configure">Configuraci�n de la estructura de
directorios</a></h2>

    <p>El siguiente paso es configurar la estructura de directorios
    para su plataforma y sus necesidades personales. Esto se hace
    usando el script <code>configure</code> incluido en el directorio
    raiz de la distribuci�n que acaba de descargar. (Los
    desarrolladores que se descarguen la versi�n del CVS de la
    estructura de directorios necesitar�n tener instalados
    <code>autoconf</code> y <code>libtool</code>, y necesitar�n
    ejecutar <code>buildconf</code> antes de continuar con los
    siguientes pasos. Esto no es preciso para las versiones
    oficiales.)</p>

    <p>Para configurar la estructura de directorios a partir del
    c�digo fuente usando las opciones por defecto, solo tiene que
    ejecutar <code>./configure</code>. Para cambiar las opciones por
    defecto, <code>configure</code> acepta una serie de variables y
    opciones por la l�nea de comandos.</p>

    <p>La opci�n m�s importante es <code>--prefix</code> que
    es el directorio en el que Apache va a ser instalado despu�s,
    porque Apache tiene que ser configurado para el directorio que se
    especifique para que funcione correctamente.  Es posible lograr un
    mayor control del lugar donde se van a instalar los ficheros de
    Apache con otras <a href="programs/configure.html#installationdirectories">opciones de
    configuraci�n</a>.</p>

    <p>En este momento, puede especificar que <a href="programs/configure.html#optionalfeatures">caracter�sticas
    o funcionalidades</a> quiere incluir en Apache activando o
    desactivando <a href="mod/">m�dulos</a>.  Apache viene con
    una <a href="mod/module-dict.html#Status">selecci�n
    b�sica</a> de m�dulos incluidos por defecto.  Se pueden
    activar otros m�dulos usando la opci�n
    <code>--enable-<var>module</var></code>, donde <var>module</var>
    es el nombre del m�dulo sin el <code>mod_</code> y
    convirtiendo los guiones bajos que tenga en guiones normales.
    Tambi�n puede optar por compilar m�dulos como <a href="dso.html">objetos din�micos compartidos (DSOs)</a> --
    que pueden ser activados o desactivados al ejecutar -- usando la
    opci�n <code>--enable-<var>module</var>=shared</code>.  De
    igual manera, puede desactivar alguno de los m�dulos que
    vienen por defecto en la selecci�n basica con la opci�n
    <code>--disable-<var>module</var></code>.  Tenga cuidado cuando
    use estas opciones, porque <code>configure</code> no le
    avisar� si el m�dulo que especifica no existe;
    simplemente ignorar� esa opci�n.</p>

    <p>Adem�s, a veces es necesario pasarle al script
    <code>configure</code> informaci�n adicional sobre donde esta
    su compilador, librerias o ficheros de cabecera.  Esto se puede
    hacer, tanto pasando variables de entorno, como pasandole opciones
    a <code>configure</code> a trav�s de la l�nea de
    comandos.  Para m�s informaci�n, consulte el <a href="programs/configure.html">Manual del script
    configure</a>.</p>

    <p>Para que se haga una idea sobre las posibilidades que tiene,
    aqu� tiene un ejemplo t�pico que configura Apache para
    la ruta <code>/sw/pkg/apache</code> con un compilador y unos flags
    determinados, y adem�s, con dos m�dulos adicionales
    <code class="module"><a href="./mod/mod_rewrite.html">mod_rewrite</a></code> y <code class="module"><a href="./mod/mod_speling.html">mod_speling</a></code> para
    cargarlos despu�s a trav�s del mecanismo DSO:</p>

<div class="example"><p><code>
      $ CC="pgcc" CFLAGS="-O2" \<br />
       ./configure --prefix=/sw/pkg/apache \<br />
       --enable-rewrite=shared \<br />
       --enable-speling=shared
</code></p></div>

    <p>Cuando se ejecuta <code>configure</code> se comprueban que
    caracter�sticas o funcionalidades est�n disponibles en
    su sistema y se crean los Makefiles que ser�n usados luego
    para compilar el servidor. Esto tardar� algunos minutos.</p>

    <p>La informaci�n sobre todas las opciones de
    <code>configure</code> est� disponible en el <a href="programs/configure.html">Manual del script
    configure</a>.</p>

</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="compile" id="compile">Compilar</a></h2>

    <p>Ahora puede compilar las diferentes partes que forman Apache
    simplemente ejecutando el siguiente comando:</p>

<div class="example"><p><code>$ make</code></p></div>

    <p>Por favor, tanga un poco de paciencia ahora, porque una
    configuraci�n b�sica tarda aproximadamente 3 minutos en
    compilar en un Pentium III con un sistema Linux 2.2, pero este
    tiempo puede variar considerablemente en funci�n de su
    hardware y del n�mero de m�dulos que haya
    seleccionado.</p>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="install" id="install">Instalar</a></h2>

    <p>Ahora es el momento de instalar el paquete en el diretorio
    elegido en <em>PREFIX</em> (consulte la opci�n
    <code>--prefix</code> m�s arriba) ejecutando:</p>

<div class="example"><p><code>$ make install</code></p></div>

    <p>Si usted est� solo actualizando una instalaci�n
    anterior, la nueva instalaci�n no sobreescribir� sus
    ficheros de configuraci�n ni otros documentos.</p>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="customize" id="customize">Personalizar</a></h2>

    <p>El paso siguiente, es personalizar su servidor Apache editando
    los <a href="configuring.html">ficheros de configuraci�n</a>
    que est�n en <code><em>PREFIX</em>/conf/</code>.</p>

<div class="example"><p><code>$ vi <em>PREFIX</em>/conf/httpd.conf</code></p></div>

    <p>�chele un vistazo al Manual de Apache que est� en <a href="./">docs/manual/</a> o consulte en <a href="http://httpd.apache.org/docs/2.2/">http://httpd.apache.org/docs/2.2/</a> la versi�n m�s
    reciente de este manual y la Guia de Referencia de todas las <a href="mod/directives.html">directivas de configuraci�n</a>
    disponibles.</p>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="test" id="test">Comprobar que la instalaci�n
funciona</a></h2>

    <p>Ahora puede <a href="invoking.html">iniciar</a> su servidor
    Apache cuando quiera ejecutando:</p>

<div class="example"><p><code>$ <em>PREFIX</em>/bin/apachectl start</code></p></div>

    <p>y entonces debe poder acceder al documento que tenga
    especificado por defecto usando el siguiente URL:
    <code>http://localhost/</code>. El documento que ver�
    estar� en <code class="directive"><a href="./mod/core.html#documentroot">DocumentRoot</a></code> y
    casi siempre estar� en <code><em>PREFIX</em>/htdocs/</code>.
    Si quiere <a href="stopping.html">parar</a> el servidor, puede
    hacerlo ejecutando:</p>

<div class="example"><p><code>$ <em>PREFIX</em>/bin/apachectl stop</code></p></div>
</div><div class="top"><a href="#page-header"><img alt="top" src="./images/up.gif" /></a></div>
<div class="section">
<h2><a name="upgrading" id="upgrading">Actualizar una instalaci�n
previa</a></h2>

    <p>El primer paso para actualizar una instalaci�n anterior es
    leer las especificaciones de la versi�n y el fichero
    <code>CHANGES</code> en la distribuci�n de c�digo fuente
    que ha descargado para encontrar los cambios que puedan afectar a
    su instalaci�n actual. Cuando el cambio sea entre versiones
    mayores (por ejemplo, de la 1.3 a la 2.0 o de la 2.0 a la 2.2),
    entonces es m�s probable que haya diferencias importantes en
    la compilaci�n y en la ejecuci�n que necesitar�n
    ajustes manuales. Todos los m�dulos necesitar�n
    tambi�n ser actualizados para adaptarse a los cambios en el
    interfaz de programaci�n (API) de m�dulos.</p>

    <p>La actualizaci�n cuando el cambio es entre versiones
    menores (por ejemplo, de la 2.0.55 a la 2.0.57) es m�s
    f�cil.  El proceso <code>make install</code> no
    sobreescribir� ninguno de los documentos existentes, archivos
    log, o archivos de configuraci�n.  Adem�s, los
    desarrolladores hacen todos los esfuerzos posibles para evitar
    cambios que generen incompatibilidades en las opciones de
    <code>configure</code>, en la configuraci�n de la
    ejecuci�n o en la interfaz de programaci�n de
    m�dulos. En la mayor parte de los casos debe poder usar un
    comando <code>configure</code> id�ntico, un fichero de
    configuraci�n id�ntico, y todos sus m�dulos deben
    seguir funcionando.  (Esto es v�lido solo para versiones
    posteriores a la 2.0.41; las versiones anteriores contienen
    cambios incompatibles.)</p>

    <p>Si va a conservar la estructura de directorios de su anterior
    instalaci�n, la actualizaci�n es m�s f�cil
    incluso.  El fichero <code>config.nice</code> que est� en el
    directorio raiz de la estructura de directorios antigua contiene
    exactamente el comando <code>configure</code> que usted us�
    para configurar la estructura de directorios de Apache.  Entonces,
    para actualizar su instalaci�n de una vers�on a la
    siguinete, solo tiene que copiar el archivo
    <code>config.nice</code> a la estructura de directorios del
    c�digo fuente de la nueva versi�n, editarlo, hacer
    cualquier cambio que desee, y ejecutarlo :</p>

    <div class="example"><p><code>
    $ ./config.nice<br />
    $ make<br />
    $ make install<br />
    $ <em>PREFIX</em>/bin/apachectl stop<br />
    $ <em>PREFIX</em>/bin/apachectl start<br />
    </code></p></div>

    <div class="warning">Tenga en cuenta que antes de poner una nueva
    versi�n de Apache en producci�n, debe siempre probarla
    antes en su entorno. Por ejemplo, puede instalar y ejecutar la
    nueva versi�n junto con la antigua usando un
    <code>--prefix</code> diferente y un puerto diferente (modificando
    la directiva <code class="directive"><a href="./mod/mpm_common.html#listen">Listen</a></code>)
    para comprobar que no existe ninguna incompatibilidad antes de
    hacer la actualizaci�n definitiva.</div>
</div></div>
<div class="bottomlang">
<p><span>Idiomas disponibles: </span><a href="./de/install.html" hreflang="de" rel="alternate" title="Deutsch">&nbsp;de&nbsp;</a> |
<a href="./en/install.html" hreflang="en" rel="alternate" title="English">&nbsp;en&nbsp;</a> |
<a href="./es/install.html" title="Espa�ol">&nbsp;es&nbsp;</a> |
<a href="./fr/install.html" hreflang="fr" rel="alternate" title="Fran�ais">&nbsp;fr&nbsp;</a> |
<a href="./ja/install.html" hreflang="ja" rel="alternate" title="Japanese">&nbsp;ja&nbsp;</a> |
<a href="./ko/install.html" hreflang="ko" rel="alternate" title="Korean">&nbsp;ko&nbsp;</a> |
<a href="./tr/install.html" hreflang="tr" rel="alternate" title="T�rk�e">&nbsp;tr&nbsp;</a></p>
</div><div class="top"><a href="#page-header"><img src="./images/up.gif" alt="top" /></a></div><div class="section"><h2><a id="comments_section" name="comments_section">Comentarios</a></h2><div class="warning"><strong>Notice:</strong><br />This is not a Q&amp;A section. Comments placed here should be pointed towards suggestions on improving the documentation or server, and may be removed again by our moderators if they are either implemented or considered invalid/off-topic. Questions on how to manage the Apache HTTP Server should be directed at either our IRC channel, #httpd, on Freenode, or sent to our <a href="http://httpd.apache.org/lists.html">mailing lists</a>.</div>
<script type="text/javascript"><!--//--><![CDATA[//><!--
var comments_shortname = 'httpd';
var comments_identifier = 'http://httpd.apache.org/docs/2.2/install.html';
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