package
{
	import mx.containers.Accordion;
	//import flexlib.containers.VAccordion;
	import mx.containers.VBox;
	import mx.containers.Box;
	import mx.core.UIComponent;
	
	/**
	 * @author Jinru Liu
	 */
	 
	public class AccordionInfoWindow extends UIComponent
	{
		public function AccordionInfoWindow(accordionData:Array)
		{
			var box:Box = new Box();
			box.width = 370;
			box.height = 300;
			addChild(box);
			
			var acc:Accordion = new Accordion();
			//acc.resizeToContent = true;
			acc.percentWidth = 100;
			acc.percentHeight = 100;
			
			for (var i:int = 0; i < accordionData.length; i++)
			{
				var vbox:VBox = new VBox();
				vbox.label = "Sound" + String(i+1);
				vbox.addChild(accordionData[i]);
				//vbox.percentHeight = 100;
				
				vbox.percentWidth = 100;
				vbox.explicitMinHeight = 150;
				acc.addChild(vbox);
			}
			
			box.addChild(acc);
		}
	}
}