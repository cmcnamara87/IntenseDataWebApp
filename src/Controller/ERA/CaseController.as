package Controller.ERA
{
	import Controller.AppController;
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAFile;
	import Model.Model_ERALogItem;
	import Model.Model_ERAProject;
	import Model.Model_ERARoom;
	import Model.Model_ERAUser;
	
	import View.ERA.CaseView;
	import View.ERA.NoERAFound;
	import View.ERA.components.EvidenceItem;
	import View.ERA.components.NotificationBar;
	
	import flash.events.Event;
	import flash.net.FileReference;
	
	import mx.controls.Alert;
	import mx.events.IndexChangedEvent;
	
	import spark.components.DropDownList;
	import spark.events.IndexChangeEvent;
	
	public class CaseController extends AppController
	{
		private var caseView:CaseView; // The View for the case 
		private var caseID:Number = 0; // The Mflux ID for the current case
		private var roomType:String;
		public static var currentERACase:Model_ERACase = null;
		private var roomArray:Array;
		private var currentRoom:Model_ERARoom = null;
		
		// setup teh users permissions for the ucrrent case
		private var isProductionManager:Boolean = false;
		private var isTeamManager:Boolean = false;
		
		public function CaseController()
		{
			// Create the View
			caseView = new CaseView();
			view = caseView;
			
			// Show the view
			if(AppController.eraProjectArray == null || AppController.eraProjectArray.length == 0) {
				view = new NoERAFound();
			}
			
			super();
		}
		
		private function setupEventListeners():void {
			// Listen for log item being saved
			caseView.addEventListener(IDEvent.ERA_SAVE_LOG_ITEM, saveLogItem);
			caseView.addEventListener(IDEvent.ERA_SAVE_FILE, saveFile);
			caseView.addEventListener(IDEvent.ERA_DELETE_LOG_ITEM, deleteLogItem);
			
			caseView.addEventListener(IDEvent.ERA_UPDATE_LOG, updateLog);
			// Listen for era being changed
			caseView.caseERADropdown.addEventListener(IndexChangeEvent.CHANGE, eraChanged);
			
			// Listen for changing to the evidence manager
			caseView.addEventListener(IDEvent.ERA_SHOW_EVIDENCE_MANAGEMENT, showEvidenceManagement);				
			// Listen for changing to the evidence box
			caseView.addEventListener(IDEvent.ERA_SHOW_EVIDENCE_BOX, showEvidenceBox);
			
			caseView.addEventListener(IDEvent.ERA_SHOW_FILE, showFile);
		}
		override public function init():void {
			layout.header.adminToolButtons.visible = false;
			layout.header.adminToolButtons.includeInLayout = false;
			layout.header.productionToolsButton.setStyle('chromeColor', '0x000000');
			
			
			if(Auth.getInstance().getPassword() == "changeme") {
				Alert.show("Please change your password. To change your password, click your username in the top right corner.", "Change your password");
			}
			
			if(AppController.eraProjectArray == null || AppController.eraProjectArray.length == 0) {
				return;
			}
			
			setupEventListeners();
			
			
			getAllERACases();
		}
		
		private function showFile(e:IDEvent):void {
			trace("got a file", e.data.fileID);
			var fileID:Number = e.data.fileID;
			trace("displatching to", "file/" + caseID + "/" + currentRoom.roomType + "/" + fileID);
			Dispatcher.call("file/" + caseID + "/" + currentRoom.roomType + "/" + fileID);
		}
		
		
		/*==================================== SHOW EVIDENCE MANAGEMENT ===========================================*/
		private function showEvidenceManagement(e:Event=null):void {
			// people who have access, are the sys admin,
			trace("its an evidence management room");
			
			
			if(Auth.getInstance().isSysAdmin() || isProductionManager || isTeamManager) {
				currentRoom = this.getRoom(Model_ERARoom.EVIDENCE_MANAGEMENT);
				trace("Access granted*******");
				
				// Change the url
				Router.getInstance().setURL("case/" + caseID + "/" + Model_ERARoom.EVIDENCE_MANAGEMENT);
				
				caseView.showEvidenceManagement(null);
				AppModel.getInstance().getAllERALogItemsInRoom(currentRoom.base_asset_id, gotAllLogItems);
			} else {
				trace("ACCESS REFUSED TO EVIDENCE MANAGER");
			}
		}
		/* ====================================== GOT ALL THE LOG ITEMS ===================================== */
		private function gotAllLogItems(status:Boolean, logItemArray:Array):void {
			caseView.showEvidenceManagement(logItemArray);
		}
		/* ====================================== END OF GOT ALL THE LOG ITEMS ===================================== */
		
		
		
		/*==================================== SHOW EVIDENCE BOX ===========================================*/
		private function showEvidenceBox(e:Event=null):void {
			if(Auth.getInstance().isSysAdmin() || isProductionManager || isTeamManager) {
				currentRoom = this.getRoom(Model_ERARoom.EVIDENCE_ROOM);
				
				// Change the url
				Router.getInstance().setURL("case/" + caseID + "/" + Model_ERARoom.EVIDENCE_ROOM);
				
				caseView.showEvidenceBox(null);
				AppModel.getInstance().getAllERAFilesInRoom(currentRoom.base_asset_id, gotAllFiles);
			} else {
				trace("ACCESS REFUSED TO EVIDENCE ROOM");
			}
		}
		private function gotAllFiles(status:Boolean, fileArray:Array):void {
			caseView.showEvidenceBox(fileArray);
		}
		/*======================================== END OF EVIDENCE BOX ========================================= */
		
		private function eraChanged(e:IndexChangeEvent):void {
			var dropdownList:DropDownList = (e.target as DropDownList);
			
			// Grab out the selected era's data
			var eraProject:Model_ERAProject = dropdownList.selectedItem.data;
			// Set it as the new current era
			currentEraProject = eraProject;
			
			// Refresh the page
			var currentURL:String = Router.getInstance().getURL();
			Dispatcher.call(currentURL);
		}
		
		
		/**
		 * Gets all the Cases for the Current ERA submission 
		 * 
		 */
		private function getAllERACases():void {
			// Get out the current for the case ID
			if(Dispatcher.getArgs().length > 0) {
				// THe case ID was given
				caseID = Dispatcher.getArgs()[0];
			} 
			if(Dispatcher.getArgs().length == 2) {
				// They room type we want to look for
				roomType = Dispatcher.getArgs()[1];
			} else {
				// No room type given, lets set it
				roomType = Model_ERARoom.EVIDENCE_MANAGEMENT;
			}
			
			// Get all the ERA cases for this ERA
			AppModel.getInstance().getAllERACases(AppController.currentEraProject.base_asset_id, gotAllERACases);
		}
		
		/**
		 * Got all the ERA cases, lets shove them into the view, and display the one we want. 
		 * @param status
		 * @param eraCaseArray	An Array of ERA cases
		 * 
		 */
		private function gotAllERACases(status:Boolean, eraCaseArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Could not retrieve any cases");
				return;
			}
			
			// did we get no cases?
			if(eraCaseArray.length == 0) {
				caseView.showNoCases();
				return;
			}
			
			if(caseID == 0) {
				// We havent been passed a case ID, so lets just default to the first case for this ERA
				if(eraCaseArray.length > 0) {
					caseID = (eraCaseArray[0] as Model_ERACase).base_asset_id;
					currentERACase = (eraCaseArray[0] as Model_ERACase);
					Router.getInstance().setURL("case/" + caseID + "/" + roomType);
				}
			} else {
				// We have been given an case ID, so lets just match it up to one of the era cases
				for each(var eraCase:Model_ERACase in eraCaseArray) {
					if(eraCase.base_asset_id == caseID) {
						currentERACase = eraCase;
						break;
					}
				}
			}
			
			// Add the cases for the view
			// If the era case is emtpy, its going to display "no cases found"
			caseView.addCases(eraCaseArray);
			
			// Just check that we found a case from all that shit up above
			if(currentERACase != null) {
				// We have the current case
				// now lets store all the permissions for the ucrrent case 
				this.readCasePermissions();

				// Get out all the rooms
				AppModel.getInstance().getAllRoomsInCase(caseID, gotAllRooms);
			}
		}
		
		private function readCasePermissions():void {
			// production manager
			isProductionManager = false;
			for each(var user:Model_ERAUser in currentERACase.productionManagerArray) {
				if(Auth.getInstance().getUsername() == user.username) {
					isProductionManager = true;
					break;
				}
			}
			
			// or production team
			isTeamManager = false;
			for each(var teamUser:Model_ERAUser in currentERACase.productionTeamArray) {
				if(Auth.getInstance().getUsername() == teamUser.username) {
					isTeamManager = true;
					break;
				}
			}
		}
		private function gotAllRooms(status:Boolean, eraRoomArray:Array):void {
			if(status) {
				// Store all the rooms
				this.roomArray = eraRoomArray;
				
				switch(roomType) {
					case Model_ERARoom.EVIDENCE_MANAGEMENT:
						this.showEvidenceManagement();
						break;
					case Model_ERARoom.EVIDENCE_ROOM:
						this.showEvidenceBox();
						break;
					default:
						break;
				}
			} else {
				layout.notificationBar.showError("No Rooms Found.");
			}
				
		}	
		
		
		
		
		
		/* ====================================== SAVE A LOG ITEM ===================================== */
		/**
		 * Saves an Evidence Item 
		 * @param e		The ID Event
		 * 
		 */
		private function saveLogItem(e:IDEvent):void {
			var type:String = e.data.type;
			var title:String = e.data.title;
			var description:String = e.data.description;
			var evidenceItem:EvidenceItem = e.data.evidenceItem;
			
			layout.notificationBar.showProcess("Saving Evidence...");
			
			AppModel.getInstance().createERALogItem(getRoom(Model_ERARoom.EVIDENCE_MANAGEMENT).base_asset_id, type, title, description, evidenceItem, logItemSaved);
		}
		private function logItemSaved(status:Boolean, logItem:Model_ERALogItem=null, evidenceItem:EvidenceItem=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to save evidence item");
				return;
			}
			
			layout.notificationBar.showGood("Evidence Item saved");
			evidenceItem.addLogItemData(logItem);
		}
		/* ====================================== END OF SAVE A LOG ITEM ===================================== */
		
		/* ====================================== DELETE A LOG ITEM ===================================== */
		private function deleteLogItem(e:IDEvent):void {
			var logItem:Model_ERALogItem = e.data.logItem;
			
			// If the log item hasnt been saved, ignore this request, since we dont need to 
			// do anything with the database @see EvidenceManagementView
			if(logItem == null) {
				return;
			}
			layout.notificationBar.showProcess("Deleting Evidence...");
			
			AppModel.getInstance().deleteERALogItem(logItem, logItemDeleted);
		}
		private function logItemDeleted(status:Boolean, logItemDeleted:Model_ERALogItem=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to delete evidence");
				return;
			}
			layout.notificationBar.showGood("Evidence Deleted");
			caseView.deleteEvidenceItem(logItemDeleted);
		}
		/* ====================================== END OF DELETE A LOG ITEM ===================================== */
		
		/* ====================================== UPDATE A LOG ITEM ===================================== */
		private function updateLog(e:IDEvent):void {
			// get out the log item
//			AppModel.getInstance().addRoleToERAUser(/
			var logItemID:Number = e.data.logItemID;
			var elementName:String = e.data.elementName;
			var value:Boolean = e.data.value;
			var evidenceItem:EvidenceItem = e.data.evidenceItem;
			
			AppModel.getInstance().updateLogItemBooleanValue(logItemID, elementName, value, evidenceItem, logItemUpdated);
			
//			AppModel.getInstance().updateERALogItem();
		}
		private function logItemUpdated(status:Boolean, logItem:Model_ERALogItem=null, evidenceItem:EvidenceItem=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to save evidence item");
				return;
			}
			
			layout.notificationBar.showGood("Evidence Item Updated");
			evidenceItem.addLogItemData(logItem);
		}
		/* ====================================== END OF UPDATE A LOG ITEM ===================================== */
		
		/* ====================================== SAVE A FILE ===================================== */
		private function saveFile(e:IDEvent):void {
			var file:FileReference = e.data.fileReference;
			var evidenceItem:EvidenceItem = e.data.evidenceItem;
			var type:String = e.data.type;
			var title:String = e.data.title;
			var description:String = e.data.description;
			var logItemID:Number = e.data.logItemID;
			
			layout.notificationBar.showProcess("Uploading file...");
			
			AppModel.getInstance().uploadERAFile(getRoom(Model_ERARoom.EVIDENCE_ROOM).base_asset_id, logItemID, type, title, description, file, evidenceItem, uploadIOError, uploadProgress, uploadComplete); 
		}
		private function uploadIOError():void {
			layout.notificationBar.showError("Failed to Upload file.");
		}
		private function uploadProgress(percentage:Number, evidenceItem:EvidenceItem):void {
			evidenceItem.showProgress(percentage);
		}
		private function uploadComplete(status:Boolean, eraEvidence:Model_ERAFile=null, evidenceItem:EvidenceItem=null):void {
			if(status) {
				layout.notificationBar.showGood("Upload Complete");
				evidenceItem.showComplete(eraEvidence);
			} else {
				Alert.show("Upload failed");
			}
		}
		/* ====================================== END OF SAVE A FILE ===================================== */
		
		
		private function getRoom(roomType:String):Model_ERARoom {
			for(var i:Number = 0; i < roomArray.length; i++) {
				var room:Model_ERARoom = (roomArray[i] as Model_ERARoom);
				trace("room type", room.roomType);
				if(room.roomType == roomType) {
					return room;
				}
			}
			return null;
		}
	}
}