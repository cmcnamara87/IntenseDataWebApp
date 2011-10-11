package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetFile
	{
		private var fileID:Number;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_GetFile(fileID:Number, connection:Connection, callback:Function)
		{
			this.fileID = fileID;
			this.connection = connection;
			this.callback = callback;
			
			getFile();
		}
		
		private function getFile():void {
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = fileID;
			
			connection.sendRequest(baseXML, fileDataReceived);
		}
		
		private function fileDataReceived(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting file", e)) == null) {
				callback(false, null);
			}
			
			var file:Model_ERAFile = new Model_ERAFile();
			file.setData(data.reply.result.asset[0]);
			
			callback(true, file);
		}
	}
}