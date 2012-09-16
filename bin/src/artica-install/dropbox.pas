unit dropbox;

{$MODE DELPHI}
{$LONGSTRINGS ON}

interface

uses
    Classes, SysUtils,variants,strutils,Process,logs,unix,RegExpr in 'RegExpr.pas',zsystem,IniFiles;



  type
  tdropbox=class


private
     LOGS:Tlogs;
     SYS:TSystem;
     artica_path:string;
     EnableDropBox:integer;
     binpath:string;
public
    procedure   Free;
    constructor Create(const zSYS:Tsystem);
    procedure   START();
    procedure   STOP();
    function    STATUS():string;
    function    VERSION():string;
    function    PID_NUM():string;



END;

implementation

constructor tdropbox.Create(const zSYS:Tsystem);
begin

       LOGS:=tlogs.Create();
       SYS:=zSYS;
       binpath:='/root/.dropbox-dist/dropbox';
       if not TryStrToInt(SYS.GET_INFO('EnableDropBox'),EnableDropBox) then EnableDropBox:=0;
end;
//##############################################################################
procedure tdropbox.free();
begin
    logs.Free;
end;
//##############################################################################

procedure tdropbox.STOP();
var
   count:integer;
   RegExpr:TRegExpr;
   cmd:string;
   pids:Tstringlist;
   pidstring:string;
   fpid,i:integer;
begin
if not FileExists(binpath) then begin
   writeln('Stopping dropbox service.....: Not installed');
   exit;
end;

if not SYS.PROCESS_EXIST(PID_NUM()) then begin
        writeln('Stopping dropbox service.....: already Stopped');
        exit;
end;
   pidstring:=PID_NUM();
   writeln('Stopping dropbox service.....: ' + pidstring + ' PID..');
   cmd:='/usr/share/artica-postfix/bin/install/dropbox/dropbox.py stop';
   fpsystem(cmd);

   count:=0;
   while SYS.PROCESS_EXIST(pidstring) do begin
        sleep(200);
        count:=count+1;
        if count>50 then begin
            if length(pidstring)>0 then begin
               if SYS.PROCESS_EXIST(pidstring) then begin
                  writeln('Stopping dropbox service.....: kill pid '+ pidstring+' after timeout');
                  fpsystem('/bin/kill -9 ' + pidstring);
               end;
            end;
            break;
        end;
        pidstring:=PID_NUM();
  end;

  if not SYS.PROCESS_EXIST(PID_NUM()) then writeln('Stopping dropbox service.....: Stopped');
end;

//##############################################################################
procedure tdropbox.START();
var
   count:integer;
   cmd:string;
   su,nohup:string;
   conf:TiniFile;
   enabled:integer;
   RegExpr:TRegExpr;
   servername:string;
   tmpfile:string;
   cmdline:string;
   mount_bin:string;
   DropBoxUri:string;
begin

   if not FileExists(binpath) then begin
         logs.DebugLogs('Starting......: dropbox daemon is not installed');
         exit;
   end;

if EnableDropBox=0 then begin
   logs.DebugLogs('Starting......:  dropbox daemon is disabled');
   STOP();
   exit;
end;

if SYS.PROCESS_EXIST(PID_NUM()) then begin
   logs.DebugLogs('Starting......:  dropbox Already running using PID ' +PID_NUM()+ '...');
   exit;
end;

   forceDirectories('/home/dropbox');
   forceDirectories('/root/Dropbox');


   fpsystem('/bin/chmod 755 /usr/share/artica-postfix/bin/install/dropbox/*');
   fpsystem('/bin/chmod 755 /home/dropbox');
   fpsystem('/bin/chmod 755 /root/Dropbox');
   mount_bin:=SYS.LOCATE_GENERIC_BIN('mount');
   if not SYS.isMountedTargetPath('/root/Dropbox') then begin
      fpsystem(mount_bin+' /home/dropbox /root/Dropbox --bind >/dev/null 2>&1');
   end;



   DropBoxUri:=trim(SYS.GET_INFO('DropBoxUri'));
   if length(DropBoxUri)=0 then begin
      SetCurrentDir('/root/.dropbox-dist');
      cmd:=SYS.LOCATE_GENERIC_BIN('nohup')+ ' ./dropboxd >/var/log/dropbox.log 2>&1 &';
   end else begin
   cmd:='/usr/share/artica-postfix/bin/install/dropbox/dropbox.py start';

   count:=0;
   end;
   fpsystem(cmd);
   while not SYS.PROCESS_EXIST(PID_NUM()) do begin
     sleep(300);
     inc(count);
     if count>50 then begin
       logs.DebugLogs('Starting......: dropbox (timeout!!!)');
       logs.DebugLogs('Starting......: dropbox "'+cmd+'"');
       break;
     end;
   end;

   if not SYS.PROCESS_EXIST(PID_NUM()) then begin
       logs.DebugLogs('Starting......: dropbox (failed!!!)');
       logs.DebugLogs('Starting......: dropbox "'+cmd+'"');
   end else begin
       logs.DebugLogs('Starting......: dropbox started with new PID '+PID_NUM());
   end;
   if length(DropBoxUri)=0 then begin
      fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.dropbox.php --uri');
   end;

end;
//##############################################################################
function tdropbox.STATUS():string;
var
pidpath:string;
mount_bin:string;
begin

   if not FileExists(binpath) then exit;
   pidpath:=logs.FILE_TEMP();
   fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.status.php --dropbox >'+pidpath +' 2>&1');
   result:=logs.ReadFromFile(pidpath);
   logs.DeleteFile(pidpath);

   if EnableDropBox=1 then begin
      mount_bin:=SYS.LOCATE_GENERIC_BIN('mount');
      if not SYS.isMountedTargetPath('/root/Dropbox') then begin
         forceDirectories('/home/dropbox');
         forceDirectories('/root/Dropbox');
         fpsystem('/bin/chmod 755 /home/dropbox');
         fpsystem('/bin/chmod 755 /root/Dropbox');
         fpsystem(mount_bin+' /home/dropbox /root/Dropbox --bind >/dev/null 2>&1');
      end;
   end;
end;
//#########################################################################################
 function tdropbox.PID_NUM():string;
begin
  result:=SYS.GET_PID_FROM_PATH('/root/.dropbox/dropbox.pid');
  if sys.verbosed then logs.Debuglogs(' ->'+result);
  if length(result)=0 then result:=SYS.PIDOF_PATTERN(binpath);
  if not SYS.PROCESS_EXIST(result) then result:=SYS.PIDOF_PATTERN(binpath);
end;
 //##############################################################################
 function tdropbox.VERSION():string;
var
   l:TstringList;
   i:integer;
   RegExpr:TRegExpr;
   tmpstr:string;
begin

    if length(binpath)=0 then exit;
    if Not Fileexists(binpath) then exit;
    result:=SYS.GET_CACHE_VERSION('APP_DROPBOX');
     if length(result)>2 then exit;
    result:=trim(logs.ReadFromFile('/root/.dropbox-dist/VERSION'));
    SYS.SET_CACHE_VERSION('APP_DROPBOX',result);
    l.free;
    RegExpr.free;
end;
//##############################################################################

end.
