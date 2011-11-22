package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAConversation;
	import Model.Model_ERAFile;
	import Model.Model_ERALogItem;
	import Model.Model_ERANotification;
	import Model.Model_ERARoom;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetAllNotifications
	{
		private var connection:Connection;
		private var callback:Function;
		private var roomID:Number;
		
		private var eraNotificationArray:Array;
		private var notificationNumber:Number = 0;
		private var processedNotificationArray:Array = new Array();

		private var notificationDataBeingProcessed:Model_ERANotification;
		
		public function Transaction_GetAllNotifications(connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.roomID = roomID;
			getAllNotifications();
		}
		
		private function getAllNotifications():void {
			// asset.query :where asset in collection <id>
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.action = "get-meta";
			argsXML["get-related-meta"] = true;
			argsXML.size = "infinity";
			
			argsXML.where = "type=ERA/notification";
			
			connection.sendRequest(baseXML, gotAllNotifications);
		}
		
		private function gotAllNotifications(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting notifications", e)) == null) {
				callback(false, null);
				return;
			}
			
			this.eraNotificationArray = AppModel.getInstance().parseResults(data, Model_ERANotification);
			
			callback(true, eraNotificationArray);
		}
	}
}