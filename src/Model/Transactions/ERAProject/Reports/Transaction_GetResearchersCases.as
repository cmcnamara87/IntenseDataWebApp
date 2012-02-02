package Model.Transactions.ERAProject.Reports
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetResearchersCases
	{
		private var connection:Connection;
		private var callback:Function;
		private var year:String;
		
		private var researcherArray:Array;
		private var researcherCaseArray:Array = new Array();
		
		
		private var currentResearcher:Model_ERAUser;
		private var researcherCounter:Number = 0;
		
		public function Transaction_GetResearchersCases(year:String, connection:Connection, callback:Function)
		{
			this.year = year;
			this.connection = connection;
			this.callback = callback;
			
			
			AppModel.getInstance().getERAUsersWithRole(Model_ERAUser.RESEARCHER, year, gotResearchers);
			
		}
		
		private function gotResearchers(status:Boolean, role:String="", userArray:Array=null) {
			if(!status) {
				callback(false);
				return;
			}
			
			researcherArray = userArray;
			researcherArray.sortOn(["lastName", "firstName"], [Array.CASEINSENSITIVE]);
			
			getCases();
		}
		
		private function getCases():void {
			if(researcherCounter >= researcherArray.length) {
				callback(true, researcherCaseArray);
				return;
			}
			
			currentResearcher = researcherArray[researcherCounter];
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + year + "' ";
			argsXML.where += "and type>=ERA/case ";
			argsXML.where += "and ERA-case/researcher_username/username='" + currentResearcher.username + "'";
			argsXML.action = "get-meta";
			
			connection.sendRequest(baseXML, gotCases);
		}
				
		private function gotCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases", e)) == null) {
				callback(false, null);
				return;
			}
			
			var caseArray:Array = AppModel.getInstance().parseResults(data, Model_ERACase);
			caseArray.sortOn(["rmCode"], [Array.CASEINSENSITIVE]);

			
				// now lets store this in the object
			var researcherCaseObject:Object = new Object();
			researcherCaseObject.researcher = currentResearcher;
			researcherCaseObject.caseArray = caseArray;
			researcherCaseArray.push(researcherCaseObject);
			
			researcherCounter++;

			getCases();
		}
	}
}