package Model
{
	import Controller.Utilities.Auth;

	public class Model_ERANotification extends Model_Base
	{
		// comment made
		public static const FILE_COMMENT:String = "file_comment";
		// {user} wrote {comment text/id} on {file name/id} {room name/id} -> have commen text/id, have file id, have room id, need filename and room name
		
		public static const ROOM_COMMENT:String = "room_comment";
		// {user} wrote {comment text/id} in {room name/id} -> have comment text/id, and room id, need room name
		
		// annotation made
		public static const ANNOTATION:String = "annotation";
		// {user} wrote {comment text } on {file name} in {room name/id} -> have commen text/id, file id, and room id, need file name nad room name
		
		// file moved to screening lab
		public static const FILE_MOVED_TO_SCREENING_LAB:String = "file_moved_to_screening_lab";
		// {user} moved {file name/id} to {room name/id} -> have file id, room id, room name (nothing needed)
		
		public static const FILE_MOVED_TO_EXHIBITION:String = "file_moved_to_exhibition";
		// {user} moved {file name/id} to {room name/id} -> have file id, room id, room name (nothing needed)
		
		public static const FILE_MOVED_TO_FORENSIC_LAB:String = "file_moved_to_forensic_lab";
		
		// file uploaded
		public static const FILE_UPLOADED:String =  "file_uploaded";
		// {user} uploaded {file name/id} to {room name/id} -> have file id, room id, room name (nothing needed)
		
		// ready for collection
		public static const EVIDENCE_READY_FOR_COLLECTION:String = "evidence_ready_for_collection";
		// {user} marked {evidence name/id} as ready for collection in {room name/id} -> have evidence id, need evidence name, room id and room name
		
		public static const EVIDENCE_COLLECTED:String = "evidence_collected";
		// {user} marked {evidence name/id} evidence as collected in {room name/id} -> have evidence id, need evidence name, room id nad room name
		
		public var type:String;
		public var username:String;
		public var firstName:String;
		public var lastName:String;
		public var fullName:String;
		public var creationDateStamp:String;
		public var read:Boolean = false;
		
		public var eraCase:Model_ERACase = null;
		public var room:Model_ERARoom = null;
		public var file:Model_ERAFile = null;
		public var logItem:Model_ERALogItem = null;
		public var comment_room:Model_ERAConversation = null;
		public var comment_file:Model_Commentary = null;
		public var annotation_file:Model_Commentary = null;
		
		public function Model_ERANotification()
		{
			super();
		}

		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			// grab out the case info
			var eraNotification:XML = rawData.meta["ERA-notification"][0];
			
			// set the type of the item (e.g. video, image etc)
			this.type = eraNotification["type"];
			
			this.username = eraNotification["username"];
			this.firstName = eraNotification["first_name"];
			this.lastName = eraNotification["last_name"];
			this.fullName = firstName + " " + lastName;
			
			// Setup the creation time
			var currDate:Date = new Date(rawData.ctime.@millisec);
			this.creationDateStamp = (currDate.getHours() + ":" + currDate.getMinutes() + " - " + currDate.getDate() + "/" + (currDate.getMonth()+ 1) + "/" + currDate.getFullYear());
			
			for each(var readUser:XML in rawData.meta["ERA-notification"]["read_by_users"]) {
				if(readUser.username == Auth.getInstance().getUsername() && readUser.read_status == "true") {
					// its been read by the current user, so make it as read
					this.read = true;
				}
			}
			
			this.eraCase = new Model_ERACase();
			eraCase.setData(rawData.related.(@type=="notification_case").asset[0]);
			
			if(rawData.related.(@type=="notification_room")) {
				// a room is given, lets store it
				room = new Model_ERARoom();
				room.setData(rawData.related.(@type=="notification_room").asset[0]);
			}
			if(rawData.related.(@type=="notification_comment")) {
				if(this.type == FILE_COMMENT || this.type == ANNOTATION) {
					comment_file = new Model_Commentary();
					comment_file.setData(rawData.related.(@type=="notification_comment").asset[0]);
				} else if (this.type == ROOM_COMMENT) {
					comment_room = new Model_ERAConversation();
					comment_room.setData(rawData.related.(@type=="notification_comment").asset[0]);
				}
			}
			if(rawData.related.(@type=="notification_file")) {
				if(this.type == EVIDENCE_COLLECTED || this.type == EVIDENCE_READY_FOR_COLLECTION) {
					logItem = new Model_ERALogItem();
					logItem.setData(rawData.related.(@type=="notification_file").asset[0]);
				} else if(this.type == FILE_COMMENT || this.type == ANNOTATION || this.type == FILE_MOVED_TO_SCREENING_LAB || this.type == FILE_MOVED_TO_FORENSIC_LAB || this.type == FILE_MOVED_TO_EXHIBITION || this.type == FILE_UPLOADED) {
					file = new Model_ERAFile();
					file.setData(rawData.related.(@type=="notification_file").asset[0]);
				}
			}
		}
	}
}