package Controller {
	
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Media;
	import Model.Transactions.Transaction_CopyAccess;
	
	import View.NewAsset;
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	
	public class NewAssetController extends AppController {
		
		private var uploadFile:FileReference;
		private var chosenFile:Boolean = false;
		private var _validUpload:Boolean = false;
		private var _validMeta:Boolean = false;
		private var file:FileReference;
		
		private var assetID:Number; // THe ID of the asset after we have finished uploading
		
		//Calls the superclass
		public function NewAssetController() {
			view = new NewAsset();
			super();
		}
		
		//INIT
		override public function init():void {
			setupEventListeners();
			setupNavbar();
		}
		
		// Setup specific event listeners
		private function setupEventListeners():void {
			(view as NewAsset).uploadForm.addEventListener(IDEvent.UPLOAD_CLICKED,uploadClicked);
			(view as NewAsset).navbar.addEventListener(IDEvent.NAV_CLICKED,navBarClicked);
			(view as NewAsset).uploadForm.addEventListener(IDEvent.FORM_CHANGED,validate);
			(view as NewAsset).metaForm.addEventListener(IDEvent.FORM_CHANGED,validate);
		}
		
		// Setup the navigation bar
		private function setupNavbar():void {
			(view as NewAsset).navbar.addHeading("New Media Asset");
			(view as NewAsset).navbar.addButton("back","right");
			(view as NewAsset).navbar.addButton("save asset","right");
			(view as NewAsset).navbar.setButtonColour("save asset","yellow");
		}
		
		// Called when a button on the navigation bar is clicked
		private function navBarClicked(e:IDEvent):void {
			switch(e.data.buttonName) {
				case 'back':
					Dispatcher.call("browse");
					break;
				case 'save asset':
					saveAsset();
					break;
				case 'cancel':
					uploadFile.cancel();
					Dispatcher.call("browse");
					break;
			}
		}
		
		// Called when the upload area is clicked - creates the browse dialog and sets up file upload events
		private function uploadClicked(e:IDEvent):void {
			uploadFile = new FileReference();
			uploadFile.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			uploadFile.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			uploadFile.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, responseHandler);
			uploadFile.addEventListener(Event.SELECT, fileSelected);
			uploadFile.browse(AssetLookup.getFileTypes());
		}
		
		// Called as the file upload occurs 
		private function progressHandler(event:ProgressEvent):void {
			var file:FileReference = FileReference(event.target);
			update(""+Math.round(event.bytesLoaded/event.bytesTotal*100));
			trace(+Math.round(event.bytesLoaded/event.bytesTotal*100));
		}
		
		// Called when the file is selected
		private function fileSelected(event:Event):void {
			file = FileReference(event.target);
			chosenFile = true;
			(view as NewAsset).uploadForm.setProgress(file.name,"ready");
		}
		
		// Called when there is an issue uploading the file
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		
		// Called when the upload is finished
		private function responseHandler( e:DataEvent ) :void {
			// Get out the XML data from the Mediaflux response
			var xml:XML = XML(e.data);
//			trace("- Upload Finished, response", e);
//			trace("response2 ", xml.reply.@type);
			if(xml.reply.@type == "result") {
				// The file upload correctly,
				// sets it as a 'media' type
				// and set this user to be the owner
				AppModel.getInstance().setMediaClass(e);
				// Get out the new assets ID
				assetID = xml.reply.result.id;
				
				trace("NewAssetController:uploadComplete - New Asset created", assetID);
				
				// Set the Owner ACLs for the asset
				AppModel.getInstance().changeAccess(assetID, Auth.getInstance().getUsername(), "system", SharingPanel.READWRITE, false, creatorAccessSaved);
			} else {
				trace("NewAssetController:uploadComplete - Failed to creator asset", e);
				Alert.show("Failed to upload file");
				Dispatcher.call('browse');
			}
		}
		
		private function creatorAccessSaved(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("NewAssetController:creatorAccessSaved - Failed to give creator access", e.target.data);
			}
			
			// Add this new asset, to whatever the current collection is
			// Provided its not All Assets or Shared Assets, since they are smart collections
			// And assets appear in them authomatically.
			if(BrowserController.currentCollectionID != BrowserController.ALLASSETID &&
				BrowserController.currentCollectionID != BrowserController.SHAREDID) {
				
				// Create a shell asset for the new asset
				var newAsset:Model_Media = new Model_Media();
				newAsset.base_asset_id = assetID;
				
				// Add it to the current collections assets
				BrowserController.currentCollectionAssets.push(newAsset);
				trace("Adding new asset", assetID  ,"to collection", BrowserController.currentCollectionID,
					BrowserController.currentCollectionTitle, "and saving"); 
				
				// Save it in the collection
				AppModel.getInstance().saveCollection(
					BrowserController.currentCollectionID, 
					BrowserController.currentCollectionTitle, 
					BrowserController.currentCollectionAssets, 
					function(collectionID:Number):void {
						trace("NewAssetController:creatorAccessSaved - Collection Updated", collectionID);
						assetSaved();
					}
				);
				
			} else {
				flash.utils.setTimeout(assetSaved,200);
			}
		}
		// Called when the save media asset button is clicked
		private function saveAsset():void {
			if(validate()) {
				saveAssetDetails();
			} else {
				Alert.show("Please enter in required information");
			}
		}
		
		// Makes sure all required information is completed
		private function validate(e:IDEvent=null):Boolean {
			_validUpload = (view as NewAsset).uploadForm.validate();
			_validMeta = (view as NewAsset).metaForm.validate();
			var valid:Boolean = true;
			if(_validUpload && _validMeta) {
				(view as NewAsset).navbar.setButtonColour("save asset","green");
				valid = true;
			} else {
				(view as NewAsset).navbar.setButtonColour("save asset","yellow");
				valid = false;
			}
			return valid;
		}
		
		// Locks the view so the user can't break the upload
		private function lock():void {
			(view as NewAsset).metaForm.lock();
			(view as NewAsset).uploadForm.lock();
			(view as NewAsset).navbar.removeButton("back");
			(view as NewAsset).navbar.addButton("cancel","right");
			(view as NewAsset).navbar.changeButtonName("save asset","saving");
		}
		
		// Gets all the data together and sends the information to the model for upload
		private function saveAssetDetails():void {
			var saved:Boolean = false;
			var dataObject:Object;
			dataObject = (view as NewAsset).metaForm.getData();
			dataObject.file = file;
			lock();
			AppModel.getInstance().startFileUpload(dataObject);
		}
		
		// Updates the file upload progress bar
		private function update(percentage:String):void {
			(view as NewAsset).uploadForm.setProgress("",percentage+"");
		}
		
		// After the file is uploaded successfully, switches the view
		public function assetSaved():void {
			trace("NewAssetController:assetSaved - Asset Saved Successfully");
			Dispatcher.call("browse");
		}
	}
}