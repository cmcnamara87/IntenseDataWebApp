package View.components.Annotation
{
	import mx.containers.Canvas;
	
	public class AnnotationPen extends Canvas implements AnnotationInterface
	{
		private var author:String; // The author of this annotation
		private var text:String; // The text of the annotation
		private var assetID:Number; // The ID of the annotation
		
		private var mediasWidth:Number; // The widht of hte media asset we are in
		private var mediasHeight:Number; // The height of the media asset we are in
		
		private var path:String; // The path for the pen drawing
		
		private var inLowerHalf:Boolean = false; // Says if this annotation is in the lower half of the screen
										// This is used when we dispayed the text overlay and its wokred out
										// by finding the point closest to the top, and if that is < 0.5
		
		/**
		 * Creates an Annotation Pen 
		 * @param assetID	The ID for the annotation
		 * @param author	The author of the annotation
		 * @param path		The path for pen tool drawing
		 * @param text(opt)	The text for the annotation 
		 * 
		 */		
		public function AnnotationPen(assetID:Number, author:String, path:String, mediasHeight:Number, mediasWidth:Number, text:String="") {
			super();
			
			// This is so the mouse events work correctly
			// otherwise it picks up the 'bordercontainerskin' class instead of
			// this Annotation class.
			this.mouseChildren = false;

			trace("dimensions of image", mediasWidth, mediasHeight);
			// Save the annotation data
			this.author = author;
			this.text = text;
			this.assetID = assetID;
			this.path = path;
			
			// Save the media assets size (we will need to draw it in relation to this
			this.mediasWidth = mediasWidth;
			this.mediasHeight = mediasHeight;
			
			// Setup the size
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			redraw(AnnotationToolbar.RED);
		}
		
		/**
		 * Redraws the path in this object based on this.mediasHeight and this.mediasWidth 
		 * 
		 */		
		private function redraw(color:uint):void {
			// Get out the path coordinates
			var pathCoordinates:XMLList = XML(path).item;
			this.graphics.clear();
			// Draw the path
			for each(var line:XML in pathCoordinates) {
				// The path is broken into line segements
				//trace("line", line.x1, line.x2, line.y1, line.y2, this.mediasHeight, this.mediasWidth);
				
				if(line.y1 > 0.5 || line.y2 > 0.5) {
					// The line goes into the lower half, so we can display the text overlay at the top
					inLowerHalf = true;	
				}
				
				//trace("drawing annotation (", line.x1 * mediasWidth, line.y1 * mediasHeight, ") (", line.x2 * mediasWidth, line.y2 * mediasHeight, ")");
				
				// Draw an invisible (well basically) big fat line, that goes underneath the thin actual annotation we see
				// This is so this fat line will trigger the mouse over, so we dont have to get exactly on top of the tiny line
				this.graphics.lineStyle(30, 0x00FF00, 0.001);
				this.graphics.beginFill(color, 0.01);

				this.graphics.moveTo(line.x1 * mediasWidth, line.y1 * mediasHeight);
				this.graphics.lineTo(line.x2 * mediasWidth, line.y2 * mediasHeight);
				
				this.graphics.lineStyle(5, color, 1);
				this.graphics.beginFill(color, 0.5);
				
				this.graphics.moveTo(line.x1 * mediasWidth, line.y1 * mediasHeight);
				this.graphics.lineTo(line.x2 * mediasWidth, line.y2 * mediasHeight);
			}
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
			this.mediasWidth = imageWidth;
			this.mediasHeight = imageHeight;
			redraw(AnnotationToolbar.RED);
		}
		
		public function highlight():void {
			redraw(0xFFFFFF);
		}
		
		
		public function unhighlight():void {
			redraw(AnnotationToolbar.RED);
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
			return inLowerHalf;	
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