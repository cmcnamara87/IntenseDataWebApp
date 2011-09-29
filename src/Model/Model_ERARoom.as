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