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
		
		private var usersRetrievedCount:Number = 0;
		public function Transaction_GetUsersWithRole(role:String, year:String, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.role = role;
			this.year = year;
			
			//actors.granted :role -type role iduser :type user
			
			var baseXML:XML = connection.packageRequest("actors.granted", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.role = role + "_" + year;
			argsXML.role.@type = "role"
			argsXML.type = "user";
			
			connection.sendRequest(baseXML, gotUsers);
		}
		
		private function gotUsers(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all users", e)) == null) {
				callback(false, role, null);
			}
			
			var usersArray:Array = new Array();
			if(data.reply.result.actor) {
				for each(var actor:XML in data.reply.result.actor) {
					usersArray.push(actor.@name);
				}
			}
//			var userArray:Array = AppModel.getInstance().parseResults(data, Model_ERAUser);
			callback(true, role, usersArray);
		}
	}
}