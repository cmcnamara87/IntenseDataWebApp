package View.components.Panels.People
{
	import Controller.BrowserController;
	import Controller.Dispatcher;
	
	import View.components.PanelElement;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Label;
	
	import spark.components.HGroup;
	
	public class CollectionHeading extends HGroup implements PanelElement
	{
		private var collectionID:Number;
		private const LABEL_CHARACTER_LENGTH:Number = 27; 	// The number of characters of text the label can dsiplay
		// Before it is chopped and '...' is appended.
		
		public function CollectionHeading(collectionID:Number, collectionName:String)
		{
			super();
			this.collectionID = collectionID;
			
			// setup size
			this.percentWidth = 100;
			
			// Setup the layout
			this.paddingLeft = 10;
			this.paddingRight = 10;
			this.paddingTop = 10;
			this.paddingBottom = 2;
			
			var label:Label = new Label();
			label.text = collectionName;

			if(label.text.length > LABEL_CHARACTER_LENGTH) {
				label.text = label.text.substr(0, LABEL_CHARACTER_LENGTH) + "...";
			}

			label.setStyle('fontWeight', 'bold');
			label.setStyle('color', 0x1F65A2);
			label.setStyle('fontSize', 14);
			this.addElement(label);
			
			this.useHandCursor = true;
			this.buttonMode = true;
			this.mouseChildren = false;
			
			this.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				BrowserController.currentCollectionID = collectionID;
				Dispatcher.call('browse');
			});
		}
		
		public function searchMatches(search:String):Boolean
		{
			return true;
		}
	}
}