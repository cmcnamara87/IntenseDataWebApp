package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_DeleteRelatedNotifications
	{
		private var objectID:Number;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_DeleteRelatedNotifications(objectID:Number, callback:Function, connection:Connection)
		{
			this.objectID = objectID;
			this.connection = connection;
			this.callback = callback;
			
			deleteRelatedNotifications();
		}
		
		private function deleteRelatedNotifications():void {
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// delete any of the related notifications
			argsXML.where = "related to (id=" + objectID + ") and type>=ERA/notification";
			argsXML.action = "pipe";
			argsXML.service.@name = "asset.destroy";
				
			connection.sendRequest(baseXML, notificationsDeleted);
		}
		
		private function notificationsDeleted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("deleting related notifications", e)) == null) {
				if(callback) {
					callback(false);
				}
			} else {
				if(callback) {
					callback(true);
				}
			}
		}
	}
}