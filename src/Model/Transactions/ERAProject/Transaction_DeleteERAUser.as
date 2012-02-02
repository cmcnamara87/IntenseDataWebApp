package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_DeleteERAUser
	{
		private var connection:Connection; 
		private var callback:Function;
		private var username:String;
		
		
		private var needToRemoveCount:Number = 0;
		private var removedCount:Number = 0;
		
		public function Transaction_DeleteERAUser(username:String, connection:Connection, callback:Function)
		{
			this.username = username;
			this.connection = connection;
			this.callback = callback;
			
			trace("*******************deleting user");
			findInvalidCases();
		}
		
		
		private function findInvalidCases():void {
			trace("*******************find cases with user", username);
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "type>=ERA/case and (xpath(ERA-case/researcher_username/username)='"+username+"' or  xpath(ERA-case/production_manager_username/username)='"+username+"' or xpath(ERA-case/production_team_username/username)='"+username+"')";
			
			connection.sendRequest(baseXML, gotAllCases);
		}
		
		private function gotAllCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("find cases that need to be upadted", e)) == null) {
				trace("failed to find any cases", e);
				callback(false);
				return;
			}
			
			var idList:XMLList = data.reply.result.id;
			needToRemoveCount = idList.length();
			trace("found", needToRemoveCount, "cases to remove user from");
			
			if(needToRemoveCount == 0) {
				deleteUser();
				return;
			}
			
			for each(var caseID:Number in idList) {
				trace("*******************removing user from case", caseID, username);
				AppModel.getInstance().removeUserFromCase(caseID, username, removedUserFromCase);
			}
		}
		private function removedUserFromCase(status:Boolean):void {
			trace("removed user from case", status);
			removedCount++;
			if(removedCount == needToRemoveCount) {
				deleteUser();
				return;
			}
		}
		
		private function deleteUser():void {
			// Get out the ERA object
			trace("DELETING USER", username);
			var baseXML:XML = connection.packageRequest("user.destroy", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.domain = "system";
			argsXML.user = username;
			
			connection.sendRequest(baseXML, userDeleted);
		}
		
		private function userDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era user", e)) == null) {
				callback(false);
				return;
			} else {
				trace("USER DELETED");
				callback(true, username);
				return;
			}
		}

	}
}