package Controller.ERA.Admin
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAUser;
	
	import View.ERA.CaseCreatorView;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	
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
		}
		
		/* ====================================== CREATE A CASE ===================================== */
		private function createCase(e:MouseEvent):void {
			// Get RM Code
			var rmCode:String = caseCreatorView.rmCode.text;
			
			// Get title
			var title:String = caseCreatorView.title.text;
			
			// get researchers
			var researcherUsernames:Array = caseCreatorView.chosenResearchersArray;
			
			// Get QUT school
			var qutSchool:String = caseCreatorView.qutSchool.text;
			
			// Get FoRs
			var forArray:Array = caseCreatorView.chosenForsArray;
			
			// Get Category array
			var categoryArray:Array = caseCreatorView.chosenCategories;
			
			var productionManagerArray:Array = caseCreatorView.chosenProductionManagersArray;
			
			var productionTeamArray:Array = caseCreatorView.chosenTeamMembersArray;
			
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
		private function gotAllResearchers(status:Boolean, role:String, userArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get all researchers");
				return;
			}

			caseCreatorView.addAllResearchers(userArray);
		}
		/* ========================================== END OF GET ALL RESEACHERS ========================================== */
		private function gotAllProductionManagers(status:Boolean, role:String, userArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get all researchers");
				return;
			}
			caseCreatorView.addAllProductionManagers(userArray);
		}
		private function gotAllTeamMembers(status:Boolean, role:String, userArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get all researchers");
				return;
			}
			caseCreatorView.addAllTeamMembers(userArray);
		}
		
		
	}
}