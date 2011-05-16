package View.components
{
	import mx.effects.Resize;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalAlign;
	
	public class SubToolbar extends BorderContainer
	{
		public static const SUB_TOOLBAR_HEIGHT:Number = 40; // The hiehgt of the Annotation Toolbar
		
		public static const YELLOW:uint = 0xFFFF00;
		public static const RED:uint = 0xFF0000;
		public static const GREEN:uint = 0x00FF00;
		public static const GREY:uint = 0xCCCCCC;
		
		public function SubToolbar()
		{
			super();
			
			// Setup size
			this.percentWidth = 100;
			this.height = SUB_TOOLBAR_HEIGHT;
			
			// Setup visibling/effetcs
			this.visible = true;
			this.setStyle("resizeEffect", new mx.effects.Resize());
			
			
			// Setup layout
			var myLayout:HorizontalLayout = new HorizontalLayout();
			myLayout.paddingTop = 5;
			myLayout.paddingRight = 5;
			myLayout.paddingBottom = 5;
			myLayout.paddingLeft = 5;
			myLayout.verticalAlign = VerticalAlign.MIDDLE;
			this.layout = myLayout;
			
			// Setup Background color
			this.backgroundFill = new SolidColor(0xFFFF00, 1);
			this.borderStroke = new SolidColorStroke(0xFFFFFF, 1);
		}
		
		public function setColor(color:uint):void {
			this.backgroundFill = new SolidColor(color, 1);
		}
	}
}