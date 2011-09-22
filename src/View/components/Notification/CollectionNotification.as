package View.components.Notification
{
	import Controller.BrowserController;
	import Controller.CollaborationController;
	import Controller.Dispatcher;
	
	import Model.Model_Notification;
	
	import View.components.IDGUI;
	
	import flash.events.MouseEvent;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class CollectionNotification extends Notification
	{
		private var mediaID:Number = 0; // The ID of the media or collection the comment is on.
		private var type:String; // Either collection or media
		
		public function CollectionNotification(notificationID:Number, username:String, type:String, collectionID:Number, collectionName:String, mediaID:Number, mediaName:String) { 
//			super(notificationID);
//			
//			var details:HGroup = new HGroup();
//			details.width = 200;
//			content.addElement(details);
//			
//			var usernameLabel:Label = new Label();
//			usernameLabel.setStyle('fontWeight', 'bold');
//			usernameLabel.setStyle('color', 0x555555);
//			usernameLabel.text = username;
//			details.addElement(usernameLabel);
//		
//			var messageLabel:Label = new Label();
//			messageLabel.setStyle('color', 0x555555);
//			if(type == Model_Notification.MEDIA_ADDED_TO_COLLECTION) {
//				messageLabel.text = "added";
//			} else if (type == Model_Notification.MEDIA_REMOVED_FROM_COLLECTION) {
//				messageLabel.text = "removed";
//			}
//			details.addElement(messageLabel);
//			
//			var mediaNameLabel:Label = new Label();
//			mediaNameLabel.setStyle('color', 0x336699);
//			mediaNameLabel.setStyle('fontWeight', 'bold');
//			mediaNameLabel.text = mediaName;
//			details.addElement(mediaNameLabel);
//			
//			mediaNameLabel.useHandCursor = true;
//			mediaNameLabel.buttonMode = true;
//			
//			mediaNameLabel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
//				trace("Going to media", mediaID);
//				Dispatcher.call('view/' + mediaID);
//			});
//			
//			var details2:HGroup = new HGroup();
//			details2.width = 200;
//			content.addElement(details2);
//			
//			var messageLabel2:Label = new Label();
//			messageLabel2.setStyle('color', 0x555555);
//			if(type == Model_Notification.MEDIA_ADDED_TO_COLLECTION) {
//				messageLabel2.text = "to";
//			} else if (type == Model_Notification.MEDIA_REMOVED_FROM_COLLECTION) {
//				messageLabel2.text = "from";
//			}
//			details2.addElement(messageLabel2);
//			
//			var collectionNameLabel:Label = new Label();
//			collectionNameLabel.text = collectionName;
//			collectionNameLabel.setStyle('color', 0x336699);
//			collectionNameLabel.setStyle('fontWeight', 'bold');
//			details2.addElement(collectionNameLabel);
//			
//			collectionNameLabel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
//				trace("Going to collection", collectionID);
//				CollaborationController.setCurrentCollectionID(collectionID);
//				Dispatcher.call('browse');
//			});
//			
//			collectionNameLabel.useHandCursor = true;
//			collectionNameLabel.buttonMode = true;
			
		}
	}
}