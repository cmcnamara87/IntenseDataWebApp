package Controller
{
	import View.EraCreatorView;
	import View.UserAdminView;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.Text;
	
	import spark.components.Label;

	public class AdminController extends AppController
	{
		public function AdminController()
		{
			view = new UserAdminView();
			super();
		}
		
		override public function init():void {
			setupEventListeners();	
		}
		
		private function setupEventListeners():void {
			layout.header.dashboardButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				Alert.show("Coming Soon");
			});
			
			layout.header.eraAdminButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				Alert.show("era admin button clicked");
			});
			
			layout.header.caseCreatorButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				Alert.show("case creator button clicked");
			});
			layout.header.reportButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				Alert.show("No Reports are currently available");
			});
		}
	}
}