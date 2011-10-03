package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_DeleteERAProject
	{
		private var connection:Connection; 
		private var callback:Function;
		private var eraProjectID:Number;
		private var year:String;
		private var currentRoleIndex:Number = 0;
		
		public function Transaction_DeleteERAProject(eraProjectID:Number, connection:Connection, callback:Function)
		{
			this.eraProjectID = eraProjectID;
			this.connection = connection;
			this.callback = callback;
			
			getERAToDelete();
		}
		
		private function getERAToDelete():void {
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = eraProjectID;
			
			connection.sendRequest(baseXML, eraDataRetrieved);
		}
		
		private function eraDataRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting era project to delete", e)) == null) {
				callback(false, null);
			}
			
			var eraProject:Model_ERAProject = new Model_ERAProject();
			eraProject.setData(data.reply.result.asset[0]);
			
			year = eraProject.year;
			
			deleteERARoles();
		}

		/**
		 * Loops through the roles array and deletes all of those roles 
		 * @param e
		 * 
		 */
		private function deleteERARoles(e:Event = null):void {
			if(e == null) {
				// This is the first time we are creating a role (probably sys-admin)
				// so its not coming back from making another one
				deleteERARole(Model_ERAUser.ERARoles[currentRoleIndex], year, deleteERARoles);
				return;
			}
			
			// We are coming back from creating another role
			// check all went well
			if(AppModel.getInstance().getData(Model_ERAUser.ERARoles[currentRoleIndex], e) == null) {
				callback(false, null);
				return;
			}
			
			// Do the next role
			currentRoleIndex++;
			
			if(currentRoleIndex == Model_ERAUser.ERARoles.length) {
				// We have finished creating all the roles successfully
				// lets make hte project
				deleteERAProject();
				return;
			}
			
			deleteERARole(Model_ERAUser.ERARoles[currentRoleIndex], year, deleteERARoles);
		}
		
		/**
		 * Creates an ERA role 
		 * @param roleName	The anme of the role
		 * @param roleYear	The year for the ERA submission
		 * @param callback	The function to call on completion
		 * 
		 */
		private function deleteERARole(roleName:String, roleYear:String, callback:Function):void {
			var baseXML:XML = connection.packageRequest("authorization.role.destroy", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create teh sys-admin role
			argsXML.role = roleName + "_" + roleYear;
			
			connection.sendRequest(baseXML, deleteERARoles);
		}
		
		private function deleteERAProject():void {
			var baseXML:XML = connection.packageRequest("asset.destroy", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = eraProjectID;
			
			connection.sendRequest(baseXML, eraDestroyed);		
		}
		
		private function eraDestroyed(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era project", e)) == null) {
				callback(false);
			} else {
				callback(true, eraProjectID);
			}
		}
	}
}