

package fink
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;


	
	public class SndMixer
	{
		
		private const maxSnds:int = 200;
		
		private var numSnds:int = new int();
		//private var sndData:Array = new Array(maxSnds);
		private var sndLengths:Array = new Array(maxSnds);
		private var snds:Array = new Array(maxSnds);
		private var dummySnd:Sound = new Sound();
		private var loaded:Boolean = new Boolean();
		private var sndChanTest:SoundChannel = new SoundChannel();
		
		private var mySound:Sound = new Sound();
		private var sndChan:Array = new Array(maxSnds);//new SoundChannel();
		private var sndChanReady:Array = new Array(maxSnds);
		
		//private var filt1:filter = new filter();
		private var samp:Number;
		private var samp1:Number;
		private var samp2:Number;
		private var vol:Number;
		
		public function SndMixer():void
		{
			numSnds = 0;
			for(var i1:int = 0; i1 < maxSnds; i1++)
			{
				//sndData[i1] = new ByteArray();
				sndLengths[i1] = new Number();
				sndChan[i1] = new SoundChannel();
				sndChanReady[i1] = new Boolean();
				sndChanReady[i1] = true;
			}
		}
		
		public function loadSnd(req:URLRequest):void
		{
			//loaded = false;
			snds[numSnds] = new Sound(req);
			//snds[numSnds].load(req)
			sndLengths[numSnds] = Math.floor(snds[numSnds].length*44.1)
			numSnds++;
			//dummySnd.addEventListener(Event.COMPLETE, loadSndData);
			//Event.
			
		}
		
		//private function loadSndData(event:Event):void
		//{
			//sndLengths[numSnds] = Math.floor(event.currentTarget.length*44.1); //32-bit stereo sounds
			//event.currentTarget.extract(sndData[numSnds], 3000000);//(sndLengths[numSnds]+10));
			//numSnds++;
			//loaded = true;
			//this.playSnd();
		//}
				
	//	private function sineWaveGenerator(event: SampleDataEvent):void {
		//private function sineWaveGenerator():void {
			
    		//for ( var c:int=0; c<4096; c++ ) {
    			//samp = Math.sin((Number(c+event.position)*0.10/Math.PI/2));
    			//samp1 = (bytes1.readFloat() + bytes2.readFloat() + bytes3.readFloat()+ bytes4.readFloat())/4.0;
    			//samp2 = (bytes1.readFloat() + bytes2.readFloat() + bytes3.readFloat()+ bytes4.readFloat())/4.0;
    			//samp1 = sndData[0].readFloat();
    			//samp2 = sndData[0].readFloat();
    			//if (samp > 0) samp = 0.25;
    			//else if (samp < 0) samp = -0.25;
    			
    			//samp = filt1.tick(samp);
        		//event.data.writeFloat(samp1);
        		//event.data.writeFloat(samp2);
    		//}
		//}

		public function playSnd(sndID:int):void
		{

			//sndData[0].position = 0;
			//mySound.addEventListener(SampleDataEvent.SAMPLE_DATA,sineWaveGenerator);
			sndChan[0] = snds[sndID].play();
			sndChan[0].addEventListener(Event.SOUND_COMPLETE, sndFinishHandler);
			
		}
		
		private function sndFinishHandler(e:Event):void{
				
		}

		public function stopSnd():void
		{

			sndChan[0].stop();
			//mySound.addEventListener(SampleDataEvent.SAMPLE_DATA,sineWaveGenerator);
			//mySound.close();
	
		} 

		public function vUp():void
		{
			//vol += 0.1;
		}
		
		public function vDown():void
		{
			//vol -= 0.1;
		}

	}
}