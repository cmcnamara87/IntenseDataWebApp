package View.components.Panels.People
{
	import View.components.PanelElement;
	
	import spark.components.HGroup;
	import spark.components.Label;
	
	public class PeoplePerson extends HGroup implements PanelElement
	{
		private var usernameAndAccess:String;
		public function PeoplePerson(usernameAndAccess:String)
		{
			super();
			this.usernameAndAccess = usernameAndAccess;
			
			
			this.percentWidth = 100;
			
			// Setup the layout
			this.paddingLeft = 10;
			this.paddingRight = 10;
			this.paddingTop = 2;
			this.paddingBottom = 2;
			
			var label2:Label = new Label();
			label2.text = usernameAndAccess;
			this.addElement(label2);
		}
		
		public function searchMatches(search:String):Boolean
		{
			if(usernameAndAccess.toLowerCase().indexOf(search.toLowerCase()) == -1) {
				return false;
			} else {
				return true;
			}
		}
	}
}