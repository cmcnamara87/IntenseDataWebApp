package Controller.ERA
{
	import Controller.AppController;
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.Router;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERALogItem;
	import Model.Model_ERARoom;
	
	import View.ERA.CaseView;
	import View.ERA.components.EvidenceItem;
	import View.ERA.components.NotificationBar;
	
	import mx.controls.Alert;
	
	public class CaseController extends AppController
	{
		private var caseView:CaseView; // The View for the case 
		private var caseID:Number = 0; // The Mflux ID for the current case
		private var roomType:String;
		private var currentERACase:Model_ERACase = null;
		private var roomArray:Array;
		private var currentRoom:Model_ERARoom = null;
		
		public function CaseController()
		{
			// Create the View
			caseView = new CaseView();
			// Show the view
			view = caseView;
			super();
		}
		
		private function setupEventListeners():void {
			// Listen for log item being saved
			caseView.addEventListener(IDEvent.SAVE_LOG_ITEM, saveLogItem);
			// Listen for file upload
		}
		override public function init():void {
			setupEventListeners();
			getAllERACases();
		}
		
		/**
		 * Gets all the Cases for the Current ERA submission 
		 * 
		 */
		private function getAllERACases():void {
			// Get out the current ID
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
			
			
			if(currentERACase != null) {
				// We have an era case to show
				// Get out all the rooms
				AppModel.getInstance().getAllRoomsInCase(caseID, gotAllRooms);
				// so lets load all the evidence for it
				// so lets show the evidence management view
				caseView.showEvidenceManagement(null);
			}
			// If the era case is emtpy, its going to display "no cases found"
			caseView.addCases(eraCaseArray);
			
		}
		private function gotAllRooms(status:Boolean, eraRoomArray:Array):void {
			if(status) {
				layout.notificationBar.showGood("got rooms");
				this.roomArray = eraRoomArray;
				currentRoom = this.getRoomIndex(roomType);
				loadRoomContents();
				
				
			} else {
				layout.notificationBar.showError("failed to get rooms");
			}
				
		}
		
		private function loadRoomContents():void {
			switch(roomType) {
				case Model_ERARoom.EVIDENCE_MANAGEMENT:
					AppModel.getInstance().getAllERALogItemsInRoom(currentRoom.base_asset_id, gotAllLogItems);
					break;
				default:
					break;
			}
		}
		private function gotAllLogItems(status:Boolean, logItemArray:Array):void {
			caseView.showEvidenceManagement(logItemArray);
		}
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
			
			AppModel.getInstance().createERALogItem(currentRoom.base_asset_id, type, title, description, evidenceItem, logItemSaved);
		}
		private function logItemSaved(status:Boolean, logItem:Model_ERALogItem=null, evidenceItem:EvidenceItem=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to save evidence item");
				return;
			}
			
			layout.notificationBar.showGood("Evidence Item saved");
			evidenceItem.addLogItemData(logItem);
		}
		
		private function startFileUpload():void {
//			dataObject = (view as NewAsset).metaForm.getData();
//			dataObject.file = file;
//			lock();
//			AppModel.getInstance().startFileUpload(dataObject);
		}
		
		private function getRoomIndex(roomType:String):Model_ERARoom {
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