package Model {
	
	public class Model_ERACase extends Model_Base {
		
		public var rmCode:String;
		public var title:String;
		public var researchersArray:Array = new Array();
		public var qutSchool:String;
		public var forArray:Array = new Array(); // array of FOR_Models
		public var categoryArray:Array = new Array();
		public var productionManagerArray:Array = new Array();
		public var productionTeamArray:Array = new Array();
		
		public static const CAT1:String = "Category_1";
		public static const CAT2:String = "Category_2";
		public static const CATEGORY_ARRAY:Array = new Array(CAT1, CAT2);
		
		public static const FOR_CODE = "for_code";
		public static const PERCENTAGE = "percentage";
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
			for each(var researcherXML:XML in eraCase["researcher_username"]) {
				var researcher:Model_ERAUser = new Model_ERAUser();
				researcher.username = researcherXML["username"];
				researcher.firstName = researcherXML["first_name"];
				researcher.lastName = researcherXML["last_name"];
				researchersArray.push(researcher);
			}
			
			// add the qut school
			this.qutSchool = eraCase["qut_school"];
			
			// add all the for codes + percentages
			for each(var forData:XML in eraCase["for"]) {
				var forPair:Array = new Array();
				forPair[FOR_CODE] = forData[FOR_CODE];
				forPair[PERCENTAGE] = forData[PERCENTAGE];
				forArray.push(forPair);
			}
			
			// add the categories (maybe 1 or more)
			for each(var category:String in eraCase["category"]) {
				categoryArray.push(category);
			}
			
			// add all the production managers
			for each(var productionManagerXML:XML in eraCase["production_manager_username"]) {
				var productionManager:Model_ERAUser = new Model_ERAUser();
				productionManager.username = productionManagerXML["username"];
				productionManager.firstName = productionManagerXML["first_name"];
				productionManager.lastName = productionManagerXML["last_name"];
				productionManagerArray.push(productionManager);
			}
			
			// add all the production team members
			for each(var productionTeamXML:XML in eraCase["production_manager_username"]) {
				var productionTeam:Model_ERAUser = new Model_ERAUser();
				productionTeam.username = productionTeamXML["username"];
				productionTeam.firstName = productionTeamXML["first_name"];
				productionTeam.lastName = productionTeamXML["last_name"];
				productionTeamArray.push(productionTeam);
			}
		}
	}
}