package Controller.ERA
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERAFile;
	
	import View.ERA.FileView2;
	
	public class FileController2 extends AppController
	{
		public function FileController2()
		{
			view = new FileView2();
			super();
		}
		
		//Protection to ensure controllers take advantage of the init method
		override public function init():void {
			trace('running init');
			
			// Get the 
			AppModel.getInstance().getERAFile(4288, gotFile);
		}
		
		private function gotFile(status:Boolean, eraFile:Model_ERAFile) {
			(view as FileView2).videoPlayer.source = eraFile.getMediaURL();
		}
	}
}