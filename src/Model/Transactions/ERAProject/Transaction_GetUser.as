package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetUser
	{
		private var username:String;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_GetUser(username:String, connection:Connection, callback:Function)
		{
			this.username = username;
			this.connection = connection;
			this.callback = callback;
			
			getUser();
		}
		
		private function getUser():void {
			var baseXML:XML = connection.packageRequest("user.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// actor.grant :type user :name system:johnsmith :role user -type role
			argsXML.user = username;
			argsXML.domain = "system";
			
			connection.sendRequest(baseXML, gotUserDetails);
		}
		
		private function gotUserDetails(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting user details", e)) == null) {
				callback(false);
				return;
			}
			
			var eraUser:Model_ERAUser = new Model_ERAUser();
			eraUser.setData(data.reply.result.user[0]);
			
			callback(true, eraUser);
		}
	}
}