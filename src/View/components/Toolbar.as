package View.components
{
	import View.BrowserView;
	
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.layouts.HorizontalLayout;
	
	public class Toolbar extends BorderContainer
	{
		private var myLayout:HorizontalLayout;
		
		public function Toolbar()
		{
			super();
			
			var myFill:LinearGradient = new LinearGradient();
			myFill.rotation = 90;
			var myFillColor:GradientEntry = new GradientEntry(0xEEEEEE);
//			var myFillColor:GradientEntry = new GradientEntry(0x333333);
//			var myFillColor1:GradientEntry = new GradientEntry(0x111111);
			var myFillColor1:GradientEntry = new GradientEntry(0xDDDDDD);
			
			myFill.entries=[myFillColor, myFillColor1];
			this.backgroundFill = myFill;
			
			//this.backgroundFill = new SolidColor(0xDDDDDD, 1);
			this.borderStroke = new SolidColorStroke(0xDDDDDD, 1, 1);
			
			// Setup the size
			this.percentWidth = 100;
			this.height = 45;//BrowserView.TOOLBARHEIGHT;
			
			// Setup the layout
			myLayout = new HorizontalLayout();
			myLayout.verticalAlign = "middle";
			myLayout.gap = 5;
			myLayout.paddingLeft = 10;
			myLayout.paddingRight = 10;
			myLayout.paddingTop = 7;
			myLayout.paddingBottom = 7;
			this.layout = myLayout;
		}
		
		public function setGap(amount:Number):void {
			myLayout.gap = amount;
		}
	}
	
	
}