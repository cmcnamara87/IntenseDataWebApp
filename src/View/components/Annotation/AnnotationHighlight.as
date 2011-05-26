package View.components.Annotation
{
	import Controller.IDEvent;
	
	import View.components.MediaViewer.PDFViewer.PDF;
	
	import spark.components.BorderContainer;

	public class AnnotationHighlight extends BorderContainer implements AnnotationInterface
	{
		private var startX:Number;
		private var startY:Number;
		private var page1:Number;
		private var startTextIndex:Number;
		private var endTextIndex:Number;
		private var pdf:PDF;
		
		public function AnnotationHighlight(startX:Number, startY:Number, page1:Number, startTextIndex:Number, endTextIndex:Number, pdf:PDF)
		{
			trace("Highlight created");
			this.percentX = percentX;
			this.percentX = startY;
			this.page1 = page1;
			this.startTextIndex = startTextIndex;
			this.endTextIndex = endTextIndex;
			this.pdf = pdf;
		}
		
		/* PUBLIC FUNCTIONS */
		/**
		 * Tells the controller to save this annotation in the database. 
		 * 
		 */		
		public function save():void {
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_HIGHLIGHT, true);
			myEvent.data.startX = startX;
			myEvent.data.startY = startY;
			myEvent.data.page1 = page1;
			myEvent.data.startTextIndex = startTextIndex;
			myEvent.data.endTextIndex = endTextIndex;
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
			this.setStyle('borderColor', 0xFFFFFF);
			this.setStyle('backgroundColor',0xFFFFFF);
			this.setStyle('backgroundAlpha', 0.02); 
		}
		
		
		public function unhighlight():void {
			this.setStyle('backgroundColor',0xFF0000);
			this.setStyle('backgroundAlpha', 0.05); 
			this.setStyle('borderColor', 0xBB0000);
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