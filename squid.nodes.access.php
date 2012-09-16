<?php
	include_once('ressources/class.templates.inc');
	include_once('ressources/class.users.menus.inc');
	include_once('ressources/class.squid.inc');
	include_once('ressources/class.status.inc');
	include_once('ressources/class.artica.graphs.inc');
	include_once('ressources/class.computers.inc');
	$users=new usersMenus();
	if(!$users->AsWebStatisticsAdministrator){die();}
	
	if(isset($_GET["search"])){search();exit;}
	if(isset($_GET["change-day-popup"])){change_day_popup();exit;}
page();	
	
function page(){
	
	$hour_table=date('Ymd')."_hour";
	$q=new mysql_squid_builder();
	$defaultday=$q->HIER();
	
	$page=CurrentPageName();
	$tpl=new templates();
	$webservers=$tpl->_ENGINE_parse_body("{webservers}");
	$hits=$tpl->_ENGINE_parse_body("{hits}");
	$size=$tpl->_ENGINE_parse_body("{size}");
	$time=$tpl->_ENGINE_parse_body("{time}");
	$member=$tpl->_ENGINE_parse_body("{member}");
	$country=$tpl->_ENGINE_parse_body("{country}");
	$url=$tpl->_ENGINE_parse_body("{url}");
	$ipaddr=$tpl->_ENGINE_parse_body("{ipaddr}");
	$hostname=$tpl->_ENGINE_parse_body("{hostname}");
	$title=$tpl->_ENGINE_parse_body("{today}: {requests} {since} ".date("H")."h");
	$change_day=$tpl->_ENGINE_parse_body("{change_day}");
	$t=time();
	$html="
	<input type='hidden' id='daycache$t' value='$defaultday'>
	<div style='margin:-10px;margin-left:-15px'>
	<table class='flexRT$t' style='display: none' id='flexRT$t' style='width:100%'></table>
	</div>
	
<script>
$(document).ready(function(){
$('#flexRT$t').flexigrid({
	url: '$page?search=yes&day=$defaultday&MAC={$_GET["MAC"]}',
	dataType: 'json',
	colModel : [
		{display: '$time', name : 'hour', width :60, sortable : true, align: 'left'},
		{display: '$country', name : 'country', width : 70, sortable : false, align: 'left'},
		{display: '$webservers', name : 'sitename', width : 282, sortable : true, align: 'left'},
		{display: '$size', name : 'size', width : 73, sortable : true, align: 'left'},
		{display: 'hits', name : 'hits', width : 60, sortable : true, align: 'left'}

		],
		
buttons : [
		{name: '$change_day', bclass: 'add', onpress : ChangeDay},
		],			
	
	searchitems : [
		{display: '$webservers', name : 'sitename'},
		],
	sortname: 'hour',
	sortorder: 'desc',
	usepager: true,
	title: '',
	useRp: true,
	rp: 50,
	showTableToggleBtn: false,
	width: 625,
	height: 420,
	singleSelect: true,
	rpOptions: [10, 20, 30, 50,100,200]
	
	});   
});


function ChangeDay(){
	YahooWin6('375','$page?change-day-popup=yes&t=$t&MAC={$_GET["MAC"]}','$change_day');
}

</script>
	
	
	";
	
	echo $html;
}

function change_day_popup(){
	$q=new mysql_squid_builder();	
	$tpl=new templates();
	$t=$_GET["t"];
	$page=CurrentPageName();
	
	$sql="SELECT DATE_FORMAT(zDate,'%Y-%m-%d') as tdate FROM tables_day ORDER BY zDate LIMIT 0,1";
	$ligne=mysql_fetch_array($q->QUERY_SQL($sql));
	$mindate=$ligne["tdate"];

	$sql="SELECT DATE_FORMAT(zDate,'%Y-%m-%d') as tdate FROM tables_day ORDER BY zDate DESC LIMIT 0,1";
	$ligne=mysql_fetch_array($q->QUERY_SQL($sql));
	$maxdate=date('Y-m-d');	
	
	$html="
	<table style='width:99%' class=form>
		<tbody>
		<tr>
			<td class=legend nowrap>{from_date}:</td>
			<td>". field_date("sdate$t",$_GET["day"],"font-size:16px;padding:3px;width:95px","mindate:$mindate;maxdate:$maxdate")."</td>	
			<td>". button("{go}","ChangeDay$t()",18)."</td>
		</tr>
		</tbody>
	</table>	
	<script>
		function ChangeDay$t(){
			var zday=document.getElementById('sdate$t').value;
			document.getElementById('daycache$t').value=zday;
			$('#flexRT$t').flexOptions({url: '$page?search=yes&day='+zday+'&MAC={$_GET["MAC"]}'}).flexReload(); 
		
		}
		document.getElementById('sdate$t').value=document.getElementById('daycache$t').value;
		
	
	</script>
	";
	echo $tpl->_ENGINE_parse_body($html);
}


function search(){
	$Mypage=CurrentPageName();
	$tpl=new templates();		
	$q=new mysql_squid_builder();	
	$t=time();
	$fontsize=13;
	$type=$_GET["type"];
	$field_query="size";
	$field_query2="SUM(size)";	
	$table_field="{size}";
	$category=$tpl->_ENGINE_parse_body("{category}");
	$table=date('Ymd',strtotime($_GET["day"]))."_hour";
	$member=$tpl->_ENGINE_parse_body("{member}");
	$sitename=$tpl->_ENGINE_parse_body("{website}");
	
	$D=date('D',strtotime("{$_GET["day"]} 00:00:00"));
	
	$search='%';
	$page=1;
	$ORDER="ORDER BY ID DESC";
	$FORCE_FILTER=" AND `MAC`='{$_GET["MAC"]}'";	
	
	
	if(isset($_POST["sortname"])){if($_POST["sortname"]<>null){$ORDER="ORDER BY {$_POST["sortname"]} {$_POST["sortorder"]}";}}	
	if(isset($_POST['page'])) {$page = $_POST['page'];}	
	if(isset($_POST['rp'])) {$rp = $_POST['rp'];}

	if($_POST["query"]<>null){
		$_POST["query"]=str_replace("*", "%", $_POST["query"]);
		$search=$_POST["query"];
		$sql="SELECT COUNT(*) as TCOUNT FROM `$table` WHERE 1 $FORCE_FILTER";
		$QUERY="WHERE (`uri` LIKE '$search')";
		$ligne=mysql_fetch_array($q->QUERY_SQL($sql));
		$total = $ligne["TCOUNT"];
		
	}else{
		$sql="SELECT COUNT(*) as TCOUNT FROM `$table` WHERE 1 $FORCE_FILTER ";
		$ligne=mysql_fetch_array($q->QUERY_SQL($sql));
		$total = $ligne["TCOUNT"];
	}	
	
	if (isset($_POST['rp'])) {$rp = $_POST['rp'];}	
	$pageStart = ($page-1)*$rp;
	$limitSql = "LIMIT $pageStart, $rp";
	
	$sql="SELECT* FROM $table WHERE 1 $FORCE_FILTER $ORDER $limitSql";
	$results=$q->QUERY_SQL($sql);
	
	$data = array();
	$data['page'] = 0;
	$data['total'] = $total;
	$data['rows'] = array();	
	

	if(!$q->ok){$data['rows'][] = array('id' => $ligne[time()],'cell' => array($sql,"$q->mysql_error", "",""));echo json_encode($data);return;}	
	if(mysql_num_rows($results)==0){array('id' => $ligne[time()],'cell' => array(null,"", "",""));echo json_encode($data);return;}
	
	$data['total'] = mysql_num_rows($results);
	
	$style="style='font-size:{$fontsize}px'";
	
	while($ligne=@mysql_fetch_array($results,MYSQL_ASSOC)){
		
		$ligne["size"]=FormatBytes($ligne["size"]/1024);
		
		$categorize="Loadjs('squid.categorize.php?www={$ligne["sitename"]}')";
		if(trim($ligne["category"])==null){$ligne["category"]="<span style='color:#D70707'>{categorize_this_website}</span>";}
	
						
		$id=md5(@implode("", $ligne));
		
		if(trim($ligne["uid"])=="-"){$ligne["uid"]=null;}
		if(trim($ligne["uid"])==null){$ligne["uid"]=$q->UID_FROM_MAC($ligne["MAC"]);}
		
		$categorize="<a href=\"javascript:blur()\" 
		OnClick=\"javascript:$categorize\" 
		style='font-size:{$fontsize}px;text-decoration:underline'>";
		
		
		$familysite=$q->GetFamilySites($ligne["sitename"]);
		$TrafficHour="<a href=\"javascript:blur()\" 
		OnClick=\"javascript:Loadjs('squid.traffic.statistics.hours.php?familysite={$ligne["sitename"]}&day={$_GET["day"]}')\" 
		style='font-size:{$fontsize}px;text-decoration:underline'>";
		
 	
		
		$data['rows'][] = array(
			'id' => $id,
			'cell' => array(
			"<span $style>$D&nbsp;{$ligne["hour"]}h</span>",
			"<span $style>{$ligne["country"]}</a></span>",
			"<span $style>{$ligne["sitename"]}</a></span>",
			"<span $style>{$ligne["size"]}</a></span>",
			"<span $style>{$ligne["hits"]}</span>",
			"<span $style>$categorize{$ligne["category"]}</a></span>"
			)
			);		
		
		
	}

echo json_encode($data);	
		
	
}
