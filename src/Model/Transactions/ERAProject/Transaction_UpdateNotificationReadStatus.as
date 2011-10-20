package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_UpdateNotificationReadStatus
	{
		private var notificationID:Number;
		private var readStatus:Boolean;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_UpdateNotificationReadStatus(notificationID:Number, readStatus:Boolean, connection:Connection, callback:Function)
		{
			this.notificationID = notificationID;
			this.readStatus = readStatus;
			this.connection = connection;
			this.callback = callback;
			getNotification();
		}
		
		private function getNotification():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = notificationID;
			
			connection.sendRequest(baseXML, gotNotification);
		}
		
		private function gotNotification(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting notification", e)) == null) {
				callback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = notificationID;
			argsXML.meta.@action = "merge";
			argsXML.meta["ERA-notification"] = "";
							

			
			argsXML.meta["ERA-notification"].appendChild(
				XML('<read_by_users><username>' +  Auth.getInstance().getUsername() + '</username><read_status>' + readStatus + '</read_status><date_read>now</date_read></read_by_users>')
			);
				
			var oldReadStatusList:XMLList = data.reply.result.asset.meta["ERA-notification"]["read_by_users"];

			for each(var readUser:XML in oldReadStatusList) {
				if(readUser.username != Auth.getInstance().getUsername()) { 
					argsXML.meta["ERA-notification"].appendChild(
						XML('<read_by_users><username>' +  readUser.username + '</username><read_status>'+ readUser.read_status + '</read_status><date_read>' + readUser.date_read + '</date_read></read_by_users>')
					);
				}
			}
			trace("xml", argsXML);
			connection.sendRequest(baseXML, readStatusUpdated);		
		}
		
		private function readStatusUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating notification read status", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
			}
		}
	}
}