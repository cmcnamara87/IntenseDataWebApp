package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_UpdateFileTemperature
	{
		private var fileID:Number;
		private var hot:Boolean;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_UpdateFileTemperature(fileID:Number, hot:Boolean, connection:Connection, callback:Function)
		{
			this.fileID = fileID;
			this.hot = hot;
			this.connection = connection;
			this.callback = callback;
			
			updateFileTemperature();
		}
		
		private function updateFileTemperature():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = fileID;
			argsXML.meta["ERA-evidence"]["hot"] = hot;
			
			connection.sendRequest(baseXML, fileTemperatureUpdated);		
		}
		
		private function fileTemperatureUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating file temperature", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
			}
		}
	}
}