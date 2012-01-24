package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_UpdatePackageNames
	{
		private var caseID:Number;
		private var connection:Connection;
		private var callback:Function;
		private var filesArray:Array;
		private var folderName:String;
		
		private var fileCounter:Number = 0;
		
		public function Transaction_UpdatePackageNames(caseID:Number, folderName:String, filesArray:Array, connection:Connection, callback:Function)
		{
			this.callback = callback;
			this.filesArray = filesArray;
			this.caseID = caseID;
			this.folderName = folderName;
			this.connection = connection;
			
			saveCaseName();
		}
		
		private function saveCaseName():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = caseID;
			argsXML.meta["ERA-case"]["download_title"] = folderName;
			
			connection.sendRequest(baseXML, caseDownloadTitleChanged);	
		}
		
		private function caseDownloadTitleChanged(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("case name changed", e)) == null) {
				callback(false);
				return;
			}
			
			saveFilePackageNames();
		}	
		
		private function saveFilePackageNames():void {
			if(fileCounter >= filesArray.length) {
				callback(true);
				return;
			}
			var currentFile:Model_ERAFile = filesArray[fileCounter];
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = currentFile.base_asset_id;
			argsXML.meta["ERA-evidence"]["download_title"] = currentFile.downloadTitle;
			
			connection.sendRequest(baseXML, downloadTitleChanged);		
		}
		
		private function downloadTitleChanged(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("package name changed", e)) == null) {
				callback(false);
				return;
			}
			
			fileCounter++;
			saveFilePackageNames();
		}
	}
}