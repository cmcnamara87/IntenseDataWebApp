package Model.Transactions.ERAProject.Reports
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetCasesDownloaded
	{
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_GetCasesDownloaded(connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			
			getCasesDownloaded();
		}

		private function getCasesDownloaded():void {
			// asset.query :where type>=ERA/case and related to{rooms} (type>=ERA/room and ERA-room/room_type='exhibit' and related to{evidence} any)
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + AppController.currentEraProject.year + "' and ";
			argsXML.where += "type>=ERA/case";
			argsXML.action = "get-meta";
			
			trace("query", baseXML);
			connection.sendRequest(baseXML, gotCases);
		}
		private function gotCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases", e)) == null) {
				callback(false, null);
				return;
			}
			var eraCaseArray:Array = AppModel.getInstance().parseResults(data, Model_ERACase);
			eraCaseArray.sortOn(["readyForDownload", "libraryDownloaded", "researcherLastName", "researcherFirstName", "rmCode"], [Array.CASEINSENSITIVE]);
			
			callback(true, eraCaseArray);
		}
	}
}