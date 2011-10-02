package Controller.ERA.Admin
{
	import Controller.AppController;
	
	import View.ERA.DashboardView;
	
	import spark.components.Label;

	public class DashboardController extends AppController
	{
		public function DashboardController()
		{
			// @todo 
			view = new DashboardView();
			super();
		}
		
		override public function init():void {
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			
		}
	}
}