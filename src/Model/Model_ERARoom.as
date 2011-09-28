package Model {
	
	public class Model_ERARoom extends Model_Base {
		
		public var roomType:String;
		public var roomTitle:String;
		
		public static const EVIDENCE_MANAGEMENT = "evidencemanagement";
		public static const EVIDENCE_ROOM = "evidenceroom";
		public static const FORENSIC_LAB = "forensiclab";
		public static const SCREENING_ROOM = "screeningroom";
		public static const EXHIBIT = "exhibit";
		
		public static const ROOM_TYPE_ARRAY:Array = new Array(EVIDENCE_MANAGEMENT, EVIDENCE_ROOM, FORENSIC_LAB, SCREENING_ROOM, EXHIBIT);
		
		public function Model_ERARoom() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			this.roomType = rawData.asset.meta["ERA-room"].room_type;
			switch(roomType) {
				case EVIDENCE_MANAGEMENT:
					roomTitle = "Evidence Management";
					break;
				case EVIDENCE_ROOM:
					roomTitle = "Evidence Room";
					break;
				case FORENSIC_LAB:
					roomTitle = "Forensic Lab";
					break;
				case SCREENING_ROOM:
					roomTitle = "Screening Room";
					break;
				case EXHIBIT:
					roomTitle = "Exhibit";
					break;
				default:
					break;
			}
		}
	}
}