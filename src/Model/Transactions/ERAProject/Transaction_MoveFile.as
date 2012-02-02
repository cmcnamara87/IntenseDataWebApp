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
		private var notifications:Boolean; // true if we should send notifications
		
		/**
		 * Moves a file from one Room to another.  
		 * @param fileID			The ID of the file to move
		 * @param fromRoomID		The ID room to move it from
		 * @param toRoomID			The ID of the room to move it to
		 * @param toRoomType		The type of the room to move it to
		 * @param notifications		True/False if you should send a notification about the move
		 * @param connection		The connection to mediaflux
		 * @param callback			The function to call on completion
		 * 
		 */		
		public function Transaction_MoveFile(fileID:Number, fromRoomID:Number, toRoomID:Number, toRoomType:String, notifications:Boolean, connection:Connection, callback:Function)
		{
			this.fileID = fileID;
			this.fromRoomID = fromRoomID;
			this.toRoomID = toRoomID;
			this.toRoomType = toRoomType;
			this.connection = connection;
			this.notifications = notifications;
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
			
			// Update the move count
			// counts the number of times we have moved a file to the exhibition or review lab
			var moveCountUpdate:Transaction_UpdateMoveCount = new Transaction_UpdateMoveCount(fileID, toRoomType, connection);
			
			// If we should send a notification, go it
			if(notifications) {
				sendNotification();
			}
			
			AppModel.getInstance().updateERAFileTemperature(fileID, true, function(status:Boolean):void {
				trace("Made file hot");
			});
			
			// if we are moving from the screening to the forensic lab
			// we need to strip all the approvals
			if(toRoomType == Model_ERARoom.FORENSIC_LAB) {
				AppModel.getInstance().removeAllFileApprovals(fileID, approvalsRemoved);
			} else {
				callback(true);
			}
		}
		
		private function approvalsRemoved(status:Boolean) {
			if(!status) {
				callback(false);
				return;
			}
			
			callback(true);
		}
		
		private function sendNotification():void {

			// we only want to send notifications if we are moving it to the screening (from forensic)
			// or to the forensic, from screening
			// screening to exhibition (and reverse) are covered by the 'move all files' transaction
			if(toRoomType == Model_ERARoom.SCREENING_ROOM) {
				trace("creating screen room notification");
				AppModel.getInstance().createERANotification(AppController.currentEraProject.year, toRoomID, Auth.getInstance().getUsername(),
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
					Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB, 0, fileID, 0);
			} else if(toRoomType == Model_ERARoom.FORENSIC_LAB) {
				trace("creating forensic lab notification");
				AppModel.getInstance().createERANotification(AppController.currentEraProject.year, toRoomID, Auth.getInstance().getUsername(),
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
					Model_ERANotification.FILE_MOVED_TO_FORENSIC_LAB, 0, fileID, 0);
			}
			/*
			} else if(toRoomType == Model_ERARoom.EXHIBIT) {
				trace("creating exhibition notification");
				AppModel.getInstance().createERANotification(AppController.currentEraProject.year, toRoomID, Auth.getInstance().getUsername(),
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
					Model_ERANotification.FILE_MOVED_TO_EXHIBITION, 0, fileID, 0);
			*/
			
		}
	}
}