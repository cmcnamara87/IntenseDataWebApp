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
			
			// The Case's XML
			var eraCaseXML:XML = data.reply.result.asset[0];

			// Create our request and its XML
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Request XML (we put in a copy of the current era case XML)
			argsXML.id = caseID;
			argsXML.meta = "";
			argsXML.meta.appendChild((eraCaseXML.meta["ERA-case"]).copy());
			argsXML.meta.@action = "replace";
			
			// Lets remove all of the user access stuff, from our new copied XML document
			// (the original is still in tact, and we will copy back what is still valid)
			delete argsXML.meta["ERA-case"]["production_manager_username"];
			delete argsXML.meta["ERA-case"]["production_team_username"];
			delete argsXML.meta["ERA-case"]["researcher_username"];
			
			// Okay, now thast all gone, lets add back what we need
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
			trace("merged!", e);
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
			if((data = AppModel.getInstance().getData("removing era acls - Transaction_RemoveUserFromCase", e)) == null) {
				cleanUpACLS();
				return;
			}
			callback(true);
		}
		
		/**
		 * Finds all instances where the actor for an ACL is invalid
		 * and removes the ACL (doesnt just do it for this user, but works on all invalids acls) 
		 * 
		 */		
		private function cleanUpACLS():void {
			var baseXML:XML = connection.packageRequest("asset.acl.invalid.remove", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;
			connection.sendRequest(baseXML, aclsCleanedUp);
		}
		
		private function aclsCleanedUp(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("cleaning up", e)) == null) {
				callback(false);
				return;
			}
			callback(true);
		}
	}
}