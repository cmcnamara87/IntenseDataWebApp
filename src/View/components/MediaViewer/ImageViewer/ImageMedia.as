package View.components.MediaViewer.ImageViewer
{
	import Controller.IDEvent;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class ImageMedia extends Group
	{
		private var image:Image = new Image();
		
		public function ImageMedia(sourceURL:String) {
			super();
			this.addElement(image);
			trace("Loading image from source", sourceURL);
			image.source = sourceURL;
			
			
			// Listen for loading progress (to display hte loading graphics)
			image.addEventListener(ProgressEvent.PROGRESS, progress);
			
			image.addEventListener(Event.COMPLETE, sourceLoaded);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
				trace("ImageMedia:EVENT - Removing Image Media");
				image.removeEventListener(Event.COMPLETE, sourceLoaded);
				image.removeEventListener(ProgressEvent.PROGRESS, progress);
			});
		}
		
		private function progress(e:ProgressEvent):void {
			dispatchEvent(e);
		}
		private function sourceLoaded(e:Event):void {
			trace("image size", image.width, image.height, image.contentWidth, image.contentHeight);
			this.width = image.contentWidth;
			this.height = image.contentHeight;
			
			// Tell the PDFViewer that the PDF has finished loading
			var myEvent:IDEvent = new IDEvent(IDEvent.MEDIA_LOADED, true);
			dispatchEvent(myEvent);	
		}
	}
}