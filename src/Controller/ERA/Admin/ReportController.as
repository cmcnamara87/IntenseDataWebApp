package Controller.ERA.Admin
{
	import Controller.AppController;
	
	public class ReportController extends AppController
	{
		public function ReportController()
		{
			super();
		}
		
		override public function init():void {
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			
		}
		
		//When the controller is destroyed/switched
		override public function dealloc():void {
			super.dealloc();
		}
	}
}