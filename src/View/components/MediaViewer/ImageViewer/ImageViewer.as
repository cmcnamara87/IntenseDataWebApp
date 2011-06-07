package View.components.MediaViewer.ImageViewer
{
	import Lib.it.transitions.Tweener;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.HSlider;
	import spark.components.Label;
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	import View.components.MediaViewer.SpaceViewer;

	public class ImageViewer extends SpaceViewer
	{
		public function ImageViewer()
		{
			super(MediaAndAnnotationHolder.MEDIA_IMAGE);
		}
		
		override protected function makeMedia():MediaAndAnnotationHolder {
			trace("asdfasdf", mediaType);
			return new MediaAndAnnotationHolder(mediaType);
		}
		
		override protected function makeBottomToolbar():void {
			var zoomOutLabel:Label = new Label();
			zoomOutLabel.text = "Zoom Out";
			sliderResizerContainer.addElement(zoomOutLabel);
			
			// Create the slider/resizer
			resizeSlider = new HSlider();
			resizeSlider.maximum = 200;
			resizeSlider.minimum = 10;
			resizeSlider.value = 100;
			//resizeSlider.liveDragging = true;
			//			slider.snapInterval = 1;
			sliderResizerContainer.addElement(resizeSlider);
			this.addElement(sliderResizerContainer);
			
			var zoomInLabel:Label = new Label();
			zoomInLabel.text = 'Zoom In';
			sliderResizerContainer.addElement(zoomInLabel);
			
			
			// Add 'Fit' button for the zoom
			var fitButton:spark.components.Button = new spark.components.Button();
			fitButton.percentHeight = 100;
			fitButton.label = "Fit";
			sliderResizerContainer.addElement(fitButton);
			
			// Add '100%' button for the zoom
			var percentButton:spark.components.Button = new spark.components.Button();
			percentButton.percentHeight = 100;
			percentButton.label = '100%';
			sliderResizerContainer.addElement(percentButton);
			
			resizeSlider.addEventListener(Event.CHANGE, resizeImage);
			
			percentButton.addEventListener(MouseEvent.CLICK, percentButtonClicked);
			fitButton.addEventListener(MouseEvent.CLICK, fitButtonClicked);
		}
		
		/**
		 * Resizes the image when the slider is moved 
		 * @param e	The slider change event
		 * 
		 */		
		private function resizeImage(e:Event):void {
			trace("resizing", (e.target as HSlider).value);
			var resizeFactor:Number = (e.target as HSlider).value / 100; 
			
			// Resize the image by the scaling facotr
			scaleMedia(resizeFactor, resizeFactor);
		}
		
		/**
		 * The resize to 100% button was clicked. Resize the image to
		 * its actual size. 
		 * @param e
		 * 
		 */		
		private function percentButtonClicked(e:MouseEvent):void {
			trace("100% button clicked");
			scaleMedia(1, 1);
			resizeSlider.value = 100;
		}
		
		/**
		 * The resize to fit the width of the screen button was clicked 
		 * @param e
		 * 
		 */		
		private function fitButtonClicked(e:MouseEvent):void {
			trace("Fit button clicked");
			// For image resizing,
			// Fit button - fits the entire image to display in the pane
			var scaleWidth:Number = scrollerAndOverlayGroup.width / media.width;
			var scaleHeight:Number = scrollerAndOverlayGroup.height / media.height;
			var scaleX:Number = Math.max(Math.min(scaleWidth, scaleHeight), 0.1);
			var scaleY:Number = Math.max(Math.min(scaleWidth, scaleHeight), 0.1);
			
			scaleMedia(scaleX, scaleY);
			
			resizeSlider.value = Math.max(scaleX * 100, 10);				
		}
	}
}