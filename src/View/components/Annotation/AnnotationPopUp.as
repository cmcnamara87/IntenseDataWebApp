package View.components.Annotation
{
	import flash.filters.DropShadowFilter;
	
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.layouts.VerticalLayout;
	
	public class AnnotationPopUp extends BorderContainer
	{
		// GUI elements
		private var usernameLabel:Label; // Holds the username of the persopn who created the annotation
		private var textLabel:Label; // Holds the text of the annotation
		private var myLayout:VerticalLayout;
		
		// class variables
		private var annotationID:Number;
		
		public function AnnotationPopUp(annotationID:Number, username:String, text:String)
		{
			super();
			this.annotationID = annotationID;
			
			// Setup size
			this.height = 100;
			this.width = 200;
			
			// Setup color
			this.backgroundFill = new SolidColor(0xFFFFFF);
			
			// Setup drop shadow
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.alpha = 0.8;
			shadow.distance = 4;
			shadow.angle = 25;
			this.filters = [shadow];
			
			// Setup layout
			myLayout = new VerticalLayout();
			myLayout.paddingBottom = 10;
			myLayout.paddingLeft = 10;
			myLayout.paddingRight = 10;
			myLayout.paddingTop = 10;
			myLayout.gap = 2;
			this.layout = myLayout;
			
			// Add elements
			// Add usenrame
			usernameLabel = new Label();
			usernameLabel.text = username;
			this.addElement(usernameLabel);
			// Add text
			textLabel = new Label();
			textLabel.text = text;
			this.addElement(textLabel);
			
			textLabel.addEventListener(FlexEvent.CREATION_COMPLETE, asdf);
			usernameLabel.addEventListener(FlexEvent.CREATION_COMPLETE, asdf);
		}
		
		
		public function getID():Number {
			return this.annotationID;
		}
		
		private function asdf(e:FlexEvent):void {
//			trace("popup stuff", usernameLabel.height, textLabel.height, myLayout.gap + myLayout.paddingBottom + myLayout.paddingTop;
			this.height = usernameLabel.height + textLabel.height + myLayout.gap + myLayout.paddingBottom + myLayout.paddingTop;
		}
	}
}