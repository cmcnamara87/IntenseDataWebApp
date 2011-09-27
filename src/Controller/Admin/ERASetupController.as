package Controller.Admin
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	
	import View.ERASetupView;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	import spark.components.Label;

	public class ERASetupController extends AppController
	{
		private var eraSetupView:ERASetupView = new ERASetupView();
		
		public function ERASetupController()
		{
			view = eraSetupView;
			
			// Setup the model info
			if(AppController.currentEraProject != null) {
				eraSetupView.day.selectedItem = AppController.currentEraProject.day;
				eraSetupView.month.selectedItem = AppController.currentEraProject.month;
				eraSetupView.year.selectedItem = AppController.currentEraProject.year;
				trace("era year is", AppController.currentEraProject.year, AppController.currentEraProject.dueDate);
				eraSetupView.packageSize.text = AppController.currentEraProject.packageSize;
			}
			super();
		}
		
		override public function init():void {
			eraSetupView.createButton.addEventListener(MouseEvent.CLICK, createButtonClicked);
		}
		
		private function createButtonClicked(e:MouseEvent):void {
			//DD-MMM-YYYY
			
			// check if we are creating or updating
			if(AppController.currentEraProject != null) {
				// there is a current era project
				// so we must be updating
				
			} else {
			// Lets make the due date
				layout.notificationBar.showProcess("Saving ERA");
				var packageSize:String = eraSetupView.packageSize.text;
				AppModel.getInstance().makeERAProject(	eraSetupView.day.selectedItem,
														eraSetupView.month.selectedItem,
														eraSetupView.year.selectedItem,
														packageSize,
														eraCreated);
			}
		}
		
		private function eraCreated(status:Boolean, data:Model_ERAProject):void {
			if(status) {
				AppController.currentEraProject = data;
				layout.notificationBar.showGood("Era Created");
			} else {
				layout.notificationBar.showError("Era Failed to be Created");	
			}
			
		}
	}
}