unit fuppes;

{$MODE DELPHI}
{$LONGSTRINGS ON}

interface

uses
    Classes, SysUtils,variants,strutils,Process,logs,unix,RegExpr in 'RegExpr.pas',zsystem,IniFiles;



  type
  tfuppes=class


private
     LOGS:Tlogs;
     SYS:TSystem;
     artica_path:string;
     EnableFuppes:integer;
     binpath:string;
public
    procedure   Free;
    constructor Create(const zSYS:Tsystem);
    procedure   START();
    procedure   STOP();
    function    PID():string;
    function BIN_PATH():string;

END;

implementation

constructor tfuppes.Create(const zSYS:Tsystem);
begin

       LOGS:=tlogs.Create();
       SYS:=zSYS;
       binpath:=BIN_PATH();
       if not TryStrToInt(SYS.GET_INFO('EnableFuppes'),EnableFuppes) then EnableFuppes:=1;

end;
//##############################################################################
procedure tfuppes.free();
begin
    logs.Free;
end;
//##############################################################################

procedure tfuppes.STOP();
var
   count:integer;
   RegExpr:TRegExpr;
   servername:string;
   pids:Tstringlist;
   pidstring:string;
   fpid,i:integer;
begin
if not FileExists(binpath) then begin
   writeln('Stopping fuppes..............: Not installed');
   exit;
end;


if not SYS.PROCESS_EXIST(PID()) then begin
        writeln('Stopping fuppes..............: already Stopped');
        exit;
end;
   pidstring:=PID();
   count:=0;
   writeln('Stopping fuppes..............: pid '+ pidstring);

   count:=0;
   while SYS.PROCESS_EXIST(pidstring) do begin
        sleep(200);
        count:=count+1;
        if count>20 then begin
            if length(pidstring)>0 then begin
               if SYS.PROCESS_EXIST(pidstring) then begin
                  writeln('Stopping fuppes..............: kill pid '+ pidstring+' after timeout');
                  fpsystem('/bin/kill -9 ' + pidstring);
               end;
            end;
            break;
        end;
  end;



   pids:=Tstringlist.Create;
   pids.AddStrings(SYS.PIDOF_PATTERN_PROCESS_LIST(binpath));
   if pids.Count>1 then begin
   for i:=0 to pids.Count-1 do begin
       if TryStrToInt(pids.Strings[i],fpid) then begin
          if fpid>1 then begin
             writeln('Stopping fuppes..............: kill pid(s) ',fpid);
             fpsystem('/bin/kill -9 '+ IntTOStr(fpid));
          end;
       end;
   end;
   end;

  if not SYS.PROCESS_EXIST(PID()) then writeln('Stopping fuppes..............: Stopped');
end;

 //##############################################################################

function tfuppes.BIN_PATH():string;
begin
exit(SYS.LOCATE_GENERIC_BIN('fuppesd'));
end;
 //##############################################################################
procedure tfuppes.START();
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
         logs.DebugLogs('Starting......: fuppes not installed');
         exit;
   end;

if EnableFuppes=0 then begin
   logs.DebugLogs('Starting......:  fuppes is disabled');
   STOP();
   exit;
end;

if SYS.PROCESS_EXIST(PID()) then begin
   logs.DebugLogs('Starting......:  fuppes Already running using PID ' +PID()+ '...');
   exit;
end;

   logs.DebugLogs('Starting......:  writing init.d script');
   fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.fuppes.php --init');

   logs.DebugLogs('Starting......:  writing configuration file');
   fpsystem(SYS.LOCATE_PHP5_BIN()+' /usr/share/artica-postfix/exec.fuppes.php --config');
   cmd:=binpath+' --log-level 1 --log-file /var/log/fuppes.log --temp-dir /tmp/fuppes --config-file /etc/fuppes/fuppes.cfg --database-file /var/db/fuppes/fuppes.db --vfolder-config-file /etc/fuppes/vfolder.cfg';
   fpsystem(cmd);
   count:=0;
   while not SYS.PROCESS_EXIST(PID()) do begin
     sleep(150);
     inc(count);
     if count>50 then begin
       logs.DebugLogs('Starting......: fuppes (timeout!!!)');
       logs.DebugLogs('Starting......: fuppes "'+cmd+'"');
       break;
     end;
   end;




   if not SYS.PROCESS_EXIST(PID()) then begin
       logs.DebugLogs('Starting......: fuppes (failed!!!)');
   end else begin
       logs.DebugLogs('Starting......: fuppes started with new PID '+PID());
   end;

end;
//##############################################################################
 function tfuppes.PID():string;
begin
  result:=SYS.PIDOF(binpath);
end;
 //##############################################################################

end.
