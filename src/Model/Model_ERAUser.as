package Model {
	
	public class Model_ERAUser extends Model_Base {
		
		public var firstName:String;
		public var lastName:String;
		public var username:String;
		
		public static const SUPER_ADMIN:String = "ERA-super-admin";
		public static const SYS_ADMIN:String = "sys_admin";
		public static const MONITOR:String = "monitor";
		public static const RESEARCHER:String = "researcher";
		public static const PRODUCTION_MANAGER:String = "production_manager";
		public static const PRODUCTION_TEAM:String = "production_team";
		public static const VIEWER:String = "viewer";
		public static const LIBRARY_ADMIN:String = "library_admin";
		
		public static var ERARoles:Array = new Array(SYS_ADMIN, MONITOR, RESEARCHER, PRODUCTION_MANAGER, PRODUCTION_TEAM, VIEWER, LIBRARY_ADMIN);
		
		public function Model_ERAUser() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {		
			this.username = rawData.@user;
			this.firstName = firstLetterUpperCase(rawData.meta["ERA-user"]["first_name"]);
			this.lastName = firstLetterUpperCase(rawData.meta["ERA-user"]["last_name"]);
//			this.firstName = rawData.asset.meta.r_user.firstname;
//			this.lastName = rawData.asset.meta.r_user.lastname;
		}
		
		public static function getRolePrettyName(role:String):String {
			switch(role) {
				case SYS_ADMIN:
					return "System Administrator";
				case MONITOR:
					return "Monitor";
				case RESEARCHER:
					return "Researcher";
				case PRODUCTION_MANAGER:
					return "Production Manager";
				case PRODUCTION_TEAM:
					return "Production Team";
				case VIEWER:
					return "External Viewer"
				case LIBRARY_ADMIN:
					return "Library Administrator";
				default:
					return "Unknown Role"
			}
		}
		
		public static function getRoleDescription(role:String):String {
			switch(role) {
				case SYS_ADMIN:
					return "These users have access to all of the nQuisitor Administration tools. They have unrestricted access rights to all Case files.";
				case MONITOR:
					return "These users have access to all Cases. They can view and comment on Case files in the Review Lab and view Case files the Exhibition Room.";
				case RESEARCHER:
					return "These users have access to their own Case files in the Review Lab. Here they can view and comment on their Case files.";
				case PRODUCTION_MANAGER:
					return "These users have access to all Case files that they have been assigned by the System Administrator";
				case PRODUCTION_TEAM:
					return "These users have access to all Case files (excluding the Exhibition Room) that they have been assigned by the System Administrator";
				case VIEWER:
					return "These users have access to all Cases. They can only view and comment on Case files that appear in the Review Lab and the Exhibition Room.";
				case LIBRARY_ADMIN:
					return "These users can download all Case files from the Exhibition Room.";
				default:
					return "Unknown Role"
			}
		}
		
		private function firstLetterUpperCase(str:String) : String {
			var firstChar:String = str.substr(0, 1); 
			var restOfString:String = str.substr(1, str.length); 
			
			return firstChar.toUpperCase()+restOfString.toLowerCase(); 
		}

	}
}