package View.components
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	
	/**
	 * So its basically what a border container is, but it can be any size, not just the weird size that the border
	 * container by default is set to, its like, a min of 112px tall and wide. so this doesnt have that, it just uses
	 * a group, and redraws it 
	 * @author cmcnamara87
	 * 
	 */
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