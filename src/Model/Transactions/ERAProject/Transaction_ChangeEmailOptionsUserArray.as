package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_ChangeEmailOptionsUserArray
	{
		private var connection:Connection;
		private var callback:Function;
		private var eraID:Number;
		private var role:String;
		private var usernameArray:Array;
		
		public function Transaction_ChangeEmailOptionsUserArray(eraID:Number, role:String, usernameArray:Array, connection:Connection, callback:Function)
		{
			trace("changing email option user array", usernameArray);
			this.eraID = eraID;
			this.role = role;
			this.usernameArray = usernameArray;
			this.connection = connection;
			this.callback = callback;
			
			getEraProject();
		}
		
		private function getEraProject():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = eraID;
			
			connection.sendRequest(baseXML, gotERAProject);
		}
		
		private function gotERAProject(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting era project", e)) == null) {
				callback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = eraID;
			argsXML.meta.@action = "replace";
			argsXML.meta["ERA-project"] = "";
			argsXML.meta["ERA-project"].due_date = data.reply.result.asset.meta["ERA-project"]["due_date"];
			argsXML.meta["ERA-project"].package_size = data.reply.result.asset.meta["ERA-project"]["package_size"];
			

			trace("username array length", usernameArray);
			for each(var username:String in usernameArray) {
				argsXML.meta["ERA-project"].appendChild(
					XML('<email_notifications><role>' +  role + '</role><username>' + username + '</username></email_notifications>')
				);
				trace("adding user", username, "role", role);
			}

			
			
			var oldEmailNotificationsList:XMLList = data.reply.result.asset.meta["ERA-project"]["email_notifications"];
			
			
			for each(var emailNotificationOption:XML in oldEmailNotificationsList) {
				// only hcanging 1 specific username one
				if(emailNotificationOption.username != undefined) {
					// it has a username, so we need to check if we should add it back in, or its the one we changed
					// if its not the one we changed, add it back in
					var found:Boolean = false;
					for each(var username:String in usernameArray) {
						if(emailNotificationOption.username == username && emailNotificationOption.role == role) {
							found = true;
						}
					}
					if(!found) {
						argsXML.meta["ERA-project"].appendChild(
							XML('<email_notifications><role>' +  emailNotificationOption.role + '</role><username>' + emailNotificationOption.username + '</username></email_notifications>')
						);
					}
				} else {
					// its a role one, so we add it back in (since we didnt change those)
					// only add in the role if its not the same as the one we changed
					if(emailNotificationOption.role != role) {
						argsXML.meta["ERA-project"].appendChild(
							XML('<email_notifications><role>' +  emailNotificationOption.role + '</role></email_notifications>')
						);
					}
				}
			}
			trace("xml", argsXML);
			connection.sendRequest(baseXML, emailStatusUpdated);		
		}
		
		private function emailStatusUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("email options changed", e)) == null) {
				callback(false);
				return;
			}
			
			
			// get the current era project again
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = eraID;
			
			connection.sendRequest(baseXML, gotERAProjectChanged);
		}
		private function gotERAProjectChanged(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting changed era project", e)) == null) {
				callback(false);
				return;
			} 
			
			var eraProject:Model_ERAProject = new Model_ERAProject();
			eraProject.setData(data.reply.result.asset[0]);
			
			callback(true, eraProject);
			
		}
	}
}