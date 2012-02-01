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
		private var caseID:Number;
		private var fileIDArray:Array;
		private var fromRoomID:Number;
		private var toRoomID:Number;
		private var connection:Connection;
		private var callback:Function;
		private var toRoomType:String;
		private var fileMovedCount:Number = 0;
		
		public function Transaction_MoveAllFiles(caseID:Number, fileIDArray:Array, fromRoomID:Number, toRoomID:Number, toRoomType:String, connection:Connection, callback:Function)
		{
			this.caseID = caseID;
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
				if(toRoomType == Model_ERARoom.EXHIBIT) {
					// we need to reset the downlaod status
					// as the librarian will not have downloaded this version
					// now we need to mark that its been downloaded
					var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
					var argsXML:XMLList = baseXML.service.args;
					
					// Setup the era meta-data
					argsXML.id = caseID;
					argsXML.meta["ERA-case"]["library_downloaded"] = false;
					argsXML.meta["ERA-case"]["ready_for_download"] = true;
					connection.sendRequest(baseXML, filesMarkAsNotDownloaded);
					
				} else if (toRoomType == Model_ERARoom.SCREENING_ROOM) {
					var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
					var argsXML:XMLList = baseXML.service.args;
					
					// Setup the era meta-data
					argsXML.id = caseID;
					argsXML.meta["ERA-case"]["ready_for_download"] = false;
					connection.sendRequest(baseXML, filesMarkAsNotDownloaded);
					
				} else {
					callback(true);
				}
								
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
		
		
		 private function filesMarkAsNotDownloaded(e:Event):void {
			  var data:XML;
			  if((data = AppModel.getInstance().getData("marking case as not downloaded", e)) == null) {
				  callback(false);
				  return;
			  }
			  callback(true);
		 }
													  
													  
	}
}