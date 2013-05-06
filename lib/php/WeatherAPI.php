<?php

$today= file_get_contents("http://www.weather.com.cn/data/sk/". $_GET['cityno']. ".html");

$week= file_get_contents("http://m.weather.com.cn/data/". $_GET['cityno']. ".html");//获取apijson

$today = json_decode($today,true);

$week = json_decode($week,true);

$weathers = array();

//当天
$weathers['current'] = $today['weatherinfo'];
$weathers['current']['date_y'] = $week['weatherinfo']['date_y'];
unset($weathers['current']['isRadar']);
unset($weathers['current']['Radar']);
unset($weathers['current']['WSE']);
//指数
$weathers['current']['index_chuanyi'] = $week['weatherinfo']['index'];
//$weathers['current']['index48'] = $week['weatherinfo']['index48'];
$weathers['current']['index_uv'] = $week['weatherinfo']['index_uv'];
$weathers['current']['index_xiche'] = $week['weatherinfo']['index_xc'];
$weathers['current']['index_comfort'] = $week['weatherinfo']['index_co'];
//$weathers['current']['index_travel'] = $week['weatherinfo']['index_tr'];
$weathers['current']['index_chenlian'] = $week['weatherinfo']['index_cl']; 
//$weathers['current']['index_liangshai'] = $week['weatherinfo']['index_ls'];
$weathers['current']['index_guomin'] = $week['weatherinfo']['index_ag'];

//6天预报
$forecasts= $week['weatherinfo'];

for($i=1;$i<7;$i++){

$w=array();
$w['temp']= $forecasts['temp'.$i];
$w['weather']= $forecasts['weather'.$i];
$w['img']= $forecasts['img'.($i*2-1)];
$w['wind']= $forecasts['wind'.$i];
  //$w['fl']= $forecasts['fl'.$i];

$weathers['forecasts'][]=$w;
}

echo json_encode($weathers);

?>