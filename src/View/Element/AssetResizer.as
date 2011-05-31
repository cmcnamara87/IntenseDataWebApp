package View.Element {
	
	import Controller.IDEvent;
	
	import flash.events.Event;
	
	import spark.components.HSlider;
	
	public class AssetResizer extends RecensioUIComponent {
		
		public var defaultWidth:Number = 120;
		public var defaultHeight:Number = 40;
		private var sliderHeight:Number = 20;
		private var padding:Number = 10;
		private var slider:HSlider = new HSlider();
		
		public function AssetResizer() {
			super();
			addChild(slider);
			slider.addEventListener(Event.CHANGE,valueChanged);
			slider.height = sliderHeight;
			slider.width = defaultWidth-padding*2;
			slider.x = padding;
			slider.y = defaultHeight/2-sliderHeight/2;
			slider.minimum = 80;
			slider.maximum = 400;
		}
		
		// Changes the slider value / position
		public function setSize(newSize:Number):void {
			slider.value = newSize;
			valueChanged(new Event(Event.CHANGE));
		}
		
		// Called when the slider position has changed
		private function valueChanged(e:Event):void {
			var sliderChangedEvent:IDEvent = new IDEvent(IDEvent.ASSET_RESIZER);
			sliderChangedEvent.data.value = slider.value;
			this.dispatchEvent(sliderChangedEvent);
		}
		
		// Redraws the background for the slider
		override protected function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0xCCCCCC,0.01);
			this.graphics.drawRect(0,0,defaultWidth,defaultHeight);
		}
	}
}