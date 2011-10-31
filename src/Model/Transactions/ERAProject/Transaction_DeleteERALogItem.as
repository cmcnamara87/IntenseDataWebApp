package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERALogItem;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_DeleteERALogItem
	{
		private var logItem:Model_ERALogItem;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_DeleteERALogItem(logItem:Model_ERALogItem, connection:Connection, callback:Function)
		{
			this.logItem = logItem;
			this.connection = connection;
			this.callback = callback;
			
			deleteERALogItem();
		}
		private function deleteERALogItem():void {
			var baseXML:XML = connection.packageRequest("asset.destroy", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = logItem.base_asset_id;
			
			connection.sendRequest(baseXML, logItemDeleted);
		}
		
		private function logItemDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era log item", e)) == null) {
				callback(false);
				return;
			}
			
			if(!logItem.uploaded) {
				callback(true, logItem);
				return;
			}
			
			// there is an uploaded file
			// now we need to destroy all versions of the uploaded file
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "related to{originalfile} (id=" + logItem.dataItemID + ")";
			argsXML.action = "pipe";
			argsXML.service.@name = "asset.destroy";
			
			connection.sendRequest(baseXML, versionsDeleted);
		}
		
		private function versionsDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era data file from log item", e)) == null) {
				callback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("asset.destroy", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = logItem.dataItemID;
			
			connection.sendRequest(baseXML, dataFileDeleted);
		}			
		
		private function dataFileDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era data file from log item", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true, logItem);
				return;
			}
		}
	}
}