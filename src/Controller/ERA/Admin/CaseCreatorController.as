package Controller.ERA.Admin
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	
	import View.ERA.CaseCreatorView;
	
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
			getAllCases();
		}
		
		private function setupEventListeners():void {
			caseCreatorView.currentCases.addEventListener(IndexChangeEvent.CHANGE, changeCase);
		}
		
		private function changeCase(e:IndexChangeEvent):void {
			var rmCode:String = (e.target as DropDownList).selectedItem;
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				if(eraCase.rmCode == rmCode) {
					caseCreatorView.showCase(eraCase);
					break;
				}
			}
		}
		
		/* ====================================== GET ALL ERA CASES FOR THE CURRENT ERA ===================================== */
		/**
		 * Get all the ERA cases for the current year 
		 * 
		 */
		private function getAllCases():void {
			AppModel.getInstance().getAllERACases(AppController.currentEraProject.base_asset_id, gotAllCases);
		}
		
		/**
		 * Got all the era cases for the current year 
		 * @param status		True is we succeeded in getting the cases, false otherwise
		 * @param eraCaseArray 	List of Model_ERACase
		 * 
		 */
		private function gotAllCases(status:Boolean, eraCaseArray:Array):void {
			if(status) {
				layout.notificationBar.showGood("Got all cases");
			} else {
				layout.notificationBar.showError("Error getting cases");
			}
			
			// Save all the case data
			this.eraCaseArray = eraCaseArray;
			
			// Make a list of ERA cases for the view
			var something:ArrayList = new ArrayList();
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				something.addItem(eraCase.rmCode);
			}
			
			caseCreatorView.currentCases.dataProvider = something;
				
			if(eraCaseArray.length > 0) {
				caseCreatorView.showCase(eraCaseArray[0]);
			}
			var forArray:Array = new Array();
			forArray["for_code"] = "2345FORCODE";
			forArray["percentage"] = "100";
			// Create a era case now lol
			AppModel.getInstance().createERACase(AppController.currentEraProject.year, "MAGC1235", "Magical Case", new Array("cmcnamara87", "mark"), "Design", new Array(forArray), new Array("magical category"), new Array("peter h", "mark"), new Array("craig", "others"), eraCaseCreated);
			// Do something
		}
		
		private function eraCaseCreated(status:Boolean, eraCase:Model_ERACase):void {
			if(status) {
				layout.notificationBar.showGood("Made cases");
			} else {
				layout.notificationBar.showError("Error making cases");
			}
		}
	}
}