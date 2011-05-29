package View.components.Annotation
{
	import Controller.IDEvent;
	
	import Model.Model_Commentary;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	
	public class AnnotationBox extends Canvas implements AnnotationInterface
	{

		private var author:String; // The author of this annotation
		private var text:String; // The text of the annotation
		private var assetID:Number; // The ID of the annotation
		
		private var xCoor:Number;
		private var yCoor:Number;
		
		private var actualWidth:Number;
		private var actualHeight:Number;

		/**
		 * An individual annotation display 
		 * @param assetID			The ID of the annotation (from the MediaFlux database)
		 * @param author			The author of the annotation (currently the username, may change to full name)//TODO
		 * @param text				The text content of the annotation
		 * @param percentHeight		How tall the annotation is, as a percentage of the assets size (used for scaling purposes)
		 * @param percentWidth		How wide the annotation is as a percetange of the assets size
		 * @param percentX			How far along the x axis the annotation occurs, as a percentage
		 * @param percentY			How far along the y axis the annotation occurs, as a percentage
		 * @param imageWidth		The width of the image
		 * @param imageHeight		The height of the image
		 * 
		 */		
		public function AnnotationBox(assetID:Number, author:String, text:String, height:Number, width:Number,
									xCoor:Number, yCoor:Number)
		{
			super();
			
			// This is so the mouse events work correctly
			// otherwise it picks up the 'bordercontainerskin' class instead of
			// this Annotation class.
			this.mouseChildren = false;
			
			// Save the annotation data
			this.author = author;
			this.text = text;
			this.assetID = assetID;
			this.xCoor = xCoor;
			this.yCoor = yCoor;
			this.actualHeight = height;
			this.actualWidth = width;
			
			// Setup size
			this.height = height;
			this.width = width;
			
			// Setup position
			this.x = this.xCoor;
			this.y = this.yCoor;
			
			// Setup color
			this.setStyle('backgroundColor',0xFF0000);
			this.setStyle('backgroundAlpha', 0.05); 
			this.setStyle('borderStyle', 'solid');
			this.setStyle('borderColor', 0xBB0000);
			
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
			trace("Saving an annotation box");
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_BOX, true);
			myEvent.data.xCoor = xCoor;
			myEvent.data.yCoor = yCoor;
			myEvent.data.width = actualWidth;
			myEvent.data.height = actualHeight;
			myEvent.data.annotationText = text;
			this.dispatchEvent(myEvent);
			
			
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
	}
}