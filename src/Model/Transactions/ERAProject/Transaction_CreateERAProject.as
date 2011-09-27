package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_CreateERAProject
	{
		private var day:String; // The day its due
		private var month:String; // the month its due (jan, feb etc)
		private var year:String; // the year its due
		private var packageSize:String; // the size of the package in mb
		private var connection:Connection; 
		private var callback:Function;
		
		
		private var currentRoleIndex:Number = 0;
		
		private var newERAProjectID:Number; // The ID of the project after its all saved
		
		public function Transaction_CreateERAProject(day:String, month:String, year:String, packageSize:String, connection:Connection, callback:Function)
		{
			this.day = day;
			this.month = month;
			this.year = year;
			this.packageSize = packageSize;
			this.connection = connection;
			this.callback = callback;
			
			createRoles();
		}
		
		private function createRoles():void {
			// sys admin
			// monitors
			// researcher
			// production manager
			// production team
			// viewers
			
			createAllRoles();
		}
		
		/**
		 * Loops through the roles array and creates all of those roles 
		 * @param e
		 * 
		 */
		private function createAllRoles(e:Event = null):void {
			if(e == null) {
				// This is the first time we are creating a role (probably sys-admin)
				// so its not coming back from making another one
				createERARole(AppController.ERARoles[currentRoleIndex], year, createAllRoles);
				return;
			}
			
			// We are coming back from creating another role
			// check all went well
			if(AppModel.getInstance().getData(AppController.ERARoles[currentRoleIndex], e) == null) {
				callback(false, null);
				return;
			}
			
			// Do the next role
			currentRoleIndex++;
			
			if(currentRoleIndex == AppController.ERARoles.length) {
				// We have finished creating all the roles successfully
				// lets make hte project
				createERAProject();
				return;
			}
			
			createERARole(AppController.ERARoles[currentRoleIndex], year, createAllRoles);
		}

		/**
		 * Creates an ERA role 
		 * @param roleName	The anme of the role
		 * @param roleYear	The year for the ERA submission
		 * @param callback	The function to call on completion
		 * 
		 */
		private function createERARole(roleName:String, roleYear:String, callback:Function):void {
			var baseXML:XML = connection.packageRequest("authorization.role.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create teh sys-admin role
			argsXML.role = roleName + "_" + roleYear;
			argsXML.ifexists = "ignore";
			
			connection.sendRequest(baseXML, createAllRoles);
		}
		
		private function createERAProject():void {
			var baseXML:XML = connection.packageRequest("asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.type = "ERA-project";
			
			// Create a namespace for this era
			argsXML.namespace = "ERA/" + this.year;
			argsXML.namespace.@create = true;
			
			// Set this as a collection
			argsXML.collection = true;
			
			// Setup the era meta-data
			argsXML.meta["ERA-project"]["due_date"] = day + "-" + month + "-" + year;
			argsXML.meta["ERA-project"]["package_size"] = packageSize;
			
			connection.sendRequest(baseXML, eraCreated);		
		}
		
		private function eraCreated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("creating era project", e)) == null) {
				callback(false, null);
				return;
			}
			
			newERAProjectID = data.reply.result.id;
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = newERAProjectID;
				
			connection.sendRequest(baseXML, eraDataRetrieved);
		}
		
		private function eraDataRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("creating era project", e)) == null) {
				callback(false, null);
			}
			
			var eraProject:Model_ERAProject = new Model_ERAProject();
			eraProject.setData(data.reply.result.asset[0]);
			
			callback(true, eraProject);
		}
	}
}