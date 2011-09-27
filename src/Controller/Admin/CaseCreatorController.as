package Controller.Admin
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	
	import View.CaseCreatorView;
	
	import mx.collections.ArrayList;
	
	import spark.components.Label;
	
	public class CaseCreatorController extends AppController
	{
		private var caseCreatorView:CaseCreatorView;
		
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
			
		}
		
		private function getAllCases():void {
			AppModel.getInstance().getAllERACases(AppController.currentEraProject.base_asset_id, gotAllCases);
		}
		
		private function gotAllCases(status:Boolean, eraCaseArray:Array):void {
//			if(status) {
//				layout.notificationBar.showGood("Got all cases");
//			} else {
//				layout.notificationBar.showError("Error getting cases");
//			}
			var something:ArrayList = new ArrayList();
			for each(var eraCase:Model_ERACase in eraCaseArray) {
				something.addItem(eraCase.rmCode);
			}
			
			caseCreatorView.currentCases.dataProvider = something;
				
			if(eraCaseArray.length > 0) {
				caseCreatorView.showCase(eraCaseArray[0]);
			}
//			var forArray:Array = new Array();
//			forArray["for_code"] = "2345FORCODE";
//			forArray["percentage"] = "100";
			// Create a era case now lol
//			AppModel.getInstance().createERACase("2010", "89101Code", "Magical Case", new Array("cmcnamara87", "mark"), "Design", new Array(forArray), new Array("magical category"), new Array("peter h", "mark"), new Array("craig", "others"), eraCaseCreated);
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