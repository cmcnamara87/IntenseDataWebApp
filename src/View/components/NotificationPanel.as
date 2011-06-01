package View.components
{
	import Controller.Dispatcher;
	
	import Model.Model_Notification;
	
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
			content.gap = 20;
			
			
			var myScroller:Scroller = new Scroller();
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
			myScroller.viewport = content;
			this.addElement(myScroller);
		}
		
		public function addNotifications(notificationArray:Array):void {
			content.removeAllElements();
			if(notificationArray.length > 0) {
				for each(var notification:Model_Notification in notificationArray) {
					var notificationLabel:Label = new Label();
					notificationLabel.percentWidth = 100;
					notificationLabel.text = notification.username + " " + notification.message + " on " + 
						notification.notification_on_title + " " + notification.notification_of_content;
					
					notificationLabel.useHandCursor = true;
					notificationLabel.buttonMode = true;
					
					notificationLabel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
						visible = false;
						Dispatcher.call('view/' + notification.notification_on);
					});
					content.addElement(notificationLabel);
				}
			} else {
				var label:Label = new Label();
				label.text = "You have no notifications";
				this.addElement(label);
			}
		}
	}
}