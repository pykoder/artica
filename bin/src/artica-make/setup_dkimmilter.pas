unit setup_dkimmilter;
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
  install_dkimmilter=class


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
   SYS:Tsystem;



public
      constructor Create();
      procedure Free;
      procedure xinstall();

END;

implementation

constructor install_dkimmilter.Create();
begin
libs:=tlibs.Create;
install:=tinstall.Create;
source_folder:='';
SYS:=Tsystem.Create();
if DirectoryExists(ParamStr(2)) then source_folder:=ParamStr(2);
end;
//#########################################################################################
procedure install_dkimmilter.Free();
begin
  libs.Free;

end;

//#########################################################################################
procedure install_dkimmilter.xinstall();
var
   CODE_NAME:string;
   cmd:string;
   zdate:string;
   smbsources:string;
   l:Tstringlist;
   i:integer;
   CC:string;
   configurelcc:string;
begin

    CODE_NAME:='APP_MILTER_DKIM';
    SetCurrentDir('/root');
    install.INSTALL_STATUS(CODE_NAME,10);
    install.INSTALL_STATUS(CODE_NAME,30);
    install.INSTALL_PROGRESS(CODE_NAME,'{downloading}');
    install.INSTALL_STATUS(CODE_NAME,40);
    if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('dkim-milter');
    if not FileExists('/usr/lib/libmilter.so') then begin
          if FileExists('/usr/lib/libmilter/libmilter.so') then begin
              fpsystem('/bin/ln -s /usr/lib/libmilter/libmilter.so /usr/lib/libmilter.so');
          end;
    end;


  if not DirectoryExists(source_folder) then begin
     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;
  end;



   zdate:=FormatDateTime('yyyy-mm-dd-hh', Now);
   smbsources:='/root/'+CODE_NAME+'-sources-'+zdate;
   writeln('Install '+CODE_NAME+' extracted on "'+source_folder+'"');
   if DirectoryExists(smbsources) then begin
       writeln('Install '+CODE_NAME+' removing old sources');
       fpsystem('/bin/rm -rf '+smbsources);
   end;

   forceDirectories(smbsources);
   writeln('copy source files in  '+smbsources);
   fpsystem('/bin/cp -rf '+source_folder+'/* '+smbsources+'/');
   writeln('copy source files in  '+smbsources +' done');
  install.INSTALL_STATUS(CODE_NAME,50);
  install.INSTALL_PROGRESS(CODE_NAME,'{compiling}');
  SetCurrentDir(smbsources);



CC:=sys.LOCATE_GENERIC_BIN('gcc');
if not FileExists(CC) then begin
   writeln('Install '+CODE_NAME+' failed...');
   install.INSTALL_STATUS(CODE_NAME,110);
   writeln('unable to stat GCC');
   exit;
end;

       configurelcc:=' LD_LIBRARY_PATH="/lib:/usr/local/lib:/usr/lib/libmilter:/usr/lib" ';
       configurelcc:=configurelcc+'CPPFLAGS="-I/usr/include/libmilter -I/usr/include -I/usr/local/include -I/usr/include/sm/os" ';
       configurelcc:=configurelcc+'LDFLAGS="-L/lib -L/usr/local/lib -L/usr/lib/libmilter -L/usr/lib" ';
       configurelcc:=configurelcc+' CC='+CC;


 SetCurrentDir(smbsources);
 cmd:='./configure -prefix=/usr --includedir="\${prefix}/include" --mandir="\${prefix}/share/man" --infodir="\${prefix}/share/info" --sysconfdir=/etc --localstatedir=/var '+configurelcc;
 cmd:='./Build';
 writeln(cmd);
 fpsystem(cmd);

  install.INSTALL_PROGRESS(CODE_NAME,'{installing}');
  install.INSTALL_STATUS(CODE_NAME,80);
  ForceDirectories('/usr/man/man3');
  ForceDirectories('/usr/man/man5');
  ForceDirectories('/usr/man/man8');
  fpsystem('./Build install');
  fpsystem('/bin/rm -f /etc/artica-postfix/versions.cache');
  SetCurrentDir('/root');

  exit;

  if FileExists('/usr/sbin/dkim-filter') then begin
     install.INSTALL_PROGRESS(CODE_NAME,'{installed}');
     install.INSTALL_STATUS(CODE_NAME,100);
     SYS.set_INFO('EnableDkimMilter','1');
     if DirectoryExists(smbsources) then fpsystem('/bin/rm -rf '+smbsources);
     exit;
  end;



     writeln('Install '+CODE_NAME+' failed...');
     install.INSTALL_STATUS(CODE_NAME,110);
     exit;



end;
//#########################################################################################









end.
