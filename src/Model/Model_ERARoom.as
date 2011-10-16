package Model {
	
	public class Model_ERARoom extends Model_Base {
		
		public var roomType:String;
		public var roomTitle:String;
		
		public static const EVIDENCE_MANAGEMENT:String = "evidencemanagement";
		public static const EVIDENCE_ROOM:String = "evidenceroom";
		public static const FORENSIC_LAB:String = "forensiclab";
		public static const SCREENING_ROOM:String = "screeningroom";
		public static const EXHIBIT:String = "exhibit";
		
		public static const ROOM_TYPE_ARRAY:Array = new Array(EVIDENCE_MANAGEMENT, EVIDENCE_ROOM, FORENSIC_LAB, SCREENING_ROOM, EXHIBIT);
		
		public function Model_ERARoom() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			this.roomType = rawData.meta["ERA-room"]["room_type"];
			this.roomTitle = getPrettyRoomName(roomType);
		}
		
		public static function  getPrettyRoomName(roomType:String):String {
			switch(roomType) {
				case EVIDENCE_MANAGEMENT:
					return "Evidence Management";
				case EVIDENCE_ROOM:
					return "Evidence Room";
				case FORENSIC_LAB:
					return "Forensic Lab";
				case SCREENING_ROOM:
					return "Screening Room";
				case EXHIBIT:
					return "Exhibit";
				default:
					return "Unknown";
			}
		}
	}
}