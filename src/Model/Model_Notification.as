package Model {
	
	public class Model_Notification extends Model_Base {
		
		public var username:String; // The user who created the annotation.
		public var message:String; // The message attached to the notification (e.g. 'added a comment')
		public var created_on:String; // The date string for when this was added
		public var controller:String; // The controller it relates to (e.g. 'view' or 'browse')
		public var notification_on:Number; // The ID of the asset this is a notification on (e.g. a picture, or a collection etc)
		public var notification_on_title:String = "FAIL"; 
		public var notification_of:Number; // THe ID of the asset this is a notificaoitn of (e.g. the comments ID)
		public var notification_of_content:String = "FAIL";
		
		public function Model_Notification() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {			
			this.username = rawData.meta.id_notification.username;
			this.message = rawData.meta.id_notification.message;
			this.created_on = rawData.meta.id_notification.created_on;
			this.controller = rawData.meta.id_notification.controller;
			this.notification_on = rawData.related.(@type=="notification_on").asset.@id;
			this.notification_on_title = rawData.related.(@type=="notification_on").asset.meta.r_resource.title;
			
			this.notification_of = rawData.related.(@type=="notification_of").asset.@id;
			this.notification_of_content = rawData.related.(@type=="notification_of").asset.meta.r_annotation.text;
		}
	}
}