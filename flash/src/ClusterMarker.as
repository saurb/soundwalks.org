package
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.styles.FillStyle;

	/**
	 *
	 * mordified by Jinru Liu
	 */
	public class ClusterMarker extends Marker 
	{

		public function ClusterMarker(cluster:Array, clusterColor:Number)
		{
			var options:MarkerOptions = new MarkerOptions();
			options.tooltip = String(cluster.length) + " sounds inside" + "\n" + "double click to zoom in";
			options.icon = new ExampleClusterMarkerIcon(cluster.length, clusterColor);
			options.hasShadow = false;
			super((cluster[0] as Marker).getLatLng(), options);
			
			/*super.addEventListener(MapMouseEvent.CLICK, addClusterInfoWindow);
			function addClusterInfoWindow(e:MapMouseEvent):void
			{
				
				var infoWindow:InfoWindowOptions = new InfoWindowOptions({customContent:window, 
       														  		fillStyle: new FillStyle({alpha: 1.0}),
       														  		width: 200,
                											  		height: 100,
                											  		drawDefaultFrame: true});					
        		e.target.openInfoWindow(infoWindow);
			}*/
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