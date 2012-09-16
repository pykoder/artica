<?php
include_once(dirname(__FILE__)."/ressources/class.user.inc");
include_once(dirname(__FILE__)."/ressources/class.templates.inc");

if(isset($_GET["about"])){about_section();exit;}
if(isset($_GET["current-time"])){get_current_time();exit;}
if(isset($_GET["settings"])){set_current_date_js();exit;}
if(isset($_GET["date-settings"])){set_current_date_page();exit;}
if(isset($_GET["year"])){save_currenttime();exit;}
die("Wrong commands");


function set_current_date_js(){
	$tpl=new templates();
	$title=$tpl->_ENGINE_parse_body('{server_time2}');
	$page=CurrentPageName();
	$user=new usersMenus();
	if(!$user->AsArticaAdministrator){
		echo $tpl->_ENGINE_parse_body("alert('{ERROR_NO_PRIVS}')");
		die();
	}
	$html="
	
	var x_SaveServerTime= function (obj) {
		var results=obj.responseText;
		if (results.length>0){
			alert(results);
			LoadTimeParams();
		}
	}	
	
		function LoadTimeParams(){
			YahooWin6('500','$page?date-settings=yes','$title');
		
		}
		
		function SaveServerTime(){
		var XHR = new XHRConnection();
		XHR.appendData('year',document.getElementById('year').value);
		XHR.appendData('month',document.getElementById('month').value);
		XHR.appendData('day',document.getElementById('day').value);
		XHR.appendData('hour',document.getElementById('hour').value);
		XHR.appendData('minute',document.getElementById('minute').value);
		XHR.appendData('seconds',document.getElementById('seconds').value);
		
		
		document.getElementById('servertimediv').innerHTML='<center><img src=\"img/wait_verybig.gif\"></center>';
		XHR.sendAndLoad('$page', 'GET',x_SaveServerTime);
		
		}
		
		
	LoadTimeParams();
	
	";
	
	echo $html;
	
}

function save_currenttime(){
	
	$newdate="MMDDhhmmYY.ss";
	$newdate="{$_GET["month"]}{$_GET["day"]}{$_GET["hour"]}{$_GET["minute"]}{$_GET["year"]}.{$_GET["seconds"]}";
	$sock=new sockets();
	echo $sock->getFrameWork("cmd.php?SetServerTime=$newdate");
}

function get_current_time(){
	
	$users=new usersMenus();
	if($users->AsArticaAdministrator){
		$html="<a onclick=\"Loadjs('index.time.php?settings=yes')\" href='#'>".date('d-m H:i:s')."</a></li>";				
	}else{
		
		$html="<a onclick=\"#\" href='#'>".date('d-m H:i:s')."</a></li>";
	}
	
	
}


function set_current_date_page(){
	$user=new usersMenus();
	$page=CurrentPageName();
	$tpl=new templates();
	$titleabout=$tpl->_ENGINE_parse_body("{server_time2}::{about_this_section}");
	if(!$user->AsArticaAdministrator){die();}
	$sock=new sockets();
	exec("/bin/date \"+%d-%m %H:%M:%S\"",$results);
	$time=@implode("",$results);
	
	for($i=1;$i<13;$i++){
		if($i<10){$month_text="0$i";}else{$month_text=$i;}
		$months[$month_text]=$month_text;
	}
	
	for($i=1;$i<32;$i++){
		if($i<10){$day_text="0$i";}else{$day_text=$i;}
		$days[$day_text]=$day_text;
	}

	for($i=1;$i<24;$i++){
		if($i<10){$hours_text="0$i";}else{$hours_text=$i;}
		$hours[$hours_text]=$hours_text;
	}

	for($i=1;$i<60;$i++){
		if($i<10){$mins_text="0$i";}else{$mins_text=$i;}
		$mins[$mins_text]=$mins_text;
		$secs[$mins_text]=$mins_text;
	}		
		
	for($i=2009;$i<2050;$i++){
		$years_value=$i-2000;
		if($years_value<10){$years_value="0$years_value";}else{$years_value=$i;}
		$years[$years_value]=$i;
	}
	
	if(preg_match("#([0-9]+)-([0-9]+) ([0-9]+):([0-9]+):([0-9]+)#",$time,$re)){
		$defday=$re[1];
		$defmonth=$re[2];
		$defhour=$re[3];
		$defmin=$re[4];
		$defsec=$re[5];
	}
	$headstyle="style='font-weight:bold;font-size:14px'";
	$form="
	<div style='width:95%' class=form>
	<table style='width:99%'>
	<tr>
		<td $headstyle align='center'>{year}</th>
		<td $headstyle align='center'>{month}</th>
		<td $headstyle align='center'>{day}</th>
		<td $headstyle align='center'>{hours}</th>
		<td $headstyle align='center'>{minutes}</th>
		<td $headstyle align='center'>{seconds}</th>
	</tr>
	<tr>
		<td align='center'>" . Field_array_Hash($years,'year',date('Y'),"style:font-size:20px;padding:5px")."</td>	
		<td align='center'>" . Field_array_Hash($months,'month',$defmonth,"style:font-size:20px;padding:5px")."</td>
		<td align='center'>" . Field_array_Hash($days,'day',$defday,"style:font-size:20px;padding:5px")."</td>
		<td align='center'>" . Field_array_Hash($hours,'hour',$defhour,"style:font-size:20px;padding:5px")."</td>
		<td align='center'>" . Field_array_Hash($mins,'minute',$defmin,"style:font-size:20px;padding:5px")."</td>
		<td align='center'>" . Field_array_Hash($secs,'seconds',$defsec,"style:font-size:20px;padding:5px")."</td>
	</tr>
	<tr>
		<td colspan=6 align='right'>
		<hr>". button("{apply}","SaveServerTime()","18px")."
		</td>
		
	</tr>
		
	</table>
	
	</div>
	<div style='text-align:right;width:100%'>". imgtootltip("20-refresh.png","{refresh}","LoadTimeParams()")."</div>";


	$html="

	<div id='servertimediv'>
	$form
	</div>
	<table style='width:50%'>
	<tr>
		<td width=1%><img src='img/arrow-right-24.png'></td>
		<td nowrap><a href=\"javascript:blur();\" OnClick=\"javascript:HelpTime();\" 
		style='font-size:14px;text-decoration:underline'>{about_this_section}</a></td>
	</tr>
	<tr>
		<td width=1%><img src='img/arrow-right-24.png'></td>
		<td nowrap><a href=\"javascript:blur();\" OnClick=\"Loadjs('ntpd.index.php');\" style='font-size:14px;text-decoration:underline'>{APP_NTPD}</a></td>
	</tr>
	</table>
		
	<script>
		function HelpTime(){
			YahooWinBrowse('550','$page?about=yes','$titleabout');
		
		}
	</script>
	
	";
	$tpl=new templates();
	echo $tpl->_ENGINE_parse_body($html);
	
}
function about_section(){
	$tpl=new templates();
	$html="<div class=explain style='font-size:13px'>{clocks_text}</div>";
	echo $tpl->_ENGINE_parse_body($html);
}
?>