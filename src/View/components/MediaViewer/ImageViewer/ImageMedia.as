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
			image.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				//trace("loading event 2", e.bytesLoaded, e.bytesTotal);
				dispatchEvent(e);
			});
			
			image.addEventListener(Event.COMPLETE, sourceLoaded);
		
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