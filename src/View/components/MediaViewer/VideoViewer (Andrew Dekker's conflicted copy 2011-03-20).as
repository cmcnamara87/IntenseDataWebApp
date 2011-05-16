package View.components.MediaViewer
{
	import Model.Model_Commentary;
	
	import View.components.Annotation.Annotation;
	import View.components.Annotation.AnnotationToolbar;
	
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.VideoPlayer;
	import spark.layouts.VerticalLayout;

	public class VideoViewer extends MediaViewer implements MediaViewerInterface
	{
		private var annotationToolbar:AnnotationToolbar; // The toolbar for making a new annotation
		private var sourceURL:String; // The source of the video
		private var videoPlayer:VideoPlayer; // The Video player
		private var annotationsArray:Array; // The array of the annotations for this image
		
		private var annotationsGroup:Group; // THe group containing the annotations
		private var newAnnotationsGroup:Group; // Where we put the new annotation while we are drawing them
		
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
			var videoAndAnnotationsGroup:Group = new Group();
			videoAndAnnotationsGroup.percentHeight = 100;
			videoAndAnnotationsGroup.percentWidth = 100;
			this.addElement(videoAndAnnotationsGroup);
			
			// Create the video player
			videoPlayer = new VideoPlayer();
			videoPlayer.percentHeight = 100;
			videoPlayer.percentWidth = 100;
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
			image.addEventListener(Event.COMPLETE, sourceLoaded);
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
			videoPlayer.source = sourceURL;
		}
		
		
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
//			annotationsAreLoaded = true;
			
//			if(isImageLoaded) {
				// This image is loaded, add the annotations now
			this.addAnnotationsToView();
//			}
		}
		
		
		/* ==================================== HELPER FUNCTIONS ========================= */
		/**
		 * Adds the annotations boxes to the image.
		 *  
		 * Clears all current annotations before re-adding annotations saved in the 
		 * annotations Array. 
		 * 
		 */		
		private function addAnnotationsToView():void {
			
//			if(image.width == 0) {
//				setTimeout(addAnnotationsToView, 1000);
//				return;
//			}
			
			clearAnnotations();
			
//			trace("image dimensions:", image.width, image.height);
			for(var i:Number = 0; i < annotationsArray.length; i++) {
				
				var annotationData:Model_Commentary = annotationsArray[i] as Model_Commentary;
				
				var annotation:Annotation = new Annotation(
					annotationData.base_asset_id,
					annotationData.meta_creator, 
					annotationData.annotation_text,
					annotationData.annotation_height, 
					annotationData.annotation_width, 
					annotationData.annotation_x,
					annotationData.annotation_y,
					videoPlayer.videoObject.videoWidth,
					videoPlayer.videoObject.videoHeight
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