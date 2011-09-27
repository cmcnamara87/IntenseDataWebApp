package Model.Transactions.ERAProject
{
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Model_ERAUser;
	import Model.Model_User;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetAllUsers
	{
		private var connection:Connection; 
		private var callback:Function;
		
		public function Transaction_GetAllUsers(connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			
			var baseXML:XML = connection.packageRequest("user.describe", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.domain = "system";
			
			connection.sendRequest(baseXML, gotAllUsers);
		}
		
		private function gotAllUsers(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all users", e)) == null) {
				callback(false, null);
				return;
			}
			
			var userArray:Array = AppModel.getInstance().parseResults(data, Model_ERAUser);
			
			callback(true, userArray);
		}
	}
}