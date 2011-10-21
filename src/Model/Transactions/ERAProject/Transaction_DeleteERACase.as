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
			
			deleteERACase();
		}
		
		private function deleteERACase():void {
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
				
				// Delet all notifications associated with this case
				var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
				var argsXML:XMLList = baseXML.service.args;
				
				argsXML.where = "type>=ERA/notification and related to{notification_case} (id=" + caseID + ")";
				argsXML.action = "pipe";
				argsXML.service.@name = "asset.destroy";
				
				connection.sendRequest(baseXML, notificationsDeleted);
			}
		}
		
		private function notificationsDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting case notifications", e)) == null) {
				callback(false);
				return;
			}
			
			callback(true, caseID);
		}
	}
	
}