package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	/**
	 * Creates a User in the Mediaflux Database.
	 * 
	 * Creates a 'user' actor, and assigns the 'user' role to it. 
	 * @author cmcnamara87
	 * 
	 */	
	public class Transaction_CreateERAUser
	{
		private var username:String;
		private var firstName:String;
		private var lastName:String;
		private var password:String;
		private var email:String;
		private var domain:String;
		private var callback:Function;
		private var connection:Connection;
		/**
		 * Saves all the info needed to create a user,
		 * and creates the user.
		 *  
		 * @param username	The user name for the user
		 * @param password	The password for the user
		 * @param email		The email for the user
		 * @param domain	The domain the user will be in (currently using system, TODO)
		 * @param details	An object that contains all the details for a user, matching the r_user doc type
		 * @param callback	The function to call when the transaction is complete
		 * 
		 */		
		public function Transaction_CreateERAUser(qutUsername:String, firstName:String, lastName:String, connection:Connection, callback:Function)
		{
			this.username = qutUsername;
			this.firstName = firstName;
			this.lastName = lastName;
			this.password = "changeme";
			this.email = qutUsername;
			this.domain = "system";
				
			this.connection = connection;
			this.callback = callback;
			
			createUser();
			
		}
		
		/**
		 * Creates the user actor in the database, then calls @see grantUserRole 
		 * @return 
		 * 
		 */		
		private function createUser():void {
			
			var baseXML:XML = connection.packageRequest("user.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.user = username;
			argsXML.password = password;
			argsXML.domain = domain;
			argsXML.email = email;
			
			argsXML.meta["ERA-user"]["first_name"] = firstName;
			argsXML.meta["ERA-user"]["last_name"] = lastName;

			connection.sendRequest(baseXML, grantIDUserRole);
		}
		
		/**
		 * Give the user the standard ID user role 
		 * @param e
		 * 
		 */
		private function grantIDUserRole(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("create user", e)) == null) {
				callback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("actor.grant", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// actor.grant :type user :name system:johnsmith :role user -type role
			argsXML.type = "user";
			argsXML.name = "system:" + username;
			argsXML.role = "iduser";
			argsXML.role.@type = "role";
						
			connection.sendRequest(baseXML, grantERAUserRole);
		}
		
		/**
		 * Give the user the special ERA user role
		 * @param e
		 * 
		 */
		private function grantERAUserRole(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("granting ID user role", e)) == null) {
				callback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("actor.grant", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// actor.grant :type user :name system:johnsmith :role user -type role
			argsXML.type = "user";
			argsXML.name = "system:" + username;
			argsXML.role = "ERA-user";
			argsXML.role.@type = "role";
			
			connection.sendRequest(baseXML, idUserGranted);
		}
		
		private function idUserGranted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("id user role granted", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
			}
		}
	}
}