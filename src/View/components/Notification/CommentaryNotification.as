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
	
	public class CommentaryNotification extends Notification
	{
		private var mediaID:Number = 0; // The ID of the media or collection the comment is on.
		private var type:String; // Either collection or media
		
		public function CommentaryNotification(notificationID:Number, username:String, type:String, assetName:String, assetID:Number, comment:String) {
			super(notificationID);

//			this.maxHeight = 400;
			
			var details:HGroup = new HGroup();
//			details.width = 200;
			content.addElement(details);
			
			var usernameLabel:Label = new Label();
			usernameLabel.setStyle('fontWeight', 'bold');
			usernameLabel.setStyle('color', 0x555555);
			usernameLabel.text = username;
			details.addElement(usernameLabel);
			
			var messageLabel:Label = new Label();
			messageLabel.setStyle('color', 0x555555);
			if(type == Model_Notification.COMMENT_ON_MEDIA || type == Model_Notification.COMMENT_ON_COLLECTION) {
				messageLabel.text = "commented on";
			} else {
				messageLabel.text = "annotated on";
			}
			details.addElement(messageLabel);
			
			var mediaNameLabel:Label = new Label();
			mediaNameLabel.setStyle('color', 0x336699);
			mediaNameLabel.setStyle('fontWeight', 'bold');
			mediaNameLabel.text = assetName;
			details.addElement(mediaNameLabel);
			
			mediaNameLabel.useHandCursor = true;
			mediaNameLabel.buttonMode = true;
			
			mediaNameLabel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				if(type == Model_Notification.COMMENT_ON_MEDIA || type == Model_Notification.ANNOTATION_ON_MEDIA) {
					trace("Going to media", assetID);
					Dispatcher.call('view/' + assetID);
				} else {
					trace("Going to collection", assetID);
					CollaborationController.setCurrentCollectionID(assetID);
					Dispatcher.call('browse');
				}
			});
			
			if(comment != "") {
				var commentLabel:Label = new Label();
				commentLabel.text = "\"" + comment + "\"";
				commentLabel.setStyle('fontStyle', 'italic');
				commentLabel.setStyle('color', 0x555555);
				content.addElement(commentLabel);
			}
			
		}
	}
}