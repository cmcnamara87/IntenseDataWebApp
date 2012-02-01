package Controller.ERA
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAProject;
	import Model.Model_ERAUser;
	
	import View.ERA.SplashScreen;
	
	import mx.controls.Alert;
	import mx.events.IndexChangedEvent;
	
	import spark.components.DropDownList;
	import spark.events.IndexChangeEvent;
	
	public class SplashScreen extends AppController
	{
		private var splashView:View.ERA.SplashScreen = null;
		public static const caseSearchBoxDefaultText:String = "Search for a Case";
		
		public function SplashScreen()
		{
			splashView = new View.ERA.SplashScreen(); 
			view = splashView;
			super();
		}
		
		//Protection to ensure controllers take advantage of the init method
		override public function init():void {
			layout.header.adminToolButtons.visible = false;
			layout.header.adminToolButtons.includeInLayout = false;
			
			setupEventListeners();
			
			// Get all the ERA cases for this ERA
			splashView.showERAInDropdown();
			
			
		}
		private function setupEventListeners():void {
			splashView.caseERADropdown.addEventListener(IndexChangeEvent.CHANGE, eraChanged, false, 0, true);
		}
	
		private function eraChanged(e:IndexChangeEvent):void {
			var dropdownList:DropDownList = (e.target as DropDownList);
			
			// Grab out the selected era's data
			var eraProject:Model_ERAProject = dropdownList.selectedItem.data;
			// Set it as the new current era
			currentEraProject = eraProject;
			trace("era project changed to", currentEraProject.year);
			
			splashView.casePanelScroller.includeInLayout = false;
			splashView.casePanelScroller.visible = false;
			
			// Clear the cases
			splashView.caseSearch.text = "Loading Cases...";
			splashView.caseSearch.enabled = false;
			splashView.casePanelContent.removeAllElements();
			
			// Disable the rooms
			splashView.placeSelect.enabled = false;
			splashView.placeSelect.visible = false;
			
			AppModel.getInstance().getAllERACases(AppController.currentEraProject.base_asset_id, gotAllERACases);
		}
	
		private function gotAllERACases(status:Boolean, eraCaseArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Could not retrieve any cases");
				return;
			}
			trace("got all cases, adding to splash screen");
			
			if(Auth.getInstance().hasRoleForYear(Model_ERAUser.LIBRARY_ADMIN, AppController.currentEraProject.year)) {
				trace("is a library admin");
				for(var i:Number = 0; i < eraCaseArray.length; i++) {
					trace("for loop");
					var eraCase:Model_ERACase = eraCaseArray[i] as Model_ERACase;
					if(!(eraCase.readyForDownload && !eraCase.libraryDownloaded)) {
						trace("removing case", eraCase.title);
						eraCaseArray.splice(i, 1);
						i--; // correcting for it being removed from the list
					} else {
						trace("leaving case", eraCase.title);
					}
				}
			} else {
				trace("isnt a library admin");
			}
			splashView.addCases(eraCaseArray);
		
			
//			AppModel.getInstance().getAllRoomsInCase(caseID, gotAllRooms);
			
		}
		override public function dealloc():void {
			splashView = null;
			super.dealloc();
		}
	}
}