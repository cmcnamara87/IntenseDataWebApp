package View.components.MediaViewer.VideoViewer
{
	import Controller.IDEvent;
	
	import View.components.IDButton;
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	import View.components.MediaViewer.SpaceViewer;
	import View.components.MediaViewer.TimelineViewer;
	
	import flash.events.MouseEvent;
	
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Label;

	public class VideoViewer extends TimelineViewer
	{
		// Variables
		private var videoPlaying:Boolean = false;
		private var videoDuration:Number; // The length of the video in seconds
		private var loadedOnce:Boolean = false;
		// GUI elements
		private var playButton:IDButton;
		private var videoHolder:VideoAndAnnotationHolder;
		private var videoScrubBar:VideoScrubBar;
		private var timeCount:TimeCount; // The current time in the toolbar e.g. 0:32/1:40
		
		public function VideoViewer()
		{
			super(MediaAndAnnotationHolder.MEDIA_VIDEO);
			
			// Just to save us from casting all the time.
			videoHolder = super.mediaHolder as VideoAndAnnotationHolder;
		}
		
		override protected function makeMedia():MediaAndAnnotationHolder {
			return new VideoAndAnnotationHolder(); 
		}
		
		override protected function addSpecificListeners():void {
			
			this.addEventListener(IDEvent.MEDIA_LOADED, function(e:IDEvent):void {
				if(!loadedOnce) {
					videoPlaying = true;
					playButton.label = "Pause";
					loadedOnce = true;
					var duration:Number = e.data.duration;
					videoScrubBar.setDuration(duration);
					timeCount.setDuration(duration);
					bottomToolbar.enabled = true;
				}

			});
			
			this.addEventListener(IDEvent.PLAYHEAD_POSITION, function(e:IDEvent):void {
				var playheadTime:Number = e.data.time;
				videoScrubBar.setPlayheadTimeTick(playheadTime);
				videoScrubBar.setBuffer(e.data.bufferStartTime, e.data.bufferLength);
				timeCount.setTime(playheadTime);
				videoHolder.readdAnnotationsToDisplay();
			});
			
			this.addEventListener(IDEvent.SEEK_TO, function(e:IDEvent):void {
				videoHolder.seekTo(e.data.seekTo);
			});
			
			
			
			this.addEventListener(IDEvent.START_TIME_SET, startTimeSet);
			this.addEventListener(IDEvent.END_TIME_SET, endTimeSet);
		}
		
		override public function addAnnotations(annotationsArray:Array):void {
			trace("VideoViewer: Adding Annotations");
			mediaHolder.addAnnotations(annotationsArray);
			videoScrubBar.addAnnotations(annotationsArray);
			super.hideAnnotationTextOverlay();
		}
		
		/* ============================================ TOOLBAR FUNCTIONS ==================================== */
		/**
		 * Makes the toolbar for the bottom of the display
		 * 
		 * Contains the play/pause buttons, scrub bar etc 
		 * 
		 */		
		override protected function makeBottomToolbar():void {
			playButton = new IDButton("Play");
			bottomToolbar.addElement(playButton);

			// Create the video scrub bar
			videoScrubBar = new VideoScrubBar();
			bottomToolbar.addElement(videoScrubBar);
			
			// Add the time count
			timeCount = new TimeCount();
			bottomToolbar.addElement(timeCount);
			
			// Add the actual size zoom button
			var actualSizeButton:IDButton = new IDButton("Actual Size");
			bottomToolbar.addElement(actualSizeButton);
			
			// Add the fit size button
			var fitButton:IDButton = new IDButton("Fit");
			bottomToolbar.addElement(fitButton);
			
			// Add the volume button
			var volumeButton:IDButton = new IDButton("Volume");
			bottomToolbar.addElement(volumeButton);
			
			// Setup the listeners
			playButton.addEventListener(MouseEvent.CLICK, playButtonClicked); 
			actualSizeButton.addEventListener(MouseEvent.CLICK, actualSizeButtonClicked);
			fitButton.addEventListener(MouseEvent.CLICK, fitButtonClicked);
			
			bottomToolbar.enabled = false;
		}
		
		/**
		 * Play or pause the video. Depending on whatever state its in.
		 * @param e
		 * 
		 */		
		private function playButtonClicked(e:MouseEvent):void {
			trace("The play button was clicked");
			if(videoPlaying) {
				// We are pausing the video
				videoHolder.pause();
				// so the button was change to 'play'
				playButton.label = "Play";				
				videoPlaying = false;
			} else {
				// We are playing the video, 
				videoHolder.play();
				//so the button will change to pause
				playButton.label = "Pause";
				videoPlaying = true;
			}
		}
		
		private function fitButtonClicked(e:MouseEvent):void {
			var scaleWidth:Number = scrollerAndOverlayGroup.width / mediaHolder.width;
			var scaleHeight:Number = scrollerAndOverlayGroup.height / mediaHolder.height;
			var scaleX:Number = Math.max(Math.min(scaleWidth, scaleHeight), 0.1);
			var scaleY:Number = Math.max(Math.min(scaleWidth, scaleHeight), 0.1);
			
			scaleMedia(scaleX, scaleY);
		}
		
		private function actualSizeButtonClicked(e:MouseEvent):void {
			scaleMedia(1, 1);
		}
		/* ====================================== END OF TOOLBAR FUNCTIONS ==================================== */
		
		
		/* ====================================== TIME ANNOTATION FUNCTIONS ==================================== */
		
		/**
		 * The set start time button was clicked in the annotaiton toolbar
		 * Tell the scrub bar to display the start annotation line
		 * and tell the videoholder to record the start annotation time 
		 * @param e
		 * 
		 */		
		private function startTimeSet(e:IDEvent):void {
			// Get out the current time
			var currentTime:Number = videoHolder.getPlayheadTime();
			trace("Setting start time", currentTime);
			
			// Tell the annotation toolbar to display it
			annotationToolbar.setStartTimeDisplay(TimeCount.secondsToTime(currentTime));
			
			// Tell the scrub bar to show the start annotation line
			videoScrubBar.showStartAnnotationLineAt(currentTime);
			
			// Tell the holder we are starting an annotation at this time.
			videoHolder.setAnnotationStartTime(currentTime);	
		}
		
		private function endTimeSet(e:IDEvent):void {
			// Get out the current time
			var currentTime:Number = videoHolder.getPlayheadTime();
			trace("Setting start time", currentTime);
			
			// Tell the annotation toolbar to display it
			annotationToolbar.setEndTimeDisplay(TimeCount.secondsToTime(currentTime));
			
			// Tell the scrub bar to show the start annotation line
			videoScrubBar.showEndAnnotationLineAt(currentTime);
			
			// Tell the holder we are starting an annotation at this time.
			videoHolder.setAnnotationEndTime(currentTime);	
		}
	}
}