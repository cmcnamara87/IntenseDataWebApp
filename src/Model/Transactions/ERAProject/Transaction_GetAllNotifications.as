package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
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
		private var readStatus:String;
		
		private var eraNotificationArray:Array;
		private var notificationNumber:Number = 0;
		private var processedNotificationArray:Array = new Array();

		private var notificationDataBeingProcessed:Model_ERANotification;
		
		public function Transaction_GetAllNotifications(readStatus:String, connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			this.roomID = roomID;
			this.readStatus = readStatus;
			getAllNotifications();
		}
		
		private function getAllNotifications():void {
			// asset.query :where asset in collection <id>
			
			// asset.query :where type>=ERA/notification and not(ERA-notification/read_by_users/username contains-all 'p.hempenstall')
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			trace("read status", this.readStatus);
			
			if(this.readStatus == Model_ERANotification.SHOW_ALL) {
				argsXML.where = "type=ERA/notification";	
			} else if (this.readStatus == Model_ERANotification.SHOW_READ) {
				argsXML.where = "type>=ERA/notification and ERA-notification/read_by_users/username contains-all '" + Auth.getInstance().getUsername() + "'";	
			} else if (this.readStatus == Model_ERANotification.SHOW_UNREAD) {
				trace("Should be showing un read notifications");
				argsXML.where = "type>=ERA/notification and not(ERA-notification/read_by_users/username contains-all '" + Auth.getInstance().getUsername() + "')";
			}
			
			argsXML.action = "get-meta";
			argsXML["get-related-meta"] = true;
			argsXML.size = "infinity";
			
			trace("GETTING ALL NOTIFICATIONS REQUEST", argsXML);
			
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