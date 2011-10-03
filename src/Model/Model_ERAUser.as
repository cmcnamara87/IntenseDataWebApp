package Model {
	
	public class Model_ERAUser extends Model_Base {
		
		public var firstName:String;
		public var lastName:String;
		public var username:String;
		
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
		
		private function firstLetterUpperCase(str:String) : String {
			var firstChar:String = str.substr(0, 1); 
			var restOfString:String = str.substr(1, str.length); 
			
			return firstChar.toUpperCase()+restOfString.toLowerCase(); 
		}

	}
}