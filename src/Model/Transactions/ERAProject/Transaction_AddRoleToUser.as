package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import View.ERA.components.ERARole;
	
	import flash.events.Event;
	
	public class Transaction_AddRoleToUser
	{
		private var connection:Connection; 
		private var callback:Function;
		private var role:String;
		private var year:String;
		private var userData:Model_ERAUser;
		private var roleComponent:ERARole;

		/**
		 * 
		 * @param username 		Username of the user (not including domain)
		 * @param role
		 * @param year
		 * @param connection
		 * @param callback
		 * 
		 */
		public function Transaction_AddRoleToUser(userData:Model_ERAUser, role:String, year:String, roleComponent:ERARole, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.roleComponent = roleComponent;
			this.role = role;
			this.year = year;
			this.userData = userData;
			
			//actor.grant :type user :name system:johnsmith :role user -type role
			
			var baseXML:XML = connection.packageRequest("actor.grant", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.type = "user";
			argsXML.name = "system:" + userData.username;
			argsXML.role = role + "_" + year;
			argsXML.role.@type = "role";
			
			connection.sendRequest(baseXML, roleAdded);
		}
		
		private function roleAdded(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("add role to user", e)) == null) {
				callback(false);
				return;
			} 
			
			if(role != Model_ERAUser.SYS_ADMIN) {
				callback(true, userData, roleComponent);
				return;
			}
			
			// Add another special role for hte sys admin
			var baseXML:XML = connection.packageRequest("actor.grant", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.type = "user";
			argsXML.name = "system:" + userData.username;
			argsXML.role = Model_ERAUser.SYS_ADMIN;
			argsXML.role.@type = "role";
			
			connection.sendRequest(baseXML, specialRoleAdded);
		}
		
		private function specialRoleAdded(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("add sys-admin role", e)) == null) {
				callback(false);
				return;
			} 
			
			callback(true, userData, roleComponent);
			return;
		}
	}
}