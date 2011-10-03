package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_DeleteERAUser
	{
		private var connection:Connection; 
		private var callback:Function;
		private var username:String;
		
		public function Transaction_DeleteERAUser(username:String, connection:Connection, callback:Function)
		{
			this.username = username;
			this.connection = connection;
			this.callback = callback;
			
			deleteUser();
		}
		
		private function deleteUser():void {
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("user.destroy", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.domain = "system";
			argsXML.user = username;
			
			connection.sendRequest(baseXML, userDeleted);
		}
		
		private function userDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era user", e)) == null) {
				callback(false);
			} else {
				callback(true, username);
			}
		}
	}
}