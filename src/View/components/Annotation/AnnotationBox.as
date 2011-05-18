package View.components.Annotation
{
	import Controller.RecensioEvent;
	
	import Model.Model_Commentary;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	
	public class AnnotationBox extends Canvas implements AnnotationInterface
	{

		private var author:String; // The author of this annotation
		private var text:String; // The text of the annotation
		private var assetID:Number; // The ID of the annotation
		
		private var percentX:Number;
		private var percentY:Number;
		

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
		public function AnnotationBox(assetID:Number, author:String, text:String, percentHeight:Number, percentWidth:Number,
									percentX:Number, percentY:Number, imageWidth:Number, imageHeight:Number)
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
			this.percentX = percentX;
			this.percentY = percentY;
			
			// Setup size
			this.percentHeight = percentHeight;
			this.percentWidth = percentWidth;
			
			// Setup position
			this.x = this.percentX * imageWidth;
			this.y = this.percentY * imageHeight;
			
			// Setup color
			this.setStyle('backgroundColor',0xFF0000);
			this.setStyle('backgroundAlpha', 0.05); 
			this.setStyle('borderStyle', 'solid');
			this.setStyle('borderColor', 0xBB0000);
//			this.setStyle('borderAlpha', 0.5);
			//this.backgroundFill = new SolidColor(0xFF0000, 0.5);
			//this.borderStroke = new SolidColorStroke(0xBB0000, 0.5);
		}
		
		/* PUBLIC FUNCTIONS */
		
		
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