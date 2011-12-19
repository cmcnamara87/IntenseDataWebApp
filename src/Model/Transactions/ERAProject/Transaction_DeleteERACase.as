package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_DeleteERACase
	{
		private var caseID:Number;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_DeleteERACase(caseID:Number, connection:Connection, callback:Function)
		{
			this.caseID = caseID;
			this.connection = connection;
			this.callback = callback;
		
			// Delete all files in the case
			deleteFiles();
		}
		
		private function deleteFiles():void {
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "related to{room} (related to{case} (id=" + caseID + "))";
			argsXML.action = "pipe";
			argsXML.service.@name = "asset.destroy";
			
			connection.sendRequest(baseXML, contentsDeleted);
		}
		
		private function contentsDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era case", e)) == null) {
				callback(false);
				return;
			} 
			trace("case contents deleted");
			deleteNotifications();
		}
		
		private function deleteNotifications():void {
			AppModel.getInstance().deleteRelatedERANotifications(caseID, deleteERACase);
		}
		
		private function deleteERACase(status:Boolean):void {
			if(!status) trace("Failed to delete notifications for", caseID);
			
			var baseXML:XML = connection.packageRequest("asset.destroy", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = caseID;
			argsXML.atomic = true;
			
			connection.sendRequest(baseXML, caseDeleted);
		}
		
		private function caseDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting era case", e)) == null) {
				callback(false);
			} else {
				callback(true, caseID);
			}
		}
	}
	
}