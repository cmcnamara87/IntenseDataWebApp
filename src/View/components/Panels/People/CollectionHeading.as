package View.components.Panels.People
{
	import Controller.BrowserController;
	
	import View.components.PanelElement;
	
	import mx.controls.Label;
	
	import spark.components.HGroup;
	
	public class CollectionHeading extends HGroup implements PanelElement
	{
		public function CollectionHeading(collectionName:String)
		{
			super();
			
			// setup size
			this.percentWidth = 100;
			
			// Setup the layout
			this.paddingLeft = 10;
			this.paddingRight = 10;
			this.paddingTop = 10;
			this.paddingBottom = 2;
			
			var label:Label = new Label();
			label.text = BrowserController.PORTAL + ": " + collectionName;
			label.setStyle('fontWeight', 'bold');
			label.setStyle('fontSize', 14);
			this.addElement(label);
		}
		
		public function searchMatches(search:String):Boolean
		{
			return true;
		}
	}
}