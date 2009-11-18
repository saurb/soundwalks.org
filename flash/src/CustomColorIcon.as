package
{
	import flash.display.Sprite;
	
	public class CustomColorIcon extends Sprite
	{
		
		public function CustomColorIcon(color:Number)
		{
				graphics.beginFill(color, 1.0);
				graphics.drawCircle(0,0,6);
				graphics.endFill();
			
		}
		
	}

}	
