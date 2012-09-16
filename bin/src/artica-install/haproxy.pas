unit haproxy;

{$MODE DELPHI}
{$LONGSTRINGS ON}

interface

uses
    Classes, SysUtils,variants,strutils,Process,logs,unix,RegExpr in 'RegExpr.pas',zsystem,IniFiles;



  type
  thaproxy=class


private
     LOGS:Tlogs;
     SYS:TSystem;
     artica_path:string;
     EnableHaProxy:integer;
     binpath:string;
     function PidfilesLines():string;
public
    procedure   Free;
    constructor Create(const zSYS:Tsystem);
    procedure   START();
    procedure   STOP();
    function    PID_NUM():string;
    function    BIN_PATH():string;
    function    PID_PATH():string;


END;

implementation

constructor thaproxy.Create(const zSYS:Tsystem);
begin

       LOGS:=tlogs.Create();
       SYS:=zSYS;
       binpath:=BIN_PATH();
       if not TryStrToInt(SYS.GET_INFO('EnableHaProxy'),EnableHaProxy) then EnableHaProxy:=1;

end;
//##############################################################################
procedure thaproxy.free();
begin
    logs.Free;
end;
//##############################################################################
function thaproxy.PidfilesLines();
var
   t:Tstringlist;
   i:integer;
begin
if Not FileExists('/var/run/haproxy.pid') then exit;
t:=Tstringlist.Create;
t.LoadFromFile('/var/run/haproxy.pid');
for i:=0 to t.Count-1 do begin
    result:=result+' '+t.Strings[i];
end;
  result:=trim(result);
end;

procedure thaproxy.STOP();
var
   count:integer;
   RegExpr:TRegExpr;
   cmd:string;
   pids:Tstringlist;
   pidstring:string;
   fpid,i:integer;
begin
if not FileExists(binpath) then begin
   writeln('Stopping HAProxy.............: Not installed');
   exit;
end;

if not SYS.PROCESS_EXIST(PID_NUM()) then begin
        writeln('Stopping HAProxy.............: Already Stopped');
        exit;
end;
   pidstring:=PID_NUM();
   writeln('Stopping HAProxy.............: ' + pidstring + ' PID..');
   fpsystem('/bin/kill ' + pidstring +' >/dev/null 2>&1');
   pidstring:=PidfilesLines();
   writeln('Stopping HAProxy.............: ' + pidstring + ' PIDs..');
   fpsystem('/bin/kill ' +pidstring +' >/dev/null 2>&1');
   count:=0;

   pidstring:=PID_NUM();
   while SYS.PROCESS_EXIST(pidstring) do begin
        fpsystem('/bin/kill  ' + pidstring +' >/dev/null 2>&1');
        pidstring:=PidfilesLines();
        fpsystem('/bin/kill ' + pidstring+' >/dev/null 2>&1');
        pidstring:=PID_NUM();
        sleep(200);
        count:=count+1;
        if count>50 then begin
            if length(pidstring)>0 then begin
               if SYS.PROCESS_EXIST(pidstring) then begin
                  writeln('Stopping HAProxy.............: Kill pid '+ pidstring+' after timeout');
                  fpsystem('/bin/kill -9 ' + pidstring +' >/dev/null 2>&1');
                  pidstring:=PidfilesLines();
                  fpsystem('/bin/kill -9 ' + pidstring+' >/dev/null 2>&1');

               end;
            end;
            break;
        end;
        pidstring:=PID_NUM();
  end;

  if not SYS.PROCESS_EXIST(PID_NUM()) then writeln('Stopping HAProxy.............: Stopped');
end;

 //##############################################################################

function thaproxy.BIN_PATH():string;
begin
result:=SYS.LOCATE_GENERIC_BIN('haproxy');
end;
procedure thaproxy.START();
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
         logs.DebugLogs('Starting......: HAProxy not installed');
         exit;
   end;

   if not FileExists(SYS.LOCATE_GENERIC_BIN('socat')) then fpsystem(SYS.LOCATE_GENERIC_BIN('nohup')+' /usr/share/artica-postfix/bin/artica-make APP_SOCAT >/dev/null 2>&1 &');


if EnableHaProxy=0 then begin
   logs.DebugLogs('Starting......:  HAProxy is disabled');
   STOP();
   exit;
end;

if SYS.PROCESS_EXIST(PID_NUM()) then begin
   logs.DebugLogs('Starting......:  HAProxy Already running using PID ' +PID_NUM()+ '...');
   exit;
end;

   logs.DebugLogs('Starting......: HAProxy building configuration...');
   fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.haproxy.php --build');

   logs.DebugLogs('Starting......: HAProxy server...');


   cmd:=binpath+' -f /etc/haproxy/haproxy.cfg -D -p /var/run/haproxy.pid';
   fpsystem(cmd);
   while not SYS.PROCESS_EXIST(PID_NUM()) do begin
     sleep(300);
     inc(count);
     if count>50 then begin
       logs.DebugLogs('Starting......: HAProxy (timeout!!!)');
       logs.DebugLogs('Starting......: HAProxy "'+cmd+'"');
       break;
     end;
   end;




   if not SYS.PROCESS_EXIST(PID_NUM()) then begin
       logs.DebugLogs('Starting......: HAProxy (failed!!!)');
   end else begin
       logs.DebugLogs('Starting......: HAProxy started with new PID '+PID_NUM());
   end;

end;


 function thaproxy.PID_NUM():string;
begin
  result:=SYS.GET_PID_FROM_PATH(PID_PATH());
  logs.Debuglogs(' ->'+result);
  if length(result)=0 then result:=SYS.PIDOF_PATTERN(binpath);
  if not SYS.PROCESS_EXIST(result) then result:=SYS.PIDOF_PATTERN(binpath);
end;
 //##############################################################################
function thaproxy.PID_PATH():string;
begin
     if FileExists('/var/run/haproxy.pid') then exit('/var/run/haproxy.pid');
end;
 //##############################################################################
end.
