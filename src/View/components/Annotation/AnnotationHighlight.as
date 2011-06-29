package View.components.Annotation
{
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import View.components.MediaViewer.PDFViewer.PDF;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.graphics.BitmapFill;
	
	import spark.components.BorderContainer;

	public class AnnotationHighlight extends BorderContainer implements AnnotationInterface
	{
		private var xCoor:Number;
		private var yCoor:Number;
		private var page1:Number;
		private var startTextIndex:Number;
		private var endTextIndex:Number;
		private var assetID:Number;
		private var author:String;
		private var text:String;
		private var pdf:PDF;
		
		public function AnnotationHighlight(assetID:Number, author:String, text:String, xCoor:Number, yCoor:Number, page1:Number, startTextIndex:Number, endTextIndex:Number, pdf:PDF)
		{
			trace("Highlight created", xCoor, yCoor);
			// Save the annotation data
			this.assetID = assetID;
			this.author = author
			this.text = text;
			this.xCoor = xCoor;
			this.yCoor = yCoor;
			this.page1 = page1;
			this.startTextIndex = startTextIndex;
			this.endTextIndex = endTextIndex;
			this.pdf = pdf;
			
			// Setup size
			this.height = 15;
			this.width = 15;
			
			// Setup position
			this.x = this.xCoor;
			this.y = this.yCoor;
			
			// Setup color
			var icon:BitmapFill = new BitmapFill();
			icon.source = AssetLookup.getPostItIcon();
			this.backgroundFill = icon;
			
//			this.setStyle('backgroundColor',0x00AA00);
//			this.setStyle('backgroundAlpha', 0.3); 
//			this.setStyle('borderStyle', 'solid');
//			this.setStyle('borderColor', 0x00AA00);
			this.setStyle('borderVisible', false);
			// This is so the mouse events work correctly
			// otherwise it picks up the 'bordercontainerskin' class instead of
			// this Annotation class.
			this.mouseChildren = false;
			
			this.addEventListener(MouseEvent.MOUSE_OVER, function(e:Event):void {
				var annotation:AnnotationInterface = e.target as AnnotationInterface;
				annotation.highlight();
				
				// tell the viewer to display the overlay to go with this
				var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_MOUSE_OVER, true);
				myEvent.data.text = annotation.getText();
				myEvent.data.author = annotation.getAuthor();
				dispatchEvent(myEvent);
			});
			
			this.addEventListener(MouseEvent.MOUSE_OUT, function(e:Event):void {
				trace("Mouse out!!!");
				var annotation:AnnotationInterface = e.target as AnnotationInterface;
				annotation.unhighlight();
				// tell the viewer to hide the annotation text overlay
				dispatchEvent(new IDEvent(IDEvent.ANNOTATION_MOUSE_OUT, true));
			});
			
		}
		
		/* PUBLIC FUNCTIONS */
		/**
		 * Tells the controller to save this annotation in the database. 
		 * 
		 */		
		public function save():void {
			trace("Saving annotation highlight, x,y", this.xCoor, this.yCoor);
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_HIGHLIGHT, true);
			myEvent.data.xCoor = xCoor;
			myEvent.data.yCoor = yCoor;
			myEvent.data.page1 = page1;
			myEvent.data.startTextIndex = startTextIndex;
			myEvent.data.endTextIndex = endTextIndex;
			myEvent.data.text = text;
			trace("Trying to dispatch event");
			this.dispatchEvent(myEvent);
		}
		
		/**
		 * Called when the image is resized, so we need to recalculate the X and Y positions
		 * of the annotation, so it scales up, as the image does (or down lol) 
		 * @param imageWidth
		 * @param imageHeight
		 * 
		 */		
		public function readjust(imageWidth:Number, imageHeight:Number):void {
			// Redo position (since we want it to be a percentage of the size of the image
			this.x = this.xCoor * imageWidth;
			this.y = this.yCoor * imageHeight;
		}
		
		public function highlight():void {
			pdf.highlightFromIndexes(page1, startTextIndex, endTextIndex, true);
			this.alpha = 0.1;
		}
		
		
		public function unhighlight():void {
			pdf.highlightFromIndexes(page1, startTextIndex, endTextIndex, false);
			this.alpha = 1;
		}
		
		/**
		 * Gets out the ID of the asset 
		 * @return The assets ID
		 * 
		 */		
		public function getID():Number {
			return assetID;
		}
		
		public function isInLowerHalf():Boolean {
			return this.yCoor > 0.5	
		}
		
		/**
		 * Gets out the author of this annotation 
		 * @return author of this annotation
		 * 
		 */		
		public function getAuthor():String {
			return author;
		}
		
		/**
		 * Gets out the text of this annotation 
		 * @return The text of this annotation
		 * 
		 */		
		public function getText():String {
			return text;
		}
		
		public function getX():Number {
			return this.x;
		}
		public function getY():Number {
			return this.y;
		}
	}
}