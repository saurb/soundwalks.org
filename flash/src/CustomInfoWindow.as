package 
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.containers.Box;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.core.UIComponent;
	
	/**
	 * @author Jinru Liu
	 */
	
	public class CustomInfoWindow extends UIComponent
	{
		//[Embed(source="play.png")] private var playIcon:Class;
		//[Embed(source="pause.png")] private var pauseIcon:Class;
		public var sound_id:String;
		public var soundwalk_id:String;
		public var infoChannel:SoundChannel = new SoundChannel(); // to access from soundwalk_map.mxml
		
		private var ready:Boolean = false;
		private var pausePosition:Number = 0;
		private var prevUser:String = "user_id";
		private var image:Image = new Image();
		private var prevUserImage:Image = new Image();
		private var tagText:String = "";
		private var tagArea:TextArea = new TextArea();
		private var soundFile:Sound;
		
		public function showTags():void
			{
				if (tagText == "") {
					var tagLoader:URLLoader = new URLLoader();
					var tagURL:String = "http://www.soundwalks.org/soundwalks/" + soundwalk_id + "/sounds/" + sound_id + "/tags.json";
					var tagReq:URLRequest = new URLRequest(tagURL);
					tagLoader.load(tagReq);
					tagLoader.addEventListener(Event.COMPLETE, decodeJSON);
					
					function decodeJSON(e:Event):void
					{
						var loader:URLLoader = URLLoader(e.target);
						var tags:Object = JSON.decode(loader.data);
						var format:String = tags.all_tags_formatted_old;
						tagArea.htmlText = format;
						tagText = format;
				
					}
				}
			}
			
			
		public function CustomInfoWindow(sound:Object)
		{
			sound_id = sound.id;
			soundwalk_id = sound.soundwalk_id;
			
			var frameLength:Number = Number(sound.frame_length);
			var frames:Number = Number(sound.frames);
			var duration:Number = frameLength * frames;
			
			if (prevUser != sound.user_id)
			{
				prevUser = sound.user_id;
				var userLoader:URLLoader = new URLLoader();
				var userURL:String = "http://soundwalks.org/users/" + sound.user_id + ".json";
				var userReq:URLRequest = new URLRequest(userURL);
				userLoader.load(userReq);
				userLoader.addEventListener(Event.COMPLETE, decodeImageJSON);
			}
			
			image = prevUserImage;
			
			//create panel for info window
			var panel:Box = new Box();
			panel.width = 360;
			panel.height = 200;
			
			var hbox1:HBox = new HBox();
			
			/*var image:Image = new Image();
			image.source = "user_brandon.png";
			image.useHandCursor = true;
			image.buttonMode = true; // rollover hand cursor
			image.addEventListener(MouseEvent.CLICK, goToLink); // go to image link*/
			
			var vbox:VBox = new VBox();
			
			var info:Text = new Text();
			info.setStyle("color", 0x285c7d);
			info.setStyle("fontFamily", "Verdana");
			info.setStyle("fontSize", 12);
			info.setStyle("fontWeight", "bold");
			info.text = "Uploader: "  + sound.user_name + "\n" + "Time: " + sound.created_at + "\n" + "Duration: " + duration + "s";
			info.selectable = false;
			
			var hbox2:HBox = new HBox();
			
			//add play&pasue button
			var ppButton:Button = new Button();
			ppButton.width = 60;
			ppButton.height = 20;
			ppButton.name = sound.id; // assign sound id to button
			ppButton.label = "Play";
			//ppButton.setStyle("icon", playIcon);
			ppButton.addEventListener(MouseEvent.CLICK, playSound);
			
			//panel.addChild(ppButton);
			// add more info button
			/*var moreInfo:Button = new Button();
			moreInfo.width = 60;
			moreInfo.height = 20;
			moreInfo.name = sound.id;
			moreInfo.label = "More";
			moreInfo.toolTip = "More Info";
			moreInfo.addEventListener(MouseEvent.CLICK, getMoreInfo);*/

			var moreInfo:Text = new Text();
			moreInfo.name = sound.id;
			moreInfo.setStyle("color", 0x607a29);
			moreInfo.setStyle("fontWeight", "bold");
			moreInfo.text = "Show details";
			moreInfo.useHandCursor = true;
			moreInfo.buttonMode = true;
			moreInfo.mouseChildren = false;
			moreInfo.mouseEnabled = true;
			moreInfo.addEventListener(MouseEvent.CLICK, getMoreInfo);
			moreInfo.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void{e.target.setStyle("color", 0x3c8bbc)});
			moreInfo.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void{e.target.setStyle("color", 0x607a29)});
			
			tagArea.setStyle("backgroundAlpha", 0);
			tagArea.setStyle("borderStyle", "none");
			//tagArea.setStyle("autosize", true);
			//tagArea.setStyle("verticalScrollPolicy", "off");
			tagArea.setStyle("textAlign", "center");
			tagArea.editable = false;
			//tagArea.selectable = false;
			tagArea.width = 350;
			tagArea.height = 80;
			
			// addEventListener(FlexEvent.SHOW, showTags);
			// TODO: EVENT LISTENER ON SHOW
			
			/*var hbox3:HBox = new HBox();
			
			var userTags:Label = new Label();
			userTags.setStyle("color", 0xff0000);
			userTags.setStyle("fontWeight", "bold");
			userTags.text = "Your Tags:";
			hbox3.addChild(userTags);*/
			
			
			hbox2.addChild(ppButton);
			hbox2.addChild(moreInfo);
			vbox.addChild(info);
			vbox.addChild(hbox2);
			hbox1.addChild(image);
			hbox1.addChild(vbox);
			panel.addChild(hbox1);
			panel.addChild(tagArea);
			//panel.addChild(hbox3);
			
			/*var slider:HSlider = new HSlider();
			//sliderLoc.minimun = 0.0;
			//sliderLoc.maximun = 1.0;
			slider.value = 5.0;
			slider.addEventListener(
			panel.addChild(slider);*/
			
			addChild(panel);
			
			//get sound id and create sound object
				var soundName:String = ppButton.name;
						
			function playSound(e:Event):void
			{
				var playButtonLocal:Button = Button(e.target);
				 //create sound channel for control
				if (playButtonLocal.label == "Play") {
					playButtonLocal.label = "Pause";
					
					if (soundFile == null) {
						soundFile = new Sound();
						var soundURL:String = "http://www.soundwalks.org/soundwalks/" + sound.soundwalk_id + "/sounds/" + soundName + ".mp3";
						soundFile.addEventListener(Event.COMPLETE, soundLoaded);
						soundFile.load(new URLRequest(soundURL));
						playButtonLocal.label = "Loading ...";
					} else {
						infoChannel = soundFile.play(pausePosition);
						infoChannel.addEventListener(Event.SOUND_COMPLETE, songFinished);
					}
					
					function soundLoaded(e:Event):void
					{
						infoChannel = soundFile.play(pausePosition);	
						infoChannel.addEventListener(Event.SOUND_COMPLETE, songFinished);
						playButtonLocal.label = "Pause";
					}
				} else if (playButtonLocal.label == "Pause") {
					pausePosition = infoChannel.position;
					infoChannel.stop();
					playButtonLocal.label = "Play";
					infoChannel.removeEventListener(Event.SOUND_COMPLETE, songFinished);
				}
			}
			
			function songFinished(e:Event):void
			{
				pausePosition = 0;
				ppButton.label = "Play";
			}
			
			function goToLink(e:Event):void // image URL
			{
				var request:URLRequest = new URLRequest("http://www.soundwalks.org/users/" + sound.user_id);
				navigateToURL(request);
			}
			
			function getMoreInfo(e:Event):void
			{
				var soundId:String = e.target.name;
				var url:String = "http://www.soundwalks.org/soundwalks/" + sound.soundwalk_id + "/sounds/" + soundId;
				var request:URLRequest = new URLRequest(url);
				navigateToURL(request);
			}
			
			function decodeImageJSON(e:Event):void
			{
				var loader:URLLoader = URLLoader(e.target);
				var userImage:Object = JSON.decode(loader.data);
				var imageURL:String = userImage.avatar_large;
			
				prevUserImage.source = imageURL;
				prevUserImage.useHandCursor = true;
				prevUserImage.buttonMode = true; // rollover hand cursor
				prevUserImage.addEventListener(MouseEvent.CLICK, goToLink); // go to image link
				
				image = prevUserImage;
			}
				
		}
			
	}
	
}
