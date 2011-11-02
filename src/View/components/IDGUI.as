package View.components
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Button;
	import spark.components.ToggleButton;
	import spark.primitives.Line;

	public class IDGUI
	{
		public static function localToLocal(containerFrom:DisplayObject, containerTo:DisplayObject, origin:Point):Point
		{
			var point:Point = origin;
			point = containerFrom.localToGlobal(point);
			point = containerTo.globalToLocal(point);
			return point;
		}
		
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
		
		public static function makeMenuButton(label:String, visible:Boolean = true, includeInLayout:Boolean = true):IDButton {
			var button:IDButton = new IDButton(label, visible, includeInLayout);
			button.setStyle("cornerRadius", "10");
			button.setStyle("chromeColor", "0xFFFFFF");
			button.height = 30;
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
		
		public static function getLinkHTML(text:String, color="#1122CC"):String {
			var newCommentText:String = text;
			var startRefLocation:Number = newCommentText.indexOf("{");
			while(startRefLocation != -1) {
//				trace("{ found at", startRefLocation);
				var endRefLocation:Number = newCommentText.indexOf("}", startRefLocation);
				
				if(endRefLocation == -1) {
					break;	
				}
				
//				trace("} found at", endRefLocation);
				
				var colonLocation:Number = newCommentText.indexOf(":", startRefLocation);
				
				if(colonLocation == -1) {
					break;
				}
				
//				trace(": found at", colonLocation);
				
				// we have everything we need
				var refAssetID:String = newCommentText.substring(colonLocation + 1, endRefLocation);
				var mediaTitle:String = newCommentText.substring(startRefLocation + 1, colonLocation);
				
				
//				trace("ref ID", refAssetID);
//				trace("mediaTitle", mediaTitle);
				
				// for tomorrow, get out the length of the first part, after the </a> is put in, and start seraching from there
				var replacementString:String = "(<font color='"+color+"'><u><a href='#go/" + refAssetID + "'>" + mediaTitle + "</a></u></font>)";
				newCommentText = newCommentText.substring(0, startRefLocation) + replacementString + newCommentText.substring(endRefLocation + 1);
				
				startRefLocation = newCommentText.indexOf("{", startRefLocation + replacementString.length);
			}
			return newCommentText;
		}
	}
}