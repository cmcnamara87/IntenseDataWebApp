package View.components.Notification
{
	import Controller.Dispatcher;
	import Controller.IDEvent;
	
	import Model.Model_Notification;
	
	import View.components.GoodBorderContainer;
	import View.components.IDGUI;
	
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import mx.controls.Text;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;
	
	public class NotificationPanel extends GoodBorderContainer
	{
		private var content:VGroup;
		
		public function NotificationPanel()
		{
			super(0xEEEEEE, 1, 0x999999, 1);
			
			this.width = 300;
			this.maxHeight = 600;
				
//			this.borderStroke = new SolidColorStroke(0x999999);
//			this.backgroundFill = new SolidColor(0xEEEEEE);
			
			// Apply the drop shadow filter to the box.
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.alpha = 0.2;
			shadow.distance = 2;
			shadow.angle = 25;
			this.filters = [shadow];

			content = new VGroup();
			content.gap = 0;
			content.percentWidth = 100;;
			
			var myScroller:Scroller = new Scroller();
			
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
			myScroller.viewport = content;
			this.addElement(myScroller);
		}
		
		public function addNotifications(notificationArray:Array):void {
			content.removeAllElements();
			
			// Check if we have any notifications
			if(notificationArray.length == 0) {
				var notification:Text = new Text();
				notification.text = "You have no notifications";
				content.addElement(notification);
				return;
			}
			
			for each(var notificationData:Model_Notification in notificationArray) {
				trace("Adding notification");
				var newNotification:Text = new Text();
				
				switch(notificationData.type) {
//					case Model_Notification.ANNOTATION_ON_MEDIA:
//						
//						break;
//					case Model_Notification.COLLECTION_SHARED:
//						break;
//					case Model_Notification.COMMENT:
//						break;
//					case Model_Notification.COMMENT_ON_COLLECTION:
//						break;
//					case Model_Notification.COMMENT_ON_MEDIA:
//						break;
					case Model_Notification.MEDIA_ADDED_TO_COLLECTION:
						var notificationBox:GoodBorderContainer = new GoodBorderContainer(0xDDDDDD, 1, 0xCCCCCC, 1);
						var layout:HorizontalLayout = new HorizontalLayout();
						var padding:Number = 10;
						layout.paddingTop = padding;
						layout.paddingRight = padding;
						layout.paddingBottom = padding;
						layout.paddingLeft = padding;
						notificationBox.layout = layout;
						
						notificationBox.percentWidth = 100;
						content.addElement(notificationBox);
						
						newNotification.htmlText = "<font color='#333333'>" + notificationData.base_creator_username + " added </font><font color='#1122CC'><a href='#view/"+notificationData.notificationOf+"'>" + notificationData.notificationOfContent + "</a></font><font color='#333333'> to </font><font color='#1122CC'><a href='#'>" + notificationData.notificationOnTitle + "</a></font>";
						newNotification.percentWidth = 100;
						notificationBox.addElement(newNotification);
						break;
//					case Model_Notification.MEDIA_REMOVED_FROM_COLLECTION:
//						break;
//					case Model_Notification.MEDIA_SHARED:
//						break;
//					case Model_Notification.SHARING:
//						break;
//					case Model_Notification.USER_LEFT_COLLECTION:
//						break;
//					case Model_Notification.USER_LEFT_MEDIA:
//						break;
//					default:
						var test:Text = new Text();
						test.text = notificationData.base_asset_id + " " + notificationData.notificationOf + " " + notificationData.notificationOn + " " + notificationData.type + " aefasdf " + notificationData.notificationOnTitle + " " + notificationData.notificationOfContent;
						content.addElement(test);
//						break;
				}
			}
			trace("COUNT IS", content.numElements);
		}
	}
}