package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Model_ERANotification;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_DownloadExhibitionFiles
	{
		private var connection:Connection;
		private var callback:Function;
		private var caseID:Number;
		private var downloaderUsername:String;
		private var exhibitionRoomID:Number;
		private var packageDownloadTitle:String;
		// after we make the package, we store its location
		private var packageUri:String = "";
		
		public function Transaction_DownloadExhibitionFiles(caseID:Number, packageDownloadTitle:String, exhibitionRoomID:Number, downloaderUsername:String, connection:Connection, callback:Function)
		{
			this.packageDownloadTitle = packageDownloadTitle;
			this.caseID = caseID;
			this.exhibitionRoomID =  exhibitionRoomID;
			this.downloaderUsername = downloaderUsername;
			this.callback = callback;
			this.connection = connection;
			
			AppModel.getInstance().getAllERAFilesInRoom(exhibitionRoomID, gotFiles);
		}
		
		private function gotFiles(status:Boolean, fileArray:Array = null):void {
			if(!status) {
				trace("failed to get files in room");
				callback(false);
			}
			// package up files now
			var baseXML:XML = connection.packageRequest("id.asset.package", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Put in the output zips name
			argsXML.output = packageDownloadTitle;
			
			//:id 7655 :id 7643 :output "test3"
			
			for each(var file:Model_ERAFile in fileArray) {
				trace("adding in file", file.title);
				baseXML.service.args.appendChild(XML("<id>" + file.base_asset_id + "</id>"));
			}
			
			trace("audio extraction request", baseXML);
			connection.sendRequest(baseXML, filesPackaged);
			
		}
		
		private function filesPackaged(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("package created", e)) == null) {
				callback(false);
				return;
			}
			
			trace("package created", data);
			packageUri = data.reply.result.zip;
			
			// now we need to mark that its been downloaded
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = caseID;
			argsXML.meta["ERA-case"]["library_downloaded"] = true;
			argsXML.meta["ERA-case"]["library_download_time"] = "now";
			argsXML.meta["ERA-case"]["library_download_username"] = downloaderUsername;
			
			connection.sendRequest(baseXML, filesMarkAsDownloaded);		
		}
		
		private function filesMarkAsDownloaded(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("marking files as downloaded", e)) == null) {
				callback(false);
				return;
			}
			
			// Send the downloaded notification
			// Only send the notification if the person was a librarian
			if(Auth.getInstance().hasRoleForYear(Model_ERAUser.LIBRARY_ADMIN, AppController.currentEraProject.year)) {
				AppModel.getInstance().createERANotification(AppController.currentEraProject.year, exhibitionRoomID, Auth.getInstance().getUsername(),
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
					Model_ERANotification.LIBRARIAN_PACKAGE_DOWNLOADED, caseID, 0, 0);
			}
			
			callback(true, packageUri);
			
		}
	}
}