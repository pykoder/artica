<?php
$GLOBALS["DEBUG_INCLUDES"]=false;
$GLOBALS["VERBOSE_MASTER"]=false;
if(preg_match("#--verbose#",implode(" ",$argv))){$GLOBALS["DEBUG"]=true;$GLOBALS["VERBOSE"]=true;
$GLOBALS["VERBOSE_MASTER"]=true;ini_set('html_errors',0);ini_set('display_errors', 1);ini_set('error_reporting', E_ALL);}
	include_once('ressources/class.templates.inc');
	include_once('ressources/class.ldap.inc');
	include_once("ressources/class.sockets.inc");
	include_once(dirname(__FILE__).'/ressources/class.os.system.inc');
	include_once(dirname(__FILE__).'/framework/class.unix.inc');
	include_once(dirname(__FILE__).'/framework/frame.class.inc');	

$GLOBALS["LOGON-PAGE"]=true;
if($GLOBALS["DEBUG"]){echo "Starting...{$argv[1]}\n";}
$GLOBALS["langs"]=array("fr","en","po","es","it","br","pol");
if($argv[1]=="--remove"){remove_ipcs();die;}
if($argv[1]=="--dump"){output_ipcs();die;}	
if($argv[1]=="--dump-pages"){dump_pages();die;}
if($argv[1]=="--parse-langs"){CompactLang();die;}
if($argv[1]=="--compile-lang"){importlangs();die;}
if($argv[1]=="--SessionMem"){PHP5SessionPath($argv[2]);die;}
if($argv[1]=="--service-up"){service_up();die();}





function PHP5SessionPath($dir){
	if($dir==null){return;}
	$unix=new unix();
	$mount=$unix->find_program("mount");
	$umount=$unix->find_program("umount");	
	$sock=new sockets();
	$SessionPathInMemory=$sock->GET_INFO("SessionPathInMemory");
	
	if(!is_numeric($SessionPathInMemory)){
		$users=new usersMenus();
		$memoire=$users->MEM_TOTAL_INSTALLEE;
		$memoire=round($memoire/1024);
		echo "Starting......: lighttpd: Try to calculate the memory available ({$memoire}M)\n";
		if($memoire>512){$SessionPathInMemory=50;}
		if($memoire>699){$SessionPathInMemory=90;}
		if($memoire>999){$SessionPathInMemory=128;}
		if($memoire>1499){$SessionPathInMemory=256;}
		if($memoire>1999){$SessionPathInMemory=320;}
		if($memoire>2599){$SessionPathInMemory=512;}
		if($memoire>4999){$SessionPathInMemory=728;}	
		$sock->SET_INFO("SessionPathInMemory", $SessionPathInMemory);
		
	}
	
	
	if(PHP5SessionPathIsMounted($dir)){
		$mountedMem=PHP5SessionPathIsMountedSizeMem($dir);
		$log[]=__LINE__." $dir = {$mountedMem}M against {$SessionPathInMemory}M";
		if($mountedMem==$SessionPathInMemory){return;}
		echo "Starting......: lighttpd: unmounting $dir memory filesystem\n";
		shell_exec("$umount -f $dir >/dev/null 2>&1");
		if(is_dir($dir)){shell_exec("/bin/rm -rf $dir/*");}
		$unix->send_email_events("Success cleaning session path in memory", @implode("\n", $log), "system");
	}
	
	if(!PHP5SessionPathIsMounted($dir)){
		if($SessionPathInMemory>0){
			echo "Starting......: lighttpd: mounting $dir memory filesystem\n";
			@mkdir($dir,0755,true);
			if(is_dir($dir)){shell_exec("/bin/rm -rf $dir/*");}
			$cmd="$mount -t tmpfs -o size={$SessionPathInMemory}M tmpfs \"$dir\" 2>&1";
			$log[]=__LINE__." $cmd";
			if($GLOBALS["VERBOSE"]){echo "$cmd\n";}
			exec("$cmd",$results_cmd);
			if(count($results_cmd)>0){while (list ($index, $line) = each ($results_cmd) ){$log[]=__LINE__." $line";}}
			if(PHP5SessionPathIsMounted($dir)){
				$unix->send_email_events("lighttpd: mounting $dir {$SessionPathInMemory}M in memory filesystem success", @implode("\n", $log), "system");
				echo "Starting......: lighttpd: mounting $dir {$SessionPathInMemory}M in memory filesystem success\n";
			}else{
				echo "Starting......: lighttpd: mounting $dir {$SessionPathInMemory}M in memory filesystem failed\n";
				$unix->send_email_events("lighttpd: mounting $dir {$SessionPathInMemory}M in memory filesystem FAILED", @implode("\n", $log), "system");
			}
		}
	}else{
		echo "Starting......: lighttpd: $dir Already mounted\n";
	}

	
}

function PHP5SessionPathIsMounted($dir){
	$f=explode("\n",@file_get_contents("/proc/mounts"));
	while (list ($index, $line) = each ($f) ){if(preg_match("#^tmpfs.+?$dir tmpfs#", $line)){return true;}
	}return false;
	
}
function PHP5SessionPathIsMountedSizeMem($dir){
	$f=explode("\n",@file_get_contents("/proc/mounts"));
	while (list ($index, $line) = each ($f) ){if(preg_match("#^tmpfs.+?$dir tmpfs.+?size=([0-9]+)k#", $line,$re)){return $re[1]/1024;}
	}return 0;
	
}

function dump_pages(){
		$debug=$GLOBALS["DEBUG"];
		
		if($debug){echo "open sockets()\n";}
		$sock=new sockets();
		
		if($debug){echo "semaphores($sock->semaphore_key,$sock->semaphore_memory)\n";}
		$sem=new semaphores($sock->semaphore_key,$sock->semaphore_memory);
		$array=$sem->MyArray();
		echo count($array)." rows ". str_replace("&nbsp;"," ",FormatBytes($taille/1024)). " memory use\n";
		while (list ($num, $ligne) = each ($array) ){
			$bytes=strlen($ligne);
			echo "Cached pages: $num=".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."\n";
		}
		$sem->CLOSE();
		$sem=new semaphores($sock->semaphore_key,$sock->semaphore_memory,2);
		$array=$sem->MyArray();
		$sem->CLOSE();
		echo count($array)." Langages\n";
		while (list ($num, $ligne) = each ($array) ){
			$bytes=strlen(serialize($ligne));
			echo "Langages: $num=".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."\n";
		}		
		
	
}


if($GLOBALS["DEBUG"]){echo "Starting..sockets()\n";}
	
			$sock=new sockets();
			$xkey = "1376880652";
			$memory=2024000;	
			
			if($GLOBALS["DEBUG"]){echo "->SHARED_INFO_BYTES($xkey,$memory)\n";}
			$bytes=$sock->SHARED_INFO_BYTES($xkey,$memory);
			
			echo "\n";
			echo "\n";
			echo "-----------------------------------------\n";			
			echo "Inter-process memory=".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."/". str_replace("&nbsp;"," ",FormatBytes($memory/1024))."\n";
			echo "-----------------------------------------\n";
			echo "\n";

			
		$xkey = "1376880653";
		$memory=3024000;
		$bytes=$sock->SHARED_INFO_BYTES($xkey,$memory);
		
			echo "\n";
			echo "\n";
			echo "-----------------------------------------\n";			
			echo "DATA-process memory=".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."/". str_replace("&nbsp;"," ",FormatBytes($memory/1024))."\n";
			echo "-----------------------------------------\n";
			echo "\n";	
			
			$xkey = "1376880654";
			$memory=5024000;
			$bytes=$sock->SHARED_INFO_BYTES($xkey,$memory);
		
			echo "\n";
			echo "\n";
			echo "-----------------------------------------\n";			
			echo "DATA-process memory=".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."/". str_replace("&nbsp;"," ",FormatBytes($memory/1024))."\n";
			echo "-----------------------------------------\n";
			echo "\n";				


			
function remove_ipcs(){
	$unix=new unix();
	$sock=new sockets();
	$sock->DATA_CACHE_EMPTY();
	$ipcs=$unix->find_program("ipcs");
	$ipcrm=$unix->find_program("ipcrm");
	exec($ipcs,$array);
	
	while (list ($num, $ligne) = each ($array) ){
		if(preg_match("#(.+?)\s+([0-9]+)\s+www-data#",$ligne,$re)){
			echo "killing shared memory entry {$re[2]}\n";
			system("$ipcrm -m {$re[2]}");
			continue;
		}
		
		if(preg_match("#(.+?)\s+([0-9]+)\s+lighttpd#",$ligne,$re)){
			echo "killing shared memory entry {$re[2]}\n";
			system("$ipcrm -m {$re[2]}");
			continue;
		}		
		
		if(preg_match("#(.+?)\s+([0-9]+)\s+(.+?)\s+([0-9]+)\s+3024000#",$ligne,$re)){
			echo "killing shared memory entry {$re[2]}\n";
			system("$ipcrm -m {$re[2]}");
			continue;
		}
		
		if(preg_match("#(.+?)\s+([0-9]+)\s+(.+?)\s+([0-9]+)\s+2024000#",$ligne,$re)){
			echo "killing shared memory entry {$re[2]}\n";
			system("$ipcrm -m {$re[2]}");
			continue;
		}		
		
		
		
	}
	
$shm=new semaphores($sock->semaphore_key,$sock->semaphore_memory,1);	
$shm->removekey();
$shm->Delete();
$shm=new semaphores($sock->semaphore_key,$sock->semaphore_memory,2);	
$shm->removekey();
$shm->Delete();
$shm=new semaphores($sock->semaphore_key,$sock->semaphore_memory,3);	
$shm->removekey();
$shm->Delete();

reset($GLOBALS["langs"]);
	while (list ($num, $ligne) = each ($GLOBALS["langs"]) ){
				$data=serialize($sock->LANGUAGE_DUMP($ligne));
				echo "Cleaned language \"$ligne\" ".str_replace("&nbsp;"," ",FormatBytes($data/1024))." bytes\n";
	}
	
	
	CompactLang();
}

function output_ipcs(){
	$sock=new sockets();
	echo "\n";
	
	while (list ($num, $val) = each ($GLOBALS["langs"]) ){
		$datas=$sock->LANGUAGE_DUMP($val);
		$bb=strlen(serialize($datas));
		$a=$a+$bb;
		$bb=str_replace("&nbsp;"," ",FormatBytes($bb/1024));
		$tt[]="\tDumping language $val $bb";
	}	
	
	
			
			$bytes=$sock->SHARED_INFO_BYTES(3);
			$text=$text."Processes memory Cache............: ".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."/". str_replace("&nbsp;"," ",FormatBytes($sock->semaphore_memory/1024))."\n";

			$bytes=$sock->SHARED_INFO_BYTES(1);
			$text=$text."DATA Cache........................: ".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."/". str_replace("&nbsp;"," ",FormatBytes($sock->semaphore_memory/1024))."\n";

			$bytes=$a;
			$text=$text."Language Cache....................: ".str_replace("&nbsp;"," ",FormatBytes($bytes/1024))."/". str_replace("&nbsp;"," ",FormatBytes($sock->semaphore_memory/1024))."\n";
			$text=$text.implode("\n",$tt)."\n";
			
		echo $text;
					
			
			
			
	
}



function CompactLang(){
	$sock=new sockets();
	while (list ($num, $language) = each ($GLOBALS["langs"]) ){
	  $array=unserialize(@file_get_contents("/usr/share/artica-postfix/ressources/language/$language.db"));
	  $sock->LANGUAGE_CACHE_IMPORT($array,$language);
	  echo "Starting lighttpd............: compacting language \"$language\" into shared memory done ". count($array)." words\n";
	}
}

function importlangs(){
	echo "importlangs()\n";
	$GLOBALS["langs"]=array("fr","en","po","es","it","br","pol");
	while (list ($num, $val) = each ($GLOBALS["langs"]) ){
		echo "COmpile $val\n";
		CompileLangs($val);
	}	
	
}

function CompileLangs($language){
	if(trim($language)==null){return;}
	$base="/usr/share/artica-postfix/ressources/language/$language";
	$sock=new sockets();
	$pattern='#<([a-zA-Z0-9\_\-\s\.]+)>(.+?)<\/([a-zA-Z0-9\_\-\s\.]+)>#is';
	$unix=new unix();
	$files=$unix->DirFiles($base);
	while (list ($num, $val) = each ($files) ){
		$datas=@file_get_contents("$base/$val");
		if(preg_match_all($pattern,$datas,$reg)){
				while (list ($index, $word) = each ($reg[1]) ){
					$langs[$word]=$reg[2][$index];
					}
			}
			
		
		
	}	
	
	echo "writing /usr/share/artica-postfix/ressources/language/$language.db ". count($langs)." words\n";
	file_put_contents("/usr/share/artica-postfix/ressources/language/$language.db",serialize($langs));			
}

function service_up(){
		remove_ipcs();
		$unix=new unix();
		$nohup=$unix->find_program("nohup");
		$rm=$unix->find_program("rm");
		shell_exec("$nohup $rm -f /usr/share/artica-postfix/ressources/logs/web/*.cache >/dev/null 2>&1 &");
		shell_exec("$nohup $rm -f /usr/share/artica-postfix/ressources/logs/web/cache/* >/dev/null 2>&1 &");
		@chmod("/var/log/php.log", 0777);
	}

			
?>