<?php
header ("Content-Type:text/xml");
include_once('ressources/class.templates.inc');
include_once('ressources/class.ldap.inc');
include_once('ressources/class.users.menus.inc');
include_once('ressources/class.main_cf.inc');

$emailaddress=$_GET["emailaddress"];
$tr=explode("@",$emailaddress);
$domain=$tr[1];

$users=new user();
$ldap=new clladp();
$uid=$ldap->uid_from_email($emailaddress);

$f[]="<?xml version=\"1.0\"?>";
$f[]="<clientConfig version=\"1.1\">";
$f[]="    <emailProvider id=\"example.com\">";
$f[]="      <domain>$domain</domain>";
$f[]="";
$f[]="      <displayName>$uid Mail</displayName>";
$f[]="      <displayShortName>$uid</displayShortName>";
$f[]="";
$f[]="      <incomingServer type=\"imap\">";
$f[]="         <hostname>pop.example.com</hostname>";
$f[]="         <port>143</port>";
$f[]="         <socketType>SSL</socketType>";
$f[]="           <!-- \"plain\": no encryption";
$f[]="                \"SSL\": SSL 3 or TLS 1 on SSL-specific port";
$f[]="                \"STARTTLS\": on normal plain port and mandatory upgrade to TLS via STARTTLS";
$f[]="                -->";
$f[]="         <username>$uid</username>";
$f[]="            <!-- \"password-cleartext\",";
$f[]="                 \"plain\" (deprecated):";
$f[]="                          Send password in the clear";
$f[]="                          (dangerous, if SSL isn't used either).";
$f[]="                          AUTH PLAIN, LOGIN or protocol-native login.";
$f[]="                 \"password-encrypted\",";
$f[]="                 \"secure\" (deprecated):";
$f[]="                           A secure encrypted password mechanism.";
$f[]="                           Can be CRAM-MD5 or DIGEST-MD5. Not NTLM.";
$f[]="                 \"NTLM\":";
$f[]="                           Use NTLM (or NTLMv2 or successors),";
$f[]="                           the Windows login mechanism.";
$f[]="                 \"GSSAPI\":";
$f[]="                           Use Kerberos / GSSAPI,";
$f[]="                           a single-signon mechanism used for big sites.";
$f[]="                 \"client-IP-address\":";
$f[]="                           The server recognizes this user based on the IP address.";
$f[]="                           No authentication needed, the server will require no username nor password.";
$f[]="                 \"TLS-client-cert\":";
$f[]="                           On the SSL/TLS layer, the server requests a client certificate and the client sends one (possibly after letting the user select/confirm one), if available. (Not yet supported by Thunderbird)";
$f[]="                 \"none\":";
$f[]="                           No authentication";
$f[]="                  Compatibility note: Thunderbird 3.0 accepts only \"plain\" and \"secure\". It will ignore the whole XML file, if other values are given. -->";
$f[]="         <authentication>password-cleartext</authentication>";
$f[]="         <pop3>";
$f[]="            <!-- remove the following and leave to client/user? -->";
$f[]="            <leaveMessagesOnServer>true</leaveMessagesOnServer>";
$f[]="            <downloadOnBiff>true</downloadOnBiff>";
$f[]="            <daysToLeaveMessagesOnServer>14</daysToLeaveMessagesOnServer>";
$f[]="            <!-- only for servers which don't allow checks more often -->";
$f[]="            <checkInterval minutes=\"15\"/><!-- not yet supported -->";
$f[]="         </pop3>";
//$f[]="         <password>optional: the user's password</password>";
$f[]="      </incomingServer>";
$f[]="";
$f[]="      <outgoingServer type=\"smtp\">";
$f[]="         <hostname>smtp.googlemail.com</hostname>";
$f[]="         <port>587</port>";
$f[]="         <socketType>STARTTLS</socketType> <!-- see above -->";
$f[]="         <username>%EMAILLOCALPART%</username> <!-- if smtp-auth -->";
$f[]="            <!-- smtp-auth (RFC 2554, 4954) or other auth mechanism.";
$f[]="                 For values, see incoming.";
$f[]="                 Additional options here:";
$f[]="                 \"SMTP-after-POP\":";
$f[]="                     authenticate to incoming mail server first";
$f[]="                     before contacting the smtp server.";
$f[]="                  Compatibility note: Thunderbird 3.0 accepts only \"plain\",";
$f[]="                  \"secure\", \"none\", and \"smtp-after-pop\".";
$f[]="                  It will ignore the whole XML file, if other values are given.";
$f[]="            -->";
$f[]="         <authentication>password-cleartext</authentication>";
$f[]="            <!-- If the server makes some additional requirements beyond";
$f[]="                 <authentication>.";
$f[]="                 \"client-IP-address\": The server is only reachable or works,";
$f[]="                     if the user is in a certain IP network, e.g.";
$f[]="                     the dialed into the ISP's network (DSL, cable, modem) or";
$f[]="                     connected to a company network.";
$f[]="                     Note: <authentication>client-IP-address</>";
$f[]="                     means that you may use the server without any auth.";
$f[]="                     <authentication>password-cleartext</> *and*";
$f[]="                     <restriction>client-IP-address</> means that you need to";
$f[]="                     be in the correct IP network *and* (should) authenticate.";
$f[]="                     Servers which do that are highly discouraged and";
$f[]="                     should be avoided, see {{bug|556267}}.";
$f[]="                Not yet implemented. Spec (element name?) up to change.";
$f[]="            -->";
$f[]="         <restriction>client-IP-address</restriction>";
$f[]="         <!-- remove the following and leave to client/user? -->";
$f[]="         <addThisServer>true</addThisServer>";
$f[]="         <useGlobalPreferredServer>true</useGlobalPreferredServer>";
$f[]="         <password>optional: the user's password</password>";
$f[]="      </outgoingServer>";
$f[]="";
$f[]="      <identity>";
$f[]="         <!-- needed? -->";
$f[]="         <!-- We don't want Verizon setting \"Organization: Verizon\"";
$f[]="              for its customers -->";
$f[]="      </identity>";
$f[]="";
$f[]="      <!-- see description. Not yet supported, see bug 564043. -->";
$f[]="      <inputField key=\"USERNAME\" label=\"Screen name\"></inputField>";
$f[]="      <inputField key=\"GRANDMA\" label=\"Grandma\">Elise Bauer</inputField>";
$f[]="";
$f[]="      <!-- Add this only when users (who already have an account) have to";
$f[]="           do something manually before the account can work with IMAP/POP or SSL.";
$f[]="           Note: Per XML, & (ampersand) needs to be escaped to & a m p ;";
$f[]="           (without spaces).";
$f[]="           Not yet implemented, see bug 586364. -->";
$f[]="      <enable";
$f[]="           visiturl=\"https://mail.google.com/mail/?ui=2&shva=1#settings/fwdandpop\">";
$f[]="           <instruction>Check 'Enable IMAP and POP' in Google settings page</instruction>";
$f[]="           <instruction lang=\"de\">Schalten Sie 'IMAP und POP aktivieren' auf der Google Einstellungs-Seite an</instruction>";
$f[]="      </enable>";
$f[]="";
$f[]="      <!-- A page where the ISP describes the configuration.";
$f[]="           This is purely informational and currently mainly for";
$f[]="           maintenance of the files and not used by the client at all.";
$f[]="           Note that we do not necessarily use exactly the config suggested";
$f[]="           by the ISP, e.g. when they don't recommend SSL, but it's available,";
$f[]="           we will configure SSL.";
$f[]="           The text content should contains a description in the native";
$f[]="           language of the ISP (customers), and a short English description,";
$f[]="           mostly for us.";
$f[]="      -->";
$f[]="      <documentation url=\"http://www.example.com/help/mail/thunderbird\">";
$f[]="         <descr lang=\"en\">Configure Thunderbird 2.0 for IMAP</descr>";
$f[]="         <descr lang=\"de\">Thunderbird 2.0 mit IMAP konfigurieren</descr>";
$f[]="      </documentation>";
$f[]="";
$f[]="    </emailProvider>";
$f[]="";
$f[]="    <!-- This allows to access the webmail service of the provider.";
$f[]="         The URLs are loaded into a standard webbrowser for the user.";
$f[]="         Specifying this is optional. -->";
$f[]="    <webMail>";
$f[]="      <!-- Webpage where the user has to log in manually by entering username";
$f[]="           and password himself.";
$f[]="           HTTPS required. -->";
$f[]="      <loginPage url=\"https://mail.example.com/login/\" />";
$f[]="";
$f[]="      <!-- Same as loginAutomaticDOM, but the website makes checks that";
$f[]="           the user comes from the login page. So, open the login page";
$f[]="           in the browser, get the page's DOM, fill out name and password";
$f[]="           fields for the user, and trigger the login button.";
$f[]="           The login button might not be an HTML button, just a div, so";
$f[]="           to trigger it, send a click event to it.";
$f[]="           HTTPS is required for the URL. -->";
$f[]="      <loginPageInfo url=\"https://mail.example.com/login/\">";
$f[]="        <!-- What to fill into the usernameField.";
$f[]="             Format is the same as for <username> within <incomingServer>,";
$f[]="             including placeholders. See below for valid placeholders. -->";
$f[]="        <username>%EMAILADDRESS%</username>";
$f[]="        <!-- Allows to find the textfield on the page, to fill it out.";
$f[]="             The id attribute give the DOM ID,";
$f[]="             The name attribute give the DOM name attribute.";
$f[]="             One or both of id and name attributes must exist.";
$f[]="             Try the ID first (e.g. using getElementById()), if existing.";
$f[]="             Otherwise, try finding the element by name.";
$f[]="             Don't treat the IDs given in this XML file as trusted,";
$f[]="             but before using them, verify the format";
$f[]="             (e.g. only characters and digits for IDs).";
$f[]="             If you use powerful functions like jQuery, and the XML returns";
$f[]="             you code in the username ID, and you feed it unchecked to jQuery,";
$f[]="             it may be executed. -->";
$f[]="        <usernameField id=\"email_field\" name=\"email\" />";
$f[]="        <passwordField name=\"password\" />";
$f[]="        <!-- The submit button to trigger the server submit";
$f[]="             after filling in the fields.";
$f[]="             id and name attributes: See <usernameField> -->";
$f[]="        <loginButton id=\"submit_button\" name=\"login\"/>";
$f[]="      </loginPageInfo>";
$f[]="    </webMail>";
$f[]="";
$f[]="    <clientConfigUpdate url=\"https://www.example.com/config/mozilla.xml\" />";
$f[]="";
$f[]="</clientConfig>";