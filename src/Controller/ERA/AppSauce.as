package Controller.ERA
{
	import Controller.AppController;
	
	import Model.AppModel;
	
	import View.ERA.ERAProfileView;
	
	import flash.events.MouseEvent;
	
	import spark.components.Label;
	
	public class AppSauce extends AppController
	{
		private var profileView:ERAProfileView;
		public function AppSauce()
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
			
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			profileView.changePassword.addEventListener(MouseEvent.CLICK, changePassword);	
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
				layout.notificationBar.showError("Failed to change password");
				return;
			} else {
				layout.notificationBar.showGood("Password Changed");
				return;
			}
			
		}
			
	}
}