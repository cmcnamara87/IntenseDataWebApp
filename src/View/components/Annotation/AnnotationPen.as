package View.components.Annotation
{
	import Controller.IDEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	
	public class AnnotationPen extends Canvas implements AnnotationInterface
	{
		private var author:String; // The author of this annotation
		private var text:String; // The text of the annotation
		private var assetID:Number; // The ID of the annotation
		
		private var path:String; // The path for the pen drawing
		
		private var inLowerHalf:Boolean = false; // Says if this annotation is in the lower half of the screen
										// This is used when we dispayed the text overlay and its wokred out
										// by finding the point closest to the top, and if that is < 0.5
		
		private var topXCoor:Number = 999999999;
		private var topYCoor:Number = 999999999; // THe smallest y coor for the pen drawing (this is, the top of it)
		
		/**
		 * Creates an Annotation Pen 
		 * @param assetID	The ID for the annotation
		 * @param author	The author of the annotation
		 * @param path		The path for pen tool drawing
		 * @param text(opt)	The text for the annotation 
		 * 
		 */		
		public function AnnotationPen(assetID:Number, author:String, path:String, text:String="") {
			super();
			
			// This is so the mouse events work correctly
			// otherwise it picks up the 'bordercontainerskin' class instead of
			// this Annotation class.
			this.mouseChildren = false;

			// Save the annotation data
			this.author = author;
			this.text = text;
			this.assetID = assetID;
			this.path = path;
			
			redraw(0x00AA00);
			
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
		
		/**
		 * Saves this annotation in the database 
		 * @return 
		 * 
		 */		
		public function save():void{
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_PEN, true);
			myEvent.data.path = path;
			myEvent.data.text = text;
			this.dispatchEvent(myEvent);
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
//			for each(var line:XML in pathCoordinates) {
//				this.graphics.lineStyle(5, 0x888888, 1);
//				this.graphics.moveTo(line.x1, line.y1);
//				this.graphics.lineTo(line.x2, line.y2);	
//			}
			for each(var line:XML in pathCoordinates) {
				// The path is broken into line segements
				//trace("line", line.x1, line.x2, line.y1, line.y2, this.mediasHeight, this.mediasWidth);
				
				if(line.y1 < topYCoor) {
					topYCoor = line.y1;
				} 
				if(line.y2 < topYCoor) {
					topYCoor = line.y2;
				}
				if(line.x1 < topXCoor) {
					topXCoor = line.x1;
				}
				if(line.x2 < topXCoor) {
					topXCoor = line.x2;
				}
				
				if(line.y1 > 0.5 || line.y2 > 0.5) {
					// The line goes into the lower half, so we can display the text overlay at the top
					inLowerHalf = true;	
				}
				
				// Draw an invisible (well basically) big fat line, that goes underneath the thin actual annotation we see
				// This is so this fat line will trigger the mouse over, so we dont have to get exactly on top of the tiny line
				this.graphics.lineStyle(20, 0x00FF00, 0.001);
				this.graphics.beginFill(color, 0.01);
				this.graphics.moveTo(line.x1, line.y1);
				this.graphics.lineTo(line.x2, line.y2);
				
				// Draw coloured line
//				this.graphics.lineStyle(2, color, 1);
//				this.graphics.beginFill(color, 0.5);
//				this.graphics.moveTo(line.x1, line.y1);
//				this.graphics.lineTo(line.x2, line.y2)
				
				this.graphics.lineStyle(3, color, 1);
				this.graphics.beginFill(color, 0.5);
				this.graphics.moveTo(line.x1, line.y1);
				this.graphics.lineTo(line.x2, line.y2);
				
				
			}
		}
		
		/* PUBLIC FUNCTIONS */
		
		public function highlight():void {
			redraw(0x00FF00);
		}
		
		
		public function unhighlight():void {
			redraw(0x00AA00);
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
		
		public function getX():Number {
			return this.topXCoor;
		}
		public function getY():Number {
			return this.topYCoor;
		}
	}
}