package Module.Videoviewer {
	
	import Controller.RecensioEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.HSlider;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.SliderEvent;

	public class Videoview2 extends UIComponent {
		
		private var testMode:Boolean = false;
		public var annotationSave:Function; 
		public var annotationDelete:Function;
		public var autoplay:Boolean = true;
		private var newAnnotation:NewVideoAnnotation;
		
		private var _screen:VideoScreen;
		
		private var _UI:VideoUI;
		
		private var _time:Number = 0;
		private var _duration:Number = 0;
		
		public function Videoview() {
			//loadUI();
			//loadEvents();
			this.addEventListener(Event.REMOVED_FROM_STAGE,removeVideo);
			this.addEventListener(FlexEvent.HIDE, removeVideo );
		}
		
		public function playFailed(code:String):void {
			var e:RecensioEvent = new RecensioEvent(RecensioEvent.MODULE_FAIL);
			e.data.code = code;
			this.dispatchEvent(e);
		}
		
		public function load(newVideo:Object):void {
			if(testMode) {
				newVideo = "mp4:jojo3.f4v";
			}
			if(!this._screen) {
				_screen = _UI.getScreen();
			}
			_screen.autoplay = autoplay;
			_screen.load(newVideo);
			_screen.delegate = this;
			_UI.timeline.delegate = this;
			_screen.getOverlay().addEventListener(MouseEvent.MOUSE_UP,createAnnotation);
			resizeUI();
			addTmpAnnotation();
		}
		
		// Starts the creation of a new annotation
		private function createAnnotation(e:MouseEvent=null):void {
			_screen.pause();
			clearNewAnnotation();
			newAnnotation = new NewVideoAnnotation();
			newAnnotation.addEventListener(Event.COMPLETE,annotationSaved);
			_screen.addChild(newAnnotation);
			newAnnotation.x = _screen.getOverlay().mouseX + _screen.getOverlay().x;
			newAnnotation.y = _screen.getOverlay().mouseY + _screen.getOverlay().y;
		}
		
		// Removes an incomplete annotation
		private function clearNewAnnotation():void {
			if(newAnnotation) {
				if(_screen.contains(newAnnotation)) {
					_screen.removeChild(newAnnotation);
				}
				if(newAnnotation.hasEventListener(Event.COMPLETE)) {
					newAnnotation.removeEventListener(Event.COMPLETE,annotationSaved);
				}
			}
			newAnnotation = null;
		}
		
		// Sends the annotation to the controller and adds it to the annotations array
		private function annotationSaved(e:Event):void {
			var dataArray:Array = new Array();
			var _data:Object = new Object();
			_data.width = 10;
			_data.height = 10;
			_data.x = (newAnnotation.x - _screen.getOverlay().x - ((_data.width/100)*_screen.getOverlay().width/2))/_screen.getOverlay().width;
			_data.y = (newAnnotation.y - _screen.getOverlay().y - ((_data.height/100)*_screen.getOverlay().height/2))/_screen.getOverlay().height;
			_data.start = _time;
			_data.end = _data.start+10;
			_data.path = "";
			_data.text = newAnnotation.getText();
			dataArray.push(_data);
			annotationSave(dataArray);
			clearNewAnnotation();
			_UI.timeline.addAnnotation(_data,_screen.getOverlay()); //This changes width/height back to a percentage
			_screen.play();
		}
		
		private function addTmpAnnotation():void {
			var annotation:Object = new Object();
			annotation.x = 0.5;
			annotation.y = 0.5;
			annotation.start = 4;
			annotation.end = 8;
			annotation.width = 10;
			annotation.height = 10;
			annotation.text = "Video Annotation";
			var annotations:Array = new Array();
			annotations.push(annotation);
			//loadAnnotations(annotations);
		}
		
		public function addAnnotations(annotations:Array):void {
			loadAnnotations(annotations);
		}
		
		public function loadAnnotations(data:Array):void {
			//trace("***");
			//trace(data);
			for(var i:Number=0; i<data.length; i++) {
				//trace(data[i].base_asset_id);
			}
			_UI.timeline.addAnnotations(data,_screen.getOverlay());
			//trace("***");
		}
		
		public function setVideoTime(newTime:Number):void {
			_time = newTime;
			updateTimelineHeadPosition();
			updateTimeCounter(); 
		}
		
		public function scrubTo(newPercentage:Number):void {
			_screen.scrubTo(newPercentage*_duration);
		}
		
		public function setDuration(newDuration:Number):void {
			_duration = newDuration;
			updateTimeCounter();
		}
		
		private function updateTimelineHeadPosition():void {
			if(_duration > 0) {
				_UI.getTimeline().updateHeadPosition(_time/_duration);
			}
		}
		
		public function isPaused(paused:Boolean):void {
			if(paused) {
				_UI.playbutton.label = "Stopped";
				_UI.playbutton.setStyle("color","#990000");
			} else {
				_UI.playbutton.label = "Playing";
				_UI.playbutton.setStyle("color","#009900");
			}
		}
		
		private function updateTimeCounter():void {
			_UI.timetext.text = formatTime(_time) +" / " + formatTime(_duration);
		}
		
		private function loadEvents():void {
			this.addEventListener(Event.RESIZE,resizeUI);
			_UI.playbutton.addEventListener(MouseEvent.CLICK,playbuttonClick);
			_UI.volumeslider.addEventListener(Event.CHANGE,volumeChanged);
			_UI.maxsizebutton.addEventListener(MouseEvent.CLICK,maxsizebuttonClick);
			_UI.fullscreenbutton.addEventListener(MouseEvent.CLICK,fullscreenClick);
		}
		
		private function volumeChanged(e:Event):void {
			_screen.setVolume(_UI.volumeslider.value/100);
		}
		
		private function playbuttonClick(e:MouseEvent):void {
			_screen.playpause();
			trace("PLAYPAUSE");
		}
		
		private function maxsizebuttonClick(e:MouseEvent):void {
			_screen.maxsizeclicked();
		}
		
		private function fullscreenClick(e:MouseEvent):void {
			_screen.fullscreen();
		}
		
		private function loadUI():void {
			this._UI = new VideoUI();
			addChild(this._UI);
			resizeUI();	
		}
		
		private function formatTime(theTime:Number):String {
			theTime = Math.round(theTime);
			var theMinutes:String = "00";
			var theSeconds:String = "00";
			if(theTime%60 < 10) {
				theSeconds = "0"+theTime%60;
			} else {
				theSeconds = ""+theTime%60;
			}
			if(Math.floor(theTime/60) < 10) {
				theMinutes = "0"+Math.floor(theTime/60);
			} else {
				theMinutes = ""+Math.floor(theTime/60);
			}
			return theMinutes+":"+theSeconds;
		}
		
		public function getDuration():Number {
			return this._duration;
		}
		
		public function getVideoDimensions():Rectangle {
			return _screen.getVideoDimensions();
		}
		
		private function resizeUI(e:Event=null):void {
			_UI.width = this.width;
			_UI.height = this.height;
		}
		
		public function updateBuffer(newTime:Number):void {
			_UI.getTimeline().buffered(newTime);
		}
		
		public function removeVideo(e:Event=null):void {
			_screen.stop();
			trace("STOPPING");
		}
		
		public function dealloc():void {
			_screen.dealloc();
			if(this.contains(this._UI)) {
				this.removeChild(this._UI);
			}
			_screen = null;
			_UI = null;
			_time = 0;
			_duration = 0;
			trace("REMOVING");
		}
	}
}