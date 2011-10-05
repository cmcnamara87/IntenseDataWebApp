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
		
		public static var ERARoles:Array = new Array(SYS_ADMIN, MONITOR, RESEARCHER, PRODUCTION_MANAGER, PRODUCTION_TEAM, VIEWER);
		
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
				case "sys_admin":
					return "System Administrator";
				case "monitor":
					return "Monitor";
				case "researcher":
					return "Researcher";
				case "production_manager":
					return "Production Manager";
				case "production_team":
					return "Production Team";
				case "viewer":
					return "External Viewer"
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