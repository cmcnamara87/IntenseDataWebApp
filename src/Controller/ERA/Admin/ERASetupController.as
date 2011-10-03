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
			// Listen for new eras being created
			eraSetupView.createButton.addEventListener(MouseEvent.CLICK, createButtonClicked);
			// Listen for old eras being updated
			eraSetupView.saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			// Listen for delete being called
			eraSetupView.deleteERAButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked);
			
			
			
			// Add the current erap rojects to the view
			eraSetupView.addERAProjects(AppController.eraProjectArray);
			
			// Listen for change in ERA list
			eraSetupView.eras.addEventListener(IndexChangeEvent.CARET_CHANGE, eraChanged);
		}
		
		/**
		 * The delete button was clicked. Delete the ERA
		 * @param e
		 * 
		 */
		private function deleteButtonClicked(e:MouseEvent):void {
			layout.notificationBar.showProcess("Updating ERA");
			var packageSize:String = eraSetupView.packageSize.text;
			AppModel.getInstance().deleteERAProject(eraSetupView.eras.selectedItem.data, eraDeleted);
		}
		/**
		 * The ERA was deleted 
		 * @param status
		 * @param deletedERAID
		 * 
		 */		
		private function eraDeleted(status:Boolean, deletedERAID:Number=0):void {
			if(!status) {
				eraSetupView.myNotificationBar.showError("Failed to delete ERA");
				return;
			}
		
			// Remove the deleted era from the list of era projects
			for(var i:Number = 0; i < AppController.eraProjectArray.length; i++) {
				var eraProject:Model_ERAProject = AppController.eraProjectArray[i] as Model_ERAProject;
				if(eraProject.base_asset_id == deletedERAID) {
					AppController.eraProjectArray.splice(i, 1);
					break;
				}
			}
			// show conformation
			layout.notificationBar.showGood("Era Deleted");
			// update the era projects being displayed in the era setup view
			eraSetupView.addERAProjects(AppController.eraProjectArray);
			// and update the global era project dropdown
			AppController.updateERADropdownList();	
			
		}
		
		private function eraChanged(e:IndexChangeEvent):void {
			try {
				trace("ERA CHANGED", DropDownList(e.target).selectedItem.data);
				var selectedEraID:Number = DropDownList(e.target).selectedItem.data;
				for each(var eraProject:Model_ERAProject in eraProjectArray) {
					if(eraProject.base_asset_id == selectedEraID) {
						eraSetupView.addERAProject(eraProject);
						break;
					}
				}
			} catch(e:Error) {
				trace("***** ERA CHANGE ERROR");
			}
		}
		
		/**
		 * The save updated version of the era has been clicked. 
		 * @param e
		 * 
		 */
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
		
		/**
		 * The ERA has been updated 
		 * @param status
		 * @param data
		 * 
		 */
		private function eraUpdated(status:Boolean, data:Model_ERAProject):void {
			if(status) {
				AppController.currentEraProject = data;
				
				// Find an removed the old version of the era
				for(var i:Number = 0; i < AppController.eraProjectArray.length; i++) {
					var eraProject:Model_ERAProject = AppController.eraProjectArray[i] as Model_ERAProject;
					if(eraProject.base_asset_id == data.base_asset_id) {
						AppController.eraProjectArray.splice(i, 1);
						trace("**** OLD ERA BEING REMOVED ***");
						break;
					}
				}
				// Add the new vesrsion
				AppController.eraProjectArray.push(data);
				
				// Update the views
				layout.notificationBar.showGood("Era Created");
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