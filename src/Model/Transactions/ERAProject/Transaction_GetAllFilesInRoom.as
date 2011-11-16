package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAFile;
	import Model.Model_ERALogItem;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetAllFilesInRoom
	{
		private var connection:Connection;
		private var callback:Function;
		private var roomID:Number;
		
		public function Transaction_GetAllFilesInRoom(roomID:Number, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.roomID = roomID;
			getAllFiles();
		}
		
		private function getAllFiles():void {
			// asset.query :where asset in collection <id>
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.action = "get-meta";

			// Get all the media for the room
			argsXML.where = "class>='recensio:base/resource/media' and related to{room} (id=" + roomID + ")";
			
			connection.sendRequest(baseXML, gotAllCases);
		}
		
		private function gotAllCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all files in " + roomID, e)) == null) {
				callback(false, null);
				return;
			}
			
			var eraEvidenceArray:Array = AppModel.getInstance().parseResults(data, Model_ERAFile);
			
			eraEvidenceArray.sortOn(["title"], [Array.CASEINSENSITIVE]);
			
			callback(true, eraEvidenceArray);
		}
	}
}