package Controller.ERA
{
	import Controller.AppController;
	import Controller.Dispatcher;
	
	import Model.AppModel;
	
	import View.CaseView;
	
	import mx.controls.Alert;
	
	public class CaseController extends AppController
	{
		private var caseView:CaseView;
		
		public function CaseController()
		{
			caseView = new CaseView();
			var caseID:Number = Dispatcher.getArgs()[0];
			Alert.show("Showing " + caseID);
			view = caseView;
			super();
		}
		
		private function setupEventListeners():void {
			// Listen for file upload
		}
		override public function init():void {
			setupEventListeners();
			
			AppModel.getInstance().getAllERACases(AppController.currentEraProject.base_asset_id, gotAllERACases);
		}
		private function gotAllERACases(status:Boolean, eraCaseArray:Array):void {
			caseView.addCases(eraCaseArray);	
		}
		
		private function startFileUpload():void {
//			dataObject = (view as NewAsset).metaForm.getData();
//			dataObject.file = file;
//			lock();
//			AppModel.getInstance().startFileUpload(dataObject);
		}
	}
}