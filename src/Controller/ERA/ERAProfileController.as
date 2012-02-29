package Controller.ERA
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	
	import View.ERA.ERAProfileView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.RadioButtonGroup;
	
	import spark.components.Label;
	
	public class ERAProfileController extends AppController
	{
		private var profileView:ERAProfileView;
		private var notificationsArray:Array = new Array();
		private var currentOffset = 0;
		
		public function ERAProfileController()
		{
			profileView = new ERAProfileView;
			view = profileView;
			super();
		}
		
		//Protection to ensure controllers take advantage of the init method
		override public function init():void {
			layout.header.adminToolButtons.visible = false;
			layout.header.adminToolButtons.includeInLayout = false;
			layout.header.productionToolsButton.setStyle('chromeColor', '0x222222');
			layout.header.profileButton.setStyle("chromeColor", '0x000000');
			
			// Get All the notifications ready for display
			AppModel.getInstance().getAllNotifications(Model_ERANotification.SHOW_OTHERS, gotAllNotifications);
			
			setupEventListeners();
		}

		private function setupEventListeners():void {
			profileView.changePassword.addEventListener(MouseEvent.CLICK, changePassword);
			profileView.loadMore.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
				profileView.loadingText.visible = true;
				profileView.loadingText.includeInLayout = true;
				sendNotificationsToView(currentOffset, 20);
//				AppModel.getInstance().getAllNotifications(Model_ERANotification.SHOW_ALL, gotAllNotifications);
			});
			
			profileView.showAll.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				trace(">>>> NOTIFICATION RADIO BUTTON CHANGED");
				profileView.notificationList.removeAllElements();
				profileView.loadingText.visible = true;
				profileView.loadingText.includeInLayout = true;
				profileView.loadMore.visible = false;
				currentOffset = 0;
				
				AppModel.getInstance().getAllNotifications(Model_ERANotification.SHOW_ALL, gotAllNotifications);
			});
			
			profileView.showOthers.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				trace(">>>> NOTIFICATION RADIO BUTTON CHANGED");
				profileView.notificationList.removeAllElements();
				profileView.loadingText.visible = true;
				profileView.loadingText.includeInLayout = true;
				profileView.loadMore.visible = false;
				currentOffset = 0;
				
				var group:RadioButtonGroup = e.currentTarget as RadioButtonGroup;
				AppModel.getInstance().getAllNotifications(Model_ERANotification.SHOW_OTHERS, gotAllNotifications);
			});
		}
		private function changePassword(e:MouseEvent):void {
			var newPassword:String = profileView.newPassword.text;
			if(newPassword == "") {
				layout.notificationBar.showError("Please enter a password");
				return;
			}
			
			AppModel.getInstance().changeERAUserPassword(newPassword, passwordChanged);
		}
		private function passwordChanged(status:Boolean):void {
			if(!status) {
				layout.notificationBar.showError("Failed to change password. Please make sure your new password is 6 characters or more.");
				return;
			} else {
				layout.notificationBar.showGood("Password Changed");
				return;
			}
			
		}
		
		private function gotAllNotifications(status:Boolean, notificationArray:Array) {
			this.notificationsArray = notificationArray;
			trace("PROFILE GOT NOTIFICATIONS", notificationArray.length);
			notificationArray.reverse();
			sendNotificationsToView(0, 10);
		}
		
		private function sendNotificationsToView(offset:Number, count:Number) {
			var slicedArray = notificationsArray.slice(offset, offset + count);
			currentOffset = offset + count;
			profileView.addNotifications(slicedArray);
		}
		
			
	}
}