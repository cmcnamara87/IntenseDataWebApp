package View.components.MediaViewer.VideoViewer
{
	import Controller.IDEvent;
	
	import Model.Model_Commentary;
	
	import View.components.GoodBorderContainer;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.layouts.VerticalLayout;
	
	public class VideoScrubBar extends GoodBorderContainer
	{
		// Variables
		private var duration:Number; // The lenght of the video in seconds
		private var mouseDown:Boolean;
		private var annotations:Array;
		private var annotationBoxes:Array = new Array();
		
		// GUI element
		private var bufferProgress:GoodBorderContainer;
		private var playhead:GoodBorderContainer;
		private var annotationTimeArea:GoodBorderContainer;
		private var timeBox:GoodBorderContainer;
		private var timeBoxText:Label;
		private var background:GoodBorderContainer;
		
		private var someShit:Group;
		
		public function VideoScrubBar()
		{
			super(0x0000FF, 1);
			this.percentWidth = 100;
			
//			this.mouseChildren = true;
			this.mouseEnabledWhereTransparent = true;

			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			someShit = new HGroup();
			someShit.percentWidth = 100;
			this.addElement(someShit);
			
			var someOtherShit:Group = new Group();
			someOtherShit.percentWidth = 100;
			this.addElement(someOtherShit);
			
//			var background1:GoodBorderContainer = new GoodBorderContainer(0xFFFFFF, 1);
//			background1.height = 29;
//			background1.percentWidth = 100;
//			this.addElement(background1);
			
			// TODO WHY THE FUCK IS THIS DISAPPEARING!! SERIOUSLY!!! WHAT THE HELL!! FUCK!!!
			background = new GoodBorderContainer(0xFFFF00, 0.5);
			background.height = 29
			background.percentWidth = 100;
			someOtherShit.addElement(background);
			
			bufferProgress = new GoodBorderContainer(0xFF0000, 0.3);
			bufferProgress.height = 29;
			bufferProgress.width = 1;
			bufferProgress.mouseEnabled = false;
			bufferProgress.mouseChildren = false;
			someOtherShit.addElement(bufferProgress);
			
			annotationTimeArea = new GoodBorderContainer(0x888888, 0.5);
			annotationTimeArea.width = 2;
			annotationTimeArea.x = 1;
			annotationTimeArea.visible = false;
			// Make the annotationTimeArea invisible to the mouse
			annotationTimeArea.mouseEnabled = false;
			annotationTimeArea.mouseChildren = false;
			someOtherShit.addElement(annotationTimeArea);
			
			// Create the playhead
			playhead = new GoodBorderContainer(0xFF0000, 1);
			playhead.height = 29;
			playhead.width = 2;
			playhead.x = 1;
			// Make the playhead invisible to the mouse
			playhead.mouseEnabled = false;
			playhead.mouseChildren = false;
			someOtherShit.addElement(playhead);

			// Create the overlay the shows the current time
			timeBox = new GoodBorderContainer(0xFFFF00, 1);
			timeBox.includeInLayout = false;
			timeBox.visible = false;
			timeBox.height = 15;
			timeBoxText = new Label();
			timeBox.addElement(timeBoxText);
			someOtherShit.addElement(timeBox);
			
			// Listen for mouse moving on the playhead
			someOtherShit.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			background.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			background.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownSeek);
			background.addEventListener(MouseEvent.MOUSE_UP, mouseUpSeek);
		}
		
		/**
		 * Sets the duration of the scrub bar (in seconds) 
		 * @param duration
		 * 
		 */		
		public function setDuration(duration:Number):void {
			this.duration = duration;
			if(annotations) {
				addAnnotationToScrubBar();
			}
		}
		
		public function setPlayheadTimeTick(time:Number):void {
			if(!mouseDown) {
				setPlayheadTime(time);
			}
		}
		/**
		 * Sets the position of the playhead and highlights annotation blocks if they
		 * are around the playhead.
		 * @param time The seconds to move the playhead
		 * 
		 */		
		private function setPlayheadTime(time:Number):void {
			// Move the playhead
			playhead.x = getXFromTime(time) - playhead.width;
			
			// Highlight hte boxes
			for(var i:Number = 0; i < annotationBoxes.length; i++) {
				var annotationBox:GoodBorderContainer = annotationBoxes[i] as GoodBorderContainer;
				var startTime:Number = getTimeFromX(annotationBox.x);
				var endTime:Number = getTimeFromX(annotationBox.x + annotationBox.width);
				if(startTime < time && time < endTime) {
					annotationBox.setBackground(0x00FF00);
				} else {
					annotationBox.setBackground(0xFFFF00);
				}
			}
		}
		
		/**
		 * Sets the length of the buffer to display 
		 * @param startTime		Where the buffer starts (used when we seek to a point and buffer from there)
		 * @param bufferLength	The number of seconds buffered (in front of the playhead)
		 * 
		 */		
		public function setBuffer(startTime:Number, bufferLength:Number):void {
			if(duration > 0) {
//				 We only want to show the buffer, when the duration has been set
				bufferProgress.x = getXFromTime(startTime);
				bufferProgress.width = Math.min(playhead.x + getXFromTime(bufferLength), background.width);
			}
		}
		
		/**
		 * Shows the line where a new annotation is starting 
		 * @param time	The time where the annotation is starting
		 * 
		 */		
		public function showStartAnnotationLineAt(time:Number):void {
			annotationTimeArea.visible = true;
			annotationTimeArea.x = getXFromTime(time); 
		} 
		
		public function showEndAnnotationLineAt(time:Number):void {
			annotationTimeArea.width = getXFromTime(time) - annotationTimeArea.x;
		}
			
		
		public function addAnnotations(annotations:Array):void {
			if(duration > 0) {
				trace("Add annotations to scrub bar");
				addAnnotationToScrubBar();
			} else {
				// Save the annotatins
				this.annotations = annotations;
			}
		}
		
		private function addAnnotationToScrubBar():void {
			
			while(annotationBoxes.length) {
				this.removeElement(annotationBoxes.pop());
			}
			
			for(var i:Number = 0; i < annotations.length; i++) {
				var annotationData:Model_Commentary = annotations[i] as Model_Commentary;
				
				var test:GoodBorderContainer = new GoodBorderContainer(0xFFFF00, 1);
				test.height = Math.random() * 40;
				test.y = -10;
				test.x = getXFromTime(annotationData.start);
				test.width = getXFromTime(annotationData.end) - getXFromTime(annotationData.start);;
				test.mouseChildren = false;
				test.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					trace("e.target.x", e.target.x);
					seekTo(getTimeFromX(e.target.x));
				});
				annotationBoxes.push(test);
				someShit.addElement(test);
			}	
		}
		
		private function mouseOut(e:MouseEvent):void {
			trace("mouse out");
			timeBox.visible = false;	
		}
		
		private function mouseDownSeek(e:MouseEvent):void {
			mouseDown = true;
			trace("Mouse down is", mouseDown);
		}
		
		private function mouseUpSeek(e:MouseEvent):void {
			mouseDown = false;
			var seekToTime:Number = getTimeFromX(e.target.mouseX);
			seekTo(seekToTime);
		}
		
		private function seekTo(time:Number):void {
			trace("Seeking to", time);
			setPlayheadTime(time);
			
			// Tell the viewer to seek to new position
			var event:IDEvent = new IDEvent(IDEvent.SEEK_TO, true);
			event.data.seekTo = time;
			this.dispatchEvent(event);
		}
		
		private function mouseMove(e:MouseEvent):void {
//			var seekToTime:Number = getTimeFromX(e.target.mouseX);
			var seekToTime:Number = getTimeFromX(background.mouseX);
			
			// Update the time overlay
			timeBoxText.text = TimeCount.secondsToTime(seekToTime);
//			timeBox.x = e.target.mouseX - timeBox.width / 2;
			timeBox.x = background.mouseX - timeBox.width / 2;
			timeBox.y = 0 - timeBox.height;
			timeBox.visible = true;
			
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			if(mouseDown) {
				seekTo(seekToTime);
			}
		}
		
		private function getTimeFromX(x:Number):Number {
			return x / background.width * duration;
		}
		
		private function getXFromTime(time:Number):Number {
			return time / duration * background.width;
		}
	}
}