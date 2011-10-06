package Controller.ERA.Admin
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	
	import View.ERA.ERAEditionManagerView;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;

	public class ERASetupController extends AppController
	{
		private var eraSetupView:ERAEditionManagerView = new ERAEditionManagerView();
		
		public function ERASetupController()
		{
			view = eraSetupView;
			super();
		}
		
		override public function init():void {
			// Make the era management button darker
			layout.header.unhighlightAllButtons();
			layout.header.newERAButton.setStyle("chromeColor", "0x000000");
			layout.header.adminToolsButton.setStyle("chromeColor", "0x000000");
			
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
		
		/* ========================================== DELETING AN ERA ========================================== */
		/**
		 * The delete button was clicked. Delete the ERA
		 * @param e
		 * 
		 */		
		private function deleteButtonClicked(e:MouseEvent):void {
			if(eraSetupView.eras.selectedIndex == -1) {
				return;
			}
			
			var myAlert:Alert = Alert.show(
				"Are you sure you wish to delete ERA Edition", "Delete ERA Edition", Alert.OK | Alert.CANCEL, null, function(e:CloseEvent):void {
					if (e.detail==Alert.OK) {
						layout.notificationBar.showProcess("Deleting ERA Edition");
						AppModel.getInstance().deleteERAProject(eraSetupView.eras.selectedItem.data, eraDeleted);
					}
				}, null, Alert.CANCEL);
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
		/* ========================================== END OF DELETING AN ERA ========================================== */
		
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
		
		
		/* ========================================== SAVING UPDATES TO AN ERA ========================================== */
		/**
		 * The save updated version of the era has been clicked. 
		 * @param e
		 * 
		 */
		private function saveButtonClicked(e:MouseEvent):void {
			layout.notificationBar.showProcess("Updating ERA");
			
			// Some basic validation stuff
			if(!inputsValid()) {
				return;
			}
			
			
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
				layout.notificationBar.showGood("ERA Edition Updated");
				eraSetupView.addERAProjects(AppController.eraProjectArray);
				AppController.updateERADropdownList();
			} else {
				eraSetupView.myNotificationBar.showError("Era Failed to be Created");	
			}
		}
		/* ========================================== END OF SAVING UPDATES TO AN ERA ========================================== */
		
		
		private function inputsValid():Boolean {
			if(eraSetupView.day.selectedIndex == -1) {
				layout.notificationBar.showError("Please select a day");
				return false;
			}
			
			if(eraSetupView.month.selectedIndex == -1) {
				layout.notificationBar.showError("Please select a month");
				return false;
			}
			
			if(eraSetupView.year.selectedIndex == -1) {
				layout.notificationBar.showError("Please select a month");
				return false;
			}
			
			if( eraSetupView.packageSize.text == "") {
				layout.notificationBar.showError("Please enter a package size");
				return false;
			}
			var packageSizeNumber:Number = Number(eraSetupView.packageSize.text);
			if(packageSizeNumber == 0 && eraSetupView.packageSize.text != "0") {
				layout.notificationBar.showError("Please enter a package size as a number.");
				return false;
			}
			
			return true;
		}
		
		
		/* ========================================== CREATE AN ERA ========================================== */
		private function createButtonClicked(e:MouseEvent):void {
			// Some basic validation stuff
			if(!inputsValid()) {
				return;
			}
			
			// check that we dont already have an era for that year
			for each(var era:Model_ERAProject in AppController.eraProjectArray) {
				if(era.year == eraSetupView.year.selectedItem) {
					layout.notificationBar.showError("An ERA Edition for this year already exists");
					return;
				}
			} 
			
			
			var eraDay:String = eraSetupView.day.selectedItem;
			
			
			var eraMonth:String = eraSetupView.month.selectedItem;
			
			
			var eraYear:String = eraSetupView.year.selectedItem;
			
			var packageSize:String = eraSetupView.packageSize.text;

			// Lets make the due date
			layout.notificationBar.showProcess("Saving ERA");
				
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
				layout.notificationBar.showGood("Era Created");
				
				eraSetupView.addERAProjects(AppController.eraProjectArray);
				AppController.updateERADropdownList();
				
			} else {
				eraSetupView.myNotificationBar.showError("Era Failed to be Created");	
			}
		}
		/* ========================================== END OF CREATE AN ERA ========================================== */
	}
	
}