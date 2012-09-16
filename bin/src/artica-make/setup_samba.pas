unit setup_samba;
{$MODE DELPHI}
//{$mode objfpc}{$H+}
{$LONGSTRINGS ON}
//ln -s /usr/lib/libmilter/libsmutil.a /usr/local/lib/libsmutil.a
//apt-get install libmilter-dev
interface

uses
  Classes, SysUtils,strutils,RegExpr in 'RegExpr.pas',
  unix,IniFiles,setup_libs,distridetect,zsystem,
  install_generic;

  type
  install_samba=class


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
   Arch:Integer;
   SYS:Tsystem;
   function SMBD_PATH():string;


   procedure uninstall();
   function SAMBA_VERSION():string;
   function SAMBA_LIBDIR():string;
   function vfsDir(mainpath:string):string;
   function sourceDir(mainpath:string):string;
   procedure xinstall_precompiled();


public
      constructor Create();
      procedure Free;
      procedure xinstall(sourcestring:string='');
      procedure xinstall_REMOVE_SAMBA();
    procedure pdnsinstall();
    procedure scannedonly();
    procedure greyhole();
    procedure poweradmin();
    function libtdb():boolean;
    function talloc():boolean;
    procedure popt();
    procedure ctdb();
END;

implementation

constructor install_samba.Create();
begin
libs:=tlibs.Create;
install:=tinstall.Create;
source_folder:='';
SYS:=Tsystem.Create();
if DirectoryExists(ParamStr(2)) then source_folder:=ParamStr(2);
end;
//#########################################################################################
procedure install_samba.Free();
begin
  libs.Free;

end;

//#########################################################################################
procedure install_samba.poweradmin();
var
   CODE_NAME:string;
   cmd:string;
   zdate:string;
   smbsources:string;
   l:Tstringlist;
   i:integer;
   compile:boolean;
begin
  CODE_NAME:='APP_POWERADMIN';
  compile:=false;
  distri:=tdistriDetect.Create;
  if distri.DISTRINAME_CODE='DEBIAN' then compile:=true;
  if distri.DISTRINAME_CODE='UBUNTU' then compile:=true;
  if distri.DISTRINAME_CODE='FEDORA' then compile:=true;
  if not compile then begin
     writeln('Upgrading from source for ',distri.DISTRINAME_CODE,' is not yet supported');
     writeln('Please, contact Artica-technology support if need support on ',distri.DISTRINAME_CODE);
     writeln('');
    install.INSTALL_STATUS(CODE_NAME,110);
    install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
   exit;
  end;

 install.INSTALL_STATUS(CODE_NAME,30);
 source_folder:='';
 install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
 source_folder:=libs.COMPILE_GENERIC_APPS('poweradmin');
   if not DirectoryExists(source_folder) then begin
     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;
install.INSTALL_STATUS(CODE_NAME,50);
install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');
SetCurrentDir(source_folder);
writeln('using source dir',source_folder);
ForceDirectories('/usr/share/poweradmin');

cmd:='/bin/cp -rf '+source_folder+'/* /usr/share/poweradmin/';
writeln(cmd);
fpsystem(cmd);
install.INSTALL_STATUS(CODE_NAME,60);
install.INSTALL_PROGRESS(CODE_NAME,'{installing}');


if not FileExists('/usr/share/poweradmin/index.php') then begin
   install.INSTALL_STATUS(CODE_NAME,110);
   install.INSTALL_PROGRESS(CODE_NAME,'{failed} PowerAdmin');
   exit;
end;
writeln('Install '+CODE_NAME+' success (PowerAdmin)...');
install.INSTALL_STATUS(CODE_NAME,100);
install.INSTALL_PROGRESS(CODE_NAME,'{success}');
fpsystem('/etc/init.d/artica-postfix restart apache');
exit;

end;
//##############################################################################
procedure install_samba.pdnsinstall();
var
   CODE_NAME:string;
   cmd:string;
   zdate:string;
   smbsources:string;
   l:Tstringlist;
   i:integer;
   compile:boolean;
   dnsmasq_bin:string;

begin
  CODE_NAME:='APP_PDNS';
  compile:=false;
  distri:=tdistriDetect.Create;
  Arch:=libs.ArchStruct();
  writeln('RESULT.................: Architecture : ',Arch);
  writeln('RESULT.................: Distribution : ',distri.DISTRINAME,' (DISTRINAME)');
  writeln('RESULT.................: Major version: ',distri.DISTRI_MAJOR,' (DISTRI_MAJOR)');
  writeln('RESULT.................: Artica Code  : ',distri.DISTRINAME_CODE,' (DISTRINAME_CODE)');

  dnsmasq_bin:=SYS.LOCATE_GENERIC_BIN('dnsmasq');
  if FileExists(dnsmasq_bin) then begin
     writeln('DnsMasq is detected, remove it....');
     if FileExists('/usr/bin/aptitude') then fpsystem('/usr/bin/aptitude -q -y purge dnsmasq');
     if FileExists('/bin/rpm') then fpsystem('/bin/rpm --quiet -e dnsmasq');
  end;

   dnsmasq_bin:=SYS.LOCATE_GENERIC_BIN('dnsmasq');
   if FileExists(dnsmasq_bin) then begin
      fpsystem('/etc/init.d/artica-postfix stop dnsmasq');
      fpsystem('/bin/rm '+dnsmasq_bin);
   end;

  if distri.DISTRINAME_CODE='DEBIAN' then compile:=true;
  if distri.DISTRINAME_CODE='UBUNTU' then compile:=true;
  if distri.DISTRINAME_CODE='FEDORA' then compile:=true;
  if not compile then begin
     writeln('Upgrading from source for ',distri.DISTRINAME_CODE,' is not yet supported');
     writeln('Please, contact Artica-technology support if need support on ',distri.DISTRINAME_CODE);
     writeln('');
     if FileExists(SYS.LOCATE_GENERIC_BIN('pdns_server')) then begin
        install.INSTALL_STATUS(CODE_NAME,100);
        install.INSTALL_PROGRESS(CODE_NAME,'{success}');
        exit;
     end;
   install.INSTALL_STATUS(CODE_NAME,110);
   install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
   exit;
  end;

 install.INSTALL_STATUS(CODE_NAME,30);
 source_folder:='';
 install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
 source_folder:=libs.COMPILE_GENERIC_APPS('pdns');
   if not DirectoryExists(source_folder) then begin
     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;
install.INSTALL_STATUS(CODE_NAME,50);
install.INSTALL_PROGRESS(CODE_NAME,'{checking}');
SetCurrentDir(source_folder);
writeln('using source dir',source_folder);
cmd:='./configure --prefix=/usr --sysconfdir=/etc/powerdns --mandir=\${prefix}/share/man --infodir=\${prefix}/share/info --libdir=''${prefix}/lib/powerdns'' --libexecdir=''${prefix}/lib'' --with-dynmodules="ldap pipe gmysql geo"';
cmd:=cmd+' --with-modules=""';
writeln('using configure: ',cmd);
fpsystem(cmd);
install.INSTALL_STATUS(CODE_NAME,50);
install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');


fpsystem('make');
install.INSTALL_STATUS(CODE_NAME,60);
install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
fpsystem('make install');
if FileExists(source_folder+'/pdns/pdns') then fpsystem('/bin/cp '+source_folder+'/pdns/pdns /etc/init.d/pdns');
if FileExists(source_folder+'/pdns/precursor') then fpsystem('/bin/cp '+source_folder+'/pdns/precursor /etc/init.d/precursor');
if not FileExists(SYS.LOCATE_GENERIC_BIN('pdns_server')) then begin
   install.INSTALL_STATUS(CODE_NAME,110);
   install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
   exit;
end;
install.INSTALL_STATUS(CODE_NAME,70);
source_folder:='';
install.INSTALL_PROGRESS(CODE_NAME,'{downloading} pdns-recursor');
source_folder:=libs.COMPILE_GENERIC_APPS('pdns-recursor');
    if not DirectoryExists(source_folder) then begin
     writeln('Install '+CODE_NAME+' failed (recursor)...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;

SetCurrentDir(source_folder);
writeln('using source dir',source_folder);
install.INSTALL_STATUS(CODE_NAME,80);
install.INSTALL_PROGRESS(CODE_NAME,'{checking}');
cmd:='./configure';
writeln('using configure: ',cmd);
fpsystem(cmd);
install.INSTALL_STATUS(CODE_NAME,90);
install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');
fpsystem('make');
install.INSTALL_STATUS(CODE_NAME,95);
install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
fpsystem('make install');

if not FileExists(SYS.LOCATE_GENERIC_BIN('pdns_recursor')) then begin
   install.INSTALL_STATUS(CODE_NAME,110);
   install.INSTALL_PROGRESS(CODE_NAME,'{failed} pdns_recursor');
   exit;
end;
writeln('Install '+CODE_NAME+' success (recursor)...');
install.INSTALL_STATUS(CODE_NAME,100);
install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
fpsystem('/usr/share/artica-postfix/bin/artica-make APP_POWERADMIN');
SYS.THREAD_COMMAND_SET('/etc/init.d/artica-postfix restart pdns');
exit;

end;
//##############################################################################
procedure install_samba.scannedonly();
var
   CODE_NAME:string;
   cmd:string;
   zdate:string;
   smbsources:string;
   l:Tstringlist;
   i:integer;
   LOCAL_VERSION,LIBDIR,REMOTE_VERSION,REMOTE_VERSION_SOURCE:string;
   LOCAL_VERSION_INT,REMOTE_VERSION_INT:integer;
begin
  CODE_NAME:='APP_SCANNED_ONLY';
  SetCurrentDir('/root');
  install.INSTALL_STATUS(CODE_NAME,10);
  LOCAL_VERSION:=SAMBA_VERSION();

 writeln('using ',smbsources ,' sources directory');
 LIBDIR:=vfsDir(SAMBA_LIBDIR());
 writeln('using ',LIBDIR ,' vfs directory');
 if not DirectoryExists(LIBDIR) then begin
         writeln('unable to stat vfs dir',LIBDIR);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         install.INSTALL_STATUS(CODE_NAME,110);
         exit;
 end;


 source_folder:=libs.COMPILE_GENERIC_APPS('scannedonly');

  if not DirectoryExists(source_folder) then begin
     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;
install.INSTALL_STATUS(CODE_NAME,50);
install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');
 SetCurrentDir(source_folder);
 writeln('using source dir',source_folder);
 fpsystem('./configure --with-samba-vfs-dir='+LIBDIR+' --prefix=/usr');
 fpsystem('make && make install');

 if not FileExists('/usr/sbin/scannedonlyd_clamav') then begin
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
 end;

install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
install.INSTALL_STATUS(CODE_NAME,100);



end;

//##############################################################################
function install_samba.sourceDir(mainpath:string):string;
begin
    if FIleExists(mainpath+'/source3/configure') then exit(mainpath+'/source3');
    if FIleExists(mainpath+'/source/configure') then exit(mainpath+'/source');


end;
//##############################################################################
function install_samba.vfsDir(mainpath:string):string;
begin
    if DirectoryExists(mainpath+'/vfs') then exit(mainpath+'/vfs');
    if DirectoryExists(mainpath+'/samba/vfs') then exit(mainpath+'/samba/vfs');
end;
//##############################################################################
procedure install_samba.xinstall_precompiled();
 var
   CODE_NAME:string;
   pkg:string;
begin
  CODE_NAME:='APP_SAMBA';
  SetCurrentDir('/root');
  install.INSTALL_STATUS(CODE_NAME,30);

  if Arch=32 then pkg:='sambac-i386';
  if Arch=64 then pkg:='sambac-x64';

  writeln('Using pre-compiled packages....');
   fpsystem('/usr/share/artica-postfix/bin/setup-ubuntu --check-krb5');


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
  fpsystem('/etc/init.d/artica-postfix stop samba --force');
  xinstall_REMOVE_SAMBA();
  fpsystem('/bin/cp -rfd '+source_folder+'* /');
  install.INSTALL_STATUS(CODE_NAME,100);
  install.INSTALL_PROGRESS(CODE_NAME,'{success}');
  libs.NOTIFICATION('Success install Samba','Artica make has successfully installed Samba','system');
  fpsystem('/etc/init.d/artica-postfix restart samba');
  fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.samba.init.php');


end;
 //##############################################################################
procedure install_samba.xinstall_REMOVE_SAMBA();
var l:Tstringlist;
i:integer;
begin
        l:=Tstringlist.Create;
	l.add('/usr/sbin/smbd');
	l.add('/usr/sbin/nmbd');
	l.add('/usr/sbin/swat');
	l.add('/usr/sbin/winbindd');
	l.add('/usr/sbin/msktutil');
	l.add('/usr/bin/wbinfo');
	l.add('/usr/bin/smbclient');
	l.add('/usr/bin/net');
	l.add('/usr/bin/smbspool');
	l.add('/usr/bin/testparm');
	l.add('/usr/bin/smbstatus');
	l.add('/usr/bin/smbget');
	l.add('/usr/bin/smbta-util');
	l.add('/usr/bin/smbcontrol');
	l.add('/usr/bin/smbtree');
	l.add('/usr/bin/tdbbackup');
	l.add('/usr/bin/nmblookup');
	l.add('/usr/bin/pdbedit');
	l.add('/usr/bin/tdbdump');
	l.add('/usr/bin/tdbrestore');
	l.add('/usr/bin/tdbtool');
	l.add('/usr/bin/smbpasswd');
	l.add('/usr/bin/rpcclient');
	l.add('/usr/bin/smbcacls');
	l.add('/usr/bin/profiles');
	l.add('/usr/bin/ntlm_auth');
	l.add('/usr/bin/sharesec');
	l.add('/usr/bin/smbcquotas');
	l.add('/usr/bin/eventlogadm');
	l.add('/usr/lib/samba/lowcase.dat');
	l.add('/usr/lib/samba/upcase.dat');
	l.add('/usr/lib/samba/valid.dat');
	l.add('/usr/lib/samba/vfs/recycle.so');
	l.add('/usr/lib/samba/vfs/audit.so');
	l.add('/usr/lib/samba/vfs/extd_audit.so');
	l.add('/usr/lib/samba/vfs/full_audit.so');
	l.add('/usr/lib/samba/vfs/netatalk.so');
	l.add('/usr/lib/samba/vfs/fake_perms.so');
	l.add('/usr/lib/samba/vfs/default_quota.so');
	l.add('/usr/lib/samba/vfs/readonly.so');
	l.add('/usr/lib/samba/vfs/cap.so');
	l.add('/usr/lib/samba/vfs/expand_msdfs.so');
	l.add('/usr/lib/samba/vfs/shadow_copy.so');
	l.add('/usr/lib/samba/vfs/shadow_copy2.so');
	l.add('/usr/lib/samba/vfs/xattr_tdb.so');
	l.add('/usr/lib/samba/vfs/catia.so');
	l.add('/usr/lib/samba/vfs/streams_xattr.so');
	l.add('/usr/lib/samba/vfs/streams_depot.so');
	l.add('/usr/lib/samba/vfs/readahead.so');
	l.add('/usr/lib/samba/vfs/fileid.so');
	l.add('/usr/lib/samba/vfs/preopen.so');
	l.add('/usr/lib/samba/vfs/syncops.so');
	l.add('/usr/lib/samba/vfs/acl_xattr.so');
	l.add('/usr/lib/samba/vfs/acl_tdb.so');
	l.add('/usr/lib/samba/vfs/smb_traffic_analyzer.so');
	l.add('/usr/lib/samba/vfs/dirsort.so');
	l.add('/usr/lib/samba/vfs/scannedonly.so');
	l.add('/usr/lib/samba/vfs/crossrename.so');
	l.add('/usr/lib/samba/vfs/linux_xfs_sgid.so');
	l.add('/usr/lib/samba/vfs/time_audit.so');
	l.add('/usr/lib/samba/idmap/rid.so');
	l.add('/usr/lib/samba/idmap/autorid.so');
	l.add('/usr/lib/samba/idmap/ad.so');
	l.add('/usr/lib/samba/charset/CP850.so');
	l.add('/usr/lib/samba/charset/CP437.so');
	l.add('/usr/lib/samba/auth/script.so');
	l.add('/usr/lib/samba/de.msg');
	l.add('/usr/lib/samba/en.msg');
	l.add('/usr/lib/samba/fi.msg');
	l.add('/usr/lib/samba/fr.msg');
	l.add('/usr/lib/samba/it.msg');
	l.add('/usr/lib/samba/ja.msg');
	l.add('/usr/lib/samba/nl.msg');
	l.add('/usr/lib/samba/pl.msg');
	l.add('/usr/lib/samba/ru.msg');
	l.add('/usr/lib/samba/tr.msg');
	l.add('/lib/security/pam_smbpass.so');
	l.add('/lib/security/pam_winbind.so');
	l.add('/usr/lib/libtalloc.so.2.0.5');
	l.add('/usr/lib/libtalloc.a');
	l.add('/usr/include/talloc.h');
	l.add('/usr/lib/libtdb.so.1.2.9');
	l.add('/usr/lib/libtdb.a');
	l.add('/usr/include/tdb.h');
	l.add('/usr/lib/libwbclient.so.0');
	l.add('/usr/lib/libwbclient.a');
	l.add('/usr/include/wbclient.h');
	l.add('/usr/lib/libnetapi.so.0');
	l.add('/usr/lib/libnetapi.a');
	l.add('/usr/include/netapi.h');
	l.add('/usr/lib/libsmbclient.so.0');
	l.add('/usr/lib/libsmbclient.a');
	l.add('/usr/include/libsmbclient.h');
	l.add('/usr/lib/libsmbsharemodes.so.0');
	l.add('/usr/lib/libsmbsharemodes.a');
	l.add('/usr/include/smb_share_modes.h');
	l.add('/usr/share/locale/de/LC_MESSAGES/net.mo');
	l.add('/usr/share/locale/ar/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/cs/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/da/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/de/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/es/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/fi/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/fr/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/hu/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/it/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/ja/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/ko/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/nb/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/nl/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/pl/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/pt_BR/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/ru/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/sv/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/zh_CN/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/share/locale/zh_TW/LC_MESSAGES/pam_winbind.mo');
	l.add('/usr/lib/libnetapi.a');
	l.add('/usr/lib/libnetapi.so.0');
	l.add('/usr/lib/libsmbclient.a');
	l.add('/usr/lib/libsmbclient.so.0');
	l.add('/usr/lib/libsmbsharemodes.a');
	l.add('/usr/lib/libsmbsharemodes.so.0');
	l.add('/usr/lib/libtalloc.a');
	l.add('/usr/lib/libtalloc.so.2.0.5');
	l.add('/usr/lib/libtalloc.so.2');
	l.add('/usr/lib/libtdb.a');
	l.add('/usr/lib/libtdb.so.1.2.9');
	l.add('/usr/lib/libwbclient.so.0');
        for i:=0 to l.Count-1 do begin
           if FileExists(l.Strings[i]) then begin
              writeln('Removing ', l.Strings[i]);
              fpsystem('/bin/rm '+l.Strings[i]);
           end;
        end;




end;
//##############################################################################
procedure install_samba.xinstall(sourceString:string);
var
   CODE_NAME:string;
   cmd:string;
   zdate:string;
   smbsources:string;
   l:Tstringlist;
   i:integer;
   LOCAL_VERSION,LOCAL_VERSION_SOURCE,REMOTE_VERSION,REMOTE_VERSION_SOURCE:string;
   LOCAL_VERSION_INT,REMOTE_VERSION_INT:integer;
   cpbin:string;
begin
  if length(sourceString)=0 then sourceString:='samba';
  distri:=tdistriDetect.Create;
  Arch:=libs.ArchStruct();
  cpbin:=SYS.LOCATE_GENERIC_BIN('cp');
  writeln('RESULT.................: Source       : ',sourceString);
  writeln('RESULT.................: Architecture : ',Arch);
  writeln('RESULT.................: Distribution : ',distri.DISTRINAME,' (DISTRINAME)');
  writeln('RESULT.................: Major version: ',distri.DISTRI_MAJOR,' (DISTRI_MAJOR)');
  writeln('RESULT.................: Artica Code  : ',distri.DISTRINAME_CODE,' (DISTRINAME_CODE)');
  writeln('RESULT.................: cp binary    : ',cpbin);
  if distri.DISTRINAME_CODE='DEBIAN' then begin
       if distri.DISTRI_MAJOR>5 then begin
          if sourceString='samba' then begin
             xinstall_precompiled();
             exit;
          end;
       end;
  end;

         fpsystem('/usr/share/artica-postfix/bin/setup-ubuntu --check-base-system');
         fpsystem('/usr/share/artica-postfix/bin/setup-ubuntu --check-samba');

    if FileExists('/etc/artica-postfix/samba-install.lock') then begin
         writeln('For unlock, please remove the /etc/artica-postfix/samba-install.lock file');
         install.INSTALL_PROGRESS(CODE_NAME,'Already running');
         install.INSTALL_STATUS(CODE_NAME,100);
         exit;
    end;

    CODE_NAME:='APP_SAMBA';
    if sourceString='samba36' then CODE_NAME:='APP_SAMBA36';
    if sourceString='samba35' then CODE_NAME:='APP_SAMBA35';
    SetCurrentDir('/root');
    install.INSTALL_STATUS(CODE_NAME,10);
    if sourceString='samba' then begin
    REMOTE_VERSION:=libs.COMPILE_VERSION_STRING(sourceString);
    REMOTE_VERSION_SOURCE:=REMOTE_VERSION;

    LOCAL_VERSION:=SAMBA_VERSION();
    LOCAL_VERSION_SOURCE:=LOCAL_VERSION;
    writeln('Install local version: ',LOCAL_VERSION,' remote version: ',REMOTE_VERSION);

if FileExists('/usr/sbin/scannedonlyd_clamav') then begin
    if LOCAL_VERSION=REMOTE_VERSION then begin
           writeln('No upgrade needed...');
           install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
           install.INSTALL_STATUS(CODE_NAME,100);
           exit;
    end;

    LOCAL_VERSION:=AnsiReplaceText(LOCAL_VERSION,'.','');
    REMOTE_VERSION:=AnsiReplaceText(REMOTE_VERSION,'.','');

    if not TryStrToInt(LOCAL_VERSION,LOCAL_VERSION_INT) then begin
       writeln('There is a problem to understand version string ',LOCAL_VERSION);
       install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
       install.INSTALL_STATUS(CODE_NAME,110);
    end;

    if not TryStrToInt(REMOTE_VERSION,REMOTE_VERSION_INT) then begin
       writeln('There is a problem to understand version string ',REMOTE_VERSION);
       install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
       install.INSTALL_STATUS(CODE_NAME,110);
    end;


    if LOCAL_VERSION_INT>REMOTE_VERSION_INT then begin
           writeln('No upgrade needed...');
           install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
           install.INSTALL_STATUS(CODE_NAME,100);
           exit;
    end;

    if LOCAL_VERSION_INT=REMOTE_VERSION_INT then begin
           writeln('No upgrade needed...');
           install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
           install.INSTALL_STATUS(CODE_NAME,100);
           exit;
    end;
end;

  if not talloc() then begin
     writeln('Install talloc failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;

  libtdb();

end;
  SetCurrentDir('/root');
  uninstall();

  install.INSTALL_STATUS(CODE_NAME,30);
  install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
  install.INSTALL_STATUS(CODE_NAME,35);
  if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS(sourceString);



  if not DirectoryExists(source_folder) then begin
     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;


   fpsystem('/bin/touch /etc/artica-postfix/samba-install.lock');
   if length(REMOTE_VERSION_SOURCE)=0 then REMOTE_VERSION_SOURCE:=sourceString;
   smbsources:='/usr/local/share/artica/samba/samba-'+REMOTE_VERSION_SOURCE;


   writeln('Install '+CODE_NAME+' extracted on "'+source_folder+'"');
   if DirectoryExists(smbsources) then begin
       writeln('Install '+CODE_NAME+' removing old sources');
       fpsystem('/bin/rm -rf '+smbsources);
   end;

   forceDirectories(smbsources);
   writeln('copy source files in  '+smbsources);
   fpsystem(cpbin+' -rf '+source_folder+'/* '+smbsources+'/');
   writeln('copy source files in  '+smbsources +' done');
  install.INSTALL_STATUS(CODE_NAME,50);
  install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');

  if DirectoryExists(smbsources+'/source3') then SetCurrentDir(smbsources+'/source3');
  if DirectoryExists(smbsources+'/source') then SetCurrentDir(smbsources+'/source');

  writeln('using source files in  '+GetCurrentDir());


 fpsystem('./autogen.sh');

cmd:='./configure';
cmd:=cmd+' --with-fhs';
cmd:=cmd+' --enable-shared';
cmd:=cmd+' --enable-static';
cmd:=cmd+' --disable-pie';
cmd:=cmd+' --prefix=/usr';
cmd:=cmd+' --sysconfdir=/etc';
cmd:=cmd+' --libdir=/usr/lib';
cmd:=cmd+' --with-privatedir=/etc/samba';
cmd:=cmd+' --with-piddir=/var/run/samba';
cmd:=cmd+' --localstatedir=/var';
cmd:=cmd+' --with-rootsbindir=/sbin';
cmd:=cmd+' --with-pammodulesdir=/lib/security';
cmd:=cmd+' --with-pam';
cmd:=cmd+' --with-syslog';
cmd:=cmd+' --with-utmp';
cmd:=cmd+' --with-readline';
cmd:=cmd+' --with-pam_smbpass';
cmd:=cmd+' --with-libsmbclient';
cmd:=cmd+' --with-winbind';
if FileExists('/usr/include/ctdb.h') then begin
   writeln('Include cluster support in Samba');
   cmd:=cmd+' --with-cluster-support';
end;
cmd:=cmd+' --with-shared-modules=idmap_rid,idmap_ad';
cmd:=cmd+' --with-automount';
cmd:=cmd+' --with-ldap';
cmd:=cmd+' --with-ads';
cmd:=cmd+' --with-dnsupdate';
cmd:=cmd+' --with-smbmount';
cmd:=cmd+' --with-cifsmount';
cmd:=cmd+' --with-acl-support';
cmd:=cmd+' --with-dnsupdate';
cmd:=cmd+' --with-quotas';
cmd:=cmd+' --with-automount';

  writeln(cmd);
  fpsystem(cmd);

  install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
  install.INSTALL_STATUS(CODE_NAME,50);
  fpsystem('make');
    install.INSTALL_STATUS(CODE_NAME,80);
   fpsystem('make install');
 install.INSTALL_STATUS(CODE_NAME,90);
  fpsystem('/bin/rm -f /etc/artica-postfix/versions.cache');
  SetCurrentDir('/root');

  if FileExists(SYS.LOCATE_GENERIC_BIN('smbd')) then begin
     LOCAL_VERSION:=SAMBA_VERSION();
     writeln('New local version: '+LOCAL_VERSION);

     if FileExists(smbsources+'/nsswitch/libnss_winbind.so') then begin
          writeln('Installing '+smbsources+'/nsswitch/libnss_winbind.so to /lib');
          fpsystem(cpbin+' -f '+smbsources+'/nsswitch/libnss_winbind.so /lib/libnss_winbind.so');

     end else begin
           writeln(smbsources+'/nsswitch/libnss_winbind.so no such file !!!');
     end;

     if FileExists(smbsources+'/nsswitch/libnss_wins.so') then begin
          writeln('Installing '+smbsources+'/nsswitch/libnss_wins.so to /lib');
          fpsystem(cpbin+' -f '+smbsources+'/nsswitch/libnss_wins.so /lib/libnss_wins.so');
     end else begin
           writeln(smbsources+'/nsswitch/libnss_wins.so no such file !!!');
     end;

     install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
     install.INSTALL_STATUS(CODE_NAME,100);
     fpsystem('/bin/rm /etc/artica-postfix/samba-install.lock');
     if FileExists('/etc/artica-postfix/KASPERSKY_WEB_APPLIANCE') then SYS.THREAD_COMMAND_SET('/usr/share/artica-postfix/bin/artica-make APP_SQUID');
     fpsystem('/usr/share/artica-postfix/bin/process1 --force');
     if FIleExists('/usr/lib/libtalloc.so.1.3.0') then begin
      writeln('Install linking /usr/lib/libtalloc.so.1.3.0 to /usr/lib/libtalloc.so.1');
      fpsystem('/bin/ln -s /usr/lib/libtalloc.so.1.3.0 /usr/lib/libtalloc.so.1');
    end;
     if not  FileExists('/etc/artica-postfix/KASPERSKY_WEB_APPLIANCE') then begin
        SYS.THREAD_COMMAND_SET('/usr/share/artica-postfix/bin/artica-make APP_GREYHOLE');
        SYS.THREAD_COMMAND_SET('/usr/share/artica-postfix/bin/artica-make APP_SCANNED_ONLY');
     end;
     exit;
  end;

  if FIleExists('/usr/lib/libtalloc.so.1.3.0') then begin
     writeln('Install linking /usr/lib/libtalloc.so.1.3.0 to /usr/lib/libtalloc.so.1');
     fpsystem('/bin/ln -s /usr/lib/libtalloc.so.1.3.0 /usr/lib/libtalloc.so.1');
  end;

     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     fpsystem('/bin/rm /etc/artica-postfix/samba-install.lock');
     exit;



end;
//#########################################################################################
function install_samba.SMBD_PATH():string;
begin
 if FileExists('/usr/sbin/smbd') then exit('/usr/sbin/smbd');
end;
//##############################################################################
function install_samba.SAMBA_VERSION():string;
var
   RegExpr:TRegExpr;
   x:string;
begin

fpsystem(SMBD_PATH() + ' -V >/tmp/samba.version');
x:=libs.ReadFromFile('/tmp/samba.version');
RegExpr:=TRegExpr.Create;
RegExpr.Expression:='Version\s+([0-9a-z\.]+)';
if RegExpr.Exec(x) then result:=trim(RegExpr.Match[1]);
end;
//##############################################################################
function install_samba.SAMBA_LIBDIR():string;
var
   RegExpr:TRegExpr;
   x:TstringList;
   i:Integer;
begin

fpsystem(SMBD_PATH() + ' -b >/tmp/samba.infos 2>&1');
x:=Tstringlist.Create;
x.LoadFromFile('/tmp/samba.infos');
RegExpr:=TRegExpr.Create;
RegExpr.Expression:='LIBDIR:\s+(.+)';
for i:=0 to x.Count-1 do begin
     if RegExpr.Exec(x.Strings[i]) then begin
        result:=trim(RegExpr.Match[1]);
        break;
     end;

end;
x.free;
RegExpr.free;
end;
//##############################################################################
procedure install_samba.ctdb();
var
CODE_NAME:string;
begin
     popt();
    CODE_NAME:='APP_SAMBA';
    SetCurrentDir('/root');
    install.INSTALL_STATUS(CODE_NAME,15);

     if not FileExists('/usr/include/popt.h') then begin
        writeln('FATAL: /usr/include/popt.h, no such file');
        writeln('FATAL: ctdb will not be compiled in order to provide cluster configuration');
        exit;
     end;

    source_folder:=libs.COMPILE_GENERIC_APPS('ctdb');
    if Not FileExists(source_folder+'/autogen.sh') then begin
         writeln('FATAL: ',source_folder+'/autogen.sh no such file !!!!');
         exit;
    end;
 SetCurrentDir(source_folder);
 writeln('using source dir',source_folder);
 fpsystem('./autogen.sh');
 fpsystem('./configure --prefix=/usr --localstatedir=/var/lib --with-logdir=/var/log/ctdb --sysconfdir=/etc');
 install.INSTALL_STATUS(CODE_NAME,16);
 fpsystem('make');
 install.INSTALL_STATUS(CODE_NAME,17);
 fpsystem('make install');
 fpsystem('/bin/rm -rf '+source_folder);
 SetCurrentDir('/root');
end;
//##############################################################################
procedure install_samba.popt();
var
CODE_NAME:string;
begin
    CODE_NAME:='APP_SAMBA';
    SetCurrentDir('/root');
    install.INSTALL_STATUS(CODE_NAME,12);
    source_folder:=libs.COMPILE_GENERIC_APPS('popt');
    if Not FileExists(source_folder+'/configure') then begin
         writeln('FATAL: ',source_folder+'/configure no such file !!!!');
         exit;
    end;
 SetCurrentDir(source_folder);
 writeln('using source dir',source_folder);
 fpsystem('./configure --prefix=/usr --localstatedir=/var/lib --with-logdir=/var/log/popt --sysconfdir=/etc');
 install.INSTALL_STATUS(CODE_NAME,13);
 fpsystem('make');
 install.INSTALL_STATUS(CODE_NAME,14);
 fpsystem('make install');
 fpsystem('/bin/rm -rf '+source_folder);
 SetCurrentDir('/root');
end;
//##############################################################################
function install_samba.talloc():boolean;
var
   l:Tstringlist;
   i:integer;
   sexport:string;
begin

  sexport:='LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/lib64"';
  sexport:=sexport+' LDFLAGS="-L/lib -L/usr/local/lib -L/usr/lib/libmilter -L/usr/lib"';
  sexport:=sexport+' CPPFLAGS="-I/usr/include/ -I/usr/local/include -I/usr/include/libpng12 -I/usr/include/sasl"';
  sexport:=sexport+' PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11';
 result:=false;

 l:=Tstringlist.Create;
 l.Add('libtalloc.a');
 l.Add('libtalloc.so');
 l.add('libtalloc.so.1');
 l.add('libtalloc.so.1.2.0');
 for i:=0 to l.Count-1 do begin
     if FIleExists('/usr/lib/'+ l.Strings[i]) then begin
        writeln('removing /usr/lib/'+ l.Strings[i]);
        fpsystem('/bin/rm -f /usr/lib/'+ l.Strings[i]);

     end;

     if FileExists('/etc/samba/'+ l.Strings[i]) then begin
        writeln('removing /etc/samba/'+ l.Strings[i]);
        fpsystem('/bin/rm -f /etc/samba/'+ l.Strings[i]);
     end;
 end;
 source_folder:=libs.COMPILE_GENERIC_APPS('talloc');
 if not DirectoryExists(source_folder) then begin
     writeln('Install talloc failed !!!...');
     source_folder:='';
     exit;
 end;
 SetCurrentDir(source_folder);
 writeln('./configure --prefix=/usr '+sexport);
 fpsystem('./configure --prefix=/usr '+sexport);
 fpsystem('make && make install');
 if FileExists('/usr/lib/libtalloc.so.1.3.0') then begin
    SetCurrentDir('/root');
    writeln('libtalloc 1.3 ok');
    source_folder:='';
    exit(true);
 end;

 if FileExists('/usr/lib/libtalloc.so.2') then begin
    SetCurrentDir('/root');
    writeln('libtalloc.so.2 ok');
    source_folder:='';
    exit(true);
 end;
 source_folder:='';

end;
function install_samba.libtdb():boolean;
var
   l:Tstringlist;
   i:integer;
   sexport:string;
begin

  sexport:='LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/lib64"';
  sexport:=sexport+' LDFLAGS="-L/lib -L/usr/local/lib -L/usr/lib/libmilter -L/usr/lib"';
  sexport:=sexport+' CPPFLAGS="-I/usr/include/ -I/usr/local/include -I/usr/include/libpng12 -I/usr/include/sasl"';
  sexport:=sexport+' PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11';
 result:=false;

 l:=Tstringlist.Create;
 source_folder:=libs.COMPILE_GENERIC_APPS('tdb');
 if not DirectoryExists(source_folder) then begin
     writeln('Install talloc failed !!!...');
     source_folder:='';
     exit;
 end;
 SetCurrentDir(source_folder);
 writeln('./configure --prefix=/usr '+sexport);
 fpsystem('./configure --prefix=/usr '+sexport);
 fpsystem('make && make install');
 source_folder:='';

end;

procedure install_samba.uninstall();
var
   l:Tstringlist;
   i:integer;
begin
exit;
l:=Tstringlist.Create;

l.add('/etc/samba/gdbcommands');
l.add('/etc/samba/samba/ja.msg');
l.add('/etc/samba/samba/upcase.dat');
l.add('/etc/samba/samba/tr.msg');
l.add('/etc/samba/samba/idmap/rid.so');
l.add('/etc/samba/samba/idmap/ad.so.old');
l.add('/etc/samba/samba/idmap/ad.so');
l.add('/etc/samba/samba/idmap/rid.so.old');
l.add('/etc/samba/samba/auth/script.so.old');
l.add('/etc/samba/samba/auth/script.so');
l.add('/etc/samba/samba/charset/CP437.so.old');
l.add('/etc/samba/samba/charset/CP850.so.old');
l.add('/etc/samba/samba/charset/CP850.so');
l.add('/etc/samba/samba/charset/CP437.so');
l.add('/etc/samba/samba/en.msg');
l.add('/etc/samba/samba/vfs/netatalk.so.old');
l.add('/etc/samba/samba/vfs/syncops.so.old');
l.add('/etc/samba/samba/vfs/default_quota.so');
l.add('/etc/samba/samba/vfs/default_quota.so.old');
l.add('/etc/samba/samba/vfs/readahead.so.old');
l.add('/etc/samba/samba/vfs/shadow_copy.so.old');
l.add('/etc/samba/samba/vfs/fileid.so.old');
l.add('/etc/samba/samba/vfs/extd_audit.so.old');
l.add('/etc/samba/samba/vfs/netatalk.so');
l.add('/etc/samba/samba/vfs/shadow_copy2.so');
l.add('/etc/samba/samba/vfs/streams_depot.so.old');
l.add('/etc/samba/samba/vfs/shadow_copy2.so.old');
l.add('/etc/samba/samba/vfs/smb_traffic_analyzer.so.old');
l.add('/etc/samba/samba/vfs/recycle.so.old');
l.add('/etc/samba/samba/vfs/readonly.so');
l.add('/etc/samba/samba/vfs/readonly.so.old');
l.add('/etc/samba/samba/vfs/dirsort.so.old');
l.add('/etc/samba/samba/vfs/full_audit.so');
l.add('/etc/samba/samba/vfs/streams_xattr.so');
l.add('/etc/samba/samba/vfs/acl_xattr.so.old');
l.add('/etc/samba/samba/vfs/cap.so.old');
l.add('/etc/samba/samba/vfs/readahead.so');
l.add('/etc/samba/samba/vfs/streams_xattr.so.old');
l.add('/etc/samba/samba/vfs/preopen.so');
l.add('/etc/samba/samba/vfs/expand_msdfs.so');
l.add('/etc/samba/samba/vfs/acl_tdb.so.old');
l.add('/etc/samba/samba/vfs/xattr_tdb.so.old');
l.add('/etc/samba/samba/vfs/preopen.so.old');
l.add('/etc/samba/samba/vfs/acl_tdb.so');
l.add('/etc/samba/samba/vfs/smb_traffic_analyzer.so');
l.add('/etc/samba/samba/vfs/shadow_copy.so');
l.add('/etc/samba/samba/vfs/acl_xattr.so');
l.add('/etc/samba/samba/vfs/audit.so.old');
l.add('/etc/samba/samba/vfs/audit.so');
l.add('/etc/samba/samba/vfs/streams_depot.so');
l.add('/etc/samba/samba/vfs/dirsort.so');
l.add('/etc/samba/samba/vfs/fake_perms.so');
l.add('/etc/samba/samba/vfs/full_audit.so.old');
l.add('/etc/samba/samba/vfs/fake_perms.so.old');
l.add('/etc/samba/samba/vfs/syncops.so');
l.add('/etc/samba/samba/vfs/expand_msdfs.so.old');
l.add('/etc/samba/samba/vfs/fileid.so');
l.add('/etc/samba/samba/vfs/extd_audit.so');
l.add('/etc/samba/samba/vfs/cap.so');
l.add('/etc/samba/samba/vfs/xattr_tdb.so');
l.add('/etc/samba/samba/vfs/recycle.so');
l.add('/etc/samba/samba/nss_info/rfc2307.so');
l.add('/etc/samba/samba/nss_info/sfu.so');
l.add('/etc/samba/samba/nss_info/sfu20.so');
l.add('/etc/samba/samba/fr.msg');
l.add('/etc/samba/samba/lowcase.dat');
l.add('/etc/samba/samba/ru.msg');
l.add('/etc/samba/samba/fi.msg');
l.add('/etc/samba/samba/it.msg');
l.add('/etc/samba/samba/valid.dat');
l.add('/etc/samba/samba/de.msg');
l.add('/etc/samba/samba/pl.msg');
l.add('/etc/samba/samba/nl.msg');
l.add('/etc/samba/libwbclient.so');
l.add('/etc/samba/libnetapi.so.0');
l.add('/etc/samba/libsmbsharemodes.so');
l.add('/etc/samba/libsmbclient.a');
l.add('/etc/samba/libnetapi.a');
l.add('/etc/samba/libsmbsharemodes.so.0');
l.add('/etc/samba/pkgconfig/talloc.pc');
l.add('/etc/samba/libnetapi.so');
l.add('/etc/samba/smb.conf.ucf-dist');
l.add('/etc/samba/libtalloc.so.1.3.0');
l.add('/etc/samba/libtdb.so');
l.add('/etc/samba/libsmbsharemodes.a');
l.add('/etc/samba/libtdb.so.1');
l.add('/etc/samba/libsmbclient.so');
if DirectoryExists('/usr/lib/samba') then fpsystem('/bin/rm -rf /usr/lib/samba');

 for i:=0 to l.Count-1 do begin
     if FIleExists(l.Strings[i]) then begin
        writeln('removing '+ l.Strings[i]);
        fpsystem('/bin/rm -f '+ l.Strings[i]);
     end;
 end;

end;
//##############################################################################
procedure install_samba.greyhole();
var
   CODE_NAME:string;
   MAJOR:integer;
   MINOR:integer;
   cmd:string;
   zdate:string;
   smbsources:string;
   l:Tstringlist;
   i:integer;
   Arch:integer;
   LOCAL_VERSION,LIBDIR,REMOTE_VERSION,REMOTE_VERSION_SOURCE:string;
   LOCAL_VERSION_INT,REMOTE_VERSION_INT:integer;
   RegExpr:TRegExpr;
   greyhole_lib:string;
begin
  CODE_NAME:='APP_GREYHOLE';
  MAJOR:=0;
  MINOR:=0;
  SetCurrentDir('/root');
  install.INSTALL_STATUS(CODE_NAME,10);
  LOCAL_VERSION:=SAMBA_VERSION();
  RegExpr:=TRegExpr.Create;
  RegExpr.Expression:='^([0-9]+)\.([0-9])';
  RegExpr.Exec(LOCAL_VERSION);
  TryStrToInt(RegExpr.Match[1],MAJOR);
  TryStrToInt(RegExpr.Match[2],MINOR);
  Arch:=libs.ArchStruct();


  writeln('Samba version Major: ',MAJOR,' minor:',MINOR);

  if MAJOR<3 then begin
     writeln('Samba version < 3.4 is depreciated, you should upgrade to the lastest samba version.');
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;

  if MINOR<4 then begin
     writeln('Samba version < 3.4 is depreciated, you should upgrade to the lastest samba version.');
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;


 if MAJOR>5 then begin
      writeln('Samba version > 3.5 you should contact Artica support team.');
     install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;

   LIBDIR:=vfsDir(SAMBA_LIBDIR());
     writeln('Samba environment..........: Version Major.: ',MAJOR,'.',MINOR);
     writeln('Samba environment..........: Version LIBDIR: ',LIBDIR);
     writeln('Samba environment..........: Architecture..: ',Arch);


 if not DirectoryExists(LIBDIR) then begin
         writeln('unable to stat vfs dir',LIBDIR);
         install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
         install.INSTALL_STATUS(CODE_NAME,110);
         exit;
 end;

source_folder:=libs.COMPILE_GENERIC_APPS('greyhole');
writeln('using source dir',source_folder);


  if not DirectoryExists(source_folder) then begin
     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;

  if MINOR=4 then begin
     if Arch=32 then  greyhole_lib:='/samba-module/bin/greyhole-i386.so';
     if Arch=64 then  greyhole_lib:='/samba-module/bin/greyhole-x86_64.so';
  end;

  if MINOR=5 then begin
     if Arch=32 then  greyhole_lib:='/samba-module/bin/3.5/greyhole-i386.so';
     if Arch=64 then  greyhole_lib:='/samba-module/bin/3.5/greyhole-x86_64.so';
  end;
  writeln('Installing pre-compiled library:',greyhole_lib );

  if not FileExists(source_folder+greyhole_lib) then begin
    writeln('unable to stat :',source_folder+greyhole_lib);
    install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
    install.INSTALL_STATUS(CODE_NAME,110);
    exit;
  end;

install.INSTALL_STATUS(CODE_NAME,50);
install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');
SetCurrentDir(source_folder);
fpsystem('/bin/cp '+source_folder+greyhole_lib+' '+LIBDIR+'/greyhole.so');

if not FileExists(LIBDIR+'/greyhole.so') then begin
     writeln('unable to stat :',LIBDIR+'/greyhole.so');
    install.INSTALL_PROGRESS(CODE_NAME,'{failed}');
    install.INSTALL_STATUS(CODE_NAME,110);
end;
install.INSTALL_STATUS(CODE_NAME,90);
install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
forceDirectories('/etc/greyhole');
fpsystem('/bin/cp '+source_folder+'/schema-mysql.sql /etc/greyhole/schema-mysql.sql');
fpsystem('/bin/cp '+source_folder+'/greyhole.example.conf /etc/greyhole/greyhole.example.conf');
fpsystem('/bin/cp '+source_folder+'/greyhole /usr/bin/greyhole');
fpsystem('/bin/cp '+source_folder+'/greyhole-dfree /usr/bin/greyhole-dfree');
fpsystem('/bin/cp '+source_folder+'/greyhole-config-update /usr/bin/greyhole-config-update');
fpsystem('/bin/chmod 755 /usr/bin/greyhole');
fpsystem('/bin/chmod 755 /usr/bin/greyhole-dfree');
fpsystem('/bin/chmod 755 /usr/bin/greyhole-config-update');
fpsystem('/ect/init.d/artica-postfix restart greyhole');
install.INSTALL_STATUS(CODE_NAME,100);
install.INSTALL_PROGRESS(CODE_NAME,'{installed}');


end;



end.
