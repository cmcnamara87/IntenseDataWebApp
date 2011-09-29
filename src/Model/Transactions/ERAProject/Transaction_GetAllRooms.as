package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERARoom;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetAllRooms
	{
		private var connection:Connection;
		private var callback:Function;
		private var caseID:Number;
		
		public function Transaction_GetAllRooms(caseID:Number, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.caseID = caseID;
			getAllRooms();
		}
		
		private function getAllRooms():void {
			// asset.query :where asset in collection <id>
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.action = "get-meta";
			
			// Get out all the ERA cases in this ERA{year} collection
			//			argsXML.where = "asset in collection " + eraID + " and type=ERA/case";
			// TODO make era case go into the era collection
			argsXML.where = "type=ERA/room";
			
			connection.sendRequest(baseXML, gotAllRooms);
		}
		
		private function gotAllRooms(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all rooms", e)) == null) {
				callback(false, null);
				return;
			}
			
			var eraRoomArray:Array = AppModel.getInstance().parseResults(data, Model_ERARoom);
			
			callback(true, eraRoomArray);
		}
	}
}