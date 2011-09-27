package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_AddRoleToUser
	{
		private var connection:Connection; 
		private var callback:Function;
		private var role:String;
		private var year:String;
		private var username:String;

		/**
		 * 
		 * @param username 		Username of the user (not including domain)
		 * @param role
		 * @param year
		 * @param connection
		 * @param callback
		 * 
		 */
		public function Transaction_AddRoleToUser(username:String, role:String, year:String, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.role = role;
			this.year = year;
			this.username = username;
			
			//actor.grant :type user :name system:johnsmith :role user -type role
			
			var baseXML:XML = connection.packageRequest("actor.grant", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.type = "user";
			argsXML.name = "system:" + username;
			argsXML.role = role + "_" + year;
			argsXML.role.@type = "role";
			
			connection.sendRequest(baseXML, roleAdded);
		}
		
		private function roleAdded(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("add role to user", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
				return;
			}
		}
	}
}