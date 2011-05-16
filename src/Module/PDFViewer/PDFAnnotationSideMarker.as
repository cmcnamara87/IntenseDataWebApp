package Module.PDFViewer {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class PDFAnnotationSideMarker extends Sprite {
		
		[Embed(source="Assets/Module/annotation_small.png")]
        public var Annotation_icon:Class;
		
		private var icon:DisplayObject;
		private var thePDF:PDF;
		private var theAnnotation:PDFAnnotation;
		
		public function PDFAnnotationSideMarker(thePDF:PDF,theAnnotation:PDFAnnotation) {
			this.theAnnotation = theAnnotation;
			this.thePDF = thePDF;
			icon = new Annotation_icon() as DisplayObject;
			this.addChild(icon);
			this.addEventListener(MouseEvent.CLICK,gotoAnnotation);
			this.addEventListener(MouseEvent.MOUSE_OVER,mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,mouseOut);
		}
		
		private function gotoAnnotation(e:MouseEvent):void {
			thePDF.gotoYPos(theAnnotation.y);
			theAnnotation.show();
		}
		
		private function mouseOver(e:MouseEvent):void {
			this.scaleX = 1.2;
			this.scaleY = 1.2;
			icon.x = -1;
			icon.y = -1;
		}
		
		private function mouseOut(e:MouseEvent):void {
			this.scaleX = 1;
			this.scaleY = 1;
			icon.x = 0;
			icon.y = 0;
		}
	}
}