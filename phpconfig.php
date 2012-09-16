<?php
include_once('ressources/class.templates.inc');
include_once('ressources/class.ldap.inc');
include_once('ressources/class.users.menus.inc');
if(isset($_GET["verbose"])){$GLOBALS["VERBOSE"]=true;ini_set('display_errors', 1);ini_set('error_reporting', E_ALL);ini_set('error_prepend_string',null);ini_set('error_append_string',null);}

		$usersmenus=new usersMenus();
		if(!$usersmenus->AsPostfixAdministrator){
			$tpl=new templates();
			echo "alert('".$tpl->javascript_parse_text('{ERROR_NO_PRIVS}')."');";
			die();
		}

	if(isset($_POST["php5DisableMagicQuotesGpc"])){save();exit;}	
	if(isset($_GET["popup"])){popup();exit;}
	if(isset($_GET["options"])){popup_options();exit;}
	if(isset($_GET["modules"])){popup_modules();exit;}
	if(isset($_GET["load-module"])){load_module();exit;}
	if(isset($_GET["Modules-list"])){load_modules_list();exit;}
	if(isset($_POST["unik-EnableRRDGraphFunction"])){EnableRRDGraphFunctionSave();exit;}
	js();
	
	
function EnableRRDGraphFunctionSave(){
	$sock=new sockets();
	$sock->SET_INFO("EnableRRDGraphFunction", $_POST["unik-EnableRRDGraphFunction"]);
}
	
function js(){
$page=CurrentPageName();
	$prefix=str_replace('.','_',$page);
	$prefix=str_replace('-','',$prefix);
	$tpl=new templates();
	$title=$tpl->_ENGINE_parse_body('{advanced_options}');
	
	
$html="
	var {$prefix}timeout=0;
	var {$prefix}timerID  = null;
	var {$prefix}tant=0;
	var {$prefix}reste=0;	


	function {$prefix}LoadPage(){
		RTMMail(730,'$page?popup=yes','$title');
	}
	
	
	

	
	
var x_SavePHP5AdvancedSettings=function (obj) {
	var results=obj.responseText;
	if(results.length>2){alert(results);}
	{$prefix}LoadPage();
	}	
	


	{$prefix}LoadPage();";

	echo $html;
	}
	
function save(){
	$sock=new sockets();
	$sock->SET_INFO("php5DefaultCharset",$_POST["php5DefaultCharset"]);
	$sock->SET_INFO("php5FuncOverloadSeven",$_POST["php5FuncOverloadSeven"]);
	$sock->SET_INFO("php5DisableMagicQuotesGpc",$_POST["php5DisableMagicQuotesGpc"]);
	$sock->SET_INFO("SSLStrictSNIVHostCheck",$_POST["SSLStrictSNIVHostCheck"]);
	$sock->SET_INFO("SessionPathInMemory",$_POST["SessionPathInMemory"]);
	$sock->SET_INFO("php5UploadMaxFileSize",$_POST["php5UploadMaxFileSize"]);
	$sock->SET_INFO("php5PostMaxSize",$_POST["php5PostMaxSize"]);
	$sock->SET_INFO("php5MemoryLimit",$_POST["php5MemoryLimit"]);
	$sock->SET_INFO("timezones",$_POST["timezones"]);
	$sock->SET_INFO("EnableRRDGraphFunction", $_POST["EnableRRDGraphFunction"]);
	sleep(1);
	$sock->getFrameWork("cmd.php?php-rewrite=yes");
	$sock->getFrameWork("cmd.php?restart-web-server=yes");
}

function popup(){
		$tpl=new templates();
		$array["options"]="{options}";
		$array["modules"]="{loaded_modules}";
		$page=CurrentPageName();

	
	while (list ($num, $ligne) = each ($array) ){
		$html[]=$tpl->_ENGINE_parse_body("<li><a href=\"$page?$num=yes\"><span style='font-size:14px'>$ligne</span></a></li>\n");
	}
	
	
	echo "
	<div id=main_config_phpadv style='width:100%;height:450px;overflow:auto'>
		<ul>". implode("\n",$html)."</ul>
	</div>
		<script>
				$(document).ready(function(){
					$('#main_config_phpadv').tabs({
				    load: function(event, ui) {
				        $('a', ui.panel).click(function() {
				            $(ui.panel).load(this.href);
				            return false;
				        });
				    }
				});
			
			
			});
		</script>";	
}

function popup_modules(){
	
	$page=CurrentPageName();
	

	
	$tablesize=590;
	$tableheight=255;
	$rowsize=515;
	$t=time();
	if(is_numeric($_GET["tablesize"])){$tablesize=$_GET["tablesize"];}
	if(is_numeric($_GET["tableheight"])){$tableheight=$_GET["tableheight"];}
	if(is_numeric($_GET["rowsize"])){$rowsize=$_GET["rowsize"];}
	
	$html="
	<table class='table-$t' style='display: none' id='table-$t' style='width:100%;margin:-10px'></table>
<script>
memedb$t='';
$(document).ready(function(){
$('#table-$t').flexigrid({
	url: '$page?Modules-list=yes&t=$t',
	dataType: 'json',
	colModel : [
		{display: '&nbsp;', name : 'none', width : 31, sortable : false, align: 'center'},
		{display: 'Modules', name : 'Modules', width :$rowsize, sortable : true, align: 'left'},
		
	],
	
	$buttons

	searchitems : [
		{display: 'Modules', name : 'Modules'},
		
		],
	sortname: 'Modules',
	sortorder: 'asc',
	usepager: true,
	title: 'PHP Modules',
	useRp: false,
	rp: 50,
	showTableToggleBtn: false,
	width: $tablesize,
	height: $tableheight,
	singleSelect: true
	
	});   
});
</script>
	";
echo $html;		
}

function load_modules_list(){
	
	
	$array=parsePHPModules();
	$page=CurrentPageName();
	
	$data = array();
	$data['page'] = 1;
	$data['total'] = $total;
	$data['rows'] = array();

	$c=0;
	
	if($_POST["query"]<>null){
		$search=$_POST["query"];
		$search=str_replace(".", "\.",$search);
		$search=str_replace("*", ".*?",$search);
	}
	
	if($_POST["sortorder"]=="asc"){
		ksort($array);
	}else{
		krsort($array);
	}
	
	while (list ($module, $array_f) = each ($array) ){
		if($search<>null){
			if(!preg_match("#$search#", $module)){continue;}
		}
		
		$html=array();
		if(is_array($array_f)){
			while (list ($a, $b) = each ($array_f) ){
				if(is_array($b)){
					while (list ($c, $d) = each ($b) ){
						//$html[]="<br><span style='font-size:11px'><strong>$c</strong>:$d</span>";
					}
					
				}else{
					$html[]="<br><span style='font-size:11px'><strong>$a</strong>:$b</span>";
				}
			}
		}
		
	$c++;	
	$data['rows'][] = array(
				'id' => $module,
				'cell' => array(
					"<img src='img/arrow-right-24.png'>",
					"<strong style='font-size:14px;style='color:$color'>$href$module</a></strong>".@implode("", $html),
					
					)
				);		
		
	}
	$data['total'] = $c;
	echo json_encode($data);
	
}


function load_module(){
	$array=parsePHPModules();
	$module=$array[$_GET["load-module"]];
	
	$html[]="<table style='width:100%;padding:4px;margin:5px;border:1px solid #005447'>";
	
	while (list ($index, $data) = each ($module) ){
		$html[]="<tr>";
		$html[]="<td class=legend valign='top' style='font-size:14px'>$index:</td>";
		$html[]="<td><strong style='font-size:12px'>";
		if(is_array($data)){
			while (list ($a, $b) = each ($data) ){
				$html[]="<li style='font-size:12px'>$a:$b</li>";
			}
		}else{
			$html[]=$data;
		}
		$html[]="</strong></td>";
		$html[]="</tr>";
	}
	
	$html[]="</table>";
	echo implode("\n",$html);
	
}
function Charsets(){
	
	$arr=array("Arabic (ASMO 708) "=>"ASMO-708",
"Arabic (DOS) "=>"DOS-720",
"Arabic (ISO) "=>"iso-8859-6",
"Arabic (Mac) "=>"x-mac-arabic",
"Arabic (Windows) "=>"windows-1256",
"Baltic (DOS) "=>"ibm775",
"Baltic (ISO) "=>"iso-8859-4",
"Baltic (Windows) "=>"windows-1257",
"Central European (DOS) "=>"ibm852",
"Central European (ISO) "=>"iso-8859-2",
"Central European (Mac) "=>"x-mac-ce",
"Central European (Windows) "=>"windows-1250",
"Chinese Simplified (EUC) "=>"EUC-CN",
"Chinese Simplified (GB2312) "=>"gb2312",
"Chinese Simplified (HZ) "=>"hz-gb-2312",
"Chinese Simplified (Mac) "=>"x-mac-chinesesimp",
"Chinese Traditional (Big5) "=>"big5",
"Chinese Traditional (CNS) "=>"x-Chinese-CNS",
"Chinese Traditional (Eten) "=>"x-Chinese-Eten",
"Chinese Traditional (Mac) "=>"x-mac-chinesetrad",
"Cyrillic (DOS) "=>"cp866",
"Cyrillic (ISO) "=>"iso-8859-5",
"Cyrillic (KOI8-R) "=>"koi8-r",
"Cyrillic (KOI8-U) "=>"koi8-u",
"Cyrillic (Mac) "=>"x-mac-cyrillic",
"Cyrillic (Windows) "=>"windows-1251",
"Europa "=>"x-Europa",
"German (IA5) "=>"x-IA5-German",
"Greek (DOS) "=>"ibm737",
"Greek (ISO) "=>"iso-8859-7",
"Greek (Mac) "=>"x-mac-greek",
"Greek (Windows) "=>"windows-1253",
"Greek, Modern (DOS) "=>"ibm869",
"Hebrew (DOS) "=>"DOS-862",
"Hebrew (ISO-Logical) "=>"iso-8859-8-i",
"Hebrew (ISO-Visual) "=>"iso-8859-8",
"Hebrew (Mac) "=>"x-mac-hebrew",
"Hebrew (Windows) "=>"windows-1255",
"IBM EBCDIC (Arabic) "=>"x-EBCDIC-Arabic",
"IBM EBCDIC (Cyrillic Russian) "=>"x-EBCDIC-CyrillicRussian",
"IBM EBCDIC (Cyrillic Serbian-Bulgarian) "=>"x-EBCDIC-CyrillicSerbianBulgarian",
"IBM EBCDIC (Denmark-Norway) "=>"x-EBCDIC-DenmarkNorway",
"IBM EBCDIC (Denmark-Norway-Euro) "=>"x-ebcdic-denmarknorway-euro",
"IBM EBCDIC (Finland-Sweden) "=>"x-EBCDIC-FinlandSweden",
"IBM EBCDIC (Finland-Sweden-Euro) "=>"x-ebcdic-finlandsweden-euro",
"IBM EBCDIC (Finland-Sweden-Euro) "=>"x-ebcdic-finlandsweden-euro",
"IBM EBCDIC (France-Euro) "=>"x-ebcdic-france-euro",
"IBM EBCDIC (Germany) "=>"x-EBCDIC-Germany",
"IBM EBCDIC (Germany-Euro) "=>"x-ebcdic-germany-euro",
"IBM EBCDIC (Greek Modern) "=>"x-EBCDIC-GreekModern",
"IBM EBCDIC (Greek) "=>"x-EBCDIC-Greek",
"IBM EBCDIC (Hebrew) "=>"x-EBCDIC-Hebrew",
"IBM EBCDIC (Icelandic) "=>"x-EBCDIC-Icelandic",
"IBM EBCDIC (Icelandic-Euro) "=>"x-ebcdic-icelandic-euro",
"IBM EBCDIC (International-Euro) "=>"x-ebcdic-international-euro",
"IBM EBCDIC (Italy) "=>"x-EBCDIC-Italy",
"IBM EBCDIC (Italy-Euro) "=>"x-ebcdic-italy-euro",
"IBM EBCDIC (Japanese and Japanese Katakana) "=>"x-EBCDIC-JapaneseAndKana",
"IBM EBCDIC (Japanese and Japanese-Latin) "=>"x-EBCDIC-JapaneseAndJapaneseLatin",
"IBM EBCDIC (Japanese and US-Canada) "=>"x-EBCDIC-JapaneseAndUSCanada",
"IBM EBCDIC (Japanese katakana) "=>"x-EBCDIC-JapaneseKatakana",
"IBM EBCDIC (Korean and Korean Extended) "=>"x-EBCDIC-KoreanAndKoreanExtended",
"IBM EBCDIC (Korean Extended) "=>"x-EBCDIC-KoreanExtended",
"IBM EBCDIC (Multilingual Latin-2) "=>"CP870",
"IBM EBCDIC (Simplified Chinese) "=>"x-EBCDIC-SimplifiedChinese",
"IBM EBCDIC (Spain) "=>"X-EBCDIC-Spain",
"IBM EBCDIC (Spain-Euro) "=>"x-ebcdic-spain-euro",
"IBM EBCDIC (Thai) "=>"x-EBCDIC-Thai",
"IBM EBCDIC (Traditional Chinese) "=>"x-EBCDIC-TraditionalChinese",
"IBM EBCDIC (Turkish Latin-5) "=>"CP1026",
"IBM EBCDIC (Turkish) "=>"x-EBCDIC-Turkish",
"IBM EBCDIC (UK) "=>"x-EBCDIC-UK",
"IBM EBCDIC (UK-Euro) "=>"x-ebcdic-uk-euro",
"IBM EBCDIC (US-Canada) "=>"ebcdic-cp-us",
"IBM EBCDIC (US-Canada-Euro) "=>"x-ebcdic-cp-us-euro",
"Icelandic (DOS) "=>"ibm861",
"Icelandic (Mac) "=>"x-mac-icelandic",
"ISCII Assamese "=>"x-iscii-as",
"ISCII Bengali "=>"x-iscii-be",
"ISCII Devanagari "=>"x-iscii-de",
"ISCII Gujarathi "=>"x-iscii-gu",
"ISCII Kannada "=>"x-iscii-ka",
"ISCII Malayalam "=>"x-iscii-ma",
"ISCII Oriya "=>"x-iscii-or",
"ISCII Panjabi "=>"x-iscii-pa",
"ISCII Tamil "=>"x-iscii-ta",
"ISCII Telugu "=>"x-iscii-te",
"Japanese (EUC) "=>"euc-jp","Japanese (EUC)"=>"x-euc-jp",
"Japanese (JIS) "=>"iso-2022-jp",
"Japanese (JIS-Allow 1 byte Kana - SO/SI) "=>"iso-2022-jp",
"Japanese (JIS-Allow 1 byte Kana) "=>"csISO2022JP",
"Japanese (Mac) "=>"x-mac-japanese",
"Japanese (Shift-JIS) "=>"shift_jis",
"Korean "=>"ks_c_5601-1987",
"Korean (EUC) "=>"euc-kr",
"Korean (ISO) "=>"iso-2022-kr",
"Korean (Johab) "=>"Johab",
"Korean (Mac) "=>"x-mac-korean",
"Latin 3 (ISO) "=>"iso-8859-3",
"Latin 9 (ISO) "=>"iso-8859-15",
"Norwegian (IA5) "=>"x-IA5-Norwegian",
"OEM United States "=>"IBM437",
"Swedish (IA5) "=>"x-IA5-Swedish",
"Thai (Windows) "=>"windows-874",
"Turkish (DOS) "=>"ibm857",
"Turkish (ISO) "=>"iso-8859-9",
"Turkish (Mac) "=>"x-mac-turkish",
"Turkish (Windows) "=>"windows-1254",
"Unicode "=>"unicode",
"Unicode (Big-Endian) "=>"unicodeFFFE",
"Unicode (UTF-7) "=>"utf-7",
"Unicode (UTF-8) "=>"utf-8",
"US-ASCII "=>"us-ascii",
"Vietnamese (Windows) "=>"windows-1258",
"Western European (DOS) "=>"ibm850",
"Western European (IA5) "=>"x-IA5",
"Western European (ISO) "=>"iso-8859-1",
"Western European (Mac) "=>"macintosh",
"Western European (Windows) "=>"Windows-1252");	
	
	while (list ($index, $data) = each ($arr) ){
		$newar[trim($data)]=strtoupper(trim($data));
	}
	ksort($newar);
	$newar[null]="{select}";
	return $newar;
}

	
function popup_options(){
	$page=CurrentPageName();
	$sock=new sockets();
	$t=time();
	$php5FuncOverloadSeven=$sock->GET_INFO("php5FuncOverloadSeven");
	$php5DefaultCharset=$sock->GET_INFO("php5DefaultCharset");
	$php5UploadMaxFileSize=$sock->GET_INFO("php5UploadMaxFileSize");
	$php5PostMaxSize=$sock->GET_INFO("php5PostMaxSize");
	$php5MemoryLimit=$sock->GET_INFO("php5MemoryLimit");
	$SessionPathInMemory=trim($sock->GET_INFO("SessionPathInMemory"));
	$php5FuncOverloadSeven=Field_checkbox("php5FuncOverloadSeven$t",1,$php5FuncOverloadSeven);
	
	
	$DisableMagicQuotesGpc=$sock->GET_INFO("php5DisableMagicQuotesGpc");
	$DisableMagicQuotesGpc=Field_checkbox("php5DisableMagicQuotesGpc$t",1,$DisableMagicQuotesGpc);
	$timezone_def=trim($sock->GET_INFO('timezones'));
	$SSLStrictSNIVHostCheck=$sock->GET_INFO("SSLStrictSNIVHostCheck");
	$SSLStrictSNIVHostCheck=Field_checkbox("SSLStrictSNIVHostCheck$t",1,$SSLStrictSNIVHostCheck);	
	
	$EnableRRDGraphFunction=$sock->GET_INFO("EnableRRDGraphFunction");
	if(!is_numeric($EnableRRDGraphFunction)){$EnableRRDGraphFunction=1;}
	$EnableRRDGraphFunction=Field_checkbox("EnableRRDGraphFunction",1,$EnableRRDGraphFunction,"EnableRRDGraphFunctionCheck()");	
	
	
	
	if(trim($timezone_def)==null){$timezone_def="Europe/Berlin";}	
	if(!is_numeric($php5UploadMaxFileSize)){$php5UploadMaxFileSize=256;}
	if(!is_numeric($php5PostMaxSize)){$php5PostMaxSize=128;}
	if(!is_numeric($php5MemoryLimit)){$php5MemoryLimit=500;}
	if(!is_numeric($SessionPathInMemory)){$SessionPathInMemory=0;}
	
	
	
	$timezone=timezonearray();
	for($i=0;$i<count($timezone);$i++){
		$array[$timezone[$i]]=$timezone[$i];
	}
	
	
	$html="
	<div id='php5div'></div>
	<table width=99% class=form>
	<tr>
		<td valign='top' class=legend nowrap>{php5FuncOverloadSeven}:</td>
		<td valign='top'>$php5FuncOverloadSeven</td>
		<td width=1%>". help_icon("{php5FuncOverloadSeven_text}")."</td>
	</tr>
	<tr>
		<td valign='top' class=legend nowrap>{DisableMagicQuotesGpc}:</td>
		<td valign='top'>$DisableMagicQuotesGpc</td>
		<td  width=1%>". help_icon("{DisableMagicQuotesGpc_text}")."</td>
	</tr>	
	<tr>
		<td valign='top' class=legend nowrap>{SSLStrictSNIVHostCheck}:</td>
		<td valign='top'>$SSLStrictSNIVHostCheck</td>
		<td  width=1%>". help_icon("{SSLStrictSNIVHostCheck_text}")."</td>
	</tr>	
	<tr>
		<td valign='top' class=legend nowrap>{EnableRRDGraphFunction}:</td>
		<td valign='top'>$EnableRRDGraphFunction</td>
		<td  width=1%>&nbsp;</td>
	</tr>	
	<tr>
		<td valign='top' class=legend nowrap>Default charset:</td>
		<td valign='top'>".Field_array_Hash(Charsets(),"php5DefaultCharset$t",$php5DefaultCharset,null,null,"style:font-size:14px;padding:3px")."</td>
		<td  width=1%>&nbsp;</td>
	</tr>
	<tr>
		<td valign='top' class=legend nowrap>{timezone}:</td>
		<td valign='top'>".Field_array_Hash($array,"timezones$t",$timezone_def,null,null,"style:font-size:14px;padding:3px")."</td>
		<td  width=1%>&nbsp;</td>
	</tr>	
	
	<tr>
		<td valign='top' class=legend nowrap>{php5UploadMaxFileSize}:</td>
		<td valign='top' style='font-size:14px;'>".Field_text("php5UploadMaxFileSize$t",$php5UploadMaxFileSize,"font-size:14px;padding:3px;width:60px")."&nbsp;MB</td>
		<td  width=1%>&nbsp;</td>
	</tr>	
	
	
	
	<tr>
		<td valign='top' class=legend nowrap>{php5PostMaxSize}:</td>
		<td valign='top' style='font-size:14px;'>".Field_text("php5PostMaxSize$t",$php5PostMaxSize,"font-size:14px;padding:3px;width:60px")."&nbsp;MB</td>
		<td  width=1%>&nbsp;</td>
	</tr>
	<tr>
		<td valign='top' class=legend nowrap>{php5MemoryLimit}:</td>
		<td valign='top' style='font-size:14px;'>".Field_text("php5MemoryLimit$t",$php5MemoryLimit,"font-size:14px;padding:3px;width:60px")."&nbsp;MB</td>
		<td  width=1%>&nbsp;</td>
	</tr>
	<tr>
		<td valign='top' class=legend nowrap>{SessionPathInMemory}:</td>
		<td valign='top' style='font-size:14px;'>".Field_text("SessionPathInMemory$t",$SessionPathInMemory,"font-size:14px;padding:3px;width:60px")."&nbsp;MB</td>
		<td  width=1%>". help_icon("{SessionPathInMemory_explain}")."</td>
	</tr>			
	<tr>
		<td colspan=3 align='right'>
		<hr>". button('{edit}',"SavePHP5AdvancedSettings$t()",16)."
		
		</td>
	</tr> 
	</table>
	
	<script>
	function SavePHP5AdvancedSettings$t(){
    	var XHR = new XHRConnection();
    	var php5DisableMagicQuotesGpc='';
    	var SSLStrictSNIVHostCheck='';
    	var EnableRRDGraphFunction=1;
    	if(document.getElementById('php5DisableMagicQuotesGpc$t').checked){php5DisableMagicQuotesGpc=1;}else{php5DisableMagicQuotesGpc=0;}
		if(document.getElementById('php5FuncOverloadSeven$t').checked){php5FuncOverloadSeven=1;}else{php5FuncOverloadSeven=0;}
		if(document.getElementById('SSLStrictSNIVHostCheck$t').checked){SSLStrictSNIVHostCheck=1;}else{SSLStrictSNIVHostCheck=0;}
		if(document.getElementById('EnableRRDGraphFunction').checked){EnableRRDGraphFunction=1;}else{EnableRRDGraphFunction=0;}
		XHR.appendData('php5DefaultCharset',document.getElementById('php5DefaultCharset$t').value);
		XHR.appendData('php5UploadMaxFileSize',document.getElementById('php5UploadMaxFileSize$t').value);
		XHR.appendData('php5PostMaxSize',document.getElementById('php5PostMaxSize$t').value);
		XHR.appendData('php5MemoryLimit',document.getElementById('php5MemoryLimit$t').value);
		XHR.appendData('php5DisableMagicQuotesGpc',php5DisableMagicQuotesGpc);
		XHR.appendData('php5FuncOverloadSeven',php5FuncOverloadSeven);				
		XHR.appendData('SSLStrictSNIVHostCheck',SSLStrictSNIVHostCheck);
		XHR.appendData('EnableRRDGraphFunction',EnableRRDGraphFunction);
		XHR.appendData('timezones',document.getElementById('timezones$t').value);
		XHR.appendData('SessionPathInMemory',document.getElementById('SessionPathInMemory$t').value);
		
		AnimateDiv('php5div');
    	XHR.sendAndLoad('$page', 'POST',x_SavePHP5AdvancedSettings);
	}
	
	var x_EnableRRDGraphFunctionCheck=function (obj) {
		var results=obj.responseText;
		if(results.length>2){alert(results);}
		document.getElementById('php5div').innerHTML='';
		}		
	
	function EnableRRDGraphFunctionCheck(){
		var EnableRRDGraphFunction=0;
		if(document.getElementById('EnableRRDGraphFunction').checked){EnableRRDGraphFunction=1;}
		var XHR = new XHRConnection();
		AnimateDiv('php5div');
		XHR.appendData('unik-EnableRRDGraphFunction',EnableRRDGraphFunction);
		XHR.sendAndLoad('$page', 'POST',x_EnableRRDGraphFunctionCheck);
	
	}
	
	
	</script>	
";
	
	$tpl=new templates();
	echo $tpl->_ENGINE_parse_body($html);
	
}

function timezonearray(){
	
$timezone[]="Africa/Abidjan";                 //,0x000000 },
	$timezone[]="Africa/Accra";                   //,0x000055 },
	$timezone[]="Africa/Addis_Ababa";             //,0x0000FD },
	$timezone[]="Africa/Algiers";                 //,0x000153 },
	$timezone[]="Africa/Asmara";                  //,0x00027E },
	$timezone[]="Africa/Asmera";                  //,0x0002D4 },
	$timezone[]="Africa/Bamako";                  //,0x00032A },
	$timezone[]="Africa/Bangui";                  //,0x000395 },
	$timezone[]="Africa/Banjul";                  //,0x0003EA },
	$timezone[]="Africa/Bissau";                  //,0x000461 },
	$timezone[]="Africa/Blantyre";                //,0x0004C7 },
	$timezone[]="Africa/Brazzaville";             //,0x00051C },
	$timezone[]="Africa/Bujumbura";               //,0x000571 },
	$timezone[]="Africa/Cairo";                   //,0x0005B5 },
	$timezone[]="Africa/Casablanca";              //,0x00097C },
	$timezone[]="Africa/Ceuta";                   //,0x000A58 },
	$timezone[]="Africa/Conakry";                 //,0x000D5F },
	$timezone[]="Africa/Dakar";                   //,0x000DCA },
	$timezone[]="Africa/Dar_es_Salaam";           //,0x000E30 },
	$timezone[]="Africa/Djibouti";                //,0x000E9D },
	$timezone[]="Africa/Douala";                  //,0x000EF2 },
	$timezone[]="Africa/El_Aaiun";                //,0x000F47 },
	$timezone[]="Africa/Freetown";                //,0x000FAD },
	$timezone[]="Africa/Gaborone";                //,0x0010BC },
	$timezone[]="Africa/Harare";                  //,0x001117 },
	$timezone[]="Africa/Johannesburg";            //,0x00116C },
	$timezone[]="Africa/Kampala";                 //,0x0011DA },
	$timezone[]="Africa/Khartoum";                //,0x001259 },
	$timezone[]="Africa/Kigali";                  //,0x00136C },
	$timezone[]="Africa/Kinshasa";                //,0x0013C1 },
	$timezone[]="Africa/Lagos";                   //,0x00141C },
	$timezone[]="Africa/Libreville";              //,0x001471 },
	$timezone[]="Africa/Lome";                    //,0x0014C6 },
	$timezone[]="Africa/Luanda";                  //,0x00150A },
	$timezone[]="Africa/Lubumbashi";              //,0x00155F },
	$timezone[]="Africa/Lusaka";                  //,0x0015BA },
	$timezone[]="Africa/Malabo";                  //,0x00160F },
	$timezone[]="Africa/Maputo";                  //,0x001675 },
	$timezone[]="Africa/Maseru";                  //,0x0016CA },
	$timezone[]="Africa/Mbabane";                 //,0x001732 },
	$timezone[]="Africa/Mogadishu";               //,0x001788 },
	$timezone[]="Africa/Monrovia";                //,0x0017E3 },
	$timezone[]="Africa/Nairobi";                 //,0x001849 },
	$timezone[]="Africa/Ndjamena";                //,0x0018C8 },
	$timezone[]="Africa/Niamey";                  //,0x001934 },
	$timezone[]="Africa/Nouakchott";              //,0x0019A7 },
	$timezone[]="Africa/Ouagadougou";             //,0x001A12 },
	$timezone[]="Africa/Porto-Novo";              //,0x001A67 },
	$timezone[]="Africa/Sao_Tome";                //,0x001ACD },
	$timezone[]="Africa/Timbuktu";                //,0x001B22 },
	$timezone[]="Africa/Tripoli";                 //,0x001B8D },
	$timezone[]="Africa/Tunis";                   //,0x001C87 },
	$timezone[]="Africa/Windhoek";                //,0x001EB1 },
	$timezone[]="America/Adak";                   //,0x0020F8 },
	$timezone[]="America/Anchorage";              //,0x00246E },
	$timezone[]="America/Anguilla";               //,0x0027E2 },
	$timezone[]="America/Antigua";                //,0x002837 },
	$timezone[]="America/Araguaina";              //,0x00289D },
	$timezone[]="America/Argentina/Buenos_Aires"; //,0x0029F8 },
	$timezone[]="America/Argentina/Catamarca";    //,0x002BA6 },
	$timezone[]="America/Argentina/ComodRivadavia";  //,0x002D67 },
	$timezone[]="America/Argentina/Cordoba";      //,0x002F0D },
	$timezone[]="America/Argentina/Jujuy";        //,0x0030E2 },
	$timezone[]="America/Argentina/La_Rioja";     //,0x003296 },
	$timezone[]="America/Argentina/Mendoza";      //,0x00344E },
	$timezone[]="America/Argentina/Rio_Gallegos"; //,0x00360E },
	$timezone[]="America/Argentina/Salta";        //,0x0037C3 },
	$timezone[]="America/Argentina/San_Juan";     //,0x00396F },
	$timezone[]="America/Argentina/San_Luis";     //,0x003B27 },
	$timezone[]="America/Argentina/Tucuman";      //,0x003E05 },
	$timezone[]="America/Argentina/Ushuaia";      //,0x003FC1 },
	$timezone[]="America/Aruba";                  //,0x00417C },
	$timezone[]="America/Asuncion";               //,0x0041E2 },
	$timezone[]="America/Atikokan";               //,0x0044C7 },
	$timezone[]="America/Atka";                   //,0x00459D },
	$timezone[]="America/Bahia";                  //,0x004903 },
	$timezone[]="America/Barbados";               //,0x004A8C },
	$timezone[]="America/Belem";                  //,0x004B26 },
	$timezone[]="America/Belize";                 //,0x004C21 },
	$timezone[]="America/Blanc-Sablon";           //,0x004D9D },
	$timezone[]="America/Boa_Vista";              //,0x004E51 },
	$timezone[]="America/Bogota";                 //,0x004F5A },
	$timezone[]="America/Boise";                  //,0x004FC6 },
	$timezone[]="America/Buenos_Aires";           //,0x00535D },
	$timezone[]="America/Cambridge_Bay";          //,0x0054F6 },
	$timezone[]="America/Campo_Grande";           //,0x00581E },
	$timezone[]="America/Cancun";                 //,0x005B0D },
	$timezone[]="America/Caracas";                //,0x005D4F },
	$timezone[]="America/Catamarca";              //,0x005DB6 },
	$timezone[]="America/Cayenne";                //,0x005F5C },
	$timezone[]="America/Cayman";                 //,0x005FBE },
	$timezone[]="America/Chicago";                //,0x006013 },
	$timezone[]="America/Chihuahua";              //,0x00652A },
	$timezone[]="America/Coral_Harbour";          //,0x006779 },
	$timezone[]="America/Cordoba";                //,0x00680B },
	$timezone[]="America/Costa_Rica";             //,0x0069B1 },
	$timezone[]="America/Cuiaba";                 //,0x006A3B },
	$timezone[]="America/Curacao";                //,0x006D19 },
	$timezone[]="America/Danmarkshavn";           //,0x006D7F },
	$timezone[]="America/Dawson";                 //,0x006EC3 },
	$timezone[]="America/Dawson_Creek";           //,0x0071E0 },
	$timezone[]="America/Denver";                 //,0x0073BA },
	$timezone[]="America/Detroit";                //,0x007740 },
	$timezone[]="America/Dominica";               //,0x007A9F },
	$timezone[]="America/Edmonton";               //,0x007AF4 },
	$timezone[]="America/Eirunepe";               //,0x007EAC },
	$timezone[]="America/El_Salvador";            //,0x007FBF },
	$timezone[]="America/Ensenada";               //,0x008034 },
	$timezone[]="America/Fort_Wayne";             //,0x0084DB },
	$timezone[]="America/Fortaleza";              //,0x00839D },
	$timezone[]="America/Glace_Bay";              //,0x008745 },
	$timezone[]="America/Godthab";                //,0x008ABC },
	$timezone[]="America/Goose_Bay";              //,0x008D80 },
	$timezone[]="America/Grand_Turk";             //,0x00923D },
	$timezone[]="America/Grenada";                //,0x0094EC },
	$timezone[]="America/Guadeloupe";             //,0x009541 },
	$timezone[]="America/Guatemala";              //,0x009596 },
	$timezone[]="America/Guayaquil";              //,0x00961F },
	$timezone[]="America/Guyana";                 //,0x00967C },
	$timezone[]="America/Halifax";                //,0x0096FD },
	$timezone[]="America/Havana";                 //,0x009C13 },
	$timezone[]="America/Hermosillo";             //,0x009F86 },
	$timezone[]="America/Indiana/Indianapolis";   //,0x00A064 },
	$timezone[]="America/Indiana/Knox";           //,0x00A2F5 },
	$timezone[]="America/Indiana/Marengo";        //,0x00A68C },
	$timezone[]="America/Indiana/Petersburg";     //,0x00A932 },
	$timezone[]="America/Indiana/Tell_City";      //,0x00AE7F },
	$timezone[]="America/Indiana/Vevay";          //,0x00B118 },
	$timezone[]="America/Indiana/Vincennes";      //,0x00B353 },
	$timezone[]="America/Indiana/Winamac";        //,0x00B607 },
	$timezone[]="America/Indianapolis";           //,0x00AC15 },
	$timezone[]="America/Inuvik";                 //,0x00B8C0 },
	$timezone[]="America/Iqaluit";                //,0x00BBB7 },
	$timezone[]="America/Jamaica";                //,0x00BED9 },
	$timezone[]="America/Jujuy";                  //,0x00BF9E },
	$timezone[]="America/Juneau";                 //,0x00C148 },
	$timezone[]="America/Kentucky/Louisville";    //,0x00C4C6 },
	$timezone[]="America/Kentucky/Monticello";    //,0x00C8E4 },
	$timezone[]="America/Knox_IN";                //,0x00CC69 },
	$timezone[]="America/La_Paz";                 //,0x00CFDA },
	$timezone[]="America/Lima";                   //,0x00D041 },
	$timezone[]="America/Los_Angeles";            //,0x00D0E9 },
	$timezone[]="America/Louisville";             //,0x00D4FA },
	$timezone[]="America/Maceio";                 //,0x00D8EF },
	$timezone[]="America/Managua";                //,0x00DA29 },
	$timezone[]="America/Manaus";                 //,0x00DADC },
	$timezone[]="America/Marigot";                //,0x00DBDE },
	$timezone[]="America/Martinique";             //,0x00DC33 },
	$timezone[]="America/Mazatlan";               //,0x00DC9F },
	$timezone[]="America/Mendoza";                //,0x00DF0C },
	$timezone[]="America/Menominee";              //,0x00E0C0 },
	$timezone[]="America/Merida";                 //,0x00E441 },
	$timezone[]="America/Mexico_City";            //,0x00E67C },
	$timezone[]="America/Miquelon";               //,0x00E8F7 },
	$timezone[]="America/Moncton";                //,0x00EB69 },
	$timezone[]="America/Monterrey";              //,0x00F000 },
	$timezone[]="America/Montevideo";             //,0x00F247 },
	$timezone[]="America/Montreal";               //,0x00F559 },
	$timezone[]="America/Montserrat";             //,0x00FA6F },
	$timezone[]="America/Nassau";                 //,0x00FAC4 },
	$timezone[]="America/New_York";               //,0x00FE09 },
	$timezone[]="America/Nipigon";                //,0x010314 },
	$timezone[]="America/Nome";                   //,0x010665 },
	$timezone[]="America/Noronha";                //,0x0109E3 },
	$timezone[]="America/North_Dakota/Center";    //,0x010B13 },
	$timezone[]="America/North_Dakota/New_Salem"; //,0x010EA7 },
	$timezone[]="America/Panama";                 //,0x011250 },
	$timezone[]="America/Pangnirtung";            //,0x0112A5 },
	$timezone[]="America/Paramaribo";             //,0x0115DB },
	$timezone[]="America/Phoenix";                //,0x01166D },
	$timezone[]="America/Port-au-Prince";         //,0x01171B },
	$timezone[]="America/Port_of_Spain";          //,0x011936 },
	$timezone[]="America/Porto_Acre";             //,0x011837 },
	$timezone[]="America/Porto_Velho";            //,0x01198B },
	$timezone[]="America/Puerto_Rico";            //,0x011A81 },
	$timezone[]="America/Rainy_River";            //,0x011AEC },
	$timezone[]="America/Rankin_Inlet";           //,0x011E24 },
	$timezone[]="America/Recife";                 //,0x01210A },
	$timezone[]="America/Regina";                 //,0x012234 },
	$timezone[]="America/Resolute";               //,0x0123F2 },
	$timezone[]="America/Rio_Branco";             //,0x0126EB },
	$timezone[]="America/Rosario";                //,0x0127EE },
	$timezone[]="America/Santarem";               //,0x012994 },
	$timezone[]="America/Santiago";               //,0x012A99 },
	$timezone[]="America/Santo_Domingo";          //,0x012E42 },
	$timezone[]="America/Sao_Paulo";              //,0x012F08 },
	$timezone[]="America/Scoresbysund";           //,0x013217 },
	$timezone[]="America/Shiprock";               //,0x013505 },
	$timezone[]="America/St_Barthelemy";          //,0x013894 },
	$timezone[]="America/St_Johns";               //,0x0138E9 },
	$timezone[]="America/St_Kitts";               //,0x013E3C },
	$timezone[]="America/St_Lucia";               //,0x013E91 },
	$timezone[]="America/St_Thomas";              //,0x013EE6 },
	$timezone[]="America/St_Vincent";             //,0x013F3B },
	$timezone[]="America/Swift_Current";          //,0x013F90 },
	$timezone[]="America/Tegucigalpa";            //,0x0140B1 },
	$timezone[]="America/Thule";                  //,0x014130 },
	$timezone[]="America/Thunder_Bay";            //,0x014377 },
	$timezone[]="America/Tijuana";                //,0x0146C0 },
	$timezone[]="America/Toronto";                //,0x014A35 },
	$timezone[]="America/Tortola";                //,0x014F4C },
	$timezone[]="America/Vancouver";              //,0x014FA1 },
	$timezone[]="America/Virgin";                 //,0x0153DE },
	$timezone[]="America/Whitehorse";             //,0x015433 },
	$timezone[]="America/Winnipeg";               //,0x015750 },
	$timezone[]="America/Yakutat";                //,0x015B90 },
	$timezone[]="America/Yellowknife";            //,0x015EFB },
	$timezone[]="Antarctica/Casey";               //,0x01620B },
	$timezone[]="Antarctica/Davis";               //,0x016291 },
	$timezone[]="Antarctica/DumontDUrville";      //,0x01631B },
	$timezone[]="Antarctica/Mawson";              //,0x0163AD },
	$timezone[]="Antarctica/McMurdo";             //,0x016429 },
	$timezone[]="Antarctica/Palmer";              //,0x01672B },
	$timezone[]="Antarctica/Rothera";             //,0x016A47 },
	$timezone[]="Antarctica/South_Pole";          //,0x016ABD },
	$timezone[]="Antarctica/Syowa";               //,0x016DC5 },
	$timezone[]="Antarctica/Vostok";              //,0x016E33 },
	$timezone[]="Arctic/Longyearbyen";            //,0x016EA8 },
	$timezone[]="Asia/Aden";                      //,0x0171DA },
	$timezone[]="Asia/Almaty";                    //,0x01722F },
	$timezone[]="Asia/Amman";                     //,0x0173AE },
	$timezone[]="Asia/Anadyr";                    //,0x01766E },
	$timezone[]="Asia/Aqtau";                     //,0x01795C },
	$timezone[]="Asia/Aqtobe";                    //,0x017B5B },
	$timezone[]="Asia/Ashgabat";                  //,0x017D13 },
	$timezone[]="Asia/Ashkhabad";                 //,0x017E30 },
	$timezone[]="Asia/Baghdad";                   //,0x017F4D },
	$timezone[]="Asia/Bahrain";                   //,0x0180C2 },
	$timezone[]="Asia/Baku";                      //,0x018128 },
	$timezone[]="Asia/Bangkok";                   //,0x018410 },
	$timezone[]="Asia/Beirut";                    //,0x018465 },
	$timezone[]="Asia/Bishkek";                   //,0x018772 },
	$timezone[]="Asia/Brunei";                    //,0x01891E },
	$timezone[]="Asia/Calcutta";                  //,0x018980 },
	$timezone[]="Asia/Choibalsan";                //,0x0189F9 },
	$timezone[]="Asia/Chongqing";                 //,0x018B72 },
	$timezone[]="Asia/Chungking";                 //,0x018C61 },
	$timezone[]="Asia/Colombo";                   //,0x018D10 },
	$timezone[]="Asia/Dacca";                     //,0x018DAC },
	$timezone[]="Asia/Damascus";                  //,0x018E4D },
	$timezone[]="Asia/Dhaka";                     //,0x01919D },
	$timezone[]="Asia/Dili";                      //,0x01923E },
	$timezone[]="Asia/Dubai";                     //,0x0192C7 },
	$timezone[]="Asia/Dushanbe";                  //,0x01931C },
	$timezone[]="Asia/Gaza";                      //,0x01941F },
	$timezone[]="Asia/Harbin";                    //,0x019768 },
	$timezone[]="Asia/Ho_Chi_Minh";               //,0x01984F },
	$timezone[]="Asia/Hong_Kong";                 //,0x0198C7 },
	$timezone[]="Asia/Hovd";                      //,0x019A93 },
	$timezone[]="Asia/Irkutsk";                   //,0x019C0B },
	$timezone[]="Asia/Istanbul";                  //,0x019EF2 },
	$timezone[]="Asia/Jakarta";                   //,0x01A2DF },
	$timezone[]="Asia/Jayapura";                  //,0x01A389 },
	$timezone[]="Asia/Jerusalem";                 //,0x01A40D },
	$timezone[]="Asia/Kabul";                     //,0x01A73C },
	$timezone[]="Asia/Kamchatka";                 //,0x01A78D },
	$timezone[]="Asia/Karachi";                   //,0x01AA72 },
	$timezone[]="Asia/Kashgar";                   //,0x01AC3F },
	$timezone[]="Asia/Kathmandu";                 //,0x01AD10 },
	$timezone[]="Asia/Katmandu";                  //,0x01AD76 },
	$timezone[]="Asia/Kolkata";                   //,0x01ADDC },
	$timezone[]="Asia/Krasnoyarsk";               //,0x01AE55 },
	$timezone[]="Asia/Kuala_Lumpur";              //,0x01B13E },
	$timezone[]="Asia/Kuching";                   //,0x01B1FB },
	$timezone[]="Asia/Kuwait";                    //,0x01B2E9 },
	$timezone[]="Asia/Macao";                     //,0x01B33E },
	$timezone[]="Asia/Macau";                     //,0x01B479 },
	$timezone[]="Asia/Magadan";                   //,0x01B5B4 },
	$timezone[]="Asia/Makassar";                  //,0x01B897 },
	$timezone[]="Asia/Manila";                    //,0x01B950 },
	$timezone[]="Asia/Muscat";                    //,0x01B9D5 },
	$timezone[]="Asia/Nicosia";                   //,0x01BA2A },
	$timezone[]="Asia/Novokuznetsk";              //,0x01BD12 },
	$timezone[]="Asia/Novosibirsk";               //,0x01C015 },
	$timezone[]="Asia/Omsk";                      //,0x01C309 },
	$timezone[]="Asia/Oral";                      //,0x01C5F1 },
	$timezone[]="Asia/Phnom_Penh";                //,0x01C7C1 },
	$timezone[]="Asia/Pontianak";                 //,0x01C839 },
	$timezone[]="Asia/Pyongyang";                 //,0x01C8FA },
	$timezone[]="Asia/Qatar";                     //,0x01C967 },
	$timezone[]="Asia/Qyzylorda";                 //,0x01C9CD },
	$timezone[]="Asia/Rangoon";                   //,0x01CBA3 },
	$timezone[]="Asia/Riyadh";                    //,0x01CC1B },
	$timezone[]="Asia/Saigon";                    //,0x01CC70 },
	$timezone[]="Asia/Sakhalin";                  //,0x01CCE8 },
	$timezone[]="Asia/Samarkand";                 //,0x01CFE8 },
	$timezone[]="Asia/Seoul";                     //,0x01D11E },
	$timezone[]="Asia/Shanghai";                  //,0x01D1C2 },
	$timezone[]="Asia/Singapore";                 //,0x01D2A2 },
	$timezone[]="Asia/Taipei";                    //,0x01D359 },
	$timezone[]="Asia/Tashkent";                  //,0x01D471 },
	$timezone[]="Asia/Tbilisi";                   //,0x01D5A2 },
	$timezone[]="Asia/Tehran";                    //,0x01D75C },
	$timezone[]="Asia/Tel_Aviv";                  //,0x01D9CA },
	$timezone[]="Asia/Thimbu";                    //,0x01DCF9 },
	$timezone[]="Asia/Thimphu";                   //,0x01DD5F },
	$timezone[]="Asia/Tokyo";                     //,0x01DDC5 },
	$timezone[]="Asia/Ujung_Pandang";             //,0x01DE4E },
	$timezone[]="Asia/Ulaanbaatar";               //,0x01DECA },
	$timezone[]="Asia/Ulan_Bator";                //,0x01E025 },
	$timezone[]="Asia/Urumqi";                    //,0x01E172 },
	$timezone[]="Asia/Vientiane";                 //,0x01E239 },
	$timezone[]="Asia/Vladivostok";               //,0x01E2B1 },
	$timezone[]="Asia/Yakutsk";                   //,0x01E59E },
	$timezone[]="Asia/Yekaterinburg";             //,0x01E884 },
	$timezone[]="Asia/Yerevan";                   //,0x01EB90 },
	$timezone[]="Atlantic/Azores";                //,0x01EE94 },
	$timezone[]="Atlantic/Bermuda";               //,0x01F397 },
	$timezone[]="Atlantic/Canary";                //,0x01F678 },
	$timezone[]="Atlantic/Cape_Verde";            //,0x01F94E },
	$timezone[]="Atlantic/Faeroe";                //,0x01F9C7 },
	$timezone[]="Atlantic/Faroe";                 //,0x01FC6B },
	$timezone[]="Atlantic/Jan_Mayen";             //,0x01FF0F },
	$timezone[]="Atlantic/Madeira";               //,0x020241 },
	$timezone[]="Atlantic/Reykjavik";             //,0x02074A },
	$timezone[]="Atlantic/South_Georgia";         //,0x020903 },
	$timezone[]="Atlantic/St_Helena";             //,0x020C1B },
	$timezone[]="Atlantic/Stanley";               //,0x020947 },
	$timezone[]="Australia/ACT";                  //,0x020C70 },
	$timezone[]="Australia/Adelaide";             //,0x020F8D },
	$timezone[]="Australia/Brisbane";             //,0x0212B9 },
	$timezone[]="Australia/Broken_Hill";          //,0x021380 },
	$timezone[]="Australia/Canberra";             //,0x0216BE },
	$timezone[]="Australia/Currie";               //,0x0219DB },
	$timezone[]="Australia/Darwin";               //,0x021D0E },
	$timezone[]="Australia/Eucla";                //,0x021D94 },
	$timezone[]="Australia/Hobart";               //,0x021E69 },
	$timezone[]="Australia/LHI";                  //,0x0221C7 },
	$timezone[]="Australia/Lindeman";             //,0x022462 },
	$timezone[]="Australia/Lord_Howe";            //,0x022543 },
	$timezone[]="Australia/Melbourne";            //,0x0227EE },
	$timezone[]="Australia/North";                //,0x022B13 },
	$timezone[]="Australia/NSW";                  //,0x022B87 },
	$timezone[]="Australia/Perth";                //,0x022EA4 },
	$timezone[]="Australia/Queensland";           //,0x022F7C },
	$timezone[]="Australia/South";                //,0x023028 },
	$timezone[]="Australia/Sydney";               //,0x023345 },
	$timezone[]="Australia/Tasmania";             //,0x023682 },
	$timezone[]="Australia/Victoria";             //,0x0239C7 },
	$timezone[]="Australia/West";                 //,0x023CE4 },
	$timezone[]="Australia/Yancowinna";           //,0x023D9A },
	$timezone[]="Brazil/Acre";                    //,0x0240BC },
	$timezone[]="Brazil/DeNoronha";               //,0x0241BB },
	$timezone[]="Brazil/East";                    //,0x0242DB },
	$timezone[]="Brazil/West";                    //,0x0245B8 },
	$timezone[]="Canada/Atlantic";                //,0x0246B0 },
	$timezone[]="Canada/Central";                 //,0x024B98 },
	$timezone[]="Canada/East-Saskatchewan";       //,0x0254A2 },
	$timezone[]="Canada/Eastern";                 //,0x024FB2 },
	$timezone[]="Canada/Mountain";                //,0x02562B },
	$timezone[]="Canada/Newfoundland";            //,0x0259A1 },
	$timezone[]="Canada/Pacific";                 //,0x025ECC },
	$timezone[]="Canada/Saskatchewan";            //,0x0262E5 },
	$timezone[]="Canada/Yukon";                   //,0x02646E },
	$timezone[]="CET";                            //,0x026771 },
	$timezone[]="Chile/Continental";              //,0x026A7A },
	$timezone[]="Chile/EasterIsland";             //,0x026E15 },
	$timezone[]="CST6CDT";                        //,0x027157 },
	$timezone[]="Cuba";                           //,0x0274A8 },
	$timezone[]="EET";                            //,0x02781B },
	$timezone[]="Egypt";                          //,0x027ACE },
	$timezone[]="Eire";                           //,0x027E95 },
	$timezone[]="EST";                            //,0x0283A6 },
	$timezone[]="EST5EDT";                        //,0x0283EA },
	$timezone[]="Etc/GMT";                        //,0x02873B },
	$timezone[]="Etc/GMT+0";                      //,0x028807 },
	$timezone[]="Etc/GMT+1";                      //,0x028891 },
	$timezone[]="Etc/GMT+10";                     //,0x02891E },
	$timezone[]="Etc/GMT+11";                     //,0x0289AC },
	$timezone[]="Etc/GMT+12";                     //,0x028A3A },
	$timezone[]="Etc/GMT+2";                      //,0x028B55 },
	$timezone[]="Etc/GMT+3";                      //,0x028BE1 },
	$timezone[]="Etc/GMT+4";                      //,0x028C6D },
	$timezone[]="Etc/GMT+5";                      //,0x028CF9 },
	$timezone[]="Etc/GMT+6";                      //,0x028D85 },
	$timezone[]="Etc/GMT+7";                      //,0x028E11 },
	$timezone[]="Etc/GMT+8";                      //,0x028E9D },
	$timezone[]="Etc/GMT+9";                      //,0x028F29 },
	$timezone[]="Etc/GMT-0";                      //,0x0287C3 },
	$timezone[]="Etc/GMT-1";                      //,0x02884B },
	$timezone[]="Etc/GMT-10";                     //,0x0288D7 },
	$timezone[]="Etc/GMT-11";                     //,0x028965 },
	$timezone[]="Etc/GMT-12";                     //,0x0289F3 },
	$timezone[]="Etc/GMT-13";                     //,0x028A81 },
	$timezone[]="Etc/GMT-14";                     //,0x028AC8 },
	$timezone[]="Etc/GMT-2";                      //,0x028B0F },
	$timezone[]="Etc/GMT-3";                      //,0x028B9B },
	$timezone[]="Etc/GMT-4";                      //,0x028C27 },
	$timezone[]="Etc/GMT-5";                      //,0x028CB3 },
	$timezone[]="Etc/GMT-6";                      //,0x028D3F },
	$timezone[]="Etc/GMT-7";                      //,0x028DCB },
	$timezone[]="Etc/GMT-8";                      //,0x028E57 },
	$timezone[]="Etc/GMT-9";                      //,0x028EE3 },
	$timezone[]="Etc/GMT0";                       //,0x02877F },
	$timezone[]="Etc/Greenwich";                  //,0x028F6F },
	$timezone[]="Etc/UCT";                        //,0x028FB3 },
	$timezone[]="Etc/Universal";                  //,0x028FF7 },
	$timezone[]="Etc/UTC";                        //,0x02903B },
	$timezone[]="Etc/Zulu";                       //,0x02907F },
	$timezone[]="Europe/Amsterdam";               //,0x0290C3 },
	$timezone[]="Europe/Andorra";                 //,0x029501 },
	$timezone[]="Europe/Athens";                  //,0x02977D },
	$timezone[]="Europe/Belfast";                 //,0x029AC0 },
	$timezone[]="Europe/Belgrade";                //,0x029FF7 },
	$timezone[]="Europe/Berlin";                  //,0x02A2C0 },
	$timezone[]="Europe/Bratislava";              //,0x02A616 },
	$timezone[]="Europe/Brussels";                //,0x02A948 },
	$timezone[]="Europe/Bucharest";               //,0x02AD7F },
	$timezone[]="Europe/Budapest";                //,0x02B0A9 },
	$timezone[]="Europe/Chisinau";                //,0x02B41C },
	$timezone[]="Europe/Copenhagen";              //,0x02B7AA },
	$timezone[]="Europe/Dublin";                  //,0x02BAB4 },
	$timezone[]="Europe/Gibraltar";               //,0x02BFC5 },
	$timezone[]="Europe/Guernsey";                //,0x02C41C },
	$timezone[]="Europe/Helsinki";                //,0x02C953 },
	$timezone[]="Europe/Isle_of_Man";             //,0x02CC09 },
	$timezone[]="Europe/Istanbul";                //,0x02D140 },
	$timezone[]="Europe/Jersey";                  //,0x02D52D },
	$timezone[]="Europe/Kaliningrad";             //,0x02DA64 },
	$timezone[]="Europe/Kiev";                    //,0x02DDC7 },
	$timezone[]="Europe/Lisbon";                  //,0x02E0DE },
	$timezone[]="Europe/Ljubljana";               //,0x02E5E2 },
	$timezone[]="Europe/London";                  //,0x02E8AB },
	$timezone[]="Europe/Luxembourg";              //,0x02EDE2 },
	$timezone[]="Europe/Madrid";                  //,0x02F238 },
	$timezone[]="Europe/Malta";                   //,0x02F5FE },
	$timezone[]="Europe/Mariehamn";               //,0x02F9B7 },
	$timezone[]="Europe/Minsk";                   //,0x02FC6D },
	$timezone[]="Europe/Monaco";                  //,0x02FF78 },
	$timezone[]="Europe/Moscow";                  //,0x0303B3 },
	$timezone[]="Europe/Nicosia";                 //,0x030705 },
	$timezone[]="Europe/Oslo";                    //,0x0309ED },
	$timezone[]="Europe/Paris";                   //,0x030D1F },
	$timezone[]="Europe/Podgorica";               //,0x031165 },
	$timezone[]="Europe/Prague";                  //,0x03142E },
	$timezone[]="Europe/Riga";                    //,0x031760 },
	$timezone[]="Europe/Rome";                    //,0x031AA5 },
	$timezone[]="Europe/Samara";                  //,0x031E68 },
	$timezone[]="Europe/San_Marino";              //,0x032194 },
	$timezone[]="Europe/Sarajevo";                //,0x032557 },
	$timezone[]="Europe/Simferopol";              //,0x032820 },
	$timezone[]="Europe/Skopje";                  //,0x032B4B },
	$timezone[]="Europe/Sofia";                   //,0x032E14 },
	$timezone[]="Europe/Stockholm";               //,0x03311C },
	$timezone[]="Europe/Tallinn";                 //,0x0333CB },
	$timezone[]="Europe/Tirane";                  //,0x033705 },
	$timezone[]="Europe/Tiraspol";                //,0x033A0B },
	$timezone[]="Europe/Uzhgorod";                //,0x033D99 },
	$timezone[]="Europe/Vaduz";                   //,0x0340B0 },
	$timezone[]="Europe/Vatican";                 //,0x034343 },
	$timezone[]="Europe/Vienna";                  //,0x034706 },
	$timezone[]="Europe/Vilnius";                 //,0x034A33 },
	$timezone[]="Europe/Volgograd";               //,0x034D72 },
	$timezone[]="Europe/Warsaw";                  //,0x03507B },
	$timezone[]="Europe/Zagreb";                  //,0x03545C },
	$timezone[]="Europe/Zaporozhye";              //,0x035725 },
	$timezone[]="Europe/Zurich";                  //,0x035A66 },
	$timezone[]="Factory";                        //,0x035D15 },
	$timezone[]="GB";                             //,0x035D86 },
	$timezone[]="GB-Eire";                        //,0x0362BD },
	$timezone[]="GMT";                            //,0x0367F4 },
	$timezone[]="GMT+0";                          //,0x0368C0 },
	$timezone[]="GMT-0";                          //,0x03687C },
	$timezone[]="GMT0";                           //,0x036838 },
	$timezone[]="Greenwich";                      //,0x036904 },
	$timezone[]="Hongkong";                       //,0x036948 },
	$timezone[]="HST";                            //,0x036B14 },
	$timezone[]="Iceland";                        //,0x036B58 },
	$timezone[]="Indian/Antananarivo";            //,0x036D11 },
	$timezone[]="Indian/Chagos";                  //,0x036D85 },
	$timezone[]="Indian/Christmas";               //,0x036DE7 },
	$timezone[]="Indian/Cocos";                   //,0x036E2B },
	$timezone[]="Indian/Comoro";                  //,0x036E6F },
	$timezone[]="Indian/Kerguelen";               //,0x036EC4 },
	$timezone[]="Indian/Mahe";                    //,0x036F19 },
	$timezone[]="Indian/Maldives";                //,0x036F6E },
	$timezone[]="Indian/Mauritius";               //,0x036FC3 },
	$timezone[]="Indian/Mayotte";                 //,0x037039 },
	$timezone[]="Indian/Reunion";                 //,0x03708E },
	$timezone[]="Iran";                           //,0x0370E3 },
	$timezone[]="Israel";                         //,0x037351 },
	$timezone[]="Jamaica";                        //,0x037680 },
	$timezone[]="Japan";                          //,0x037745 },
	$timezone[]="Kwajalein";                      //,0x0377CE },
	$timezone[]="Libya";                          //,0x037831 },
	$timezone[]="MET";                            //,0x03792B },
	$timezone[]="Mexico/BajaNorte";               //,0x037C34 },
	$timezone[]="Mexico/BajaSur";                 //,0x037F9D },
	$timezone[]="Mexico/General";                 //,0x0381E2 },
	$timezone[]="MST";                            //,0x038440 },
	$timezone[]="MST7MDT";                        //,0x038484 },
	$timezone[]="Navajo";                         //,0x0387D5 },
	$timezone[]="NZ";                             //,0x038B4E },
	$timezone[]="NZ-CHAT";                        //,0x038ECC },
	$timezone[]="Pacific/Apia";                   //,0x0391B4 },
	$timezone[]="Pacific/Auckland";               //,0x039232 },
	$timezone[]="Pacific/Chatham";                //,0x0395BE },
	$timezone[]="Pacific/Easter";                 //,0x0398B5 },
	$timezone[]="Pacific/Efate";                  //,0x039C13 },
	$timezone[]="Pacific/Enderbury";              //,0x039CD9 },
	$timezone[]="Pacific/Fakaofo";                //,0x039D47 },
	$timezone[]="Pacific/Fiji";                   //,0x039D8B },
	$timezone[]="Pacific/Funafuti";               //,0x039E01 },
	$timezone[]="Pacific/Galapagos";              //,0x039E45 },
	$timezone[]="Pacific/Gambier";                //,0x039EBD },
	$timezone[]="Pacific/Guadalcanal";            //,0x039F22 },
	$timezone[]="Pacific/Guam";                   //,0x039F77 },
	$timezone[]="Pacific/Honolulu";               //,0x039FCD },
	$timezone[]="Pacific/Johnston";               //,0x03A061 },
	$timezone[]="Pacific/Kiritimati";             //,0x03A0B3 },
	$timezone[]="Pacific/Kosrae";                 //,0x03A11E },
	$timezone[]="Pacific/Kwajalein";              //,0x03A17B },
	$timezone[]="Pacific/Majuro";                 //,0x03A1E7 },
	$timezone[]="Pacific/Marquesas";              //,0x03A246 },
	$timezone[]="Pacific/Midway";                 //,0x03A2AD },
	$timezone[]="Pacific/Nauru";                  //,0x03A337 },
	$timezone[]="Pacific/Niue";                   //,0x03A3AF },
	$timezone[]="Pacific/Norfolk";                //,0x03A40D },
	$timezone[]="Pacific/Noumea";                 //,0x03A462 },
	$timezone[]="Pacific/Pago_Pago";              //,0x03A4F2 },
	$timezone[]="Pacific/Palau";                  //,0x03A57B },
	$timezone[]="Pacific/Pitcairn";               //,0x03A5BF },
	$timezone[]="Pacific/Ponape";                 //,0x03A614 },
	$timezone[]="Pacific/Port_Moresby";           //,0x03A669 },
	$timezone[]="Pacific/Rarotonga";              //,0x03A6AD },
	$timezone[]="Pacific/Saipan";                 //,0x03A789 },
	$timezone[]="Pacific/Samoa";                  //,0x03A7EC },
	$timezone[]="Pacific/Tahiti";                 //,0x03A875 },
	$timezone[]="Pacific/Tarawa";                 //,0x03A8DA },
	$timezone[]="Pacific/Tongatapu";              //,0x03A92E },
	$timezone[]="Pacific/Truk";                   //,0x03A9BA },
	$timezone[]="Pacific/Wake";                   //,0x03AA13 },
	$timezone[]="Pacific/Wallis";                 //,0x03AA63 },
	$timezone[]="Pacific/Yap";                    //,0x03AAA7 },
	$timezone[]="Poland";                         //,0x03AAEC },
	$timezone[]="Portugal";                       //,0x03AECD },
	$timezone[]="PRC";                            //,0x03B3C9 },
	$timezone[]="PST8PDT";                        //,0x03B47A },
	$timezone[]="ROC";                            //,0x03B7CB },
	$timezone[]="ROK";                            //,0x03B8E3 },
	$timezone[]="Singapore";                      //,0x03B987 },
	$timezone[]="Turkey";                         //,0x03BA3E },
	$timezone[]="UCT";                            //,0x03BE2B },
	$timezone[]="Universal";                      //,0x03BE6F },
	$timezone[]="US/Alaska";                      //,0x03BEB3 },
	$timezone[]="US/Aleutian";                    //,0x03C21C },
	$timezone[]="US/Arizona";                     //,0x03C582 },
	$timezone[]="US/Central";                     //,0x03C610 },
	$timezone[]="US/East-Indiana";                //,0x03D01A },
	$timezone[]="US/Eastern";                     //,0x03CB1B },
	$timezone[]="US/Hawaii";                      //,0x03D284 },
	$timezone[]="US/Indiana-Starke";              //,0x03D312 },
	$timezone[]="US/Michigan";                    //,0x03D683 },
	$timezone[]="US/Mountain";                    //,0x03D9BA },
	$timezone[]="US/Pacific";                     //,0x03DD33 },
	$timezone[]="US/Pacific-New";                 //,0x03E138 },
	$timezone[]="US/Samoa";                       //,0x03E53D },
	$timezone[]="UTC";                            //,0x03E5C6 },
	$timezone[]="W-SU";                           //,0x03E8BD },
	$timezone[]="WET";                            //,0x03E60A },
	$timezone[]="Zulu";                           //,0x03EBF8 },	
	return $timezone;
	
	
}




function parsePHPModules() {
 ob_start();
 phpinfo(INFO_MODULES);
 $s = ob_get_contents();
 ob_end_clean();

 $s = strip_tags($s,'<h2><th><td>');
 $s = preg_replace('/<th[^>]*>([^<]+)<\/th>/',"<info>\\1</info>",$s);
 $s = preg_replace('/<td[^>]*>([^<]+)<\/td>/',"<info>\\1</info>",$s);
 $vTmp = preg_split('/(<h2[^>]*>[^<]+<\/h2>)/',$s,-1,PREG_SPLIT_DELIM_CAPTURE);
 $vModules = array();
 for ($i=1;$i<count($vTmp);$i++) {
  if (preg_match('/<h2[^>]*>([^<]+)<\/h2>/',$vTmp[$i],$vMat)) {
   $vName = trim($vMat[1]);
   $vTmp2 = explode("\n",$vTmp[$i+1]);
   foreach ($vTmp2 AS $vOne) {
   $vPat = '<info>([^<]+)<\/info>';
   $vPat3 = "/$vPat\s*$vPat\s*$vPat/";
   $vPat2 = "/$vPat\s*$vPat/";
   if (preg_match($vPat3,$vOne,$vMat)) { // 3cols
     $vModules[$vName][trim($vMat[1])] = array(trim($vMat[2]),trim($vMat[3]));
   } elseif (preg_match($vPat2,$vOne,$vMat)) { // 2cols
     $vModules[$vName][trim($vMat[1])] = trim($vMat[2]);
   }
   }
  }
 }
 return $vModules;
}

?>