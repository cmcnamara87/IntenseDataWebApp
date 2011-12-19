package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetERAUserRoles
	{
		private var username:String;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_GetERAUserRoles(username:String, connection:Connection, callback:Function)
		{
			this.username = username;
			this.connection = connection;
			this.callback = callback;
			
			getERAUserRoles();
		}
		
		private function getERAUserRoles():void {
			var baseXML:XML = connection.packageRequest("actor.describe", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.name = "system:" + username;
			argsXML.type = "user";
			
			connection.sendRequest(baseXML, gotERARoles);
		}
		
		private function gotERARoles(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting notification for mail", e)) == null) {
				callback(false);
				return
			}
			
			var rolesArray:Array = new Array();
			var rolesXML:XMLList = data.reply.result.actor.role;
			for each(var role:String in rolesXML) {
				rolesArray.push(role);
			}
			
			callback(true, rolesArray);			
		}
	}
}