package View.components.MediaViewer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.HSlider;
	import spark.components.Label;

	public class ImageViewer extends Viewer
	{
		public function ImageViewer(mediaType:String)
		{
			super(mediaType);
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
			media.scaleX = resizeFactor;
			media.scaleY = resizeFactor;
		}
		
		/**
		 * The resize to 100% button was clicked. Resize the image to
		 * its actual size. 
		 * @param e
		 * 
		 */		
		private function percentButtonClicked(e:MouseEvent):void {
			trace("100% button clicked");
			if(mediaType == MediaAndAnnotationHolder.MEDIA_IMAGE) {
				media.scaleX = 1;
				media.scaleY = 1;
				resizeSlider.value = 100;
			} else if (mediaType == MediaAndAnnotationHolder.MEDIA_PDF) {
				media.scaleX = scrollerAndOverlayGroup.width / media.width;
				media.scaleY = scrollerAndOverlayGroup.width / media.width;
				resizeSlider.value = scrollerAndOverlayGroup.width / media.width * 100;
			}
		}
		
		/**
		 * The resize to fit the width of the screen button was clicked 
		 * @param e
		 * 
		 */		
		private function fitButtonClicked(e:MouseEvent):void {
			trace("Fit button clicked");
			// work out which side (height or width) is further out of the frame
			if(mediaType == MediaAndAnnotationHolder.MEDIA_PDF) {
				// for PDF resizing,
				// Fit button - fits 1 page
				media.scaleX = scrollerAndOverlayGroup.height / media.getFitHeightSize();
				media.scaleY = scrollerAndOverlayGroup.height / media.getFitHeightSize();
				resizeSlider.value = scrollerAndOverlayGroup.height / media.getFitHeightSize() * 100;
				
			} else if (mediaType == MediaAndAnnotationHolder.MEDIA_IMAGE) {
				// For image resizing,
				// Fit button - fits the entire image to display in the pane
				var scaleWidth:Number = scrollerAndOverlayGroup.width / media.width;
				var scaleHeight:Number = scrollerAndOverlayGroup.height / media.height;
				media.scaleX = Math.max(Math.min(scaleWidth, scaleHeight), 0.1);
				media.scaleY = Math.max(Math.min(scaleWidth, scaleHeight), 0.1);
				
				resizeSlider.value = Math.max(Math.min(scaleWidth, scaleHeight) * 100, 10);	
			}
			
		}
	}
}