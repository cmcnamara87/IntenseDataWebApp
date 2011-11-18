package Module.Videoviewer {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	public class VideoTimeline extends UIComponent {
		
		public var backgroundColor:uint = 0xFFFFFF;
		public var borderColor:uint = 0xFF0000;
		public var cornerRadius:Number = 10;
		public var delegate:Videoview;
		
		private var _timeline:Sprite = new Sprite();
		private var _timelineHead:Sprite = new Sprite();
		
		// The space above the timeline, that holds the box versions of the annotations
		private var _annotationArea:UIComponent = new UIComponent();
		
		private var _timelineBuffer:Sprite = new Sprite();
		private var _timelineBufferMask:Sprite = new Sprite();
		private var loadedAnnotations:Boolean = false;
		

		// are we scrubbing on the timeline
		private var isScrubbing:Boolean = false;
		
		private var colours:Array = new Array(
			0xFF0000,0x0000FF,0x226666,0xC71585,0x009A9A,0xFF8C00,0x4B0082
		);
		
		public function VideoTimeline():void {
			VideoAnnotation.resetAnnotations();
			this.addEventListener(Event.ADDED_TO_STAGE,setupTimeline);
			this.addEventListener(Event.RESIZE,resize);
			addObjects();
		}
		
		private function setupTimeline(e:Event=null):void {
			resize();
		}
		
		public function updateHeadPosition(timePercentage:Number):void {
			_timelineHead.x = Math.round(timePercentage*(this.width-20-4));
			VideoAnnotation.showhide(_timelineHead.x);
		}
		
		public function resize(e:Event=null):void {
			this.graphics.clear();
			this.graphics.lineStyle(1,borderColor,1);
			this.graphics.beginFill(backgroundColor,1);
			this.graphics.drawRoundRect(0,0,this.width,this.height,cornerRadius);
			
			_timeline.graphics.clear();
			_timeline.graphics.lineStyle(1,borderColor,1);
			_timeline.graphics.beginFill(0xFFFFFF,0.1);
			_timeline.graphics.drawRect(0,0,this.width-20,20);
			_timeline.x = 10;
			_timeline.y = this.height-30;
			_timelineBufferMask.graphics.clear();
			_timelineBufferMask.graphics.beginFill(0xFF0000,0.5);
			_timelineBufferMask.graphics.drawRect(1,1,this.width-21,19);
			_timelineBufferMask.x = 0;
			_timelineBufferMask.y = 0;
			//_timelineBuffer.mask = _timelineBufferMask;
			redrawAnnotations();
		}
		
		/**
		 * Update the length of the blue buffer bar 
		 * @param newTime	The amount of time buffered, ahead of the current playhead position
		 * 
		 */		
		public function buffered(newTime:Number):void {
			try {
				// work out the percentage loaded (ahead of the playhead)
				var percentLoaded:Number = newTime/delegate.getDuration();
				if(percentLoaded*(this.width-20) > 0) {
					_timelineBuffer.graphics.clear();
					_timelineBuffer.graphics.beginFill(0xEEEEEE,1);
					if(_timelineHead.x+1 > 0) {
						_timelineBuffer.graphics.drawRect(1,1,percentLoaded*(this.width-20)+3+_timelineHead.x,19);
						redrawAnnotations();
					}
				}
			} catch (e:Error) {
				trace("COULD NOT GET BUFFER"+e.message);
			}
		}
		
		private function addObjects():void {
			this.addChild(_annotationArea);
			_annotationArea.x = 14;
			_annotationArea.y = 30;
			this.addChild(_timeline);
			_timeline.addEventListener(MouseEvent.MOUSE_DOWN,startMovePosition);
			_timeline.addChild(_timelineBuffer);
			//_timeline.addChild(_timelineBufferMask);
			_timeline.addChild(_timelineHead);
			drawTimelineHead();
		}
		
		public function getTime():Number {
			return _timelineHead.x;
		}
		
		/**
		 * Mouse down on the timeline.  
		 * @param e
		 * 
		 */		
		private function startMovePosition(e:MouseEvent):void {
			//mouseMoveX = this.mouseX;
			
			_timeline.addEventListener(MouseEvent.MOUSE_UP, stopMovePosition);
			
			_timeline.addEventListener(MouseEvent.MOUSE_MOVE, scrubbing);
			
			// Listen for the mouse to stop scrubbing
			_timeline.addEventListener(MouseEvent.MOUSE_OUT, stopMovePosition);
		}
		
		/**
		 * Mouse moved on timeline while scrubbing. 
		 * Scrub to a position in the timeline (based on mouse movement on the timeline) 
		 * @param e
		 * 
		 */		
		private function scrubbing(e:MouseEvent):void {
			// We are scrubbing on the timeline

			if(!isScrubbing) {
				// we just started to scrub
				// Tell the video to pause while we scrub	
				delegate.pauseVideo();
				isScrubbing = true;
			}
			
			scrubTo((this.mouseX-10)/(this.width-10));				
			
		}
		
		/**
		 * Mouse is released on timeline. Scrub to a position in the timeline when mouse is released. 
		 * @param e
		 * 
		 */		
		private function stopMovePosition(e:MouseEvent):void {
			// Scrub to time on timeline
			scrubTo((this.mouseX-10)/(this.width-10));
			
			// Resume video
			delegate.playVideo();
			// say we stopped scrubbing
			isScrubbing = false;
			
			if(_timeline.hasEventListener(MouseEvent.MOUSE_UP)) {
				_timeline.removeEventListener(MouseEvent.MOUSE_UP,stopMovePosition);
			}
			
			if(_timeline.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				_timeline.removeEventListener(MouseEvent.MOUSE_MOVE,scrubbing);
			}
			
			if(_timeline.hasEventListener(MouseEvent.MOUSE_OUT)) {
				_timeline.removeEventListener(MouseEvent.MOUSE_OUT,stopMovePosition);
			}
		}
		
		public function annotationClicked(annotationPosition:Number):void {
			scrubTo((annotationPosition+3)/(this.width-10));
		}
		
		private function scrubTo(newPercentage:Number):void {
			delegate.scrubTo(newPercentage);
		}
		
		private function drawTimelineHead():void {
			_timelineHead.graphics.beginFill(0x000000,1);
			_timelineHead.graphics.drawRect(0,1,4,19);
			_timelineHead.mouseEnabled = false;
			if(!loadedAnnotations) {
				redrawAnnotations();
				
			}
		}
		
		public function addAnnotations(data:Array,overlay:Sprite):void {
			// Remove all current annotations???
			VideoAnnotation.resetAnnotations(overlay);
			
			for(var i:Number=0; i<data.length; i++) {
				addAnnotation(data[i], overlay);
			}
			resize();
		}
		
		public function addAnnotation(data:Object,onVideoAnnotationHolder:Sprite):void {
			trace("*** ADDING VIDEO ANNOTATION ***");
			var newAnnotation:VideoAnnotation = VideoAnnotation.add(data,this,colours[Math.round(Math.random()*colours.length-1)]);
			_annotationArea.addChild(newAnnotation);
			newAnnotation.addOverlay(onVideoAnnotationHolder);	
		}
		
		private function redrawAnnotations():void {
			if(delegate && delegate.getDuration() > 0) {
				if(!loadedAnnotations) {
					loadedAnnotations = true;
				}
				_annotationArea.alpha = 1;
				var maxXLevel:Number = VideoAnnotation.redraw(this.width-20,delegate.getDuration(),delegate.getVideoDimensions());
				//trace("!!!!"+maxXLevel);
				// TODO this is running constantyl even when it should be unloaded, make it stop.
				// REALLY this needs to be fixed.
				/* Need to increase size of timeline based on maxXLevel, limited to 3 at the moment */
			} else {
				_annotationArea.alpha = 0;
			}
		}
	}
}