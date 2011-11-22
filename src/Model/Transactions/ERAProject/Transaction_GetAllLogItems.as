package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERALogItem;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetAllLogItems
	{
		private var connection:Connection;
		private var callback:Function;
		private var roomID:Number;
		
		public function Transaction_GetAllLogItems(roomID:Number, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.roomID = roomID;
			getAllLogItems();
		}
		
		private function getAllLogItems():void {
			// asset.query :where asset in collection <id>
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.action = "get-meta";
			argsXML.size = "infinity";
			
			// Get out all the ERA cases in this ERA{year} collection
			//			argsXML.where = "asset in collection " + eraID + " and type=ERA/case";
			// TODO make era case go into the era collection
			argsXML.where = "type=ERA/logitem and related to{room} (id=" + roomID + ")";
			
			connection.sendRequest(baseXML, gotAllCases);
		}
		
		private function gotAllCases(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all log items", e)) == null) {
				callback(false, null);
				return;
			}
			
			var eraLogItemArray:Array = AppModel.getInstance().parseResults(data, Model_ERALogItem);
			
			eraLogItemArray.sortOn(["type"], [Array.CASEINSENSITIVE]);
			
			callback(true, eraLogItemArray);
		}
	}
}