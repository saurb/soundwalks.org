/*
	!red = #bf3030
	!green = #9dbf30
	!light_blue = #a3bfbf
	!very_light_blue = !light_blue / 2 + #999999
	!dark_blue = #223241
	!tan = #efebe6
	!gray = #888888
	!light_gray = #efefef
*/

$(document).ready(function() {
	$(".button").hover(
		function() {$(this).css({'background-color' : '#efefef', 'color' : '#bf3030', 'border' : '1px dashed #888888'});},
		function() {$(this).css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});}
	);
	
	$(".button").mousedown(function() {$(this).css({'background-color' : '#eaf8f8', 'color' : '#bf3030', 'border' : '1px solid #223241'});});
	$(".button").mouseup(function() {$(this).css({'background-color' : '#efefef', 'color' : 'black', 'border' : '1px dashed #888888'});});
});
