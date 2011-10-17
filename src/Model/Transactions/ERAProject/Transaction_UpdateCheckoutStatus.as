package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_UpdateCheckoutStatus
	{
		private var fileID:Number;
		private var checkedOut:Boolean = false; // if the file has been downloaded (and its awaiting upload)
		private var checkedOutUsername:String = ""; // the username of the person who checked out the file
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_UpdateCheckoutStatus(fileID:Number, checkedOut:Boolean, checkedOutUsername:String, connection:Connection, callback:Function)
		{
			this.fileID = fileID;
			this.checkedOut = checkedOut;
			this.checkedOutUsername = checkedOutUsername;
			this.connection = connection;
			this.callback = callback;
			
			updateCheckoutStatus();
		}
		
		private function updateCheckoutStatus():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = fileID;
			argsXML.meta["ERA-evidence"]["checked_out"] = this.checkedOut;
			argsXML.meta["ERA-evidence"]["checked_out_username"] = this.checkedOutUsername;
			
			connection.sendRequest(baseXML, fileCheckedOutStatusUpdated);		
		}
		
		private function fileCheckedOutStatusUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating checked out status", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
			}
		}
	}
}