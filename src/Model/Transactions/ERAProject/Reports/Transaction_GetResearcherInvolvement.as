package Model.Transactions.ERAProject.Reports
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERANotification;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetResearcherInvolvement
	{
		private var connection:Connection;
		private var callback:Function;
		private var year:String;
		
		private var eraCaseArray:Array;
		
		private var currentERACase:Model_ERACase;
		private var eraCaseCounter:Number = 0;
		private var researcherCounter:Number = 0;
		
		public function Transaction_GetResearcherInvolvement(year:String, connection:Connection, callback:Function)
		{
			this.year = year;
			this.connection = connection;
			this.callback = callback;
			
			getResearcherInvolvement();
		}
		
		private function getResearcherInvolvement():void {
			// First we are going to get out all the cases
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "type>=ERA/case and namespace>='ERA/" + year + "'";
			argsXML.action = "get-meta";
			
//			trace("getting all casses", baseXML);
			connection.sendRequest(baseXML, gotCases);
		}
		
		private function gotCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases for researcher involvement", e)) == null) {
				callback(false, null);
				return;
			}
			trace("got cases");
			//trace("something", data);
			eraCaseArray = AppModel.getInstance().parseResults(data, Model_ERACase);
			eraCaseArray.sortOn(["researcherLastName", "researcherFirstName", "rmCode"], [Array.CASEINSENSITIVE]);
			
			// lets see all the files that were approved or not approved
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + AppController.currentEraProject.year + "' and ";
			argsXML.where += "xpath(ERA-notification/type)='file_approve_by_researcher' or ";
			argsXML.where += "xpath(ERA-notification/type)='file_not_approve_by_researcher'";
			argsXML.action = "get-meta";
			
//			trace("getting ", baseXML);
			connection.sendRequest(baseXML, gotApprovedNotApprovedFiles);
		}
		
		private function gotApprovedNotApprovedFiles(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases for researcher involvement", e)) == null) {
				callback(false, null);
				return;
			}
			trace("got cases with approval");
			//trace("something", data);
			var eraNotificationArray:Array = AppModel.getInstance().parseResults(data, Model_ERANotification);
			
			// now we should have removed any cases that have a notification
			for each(var eraNotification:Model_ERANotification in eraNotificationArray) {
				for(var i:Number = 0; i < eraCaseArray.length; i++) {
					var currentERACase:Model_ERACase = eraCaseArray[i] as Model_ERACase;
					if(eraNotification.eraCase.base_asset_id == currentERACase.base_asset_id) {
						eraCaseArray.splice(i, 1);
					}
				}
			}
			
			checkForComments();
		}
			
		private function checkForComments():void {
			if(eraCaseArray.length == 0 || eraCaseCounter >= eraCaseArray.length) {
				// do something here, probably 
				// END CASE HERE
				finished();
				return;
			}
			
			currentERACase = eraCaseArray[eraCaseCounter];
			trace("counter", eraCaseCounter, eraCaseArray.length);
			trace("LOOKING AT CASE", currentERACase.title);
			checkForResearcherComments();
		}
		
		private function checkForResearcherComments():void {
			// now look at each researcher, and see if they left a comment
			if(currentERACase.researchersArray.length == 0 || researcherCounter >= currentERACase.researchersArray.length) {
				// there are no researchers for some reason, move onto the next case
				eraCaseCounter++;
				checkForComments();
			}
			
			var currentResearcher:Model_ERAUser = (currentERACase.researchersArray[researcherCounter] as Model_ERAUser);
			
			var baseXML:XML = connection.packageRequest("asset.count", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + AppController.currentEraProject.year + "' and ";
			argsXML.where += "type>=ERA/case and ";
			argsXML.where += "id=" + currentERACase.base_asset_id + " and ";
			argsXML.where += "related to{rooms} (type>=ERA/room and related to{evidence} (related to{conversation} (r_base/creator='" + currentResearcher.username + "') ) )";
			trace("query", baseXML);
			connection.sendRequest(baseXML, gotResearcherComments);
		}
		
		private function gotResearcherComments(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all rooms", e)) == null) {
				callback(false, null);
				return;
			}
			trace("got count", data);
			// Update the era room here
			trace("count is", data.reply.result.total);
			
			if(data.reply.result.total >= 0) {
				// we got a result
				// so splice this one out of the array
				eraCaseArray.splice(eraCaseCounter, 1);
				// move onto the next case
				eraCaseCounter++;
				checkForComments();
			} else {
				// we didnt find any comments
				// now we have to check the next researcher
				researcherCounter++;
				checkForResearcherComments();
			}
		}
		
		private function finished():void {
			callback(true, eraCaseArray);
		}
	}
}