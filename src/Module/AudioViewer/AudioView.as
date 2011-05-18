package Module.AudioViewer
{
	import Controller.MediaController;
	
	import Lib.it.transitions.Tweener;
	
	import Model.Model_Commentary;
	
	import Module.AudioViewer.AudioAnnotateWave;
	import Module.ImageViewer.ImageAnnotation;
	
	import View.MediaView;
	import View.components.Annotation.AnnotationBox;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.MediaViewerInterface;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.SliderEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.HSlider;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Line;

	public class AudioView extends MediaViewer implements MediaViewerInterface {
		
		public var viewerWidth:Number = 800;
		public var viewerHeight:Number = 600;
		public var file:String = 'null';
		public var visualisation:String = 'line';
		//public var autoplay:Boolean = false;
		public var autoplay:Boolean = true;
		public var annotationSave:Function = MediaView.saveAnnotationFunction;
		public var annotationDelete:Function;
		
		public var borderWidth:Number = 2;
		public var navHeight:Number = 60;
		public var audioLength:Number = -1;
		private var _audioFile:Sound = new Sound();
		private var _audioChannel:SoundChannel;
		private var _audioTransform:SoundTransform = new SoundTransform();
		private var _audioTimer:Timer = new Timer(30); 
		private var _background:AudioVisualiser;
		private var _musicPlaying:Boolean = false;
		private var _musicPosition:Number = 0;
		private var _soundWave:AudioWave;
		private var _lastHeadPosition:Number = -1;
		private var _scrollpadding:Number = 20;
		private var _channelSize:Number = 80;
		
		
		
		private var _UIVolumeslider:HSlider;
		private var _UI:AudioUI;
		private var _UIView:Canvas;
		private var _UIAnnotater:AudioAnnotateWave;
		private var _UIToolbar:VBox;
		private var _UITimeText:Label;
		private var _UIVisualiser:AudioVisualiser;
		private var _UIPlayButton:Button;
		private var _UITimeline:AudioTimeline;
		private var _isplaying:Boolean = false;
		private var _audioFileLoader:AudioFileLoader;
		
		private var hLine:UIComponent = new UIComponent();
		
		
		// stores the list of annotations CRAG
		private var annotations:Array;
		
		//private var _loadingScreen:Sprite = new Sprite();
		private var _loadingScreen:BorderContainer = new BorderContainer();
		//private var _loadingScreenText:TextField = new TextField();
		private var _loadingScreenText:Label = new Label();
		private var _loadingScreenTextFormat:TextFormat = new TextFormat();
		private var _loadingTimer:Timer = new Timer(30);
		
		private var _isLoaded:Boolean = false;
		
		public function AudioView() {
			//this.addEventListener(Event.ADDED_TO_STAGE,loadAudio);
			this.addEventListener(Event.REMOVED_FROM_STAGE,removeAudio);
			this.addEventListener(FlexEvent.HIDE, removeAudio );
			
		}
		
//		public function loadAudio(e:Event = null):void {
//			if(file != 'null') {
//				loadFile(file);
//			}
//		}
		
		public function removeAudio(e:Event = null):void {
			if(_isLoaded) {
				togglePlay(true,false);
			} else {
				_loadingTimer.stop();
				_loadingTimer = null;
			}
			_audioFileLoader.dealloc();
		}
		
		override public function load(fileurl:String):void {
			//file = fileurl;
		//}
		
		//public function loadFile(fileurl:String):void {
			trace("file url:", fileurl);
			file = fileurl;
			
			createUI();
			
			
			_audioFileLoader = new AudioFileLoader(file);
			_audioFileLoader.addEventListener("AUDIOPROGRESSUPDATE",audioUpdated);
			_audioFileLoader.addEventListener(Event.COMPLETE,audioLoaded);
		}
		
		private function audioLoaded(e:Event):void {
			hideLoading();
			trace("AUDIO LOADED HOORAY!!!");
			_UIAnnotater.showAnnotationBars();
			_isLoaded = true;
			loadWave();
			if(autoplay) {
				togglePlay(true,true);
			}
			resizeUI();
			_UITimeline.resize();
		}
		
		public function togglePlay(force:Boolean=false,playstatus:Boolean=false):void {
			if(force) {
				if(playstatus) {
					_isplaying = false;
				} else {
					_isplaying = true;
				}
			}
			if(_isplaying) {
				_UIVisualiser.stop();
				_UIPlayButton.label = "Stopped";
				_UIPlayButton.setStyle("color","#990000");
				_audioFileLoader.stop();
				_isplaying = false;
			} else {
				_UIVisualiser.start();  
				_UIPlayButton.label = "Playing";
				_UIPlayButton.setStyle("color","#009900");
				_audioFileLoader.play();
				_isplaying = true;
			}
		}
		
		public function pause():void {
			if(_isLoaded) {
				togglePlay(true,false);
			} else {
				trace("Content not yet loaded");
			}
		}
		
		public function play():void {
			if(_isLoaded) {
				togglePlay(true,true);
			} else {
				trace("Content not yet loaded");
			}
		}
		
		private function playbuttonClick(e:MouseEvent):void {
			if(_UIPlayButton.label != "Loading...") {
				togglePlay();
			} else {
				trace("STILL LOADING");
			}
		}
		
		private function createUI():void {
			setupLoading();
			this._UI = new AudioUI();
			this.addElement(this._UI);
			_UIView = this._UI.view;
			_UIToolbar = this._UI.toolbar;
			_UITimeText = this._UI.getTimeText();
			_UIPlayButton = this._UI.getPlayButton();
			_UITimeline = this._UI.getTimeline();
			_UIVisualiser = this._UI.getVisualiser();
			_UIVolumeslider = this._UI.getVolumeSlider();
			_UIAnnotater = this._UI.getAnnotaterView();
			_UIAnnotater.viewer = this;
			_UIAnnotater.addEventListener("STARTINGANNOTATION",startingAnnotation);
			_UIVolumeslider.addEventListener(Event.CHANGE,volumeChanged);
			_UITimeline.setView(this);
			_UITimeline.setAnnotationView(_UIAnnotater);
			_UIPlayButton.addEventListener(MouseEvent.CLICK,playbuttonClick);
			
			// Listen for Show Annotation List button being clicked (CRAIG)

			
			this.addEventListener(Event.RESIZE,resizeUI);
			resizeUI();
			
			
			showLoading();
		}

		
		
		private function annotationListMouseOver(e:MouseEvent):void {
			AudioAnnotation.isBeingMouseOvered = true;
			for(var i:Number = 0; i < _UITimeline._annotationArea.numChildren; i++) {
				var audioAnnotation:AudioAnnotation = _UITimeline._annotationArea.getChildAt(i) as AudioAnnotation;
				if(audioAnnotation.getID() == e.target.id) {
					audioAnnotation.showAnnotationBubble();
				}
			}
		}
		
		private function annotationListMouseOut(e:MouseEvent):void {
			AudioAnnotation.isBeingMouseOvered = false;
			for(var i:Number = 0; i < _UITimeline._annotationArea.numChildren; i++) {
				var audioAnnotation:AudioAnnotation = _UITimeline._annotationArea.getChildAt(i) as AudioAnnotation;
				audioAnnotation.hideAnnotationBubble();
			}
		}
		
		public function setupLoading():void {
			_loadingScreen.backgroundFill = new SolidColor(0x333333,0.8);
			var myLayout:HorizontalLayout = new HorizontalLayout();
			myLayout.verticalAlign = "middle";
			_loadingScreen.layout = myLayout;
			//_loadingScreen.x = -80;
			_loadingScreen.x = 0;
			//_loadingScreen.y = -30;
			_loadingScreen.width = 240;
			_loadingScreen.height = 60;
			//_loadingScreen.graphics.beginFill(0x333333,0.8);
			//_loadingScreen.graphics.drawRoundRect(-120,-30,240,60,12);
			_loadingScreenText.text = "Loading 0%";
			_loadingScreenText.width = 240;
			//_loadingScreenText.x = -120;
			//_loadingScreenText.y = -10;
			_loadingScreenText.setStyle('color', 'white');
			_loadingScreenText.setStyle('fontSize', '16');
			_loadingScreenText.setStyle('textAlign', TextAlign.CENTER);
//			_loadingScreenTextFormat.font = "Arial";
//			_loadingScreenTextFormat.size = 18;
//			_loadingScreenTextFormat.color = 0xFFFFFF;
//			_loadingScreenTextFormat.align = TextFormatAlign.CENTER;
			//_loadingScreenText.setTextFormat(_loadingScreenTextFormat);
			//_loadingScreen.addChild(_loadingScreenText);
			_loadingScreen.addElement(_loadingScreenText);
		}
		
		public function showLoading():void {
			if(!this.contains(_loadingScreen)) {
				this.addElementAt(_loadingScreen,this.numChildren);
				_loadingTimer.addEventListener(TimerEvent.TIMER,updateLoadingInfo);
				_loadingTimer.start();
			}
		}
		
		private function updateLoadingInfo(e:TimerEvent):void {
			var newPercentage:Number = Math.round(100*(_audioFileLoader.getAudioFile().bytesLoaded / _audioFileLoader.getAudioFile().bytesTotal));
			_loadingScreenText.text = "Loading "+newPercentage+"%";
			//trace("Loading "+newPercentage+"%");
			if(isNaN(newPercentage)) {
				_loadingScreenText.text = "Loading 0%";
			}
			//_loadingScreenText.setTextFormat(_loadingScreenTextFormat);
		}
		
		public function hideLoading():void {
			if(this.contains(_loadingScreen)) {
				//this.removeChild(_loadingScreen);
				this.removeElement(_loadingScreen);
			}
			_loadingTimer.stop();
		}
		
		public function resizeUI(e:Event=null):void {
			_UI.width = this.width;
			_UI.height = this.height;
			_loadingScreen.x = (this.width - _loadingScreen.width)/2;
			_loadingScreen.y = (this.height + _loadingScreen.height)/2 - 100;
		}
		
		private function startingAnnotation(e:Event):void {
			_UITimeline.removeExistingBubbles();
			togglePlay(true,false);
		}
		
		public function changeTimelineSize(maxLevel:Number):void {
			_UITimeline.height = 30+10*maxLevel;
			_UIToolbar.height = 80+10*maxLevel;
			_UIView.setStyle("bottom",110+10*maxLevel);
		}
		
		public function saveAnnotation(start:Number,end:Number,text:String):void {
			_UIAnnotater.removeNewAnnotation();
			if(text != "") {
				var newAnnotation:Model_Commentary = new Model_Commentary();
					newAnnotation.annotation_x = start*getDuration();
					newAnnotation.annotation_y = end*getDuration();
					newAnnotation.annotation_text = text;
				_UITimeline.addAnnotation(
					newAnnotation
				);
				if(annotationSave != null) {
					var annotationArray:Array = new Array(newAnnotation);
					trace(newAnnotation);
					annotationSave(annotationArray);
				}
				_audioFileLoader.scanTo(start);
				this.togglePlay(true,true);
			}
		}
		
		public function volumeChanged(e:Event):void {
			_audioFileLoader.setVolume(_UIVolumeslider.value/100);
		}
		
		private function audioUpdated(e:Event):void {
			if(_audioFileLoader.time > 0) {
				_UITimeText.text = totime(_audioFileLoader.time)+" / "+totime(_audioFileLoader.duration);
				_UITimeline.updateHeadPosition(_audioFileLoader.time/_audioFileLoader.duration);
				_UIAnnotater.updateBarPosition(_audioFileLoader.time/_audioFileLoader.duration);
			}
		}
		
		public function scanTo(newPosition:Number):void {
			_audioFileLoader.scanTo(newPosition);
		}
		
		override public function addAnnotations(annotations:Array):void {
			// Save the ANnotations (craig)
			this.annotations = annotations;
//			redrawSidebar();
			
			_UITimeline.addAnnotations(annotations);
			resizeUI();
			_UITimeline.resize();
		}
		
		public function getDuration():Number {
			return _audioFileLoader.duration;
		}
		
		private function loadWave():void {
			_UIAnnotater.loadSoundWave(_audioFileLoader.getAudioFile());
		}
		
		private function totime(time:Number):String {
			var timeString:String = "";
			time = Math.floor(time);
			var seconds:Number = time%60;
			var minutes:Number = Math.floor(time/60);
			if(minutes < 10) {
				timeString = "0"+minutes+":";
			} else {
				timeString = minutes+":";
			}
			if(seconds < 10) {
				timeString = timeString+"0"+seconds;
			} else {
				timeString = timeString+seconds;
			}
			return timeString;
		}
	}
}