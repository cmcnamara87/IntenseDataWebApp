package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Utilities.Connection;

	public class Transaction_UpdateAllNotificationsAsRead
	{
		private var notificationModelArray:Array;
		private var connection:Connection;
		private var callback:Function;
		
		private var updateCounter:Number = 0;
		
		public function Transaction_UpdateAllNotificationsAsRead(notificationModelArray:Array, connection:Connection, callback:Function)
		{
			this.notificationModelArray = notificationModelArray;
			this.connection = connection;
			this.callback = callback;
			
			updateAll();
		}
		
		private function updateAll() {
			if(updateCounter == notificationModelArray.length) {
				// we have updated them all
				callback(true);
				return;
			}

			var currentNotification:Model_ERANotification = this.notificationModelArray[updateCounter];
			
			// check if the notification is already read
			if(currentNotification.read == true) {
				updateCounter++;
				updateAll();
				return;
			}
			
			AppModel.getInstance().updateNotificationReadStatus(currentNotification.base_asset_id, true, updated);
		}
		private function updated(status:Boolean) {
			if(!status) {
				callback(false);
				return;
			}
			
			updateCounter++;
			updateAll();
			return;
		}
	}
}