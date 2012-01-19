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
					return "Library Admin";
				default:
					return "Unknown Role"
			}
		}
		
		public static function getRoleDescription(role:String):String {
			switch(role) {
				case SYS_ADMIN:
					return "Users with access to all of the administration tools available and all cases.";
				case MONITOR:
					return "Users with access to all cases, and view and comment in the Screening Lab and view the Exhibition.";
				case RESEARCHER:
					return "A QUT Researcher account. These users have access to view and comment in the Screening Lab of cases they are assigned to. ";
				case PRODUCTION_MANAGER:
					return "Users with access to all cases they are assigned to for all sections.";
				case PRODUCTION_TEAM:
					return "Users with access to all cases they are assigned to for all sections except the Exhibition.";
				case VIEWER:
					return "Users with access to all cases, and view and comment in the Screening Lab and view the Exhibition.";
				case LIBRARY_ADMIN:
					return "User with access to download files from Exhibition for library purposes.";
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