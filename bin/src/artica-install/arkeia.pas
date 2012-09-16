unit arkeia;

{$MODE DELPHI}
{$LONGSTRINGS ON}

interface

uses
    Classes, SysUtils,variants,strutils,Process,logs,unix,RegExpr in 'RegExpr.pas',zsystem,IniFiles;



  type
  tarkeia=class


private
     LOGS:Tlogs;
     SYS:TSystem;
     artica_path:string;
     EnableArkeia:integer;
     binpath:string;
public
    procedure   Free;
    constructor Create(const zSYS:Tsystem);
    procedure   START();
    procedure   STOP();
    function    PID_NUM():string;
    function    BIN_PATH():string;
END;

implementation

constructor tarkeia.Create(const zSYS:Tsystem);
begin

       LOGS:=tlogs.Create();
       SYS:=zSYS;
       binpath:=BIN_PATH();
       if not TryStrToInt(SYS.GET_INFO('EnableArkeia'),EnableArkeia) then EnableArkeia:=0;

end;
//##############################################################################
procedure tarkeia.free();
begin
    logs.Free;
end;
//##############################################################################
procedure tarkeia.STOP();
var
   count:integer;
   RegExpr:TRegExpr;
   cmd:string;
   pids:Tstringlist;
   pidstring:string;
   fpid,i:integer;
begin
if not FileExists(binpath) then begin
   writeln('Stopping Arkeia Network Back.: Not installed');
   exit;
end;

if not SYS.PROCESS_EXIST(PID_NUM()) then begin
         writeln('Stopping Arkeia Network Back.: Already Stopped');
        exit;
end;
   pidstring:=PID_NUM();
   writeln('Stopping Arkeia Network Back.: ' + pidstring + ' PID..');
   fpsystem(binpath+' stop');


   pidstring:=PID_NUM();
   while SYS.PROCESS_EXIST(pidstring) do begin
        sleep(2000);
        count:=count+1;
        if count>50 then begin
            if length(pidstring)>0 then begin
               if SYS.PROCESS_EXIST(pidstring) then begin
                  writeln('Stopping Arkeia Network Back.: timeout');
                  break;
               end;
            end;
            break;
        end;
        pidstring:=PID_NUM();
  end;

  if not SYS.PROCESS_EXIST(PID_NUM()) then writeln('Stopping Arkeia Network Back.: Stopped');
end;

//##############################################################################
function tarkeia.BIN_PATH():string;
begin
result:='/opt/arkeia/bin/arkboot';
end;
 //##############################################################################
procedure tarkeia.START();
var
   count:integer;
   cmd:string;
   su,nohup:string;
   conf:TiniFile;
   enabled:integer;
   RegExpr:TRegExpr;
   servername:string;
   tmpfile:string;
   http_port:integer;
begin

   if not FileExists(binpath) then begin
         logs.DebugLogs('Starting......: Arkeia Network Backup not installed');
         exit;
   end;

if EnableArkeia=0 then begin
   logs.DebugLogs('Starting......: Arkeia Network Backup is disabled');
   STOP();
   exit;
end;

if SYS.PROCESS_EXIST(PID_NUM()) then begin
   logs.DebugLogs('Starting......:  Arkeia Network Backup running using PID ' +PID_NUM()+ '...');
   exit;
end;

   logs.DebugLogs('Starting......: Arkeia Network Backup building configuration...');
   fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.arkeia.php --build');

   logs.DebugLogs('Starting......: Arkeia Network Backup...');


   cmd:=binpath+' start';
   fpsystem(cmd);
   while not SYS.PROCESS_EXIST(PID_NUM()) do begin
     sleep(2000);
     inc(count);
     if count>50 then begin
       logs.DebugLogs('Starting......: Arkeia Network Backup (timeout!!!)');
       logs.DebugLogs('Starting......: Arkeia Network Backup "'+cmd+'"');
       break;
     end;
   end;

   if not SYS.PROCESS_EXIST(PID_NUM()) then begin
       logs.DebugLogs('Starting......: Arkeia Network Backup (failed!!!)');
   end else begin
       logs.DebugLogs('Starting......: Arkeia Network Backup started with new PID '+PID_NUM());
       fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.arkeia.php --default-storage');
   end;

end;

  //##############################################################################
 function tarkeia.PID_NUM():string;
begin
  result:=SYS.GET_PID_FROM_PATH('/opt/arkeia/arkeiad/arkeiad.pid');
  logs.Debuglogs(' ->'+result);
  if length(result)=0 then result:=SYS.PIDOF_PATTERN('/opt/arkeia/bin/arkeiad');
  if not SYS.PROCESS_EXIST(result) then result:=SYS.PIDOF_PATTERN('/opt/arkeia/bin/arkeiad');
end;
 //##############################################################################
end.
