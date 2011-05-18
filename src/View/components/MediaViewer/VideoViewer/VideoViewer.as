package View.components.MediaViewer.VideoViewer
{
	import Model.Model_Commentary;
	
	import View.components.Annotation.AnnotationBox;
	import View.components.Annotation.AnnotationToolbar;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.MediaViewerInterface;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.events.ResizeEvent;
	import mx.graphics.SolidColor;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.VideoDisplay;
	import spark.components.VideoPlayer;
	import spark.layouts.VerticalLayout;
	
	
	public class VideoViewer extends MediaViewer implements MediaViewerInterface
	{
		private var annotationToolbar:AnnotationToolbar; // The toolbar for making a new annotation
		private var sourceURL:String; // The source of the video
		//private var videoPlayer:VideoPlayer; // The Video player
		private var videoPlayer:VideoPlaybackScreen;
		//private var videoPlayer:View.components.MediaViewer.VideoViewer.VideoViewer;
		private var annotationsArray:Array; // The array of the annotations for this image
		
		private var annotationsGroup:Group; // THe group containing the annotations
		private var newAnnotationsGroup:Group; // Where we put the new annotation while we are drawing them
		
		private var videoIsLoaded:Boolean = false; // True when an image has been loaded
		private var annotationsAreLoaded:Boolean = false; // True when the annotations have been loaded
		
		private var videoAndAnnotationsGroup:Group;
		
		private var paused:Boolean;
		
		public function VideoViewer()
		{
			super();
			
			// Setup the size
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			// Setup the layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Setup background
			this.backgroundFill = new SolidColor(0x000000);
			
			// Create the Annotation Tools toolbar
			// Will show 'Save' and 'Cancel' Buttons
			annotationToolbar = new AnnotationToolbar();
			this.addElement(annotationToolbar);
			
			// Create the group for the Video player, the Annotations, and the New Annotations
			videoAndAnnotationsGroup = new Group();
			videoAndAnnotationsGroup.percentHeight = 100;
			videoAndAnnotationsGroup.percentWidth = 100;
			this.addElement(videoAndAnnotationsGroup);
		
			// Create the video player
			videoPlayer = new VideoPlaybackScreen();
			//videoPlayer.autoPlay = true;
//			videoPlayer.percentHeight = 100;
//			videoPlayer.percentWidth = 100;
			videoAndAnnotationsGroup.addElement(videoPlayer);
			
			// Where we are going to put the annotations
			annotationsGroup = new Group();
			annotationsGroup.percentHeight = 100;
			annotationsGroup.percentWidth = 100;
			videoAndAnnotationsGroup.addElement(annotationsGroup);
			
			// Create New annotations group
			// This is where the temporary place where we are drawing 
			// the new annotations (while they are being drawn)
			// once they are saved, they go to the annotationsGroup
			newAnnotationsGroup = new Group();
			newAnnotationsGroup.percentHeight = 100;
			newAnnotationsGroup.percentWidth = 100;
			videoAndAnnotationsGroup.addElement(newAnnotationsGroup);
			
			// Event Listeners
			videoPlayer.addEventListener(Event.COMPLETE, sourceLoaded);
			videoPlayer.addEventListener(ResizeEvent.RESIZE, videoResized);
//			videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, vidPlyr_mediaPlayerStateChangeHandler);
		}
		
		
		/**
		 * Loads an Image URL. Called by @see MediaView
		 * @param url	The URL of the image to load.
		 * 
		 */		
		override public function load(url:String):void {
			trace("Loading Video:", url);
			// Save the URL
			sourceURL = url;
			
			trace("Adding Image:", sourceURL);
			// Load the Image from the URL
			videoPlayer.load(sourceURL);
			
			videoIsLoaded = true;
			
//			trace('group', videoAndAnnotationsGroup.width, videoAndAnnotationsGroup.height);
//			videoPlayer.width = videoAndAnnotationsGroup.width;
//			videoPlayer.height = videoAndAnnotationsGroup.height;
			
			if(annotationsAreLoaded) {
				trace("image is loaded, now adding the annotations");
				this.addAnnotationsToView();
			}
		}
		
//		protected function vidPlyr_mediaPlayerStateChangeHandler(evt:MediaPlayerStateChangeEvent):void {
//			trace("Player State", evt.state);
//			var hello:MediaPlayer = new MediaPlayer();
//			hello.
//			switch (evt.state) {
//				case MediaPlayerState.LOADING:
//					Alert.show("Loading");
//					break;
//				case MediaPlayerState.PLAYBACK_ERROR:
//					Alert.show("Unable to load video", evt.state);
//					videoPlayer.errorString = "Unable to load video";
//					break;
//			}
//		}
		
		override public function enterNewAnnotationMode():void {
			trace("Showing annotation toolbar");	
			annotationToolbar.show();
		}
		
		/**
		 * Removes all the current annotations 
		 * 
		 */		
		public function clearAnnotations():void {
			annotationsGroup.removeAllElements();
		}
		
		override public function addAnnotations(annotationsArray:Array):void {
			trace("Adding Annotatio");
			this.annotationsArray = annotationsArray;
			
			// Set the annotations to loaded
			annotationsAreLoaded = true;
			
			if(videoIsLoaded) {
				// This image is loaded, add the annotations now
				this.addAnnotationsToView();
			}
		}
		
		/* ============================== EVENT LISTENER FUNCTIONS ======================= */
		/**
		 * The image to display has been loaded.
		 * If the image is bigger than the container, make it fit
		 * Otherwise, let it be its regular size. 
		 * @param e
		 * 
		 */		
		private function sourceLoaded(e:Event):void {
			trace("Video is loaded");
			//			// Set the dimensions of the image to be the dimensions of its image conent
			//			image.width = image.contentWidth;
			//			image.height = image.contentHeight;
			//			
			//			// Save the actual size of the image (used when we resize the image)
			//			actualImageHeight = image.contentHeight;
			//			actualImageWidth = image.contentWidth;
			
			videoIsLoaded = true;
			
			// Load/Reload the annotations (because the image's size may have changed if its been reloaded)
			// or if its the first load, its going to change a lot :P (from 0 to something :P)
			if(annotationsAreLoaded) {
				trace("image is loaded, now adding the annotations");
				this.addAnnotationsToView();
			}
		}
		
		private function videoResized(e:ResizeEvent):void {
			trace("video resized");
			
		}
		
		/* ==================================== HELPER FUNCTIONS ========================= */
		
		private function isPaused(value:Boolean):void {
			paused = value;
		}
		/**
		 * Adds the annotations boxes to the image.
		 *  
		 * Clears all current annotations before re-adding annotations saved in the 
		 * annotations Array. 
		 * 
		 */		
		private function addAnnotationsToView():void {
			
			// Even though this function is called, when the video is loaded
			// We need to just wait to make sure it has actually loaded and its appearing on the stage
			// So we wait for the videoObject to load (when it finds the file) and when it has a width
			// (when its added to the stage)
//			if(!videoPlayer.videoObject || videoPlayer.videoObject.videoWidth == 0) {
//				setTimeout(addAnnotationsToView, 1000);
//				return;
//			}
			
			clearAnnotations();
			
//			trace("Video stuff", videoPlayer.videoObject.videoWidth,videoPlayer.videoObject.videoHeight);
				
//			trace("image dimensions:", image.width, image.height);
			for(var i:Number = 0; i < annotationsArray.length; i++) {
				
				var annotationData:Model_Commentary = annotationsArray[i] as Model_Commentary;
				
				trace("Adding annotation", annotationData.annotation_text);
				
				var annotation:AnnotationBox = new AnnotationBox(
					annotationData.base_asset_id,
					annotationData.meta_creator, 
					annotationData.annotation_text,
					annotationData.annotation_height, 
					annotationData.annotation_width, 
					annotationData.annotation_x,
					annotationData.annotation_y,
					videoPlayer.height,//videoObject.videoWidth,
					videoPlayer.width//videoPlayer.videoObject.videoHeight
				);
				//				annotation.alpha = 0;
				
				annotationsGroup.addElement(annotation);
				
				//				if(!annotationsAreLoaded) {
				// We havent previously loaded the annotaitons
				// If we had, we would just be replacing them, so we dont want them to
				// fade in. 
				//					Lib.it.transitions.Tweener.addTween(annotation, {transition:"easeInOutCubic", time:1, alpha:1});
				//				} else {
				//					annotation.alpha = 1;
				//				}
				
				// Listen for this annotation being mouse-overed
//				annotation.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
//				annotation.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
			}
		}
	}
}