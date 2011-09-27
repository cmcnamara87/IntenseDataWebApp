package Model {
	
	public class Model_ERACase extends Model_Base {
		
		public var rmCode:String;
		public var title:String;
		public var researcherUsernames:Array = new Array();
		public var qutSchool:String;
		public var forArray:Array = new Array(); // array of FOR_Models
		public var categoryArray:Array = new Array();
		public var productionManagerUsernameArray:Array = new Array();
		public var productionTeamUsernameArray:Array = new Array();
		
		
		public function Model_ERACase() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			// grab out the case info
			var eraCase:XML = rawData.meta["ERA-case"][0];
			
			// set the RM code
			this.rmCode = eraCase["RM_code"];
			
			// set the title of the case
			this.title = eraCase["title"];
			
			// add all the researchers usernames
			for each(var researcherUsername:String in eraCase["researcher_username"]) {
				researcherUsernames.push(researcherUsername);
			}
			
			// add the qut school
			this.qutSchool = eraCase["qut_school"];
			
			// add all the for codes + percentages
			for each(var forData:XML in eraCase["for"]) {
				var forPair:Array = new Array();
				forPair["for_code"] = forData["for_code"];
				forPair["percentage"] = forData["percentage"];
				forArray.push(forPair);
			}
			
			// add the categories (maybe 1 or more)
			for each(var category:String in eraCase["category"]) {
				categoryArray.push(category);
			}
			
			// add all the production managers
			for each(var productionManagerUsername:String in eraCase["production_manager_username"]) {
				productionManagerUsernameArray.push(productionManagerUsername);
			}
			
			// add all the production team members
			for each(var productionTeamUsername:String in eraCase["production_team_username"]) {
				productionTeamUsernameArray.push(productionTeamUsername);
			}
		}
	}
}