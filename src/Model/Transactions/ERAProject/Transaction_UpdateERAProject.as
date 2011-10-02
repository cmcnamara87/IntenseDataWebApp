package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_UpdateERAProject
	{
		private var day:String; // The day its due
		private var month:String; // the month its due (jan, feb etc)
		private var year:String; // the year its due
		private var packageSize:String; // the size of the package in mb
		private var connection:Connection; 
		private var callback:Function;
		private var eraProjectID:Number;
		
		private var newERAProjectID:Number; // The ID of the project after its all saved
		
		public function Transaction_UpdateERAProject(eraProjectID:Number, day:String, month:String, year:String, packageSize:String, connection:Connection, callback:Function)
		{
			this.eraProjectID = eraProjectID;
			this.day = day;
			this.month = month;
			this.year = year;
			this.packageSize = packageSize;
			this.connection = connection;
			this.callback = callback;
			
			createERAProject();
		}

		private function createERAProject():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;

			// Setup the era meta-data
			argsXML.id = eraProjectID;
			argsXML.meta["ERA-project"]["due_date"] = day + "-" + month + "-" + year;
			argsXML.meta["ERA-project"]["package_size"] = packageSize;
			
			connection.sendRequest(baseXML, eraUpdated);		
		}
		
		private function eraUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating era project", e)) == null) {
				callback(false, null);
				return;
			}
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = eraProjectID;
			
			connection.sendRequest(baseXML, eraDataRetrieved);
		}
		
		private function eraDataRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting update era project", e)) == null) {
				callback(false, null);
			}
			
			var eraProject:Model_ERAProject = new Model_ERAProject();
			eraProject.setData(data.reply.result.asset[0]);
			
			callback(true, eraProject);
		}
	}
}