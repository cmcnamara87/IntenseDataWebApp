package View.components.Panels.Sharing
{
	import Controller.IDEvent;
	
	import View.components.PanelElement;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.ButtonBar;
	import spark.components.ButtonBarButton;
	import spark.components.CheckBox;
	import spark.components.HGroup;
	import spark.components.Label;
	
	public class SharingPanelUser extends HGroup implements PanelElement
	{
		private var readWriteCheckbox:CheckBox;
		private var readCheckbox:CheckBox
		private var username:String; // The username of the user lol
		private var readAccess:Boolean = false; // Whether the user has read access to this asset
		private var readWriteAccess:Boolean = false; // Whether the user has write access to this asset
		//public function SharingPanelUser(username:String, readAccess:Boolean, writeAccess:Boolean)
		public function SharingPanelUser(username:String, accessString:String)
		{
		
			super();
			
			// Save the variables
			this.username = username;
			
			// Setup the access
			if(accessString == 'read') {
				this.readAccess = true;
			}
			if(accessString == 'read-write') {
				this.readWriteAccess = true;
				this.readAccess = true;
			}
			
			// Setup the size
			this.percentWidth = 100;
			
			// Setup the layout
			this.paddingLeft = 10;
			this.paddingRight = 10;
			this.paddingTop = 10;
			this.paddingBottom = 10;
			
			// Create the User name label
			var usernameLabel:Label = new Label();
			usernameLabel.text = username;
			usernameLabel.setStyle('fontWeight', 'bold');
			// Set this to be 100% width, this means it will fill whatever
			// space is left by the check boxes
			usernameLabel.percentWidth = 100;
			
			this.addElement(usernameLabel);
			
			// Create the checkbox for  read access
			readCheckbox = new CheckBox();
			readCheckbox.label = "View";
			readCheckbox.selected = readAccess;
			this.addElement(readCheckbox);
			
			// Create the checkbox for write access
			//var readWriteCheckbox:CheckBox = new Checkbox();
			readWriteCheckbox = new CheckBox();
			readWriteCheckbox.label = "Full Access";
			readWriteCheckbox.selected = readWriteAccess;
			this.addElement(readWriteCheckbox);
			
			// Event Listeners
			readCheckbox.addEventListener(MouseEvent.CLICK, checkBoxClicked);
			readWriteCheckbox.addEventListener(MouseEvent.CLICK, checkBoxClicked);
		}
		
		public function getAccessString():String {
			if(readWriteCheckbox.selected) {
				return 'read-write';
			} else if (readCheckbox.selected) {
				return 'read';
			} else {
				return 'none';
			}
		}
		
		public function getUsername():String {
			return username;
		}
		
		/**
		 * One of the checkboxes was clicked.
		 * Check other box if appropritae. Like, if we click 'annotate'
		 * turn on 'view'. 
		 * 
		 * Also tell the SharingPanel
		 * who will pass this new info to the Controller. 
		 * @param e
		 * 
		 */		
		private function checkBoxClicked(e:MouseEvent):void {
			trace("Checkbox changed");
			if(e.target == readCheckbox) {
				if(readCheckbox.selected == false) {
					readWriteCheckbox.selected = false;
				}
			} else {
				if(readWriteCheckbox.selected == true) {
					readCheckbox.selected = true;
				}
			}
			
			// Create a new sharing changed event
			var sharingChangedEvent:IDEvent = new IDEvent(IDEvent.SHARING_CHANGED, true);
			// Put in the user
			sharingChangedEvent.data.username = username;
			// And their new access level
			if(readWriteCheckbox.selected) {
				sharingChangedEvent.data.access = SharingPanel.READWRITE;
			} else if (readCheckbox.selected) {
				sharingChangedEvent.data.access = SharingPanel.READ;
			} else {
				sharingChangedEvent.data.access = SharingPanel.NOACCESS;
			}
			
			// Dispatch the event
			this.dispatchEvent(sharingChangedEvent);
		}
		
		public function searchMatches(search:String):Boolean {
			if(username.toLowerCase().indexOf(search.toLowerCase()) == -1) {
				return false;
			} else {
				return true;
			}
		}
	}
}