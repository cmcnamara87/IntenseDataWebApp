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
			this.minHeight = 200;
			this.maxHeight = 600;
				
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
				// We have some notifications, add them to the display
				for(var i:Number = 0; i < notificationArray.length; i++) {
					var notificationData:Model_Notification = notificationArray[i];
					if(notificationData.type == Model_Notification.COMMENT_ON_MEDIA ||
						notificationData.type == Model_Notification.ANNOTATION_ON_MEDIA ||
						notificationData.type == Model_Notification.COMMENT_ON_COLLECTION) {
						var commentaryNotification:CommentaryNotification = new CommentaryNotification(
							notificationData.username,
							notificationData.type,
							notificationData.notificationOnTitle,
							notificationData.notificationOn,
							notificationData.notificationOfContent
						);
						content.addElement(commentaryNotification);
					} else {
						trace("got a weird notification type", notificationData.type);
					} 

					if(i + 1 != notificationArray.length) {
						var line:Line = IDGUI.makeHorizontalLine();
						content.addElement(line);
					}
				}
			} else {
				// There are no notifications
				var label:Label = new Label();
				label.text = "You have no notifications";
				content.addElement(label);
			}
		}
	}
}