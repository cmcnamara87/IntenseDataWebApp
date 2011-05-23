package View.components
{
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Button;
	import spark.components.ToggleButton;
	import spark.primitives.Line;

	public class IDGUI
	{
		/**
		 * Creates a new button 
		 * @param label	The text for the button
		 * @return 	The button
		 * 
		 */		
		public static function makeButton(label:String):Button {
			var button:Button = new Button();
			button.label = label;
			button.percentHeight = 100;
			return button
		}
		
		public static function makeToggleButton(label:String, state:Boolean = false):ToggleButton {
			var button:ToggleButton = new ToggleButton();
			button.label = label;
			button.selected = state;			
			button.percentHeight = 100;
			return button;
		}
		/**
		 * Creates a new vertical line 
		 * @param color	The color of the line (defaults ot a grey)
		 * @return The new line
		 * 
		 */		
		public static function makeLine(color:uint = 0xBBBBBB):Line {
			var line:Line = new Line();
			line.percentHeight = 100;
			line.stroke = new SolidColorStroke(color, 1, 1);
			return line;
		}

	}
}