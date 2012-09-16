unit setup_zarafa;
{$MODE DELPHI}
//{$mode objfpc}{$H+}
{$LONGSTRINGS ON}
//ln -s /usr/lib/libmilter/libsmutil.a /usr/local/lib/libsmutil.a
//apt-get install libmilter-dev
interface

uses
  Classes, SysUtils,RegExpr in 'RegExpr.pas',
  unix,setup_libs,distridetect,postfix_class,zsystem,
  install_generic;

  type
  tzarafa=class


private
   libs:tlibs;
   distri:tdistriDetect;
   install:tinstall;
   source_folder,cmd:string;
   webserver_port:string;
   artica_admin:string;
   artica_password:string;
   ldap_suffix:string;
   mysql_server:string;
   mysql_admin:string;
   mysql_password:string;
   ldap_server:string;
   postfix:tpostfix;
   SYS:Tsystem;
   CODE_NAME:string;
   function VERSION_INTEGER():integer;
   function REMOTE_VERSION_INTEGER():integer;


public
      constructor Create();
      procedure Free;
      procedure xinstall(ProductCode:string);
      function libvmime():boolean;
      function google_perftools():boolean;
      function clucene():boolean;
      function libical():boolean;
      procedure REMOVE();
      procedure archiver();
      function spreedsrc():boolean;
   procedure COMPILE_TAR();
   procedure xcompile();
   procedure xinstall6();
   function zpush():boolean;
   function zadmin():boolean;
   function hamachi():boolean;
   function webapp():boolean;
   procedure netatalk();
   procedure arkeia();
END;

implementation

constructor tzarafa.Create();
begin
libs:=tlibs.Create;
install:=tinstall.Create;
source_folder:='';
SYS:=Tsystem.Create();
if DirectoryExists(ParamStr(2)) then source_folder:=ParamStr(2);
CODE_NAME:='APP_ZARAFA';
end;
//#########################################################################################
procedure tzarafa.Free();
begin
  libs.Free;
  //libgsasl7-dev
  ///usr/lib/libvmime.so
  // /usr/local/lib/libicalvcal.a
end;

//#########################################################################################



//#########################################################################################
function tzarafa.zpush():boolean;
begin
result:=false;
source_folder:='';
CODE_NAME:='APP_Z_PUSH';
install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
install.INSTALL_STATUS(CODE_NAME,35);

if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('z-push');
  if not DirectoryExists(source_folder) then begin
     writeln('Install z-push failed...');
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;
   SetCurrentDir(source_folder);
   install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
   install.INSTALL_STATUS(CODE_NAME,70);
   forceDirectories('/usr/share/z-push');
   fpsystem('/bin/cp -rf '+source_folder+'/* /usr/share/z-push/');

   if FileExists('/usr/share/z-push/index.php') then begin
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      install.INSTALL_STATUS(CODE_NAME,100);
      exit;
   end;

      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      install.INSTALL_STATUS(CODE_NAME,110);

end;
//#########################################################################################
function tzarafa.hamachi():boolean;
var
   Arch:integer;
   repos:string;
begin
result:=false;
source_folder:='';
CODE_NAME:='APP_HAMACHI';
install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
install.INSTALL_STATUS(CODE_NAME,35);
Arch:=libs.ArchStruct();
if Arch=32 then repos:='logmein-hamachi-i386';
if Arch=64 then repos:='logmein-hamachi-x64';

if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS(repos);
  if not DirectoryExists(source_folder) then begin
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;

   if not FileExists(source_folder+'/install.sh') then begin
      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
   end;


   SetCurrentDir(source_folder);
   install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
   install.INSTALL_STATUS(CODE_NAME,70);
   fpsystem('./install.sh');

   if FileExists('/usr/bin/hamachi') then begin
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      install.INSTALL_STATUS(CODE_NAME,100);
      fpsystem('/etc/init.d/artica-postfix restart hamachi');
      exit;
   end;

      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      install.INSTALL_STATUS(CODE_NAME,110);

end;
//#########################################################################################




function tzarafa.spreedsrc():boolean;
begin
result:=false;
source_folder:='';
CODE_NAME:='APP_SPREED';

install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
install.INSTALL_STATUS(CODE_NAME,35);
if not DirectoryExists('/usr/share/zarafa-webaccess/plugins') then begin
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
end;

if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('spreedsrc');

install.INSTALL_PROGRESS(CODE_NAME,'{checking');
install.INSTALL_STATUS(CODE_NAME,45);

  if not DirectoryExists(source_folder) then begin
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;



  SetCurrentDir(source_folder);

  install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
  install.INSTALL_STATUS(CODE_NAME,70);
  writeln('Copy files from `'+source_folder+'/*` /usr/share/zarafa-webaccess/plugins/');
  fpsystem('/bin/cp -rfv '+source_folder+'/* /usr/share/zarafa-webaccess/plugins/');

   if FileExists('/usr/share/zarafa-webaccess/plugins/spreed/manifest.xml') then begin
      writeln('Success... restart service');
      fpsystem('/etc/init.d/artica-postfix restart zarafa-web');
      fpsystem('/etc/init.d/artica-postfix restart apachesrc');
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      install.INSTALL_STATUS(CODE_NAME,100);
      exit;
   end;

      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      install.INSTALL_STATUS(CODE_NAME,110);

end;
//#########################################################################################
function tzarafa.webapp():boolean;
begin
result:=false;
source_folder:='';
CODE_NAME:='APP_ZARAFA_WEBAPP';

install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
install.INSTALL_STATUS(CODE_NAME,35);


if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('zarafa-webapp');

install.INSTALL_PROGRESS(CODE_NAME,'{checking');
install.INSTALL_STATUS(CODE_NAME,45);

  if not DirectoryExists(source_folder+'/usr') then begin
     writeln('Install WebApp failed...');
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;
   writeln('sources extracted in '+source_folder);
   fpsystem('/bin/cp -rf '+source_folder+'/* /');
   if not FileExists('/usr/share/zarafa-webapp/index.php') then begin
     writeln('/usr/share/zarafa-webapp/index.php no such file...');
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
   end;
     writeln('Install WebApp success...');
     install.INSTALL_PROGRESS(CODE_NAME,'{success}');
     install.INSTALL_STATUS(CODE_NAME,100);
     fpsystem('/bin/rm -rf '+source_folder);

end;
//#########################################################################################


function tzarafa.zadmin():boolean;
begin
result:=false;
source_folder:='';
CODE_NAME:='APP_YAFFAS';

install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
install.INSTALL_STATUS(CODE_NAME,35);


if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('yaffas');

install.INSTALL_PROGRESS(CODE_NAME,'{checking');
install.INSTALL_STATUS(CODE_NAME,45);

  if not DirectoryExists(source_folder) then begin
     writeln('Install z-admin failed...');
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;

  if ExtractFileName(source_folder)='tmp' then source_folder:=ExtractFilePath(source_folder);
  if ExtractFileName(source_folder)='var' then source_folder:=ExtractFilePath(source_folder);
  if ExtractFileName(source_folder)='etc' then source_folder:=ExtractFilePath(source_folder);
  if ExtractFileName(source_folder)='opt' then source_folder:=ExtractFilePath(source_folder);
  if ExtractFileName(source_folder)='usr' then source_folder:=ExtractFilePath(source_folder);
  source_folder:=ExcludeTrailingPathDelimiter(source_folder);
   SetCurrentDir(source_folder);

   install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
   install.INSTALL_STATUS(CODE_NAME,70);
   writeln('Copy files from  '+source_folder+'/* /');
   fpsystem('/bin/cp -rf '+source_folder+'/* /');

   if FileExists('/opt/yaffas/lib/bbinstall-lib.sh') then begin
      writeln('Success... restart service');
      fpsystem('/etc/init.d/artica-postfix restart yaffas');
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      install.INSTALL_STATUS(CODE_NAME,100);
      exit;
   end;

      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      install.INSTALL_STATUS(CODE_NAME,110);

end;
//#########################################################################################


function tzarafa.libical():boolean;
begin
result:=false;
if FileExists('/usr/local/lib/libicalvcal.a') then begin
   writeln('/usr/local/lib/libicalvcal.a OK');
   exit(true);
end;
if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('libical');
  if not DirectoryExists(source_folder) then begin
     writeln('Install libical failed...');
     exit;
  end;
SetCurrentDir(source_folder);
   install.INSTALL_PROGRESS(CODE_NAME,'libicalvcal');
   install.INSTALL_STATUS(CODE_NAME,70);
   fpsystem('./configure');
   install.INSTALL_PROGRESS(CODE_NAME,'libicalvcal');
   install.INSTALL_STATUS(CODE_NAME,70);
   fpsystem('make');
   install.INSTALL_PROGRESS(CODE_NAME,'libicalvcal');
   install.INSTALL_STATUS(CODE_NAME,70);
   fpsystem('make install');
   install.INSTALL_STATUS(CODE_NAME,70);
if FileExists('/usr/local/lib/libicalvcal.a') then begin
   writeln('/usr/local/lib/libicalvcal.a success');
   SetCurrentDir('/root');
   exit(true);
end;

writeln('Unable to stat /usr/local/lib/libicalvcal.a');
install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
install.INSTALL_STATUS(CODE_NAME,110);

end;
//#########################################################################################

function tzarafa.libvmime():boolean;
begin
result:=false;



if FileExists('/usr/local/lib/libvmime.so.0.7.1') then begin
     writeln('/usr/local/lib/libvmime.so.0.7.1 already installed');
    exit(true);
end;

   install.INSTALL_STATUS(CODE_NAME,50);
   writeln('Downloading libvmime-0.7.1.tar.bz2');
libs.WGET_DOWNLOAD_FILE('http://www.artica.fr/download/libvmime-0.7.1.tar.bz2','/tmp/libvmime-0.7.1.tar.bz2');
if not FileExists('/tmp/libvmime-0.7.1.tar.bz2') then begin
   install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
   install.INSTALL_STATUS(CODE_NAME,110);
   exit;
end;

writeln('Extracting libvmime-0.7.1.tar.bz2');
fpsystem('tar xjf /tmp/libvmime-0.7.1.tar.bz2 -C /root/');
fpsystem('/bin/rm /tmp/libvmime-0.7.1.tar.bz2');
install.INSTALL_STATUS(CODE_NAME,50);
if not DirectorYExists('/root/libvmime-0.7.1') then begin
   install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
   install.INSTALL_STATUS(CODE_NAME,110);
   exit;
end;


writeln('Downloading zarafa-vmime-patches.tar.gz');
libs.WGET_DOWNLOAD_FILE('http://www.artica.fr/download/zarafa-vmime-patches.tar.gz','/tmp/zarafa-vmime-patches.tar.gz');
if not FileExists('/tmp/zarafa-vmime-patches.tar.gz') then begin
   install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
   install.INSTALL_STATUS(CODE_NAME,110);
   exit;
end;

ForceDirectories('/root/zarafa-vmime-patches');
writeln('Extracting zarafa-vmime-patches.tar.gz');
fpsystem('tar xf /tmp/zarafa-vmime-patches.tar.gz -C /root/zarafa-vmime-patches/');
if not FileExists('/root/zarafa-vmime-patches/README') then begin
   install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
   install.INSTALL_STATUS(CODE_NAME,110);
   exit;
end;


   SetCurrentDir('/root/libvmime-0.7.1');
   writeln('Patching');
   install.INSTALL_STATUS(CODE_NAME,50);
   install.INSTALL_PROGRESS(CODE_NAME,'libvmime');
   fpsystem('for i in ../zarafa-vmime-patches/*.diff; do patch -p1 < $i; done');
   fpsystem('./configure');
  install.INSTALL_STATUS(CODE_NAME,50);
   fpsystem('make');
   install.INSTALL_STATUS(CODE_NAME,50);
   fpsystem('make install');
   install.INSTALL_STATUS(CODE_NAME,50);
   SetCurrentDir('/root');


if FileExists('/usr/local/lib/libvmime.so.0.7.1') then begin
   writeln('/usr/local/lib/libvmime.so.0.7.1 success');
   exit(true);
end;


writeln('Unable to stat /usr/local/lib/libvmime.so.0.7.1');
install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
install.INSTALL_STATUS(CODE_NAME,110);
end;
//#########################################################################################


function tzarafa.clucene():boolean;
begin
result:=false;
if FileExists('/usr/lib/CLucene/clucene-config.h') then exit(true);
if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('clucene-core');
  if not DirectoryExists(source_folder) then begin
     writeln('Install clucene failed...');
     exit;
  end;
SetCurrentDir(source_folder);
   install.INSTALL_PROGRESS(CODE_NAME,'clucene');
   install.INSTALL_STATUS(CODE_NAME,10);

   fpsystem('./configure --prefix=/usr --includedir="\${prefix}/include" --mandir="\${prefix}/share/man" --infodir="\${prefix}/share/info" --sysconfdir=/etc --localstatedir=/var --libexecdir="\${prefix}/lib/clucene-core"');
   install.INSTALL_PROGRESS(CODE_NAME,'clucene');
   install.INSTALL_STATUS(CODE_NAME,10);
   fpsystem('make');
   install.INSTALL_PROGRESS(CODE_NAME,'clucene');
   install.INSTALL_STATUS(CODE_NAME,10);
   fpsystem('make install');
if FileExists('/usr/lib/CLucene/clucene-config.h') then begin
   SetCurrentDir('/root');
   exit(true);
end;
install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
install.INSTALL_STATUS(CODE_NAME,110);

end;
//#########################################################################################
function tzarafa.google_perftools():boolean;
begin
result:=false;
if FileExists('/usr/bin/pprof') then exit(true);
if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('google-perftools');
  if not DirectoryExists(source_folder) then begin
     writeln('Install google perftools failed...');
     exit;
  end;
  forceDirectories('/root/goolge-perfs');
  fpsystem('/bin/cp -rf '+source_folder+'/* /root/goolge-perfs/');


   SetCurrentDir('/root/goolge-perfs');
   install.INSTALL_PROGRESS(CODE_NAME,'perftools');
   install.INSTALL_STATUS(CODE_NAME,30);
   fpsystem('./configure --prefix=/usr --includedir="\${prefix}/include" --mandir="\${prefix}/share/man" --infodir="\${prefix}/share/info" --sysconfdir=/etc --localstatedir=/var --libexecdir="\${prefix}/lib/google-perftools"');
   install.INSTALL_PROGRESS(CODE_NAME,'perftools');
    install.INSTALL_STATUS(CODE_NAME,30);

   fpsystem('make');
   install.INSTALL_PROGRESS(CODE_NAME,'perftools');
   install.INSTALL_STATUS(CODE_NAME,30);
   fpsystem('make install');

if FileExists('/usr/bin/pprof') then begin
   SetCurrentDir('/root');
   exit(true);
end;
 writeln('Unable to stat /usr/bin/pprof tool');
install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
install.INSTALL_STATUS(CODE_NAME,110);
end;
//#########################################################################################
procedure tzarafa.xcompile();
var
   CODE_NAME:string;
   cmd:string;
   PERL_MODULES:string;
   configure_scripts:string;
   LOCAL_INTEGER:integer;
   REMOTE_INTEGER:integer;
   t:tstringlist;
   l:Tstringlist;
   i:integer;
   Arch:Integer;
   pkg:string;
begin

CODE_NAME:='APP_ZARAFA';

 writeln('-------------- Checking  clucene library ------------');
 install.INSTALL_STATUS(CODE_NAME,10);
 install.INSTALL_PROGRESS(CODE_NAME,'{checking}');
   if not clucene() then begin
      install.INSTALL_STATUS(CODE_NAME,110);
      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      exit;
   end;

 CODE_NAME:='APP_ZARAFA';
 writeln('-------------- Checking  Google perftools library ------------');
 install.INSTALL_STATUS(CODE_NAME,30);
 install.INSTALL_PROGRESS(CODE_NAME,'perftools');
   if not google_perftools() then begin
      install.INSTALL_STATUS(CODE_NAME,110);
      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      writeln('-------------- installing Google perftools failed ------------');
      exit;
   end;
 CODE_NAME:='APP_ZARAFA';
 writeln('-------------- Checking libvmime library ------------');
 install.INSTALL_STATUS(CODE_NAME,50);
 install.INSTALL_PROGRESS(CODE_NAME,'libvmime');
   if not libvmime() then begin
      install.INSTALL_STATUS(CODE_NAME,110);
      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      writeln('-------------- installing libvmime library failed ------------');
      exit;
   end;
 CODE_NAME:='APP_ZARAFA';
 writeln('-------------- Checking libical library ------------');
 install.INSTALL_STATUS(CODE_NAME,70);
 install.INSTALL_PROGRESS(CODE_NAME,'libical');
    if not libical() then begin
      install.INSTALL_STATUS(CODE_NAME,110);
      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
       writeln('-------------- installing libical library failed ------------');
      exit;
   end;

 writeln('-------------- Installing Zarafa server ------------');
  fpsystem('ldconfig');
  CODE_NAME:='APP_ZARAFA';
  install.INSTALL_STATUS(CODE_NAME,80);
  install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');
  configure_scripts:='VMIME_PREFIX="/usr/include/vmime" ./configure --with-vmime-prefix=/usr/local/include --with-ical-prefix=/usr/local/include';
  configure_scripts:=configure_scripts+'  --enable-tcmalloc --disable-static --disable-testtools --with-userscript-prefix=/etc/zarafa/userscripts --with-quotatemplate-prefix=/etc/zarafa/quotamails --prefix=/usr/local --sysconfdir=/etc';
  if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('zarafa');


  if not DirectoryExists(source_folder) then begin
     writeln('Install zarafa failed...');
      install.INSTALL_STATUS(CODE_NAME,110);
      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      exit;
  end;
    SetCurrentDir(source_folder);
    install.INSTALL_STATUS(CODE_NAME,80);
    install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');
    writeln('using: ',configure_scripts);
    fpsystem(configure_scripts);
    fpsystem('make');
    install.INSTALL_STATUS(CODE_NAME,90);
    install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
    fpsystem('make install');

    if not FIleExists('/usr/local/bin/zarafa-server') then begin
          install.INSTALL_STATUS(CODE_NAME,110);
          install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
          exit;
    end;

    forceDirectories('/usr/share/zarafa-webaccess');
    forceDirectories('/usr/share/zarafa-webaccess-mobile');
    if not DirectoryExists(source_folder+'/php-webclient-ajax') then begin
       writeln('Unable to stat '+source_folder+'/php-webclient-ajax');
       install.INSTALL_STATUS(CODE_NAME,110);
       install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
       exit;
    end;

    fpsystem('/bin/cp -rfv '+source_folder+'/php-webclient-ajax/* /usr/share/zarafa-webaccess/');
    fpsystem('/bin/cp -rfv '+source_folder+'/php-mobile-webaccess/* /usr/share/zarafa-webaccess-mobile/');

    install.INSTALL_STATUS(CODE_NAME,100);
    install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
    forcedirectories('/var/lib/zarafa-webaccess/tmp');

l:=tstringlist.Create;
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/da_DK.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/da_DK.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/de_DE.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/de_DE.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/en_US.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/en_US.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/es_CA.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/es_CA.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/es_ES.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/es_ES.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/fi_FI.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/fi_FI.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/fr_BE.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/fr_BE.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/fr_FR.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/fr_FR.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/it_IT.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/it_IT.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/nl_NL.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/nl_NL.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/no_NO.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/no_NO.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/pt_BR.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/pt_BR.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/pt_PT.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/pt_PT.UTF-8/LC_MESSAGES/zarafa.mo');
l.add('/usr/bin/msgfmt /usr/share/zarafa-webaccess/server/language/sv_SE.UTF-8/LC_MESSAGES/zarafa.po -o /usr/share/zarafa-webaccess/server/language/sv_SE.UTF-8/LC_MESSAGES/zarafa.mo');
for i:=0 to l.Count-1 do begin
    fpsystem(l.Strings[i]);
end;
    fpsystem('/usr/share/artica-postfix/bin/process1 --force');
    fpsystem('/usr/share/artica-postfix/bin/artica-install --postfix-reload');
    fpsystem('/etc/init.d/artica-postfix restart apache');
    fpsystem('/etc/init.d/artica-postfix restart zarafa');
    fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.postfix.maincf.php --mailbox-transport');
end;

//##############################################################################
procedure tzarafa.netatalk();
var
   CODE_NAME:string;
   cmd:string;
   PERL_MODULES:string;
   configure_scripts:string;
   ODIST:boolean;
   REMOTE_INTEGER:integer;
   t:tstringlist;
   l:Tstringlist;
   i:integer;
   Arch:Integer;
   pkg:string;
begin
CODE_NAME:='APP_NETATALK';
 distri:=tdistriDetect.Create;
writeln('RESULT.................: Installing/Upgrading');
ODIST:=false;
Arch:=libs.ArchStruct();
writeln('RESULT.................: Architecture : ',Arch);
writeln('RESULT.................: Distribution : ',distri.DISTRINAME,' (DISTRINAME)');
writeln('RESULT.................: Major version: ',distri.DISTRI_MAJOR,' (DISTRI_MAJOR)');
writeln('RESULT.................: Artica Code  : ',distri.DISTRINAME_CODE,' (DISTRINAME_CODE)');
if distri.DISTRINAME_CODE='UBUNTU' then ODIST:=true;
if distri.DISTRINAME_CODE='DEBIAN' then ODIST:=true;
if not ODIST then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed} {not_supported}');
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
end;
if distri.DISTRINAME_CODE='DEBIAN' then begin
     if distri.DISTRI_MAJOR<6  then ODIST:=false;
end;
if distri.DISTRINAME_CODE='UBUNTU' then begin
     if distri.DISTRI_MAJOR<10  then ODIST:=false;
end;




if not ODIST then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed} {not_supported} '+intToStr(distri.DISTRI_MAJOR));
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
end;

if arch=32 then pkg:='netatalk-debian6-32';
if arch=64 then pkg:='netatalk-debian6-64';


    if length(pkg)=0 then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed} Arch !');
         writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
         exit;
       end;


      writeln('checking source................: ',pkg);

      source_folder:=libs.COMPILE_GENERIC_APPS(pkg);

      if not DirectoryExists(source_folder) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed} {download}');
         exit;
      end;

      source_folder:=extractFilePath(source_folder);
      writeln('source.................: ',source_folder);
      fpsystem('/bin/cp -rfd '+source_folder+'* /');

      if not FIleExists('/etc/init.d/netatalk') then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed} {extract}');
         exit;
      end;

      if not FIleExists(SYS.LOCATE_GENERIC_BIN('afpd')) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed} {extract}');
         exit;
      end;
      fpsystem(SYS.LOCATE_GENERIC_BIN('update-rc.d')+' -f netatalk defaults');
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      fpsystem('/etc/init.d/artica-postfix restart netatalk');

end;
//##############################################################################

procedure tzarafa.arkeia();
var
   CODE_NAME:string;
   cmd:string;
   PERL_MODULES:string;
   configure_scripts:string;
   LOCAL_INTEGER:integer;
   REMOTE_INTEGER:integer;
   t:tstringlist;
   l:Tstringlist;
   i:integer;
   Arch:Integer;
   pkg:string;
begin
LOCAL_INTEGER:=0;
REMOTE_INTEGER:=0;
CODE_NAME:='APP_ARKEIA';



 distri:=tdistriDetect.Create;
writeln('RESULT.................: Installing/Upgrading');

Arch:=libs.ArchStruct();
writeln('RESULT.................: Architecture : ',Arch);
writeln('RESULT.................: Distribution : ',distri.DISTRINAME,' (DISTRINAME)');
writeln('RESULT.................: Major version: ',distri.DISTRI_MAJOR,' (DISTRI_MAJOR)');
writeln('RESULT.................: Artica Code  : ',distri.DISTRINAME_CODE,' (DISTRINAME_CODE)');

if arch=32 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');

      if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 6 only');
               exit;
           end;

           if distri.DISTRI_MAJOR=5  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=6  then pkg:='arkeia-debian6-i386';


       end;



end;
if arch=64 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');

      if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 6 only');
               exit;
           end;

           if distri.DISTRI_MAJOR=5  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=6  then pkg:='arkeia-debian6-x64';


       end;



end;
    if length(pkg)=0 then begin
        install.INSTALL_STATUS(CODE_NAME,110);
        install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 6 only ('+distri.DISTRINAME_CODE+' not supported)');
        exit;
   end;
   source_folder:=libs.COMPILE_GENERIC_APPS(pkg);
   if not DirectoryExists(source_folder) then begin
      install.INSTALL_STATUS(CODE_NAME,110);
      install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
      exit;
   end;
   source_folder:=extractFilePath(source_folder);
   writeln('source.................: ',source_folder);
   install.INSTALL_STATUS(CODE_NAME,50);
   install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
   writeln('/bin/cp -rfd '+source_folder+'* /');
   fpsystem('/bin/cp -rfd '+source_folder+'* /');
   if FileExists('/opt/arkeia/bin/arkboot') then begin
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.arkeia.php --build');
      SYS.set_INFO('EnableArkeia','1');
      fpsystem('/etc/init.d/artica-postfix restart arkeia');
      fpsystem('/etc/init.d/artica-postfix restart apache');
      exit;
   end;
        install.INSTALL_STATUS(CODE_NAME,110);
        install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
        exit;
end;

procedure tzarafa.archiver();
var
   CODE_NAME:string;
   cmd:string;
   PERL_MODULES:string;
   configure_scripts:string;
   LOCAL_INTEGER:integer;
   REMOTE_INTEGER:integer;
   t:tstringlist;
   l:Tstringlist;
   i:integer;
   Arch:Integer;
   pkg:string;
begin
LOCAL_INTEGER:=0;
REMOTE_INTEGER:=0;
CODE_NAME:='APP_ZARAFA_ARCHIVER';



 distri:=tdistriDetect.Create;
writeln('RESULT.................: Installing/Upgrading');

Arch:=libs.ArchStruct();
writeln('RESULT.................: Architecture : ',Arch);
writeln('RESULT.................: Distribution : ',distri.DISTRINAME,' (DISTRINAME)');
writeln('RESULT.................: Major version: ',distri.DISTRI_MAJOR,' (DISTRI_MAJOR)');
writeln('RESULT.................: Artica Code  : ',distri.DISTRINAME_CODE,' (DISTRINAME_CODE)');

if arch=32 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');




      if distri.DISTRINAME_CODE='SUSE' then begin
           if distri.DISTRI_MAJOR=11 then begin
              pkg:='zarafa-archiver-i386-opensuse';
           end;

      end;

      if distri.DISTRINAME_CODE='CENTOS' then begin
           if distri.DISTRI_MAJOR=5 then begin
               pkg:='zarafa-archiver-i386-centos';
           end;

      end;

      if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 5-6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=5  then pkg:='zarafa-archiver-debian50-i386';
           if distri.DISTRI_MAJOR=6  then pkg:='zarafa-archiver-debian60-i386';


       end;


       if distri.DISTRINAME_CODE='UBUNTU' then begin
            if distri.DISTRI_MAJOR=9  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=11  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=10 then pkg:='zarafa-archiver-ubuntu100-i386';
            if distri.DISTRI_MAJOR=12 then pkg:='zarafa-archiver-ubuntu120-i386';
            if distri.DISTRI_MAJOR=8 then pkg:='zarafa-archiver-ubuntu80-i386';
       end;


       if length(pkg)=0 then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
         exit;
       end;
      source_folder:=libs.COMPILE_GENERIC_APPS(pkg);

      if not DirectoryExists(source_folder) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         exit;
      end;
      source_folder:=extractFilePath(source_folder);
      writeln('source.................: ',source_folder);
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
      forceDirectories('/usr/share/php/mapi');
      forceDirectories('/etc/php5/apache2/conf.d');
      fpsystem('/etc/init.d/artica-postfix stop zarafa');
      REMOVE();
      fpsystem('/bin/cp -rfd '+source_folder+'* /');
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      libs.NOTIFICATION('Success install zarafa','Artica make has successfully installed Zarafa archiver','mailbox');
      fpsystem('/etc/init.d/artica-postfix restart zarafa');
      exit;
end;

if arch=64 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');

      if distri.DISTRINAME_CODE='CENTOS' then begin
           if distri.DISTRI_MAJOR=5 then begin
               pkg:='zarafa-archiver-x64-centos';
           end;

      end;

       if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 5-6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=5  then pkg:='zarafa-archiver-debian50-x64';
           if distri.DISTRI_MAJOR=6  then pkg:='zarafa-archiver-debian60-x64';


       end;
       if distri.DISTRINAME_CODE='UBUNTU' then begin
            if distri.DISTRI_MAJOR=9  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=11  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=10 then pkg:='zarafa-archiver-ubuntu100-x64';
            if distri.DISTRI_MAJOR=8 then pkg:='zarafa-archiver-ubuntu80-x64';
            if distri.DISTRI_MAJOR=12 then pkg:='zarafa-archiver-ubuntu120-x64';

       end;


       if length(pkg)=0 then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
         exit;
       end;


      writeln('checking source................: ',pkg);

      source_folder:=libs.COMPILE_GENERIC_APPS(pkg);

      if not DirectoryExists(source_folder) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         exit;
      end;
      source_folder:=extractFilePath(source_folder);
      writeln('source.................: ',source_folder);
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
      fpsystem('/etc/init.d/artica-postfix stop zarafa');
      REMOVE();
      fpsystem('/bin/cp -rfd '+source_folder+'* /');
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      libs.NOTIFICATION('Success install zarafa','Artica make has successfully installed Zarafa Archiver','mailbox');
      fpsystem('/etc/init.d/artica-postfix restart zarafa');
      exit;
end;




  if distri.DISTRINAME_CODE='FEDORA' then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
  end;

  if distri.DISTRINAME_CODE='MANDRAKE' then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
  end;




end;
//#########################################################################################
procedure tzarafa.xinstall6();
var
   CODE_NAME:string;
   cmd:string;
   PERL_MODULES:string;
   configure_scripts:string;
   LOCAL_INTEGER:integer;
   REMOTE_INTEGER:integer;
   t:tstringlist;
   l:Tstringlist;
   i:integer;
   Arch:Integer;
   pkg:string;
begin
LOCAL_INTEGER:=0;
REMOTE_INTEGER:=0;
CODE_NAME:='APP_ZARAFA6';



 if libs.COMMANDLINE_PARAMETERS('--uninstall') then begin
     writeln('Uninstall process is enabled');
     REMOVE();
 end;


 distri:=tdistriDetect.Create;
Arch:=libs.ArchStruct();
writeln('RESULT.................: Architecture : ',Arch);
writeln('RESULT.................: Distribution : ',distri.DISTRINAME,' (DISTRINAME)');
writeln('RESULT.................: Major version: ',distri.DISTRI_MAJOR,' (DISTRI_MAJOR)');
writeln('RESULT.................: Artica Code  : ',distri.DISTRINAME_CODE,' (DISTRINAME_CODE)');
fpsystem('/usr/share/artica-postfix/bin/setup-ubuntu --check-base-system');
if arch=32 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');




      if distri.DISTRINAME_CODE='SUSE' then begin
           if distri.DISTRI_MAJOR=11 then begin
              pkg:='zarafa6-i386-opensuse';
           end;

      end;

      if distri.DISTRINAME_CODE='CENTOS' then begin
           if distri.DISTRI_MAJOR=5 then begin
               pkg:='zarafa6-i386-centos';
           end;

      end;

      if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 5-6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=5  then pkg:='zarafa6-debian50-i386';
           if distri.DISTRI_MAJOR=6  then pkg:='zarafa6-debian60-i386';


       end;


       if distri.DISTRINAME_CODE='UBUNTU' then begin
            if distri.DISTRI_MAJOR=9  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=11  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=10 then pkg:='zarafa6-ubuntu100-i386';
            if distri.DISTRI_MAJOR=8 then pkg:='zarafa6-ubuntu80-i386';
       end;


       if length(pkg)=0 then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
         exit;
       end;
      source_folder:=libs.COMPILE_GENERIC_APPS(pkg);

      if not DirectoryExists(source_folder) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         exit;
      end;
      source_folder:=extractFilePath(source_folder);
      writeln('source.................: ',source_folder);
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{installing}');


      l:=Tstringlist.Create;
      l.Add('/usr/lib/libinetmapi.so.1.0.0');
      l.Add('/usr/lib/libinetmapi.so.1');
      l.Add('/usr/lib/libinetmapi.so');
      l.Add('/usr/lib/libmapi.la');
      l.Add('/usr/lib/libmapi.so');
      l.Add('/usr/lib/libmapi.so.0');
      l.Add('/usr/lib/libmapi.so.0.0.0');
      l.add('/usr/lib/php5/20090626/mapi.so');
      for i:=0 to l.Count-1 do begin
          if FileExists(l.Strings[i]) then begin
             writeln('removing '+l.Strings[i]);
             fpsystem('/bin/rm -f '+l.Strings[i]);
          end;
      end;



      forceDirectories('/usr/share/php/mapi');
      forceDirectories('/etc/php5/apache2/conf.d');
      fpsystem('/etc/init.d/artica-postfix stop zarafa');
      REMOVE();
      fpsystem('/bin/cp -rfd '+source_folder+'* /');
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      libs.NOTIFICATION('Success install zarafa','Artica make has successfully installed Zarafa','mailbox');
      fpsystem('/etc/init.d/artica-postfix restart zarafa');
      fpsystem('/etc/init.d/artica-postfix restart apache');
      fpsystem('/etc/init.d/artica-postfix restart zarafa-web');
      exit;
end;

if arch=64 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');

      if distri.DISTRINAME_CODE='CENTOS' then begin
           if distri.DISTRI_MAJOR=5 then begin
               pkg:='zarafa-x64-centos';
           end;

      end;

       if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 5-6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=5  then pkg:='zarafa6-debian50-x64';
           if distri.DISTRI_MAJOR=6  then pkg:='zarafa6-debian60-x64';


       end;
       if distri.DISTRINAME_CODE='UBUNTU' then begin
            if distri.DISTRI_MAJOR=9  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=11  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=10 then pkg:='zarafa6-ubuntu100-x64';
            if distri.DISTRI_MAJOR=8 then pkg:='zarafa6-ubuntu80-x64';
       end;


       if length(pkg)=0 then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
         exit;
       end;


      writeln('checking source................: ',pkg);

      source_folder:=libs.COMPILE_GENERIC_APPS(pkg);

      if not DirectoryExists(source_folder) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         exit;
      end;

      l:=Tstringlist.Create;
      l.Add('/usr/lib/libinetmapi.so.1.0.0');
      l.Add('/usr/lib/libinetmapi.so.1');
      l.Add('/usr/lib/libinetmapi.so');
      l.Add('/usr/lib/libinetmapi.so.1');


      for i:=0 to l.Count-1 do begin
          if FileExists(l.Strings[i]) then begin
             writeln('removing '+l.Strings[i]);
             fpsystem('/bin/rm -f '+l.Strings[i]);
          end;
      end;
      source_folder:=extractFilePath(source_folder);
      writeln('source.................: ',source_folder);
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
      fpsystem('/etc/init.d/artica-postfix stop zarafa');
      REMOVE();
      fpsystem('/bin/cp -rfd '+source_folder+'* /');
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      libs.NOTIFICATION('Success install zarafa','Artica make has successfully installed Zarafa','mailbox');
      fpsystem('/etc/init.d/artica-postfix restart zarafa');
      fpsystem('/etc/init.d/artica-postfix restart apachesrc');
      fpsystem('/etc/init.d/artica-postfix restart zarafa-web');
      exit;
end;




  if distri.DISTRINAME_CODE='FEDORA' then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
  end;

  if distri.DISTRINAME_CODE='MANDRAKE' then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
  end;




end;
//#########################################################################################


//#########################################################################################
procedure tzarafa.xinstall(ProductCode:string);
var
   CODE_NAME:string;
   cmd:string;
   PERL_MODULES:string;
   configure_scripts:string;
   LOCAL_INTEGER:integer;
   REMOTE_INTEGER:integer;
   t:tstringlist;
   l:Tstringlist;
   i:integer;
   Arch:Integer;
   pkg:string;
begin
LOCAL_INTEGER:=0;
REMOTE_INTEGER:=0;
CODE_NAME:=ProductCode;
if length(CODE_NAME)=0 then CODE_NAME:='APP_ZARAFA';



 if libs.COMMANDLINE_PARAMETERS('--uninstall') then begin
     writeln('Uninstall process is enabled');
     REMOVE();
 end;


 distri:=tdistriDetect.Create;
 REMOTE_INTEGER:=REMOTE_VERSION_INTEGER();
 LOCAL_INTEGER:=VERSION_INTEGER();

 writeln('LOCAL VERSION..........: ',LOCAL_INTEGER);
 writeln('REMOTE VERSION.........: ',REMOTE_INTEGER);

 if  LOCAL_INTEGER>=REMOTE_INTEGER then begin
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
      writeln('RESULT.................: No update needed');
      install.INSTALL_STATUS('APP_ZARAFA',100);
      install.INSTALL_PROGRESS('APP_ZARAFA','{installed}');
      exit();
end;
writeln('RESULT.................: Installing/Upgrading');

Arch:=libs.ArchStruct();
writeln('RESULT.................: Architecture : ',Arch);
writeln('RESULT.................: Distribution : ',distri.DISTRINAME,' (DISTRINAME)');
writeln('RESULT.................: Major version: ',distri.DISTRI_MAJOR,' (DISTRI_MAJOR)');
writeln('RESULT.................: Artica Code  : ',distri.DISTRINAME_CODE,' (DISTRINAME_CODE)');
fpsystem('/usr/share/artica-postfix/bin/setup-ubuntu --check-base-system');
if arch=32 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');




      if distri.DISTRINAME_CODE='SUSE' then begin
           if distri.DISTRI_MAJOR=11 then begin
              pkg:='zarafa-i386-opensuse';
           end;

      end;

      if distri.DISTRINAME_CODE='CENTOS' then begin
           if distri.DISTRI_MAJOR=5 then begin
               pkg:='zarafa-i386-centos';
           end;

      end;

      if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 5-6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=5  then pkg:='zarafa-debian50-i386';
           if distri.DISTRI_MAJOR=6  then pkg:='zarafa-debian60-i386';


       end;


       if distri.DISTRINAME_CODE='UBUNTU' then begin
            if distri.DISTRI_MAJOR=9  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=11  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;
            if distri.DISTRI_MAJOR=12 then pkg:='zarafa-ubuntu120-i386';
            if distri.DISTRI_MAJOR=10 then pkg:='zarafa-ubuntu100-i386';
            if distri.DISTRI_MAJOR=8 then pkg:='zarafa-ubuntu80-i386';
       end;


       if length(pkg)=0 then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
         exit;
       end;
      source_folder:=libs.COMPILE_GENERIC_APPS(pkg);

      if not DirectoryExists(source_folder) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         exit;
      end;
      source_folder:=extractFilePath(source_folder);
      writeln('source.................: ',source_folder);
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{installing}');


      l:=Tstringlist.Create;
      l.Add('/usr/lib/libinetmapi.so.1.0.0');
      l.Add('/usr/lib/libinetmapi.so.1');
      l.Add('/usr/lib/libinetmapi.so');
      l.Add('/usr/lib/libmapi.la');
      l.Add('/usr/lib/libmapi.so');
      l.Add('/usr/lib/libmapi.so.0');
      l.Add('/usr/lib/libmapi.so.0.0.0');
      l.add('/usr/lib/php5/20090626/mapi.so');
      for i:=0 to l.Count-1 do begin
          if FileExists(l.Strings[i]) then begin
             writeln('removing '+l.Strings[i]);
             fpsystem('/bin/rm -f '+l.Strings[i]);
          end;
      end;




      forceDirectories('/usr/share/php/mapi');
      forceDirectories('/etc/php5/apache2/conf.d');
      fpsystem('/etc/init.d/artica-postfix stop zarafa');
      REMOVE();
      fpsystem('/bin/cp -rfd '+source_folder+'* /');
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      libs.NOTIFICATION('Success install zarafa','Artica make has successfully installed Zarafa','mailbox');
      fpsystem('/etc/init.d/artica-postfix restart zarafa');
      fpsystem('/etc/init.d/artica-postfix restart apache');
      fpsystem('/etc/init.d/artica-postfix restart zarafa-web');
      exit;
end;

if arch=64 then begin

      SetCurrentDir('/root');
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');

      if distri.DISTRINAME_CODE='CENTOS' then begin
           if distri.DISTRI_MAJOR=5 then begin
               pkg:='zarafa-x64-centos';
           end;

      end;

       if distri.DISTRINAME_CODE='DEBIAN' then begin
           if distri.DISTRI_MAJOR=4  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} debian 5-6 only');
               exit;
           end;
           if distri.DISTRI_MAJOR=5  then pkg:='zarafa-debian50-x64';
           if distri.DISTRI_MAJOR=6  then pkg:='zarafa-debian60-x64';


       end;
       if distri.DISTRINAME_CODE='UBUNTU' then begin
            if distri.DISTRI_MAJOR=9  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;

            if distri.DISTRI_MAJOR=11  then begin
               install.INSTALL_STATUS(CODE_NAME,110);
               install.INSTALL_PROGRESS(CODE_NAME,'{failed} ubuntu 10.04 only');
               exit;
            end;
            if distri.DISTRI_MAJOR=10 then pkg:='zarafa-ubuntu120-x64';
            if distri.DISTRI_MAJOR=10 then pkg:='zarafa-ubuntu100-x64';
            if distri.DISTRI_MAJOR=8 then pkg:='zarafa-ubuntu80-x64';
       end;


       if length(pkg)=0 then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
         exit;
       end;


      writeln('checking source................: ',pkg);

      source_folder:=libs.COMPILE_GENERIC_APPS(pkg);

      if not DirectoryExists(source_folder) then begin
         install.INSTALL_STATUS(CODE_NAME,110);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         exit;
      end;

      l:=Tstringlist.Create;
      l.Add('/usr/lib/libinetmapi.so.1.0.0');
      l.Add('/usr/lib/libinetmapi.so.1');
      l.Add('/usr/lib/libinetmapi.so');
      l.Add('/usr/lib/libinetmapi.so.1');


      for i:=0 to l.Count-1 do begin
          if FileExists(l.Strings[i]) then begin
             writeln('removing '+l.Strings[i]);
             fpsystem('/bin/rm -f '+l.Strings[i]);
          end;
      end;

      source_folder:=extractFilePath(source_folder);
      writeln('source.................: ',source_folder);
      install.INSTALL_STATUS(CODE_NAME,50);
      install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
      fpsystem('/etc/init.d/artica-postfix stop zarafa');
      REMOVE();
      fpsystem('/bin/cp -rfd '+source_folder+'* /');
      install.INSTALL_STATUS(CODE_NAME,100);
      install.INSTALL_PROGRESS(CODE_NAME,'{success}');
      libs.NOTIFICATION('Success install zarafa','Artica make has successfully installed Zarafa','mailbox');
      fpsystem('/etc/init.d/artica-postfix restart zarafa');
      fpsystem('/etc/init.d/artica-postfix restart apachesrc');
      fpsystem('/etc/init.d/artica-postfix restart zarafa-web');
      exit;
end;




  if distri.DISTRINAME_CODE='FEDORA' then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
  end;

  if distri.DISTRINAME_CODE='MANDRAKE' then begin
     install.INSTALL_STATUS(CODE_NAME,110);
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     writeln(distri.DISTRINAME,' ',distri.DISTRINAME_CODE,' ',distri.DISTRI_MAJOR,' not supported');
     exit;
  end;




end;
//#########################################################################################
procedure tzarafa.REMOVE();
var
   l:Tstringlist;
   i:integer;
begin
l:=Tstringlist.Create;
l.add('/usr/local/lib/libical.a');
l.add('/usr/local/lib/libical.la');
l.add('/usr/local/lib/libicalmapi.la');
l.add('/usr/local/lib/libicalmapi.so');
l.add('/usr/local/lib/libicalmapi.so.1');
l.add('/usr/local/lib/libicalmapi.so.1.0.0');
l.add('/usr/local/lib/libical.so');
l.add('/usr/local/lib/libical.so.0');
l.add('/usr/local/lib/libical.so.0.44.0');
l.add('/usr/local/lib/libicalss.a');
l.add('/usr/local/lib/libicalss.la');
l.add('/usr/local/lib/libicalss.so');
l.add('/usr/local/lib/libicalss.so.0');
l.add('/usr/local/lib/libicalss.so.0.44.0');
l.add('/usr/local/lib/libicalvcal.a');
l.add('/usr/local/lib/libicalvcal.la');
l.add('/usr/local/lib/libicalvcal.so');
l.add('/usr/local/lib/libicalvcal.so.0');
l.add('/usr/local/lib/libicalvcal.so.0.44.0');
l.add('/usr/local/lib/libinetmapi.la');
l.add('/usr/local/lib/libinetmapi.so');
l.add('/usr/local/lib/libinetmapi.so.1');
l.add('/usr/local/lib/libinetmapi.so.1.0.0');
l.add('/usr/local/lib/libmapi.la');
l.add('/usr/local/lib/libmapi.so');
l.add('/usr/local/lib/libmapi.so.0');
l.add('/usr/local/lib/libmapi.so.0.0.0');
l.add('/usr/local/lib/libvmime.a');
l.add('/usr/local/lib/libvmime.la');
l.add('/usr/local/lib/libvmime.so');
l.add('/usr/local/lib/libvmime.so.0');
l.add('/usr/local/lib/libvmime.so.0.7.1');
l.add('/usr/local/lib/libzarafaclient.la');
l.add('/usr/local/lib/libzarafaclient.so');
l.add('/usr/local/bin/zarafa-admin');
l.add('/usr/local/bin/zarafa-autorespond');
l.add('/usr/local/bin/zarafa-dagent');
l.add('/usr/local/bin/zarafa-fsck');
l.add('/usr/local/bin/zarafa-gateway');
l.add('/usr/local/bin/zarafa-ical');
l.add('/usr/local/bin/zarafa-monitor');
l.add('/usr/local/bin/zarafa-passwd');
l.add('/usr/local/bin/zarafa-server');
l.add('/usr/local/bin/zarafa-spooler');
l.add('/usr/local/bin/zarafa-stats');
l.add('/usr/local/lib/libical.a');
l.add('/usr/local/lib/libicalmapi.so.1.0.0');
l.add('/usr/local/lib/libical.so.0.44.0');
l.add('/usr/local/lib/libicalss.so');
l.add('/usr/local/lib/libicalvcal.a');
l.add('/usr/local/lib/libicalvcal.so.0');
l.add('/usr/local/lib/libinetmapi.so.1.0.0');
l.add('/usr/local/lib/libvmime.a');
l.add('/usr/local/lib/libvmime.so.0');
l.add('/usr/local/lib/libical.la');
l.add('/usr/local/lib/libical.so');
l.add('/usr/local/lib/libicalss.a');
l.add('/usr/local/lib/libicalss.so.0');
l.add('/usr/local/lib/libicalvcal.la');
l.add('/usr/local/lib/libicalvcal.so.0.44.0');
l.add('/usr/local/lib/libmapi.so.0');
l.add('/usr/local/lib/libvmime.la');
l.add('/usr/local/lib/libvmime.so.0.7.1');
l.add('/usr/local/lib/zarafa');
l.add('/usr/local/lib/libicalmapi.so.1');
l.add('/usr/local/lib/libical.so.0');
l.add('/usr/local/lib/libicalss.la');
l.add('/usr/local/lib/libicalss.so.0.44.0');
l.add('/usr/local/lib/libicalvcal.so');
l.add('/usr/local/lib/libinetmapi.so.1');
l.add('/usr/local/lib/libmapi.so.0.0.0');
l.add('/usr/local/lib/libvmime.so');
l.add('/usr/local/lib/libzarafaclient.so');
l.add('/usr/bin/zarafa-indexer');
l.add('/usr/bin/zarafa-dagent');
l.add('/usr/bin/zarafa-fsck');
l.add('/usr/bin/zarafa-backup');
l.add('/usr/bin/zarafa-ical');
l.add('/usr/bin/zarafa-msr');
l.add('/usr/bin/zarafa-spooler');
l.add('/usr/bin/zarafa-ssm');
l.add('/usr/bin/zarafa-monitor');
l.add('/usr/bin/zarafa-admin');
l.add('/usr/bin/zarafa-server');
l.add('/usr/bin/zarafa-gateway');
l.add('/usr/bin/zarafa-passwd');
l.add('/usr/bin/zarafa-stats');
l.add('/usr/bin/zarafa-licensed');
l.add('/usr/bin/zarafa-report');
l.add('/usr/bin/zarafa-autorespond');
l.add('/usr/bin/zarafa-restore');
l.add('/usr/lib/libvmime.so.0');
l.add('/usr/lib/libical.a');
l.add('/usr/lib/libcommon_util.la');
l.add('/usr/lib/libcommon_mapi.la');
l.add('/usr/lib/libicalss.la');
l.add('/usr/lib/libicalvcal.a');
l.add('/usr/lib/libical.so.0.44.0');
l.add('/usr/lib/libinetmapi.la');
l.add('/usr/lib/libcommon_ssl.la');
l.add('/usr/lib/libmapi.so.0.0.0');
l.add('/usr/lib/zarafa/dbplugin.so');
l.add('/usr/lib/zarafa/ldapmsplugin.so');
l.add('/usr/lib/zarafa/unixplugin.so');
l.add('/usr/lib/zarafa/ldapplugin.so');
l.add('/usr/lib/php5/extensions/mapi.so');
l.add('/usr/lib/libicalmapi.so.1.0.0');
l.add('/usr/lib/libarchiver.so');
l.add('/usr/lib/libicalss.a');
l.add('/usr/lib/libicalvcal.so.0.44.0');
l.add('/usr/lib/libinetmapi.so.1.0.0');
l.add('/usr/lib/libcommon_util.a');
l.add('/usr/lib/libicalmapi.la');
l.add('/usr/lib/libfreebusy.la');
l.add('/usr/lib/libicalmapi.so');
l.add('/usr/lib/libcommon_ssl.a');
l.add('/usr/lib/libmapi.so.0');
l.add('/usr/lib/libinetmapi.so');
l.add('/usr/lib/libicalvcal.la');
l.add('/usr/lib/libarchiver.la');
l.add('/usr/lib/libzarafasync.a');
l.add('/usr/lib/libicalss.so');
l.add('/usr/lib/libzarafaclient.so');
l.add('/usr/lib/libical.so.0');
l.add('/usr/lib/libzarafasync.la');
l.add('/usr/lib/libicalvcal.so');
l.add('/usr/lib/libvmime.so.0.0.0');
l.add('/usr/lib/libical.la');
l.add('/usr/lib/libicalss.so.0.44.0');
l.add('/usr/lib/libvmime.la');
l.add('/usr/lib/libarchiver.so.0');
l.add('/usr/lib/libmapi.la');
l.add('/usr/lib/libicalmapi.so.1');
l.add('/usr/lib/libicalvcal.so.0');
l.add('/usr/lib/libfreebusy.a');
l.add('/usr/lib/libcommon_mapi.so');
l.add('/usr/lib/libinetmapi.so.1.0.0');
l.add('/usr/lib/php5/20090626/mapi.so');
l.add('/usr/lib/libicalmapi.so');
l.add('/usr/lib/libicalmapi.so.1');
l.add('/usr/lib/libicalmapi.so.1.0.0');
l.add('/usr/lib/libinetmapi.so');
l.add('/usr/lib/libinetmapi.so.1');
l.add('/usr/lib/libinetmapi.so.1.0.0');
l.add('/usr/lib/libmapi.so');
l.add('/usr/lib/libmapi.so.0');
l.add('/usr/lib/libmapi.so.0.0.0');
fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.zarafa.remove.php');




if DirectoryExists('/usr/local/lib/zarafa') then begin
   writeln('Remove directory /usr/local/lib/zarafa');
   fpsystem('/bin/rm -rf /usr/local/lib/zarafa');
end;


for i:=0 TO l.Count-1 do begin
    if FileExists(l.Strings[i]) then begin
       writeln('Remove file '+l.Strings[i]);
       fpsystem('/bin/rm '+ l.Strings[i]);
    end;
end;

writeln('done.');
end;

//##############################################################################
function tzarafa.VERSION_INTEGER():integer;
var
    path:string;
    RegExpr:TRegExpr;
    FileData:TStringList;
    i:integer;
    D:Boolean;
    tmpstr:string;
    a,b,c,final:string;

begin
     result:=0;
     path:='/usr/local/bin/zarafa-server';
     if not FileExists(path) then begin
        exit(0);
     end;
     tmpstr:='/tmp/artica-zarafa-version';
     FileData:=TStringList.Create;
     RegExpr:=TRegExpr.Create;
     fpsystem(path+' -V >'+ tmpstr + ' 2>&1');
     FileData.LoadFromFile(tmpstr);
 RegExpr.Expression:='version:\s+([0-9]+),([0-9]+),([0-9]+)';
  for i:=0 to FileData.Count -1 do begin
          if RegExpr.Exec(FileData.Strings[i]) then  begin
               a:=RegExpr.Match[1];
               b:=RegExpr.Match[2];
               c:=RegExpr.Match[3];
              writeln('LOCAL VERSION  (string): ',a,'.',b,'.',c);
               if length(a)=1 then a:='0'+a;
               if length(b)=1 then b:='0'+b;
               if length(c)=1 then c:='0'+c;
               final:=a+''+b+''+c;
               TryStrToInt(final,result);
          end;
  end;

end;
//#############################################################################
function tzarafa.REMOTE_VERSION_INTEGER():integer;
var
    path:string;
    RegExpr:TRegExpr;
    FileData:TStringList;
    i:integer;
    D:Boolean;
    remoteversion:string;
    a,b,c,final:string;

begin
   RegExpr:=TRegExpr.Create;
    remoteversion:=libs.COMPILE_VERSION_STRING('zarafa');
   RegExpr.Expression:='([0-9]+).([0-9]+).([0-9]+)';
          if RegExpr.Exec(remoteversion) then  begin
               a:=RegExpr.Match[1];
               b:=RegExpr.Match[2];
               c:=RegExpr.Match[3];
              writeln('REMOTE VERSION (string): ',a,'.',b,'.',c);
               if length(a)=1 then a:='0'+a;
               if length(b)=1 then b:='0'+b;
               if length(c)=1 then c:='0'+c;
               final:=a+''+b+''+c;
               TryStrToInt(final,result);
         end;

end;
//#############################################################################
procedure tzarafa.COMPILE_TAR();

var
   l:Tstringlist;
   i:integer;
   patht:string;
begin


l:=Tstringlist.Create;

l.add('/usr/local/bin/zarafa-admin');
l.add('/usr/local/bin/zarafa-autorespond');
l.add('/usr/local/bin/zarafa-cfgchecker');
l.add('/usr/local/bin/zarafa-dagent');
l.add('/usr/local/bin/zarafa-fsck');
l.add('/usr/local/bin/zarafa-gateway');
l.add('/usr/local/bin/zarafa-ical');
l.add('/usr/local/bin/zarafa-indexer');
l.add('/usr/local/bin/zarafa-monitor');
l.add('/usr/local/bin/zarafa-passwd');
l.add('/usr/local/bin/zarafa-server');
l.add('/usr/local/bin/zarafa-spooler');
l.add('/usr/local/bin/zarafa-stats');
l.add('/usr/bin/pprof');
l.add('/usr/lib/CLucene');
l.add('/usr/lib/libclucene.a');
l.add('/usr/lib/libclucene.la');
l.add('/usr/lib/libclucene.so');
l.add('/usr/lib/libclucene.so.0');
l.add('/usr/lib/libclucene.so.0.0.0');
l.add('/usr/lib/libprofiler.a');
l.add('/usr/lib/libprofiler.la');
l.add('/usr/lib/libprofiler.so');
l.add('/usr/lib/libprofiler.so.0');
l.add('/usr/lib/libprofiler.so.0.0.0');
l.add('/usr/lib/libtcmalloc.a');
l.add('/usr/lib/libtcmalloc_and_profiler.a');
l.add('/usr/lib/libtcmalloc_and_profiler.la');
l.add('/usr/lib/libtcmalloc_and_profiler.so');
l.add('/usr/lib/libtcmalloc_and_profiler.so.0');
l.add('/usr/lib/libtcmalloc_and_profiler.so.0.0.0');
l.add('/usr/lib/libtcmalloc_debug.a');
l.add('/usr/lib/libtcmalloc_debug.la');
l.add('/usr/lib/libtcmalloc_debug.so');
l.add('/usr/lib/libtcmalloc_debug.so.0');
l.add('/usr/lib/libtcmalloc_debug.so.0.0.0');
l.add('/usr/lib/libtcmalloc.la');
l.add('/usr/lib/libtcmalloc_minimal.a');
l.add('/usr/lib/libtcmalloc_minimal_debug.a');
l.add('/usr/lib/libtcmalloc_minimal_debug.la');
l.add('/usr/lib/libtcmalloc_minimal_debug.so');
l.add('/usr/lib/libtcmalloc_minimal_debug.so.0');
l.add('/usr/lib/libtcmalloc_minimal_debug.so.0.0.0');
l.add('/usr/lib/libtcmalloc_minimal.la');
l.add('/usr/lib/libtcmalloc_minimal.so');
l.add('/usr/lib/libtcmalloc_minimal.so.0');
l.add('/usr/lib/libtcmalloc_minimal.so.0.0.0');
l.add('/usr/lib/libtcmalloc.so');
l.add('/usr/lib/libtcmalloc.so.0');
l.add('/usr/local/lib/libinetmapi.so.1');
l.add('/usr/local/lib/libinetmapi.so.1.0.0');
l.add('/usr/local/lib/libmapi.so.0');
l.add('/usr/local/lib/libicalmapi.so.1');
l.add('/usr/local/lib/libicalmapi.so.1.0.0');
l.add('/usr/local/lib/libmapi.so.0.0.0');
l.add('/usr/lib/libtcmalloc.so.0.0.0');
l.add('/usr/local/lib/zarafa/dbplugin.la');
l.add('/usr/local/lib/zarafa/dbplugin.so');
l.add('/usr/local/lib/zarafa/ldapplugin.la');
l.add('/usr/local/lib/zarafa/ldapplugin.so');
l.add('/usr/local/lib/zarafa/unixplugin.la');
l.add('/usr/local/lib/zarafa/unixplugin.so');
l.add('/usr/local/include/ical.h');
l.add('/usr/local/include/icalmapi');
l.add('/usr/local/include/inetmapi');
l.add('/usr/local/include/libfreebusy');
l.add('/usr/local/include/libical');
l.add('/usr/local/include/libzarafasync');
l.add('/usr/local/include/mapi4linux');
l.add('/usr/local/include/vmime');
l.add('/usr/local/include/zarafa');
l.add('/usr/include/CLucene');
l.add('/usr/include/CLucene.h');
l.add('/usr/include/google');
l.add('/usr/share/php/mapi');
l.add('/usr/share/zarafa-webaccess');
l.add('/usr/share/zarafa-webaccess-mobile');
l.add('/etc/zarafa');
l.add('/usr/local/lib/libvmime.so.0');
l.add('/usr/local/lib/libvmime.so.0.7.1');
l.add('/usr/local/lib/libical.so.0');
l.add('/usr/local/lib/libical.so.0.44.0');
l.add('/usr/local/lib/libicalss.so.0');
l.add('/usr/local/lib/libicalss.so.0.44.0');
l.add('/usr/local/lib/libzarafaclient.so');
L.add('/usr/lib/php5/20060613+lfs/mapi.so');
L.Add('/usr/local/share/php/mapi');
l.add('/usr/lib/php5/extensions/mapi.so');
l.add('/usr/lib/php5/extensions/mapi.la');
l.add('/etc/php5/conf.d/zarafa.ini');
l.add('/usr/lib/php/modules/mapi.so');
l.add('/usr/lib/php/modules/mapi.la');


forceDirectories('/home/zarafa-compile');

for i:=0 to l.Count-1 do begin
      writeln( l.Strings[i]);
      if DirectoryExists(l.Strings[i]) then begin
         writeln('DIRECTORY:',l.Strings[i]);
         writeln('MKDIR:','/home/zarafa-compile'+l.Strings[i]);
         forceDirectories('/home/zarafa-compile'+l.Strings[i]);
         writeln('/bin/cp -rf '+l.Strings[i]+'/* /home/zarafa-compile'+l.Strings[i]+'/');
         fpsystem('/bin/cp -rf '+l.Strings[i]+'/* /home/zarafa-compile'+l.Strings[i]+'/');
         continue;
      end;

      if FileExists(l.Strings[i]) then begin
         writeln('FILE:',l.Strings[i]);
          patht:=ExtractFilePath(l.Strings[i]);
          writeln('MKDIR:','/home/zarafa-compile'+patht);
          forceDirectories('/home/zarafa-compile'+patht);
          writeln('/bin/cp -d '+l.Strings[i] +' /home/zarafa-compile'+patht);
          fpsystem('/bin/cp -d '+l.Strings[i] +' /home/zarafa-compile'+patht);
      end;
end;


end;




end.
