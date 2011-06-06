package View.components.Notification
{
	import Controller.Dispatcher;
	import Controller.IDEvent;
	
	import Model.Model_Notification;
	
	import View.components.IDButton;
	import View.components.IDGUI;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class Notification extends HGroup
	{
		protected var content:VGroup = new VGroup();
		protected var notificationID:Number;
		
		public function Notification(notificationID:Number) {
			this.notificationID = notificationID;
			super();
			
			
			var deleteNotificationButton:IDButton = new IDButton("X");
			deleteNotificationButton.width = 30;
			this.addElement(deleteNotificationButton);
			
			this.addElement(content);
			
			deleteNotificationButton.addEventListener(MouseEvent.CLICK, deleteNotificationButtonClicked);
		}
		
		private function deleteNotificationButtonClicked(e:MouseEvent):void {
			trace("Delete notification button clicked");
			// Tell the collabcontroller someone clicked the 'delete notification' button
			var event:IDEvent = new IDEvent(IDEvent.DELETE_NOTIFICATION, true);
			event.data.notificationID = notificationID;
			dispatchEvent(event);	
			
			this.visible = false;
			this.includeInLayout = false;
		}
	}
}