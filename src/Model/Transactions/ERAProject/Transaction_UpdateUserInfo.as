package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_UpdateUserInfo
	{
		private var username:String;
		private var firstName:String;
		private var lastName:String;
		private var connection:Connection;
		private var callback:Function;
		
		private var numberOfCasesToUpdate:Number = 0;
		private var casesUpdated:Number = 0;
	
		
		public function Transaction_UpdateUserInfo(username:String, firstName:String, lastName:String, connection:Connection, callback:Function)
		{
			this.username = username;
			this.firstName = firstName;
			this.lastName = lastName;
			this.connection = connection;
			this.callback = callback;
			
			updateInfo();
		}
		
		private function updateInfo():void {
			var baseXML:XML = connection.packageRequest("user.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.user = username;
			argsXML.domain = "system";
			argsXML.meta["ERA-user"].first_name = firstName;
			argsXML.meta["ERA-user"].last_name = lastName;
			
			connection.sendRequest(baseXML, userInfoUpdated);	
		}
		
		private function userInfoUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("udating user info", e)) == null) {
				callback(false);
				return;
			}
			
			trace("USER INFO UPDATED, CHECKING CASES");
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.where = "type>=ERA/case and (ERA-case/production_manager_username/username='" + username + "' " +
				"or ERA-case/researcher_username/username='" + username + "' " +
				"or ERA-case/production_team_username/username='" + username + "')";

			argsXML.size = "infinity";
			argsXML.action = "get-meta";
			
			trace("sending xml", baseXML);
			connection.sendRequest(baseXML, getCasesNeedUpdating);
		}
		
		private function getCasesNeedUpdating(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases need update", e)) == null) {
				callback(false);
				return;
			}
			
			trace("asset data", data);
			
			numberOfCasesToUpdate = data.reply.result.asset.length();
			
			trace("CASES FOUND", numberOfCasesToUpdate);
			
			if(numberOfCasesToUpdate == 0) {
				trace("FOUND NO CASES, GETTING USERS");
				getUsers();
				return;
			}
			
			
			for each(var eraCaseXML:XML in data.reply.result.asset) {
				// The Case's XML
				
				// Create our request and its XML
				var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
				var argsXML:XMLList = baseXML.service.args;
				
				
				trace("UPDATING CASE", eraCaseXML.@id);
				// Request XML (we put in a copy of the current era case XML)
				argsXML.id = eraCaseXML.@id;
				argsXML.meta = "";
				argsXML.meta.appendChild((eraCaseXML.meta["ERA-case"]).copy());
				argsXML.meta.@action = "replace";
				
				// Lets remove all of the user access stuff, from our new copied XML document
				// (the original is still in tact, and we will copy back what is still valid)
				delete argsXML.meta["ERA-case"]["production_manager_username"];
				delete argsXML.meta["ERA-case"]["production_team_username"];
				delete argsXML.meta["ERA-case"]["researcher_username"];
				
				// Okay, now thast all gone, lets add back what we need
				for each(var user:XML in eraCaseXML.meta["ERA-case"]["production_manager_username"]) {
					if(user.username != username) { 
						argsXML.meta["ERA-case"].appendChild(
							XML('<production_manager_username><username>' +  user.username + '</username><first_name>'+ user.first_name + '</first_name><last_name>' + user.last_name + '</last_name></production_manager_username>')
						);
					} else {
						argsXML.meta["ERA-case"].appendChild(
							XML('<production_manager_username><username>' +  username + '</username><first_name>'+ firstName + '</first_name><last_name>' + lastName + '</last_name></production_manager_username>')
						);
					}
				}
				
				for each(var user:XML in eraCaseXML.meta["ERA-case"]["production_team_username"]) {
					if(user.username != username) { 
						argsXML.meta["ERA-case"].appendChild(
							XML('<production_team_username><username>' +  user.username + '</username><first_name>'+ user.first_name + '</first_name><last_name>' + user.last_name + '</last_name></production_team_username>')
						);
					} else {
						argsXML.meta["ERA-case"].appendChild(
							XML('<production_manager_username><username>' +  username + '</username><first_name>'+ firstName + '</first_name><last_name>' + lastName + '</last_name></production_manager_username>')
						);
					}
				}
				
				for each(var user:XML in eraCaseXML.meta["ERA-case"]["researcher_username"]) {
					if(user.username != username) { 
						argsXML.meta["ERA-case"].appendChild(
							XML('<researcher_username><username>' +  user.username + '</username><first_name>'+ user.first_name + '</first_name><last_name>' + user.last_name + '</last_name></researcher_username>')
						);
					} else {
						argsXML.meta["ERA-case"].appendChild(
							XML('<production_manager_username><username>' +  username + '</username><first_name>'+ firstName + '</first_name><last_name>' + lastName + '</last_name></production_manager_username>')
						);
					}
				}
				
				trace("xml", argsXML);
				connection.sendRequest(baseXML, caseUpdated);	
			}
		}
		
		private function caseUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating case", e)) == null) {
				callback(false);
				return;
			}
			trace("case updated");
			casesUpdated++;
			
			if(casesUpdated == numberOfCasesToUpdate) {
				getUsers();
			}
		}
		
		private function getUsers():void {
			// just get the list of all users again? just saves doing it else where
			AppModel.getInstance().getERAUsers(gotUsers);
		}
		
		private function gotUsers(status:Boolean, usersArray:Array=null):void {
			if(!status) {
				callback(false);
				return;
			}
			callback(true, usersArray);
		}
	}
}