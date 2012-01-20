package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_DownloadExhibitionFiles
	{
		private var connection:Connection;
		private var callback:Function;
		private var caseID:Number;
		private var downloaderUsername:String
		
		public function Transaction_DownloadExhibitionFiles(caseID:Number, downloaderUsername:String, connection:Connection, callback:Function)
		{
			this.caseID = caseID;
			this.downloaderUsername = downloaderUsername;
			this.callback = callback;
			this.connection = connection;
			
			AppModel.getInstance().getAllERAFilesInRoom(caseID, gotFiles);
		}
		
		private function gotFiles(status:Boolean, fileArray:Array = null) {
			// package up files now
			filesPackaged();
		}
		
		private function filesPackaged():void {
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
			} else {
				callback(true);
			}
		}
	}
}