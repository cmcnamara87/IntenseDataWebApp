package Controller.ERA
{
	import Controller.AppController;
	
	import View.PasswordRecover;
	
	public class RecoverController extends AppController
	{
		public function RecoverController()
		{
			view = new PasswordRecover();
			super();
		}
		
		//Protection to ensure controllers take advantage of the init method
		override public function init():void {
			
		}
	}
}