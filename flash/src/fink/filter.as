// ActionScript file


package fink
{
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;

	
	public class filter
	{
		//private var mySound = new Sound();
		//private var sndChan = new SoundChannel();
		
		private var a1:Number;
		private var a2:Number;
		private var b0:Number;
		private var b1:Number;
		private var b2:Number;
		private var yt:Number;
		private var yt1:Number;
		private var yt2:Number;
		private var xt:Number;
		private var xt1:Number;
		private var xt2:Number;
		
		public function filter()
		{
			a1 = 0;
			a2 = 0.9;
			b0 = 0.25;
			b1 = 0.5;
			b2 = 0.25;
			yt = 0;
			yt1 = 0;
			yt2 = 0;
			xt = 0;
			xt1 = 0;
			xt2 = 0;
			
		}
			
		public function tick(ip:Number):Number
		{		
			xt = ip;
			yt = a1*yt1 + a2*yt2 + b0*xt + b1*xt1 + b2*xt2;
			yt2 = yt1;
			yt1 = yt;
			xt2 = xt1;
			xt1 = xt;
			return yt;
		}

	}
}
