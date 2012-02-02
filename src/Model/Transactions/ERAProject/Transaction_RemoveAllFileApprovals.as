package Model.Transactions.ERAProject
{
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_RemoveAllFileApprovals
	{
		private var fileID:Number;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_RemoveAllFileApprovals(fileID:Number, connection:Connection, callback:Function)
		{
			this.fileID = fileID;
			this.connection = connection;
			this.callback = callback;
			
			getFile();
		}
		
		private function getFile():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = fileID;
			
			connection.sendRequest(baseXML, gotFile);
		}
		
		/**
		 * Got the file. Now lets try and remove the approval
		 * @param e
		 * 
		 */		
		private function gotFile(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("got the file", e)) == null) {
				callback(false);
				return;
			} 
			
			// Get out the ERA file meta-data
			var eraFileXML:XML = data.reply.result.asset[0];
			
			// Remove all the approval
			delete eraFileXML.meta["ERA-evidence"].exhibition_approval;
			
			// Create a new doc for submission
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = fileID;
			argsXML.meta = "";
			argsXML.meta.appendChild(eraFileXML.meta["ERA-evidence"]);
			argsXML.meta.@action = "replace";
			
			connection.sendRequest(baseXML, approvalsRemoved);
		}
		
		private function approvalsRemoved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("approvals removed", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
				return;
			}
		}
	}
}