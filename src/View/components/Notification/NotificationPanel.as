package View.components.Notification
{
	import Controller.Dispatcher;
	
	import Model.Model_Notification;
	
	import View.components.IDGUI;
	
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;
	
	public class NotificationPanel extends BorderContainer
	{
		private var content:VGroup = new VGroup();
		
		public function NotificationPanel()
		{
			super();
			
			this.width = 300;
			
			this.borderStroke = new SolidColorStroke(0x999999);
			this.backgroundFill = new SolidColor(0xEEEEEE);
			
			// Apply the drop shadow filter to the box.
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.alpha = 0.2;
			shadow.distance = 2;
			shadow.angle = 25;
			this.filters = [shadow];
			
			content.paddingTop = 10;
			content.paddingRight = 10;
			content.paddingBottom = 10;
			content.paddingLeft = 10;
			content.gap = 10;
			
			
			var myScroller:Scroller = new Scroller();
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
			myScroller.viewport = content;
			this.addElement(myScroller);
		}
		
		public function addNotifications(notificationArray:Array):void {
			content.removeAllElements();
			if(notificationArray.length > 0) {
				for(var i:Number = 0; i < notificationArray.length; i++) {
					var notificationData:Model_Notification = notificationArray[i];
					var notification:Notification = new Notification(
						notificationData.username,
						notificationData.message,
						notificationData.notification_on,
						notificationData.notification_on_title,
						notificationData.notification_of,
						notificationData.notification_of_content
					);
					content.addElement(notification);
					
					if(i + 1 != notificationArray.length) {
						var line:Line = IDGUI.makeHorizontalLine();
						content.addElement(line);
					}
				}
			} else {
				var label:Label = new Label();
				label.text = "You have no notifications";
				content.addElement(label);
			}
		}
	}
}