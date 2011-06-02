package Model {
	
	public class Model_Notification extends Model_Base {
		
		public var username:String; // The user who created the annotation.
		public var created_on:String; // The date string for when this was added
		public var notificationOn:Number; // The ID of the asset this is a notification on (e.g. a picture, or a collection etc)
		public var notificationOnTitle:String = "FAIL"; 
		public var notificationOf:Number; // THe ID of the asset this is a notificaoitn of (e.g. the comments ID)
		public var notificationOfContent:String = "FAIL";
		public var type:String;
		
		
		public static var COMMENT:String = "comment";
		public static var COMMENT_ON_MEDIA:String = "comment_on_media";
		public static var COMMENT_ON_COLLECTION:String = "comment_on_collection";
		public static var ANNOTATION_ON_MEDIA:String = "annotation_on_media";
		public static var MEDIA_SHARED:String = "media_shared";
		public static var SHARING:String = "sharing";
		public static var COLLECTION_SHARED:String = "collection_shared";
		public static var MEDIA_ADDED_TO_COLLECTION:String = "media_added_to_collection";
		public static var MEDIA_REMOVED_FROM_COLLECTION:String = "media_removed_from_collection";
		public static var USER_LEFT_MEDIA:String = "user_left_media";
		public static var USER_LEFT_COLLECTION:String = "user_left_collection";
		
		public function Model_Notification() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {			
			this.username = rawData.meta.id_notification.username;
			this.type = rawData.meta.id_notification.type;
			this.created_on = rawData.meta.id_notification.created_on;
			this.notificationOn = rawData.related.(@type=="notification_on").asset.@id;
			this.notificationOnTitle = rawData.related.(@type=="notification_on").asset.meta.r_resource.title;
			this.notificationOf = rawData.related.(@type=="notification_of").asset.@id;
			this.notificationOfContent = rawData.related.(@type=="notification_of").asset.meta.r_annotation.text;
		}
	}
}