package
{
	import mx.containers.Box;
	import mx.containers.VBox;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	/**
	 * @author Jinru Liu
	 */
	 
	public class ClusterInfoWindow extends UIComponent
	{
		public function ClusterInfoWindow(num:int)
		{
			var panel:Box = new Box();
			panel.width = 200;
			panel.width = 100;
			addChild(panel);
			
			var clusterInfo:Text = new Text();
			clusterInfo.text = "There are " + String(num) + " sounds in this cluster.";
			clusterInfo.selectable = false;
			
			var zoom:Text = new Text();
			zoom.setStyle("color", 0x607a29);
			zoom.setStyle("fontWeight", "bold");
			zoom.text = "Zoom in to see more.";
			zoom.useHandCursor = true;
			zoom.buttonMode = true;
			zoom.mouseChildren = false;
			zoom.mouseEnabled = true;
			//zoom.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void(map.setZoom(map.getZoom() + 2);));
			//zoom.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void{e.target.setStyle("color", 0x3c8bbc)});
			//zoom.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void{e.target.setStyle("color", 0x607a29)});
			
			panel.addChild(clusterInfo);
			panel.addChild(zoom);
		}
	}
}