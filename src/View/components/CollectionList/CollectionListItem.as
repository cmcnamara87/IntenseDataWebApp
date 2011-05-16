package View.components.CollectionList
{
	import Controller.RecensioEvent;
	import Controller.Utilities.AssetLookup;
	
	import Model.Model_Collection;
	
	import View.Element.Collection;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.effects.Fade;
	import mx.graphics.SolidColor;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Rect;

	public class CollectionListItem extends Group
	{
		private var myLabel:spark.components.Label; // The collection list label
		private const LABEL_CHARACTER_LENGTH:Number = 28; 	// The number of characters of text the label can dsiplay
															// Before it is chopped and '...' is appended.
		
		
		/**
		 * Creates a new collection list item for the collection list (in left sidebar)
		 */		
		public function CollectionListItem()
		{
			// Setup the size
			this.percentWidth = 100;
			
			// Setup the layout
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = "middle";
			layout.gap = 10;
			this.layout = layout;
			
			// Setup hand cursor
			this.useHandCursor = true;
			this.buttonMode = true;
			this.mouseChildren = false;

			// List Icon
			var myIcon:Image = new Image();
			myIcon.source = AssetLookup.getCollectionIconClass();
			myIcon.width = 20;
			myIcon.height = 20;
			this.addElement(myIcon);
			
			// List Label
			myLabel = new spark.components.Label();
			myLabel.setStyle('fontSize', 12);
			this.addElement(myLabel);
			// Label text is set in extended classes
		}
		
		// Sets the text for the label for this list item
		protected function setLabel(label:String):void {
			
			if(label.length > LABEL_CHARACTER_LENGTH) {
				label = label.substr(0, LABEL_CHARACTER_LENGTH) + "...";
			}
			this.myLabel.text = label;
		}
		
		public function setSelected():void {
			// Make this collection bold
			this.setStyle('fontWeight', 'bold');
		}
		
		public function unSelect():void {
			this.setStyle('fontWeight', 'normal');
		}
		
		public function getCollectionID():Number {
			throw new Error("getCollectionID() must be overwritten by subclasses");
		}
	}
}