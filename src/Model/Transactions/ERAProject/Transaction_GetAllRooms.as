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
		
		private var eraRoomArray:Array;
		private var roomCounter:Number = 0;
		
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
			argsXML.where = "type=ERA/room and related to{case} (id=" + caseID + ")";
			
			connection.sendRequest(baseXML, gotAllRooms);
		}
		
		private function gotAllRooms(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all rooms", e)) == null) {
				callback(false, null);
				return;
			}
			
			eraRoomArray = AppModel.getInstance().parseResults(data, Model_ERARoom);
			
			trace("room array length", eraRoomArray.length);
			
			if(eraRoomArray.length > 0) {
				// we need to go through, and work outif there are active files
				// asset.count :where related to{room} (id=5114) and (ERA-evidence/hot=true or type>=ERA/logitem)
				getEvidenceCount();
			} else {
				callback(true, eraRoomArray);
			}
		}
		
		private function getEvidenceCount():void {
			var baseXML:XML = connection.packageRequest("asset.count", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			if((eraRoomArray[roomCounter] as Model_ERARoom).roomType == Model_ERARoom.EVIDENCE_ROOM) {
				argsXML.where = "related to{room} (id=" + (eraRoomArray[roomCounter] as Model_ERARoom).base_asset_id + ") and (class>='recensio:base/resource/media')";
			} else {
				argsXML.where = "related to{room} (id=" + (eraRoomArray[roomCounter] as Model_ERARoom).base_asset_id + ") and (ERA-evidence/hot=true or type>=ERA/logitem) and (class>='recensio:base/resource/media' or type>=ERA/logitem)";
			}
			trace("looking at room", (eraRoomArray[roomCounter] as Model_ERARoom).base_asset_id);
			connection.sendRequest(baseXML, gotEvidenceCount);
		}
		private function gotEvidenceCount(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting all rooms", e)) == null) {
				callback(false, null);
				return;
			}
			trace("RAAARRRRRRRRRR", data);
			// Update the era room here
			trace("count is", data.reply.result.total);
			(eraRoomArray[roomCounter] as Model_ERARoom).evidenceCount = data.reply.result.total;
			
			roomCounter++;
			trace("room counter is", roomCounter, eraRoomArray.length);
			
			if(roomCounter >= eraRoomArray.length) {
				callback(true, eraRoomArray);
			} else {
				getEvidenceCount();
			}
		}
	}
}