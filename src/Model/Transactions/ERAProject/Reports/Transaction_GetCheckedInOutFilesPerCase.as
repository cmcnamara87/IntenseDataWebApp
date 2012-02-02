package Model.Transactions.ERAProject.Reports
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAFile;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetCheckedInOutFilesPerCase
	{
		private var connection:Connection;
		private var callback:Function;
		private var year:String;
		
		private var caseFileArray:Array = new Array();
		
		private var eraCaseArray:Array;
		private var eraCaseCounter:Number = 0;
		
		private var currentERACase:Model_ERACase;
		
		public function Transaction_GetCheckedInOutFilesPerCase(year:String, connection:Connection, callback:Function)
		{
			this.year = year;
			this.connection = connection;
			this.callback = callback;
			
			getCheckedInOutFilesPerCase();
		}
		
		private function getCheckedInOutFilesPerCase():void {
			// First we are going to get out all the cases
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + AppController.currentEraProject.year + "' and ";
			argsXML.where += "type>=ERA/case"; // and namespace>='ERA/" + year + "'";
			argsXML.action = "get-meta";
			
			trace("query", baseXML);
			connection.sendRequest(baseXML, gotCases);
		}
		
		private function gotCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases for checked in out files per case", e)) == null) {
				callback(false, null);
				return;
			}
			trace("got cases");
			//trace("something", data);
			eraCaseArray = AppModel.getInstance().parseResults(data, Model_ERACase);
			eraCaseArray.sortOn(["researcherLastName", "researcherFirstName", "rmCode"], [Array.CASEINSENSITIVE]);
			trace("seropis;y");
			getFiles();
		}
		private function getFiles():void {
			currentERACase = eraCaseArray[eraCaseCounter];
			
			// get the files for this case that are in the evidence whatever
			/*asset.query :where class>='recensio:base/resource/media' and related to{room} (
				type>=ERA/room and
				ERA-room/room_type='forensiclab' and
				related to{case} (id=4626) */
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>='ERA/" + year + "' ";
			argsXML.where += "and class>='recensio:base/resource/media' ";
			argsXML.where += "and ERA-evidence/checked_out=true ";
			argsXML.where += "and related to{room} (type>=ERA/room and ERA-room/room_type='forensiclab' ";
			argsXML.where += "and related to{case} (id=" + currentERACase.base_asset_id + "))"
			argsXML.action = "get-meta";
			
//			trace("query", baseXML);
			connection.sendRequest(baseXML, gotFiles);
		}
		
		private function gotFiles(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("get cases", e)) == null) {
				callback(false, null);
				return;
			}
			
			var fileArray:Array = AppModel.getInstance().parseResults(data, Model_ERAFile);
			trace("found files", fileArray.length);
			fileArray.sortOn(["title"], [Array.CASEINSENSITIVE]);
			
			// if there are files, lets store it
			// since we only want to show cases with files checked out (apparently)
			if(fileArray.length) {
				// now lets store this in the object
				var caseFileObject:Object = new Object();
				caseFileObject.eraCase = currentERACase;
				caseFileObject.files = fileArray;
				caseFileArray.push(caseFileObject);
			}
			
			eraCaseCounter++;
			
			if(eraCaseCounter >= eraCaseArray.length) {
				callback(true, caseFileArray);
			} else {
				getFiles();
			}
			
		}
	}
}