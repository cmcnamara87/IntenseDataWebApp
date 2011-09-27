package Controller.Admin
{
	import spark.components.Label;
	import Controller.AppController;

	public class DashboardController extends AppController
	{
		public function DashboardController()
		{
			// @todo 
			var label:Label = new Label();
			label.text = "dashboard controller";
			view = label;
			super();
		}
		
		override public function init():void {
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			
		}
	}
}