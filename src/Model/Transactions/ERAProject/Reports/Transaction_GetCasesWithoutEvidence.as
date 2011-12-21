package Model.Transactions.ERAProject.Reports
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	/**
	 * Finds all ERA Cases (@see @Model_ERACase) that do not have
	 * any files uploaded in the Evidence Box 
	 * @author cmcnamara87
	 * 
	 */	
	public class Transaction_GetCasesWithoutEvidence
	{
		private var connection:Connection;
		private var callback:Function;
		
		private var allERACases:Array;
		
		public function Transaction_GetCasesWithoutEvidence(connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			
			getAllCases();
		}
		
		private function getAllCases():void {
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
			allERACases = AppModel.getInstance().parseResults(data, Model_ERACase);
			allERACases.sortOn(["rmCode"], [Array.CASEINSENSITIVE]);
			// now we need to get out all the cases with evidence, and manually do a 'not'
			// since this 
			/*
			> asset.query :where type>=ERA/case and related to{rooms} (type>=ERA/room and ERA-room/room_type='evidenceroom' and not(related to{evidence} any))
			error: executing asset.query: [arc.mf.server.Services$ExServiceError]: call to service 'asset.query' failed: java.lang.NullPointerException
			*/
			// is what i am getting from mediaflux
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + AppController.currentEraProject.year + "' and ";
			argsXML.where += "type>=ERA/case and related to{rooms} (type>=ERA/room and ERA-room/room_type='evidenceroom' and related to{evidence} any)"
			argsXML.action = "get-meta";
			
			trace("query", baseXML);
			connection.sendRequest(baseXML, gotCasesWithEvidence);
		}
		private function gotCasesWithEvidence(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases with evidence", e)) == null) {
				callback(false, null);
				return;
			}
			var eraCasesWithEvidence:Array = AppModel.getInstance().parseResults(data, Model_ERACase);
			
			var eraCasesWithoutEvidence:Array = new Array();
			
			for(var i:Number = 0; i < allERACases.length; i++) {
				var found:Boolean = false;
				for(var j:Number = 0; j < eraCasesWithEvidence.length; j++) {
					if((eraCasesWithEvidence[j] as Model_ERACase).base_asset_id == (allERACases[i] as Model_ERACase).base_asset_id) {
						found = true;
					}
				}
				if(!found) {
					eraCasesWithoutEvidence.push(allERACases[i]);
				}
			}
			
			callback(true, eraCasesWithoutEvidence);
		}
	}
}