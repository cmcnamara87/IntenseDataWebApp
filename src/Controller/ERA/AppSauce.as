package Controller.ERA
{
	import Controller.AppController;
	
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
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			profileView.changePassword.addEventListener(MouseEvent.CLICK, changePassword);	
		}
		private function changePassword(e:MouseEvent):void {
			var newPassword:String = profileView.newPassword.text;
			
		}
	}
}