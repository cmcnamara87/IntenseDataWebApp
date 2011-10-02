package Controller.ERA.Admin
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	
	import View.ERA.ERASetupView;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;

	public class ERASetupController extends AppController
	{
		private var eraSetupView:ERASetupView = new ERASetupView();
		
		public function ERASetupController()
		{
			view = eraSetupView;
			super();
		}
		
		override public function init():void {
			eraSetupView.createButton.addEventListener(MouseEvent.CLICK, createButtonClicked);
			eraSetupView.saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			eraSetupView.deleteERAButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked);
			
			eraSetupView.addERAProjects(AppController.eraProjectArray);
			
			// Listen for change in ERA list
			eraSetupView.eras.addEventListener(IndexChangeEvent.CARET_CHANGE, eraChanged);
		}
		
		private function deleteButtonClicked(e:MouseEvent):void {
			layout.notificationBar.showProcess("Updating ERA");
			var packageSize:String = eraSetupView.packageSize.text;
			AppModel.getInstance().deleteERAProject(eraSetupView.eras.selectedItem.data, eraDeleted);
		}
		private function eraDeleted(status:Boolean, deletedERAID:Number=0):void {
			if(status) {
				for(var i:Number = 0; i < AppController.eraProjectArray.length; i++) {
					var eraProject:Model_ERAProject = AppController.eraProjectArray[i] as Model_ERAProject;
					if(eraProject.base_asset_id == deletedERAID) {
						AppController.eraProjectArray.splice(i, 1);
						break;
					}
				}
				layout.notificationBar.showGood("Era Deleted");
				eraSetupView.addERAProjects(AppController.eraProjectArray);
				AppController.updateERADropdownList();	
			} else {
				eraSetupView.myNotificationBar.showError("Era Failed to be Created");	
			}
		}
		
		private function eraChanged(e:IndexChangeEvent):void {
			trace("ERA CHANGED", DropDownList(e.target).selectedItem.data);
			var selectedEraID:Number = DropDownList(e.target).selectedItem.data;
			for each(var eraProject:Model_ERAProject in eraProjectArray) {
				if(eraProject.base_asset_id == selectedEraID) {
					eraSetupView.addERAProject(eraProject);
					break;
				}
			}
		}
		private function saveButtonClicked(e:MouseEvent):void {
			layout.notificationBar.showProcess("Updating ERA");
			var packageSize:String = eraSetupView.packageSize.text;
			AppModel.getInstance().updateERAProject(eraSetupView.eras.selectedItem.data,
													eraSetupView.day.selectedItem,
													eraSetupView.month.selectedItem,
													eraSetupView.year.selectedItem,
													packageSize,
													eraUpdated);
		}
		private function eraUpdated(status:Boolean, data:Model_ERAProject):void {
			if(status) {
				AppController.currentEraProject = data;
				
				for(var i:Number = 0; i < AppController.eraProjectArray.length; i++) {
					var eraProject:Model_ERAProject = AppController.eraProjectArray[i] as Model_ERAProject;
					if(eraProject.base_asset_id == data.base_asset_id) {
						AppController.eraProjectArray.splice(i, 1);
						AppController.eraProjectArray.push(eraProject);
						break;
					}
				}
				eraSetupView.myNotificationBar.showGood("Era Created");
				eraSetupView.addERAProjects(AppController.eraProjectArray);
				AppController.updateERADropdownList();
			} else {
				eraSetupView.myNotificationBar.showError("Era Failed to be Created");	
			}
		}

		private function createButtonClicked(e:MouseEvent):void {
			//DD-MMM-YYYY
			
			// Lets make the due date
				layout.notificationBar.showProcess("Saving ERA");
				var packageSize:String = eraSetupView.packageSize.text;
				AppModel.getInstance().makeERAProject(	eraSetupView.day.selectedItem,
														eraSetupView.month.selectedItem,
														eraSetupView.year.selectedItem,
														packageSize,
														eraCreated);
		}
		
		private function eraCreated(status:Boolean, data:Model_ERAProject):void {
			if(status) {
				AppController.currentEraProject = data;
				AppController.eraProjectArray.push(data);
				eraSetupView.myNotificationBar.showGood("Era Created");
				
				eraSetupView.addERAProjects(AppController.eraProjectArray);
				AppController.updateERADropdownList();
				
			} else {
				eraSetupView.myNotificationBar.showError("Era Failed to be Created");	
			}
			
		}
	}
}