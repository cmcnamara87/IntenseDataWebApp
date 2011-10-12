package Controller.ERA.Admin
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAUser;
	
	import View.ERA.CaseCreatorView;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	
	public class CaseCreatorController extends AppController
	{
		// The View
		private var caseCreatorView:CaseCreatorView;
		
		// Case Data
		private var eraCaseArray:Array;
		
		public function CaseCreatorController()
		{
			// @todo
			caseCreatorView = new CaseCreatorView;
			view = caseCreatorView;
			super();
		}
		
		override public function init():void {
			layout.header.unhighlightAllButtons();
			layout.header.caseCreatorButton.setStyle("chromeColor", "0x000000");
			
			caseCreatorView.currentYear = AppController.currentEraProject.year;
			
			setupEventListeners();
			// Get all the cases
			AppModel.getInstance().getAllERACases(AppController.currentEraProject.base_asset_id, gotAllCases);
			// Get all the researchers
			AppModel.getInstance().getERAUsersWithRole(Model_ERAUser.RESEARCHER, AppController.currentEraProject.year, gotAllResearchers);
			// Get all the production managers
			AppModel.getInstance().getERAUsersWithRole(Model_ERAUser.PRODUCTION_MANAGER, AppController.currentEraProject.year, gotAllProductionManagers);
			// Get all the team members
			AppModel.getInstance().getERAUsersWithRole(Model_ERAUser.PRODUCTION_TEAM, AppController.currentEraProject.year, gotAllTeamMembers);
		}
		
		private function setupEventListeners():void {
			caseCreatorView.createCaseButton.addEventListener(MouseEvent.CLICK, createCase);
			caseCreatorView.saveButton.addEventListener(MouseEvent.CLICK, saveChangesToCase);
			caseCreatorView.deleteCaseButton.addEventListener(MouseEvent.CLICK, deleteCase);
		}
		
		private function validInputs():Boolean {
			var rmCode:String = caseCreatorView.rmCode.text;			
			if(rmCode == "") {
				layout.notificationBar.showError("Please enter an RM Code.");
				return false;
			}
			
			// Get title
//			var title:String = caseCreatorView.title.text;
//			if(title == "") {
//				layout.notificationBar.showError("Please enter a Case Title.");
//				return false;
//			}
			
			// Get QUT school
//			if(caseCreatorView.qutSchool.selectedIndex == -1) {
//				layout.notificationBar.showError("Please Select a QUT School");
//				return false;
//			}
//			var qutSchool:String = caseCreatorView.qutSchool.selectedItem.data;
			
			// get researchers
			var researcherUsernames:Array = caseCreatorView.chosenResearchersArray;
			if(researcherUsernames.length == 0) {
				layout.notificationBar.showError("Please Add at least one Researcher.");
				return false;
			}
			
			// Get FoRs
			var forArray:Array = caseCreatorView.chosenForsArray;
//			if(forArray.length == 0) {
//				layout.notificationBar.showError("Please Add at least one FoR");
//				return false;
//			}
			// Check taht the FORs add up to 100%
			var totalPercentage:Number = 0;
			for each(var forPair:Array in forArray) {
				totalPercentage += Number(forPair[Model_ERACase.PERCENTAGE]);
			}
			// If there are FoRs, make sure they add up to 100%
			if(forArray.length > 0 && totalPercentage != 100) {
				layout.notificationBar.showError("Please make sure your FoR percentages add up to 100%");
				return false;
			}
			
			// Get Category array
//			var categoryArray:Array = caseCreatorView.chosenCategories;
//			if(categoryArray.length == 0) {
//				layout.notificationBar.showError("Please Add at least one Category.");
//				return false;
//			}
			
//			var productionManagerArray:Array = caseCreatorView.chosenProductionManagersArray;
//			if(productionManagerArray.length == 0) {
//				layout.notificationBar.showError("Please enter at least one Production Manager.");
//				return false;
//			}
			
			/*var productionTeamArray:Array = caseCreatorView.chosenTeamMembersArray;
			if(productionTeamArray.length == 0) {
				layout.notificationBar.showError("Please enter at least one Production Team Member.");
				return false;
			}*/
			
			return true;
		}
		
		/* ====================================== UPDATE A CASE ===================================== */
		private function saveChangesToCase(e:MouseEvent):void {
			if(!validInputs()) {
				return;
			}
			
			if(caseCreatorView.currentCases.selectedIndex == -1) {
				return;
			}
			
			// Get out the case ID
			var caseID:Number = (caseCreatorView.currentCases.selectedItem.data as Model_ERACase).base_asset_id;
			
			// Get RM Code
			var rmCode:String = caseCreatorView.rmCode.text;			
			
			// Get title
			var title:String = caseCreatorView.title.text;
			
			// Get QUT school
			var qutSchool:String = "";
			if(caseCreatorView.qutSchool.selectedIndex != -1) {
				var qutSchool:String = caseCreatorView.qutSchool.selectedItem.data;
			}
			
			// get researchers
			var researcherUsernames:Array = caseCreatorView.chosenResearchersArray;
			
			// Get FoRs
			var forArray:Array = caseCreatorView.chosenForsArray;
			
			// Get Category array
			var categoryArray:Array = caseCreatorView.chosenCategories;
			
			var productionManagerArray:Array = caseCreatorView.chosenProductionManagersArray;
			
			var productionTeamArray:Array = caseCreatorView.chosenTeamMembersArray;
			
			layout.notificationBar.showProcess("Saving Case...");
			
			// Create a era case now lol
			AppModel.getInstance().updateERACase(
				caseID,
				rmCode,
				title,
				researcherUsernames,
				qutSchool,
				forArray,
				categoryArray,
				productionManagerArray,
				productionTeamArray,
				eraCaseUpdated);
		}
		private function eraCaseUpdated(status:Boolean, eraCaseUpdated:Model_ERACase):void {
			if(!status) {
				layout.notificationBar.showError("Error Updating Case");
				return;
			}
			
			layout.notificationBar.showGood("Case Updated " + eraCaseUpdated.rmCode);
			
			// Replace the case with the new one
			for(var i:Number = 0; i < this.eraCaseArray.length; i++) {
				var eraCase:Model_ERACase = this.eraCaseArray[i] as Model_ERACase;
				if(eraCase.base_asset_id == eraCaseUpdated.base_asset_id) {
					this.eraCaseArray.splice(i, 1);
					break;
				}
			}
			this.eraCaseArray.push(eraCaseUpdated);
			
			// Add it to the view
			caseCreatorView.addAllCases(eraCaseArray);
			
			caseCreatorView.exitCreationMode();
			
			caseCreatorView.showCase(eraCaseArray[i]);
			
			trace("selecting index", i);
			caseCreatorView.currentCases.selectedIndex = i;
		}
		/* ====================================== END OF UPDATE A CASE ===================================== */
		
		/* ====================================== CREATE A CASE ===================================== */
		private function createCase(e:MouseEvent):void {
			
			if(!validInputs()) {
				return;
			}
			// Get RM Code
			var rmCode:String = caseCreatorView.rmCode.text;			
			
			// Get title
			var title:String = caseCreatorView.title.text;
			
			// Get QUT school
			var qutSchool:String = "";
			if(caseCreatorView.qutSchool.selectedIndex != -1) {
				qutSchool = caseCreatorView.qutSchool.selectedItem.data;
			}
			
			// get researchers
			var researcherUsernames:Array = caseCreatorView.chosenResearchersArray;

			// Get FoRs
			var forArray:Array = caseCreatorView.chosenForsArray;
			
			// Get Category array
			var categoryArray:Array = caseCreatorView.chosenCategories;
			
			var productionManagerArray:Array = caseCreatorView.chosenProductionManagersArray;
			
			var productionTeamArray:Array = caseCreatorView.chosenTeamMembersArray;
			
			layout.notificationBar.showProcess("Saving Case...");
			
			// Create a era case now lol
			AppModel.getInstance().createERACase(
				AppController.currentEraProject.year,
				rmCode,
				title, 
				researcherUsernames, 
				qutSchool, 
				forArray,
				categoryArray,
				productionManagerArray,
				productionTeamArray, 
				eraCaseCreated);
		}
		private function eraCaseCreated(status:Boolean, eraCase:Model_ERACase):void {
			if(!status) {
				layout.notificationBar.showError("Error making cases");
				return;
			}
			
			layout.notificationBar.showGood("Case Created");
			// Add the case
			this.eraCaseArray.push(eraCase);
			
			// Add it to the view
			caseCreatorView.addAllCases(eraCaseArray);
			
			caseCreatorView.exitCreationMode();
			
			caseCreatorView.currentCases.selectedIndex = eraCaseArray.length - 1;
			caseCreatorView.showCase(eraCaseArray[eraCaseArray.length - 1]);
		}
		/* ====================================== END OF CREATE A CASE ===================================== */
		
		private function deleteCase(e:MouseEvent):void {
			if(caseCreatorView.currentCases.selectedIndex == -1) return;
			
			var myAlert:Alert = Alert.show(
				"Are you sure you wish to this Case", "Delete Case", Alert.OK | Alert.CANCEL, null, function(e:CloseEvent):void {
					if (e.detail==Alert.OK) {
						var caseID:Number = (caseCreatorView.currentCases.selectedItem.data as Model_ERACase).base_asset_id;
						AppModel.getInstance().deleteERACase(caseID, caseDeleted);
					}
				}, null, Alert.CANCEL);
			
		}
		private function caseDeleted(status:Boolean, caseID:Number):void {
			if(!status) {
				layout.notificationBar.showError("Failed to delete Case");
				return;
			}	
			
			layout.notificationBar.showGood("Case Deleted");
			
			// Replace the case with the new one
			for(var i:Number = 0; i < this.eraCaseArray.length; i++) {
				var eraCase:Model_ERACase = this.eraCaseArray[i] as Model_ERACase;
				if(eraCase.base_asset_id == caseID) {
					this.eraCaseArray.splice(i, 1);
					break;
				}
			}
			
			caseCreatorView.addAllCases(eraCaseArray);
				if(eraCaseArray.length != 0) {
				caseCreatorView.currentCases.selectedIndex = 0;
				caseCreatorView.showCase(eraCaseArray[0]);
			}
			
		}
		
		/* ====================================== GET ALL ERA CASES FOR THE CURRENT ERA ===================================== */
		/**
		 * Got all the era cases for the current year 
		 * @param status		True is we succeeded in getting the cases, false otherwise
		 * @param eraCaseArray 	List of Model_ERACase
		 * 
		 */
		private function gotAllCases(status:Boolean, eraCaseArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Error getting cases");
			}

			// Save all the case data
			this.eraCaseArray = eraCaseArray;
			
			caseCreatorView.addAllCases(eraCaseArray);
				
			if(eraCaseArray.length > 0) {
				caseCreatorView.currentCases.selectedIndex = 0;
				caseCreatorView.showCase(eraCaseArray[0]);
			}
		}
		/* ========================================== END OF GET ALL ERA CASES FOR THE CURRENT ERA ========================================== */
		
		/* ========================================== GET ALL RESEACHERS ========================================== */
		private function gotAllResearchers(status:Boolean, role:String="", userArray:Array=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get all researchers");
				return;
			}

			caseCreatorView.addAllResearchers(userArray);
		}
		/* ========================================== END OF GET ALL RESEACHERS ========================================== */
		private function gotAllProductionManagers(status:Boolean, role:String="", userArray:Array=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get all researchers");
				return;
			}
			caseCreatorView.addAllProductionManagers(userArray);
		}
		private function gotAllTeamMembers(status:Boolean, role:String="", userArray:Array=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get all researchers");
				return;
			}
			caseCreatorView.addAllTeamMembers(userArray);
		}
		
		
	}
}