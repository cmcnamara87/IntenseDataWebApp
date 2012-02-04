package Model {
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	public class Model_ERARoom extends Model_Base {
		
		public var roomType:String;
		public var roomTitle:String;
		public var caseID:Number;
		public var evidenceCount:Number = 0;
		
		public static const EVIDENCE_MANAGEMENT:String = "evidencemanagement";
		public static const EVIDENCE_ROOM:String = "evidenceroom";
		public static const FORENSIC_LAB:String = "forensiclab";
		public static const SCREENING_ROOM:String = "screeningroom";
		public static const EXHIBIT:String = "exhibit";
		public static const POST_MORTEM:String = "postmortem";
		
		public static const ROOM_TYPE_ARRAY:Array = new Array(EVIDENCE_MANAGEMENT, EVIDENCE_ROOM, FORENSIC_LAB, SCREENING_ROOM, EXHIBIT, POST_MORTEM);
		
		public var notificationCount:Number = 0;
		public var notificationArray:Array = new Array();
		
		public function Model_ERARoom() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			this.roomType = rawData.meta["ERA-room"]["room_type"];
			this.roomTitle = getPrettyRoomName(roomType);
			this.caseID = rawData.related.(@type=="case").to;
			
//			this.evidenceCount = rawData.related.(@type=="evidence").to.length();
			updateNotificationCount();
		}
		
		public function updateNotificationCount():void {
			// Count up the number of notifications this file has
			this.notificationCount = 0;
			
			for each(var notificationData:Model_ERANotification in AppController.notificationsArray) {
				if(!notificationData.room || notificationData.read) continue;
				
				if(notificationData.room.base_asset_id == this.base_asset_id) {
					this.notificationCount++;
					this.notificationArray.push(notificationData);
				}
			}
		}
		
		public static function  getPrettyRoomName(roomType:String):String {
			switch(roomType) {
				case EVIDENCE_MANAGEMENT:
					return "Evidence Management";
				case EVIDENCE_ROOM:
					return "Evidence Box";
				case FORENSIC_LAB:
					return "Forensic Lab";
				case SCREENING_ROOM:
					return "Review Lab";
				case EXHIBIT:
					return "Exhibition Room";
				default:
					return "Unknown";
			}
		}
	}
}