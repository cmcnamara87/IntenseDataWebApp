package Model.Transactions.ERAProject.Reports
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetResearchersInSchools
	{
		private var connection:Connection;
		private var callback:Function;
		private var schoolArray:Array;
		private var schoolCounter:Number = 0;
		
		private var researcherObject:Object = new Object();
		
		public function Transaction_GetResearchersInSchools(schoolArray:Array, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.schoolArray = schoolArray;
			
			if(!schoolArray.length) callback(false);
			
			getResearchers();
		}
		
		private function getResearchers():void {
			// asset.query :where ERA-case/qut_school='MECA'
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + AppController.currentEraProject.year + "' and ";
			argsXML.where += "ERA-case/qut_school='" + schoolArray[schoolCounter] + "'";
			argsXML.action = "get-meta";
			
			trace("query", baseXML);
			connection.sendRequest(baseXML, gotAllCases);
		}
		
		private function gotAllCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting cases with schools", e)) == null) {
				callback(false, null);
				return;
			}
			var currentSchool:String = schoolArray[schoolCounter];
			trace("looking at school", currentSchool);
			
			researcherObject[currentSchool] = new Array();
			trace("researcher object current school", researcherObject[currentSchool]);
			var eraCaseArray:Array = AppModel.getInstance().parseResults(data, Model_ERACase);
			eraCaseArray.sortOn(["researcherLastName", "researcherFirstName", "rmCode"], [Array.CASEINSENSITIVE]);
			
			trace("looking at school", currentSchool, eraCaseArray.length);
			
			// we need to get out all the unique researchers
			
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				// check if the researcher is already in our researcher array
				for each(var caseResearcher:Model_ERAUser in eraCase.researchersArray) {
					trace("got researcher", caseResearcher.username);
					var found:Boolean = false;

					for each(var researcher:Model_ERAUser in researcherObject[currentSchool]) {
						trace("looking at researcher", researcher.username);
						if(researcher.username == caseResearcher.username) {
							found = true;
						}
					}
					if(!found) {
						trace("adding");
						
						(researcherObject[currentSchool] as Array).push(caseResearcher);
					}
				}
				
			}
			
			trace("researcher object current school length", (researcherObject[currentSchool] as Array).length);
			
			(researcherObject[currentSchool] as Array).sortOn(["lastName", "firstName"], [Array.CASEINSENSITIVE]);
			if(++schoolCounter >= schoolArray.length) {
				callback(true, researcherObject);
			} else {
				getResearchers();
			}
		}
	}
}