

package fink
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;


	
	public class AudPlayer
	{
		private var mySound:Sound = new Sound();
		private var snd1:Sound = new Sound();
		private var snd2:Sound = new Sound();
		private var snd3:Sound = new Sound();
		private var snd4:Sound = new Sound();
		private var sndChan:SoundChannel = new SoundChannel();
		
		private var filt1:filter = new filter();
		private var samp:Number;
		private var samp1:Number;
		private var samp2:Number;
		private var vol:Number;
		
		//private var req:URLRequest = new URLRequest("http://av.adobe.com/podcast/csbu_dev_podcast_epi_2.mp3");
		private var req1:URLRequest = new URLRequest("tr1.mp3");
		private var req2:URLRequest = new URLRequest("tr2.mp3");
		private var req3:URLRequest = new URLRequest("tr3.mp3");
		private var req4:URLRequest = new URLRequest("tr4.mp3");
		private var bytes1:ByteArray = new ByteArray();
		private var bytes2:ByteArray = new ByteArray();
		private var bytes3:ByteArray = new ByteArray();
		private var bytes4:ByteArray = new ByteArray();
		
		public function AudPlayer(sndIn:Sound)
		{
			mySound = sndIn;
			vol = 1.0;
			snd1.load(req1);
			snd2.load(req2);
			snd3.load(req3);
			snd4.load(req4);
			snd1.addEventListener(Event.COMPLETE, doNothing1);
			snd2.addEventListener(Event.COMPLETE, doNothing2);
			snd3.addEventListener(Event.COMPLETE, doNothing3);
			snd4.addEventListener(Event.COMPLETE, doNothing4);
		    vol = 1.0;
		}
		
		private function doNothing1(event:Event):void
		{
			snd1.extract(bytes1, (44100*30));
		}
		private function doNothing2(event:Event):void
		{
			snd2.extract(bytes2, (44100*30));
		}
		private function doNothing3(event:Event):void
		{
			snd3.extract(bytes3, (44100*30));
		}
		private function doNothing4(event:Event):void
		{
			snd4.extract(bytes4, (44100*30));
		}
			
	//	private function loaded(event:Event):void
	//	{
    //		outputSnd.addEventListener(SampleDataEvent.SAMPLE_DATA, processSound);
    //	}

		
		private function sineWaveGenerator(event: SampleDataEvent):void {
		//private function sineWaveGenerator():void {
			
    		for ( var c:int=0; c<4096; c++ ) {
    			//samp = Math.sin((Number(c+event.position)*0.10/Math.PI/2));
    			samp1 = (bytes1.readFloat() + bytes2.readFloat() + bytes3.readFloat()+ bytes4.readFloat())/4.0;
    			samp2 = (bytes1.readFloat() + bytes2.readFloat() + bytes3.readFloat()+ bytes4.readFloat())/4.0;
    			//if (samp > 0) samp = 0.25;
    			//else if (samp < 0) samp = -0.25;
    			
    			//samp = filt1.tick(samp);
        		event.data.writeFloat(samp1);
        		event.data.writeFloat(samp2);
    		}
		}

		public function playSnd():void
		{
			bytes1.position = 0;
			bytes2.position = 0;
			bytes3.position = 0;
			bytes4.position = 0;
			mySound.addEventListener(SampleDataEvent.SAMPLE_DATA,sineWaveGenerator);
			sndChan = mySound.play();
			//snd1.play();
	
		}

		public function stopSnd():void
		{

			sndChan.stop();
			//mySound.addEventListener(SampleDataEvent.SAMPLE_DATA,sineWaveGenerator);
			//mySound.close();
	
		} 

		public function vUp():void
		{
			vol += 0.1;
		}
		
		public function vDown():void
		{
			vol -= 0.1;
		}

	}
}