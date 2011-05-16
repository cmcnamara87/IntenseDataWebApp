package View.Element {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class BackgroundImage extends RecensioUIComponent {
		
		[Embed(source="Assets/Template/header_bg.png")] 
		[Bindable] private var backgroundImage:Class;
		private var backgroundImageData:BitmapData;
		
		public function BackgroundImage() {
			super();
			backgroundImageData = (new backgroundImage() as Bitmap).bitmapData;
		}
		
		// Draws a repeating background image
		override protected function draw():void {
			this.graphics.clear();
			this.graphics.beginBitmapFill(backgroundImageData);
			this.graphics.drawRect(0,0,this.parent.width,88);
		}
	}
}