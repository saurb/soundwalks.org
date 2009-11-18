package
{
	import com.google.maps.overlays.Marker;
	
	public class MarkerWithId extends Marker
	{
		private var _soundId:int;
		public function set soundId(id:int):void
		{
			if(id != _soundId)
			{
				_soundId = id;
			}
		}
		public function get soundId():int
		{
			return _soundId;
		}
	}
}