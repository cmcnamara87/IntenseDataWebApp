package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Model_ERARoom;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_UpdateMoveCount
	{
		private var fileID:Number;
		private var roomType:String;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_UpdateMoveCount(fileID:Number, roomType:String, connection:Connection)
		{
			this.fileID = fileID;
			this.roomType = roomType;
			this.connection = connection;
			this.callback = callback;
			
			// Get teh current file
			AppModel.getInstance().getERAFile(fileID, gotFile);
		}
		
		private function gotFile(status:Boolean, fileModel:Model_ERAFile):void { 
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			trace("&&&&& UPDATING FILE MOVE COUNT", fileID);
			// Setup the era meta-data
			argsXML.id = fileModel.base_asset_id;
			if(roomType == Model_ERARoom.EXHIBIT) {
				trace("&&&&& EXHIBIT",  fileModel.exhibitionCount, fileModel.exhibitionCount + 1);
				argsXML.meta["ERA-evidence"]["exhibition_count"] = fileModel.exhibitionCount + 1;
			} else if (roomType == Model_ERARoom.SCREENING_ROOM) {
				trace("&&&&& REVIEW", fileModel.screeningCount, fileModel.screeningCount + 1);
				argsXML.meta["ERA-evidence"]["review_count"] = fileModel.screeningCount + 1;
			}
			
			connection.sendRequest(baseXML, fileMoveCountUpdated);		
		}
		
		private function fileMoveCountUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("file move coutn changed", e)) == null) {
				//callback(false);
				return;
			} else {
//				callback(true);
				return;
			}
		}
	}
}