package Controller.ERA
{
	import Controller.AppController;
	
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
		}
	}
}