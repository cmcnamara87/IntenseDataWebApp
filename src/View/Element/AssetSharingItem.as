package View.Element {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class AssetSharingItem extends RecensioUIComponent {
		
		private var formItem:AssetSharingFormItem = new AssetSharingFormItem();
		private var _name:String = "";
		private var _access:String = "";
		public var read:Boolean = false;
		public var write:Boolean = false;
		
		public function AssetSharingItem(name:String,access:String) {
			formItem.addEventListener(Event.ADDED_TO_STAGE,setInformation);			
			addChild(formItem);
			_name = name;
			_access = access;
			super();
			this.percentWidth = 100;
			this.height = 20;
		}
		
		// Returns the username for the row
		public function getUsername():String {
			return _name;
		}
		
		// Sets the information of the row (username and access level)
		private function setInformation(e:Event=null):void {
			formItem.read.addEventListener(MouseEvent.MOUSE_UP,readToggled);
			formItem.write.addEventListener(MouseEvent.MOUSE_UP,writeToggled);
			formItem.username.text = _name;
			if(_access == 'read') {
				formItem.read.selected = true;
				read = true;
			} else if (_access == 'read-write') {
				formItem.read.selected = true;
				formItem.write.selected = true;
				read = true;
				write = true;
			}
		}
		
		// Returns the access level for the row/user
		public function getAccess():String {
			if(formItem.read.selected && !formItem.write.selected) {
				return "read";
			}
			if(formItem.read.selected && formItem.write.selected) {
				return "read-write";
			}
			return "none";
		}
		
		// Toggles read access on and off
		private function readToggled(e:MouseEvent):void {
			read = formItem.read.selected;
			if(!read && write) {
				formItem.write.selected = false;
				write = formItem.read.selected;
			}
		}
		
		// Toggles write access on and off
		private function writeToggled(e:MouseEvent):void {
			write = formItem.write.selected;
			if(write && !read) {
				formItem.read.selected = true;
				write = formItem.read.selected;
			}
		}
	}
}