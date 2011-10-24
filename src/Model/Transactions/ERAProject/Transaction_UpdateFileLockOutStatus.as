package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_UpdateFileLockOutStatus
	{
		private var year:String;
		private var roomID:Number;
		private var firstName:String;
		private var lastName:String;
		private var notificationType:String;
		private var caseID:Number;
		private var fileID:Number;
		private var username:String;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_UpdateFileLockOutStatus(year:String, roomID:Number, firstName:String, lastName:String, notificationType:String, caseID:Number, fileID:Number, username:String, connection:Connection, callback:Function)
		{
			this.year = year;
			this.roomID = roomID;
			this.firstName = firstName;
			this.lastName = lastName;
			this.notificationType = notificationType;
			this.caseID = caseID;
			this.fileID = fileID;
			this.username = username;
			this.connection = connection;
			this.callback = callback;
			
			getFile();
		}
		
		private function getFile():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = fileID;
			
			connection.sendRequest(baseXML, gotFile);
		}
		
		private function gotFile(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("got the file", e)) == null) {
				callback(false);
				return;
			} 
			
			var eraFileXML:XML = data.reply.result.asset[0];
			
			eraFileXML.meta["ERA-evidence"].appendChild(XML("<locked_for_user>" + username + "</locked_for_user>"));

		
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = fileID;
			argsXML.meta["ERA-evidence"] = "";
			argsXML.meta["ERA-evidence"].appendChild(eraFileXML.meta["ERA-evidence"].locked_for_user);
			
			connection.sendRequest(baseXML, fileLockOutStatusUpdated);		
		}
		
		private function fileLockOutStatusUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating lock out status", e)) == null) {
				callback(false);
				return;
			} else {
				AppModel.getInstance().createERANotification(this.year, this.roomID, this.username, this.firstName, this.lastName, this.notificationType, this.caseID, this.fileID); 
				
				callback(true);
			}
		}
	}
}