package View.components
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	
	public class GoodBorderContainer extends Group
	{
		private var backgroundColor:uint;
		private var backgroundAlpha:Number;
		private var borderColor:uint;
		private var borderThickness:Number;
		
		public function GoodBorderContainer(backgroundColor:uint, backgroundAlpha:Number, borderColor:uint = 0, borderThickness:Number = 0)
		{
			super();
			this.backgroundColor = backgroundColor;
			this.backgroundAlpha = backgroundAlpha;
			this.borderColor = borderColor;	
			this.borderThickness = borderThickness;
			
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, redrawBackground);
		}
		
		public function setBackground(backgroundColor:uint, backgroundAlpha:Number = 1):void {
			this.backgroundColor = backgroundColor;
			this.backgroundAlpha = backgroundAlpha;
			redrawBackground();
		}
		
		private function redrawBackground(e:Event=null):void {
			this.graphics.clear();
			this.graphics.beginFill(backgroundColor, backgroundAlpha);
			if(borderThickness > 0) {
				this.graphics.lineStyle(borderThickness, borderColor);
			}
			this.graphics.drawRect(0,0,this.width, this.height);
		}
	}
}