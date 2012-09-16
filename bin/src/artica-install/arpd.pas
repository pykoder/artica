unit arpd;

{$MODE DELPHI}
{$LONGSTRINGS ON}

interface

uses
    Classes, SysUtils,variants,strutils,Process,logs,unix,RegExpr in 'RegExpr.pas',zsystem,IniFiles,tcpip;



  type
  tarpd=class


private
     LOGS:Tlogs;
     SYS:TSystem;
     artica_path:string;
     EnableArpDaemon:integer;
     binpath:string;
public
    procedure   Free;
    constructor Create(const zSYS:Tsystem);
    procedure   START();
    procedure   STOP();
    function    BIN_PATH():string;
    function    PID_NUM():string;
   procedure    RELOAD();
   procedure    INSTALL_INIT_D();


END;

implementation

constructor tarpd.Create(const zSYS:Tsystem);
begin

       LOGS:=tlogs.Create();
       SYS:=zSYS;
       binpath:=BIN_PATH();
       if not TryStrToInt(SYS.GET_INFO('EnableArpDaemon'),EnableArpDaemon) then EnableArpDaemon:=1;

end;
//##############################################################################
procedure tarpd.free();
begin
    logs.Free;
end;
//##############################################################################
procedure tarpd.INSTALL_INIT_D();
var
   l:Tstringlist;
begin
l:=Tstringlist.Create;
l.add('#!/bin/sh');
 if fileExists('/sbin/chkconfig') then begin
    l.Add('# chkconfig: 2345 11 89');
    l.Add('# description: Artica-status Daemon');
 end;
l.add('### BEGIN INIT INFO');
l.add('# Provides:          Artica-status ');
l.add('# Required-Start:    $local_fs');
l.add('# Required-Stop:     $local_fs');
l.add('# Should-Start:');
l.add('# Should-Stop:');
l.add('# Default-Start:     2 3 4 5');
l.add('# Default-Stop:      0 1 6');
l.add('# Short-Description: Start Artica status daemon');
l.add('# chkconfig: 2345 11 89');
l.add('# description: Artica status Daemon');
l.add('### END INIT INFO');
l.add('');
l.add('case "$1" in');
l.add(' start)');
l.add('    /usr/share/artica-postfix/bin/artica-install -watchdog arpd $2');
l.add('    ;;');
l.add('');
l.add('  stop)');
l.add('    /usr/share/artica-postfix/bin/artica-install -shutdown arpd $2');
l.add('    ;;');
l.add('');
l.add(' restart)');
l.add('     /usr/share/artica-postfix/bin/artica-install -shutdown arpd $2');
l.add('     sleep 3');
l.add('     /usr/share/artica-postfix/bin/artica-install -watchdog arpd $2');
l.add('    ;;');
l.add('');
l.add('  *)');
l.add('    echo "Usage: $0 {start|stop|restart}"');
l.add('    exit 1');
l.add('    ;;');
l.add('esac');
l.add('exit 0');

logs.WriteToFile(l.Text,'/etc/init.d/arpd');
 fpsystem('/bin/chmod +x /etc/init.d/arpd >/dev/null 2>&1');

 if FileExists('/usr/sbin/update-rc.d') then begin
    fpsystem('/usr/sbin/update-rc.d -f arpd defaults >/dev/null 2>&1');
 end;

  if FileExists('/sbin/chkconfig') then begin
     fpsystem('/sbin/chkconfig --add arpd >/dev/null 2>&1');
     fpsystem('/sbin/chkconfig --level 2345 arpd on >/dev/null 2>&1');
  end;

   LOGS.Debuglogs('Starting......: ARP Daemon install init.d scripts........:OK (/etc/init.d/arpd {start,stop,restart})');



end;
//##############################################################################
procedure tarpd.STOP();
var
   count:integer;
   RegExpr:TRegExpr;
   cmd:string;
   pids:Tstringlist;
   pidstring:string;
   fpid,i:integer;
begin
if not FileExists(binpath) then begin
   writeln('Stopping ARP Daemon..........: Not installed');
   exit;
end;

if not SYS.PROCESS_EXIST(PID_NUM()) then begin
      writeln('Stopping ARP Daemon..........: Already Stopped');
      exit;
end;
   pidstring:=PID_NUM();
   writeln('Stopping ARP Daemon..........: ' + pidstring + ' PID..');
   cmd:=SYS.LOCATE_GENERIC_BIN('kill')+' -9 '+pidstring+' >/dev/null 2>&1';
   fpsystem(cmd);

   count:=0;
   while SYS.PROCESS_EXIST(pidstring) do begin
        sleep(200);
        count:=count+1;
        if count>50 then begin
            if length(pidstring)>0 then begin
               if SYS.PROCESS_EXIST(pidstring) then begin
                  writeln('Stopping ARP Daemon..........: kill pid '+ pidstring+' after timeout');
                  fpsystem('/bin/kill -9 ' + pidstring);
               end;
            end;
            break;
        end;
        pidstring:=PID_NUM();
  end;

  count:=0;
  pids:=Tstringlist.Create;
  pids.AddStrings(SYS.PIDOF_PATTERN_PROCESS_LIST(bin_path));
  writeln('Stopping ARP Daemon..........: ',pids.Count,' childrens.');
  for i:=0 to pids.Count-1 do begin
        if not TryStrToInt(pids.Strings[i],fpid) then continue;
        if fpid>2 then begin
              writeln('Stopping ARP Daemon..........: kill pid ',fpid);
              fpsystem('/bin/kill -9 '+ IntToStr(fpid));
        end;
  end;

  if not SYS.PROCESS_EXIST(PID_NUM()) then    writeln('Stopping ARP Daemon..........: success');
end;

//##############################################################################
function tarpd.BIN_PATH():string;
begin
result:=SYS.LOCATE_GENERIC_BIN('arpd');
end;
//##############################################################################
procedure tarpd.RELOAD();
var
   pid:string;
begin
pid:=PID_NUM();

if SYS.PROCESS_EXIST(pid) then begin
   logs.DebugLogs('Starting......: ARP Daemon reload PID ' +pid+ '...');
   fpsystem('/bin/kill -HUP '+ pid);
   exit;
end;
   START();

end;
//##############################################################################


procedure tarpd.START();
var
   count,i:integer;
   cmd:string;
   su,nohup:string;
   conf:TiniFile;
   enabled:integer;
   RegExpr:TRegExpr;
   servername:string;
   tmpfile:string;
   cmdline:string;
   zinterfaces:string;
   tcp_IP:ttcpip;
   ArpdKernelLevel:integer;
   ArpdKernelLevel_string:string;
begin

     if not TryStrToInt(SYS.GET_INFO('ArpdKernelLevel'),ArpdKernelLevel) then ArpdKernelLevel:=0;


   if not FileExists(binpath) then begin
         logs.DebugLogs('Starting......: ARP Daemon is not installed');
         exit;
   end;

   if not FileExists('/etc/init.d/arpd') then  INSTALL_INIT_D();

if EnableArpDaemon=0 then begin
   logs.DebugLogs('Starting......: ARP Daemon is disabled');
   STOP();
   exit;
end;
if ArpdKernelLevel=0 then begin
          logs.DebugLogs('Starting......: ARP Daemon without kernel helper');
end else begin
    logs.DebugLogs('Starting......: ARP Daemon kernel level '+IntTOStr(ArpdKernelLevel));
end;

if SYS.PROCESS_EXIST(PID_NUM()) then begin
   logs.DebugLogs('Starting......: ARP Daemon Already running using PID ' +PID_NUM()+ '...');
   exit;
end;

   tcp_IP:=ttcpip.Create;
   RegExpr:=TRegExpr.Create;
   RegExpr.Expression:='^.+?:.+';
   tcp_IP.InterfacesStringListMEM();
   for i:=0 to tcp_IP.MEMORY_LIST_NIC.Count -1 do begin
         if trim(tcp_IP.MEMORY_LIST_NIC.Strings[i])='lo' then continue;
         if RegExpr.Exec(tcp_IP.MEMORY_LIST_NIC.Strings[i]) then continue;
         logs.DebugLogs('Starting......: ARP Daemon hook '+tcp_IP.MEMORY_LIST_NIC.Strings[i]+' interface');
         zinterfaces:=zinterfaces+' '+ tcp_IP.MEMORY_LIST_NIC.Strings[i];
   end;

   zinterfaces:=trim(zinterfaces);
   if length(zinterfaces)=0 then begin
        logs.DebugLogs('Starting......: ARP Daemon no interface found, aborting !');
        exit;
   end;
  if ArpdKernelLevel>0 then ArpdKernelLevel_string:=' -a '+IntToStr(ArpdKernelLevel);
   ForceDirectories('/var/lib/arpd');
   cmd:=binpath +' -b /var/lib/arpd/arpd.db'+ArpdKernelLevel_string+' -k '+zinterfaces+' &';
   fpsystem(cmd);
   count:=0;
   while not SYS.PROCESS_EXIST(PID_NUM()) do begin
     sleep(300);
     inc(count);
     if count>50 then begin
       logs.DebugLogs('Starting......: ARP Daemon (timeout!!!)');
       logs.DebugLogs('Starting......: ARP Daemon "'+cmd+'"');
       break;
     end;
   end;

   if not SYS.PROCESS_EXIST(PID_NUM()) then begin
       logs.DebugLogs('Starting......: ARP Daemon (failed!!!)');
       logs.DebugLogs('Starting......: ARP Daemon "'+cmd+'"');
   end else begin
       logs.DebugLogs('Starting......: ARP Daemon started with new PID '+PID_NUM());
   end;

end;
//##############################################################################
 function tarpd.PID_NUM():string;
begin
  result:=SYS.PIDOF(binpath);
  if sys.verbosed then logs.Debuglogs('PID_NUM():: '+binpath+'  -> '+result);
end;
 //##############################################################################
end.
