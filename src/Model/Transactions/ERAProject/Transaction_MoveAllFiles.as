package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Model_ERARoom;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_MoveAllFiles
	{
		private var fileIDArray:Array;
		private var fromRoomID:Number;
		private var toRoomID:Number;
		private var connection:Connection;
		private var callback:Function;
		private var toRoomType:String;
		private var fileMovedCount:Number = 0;
		
		public function Transaction_MoveAllFiles(fileIDArray:Array, fromRoomID:Number, toRoomID:Number, toRoomType:String, connection:Connection, callback:Function)
		{
			this.fileIDArray = fileIDArray;
			this.fromRoomID = fromRoomID;
			this.toRoomID = toRoomID;
			this.toRoomType = toRoomType;
			this.connection = connection;
			this.callback = callback;
			
			moveFile();
		}
		
		private function moveFile():void {
			
			if(fileMovedCount == fileIDArray.length) {
				// Success
				
				// Determine the type of notification to send
				var notificationType:String = "";
				if(toRoomType == Model_ERARoom.SCREENING_ROOM) {
					notificationType = Model_ERANotification.ALL_FILES_MOVED_TO_SCREENING_LAB;
				} else if (toRoomType = Model_ERARoom.EXHIBIT) {
					notificationType = Model_ERANotification.ALL_FILES_MOVED_TO_EXHIBITION;
				}
				if(notificationType != "") {
					// Send the notification (provided it all worked out)
					AppModel.getInstance().createERANotification(AppController.currentEraProject.year, toRoomID, Auth.getInstance().getUsername(),
						Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
						notificationType, 0, 0, 0);	
				}
				
				// Let it be known its done :D
				callback(true);
								
				return;
			}

			AppModel.getInstance().moveERAFile(fileIDArray[fileMovedCount], fromRoomID, toRoomID, toRoomType, fileMoved, false);			
		}
		
		private function fileMoved(status:Boolean):void {
			if(!status) {
				callback(false);
				return;
			}
			
			fileMovedCount++;
			moveFile();
		}
	}
}