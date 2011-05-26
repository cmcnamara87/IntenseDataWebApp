package View.components.Annotation
{
	import Controller.IDEvent;
	
	import View.components.MediaViewer.PDFViewer.PDF;
	
	import spark.components.BorderContainer;

	public class AnnotationHighlight extends BorderContainer implements AnnotationInterface
	{
		private var percentX:Number;
		private var percentY:Number;
		private var page1:Number;
		private var startTextIndex:Number;
		private var endTextIndex:Number;
		private var pdf:PDF;
		private var assetID:Number;
		private var author:String;
		private var text:String;
		
		public function AnnotationHighlight(assetID:Number, author:String, text:String, percentX:Number, percentY:Number, page1:Number, startTextIndex:Number, endTextIndex:Number, pdf:PDF)
		{
			trace("Highlight created");
			// Save the annotation data
			this.assetID = assetID;
			this.author = author
			this.text = text;
			this.percentX = percentX;
			this.percentY = percentY;
			this.page1 = page1;
			this.startTextIndex = startTextIndex;
			this.endTextIndex = endTextIndex;
			this.pdf = pdf;
			
			// Setup size
			this.height = 10;
			this.width = 10
			
			// Setup position
			this.x = this.percentX * pdf.width * pdf.scaleX;
			this.y = this.percentY * pdf.height * pdf.scaleY;
			
			// Setup color
			this.setStyle('backgroundColor',0xFFFF00);
			this.setStyle('backgroundAlpha', 0.9); 
			this.setStyle('borderStyle', 'solid');
			this.setStyle('borderColor', 0x000000);
			
			// This is so the mouse events work correctly
			// otherwise it picks up the 'bordercontainerskin' class instead of
			// this Annotation class.
			this.mouseChildren = false;
		}
		
		/* PUBLIC FUNCTIONS */
		/**
		 * Tells the controller to save this annotation in the database. 
		 * 
		 */		
		public function save():void {
			trace("Saving annotation highlight");
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_HIGHLIGHT, true);
			myEvent.data.percentX = percentX;
			myEvent.data.percentY = percentY;
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
			this.x = this.percentX * imageWidth;
			this.y = this.percentY * imageHeight;
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
			return this.percentY > 0.5	
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
	}
}