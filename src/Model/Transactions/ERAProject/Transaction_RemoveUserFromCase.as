package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_RemoveUserFromCase
	{
		private var caseID:Number;
		private var removeUsername:String;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_RemoveUserFromCase(caseID:Number, removeUsername:String, connection:Connection, callback:Function)
		{
			this.caseID = caseID;
			this.removeUsername = removeUsername;
			this.connection = connection;
			this.callback = callback;

			removeUserFromCase();
		}
		
		private function removeUserFromCase():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;
			
			connection.sendRequest(baseXML, gotCase);
		}
		
		private function gotCase(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting case", e)) == null) {
				callback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup create the new replacement data
			argsXML.id = caseID;
			argsXML.meta.@action = "merge";
			argsXML.meta["ERA-case"] = "";
			
			for each(var user:XML in data.reply.result.asset.meta["ERA-case"]["production_manager_username"]) {
				if(user.username != removeUsername) { 
					argsXML.meta["ERA-case"].appendChild(
						XML('<production_manager_username><username>' +  user.username + '</username><first_name>'+ user.first_name + '</first_name><last_name>' + user.last_name + '</last_name></production_manager_username>')
					);
				}
			}
			
			for each(var user:XML in data.reply.result.asset.meta["ERA-case"]["production_team_username"]) {
				if(user.username != removeUsername) { 
					argsXML.meta["ERA-case"].appendChild(
						XML('<production_team_username><username>' +  user.username + '</username><first_name>'+ user.first_name + '</first_name><last_name>' + user.last_name + '</last_name></production_team_username>')
					);
				}
			}
			
			for each(var user:XML in data.reply.result.asset.meta["ERA-case"]["researcher_username"]) {
				if(user.username != removeUsername) { 
					argsXML.meta["ERA-case"].appendChild(
						XML('<researcher_username><username>' +  user.username + '</username><first_name>'+ user.first_name + '</first_name><last_name>' + user.last_name + '</last_name></researcher_username>')
					);
				}
			}
			
			trace("xml", argsXML);
			connection.sendRequest(baseXML, caseUpdated);	
		}
		
		private function caseUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating case", e)) == null) {
				callback(false);
				return;
			}
			
			// now lets remove that persons access to this thing
			// Now remove everyones access, we will grant the new people access in a bit
			var baseXML:XML = connection.packageRequest("asset.acl.revoke", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;

			argsXML.appendChild(XML('<acl><actor type="user">system:' + removeUsername + '</actor></acl>'));
			
			
			trace('acls to remove', argsXML);
			connection.sendRequest(baseXML, aclsRemoved);
		}
		
		private function aclsRemoved(e:Event):void{
			var data:XML;
			if((data = AppModel.getInstance().getData("removing era acls", e)) == null) {
				callback(false);
				return;
			}
			callback(true);
		}
	}
}