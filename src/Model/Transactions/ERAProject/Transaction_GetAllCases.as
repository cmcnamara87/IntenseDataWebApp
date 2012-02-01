package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetAllCases
	{
		private var connection:Connection;
		private var callback:Function;
		private var eraID:Number;
		
		public function Transaction_GetAllCases(eraID:Number, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.eraID = eraID;
			getAllCases();
		}
		
		private function getAllCases():void {
			// asset.query :where asset in collection <id>
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.action = "get-meta";

			// Get out all the ERA cases in this ERA{year} collection
//			argsXML.where = "asset in collection " + eraID + " and type=ERA/case";
			// TODO make era case go into the era collection
			argsXML.where = "type=ERA/case and related to{era} (id=" + eraID + ")";
			argsXML.size = "infinity";
			connection.sendRequest(baseXML, gotAllCases);
		}
		
		private function gotAllCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all cases", e)) == null) {
				callback(false, null);
				return;
			}
			
			var eraCaseArray:Array = AppModel.getInstance().parseResults(data, Model_ERACase);
			
			// Now we need to do some specialized stripping of cases here
			// if someone is a librarian only! we need to strip out cases that arent ready

			eraCaseArray.sortOn(["researcherLastName", "researcherFirstName"], [Array.CASEINSENSITIVE]);
			
			callback(true, eraCaseArray);
		}
	}
}