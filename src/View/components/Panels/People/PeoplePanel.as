package View.components.Panels.People
{
	import Controller.BrowserController;
	
	import View.components.IDButton;
	import View.components.IDGUI;
	import View.components.Panels.Panel;
	
	import flash.events.MouseEvent;
	
	import spark.components.Label;
	import spark.components.VGroup;
	
	public class PeoplePanel extends Panel
	{
		public function PeoplePanel()
		{
			super();
			
			// Set heading on the panel
			setHeading(BrowserController.PORTAL + "s");
			
			// Add the close button to the panel
			var closeButton:IDButton = new IDButton('X');
			closeButton.width = 30;
			toolbar.addElement(closeButton);
			
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
		}
		
		/**
		 * Takes the sharing data for the asset, and displays it using
		 * sharing panel user items.
		 *  
		 * @param sharingData 	The data containing which users have access etc
		 * 
		 */		
		public function addPeople(peopleCollection:Array, assetID:Number):void {
			content.removeAllElements();
	
			for each(var collection:Array in peopleCollection) {
				var collectionID:Number =  collection[0];
				var collectionName:String = collection[1];
				
				if(assetID == collectionID) {
//					content.addElement(new CollectionHeading(collectionName, "File"));
				} else {
					content.addElement(new CollectionHeading(collectionID, collectionName));
					
					for(var i:Number = 0; i < collection[2].length; i++) {
						var usernameAndAccess:String = collection[2][i];
						content.addElement(new PeoplePerson(usernameAndAccess));
					}
					
				}
				
				
				
			}	
		}
		
		private function closeButtonClicked(e:MouseEvent):void {
			this.width = 0;
		}
		
	}
}