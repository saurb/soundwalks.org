package com.kelvinluck.gmaps.example 
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.styles.FillStyle;

	/**
	 * @author kelvinluck
	 * mordified by Jinru Liu
	 */
	public class ExampleClusterMarker extends Marker 
	{

		public function ExampleClusterMarker(cluster:Array, clusterColor:Number, window:AccordionInfoWindow)
		{
			var options:MarkerOptions = new MarkerOptions();
			options.icon = new ExampleClusterMarkerIcon(cluster.length, clusterColor);
			options.hasShadow = false;
			super((cluster[0] as Marker).getLatLng(), options);
			
			super.addEventListener(MapMouseEvent.CLICK, addClusterInfoWindow);
			function addClusterInfoWindow(e:MapMouseEvent):void
			{
				
				var infoWindow:InfoWindowOptions = new InfoWindowOptions({customContent:window, 
       														  		fillStyle: new FillStyle({alpha: 1.0}),
       														  		width: 400,
                											  		height: 270,
                											  		drawDefaultFrame: true});					
        		e.target.openInfoWindow(infoWindow);
			}
		}
	}
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

internal class ExampleClusterMarkerIcon extends Sprite
{

	public function ExampleClusterMarkerIcon(numChildren:int, color:Number)
	{
		graphics.beginFill(color);
		if (numChildren <= 50)
		{
			graphics.drawCircle(0, 0, 6+numChildren/2);
		}
		else
		{
			graphics.drawCircle(0, 0, 30);
		}
		var tf:TextField = new TextField();
		var format:TextFormat = tf.getTextFormat();
		format.font = 'arial';
		tf.defaultTextFormat = format;
		tf.text = numChildren + '';
		tf.textColor = 0xffffff;
		tf.x = -int(tf.textWidth / 2) - 2;
		tf.y = -int(tf.textHeight / 2);
		tf.mouseEnabled = false;
		tf.width = tf.textWidth + 4;
		mouseChildren = false;
		addChild(tf);
	}
}