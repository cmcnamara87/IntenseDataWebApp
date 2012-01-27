package Model {
	
	public class Model_ERAProject extends Model_Base {
	
		public var dueDate:String;
		public var packageSize:String;
		public var day:String;
		public var month:String;
		public var year:String;
		
		private var emailOptionArray:Array;
		
		public function Model_ERAProject() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {	
			trace("set specific data");
			this.dueDate = rawData.meta["ERA-project"]["due_date"];
			this.packageSize = rawData.meta["ERA-project"]["package_size"];
			
			var dateArray:Array = dueDate.split("-");
			this.day = dateArray[0];
			this.month = dateArray[1];
			
			var yearArray:Array = (dateArray[2] as String).split(" ");
			this.year = yearArray[0];
			
			// grab out the case info
			emailOptionArray = new Array();
			
			for each(var emailOptionsXML:XML in rawData.meta["ERA-project"]["email_notifications"]) {
				var emailOptionsObject:Object = new Object();
				emailOptionsObject.role = emailOptionsXML.role;
				emailOptionsObject.username = "";
				if(emailOptionsXML.username != undefined) {
					emailOptionsObject.username = emailOptionsXML.username;
				}
				trace("************email options", emailOptionsXML.role, emailOptionsXML.username);
				emailOptionArray.push(emailOptionsObject);
			}
		}
		
		public function isEmailEnabled(role:String, username:String=""):Boolean {
			// given role - need to match role only
			// given role and username - need to match either role alone, or role + username
//			trace("** CHECKING MATCH FOR", role, username);
			
			for each(var emailOptionsObject:Object in emailOptionArray) {
				trace(" checking match with", emailOptionsObject.role, emailOptionsObject.username);
				// given role only
				if(username == "" && emailOptionsObject.role == role && emailOptionsObject.username == "") return true;
				// we have been given a user
				// if there is a role only enabled, return true
				// or if there is a match to both rule and username return true
				
				if(username != "" && (emailOptionsObject.role == role && (emailOptionsObject.username == "" || emailOptionsObject.username == username))) return true;
			}
			return false;
		}
	}
}