package View.components.Notification
{
	import Controller.Dispatcher;
	
	import Model.Model_Notification;
	
	import View.components.IDGUI;
	
	import flash.events.MouseEvent;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class Notification extends VGroup
	{
		private var notificationOn:Number;
		public function Notification(username:String, notificationType:String, notificationOn:Number, notificationOnTitle:String, 
									 notificationOf:Number, notificationOfTitle:String) {
			super();
		}
	}
}