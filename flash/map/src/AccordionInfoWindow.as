package
{
	import flash.events.MouseEvent;
	
	import mx.containers.Accordion;
	import mx.containers.VBox;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	/**
	 * @author Jinru Liu
	 */
	 
	public class AccordionInfoWindow extends UIComponent
	{
		public function AccordionInfoWindow(accordionData:Array)
		{
			var box:VBox = new VBox();
			box.width = 370;
			box.height = 250;
			addChild(box);
			
			var info:Text = new Text();
			info.setStyle("color", 0x285c7d);
			info.setStyle("fontFamily", "Verdana");
			info.setStyle("fontSize", 10);
			info.text = "There are " + String(accordionData.length) + " sounds within this area."
			box.addChild(info);
			
			var acc:Accordion = new Accordion();
			acc.percentWidth = 100;
			acc.percentHeight = 100;
			acc.setStyle("headerHeight", 15);
			
			for (var i:int = 0; i < accordionData.length; i++)
			{
				var vbox:VBox = new VBox();
				//vbox.label = "Sound" + String(i+1);
				vbox.label = accordionData[i].soundTitle;
				vbox.id = "Sound" + String(i+1);
				vbox.addChild(accordionData[i]);
				
				vbox.percentWidth = 100;
				vbox.explicitMinHeight = 160;
				acc.addChild(vbox);
			}
			
			accordionData[0].showTags();
			
			// click show tag cloud
			acc.addEventListener(MouseEvent.CLICK, handleClick);
			function handleClick(e:MouseEvent):void
			{
				if (e.target.className == "AccordionHeader")
				{
					var index:Number = e.currentTarget.selectedIndex;
					accordionData[index].showTags();
				}
		
			}
			
			box.addChild(acc);
			
		}
	}
}