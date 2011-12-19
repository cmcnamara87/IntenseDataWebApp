package Controller.ERA
{
	import Controller.AppController;
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAConversation;
	import Model.Model_ERAFile;
	import Model.Model_ERALogItem;
	import Model.Model_ERAProject;
	import Model.Model_ERARoom;
	import Model.Model_ERAUser;
	import Model.Transactions.ERAProject.Transaction_CreateAllCases;
	import Model.Transactions.ERAProject.Transaction_CreateAllResearchers;
	
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
		private var eraCaseArray:Array;
		public static var currentERACase:Model_ERACase = null;
		public static var roomArray:Array = new Array();
		private var currentRoom:Model_ERARoom = null;
		
		// setup teh users permissions for the ucrrent case
		// for other roles, see @Auth.getInstance().hasRoleForYear
		public static var isProductionManager:Boolean = false;
		private var isTeamManager:Boolean = false;
		public static var isResearcher:Boolean = false;
		
		public function CaseController()
		{
			// Create the View
			caseView = new CaseView();
			view = caseView;
			
			// Show the view
			if(AppController.eraProjectArray == null || AppController.eraProjectArray.length == 0) {
				view = new NoERAFound();
			}
		
//			var test:Transaction_CreateAllResearchers = new Transaction_CreateAllResearchers();
			
//			var test:Transaction_CreateAllCases = new Transaction_CreateAllCases();
			
			super();
		}
		
		private function setupEventListeners():void {
			// Listen for log item being saved
			caseView.addEventListener(IDEvent.ERA_SAVE_LOG_ITEM, saveLogItem, false, 0, true);
			caseView.addEventListener(IDEvent.ERA_SAVE_FILE, saveFile, false, 0, true);
			caseView.addEventListener(IDEvent.ERA_DELETE_LOG_ITEM, deleteLogItem, false, 0, true);
			
			caseView.addEventListener(IDEvent.ERA_UPDATE_LOG, updateLog, false, 0, true);
			// Listen for era being changed
			caseView.caseERADropdown.addEventListener(IndexChangeEvent.CHANGE, eraChanged, false, 0, true);
			
			// Listen for changing to the evidence manager
			caseView.addEventListener(IDEvent.ERA_SHOW_EVIDENCE_MANAGEMENT, showEvidenceManagement, false, 0, true);				
			// Listen for changing to the evidence box
			caseView.addEventListener(IDEvent.ERA_SHOW_EVIDENCE_BOX, showEvidenceBox, false, 0, true);
			// Listen for changing to the forensic lab
			caseView.addEventListener(IDEvent.ERA_SHOW_FORENSIC_LAB, showForensicLab, false, 0, true);
			caseView.addEventListener(IDEvent.ERA_SHOW_SCREENING_LAB, showScreeningLab, false, 0, true);
			caseView.addEventListener(IDEvent.ERA_SHOW_EXHIBITION, showExhibition, false, 0, true);
			
			// Show one of the files
			caseView.addEventListener(IDEvent.ERA_SHOW_FILE, showFile, false, 0, true);
			
			// Move files between the different rooms
			caseView.addEventListener(IDEvent.ERA_MOVE_FILE, moveFile, false, 0, true);
			
			// Change the temperature of the file
			caseView.addEventListener(IDEvent.ERA_CHANGE_FILE_TEMPERATURE, changeTemperature, false, 0, true);
			
			// Listne for comment creation
			caseView.addEventListener(IDEvent.ERA_SAVE_COMMENT, saveComment, false, 0, true);
			
			// Listen for errors to show
			caseView.addEventListener(IDEvent.ERA_ERROR, function(e:IDEvent):void {
				layout.notificationBar.showError(e.data.error);
			}, false, 0, true);
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
			var roomType:String = "";
			if(e.data.roomType) {
				roomType = e.data.roomType;
			} else {
				roomType = currentRoom.roomType;
			} 
			
//			trace("displatching to", "file/" + caseID + "/" + escape(currentERACase.rmCode) + "/" + roomType + "/" + fileID);
			Dispatcher.showFile(caseID, currentERACase.rmCode, roomType, currentRoom.base_asset_id, fileID);
		}
		
		/* ======================================= MOVE FILE TO DIFFERENT ROOM ======================================= */
		private function moveFile(e:IDEvent):void {
			var fileID:Number = e.data.fileID;
			trace('move file id is', fileID);
			// move from and to
			var moveToRoomType = e.data.moveToRoomType;
			trace('move to room type', moveToRoomType);
			
			AppModel.getInstance().moveERAFile(fileID, currentRoom.base_asset_id, getRoom(moveToRoomType).base_asset_id, moveToRoomType, fileMoved);

			// if the file is a hot file, we need to descrease the number of hot files i nthe room
			// its going to be hot for every room, except the forensic lab inactive section
			if(e.data.hot) {
				caseView.changeRoomEvidenceCount(currentRoom.roomType, false);
			}
		}
		private function fileMoved(status:Boolean):void {
			if(status) {
				layout.notificationBar.showGood("File Moved");
				// tell the view to update its icons
			} else {
				layout.notificationBar.showError("Failed to Move File");
			}
		}
		/* ======================================== END OF MOVE FILE TO DIFFERENT ROOM =============================== */
		private function changeTemperature(e:IDEvent):void {
			var fileID:Number = e.data.fileID;
			var hot:Boolean = e.data.hot;
			
			trace("file is for change is", fileID);
			AppModel.getInstance().updateERAFileTemperature(fileID, hot, temperatureChanged);
			if(hot) {
				caseView.changeRoomEvidenceCount(currentRoom.roomType, true);
			} else {
				caseView.changeRoomEvidenceCount(currentRoom.roomType, false);
			}
		}
		private function temperatureChanged(status:Boolean):void {
			if(!status) {
				layout.notificationBar.showError("Failed to Changed Activity Level");
			}
		}
		
		private function saveComment(e:IDEvent):void {
			var text:String = e.data.text;
			var replyToID:Number = e.data.replyToID;
			
			AppModel.getInstance().createERAConversation(currentRoom.base_asset_id, currentRoom.base_asset_id, replyToID, text, commentSaved);
		}
		private function commentSaved(status:Boolean, comment:Model_ERAConversation):void {
			
		}
		/*==================================== SHOW EVIDENCE MANAGEMENT ===========================================*/
		private function showEvidenceManagement(e:Event=null):void {
			// people who have access, are the sys admin,
			trace("its an evidence management room");
			
			
			if(Auth.getInstance().isSysAdmin() || isProductionManager || isTeamManager) {
				currentRoom = getRoom(Model_ERARoom.EVIDENCE_MANAGEMENT);
				if(!currentRoom) return;
				trace("Access granted*******");
				
				// Change the url
				Router.getInstance().setURL("case/" + caseID + "/" + Model_ERARoom.EVIDENCE_MANAGEMENT);
				
				caseView.showEvidenceManagement(null);
				AppModel.getInstance().getAllERALogItemsInRoom(currentRoom.base_asset_id, gotAllLogItems);
				
				
			} else {
				caseView.showAccessDenied("Sorry, Evidence Management can only be accessed by the System Administrator or Production Team");
			}
		}
		/* ====================================== GOT ALL THE LOG ITEMS ===================================== */
		private function gotAllLogItems(status:Boolean, logItemArray:Array):void {
			if(!caseView) return;
			caseView.showEvidenceManagement(logItemArray);
			
		}
		/* ====================================== END OF GOT ALL THE LOG ITEMS ===================================== */
		
		
		/*==================================== SHOW FORENSIC LAB ===========================================*/
		private function showForensicLab(e:Event=null):void {
			// @todo add use permission checking
			if(!caseView) return;
			
			if(!(Auth.getInstance().isSysAdmin() || isProductionManager || isTeamManager)) {
				caseView.showAccessDenied("Sorry, the Forensic Lab can only be accessed by the System Administrator or Production Team");
				return;
			}
			
			currentRoom = getRoom(Model_ERARoom.FORENSIC_LAB);
			if(!currentRoom) return;
			
			// Change the url
			Router.getInstance().setURL("case/" + caseID + "/" + Model_ERARoom.FORENSIC_LAB);
			
			caseView.showForensicLab(null);
			AppModel.getInstance().getAllERAFilesInRoom(currentRoom.base_asset_id, gotAllForensicLabFiles);
			
			AppModel.getInstance().getAllConversationOnOject(currentRoom.base_asset_id, currentRoom.base_asset_id, forensicLabCommentsRetrieved);
		}
		private function gotAllForensicLabFiles(status:Boolean, fileArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get forensic lab files");
				return;
			}
			caseView.showForensicLab(fileArray);
		}
		private function forensicLabCommentsRetrieved(status:Boolean, commentArray:Array):void {
			caseView.addForensicLabConversation(commentArray);
		}
		/*==================================== END OF SHOW FORENSIC LAB ===========================================*/
		
		
		private function showExhibition(e:Event=null):void {
			if(!caseView) return;
			
			if(!(Auth.getInstance().isSysAdmin() || isProductionManager 
				|| Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year))) {
				caseView.showAccessDenied("Sorry, the Exhibition can only be accessed by the System Administrator, Production Manager or Monitor.");
				return;
			}
			
			currentRoom = getRoom(Model_ERARoom.EXHIBIT);
			
			// Change the url
			Router.getInstance().setURL("case/" + caseID + "/" + Model_ERARoom.EXHIBIT);
			
			// Show the screening lab
			caseView.showExhibition(null);
			// Get all the files in the screening lab
			AppModel.getInstance().getAllERAFilesInRoom(currentRoom.base_asset_id, gotExhibitionFiles);
		}
		private function gotExhibitionFiles(status:Boolean, fileArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get forensic lab files");
				return;
			}
			caseView.showExhibition(fileArray);
		}
		/*==================================== SHOW SCREENING BOX ===========================================*/
		private function showScreeningLab(e:Event=null):void {
			
			if(!caseView) return;
			
			if(!(Auth.getInstance().isSysAdmin() || isProductionManager || isResearcher 
				|| Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year))) {
				caseView.showAccessDenied("Sorry, the Screening Lab can only be accessed by the System Administrator, Production Manager, Researcher or Monitor");
				return;
			}
			
			
			currentRoom = getRoom(Model_ERARoom.SCREENING_ROOM);
			
			// Change the url
			Router.getInstance().setURL("case/" + caseID + "/" + Model_ERARoom.SCREENING_ROOM);
			
			// Show the screening lab
			caseView.showScreeningLab(null);
			try {
			// Get all the files in the screening lab
			AppModel.getInstance().getAllERAFilesInRoom(currentRoom.base_asset_id, gotAllScreeningLabFiles);
			// get all the conversation for the screening lab
			AppModel.getInstance().getAllConversationOnOject(currentRoom.base_asset_id, currentRoom.base_asset_id, screeningLabCommentsRetrieved);
			} catch (e:Error) {
				trace("BIG ERROR HERE!!!!!!!!!!!");
			}
		}
		private function gotAllScreeningLabFiles(status:Boolean, fileArray:Array):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get forensic lab files");
				return;
			}
			caseView.showScreeningLab(fileArray);
		}
		private function screeningLabCommentsRetrieved(status:Boolean, conversationArray:Array=null):void {
			if(!status) {
				// failed to get comments
				layout.notificationBar.showError("Failed to get conversation");
				return;
			}
			
			// Add the comments to the view
			caseView.addScreeningLabConversation(conversationArray);

		}
		/*==================================== END OF SHOW SCREENING BOX ===========================================*/
		
		
		/*==================================== SHOW EVIDENCE BOX ===========================================*/
		private function showEvidenceBox(e:Event=null):void {
			if(!caseView) return;
			
			if(!(Auth.getInstance().isSysAdmin() || isProductionManager || isTeamManager || isResearcher 
				|| Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year))) {
				caseView.showAccessDenied("Sorry, the Evidence Box can only be accessed by the System Administrator, Production Team, Researcher, and Monitor");
				return;
			}
			
			
			currentRoom = getRoom(Model_ERARoom.EVIDENCE_ROOM);
			
			// Change the url
			Router.getInstance().setURL("case/" + caseID + "/" + Model_ERARoom.EVIDENCE_ROOM);
			
			caseView.showEvidenceBox(null);
			AppModel.getInstance().getAllERAFilesInRoom(currentRoom.base_asset_id, gotAllEvidenceRoomFiles);

		}
		private function gotAllEvidenceRoomFiles(status:Boolean, fileArray:Array):void {
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
			
			if(!caseView) return;
			
			
			this.eraCaseArray = eraCaseArray;
			
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
			// check incase we have been dealloced
			if(caseView) {
				caseView.addCases(eraCaseArray);	
			}
			
			
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
			
			isResearcher = false;
			for each(var teamUser:Model_ERAUser in currentERACase.researchersArray) {
				if(Auth.getInstance().getUsername() == teamUser.username) {
					isResearcher = true;
					break;
				}
			}
			
		}
		private function gotAllRooms(status:Boolean, eraRoomArray:Array):void {
			if(status) {
				// Store all the rooms
				roomArray = eraRoomArray;
				
				// Add give the room data to the view
				caseView.addRoomData(eraRoomArray);
				
				switch(roomType) {
					case Model_ERARoom.EVIDENCE_MANAGEMENT:
						this.showEvidenceManagement();
						break;
					case Model_ERARoom.EVIDENCE_ROOM:
						this.showEvidenceBox();
						break;
					case Model_ERARoom.FORENSIC_LAB:
						this.showForensicLab();
						break;
					case Model_ERARoom.SCREENING_ROOM:
						this.showScreeningLab();
						break;
					case Model_ERARoom.EXHIBIT:
						this.showExhibition();
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
			
			AppModel.getInstance().updateLogItemBooleanValue(AppController.currentEraProject.year, currentRoom.base_asset_id, logItemID, elementName, value, evidenceItem, logItemUpdated);
			
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
			var version:Number = e.data.version;
			var logItemID:Number = e.data.logItemID;
			
			layout.notificationBar.showProcess("Uploading file...");
			
			// get out the room IDs
			trace("ROOM IDS ARE: EVIDNECE ROOM", getRoom(Model_ERARoom.EVIDENCE_ROOM).base_asset_id, "FORENSIC LAB", getRoom(Model_ERARoom.FORENSIC_LAB).base_asset_id);
			
			AppModel.getInstance().uploadERAFile(getRoom(Model_ERARoom.EVIDENCE_ROOM).base_asset_id, getRoom(Model_ERARoom.FORENSIC_LAB).base_asset_id, logItemID, type, title, description, version, file, evidenceItem, uploadIOError, AppController.layout.allProgressEvents, AppController.layout.allCompleteEvents);
			
			caseView.forensicLabButton.increaseEvidenceCount();
			caseView.evidenceBoxButton.increaseEvidenceCount();
		}
		private function uploadIOError():void {
			layout.notificationBar.showError("Failed to Upload file.");
		}
		
		public static function uploadProgress(percentage:Number, evidenceItem:EvidenceItem):void {
			// is the current room the evidence management room?
			
			
		}

//		private function uploadComplete(status:Boolean, eraEvidence:Model_ERAFile=null, evidenceItem:EvidenceItem=null):void {
//			if(status) {
//				layout.notificationBar.showGood("Upload Complete");
//				evidenceItem.showComplete(eraEvidence);
//			} else {
//				Alert.show("Upload failed");
//			}
//		}
		/* ====================================== END OF SAVE A FILE ===================================== */
		
		
		public static function getRoom(roomType:String):Model_ERARoom {
			for(var i:Number = 0; i < roomArray.length; i++) {
				var room:Model_ERARoom = (roomArray[i] as Model_ERARoom);
				if(room.roomType == roomType) {
					return room;
				}
			}
			return null;
		}
		
		//When the controller is destroyed/switched
		override public function dealloc():void {
			caseView = null; 
			caseID = null;
			roomType = null;
			currentRoom = null;
			
			eraCaseArray = null;
			
			super.dealloc();
		}
	}
}