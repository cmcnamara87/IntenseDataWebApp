package Module.Videoviewer {
	
	import Controller.MediaController;
	import Controller.RecensioEvent;
	
	import View.MediaView;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.MediaViewerInterface;
	
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

	public class Videoview extends MediaViewer implements MediaViewerInterface {
		
		private var testMode:Boolean = false;
		public var annotationSave:Function = MediaView.saveAnnotationFunction; 
		public var annotationDelete:Function;
		public var autoplay:Boolean = true;
		private var newAnnotation:NewVideoAnnotation;
		
		private var _screen:VideoScreen;
		
		private var _UI:VideoUI;
		
		private var _time:Number = 0; // The time of the playhead? i think?
		
		private var newAnnotationStartTime:Number = -1;
		private var newAnnotationEndTime:Number = -1;
		
		
		private var _duration:Number = 0;

		private var newAnnotationStartingX:Number; // Stores the x coordinate where the new annotation was started to be drawn from
		private var newAnnotationStartingY:Number;// Stores the y coordinate where the new annotation was started to be drawn from
		
		
		public function Videoview() {
			loadUI();
			loadEvents();
			this.addEventListener(Event.REMOVED_FROM_STAGE,removeVideo);
			this.addEventListener(FlexEvent.HIDE, removeVideo );
		}
		
		public function playFailed(code:String):void {
			var e:RecensioEvent = new RecensioEvent(RecensioEvent.MODULE_FAIL);
			e.data.code = code;
			this.dispatchEvent(e);
		}
		
		public function nearEnd():Boolean {
			checkForFinish();
			if((this._time + 5 > this._duration) && (this._time != 0)) {
				return true;
			}
			return false;
		}
		
		public function checkForFinish():void {
			if((Math.round((this._time)*10) ==
				Math.round((this._duration)*10)) 
				&& (this._time != 0)) {
				_screen.stop();
			}
		}
		
		/**
		 * Loads the video url 
		 * @param newVideo	The URL to the video
		 * 
		 */		
		override public function load(newVideo:String):void {
			if(testMode) {
				newVideo = "mp4:jojo3.f4v";
			}
			if(!this._screen) {
				_screen = _UI.getScreen();
			}
			_screen.autoplay = autoplay;
			trace("VideoView Loading: ", newVideo);
			_screen.load(newVideo);
			_screen.delegate = this;
			_UI.timeline.delegate = this;
			
			// Listening for MouseDown/Up to create annotations
			_screen.getOverlay().addEventListener(MouseEvent.MOUSE_DOWN,annotationCreationBegin);
			_screen.getOverlay().addEventListener(MouseEvent.MOUSE_UP,annotationCreationEnd);
			
			trace('overlay size ', _screen.getOverlay().width, _screen.getOverlay().height);
			resizeUI();
			addTmpAnnotation();
		}

		/**
		 * Starts drawing an annotation from the current x,y coordinates
		 * @param 	e	Mouse Down Event
		 */		
		private function annotationCreationBegin(e:MouseEvent):void {
			trace("starting annotation");
			// Pause the video playback
			_screen.pause();
			
			// Get rid of any potential half finished annotations??? no idea.
			clearNewAnnotation();
			
			// Save starting X,Y coordinates
			newAnnotationStartingX = _screen.getOverlay().mouseX + _screen.getOverlay().x;
			newAnnotationStartingY = _screen.getOverlay().mouseY + _screen.getOverlay().y;
			
			trace("starting at: " + newAnnotationStartingX + ", " + newAnnotationStartingY);
			
			// Draw on move.
			_screen.getDrawableArea().addEventListener(MouseEvent.MOUSE_MOVE,annotationCreationDraw);
		}
		
		/**
		 * Draws a box to show where the annotation will go, removed on MouseUP @see annotationCreationEnd
		 * @param e	Mouse Move Event
		 */		
		private function annotationCreationDraw(e:MouseEvent):void {
			// The current position of the mouses X and Y coordinates
			// This is where we will draw the box to, from the start coordinates
			var newAnnotationFinishingX:Number = _screen.getOverlay().mouseX + _screen.getOverlay().x;
			var newAnnotationFinishingY:Number = _screen.getOverlay().mouseY + _screen.getOverlay().y;
			
			var annotationWidth:Number = newAnnotationFinishingX - newAnnotationStartingX;
			var annotationHeight:Number = newAnnotationFinishingY - newAnnotationStartingY;
			
			_screen.clearDrawableArea();

			// Draw Annotation Box
			_screen.getDrawableArea().graphics.lineStyle(1,0xFF0000,0.8);
			_screen.getDrawableArea().graphics.beginFill(0xFF0000,0.2);
			_screen.getDrawableArea().graphics.drawRect(newAnnotationStartingX-_screen.getOverlay().x, newAnnotationStartingY-_screen.getOverlay().y, annotationWidth, annotationHeight);
			
		}
		
		// Starts the creation of a new annotation
		private function annotationCreationEnd(e:MouseEvent=null):void {
			
			// Stop drawing
			_screen.getDrawableArea().removeEventListener(MouseEvent.MOUSE_MOVE,annotationCreationDraw);
			_screen.clearDrawableArea();
			//_screen.getOverlay().graphics.clear();
			
			// Get the finishing mouse coordinates
			var newAnnotationFinishingX:Number = _screen.getOverlay().mouseX + _screen.getOverlay().x;
			var newAnnotationFinishingY:Number = _screen.getOverlay().mouseY + _screen.getOverlay().y;
			
			if(newAnnotationFinishingX == newAnnotationStartingX && newAnnotationFinishingY == newAnnotationStartingY) {
				// Singe click, not a click and drag, so they dont really want an annotation.
				return;
			}
			trace("starting at saved: " + newAnnotationStartingX + ", " + newAnnotationStartingY);
			trace("ending at: " + newAnnotationFinishingX + ", " + newAnnotationFinishingY);
			
			// Create a new annotation
			newAnnotation = new NewVideoAnnotation(
				newAnnotationStartingX,
				newAnnotationStartingY,
				newAnnotationFinishingX,
				newAnnotationFinishingY
			);
			
			// Save the annotation in the controller, do this later.
			newAnnotation.addEventListener(Event.COMPLETE,annotationSaved);
			newAnnotation.addEventListener(RecensioEvent.ANNOTATION_START_SET, setAnnotationStart);
			newAnnotation.addEventListener(RecensioEvent.ANNOTATION_END_SET, setAnnotationEnd);
			
			//_screen.addChild(newAnnotation);
			_screen.addChild(newAnnotation);
			trace('actual middle is: ' + newAnnotation.x + ": " +  newAnnotation.y);
			trace("screen size is: " + _screen.width + "px " + _screen.height + "px");
			
		}
		
		/**
		 * Called when the user has clicked the 'Set Start' button on the annotation.
		 * Saves the current time of the playhead.
		 * @param e The button was clicked.
		 * @return 
		 * 
		 */		
		private function setAnnotationStart(e:RecensioEvent):void {
			newAnnotationStartTime = _time;
			trace("Start Time set as", newAnnotationStartTime);
			trace("------------------------------------");
		}
		
		
		/**
		 * Called when the user has clicked the 'Set End' button on the annotation.
		 * Saves the current time of the playhead.
		 * @param e The button was clicked.
		 * @return 
		 * 
		 */		
		private function setAnnotationEnd(e:RecensioEvent):void {
			newAnnotationEndTime = _time;
			// Check that the end time, is not < the start time
			// if it is, we can invalidate the start time
			// and it will just use the default times for both
			if(newAnnotationEndTime < newAnnotationStartTime) {
				newAnnotationStartTime = -1;
			}
			trace("Start Time set as", newAnnotationStartTime);
			trace("End time set as", newAnnotationEndTime);
			trace("------------------------------------");
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
			
			// Remove starting x,y coordinates
			newAnnotationStartingX = 0;
			newAnnotationStartingY = 0;
		}
		
		// Sends the annotation to the controller and adds it to the annotations array
		private function annotationSaved(e:Event):void {
			var dataArray:Array = new Array();
			var _data:Object = new Object();
			
			
			_data.width = newAnnotation.getWidth();
			_data.height = newAnnotation.getHeight();
			trace('creating with width/height ', _data.width, _data.height, newAnnotation.getWidth(), newAnnotation.getHeight());
			_data.x = newAnnotation.x - _screen.getOverlay().x;
			_data.y = newAnnotation.y - _screen.getOverlay().y;
			//OR
			_data.width = 10;
			_data.height = 10;
			_data.width = int(newAnnotation.getWidth()/_screen.getVideoPlayerWidth()*100);
			_data.height = int(newAnnotation.getHeight()/_screen.getVideoPlayerHeight()*100);
			_data.x = (newAnnotation.x - _screen.getOverlay().x - ((_data.width/100)*_screen.getOverlay().width/2))/_screen.getVideoPlayerWidth();
			_data.y = (newAnnotation.y - _screen.getOverlay().y - ((_data.height/100)*_screen.getOverlay().height/2))/_screen.getVideoPlayerHeight();
			//EQUALS
			
			// If the user has not set a start or an end time for hte annotation
			// use the default.
			if(newAnnotationStartTime == -1 || newAnnotationStartTime == -1) {
				_data.start = Math.max(_time-5,0);
				_data.end = _data.start+10;
			} else {
				_data.start = newAnnotationStartTime;
				_data.end = newAnnotationEndTime;
				
				trace("Start Time set as", _data.start);
				trace("End time set as", _data.end);
				trace("------------------------------------");
				
				// We have used the current start/end times
				// now we should invalidate them so the next annotation
				// defaults to the standard time unless its set again
				newAnnotationStartTime = -1;
				newAnnotationEndTime = -1;
			}
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
		
		override public function addAnnotations(annotations:Array):void {
			loadAnnotations(annotations);
		}
		
		public function loadAnnotations(data:Array):void {
			//trace("***");
			//trace(data);
			for(var i:Number=0; i<data.length; i++) {
				//trace(data[i].base_asset_id);
			}
			_screen.clearOverlay();
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
			this.addElement(this._UI);
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
			this.removeElement(_UI);
			dealloc();
			trace("STOPPING");
		}
		
		public function dealloc():void {
			trace("DEALLOCING");
			_screen.dealloc();
			if(this.contains(this._UI)) {
				this.removeChild(this._UI);
			}
			_screen = null;
			_UI = null;
			_time = 0;
			_duration = 0;
		}
	}
}