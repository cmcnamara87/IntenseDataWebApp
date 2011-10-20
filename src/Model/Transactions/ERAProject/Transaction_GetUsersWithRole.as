package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetUsersWithRole
	{
		private var connection:Connection; 
		private var callback:Function;
		private var role:String;
		private var year:String;
		
		private var userArray:Array;
		private var userDetailsArray:Array = new Array();
		
		public function Transaction_GetUsersWithRole(role:String, year:String, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.role = role;
			this.year = year;
			
			//actors.granted :role -type role iduser :type user
			
			var baseXML:XML = connection.packageRequest("user.describe", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.domain = "system";		
			if(year == "") {
				argsXML.role = role;
			} else {
				argsXML.role = role + "_" + year;
			}
			argsXML.role.@type = "role"
			
			connection.sendRequest(baseXML, gotUsers);
		}
		
		private function gotUsers(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting users with role " + role, e)) == null) {
				callback(false, role, null);
			}
			
			// Gets out all the users
			userArray = AppModel.getInstance().parseResults(data, Model_ERAUser);
			
			if(userArray.length == 0) {
				// No users found, no point getting any details etc, lets just give it back
				callback(true, role, userArray);
			}
			
			// Get the details for each user
			for each(var user:Model_ERAUser in userArray) {
				getUserDetails(user.username);
			}
		}
		
		private function getUserDetails(username:String):void {
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
			
			// Save the new user with details
			userDetailsArray.push(eraUser);
			
			// Check if we have them all
			if(userDetailsArray.length == userArray.length) {
				// We have them all, give it back
				callback(true, role, userDetailsArray);
			}
		}
	}
}