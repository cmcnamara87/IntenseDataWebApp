package Model {
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	public class Model_ERACase extends Model_Base {
		
		// The case RM code
		public var rmCode:String;
		// The title of the case
		public var title:String;
		public var downloadTitle:String;
		// the number of files expected to be in the era case for exhibition
		public var fileCount:Number = 0;
		
		// has the library downloaded the package
		public var readyForDownload:Boolean = false;
		public var libraryDownloaded:Boolean = false;
		public var libraryDownloadTime:String = "";
		public var libraryDownloadUsername:String = "";
		
		// The researches for hte case (an array of usernames)
		public var researchersArray:Array = new Array();
		// the first name of the first researcher
		public var researcherFirstName:String = "";
		// the last name of the last researcher
		public var researcherLastName:String = "";
		
		// the QUT school
		public var qutSchool:String;
		public var forArray:Array = new Array(); // array of FOR_Models
		// an array of categories for hte case
		public var categoryArray:Array = new Array();
		public var productionManagerArray:Array = new Array();
		public var productionTeamArray:Array = new Array();

		public static const CAT1:String = "Original Creative Works - Visual Art Work (NP-A1)";
		public static const CAT2:String = "Original Creative Works - Design/Architectual Work (NP-A2)";
		public static const CAT3:String = "Original Creative Works - Textural Work (NP-A3)";
		public static const CAT4:String = "Original Creative Works - Other (NP-A4)";
		
		public static const CAT5:String = "Recorded/Rendered Creative Works - Film/Video (NP-C1)";
		public static const CAT6:String = "Recorded/Rendered Creative Works - Performance (NP-C2)";
		public static const CAT7:String = "Recorded/Rendered Creative Works - Inter-Arts (NP-C3)";
		public static const CAT8:String = "Recorded/Rendered Creative Works - Digital Creative Works (NP-C4)";
		public static const CAT9:String = "Recorded/Rendered Creative Works - Website/Web Exhibition (NP-C5)";
		public static const CAT10:String = "Recorded/Rendered Creative Works - Other (NP-C6)";
		
		public static const CAT11:String = "Curated or Produced Substantial Exhibitions - Web-based Exhibition (NP-D1)";
		public static const CAT12:String = "Curated or Produced Substantial Exhibitions - Exihition/Event (NP-D2)";
		public static const CAT13:String = "Curated or Produced Substantial Exhibitions - Festival (NP-D3)";
		public static const CAT14:String = "Curated or Produced Substantial Exhibitions - Other (NP-D4)";
		
		public static const CAT15:String = "Live Performance of Creative Work - Music (NPB1)";
		public static const CAT16:String = "Live Performance of Creative Work - Play (NPB2)";
		public static const CAT17:String = "Live Performance of Creative Work - Dance (NPB3)";
		public static const CAT18:String = "Live Performance of Creative Work - Other (NPB4)";
		
		public static const CATEGORY_ARRAY:Array = new Array(CAT1, CAT2, CAT3, CAT4, CAT5, CAT6, CAT7, CAT8, CAT9, CAT10, CAT11, CAT12, CAT13, CAT14, CAT15, CAT16, CAT17, CAT18);
		
		public static const FOR_CODE:String = "for_code";
		public static const PERCENTAGE:String = "percentage";
		
		public var notificationCount:Number = 0;
		public var notificationArray:Array = new Array();
		
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
			
			this.downloadTitle = eraCase["download_title"];
			
			// set the number of files expected in the exhibition
			if(eraCase["file_count"].length() > 0) {
				this.fileCount = eraCase["file_count"];
			}
			
			if(eraCase["library_downloaded"].length() > 0) {
				this.libraryDownloaded = eraCase["library_downloaded"] == "true";
				if(this.libraryDownloaded) {
					if(eraCase["library_download_time"].length() > 0) this.libraryDownloadTime = eraCase["library_download_time"];
					if(eraCase["library_download_username"].length() > 0) this.libraryDownloadUsername = eraCase["library_download_username"];
				}
			}
			
			if(eraCase["ready_for_download"].length()) {
				this.readyForDownload = eraCase["ready_for_download"] == "true";
			}
				
			// add all the researchers usernames
			var blah:Number = 0;
			for each(var researcherXML:XML in eraCase["researcher_username"]) {

				var researcher:Model_ERAUser = new Model_ERAUser();
				researcher.username = researcherXML["username"];
				researcher.firstName = researcherXML["first_name"];
				researcher.lastName = researcherXML["last_name"];
				researchersArray.push(researcher);
				
				if(blah++ == 0) {
					researcherFirstName = researcherXML["first_name"];
					researcherLastName = researcherXML["last_name"];
				}
			}
			researchersArray.sortOn(["lastName", "firstName"], [Array.CASEINSENSITIVE]);
			
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
			for each(var productionTeamXML:XML in eraCase["production_team_username"]) {
				var productionTeam:Model_ERAUser = new Model_ERAUser();
				productionTeam.username = productionTeamXML["username"];
				productionTeam.firstName = productionTeamXML["first_name"];
				productionTeam.lastName = productionTeamXML["last_name"];
				productionTeamArray.push(productionTeam);
			}
			
			updateNotificationCount();
		}
		
		public function updateNotificationCount():void {		
			// Count up the number of notifications this file has
//			trace("###### notification count", AppController.notificationsArray);
			this.notificationCount = 0;
			for each(var notificationData:Model_ERANotification in AppController.notificationsArray) {

				if(!notificationData.eraCase || notificationData.read) continue;
				
//				trace("###### looking for notification match");
				if(notificationData.eraCase.base_asset_id == this.base_asset_id) {
//					trace("######### found notification match"); 
					this.notificationCount++;
					this.notificationArray.push(notificationData);
				}
			}
		}
	}
}