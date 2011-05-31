package View.components
{
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Button;
	import spark.components.ToggleButton;
	import spark.primitives.Line;

	public class IDGUI
	{
		/**
		 * DEPRECATED - CREATE AN IDBUTTON OBJECT INSTEAD.
		 * Creates a new button 
		 * @param label	The text for the button
		 * @return 	The button
		 * 
		 */		
		public static function makeButton(label:String, visible:Boolean = true, includeInLayout:Boolean = true):IDButton {
			var button:IDButton = new IDButton(label, visible, includeInLayout);
			return button
		}
		
		public static function makeToggleButton(label:String, state:Boolean = false, visible:Boolean = true, includeInLayout:Boolean = true):ToggleButton {
			var button:ToggleButton = new ToggleButton();
			button.label = label;
			button.selected = state;			
			button.percentHeight = 100;
			button.visible = visible;
			button.includeInLayout = includeInLayout;
			return button;
		}
		/**
		 * Creates a new vertical line 
		 * @param color	The color of the line (defaults ot a grey)
		 * @return The new line
		 * 
		 */		
		public static function makeLine(color:uint = 0xBBBBBB, visible:Boolean = true, includeInLayout:Boolean = true):Line {
			var line:Line = new Line();
			line.percentHeight = 100;
			line.stroke = new SolidColorStroke(color, 1, 1);
			line.visible = visible;
			line.includeInLayout = includeInLayout;
			return line;
		}

	}
}