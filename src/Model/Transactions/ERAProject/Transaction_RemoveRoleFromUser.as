package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import View.ERA.components.ERARole;
	
	import flash.events.Event;

	public class Transaction_RemoveRoleFromUser
	{
		
		private var username:String;
		private var role:String;
		private var roleComponent:ERARole;
		private var connection:Connection;
		private var callback:Function;
		private var year:String;
		
		/**
		 * 
		 * @param username 		Username of the user (not including domain)
		 * @param role			the role to remove them from
		 * @param year			The year of this ERA
		 * @param connection
		 * @param callback
		 * 
		 */
		public function Transaction_RemoveRoleFromUser(username:String, role:String, year:String, roleComponent:ERARole, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.role = role;
			this.year = year;
			this.username = username;
			this.roleComponent = roleComponent;
			
			//actor.grant :type user :name system:johnsmith :role user -type role
			
			var baseXML:XML = connection.packageRequest("actor.revoke", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.type = "user";
			argsXML.name = "system:" + username;
	
			argsXML.role = role + "_" + year;
			
			argsXML.role.@type = "role";
			
			trace("remove role from user", baseXML);
			connection.sendRequest(baseXML, roleRevoked);
		}
		
		private function roleRevoked(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("remove role " + role +  " from user", e)) == null) {
				callback(false);
				return;
			} else {
				// TODO work out what happens for 'sys-admin' role (non-year version)
				if(role != Model_ERAUser.SYS_ADMIN) {
					callback(true, username, roleComponent);
					return;
				}				
				
				// Add another special role for hte sys admin
				var baseXML:XML = connection.packageRequest("actor.revoke", new Object(), true);
				var argsXML:XMLList = baseXML.service.args;
				
				argsXML.type = "user";
				argsXML.name = "system:" + username;
				argsXML.role = Model_ERAUser.SYS_ADMIN;
				argsXML.role.@type = "role";
				
				connection.sendRequest(baseXML, removeSpecialRole);
			}
		}
			
		private function removeSpecialRole(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("remove sys-admin role", e)) == null) {
				callback(false);
				return;
			} 
			
			callback(true, username, roleComponent);
			return;
		}
	}
}