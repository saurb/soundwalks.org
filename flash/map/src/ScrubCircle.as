package
{
	import flash.display.Sprite;
	
	/**
	 * @author Jinru Liu
	 */
	
	public class ScrubCircle extends Sprite
	{
		private var _radius:Number;
		
		public function set radius(r:Number):void
		{
			if(r != _radius)
			{
				_radius = r;
			}
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		public function ScrubCircle(radius:Number)
		{
				_radius = radius;
				//graphics.beginFill(0xff3e96, 0.3);
				graphics.beginFill(0xffffff, 0.8);
				graphics.drawCircle(0,0,_radius);
				graphics.endFill();
			
		}
		
	}

}	
