package Module.PDFViewer  {
	import flash.display.Sprite;

	public class PDFSideAnnotationContainer extends Sprite {
		
		private var viewer:PDFViewer;
		private var iconsArray:Array = new Array();
		
		public function PDFSideAnnotationContainer(viewer:PDFViewer) {
			this.viewer = viewer;
			super();
		}
		
		public function resize():void {
			this.graphics.clear();
			this.graphics.beginFill(0xDDDDFF,1);
			this.graphics.drawRoundRectComplex(0,-6,25,viewer.height-37,0,0,0,10);
			this.graphics.lineStyle(1,0x000000,1);
			this.graphics.moveTo(0,-6);
			this.graphics.lineTo(0,viewer.height-42);
			this.x = viewer.width-27;
			
			for each(var annotation:Object in iconsArray) {
				annotation.annotation.y = annotation.ratio*(viewer.height-82)+10;
			}
		}
		
		public function add(theAnnotation:PDFAnnotationSideMarker,ratio:Number):void {
			addChild(theAnnotation);
			var tmpAnnotation:Object = {'annotation':theAnnotation,'ratio':ratio};
			iconsArray.push(tmpAnnotation);
			theAnnotation.x = 5;
			resize();
		}
		
	}
}