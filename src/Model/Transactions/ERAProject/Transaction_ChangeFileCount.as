package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_ChangeFileCount
	{
		private var caseID:Number;
		private var fileCount:Number;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_ChangeFileCount(caseID:Number, fileCount:Number, connection:Connection, callback:Function) {
			this.caseID = caseID;
			this.fileCount = fileCount;
			this.connection = connection;
			this.callback = callback;
			
			updateCheckoutStatus();
		}
		
		private function updateCheckoutStatus():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = caseID;
			argsXML.meta["ERA-case"]["file_count"] = this.fileCount;
			
			connection.sendRequest(baseXML, fileCountChanged);		
		}
		
		private function fileCountChanged(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("file count changed", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
			}
		}
	}
}