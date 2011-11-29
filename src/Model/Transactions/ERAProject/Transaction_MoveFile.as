package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Model_ERARoom;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_MoveFile
	{
		private var fileID:Number;
		private var fromRoomID:Number;
		private var toRoomID:Number;
		private var connection:Connection;
		private var callback:Function;
		private var toRoomType:String;
		
		public function Transaction_MoveFile(fileID:Number, fromRoomID:Number, toRoomID:Number, toRoomType:String, connection:Connection, callback:Function)
		{
			this.fileID = fileID;
			this.fromRoomID = fromRoomID;
			this.toRoomID = toRoomID;
			this.toRoomType = toRoomType;
			this.connection = connection;
			this.callback = callback;
			
			moveFile();
		}
		
		private function moveFile():void {
			// remove to relationship
			var baseXML:XML = connection.packageRequest("asset.relationship.remove", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = fileID;
			argsXML.to = fromRoomID;
			argsXML.to.@relationship = "room";
			argsXML.comment = "Changed to room " + toRoomID + " from room " + fromRoomID;

			connection.sendRequest(baseXML, fileRemovedFromRoom);			
		}
		
		private function fileRemovedFromRoom(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("removed file from room", e)) == null) {
				callback(false);
				return;
			}

			var baseXML:XML = connection.packageRequest("asset.relationship.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = fileID;
			argsXML.to = toRoomID;
			argsXML.to.@relationship = "room";
			
			connection.sendRequest(baseXML, fileAddedToRoom);
		}
		
		private function fileAddedToRoom(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("added file to room", e)) == null) {
				callback(false);
				return;
			}
			
			sendNotification();
			
			callback(true);
		}
		
		private function sendNotification():void {
			// only send the ontification, if we are moving the file to the screening lab

			if(toRoomType == Model_ERARoom.SCREENING_ROOM) {
				AppModel.getInstance().createERANotification(AppController.currentEraProject.year, toRoomID, Auth.getInstance().getUsername(),
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
					Model_ERANotification.FILE_MOVED_TO_REVIEW_LAB, 0, fileID, 0);
			} else if(toRoomType == Model_ERARoom.EXHIBIT) {
				AppModel.getInstance().createERANotification(AppController.currentEraProject.year, toRoomID, Auth.getInstance().getUsername(),
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
					Model_ERANotification.FILE_MOVED_TO_EXHIBITION, 0, fileID, 0);
			} else if(toRoomType == Model_ERARoom.FORENSIC_LAB) {
				AppModel.getInstance().createERANotification(AppController.currentEraProject.year, toRoomID, Auth.getInstance().getUsername(),
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
					Model_ERANotification.FILE_MOVED_TO_FORENSIC_LAB, 0, fileID, 0);
			}
		}
	}
}