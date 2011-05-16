package View.Element {
	
	public class BottomMenu extends RecensioUIComponent {
		
		public var defaultWidth:Number;
		public var defaultHeight:Number;
		
		public function BottomMenu() {
			super();
		}
		
		// Redraw
		override protected function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0xCCCCCC,1);
			this.graphics.drawRect(0,0,defaultWidth,defaultHeight);
		}
	}
}