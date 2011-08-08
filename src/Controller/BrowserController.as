package Controller {
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import Lib.LoadingAnimation.LoadAnim;
	
	import Model.AppModel;
	import Model.Model_Collection;
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import View.Browser;
	import View.BrowserView;
	import View.Element.SmallButton;
	import View.components.Panels.Comments.NewComment;
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	public class BrowserController extends AppController {
		
		
		public static const PORTAL:String = "View";
		
		private var collectionToDelete:Number = 0;
		//private var addButton:SmallButton;
		
		private static var editOn:Boolean = false; // stores whether or not we are in edit mode (e.g editing a collection)
		private static var shelfOn:Boolean = false; // stores whether the shelf is enabled
		
		public static var currentCollectionAssets:Array = new Array();// Stores all the assets that are in the current collection.
		private static var shelfAssets:Array = new Array(); 	// stores all the assets that are currently in the shelf
															// is static so it is persistant when we go to view an asset etc
		
		private static var editAssets:Array = new Array();	// Stores all the assets for the current collection we are viewing
															// So when we switch into edit mode, they are already there.
															// It is also where we edit/remove things from, when editing a collection.
		private static var collectionBeingEditedID:Number; 	// The ID of the collection being edited.
		
		private var modifyAccess:Boolean = true;
		
		public static var collectionData:Model_Collection;
		
		public static var currentCollectionID:Number = ALLASSETID; //1576; //ALLASSETID; //1492; //ALLASSETID;	// Stores the ID for the current collection we are viewing
		public static var currentCollectionTitle:String = ""; // The title of the current collection we are looking at
		public static var editCollectionName:String = ""; // The title of the current collection we are editing
		
		public static const ALLASSETID:Number = -1; // since these dont have actually Collection IDs
		public static const SHAREDID:Number = -2;   // we just make some up
		public static const SHELFID:Number = -3;
		
		
		private static var cachedCollectionMedia:Array = new Array(); 
		private static var cachedCollections:Event;
		
		private static var collectionTimer:Timer = new Timer(20000);
		
		public static var currentMediaData:Model_Media = null;
		
		//Calls the superclass
		public function BrowserController() {
			trace("--- Creating Browser Controller ---");
			view = new Browser();
			resetShelf();
			super();
			
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			currentView.addEventListener(Event.REMOVED_FROM_STAGE, stopTimerPlease);
			currentView.addEventListener(FlexEvent.HIDE, stopTimerPlease );
		}

		public function stopTimerPlease(e:Event):void {
			trace("Stoping view refresh timer");
			collectionTimer.removeEventListener(TimerEvent.TIMER, refreshCollectionList);
		}
		
		/**
		 * Resets the browser's variables. Used when a user logs out. 
		 */				
		public static function resetBrowserController():void {
			collectionTimer.stop();
			editOn = false;
			shelfOn = false;
			currentCollectionAssets = new Array();
			shelfAssets = new Array();
			editAssets = new Array();
			collectionBeingEditedID = -1;
			currentCollectionID = ALLASSETID;
			cachedCollectionMedia = new Array();
			cachedCollections = null;
		}
		
		
		private function resetShelf():void {
			// Turn editing and collection creation off
			editOn = false;
			shelfOn = false;
			// Clear anything we might have saved
			currentCollectionAssets = new Array();
			editAssets = new Array();
		}
		
		//INIT
		override public function init():void {
			setupEventListeners();
			
			// Reload any assets that are already in the shelf
			// Obviously there are none there when we start
			// but this is for when we come back from viewing an asset etc
			reAddAssetsToShelf();
			
			
			// Load the collections for the sidebar
			loadAllMyCollections();
			collectionTimer.addEventListener(TimerEvent.TIMER, refreshCollectionList);
			collectionTimer.start();
//			refreshCollectionList();
			
			// Load the appropriate assets for whatever
			// collection we have selected when this runs (not just All Assets
			// because we could be coming back from an asset and we
			// want to return the collection we were previously in)
			switch(currentCollectionID) {
				case BrowserController.ALLASSETID:
					loadAllMyMedia();
					break;
				case BrowserController.SHAREDID:
					loadShared();
					break;
				default:
					loadAssetsInCollection(currentCollectionID);
			}
		}
		
		private function refreshCollectionList(e:TimerEvent):void {
			trace("Refreshing collection list");
			//loadAllMyCollections();
		}
		
		// Sets up all the event listeners
		private function setupEventListeners():void {
			// Asset Browser
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Listen for Create Collection Button being clicked.
			currentView.addEventListener(IDEvent.SHELF_CLICKED, newCollectionButtonClicked);
			
			// Listen for Edit Collection button being clicked
			currentView.addEventListener(IDEvent.COLLECTION_EDIT_BUTTON_CLICKED, editButtonClicked);
			
			// Listen for Delete Collection button being clicked
			currentView.addEventListener(IDEvent.COLLECTION_DELETE_BUTTON_CLICKED, deleteButtonClicked);
			
			// Listen for Shelf Being closed (clicking the X button on the shelf);
			currentView.addEventListener(IDEvent.SHELF_CLOSE_BUTTON_CLICKED, closeShelfButtonClicked);
			
			// Listen for Media Asset being clicked inside the Asset Browser
			currentView.addEventListener(IDEvent.ASSET_BROWSER_MEDIA_CLICKED, assetBrowserMediaClicked);
			
			// Listen for Media Asset being clicked inside the Shelf
			currentView.addEventListener(IDEvent.SHELF_MEDIA_CLICKED, shelfMediaClicked);
			
			// Listen for shelf clear being clicked
			currentView.addEventListener(IDEvent.SHELF_CLEAR_BUTTON_CLICKED, shelfClearClicked);
			// Listen for Collection Asset being clicked
			currentView.addEventListener(IDEvent.ASSET_COLLECTION_CLICKED, assetCollectionClicked);
			
			// Listen for All Assets being clicked
			currentView.addEventListener(IDEvent.ASSET_COLLECTION_ALL_MEDIA, showAllAssetsClicked);
			
			// Listen for Shared With Me (collecion tab) being clicked
			currentView.addEventListener(IDEvent.ASSET_COLLECTION_SHARED_WITH_ME, showSharedWithMeClicked);
			
			// Listen for Shelf (collection tab) being clicked
//			currentView.addEventListener(RecensioEvent.ASSET_COLLECTION_SHELF, showShelfCollectionClicked);
			
			// Listen for Shelf Being Saved to a COllection
			currentView.addEventListener(IDEvent.COLLECTION_SAVE, saveCollection);
			
			// Listen for "Save Comment" button being clicked.
			currentView.addEventListener(IDEvent.COMMENT_SAVED, saveComment);
			
			currentView.addEventListener(IDEvent.COMMENT_DELETE, deleteComment);
			
			
			
			// Listne for 'Sharing Changed' update to be pushed through from the view (in the sharing panel)
			currentView.addEventListener(IDEvent.SHARING_CHANGED, sharingInfoChanged);
			
			// Collection Browser
			//(view as Browser).collectionbrowser.addEventListener(RecensioEvent.ASSET_MEDIA_CLICKED,assetCollectionClicked);
			/*(view as Browser).collectionbrowser.addEventListener(RecensioEvent.ASSET_MEDIA_CLICKED,assetCollectionClicked);
			(view as Browser).collectionbrowser.addEventListener(RecensioEvent.COLLECTION_DELETED,deleteCollection);
			(view as Browser).collectionbrowser.addEventListener(RecensioEvent.COLLECTION_SAVE,saveCollection);
			(view as Browser).navbar.addEventListener(RecensioEvent.SEARCH,searchClicked);
			(view as Browser).navbar.addEventListener(RecensioEvent.LIVE_SEARCH,liveSearchChanged);
			(view as Browser).navbar.addEventListener(RecensioEvent.NAV_CLICKED,navBarClicked);
			(view as Browser).navbar.addEventListener(RecensioEvent.ASSET_RESIZER,assetPreviewResize);*/
		}
		
		
		
		
		/* ========================= FUNCTIONS THAT LOAD ALL ASSETS, SHARED ASSETS, COLLECTIONS, or ASSETS IN COLLECTIONS ========================= */
		
		/**
		 * Loads all media assets owned by the user or
		 * shared with the user. 
		 */		
		private function loadAllMyMedia():void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			currentView.setToolbarToFixedCollectionMode();
			currentView.hideAllPanels();
			currentView.showMediaLoading();
			//LoadAnim.show((view as Browser), 0, 0, 0x999999,2);
//			LoadAnim.show((view as Browser),(view as Browser).width/2,(view as Browser).height/2+(view as Browser).navbar.height,0x999999,2);
			// Hide the browser?
			//(view as Browser).browser.hide(false);
			// Hide the collection browser
			//(view as Browser).collectionbrowser.hide(true);
			// Setup add button? (probably going to remove this)
			//addButton.setText("New Media Asset");
			//addButton.toolTip = "Upload and create a new media asset";
			// Get all the assets! weeeeeee
//			this.quickAddCachedMedia(ALLASSETID);
			
			// Load any media we might already have cached
			this.loadCachedCollectionMedia(ALLASSETID);
			
			Model.AppModel.getInstance().getAllMediaAssets(fixedCollectionAssetsLoaded);
		}
		
		/**
		 * Loads all collection assets owned by the user. TODO look at this owned by? sharing with? what?
		 */		
		private function loadAllMyCollections():void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Load any cached collections
			this.loadCachedCollections();
			// Load the full colleciton list in the background (and we update the collection list when this comes throuhg)
			Model.AppModel.getInstance().getCollections(collectionAssetsLoaded);
		}
		
		/**
		 * Loads media assets in a specific collection. 
		 * @param collectionID	the assetID of the collection
		 */		
		private function loadAssetsInCollection(collectionID:Number):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Tell the browser to highlight the collection list item we clicked
			currentView.highlightCollectionListItem(collectionID);
			
			currentView.showMediaLoading();
			
			
			// Change to the Regular toolbar
			currentView.setToolbarToRegularCollectionMode(modifyAccess);
			
			// Load any media we might already have cached
			this.loadCachedCollectionMedia(collectionID);
			
			// Get the Media inside/ this collection
			AppModel.getInstance().getThisCollectionsMediaAssets(collectionID, collectionMediaLoaded);
			
			// Get the Commentary for this collection
			AppModel.getInstance().getThisAssetsCommentary(collectionID, collectionCommentsLoaded);
			
			// Get the sharing access for this collection
			AppModel.getInstance().getAccess(collectionID, sharingDataLoaded);
		}
		
		/**
		 * Loads the media NOT owned by the user but that the user has access to 
		 */		
		private function loadShared():void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			currentView.setToolbarToFixedCollectionMode();
			currentView.hideAllPanels();
			currentView.showMediaLoading();
			Model.AppModel.getInstance().getSharedAssets(fixedCollectionAssetsLoaded);
		}
		
		
		/* ================================= DATABASE CALLBACKS ================================= */
		/* FUNCTIONS THAT ARE CALLED WHEN ALLL ASSETS, SHARED ASSETS, COLLECTIONS, or ASSETS IN COLLECTIONS  ARE LOADED
						OR WHEN COLLECTION IS CREATED/EDIT */
		
		/**
		 * Called when Assets for Fixed Collections (All Assets, Shared etc) are loaded.
		 * @param e
		 */		
		public function fixedCollectionAssetsLoaded(e:Event):void {
			// TODO need to add in another transaction for this similar to the regular collections
			
			this.cacheCollectionMedia(ALLASSETID, e);
			
			if(currentCollectionID != ALLASSETID && currentCollectionID != SHAREDID) {
				trace("returned a fixed collection, but we arent looking at one currently," +
					"FIX ME UP lol", currentCollectionID);
				return;
			}
			
			var data:String = e.target.data;
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Remove current tiles
			currentView.clearMediaAssets();
			
			// Convert XML return to Model_Media classes
			var assets:Array = AppModel.getInstance().extractAssetsFromXML(XML(data), Model_Media);
				
			// Since this is the list of the 'original files'
			// we want to remove all duplicates (that is, assets that point to the same file type)
			var files:Array = new Array();
			var cleanAssets:Array = new Array();
			
			for each(var asset:Model_Media in assets) {
				if(asset.meta_clone == false && asset.base_creator_username == Auth.getInstance().getUsername()) {
					cleanAssets.push(asset);
				} 
				asset.base_asset_id *= -1;
			}

			// Sort Alphabetically
			cleanAssets.sortOn(["meta_title"],[Array.CASEINSENSITIVE]);
			// Add the assets to the view
			currentView.addMediaAssets(cleanAssets);
			
			// Change to the Fixed toolbar
			currentView.setToolbarToFixedCollectionMode();
		}

		/**
		 * Called when collection assets are loaded. The collections are then added
		 * to the browser.
		 * @param e
		 * 
		 */		
		public function collectionAssetsLoaded(e:Event):void {
			
			// Save the collections away in a cache, so they can be easily retrieved next time
			this.cacheCollections(e);
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Remove current collections
			currentView.clearCollections();
		
			//var collections:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Collection);
			// Add the collections to the sidebar
			
			var collectionsAndFiles:Array = AppModel.getInstance().convertXMLtoCollectionObjectsWithMedia(XML(e.target.data).reply.result.asset);
//			files.sortOn(["meta_title"], [Array.CASEINSENSITIVE]);
//			trace("BrowserController:collectionAssetsLoaded - Files in collection", files.length);
			
//			collections.sortOn(["meta_title"],[Array.CASEINSENSITIVE]);
			
//			for(var i:Number = 0; i < collections.length; i++) {
//				//if((collections[i] as Model_Collection).numberOfChildren()) {
//					trace("found collection " + (collections[i] as Model_Collection).meta_title);
//				//}
//			}
			currentView.addCollections(collectionsAndFiles);
			currentView.highlightCollectionListItem(currentCollectionID);
			
			currentView.updateNewCollectionButton();
			//LoadAnim.hide();
		}
		
		/**
		 * Called when the media assets for a specific collection are loaded (both their own or shared assets)
		 * @param e
		 */		
		// 
		public function collectionMediaLoaded(collectionID:Number, e:Event):void {
			
			// Cache this media in this collection
			this.cacheCollectionMedia(collectionID, e);
				
			// If we have just got data back from a collection we are no longer looking at
			// ignore it.
			trace("got data for", collectionID, "we are looking at", currentCollectionID);
			if(collectionID != currentCollectionID) {
				return;
			}
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Remove current tiles
			currentView.clearMediaAssets();
			
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			//trace("Collection data", e.target.data);
			// Convert the returned data to an array of media assets
			// and store those assets.
			BrowserController.currentCollectionAssets = AppModel.getInstance().extractAssetsFromXML(data, Model_Media);

			// If we arent in edit mode, update the assets we could be editing
			// If we are in edit mode, then we want to keep editing the current assets, when we switch collections
//			if(!BrowserController.getEditOn()) {
//				BrowserController.editAssets = mediaInCollection;
//			}

			// Sort Alphabetically
			BrowserController.currentCollectionAssets.sortOn(["meta_title"],[Array.CASEINSENSITIVE]);
			
			// Add all of the assets inside this collection
			currentView.addMediaAssets(BrowserController.currentCollectionAssets);
		}
		
		/**
		 * The comments for the collection has loaded. Send the comments to the view. 
		 * @param e
		 * 
		 */		
		public function collectionCommentsLoaded(e:Event):void {
			trace("Comments loaded from Database");
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			var commentsForCollection:Array = AppModel.getInstance().extractCommentsFromXML(data);
			
			// Add all the comments for this collection
			// Send the collection ID, and all the comments
			currentView.addComments(commentsForCollection);
			
		}
		
		public function collectionCreated(collectionID:Number):void {
			// The collection has been created.
			
			// Get out ID of new collection.
			if(collectionID == -1) {
				trace("cllection failed");
				Alert.show("Failed to create collection");
				return;
			}
			
			// Set the current collection being view, to the net collection
			BrowserController.currentCollectionID = collectionID;
			
//			// Update the Collection Class so it is a 'collection'
//			AppModel.getInstance().setCollectionClass(e);
//			// Set this user as the owner of the collection
//			AppModel.getInstance().changeAccess(newCollectionID, Auth.getInstance().getUsername(), "system", SharingPanel.READWRITE, true);
//			
			// Remove all teh current items from the shelf
			shelfAssets.length = 0;
			
			// Set the shelf to off
			this.setCollectionCreationMode(false);
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Clear the on screen shelf
			currentView.hideShelf();
			currentView.clearShelf();
				
			// Lets reload the collections and diplay them.
			trace("Collection Saved")
			loadAllMyCollections();
			
			// Now lets load the assets for this specific collection
			loadAssetsInCollection(currentCollectionID);
		}
		
		public function collectionUpdated(collectionID:Number):void {
			// The collection has been updated.

			// Set the shelf to off
			this.setEdit(false);
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Clear the on screen shelf
			currentView.hideShelf();
			currentView.clearShelf();

			// Set the current collection being view, to the net collection
			BrowserController.currentCollectionID = collectionID;
			
			// Lets reload the collections and diplay them.
			trace("- Collection Saved.")
			trace("******************");
			loadAllMyCollections();
			
			// Now lets load the assets for this specific collection
			loadAssetsInCollection(collectionID);
		}
		
		/**
		 * The comment has been saved. 
		 * @param commentID			The ID for the saved comment
		 * @param commentText		The text for the saved comment
		 * @param newCommentObject	The NewCommentObject that is to be replaced by a regular comment.
		 * 
		 */		
		public function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			currentView.commentSaved(commentID, commentText, newCommentObject);
			
		}
		
		
		/**
		 * Called when the list of Users and Permissions for the current collection
		 * is returned. 
		 * @param userData	An array of users + permissions for the asset.
		 * 
		 */		
		private function sharingDataLoaded(userData:Array):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Send the data to view
			if(collectionData != null) {
				currentView.setupAssetsSharingInformation(userData, collectionData.base_creator_username);
			} else {
				currentView.setupAssetsSharingInformation(userData, "");
			}
		}
		
		/**
		 * The database has replied about updating the collections shared information. 
		 * @param e
		 * 
		 */		
		private function sharingInfoUpdated(e:Event):void {
			
			// Sharing complete,
			// enable the logout button
//			layout.header.logoutButton.enabled = true;
			super.addLogoutListener();
			
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			// Was the sharing update not access
			if(data.reply.@type == "result") {
				// Sharing update successfully
				trace("Sharing Updated Successfully", e.target.data);
				var currentView:BrowserView = (view as Browser).craigsbrowser;
				currentView.unlockSharingPanelUsers();
				trace("-------------------------");
			} else {
				//Alert.show("Sharing Update Failed");
				trace("Sharing Update Failed", e.target.data);
			} 
		}

		/* ========================= FUNCTIONS THAT ARE CALLED FROM USER MOUSE EVENTS ========================= */
		
		/**
		 * Called when the shelf button is clicked. 
		 * Changes the stored shelf value, and makes the shelf visible
		 * @param e event data
		 */		
		private function newCollectionButtonClicked(e:IDEvent):void {
			
			// Change the stored shelf value to be (im guessing true)
			// means the shelf is up basically
			this.setCollectionCreationMode(e.data.shelfState);
			
			// Turn Edit collection off
			this.setEdit(false);
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;

			if(BrowserController.getShelfOn()) {
				
				// Clear the shelf of any assets in there already (probably from edit mode)
				currentView.clearShelf();
				currentView.unsetEditButton();
				
				// Put all the assets for the current collection, into the shelf.
				for(var i:Number = 0; i < shelfAssets.length; i++) {
					currentView.addAssetToShelf(shelfAssets[i]);
				}
				
				// Shows the shelf, puts it all in Creation mode
				currentView.showShelf();
			} else {
				currentView.hideShelf();
			}
		}
		
		private function editButtonClicked(e:IDEvent):void {
			trace("Caught Edit Button Clicked");
			
			// Change the stored edit value to be whatever the buttons value is
			// true or false
			this.setEdit(e.data.editState);
			
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			if(BrowserController.getEditOn()) {
				// Edit mode is turned on.
				
				// Turn Create collection (or shelf mode) off
				this.setCollectionCreationMode(false);
				
				// Save the current collections being edited ID
				collectionBeingEditedID = currentCollectionID;
				
				// Copy the media assets for the current collection, so they can be edited.
				BrowserController.editAssets = new Array();
				for(var i:Number = 0; i < BrowserController.currentCollectionAssets.length; i++) {
					BrowserController.editAssets.push(BrowserController.currentCollectionAssets[i]);
				}
				
				// View related code below
				
				// Clear the shelf of any assets from creationm ode
				currentView.clearShelf();
				currentView.unsetCreateCollectionButton();
				
				// Set the name for the shelf, to be the current collections name
				// This is so we can move between collections, and the name remains the same
				trace("- Current collection name is:", currentCollectionTitle);
				editCollectionName = currentCollectionTitle;
				currentView.setShelfCollectionName(editCollectionName);
				
				// Put all the assets for the current collection, into the shelf.
				for(i = 0; i < editAssets.length; i++) {
					currentView.addAssetToShelf(editAssets[i]);
				}
				currentView.showShelf();
			} else {
				currentView.hideShelf();
			}
		}

		private function closeShelfButtonClicked(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			this.setEdit(false);
			this.setCollectionCreationMode(false);
			currentView.hideShelf();
		}
		
		/**
		 * Called when the delete button is clicked in the browser.
		 * Asks if the user is sure 
		 * 
		 */		
		private function deleteButtonClicked(e:IDEvent):void {
			if(collectionData.base_creator_username == Auth.getInstance().getUsername()) {
				// We are the creator of the collection
				var myAlert:Alert = Alert.show("Are you sure you wish to delete this " + BrowserController.PORTAL + "?", "Delete " + BrowserController.PORTAL, Alert.OK | Alert.CANCEL, null, deleteCollection, null, Alert.CANCEL);	
			} else {
				myAlert = Alert.show("Are you sure you wish to remove this " + BrowserController.PORTAL + "?", "Remove " + BrowserController.PORTAL, Alert.OK | Alert.CANCEL, null, deleteCollection, null, Alert.CANCEL);	
			}
			myAlert.height = 100;
			myAlert.width = 300;
		}
		
		/**
		 * Deletes the collection (from user confirmation) 
		 * @param e
		 * 
		 */		
		private function deleteCollection(e:CloseEvent):void {
			if (e.detail==Alert.OK) {
				AppModel.getInstance().deleteCollection(currentCollectionID, collectionData.base_creator_username, collectionDeleted);
				
				var currentView:BrowserView = (view as Browser).craigsbrowser;

				// The collection was deleted, so lets re-load the 
				// all assets colletion
				this.saveCurrentCollectionID(ALLASSETID);
				loadAllMyCollections();
				loadAllMyMedia();				
				//currentView.setToolbarToFixedCollectionMode();
			}
		}
		
		/**
		 * The collection was deleted. So reload the collection list. 
		 * @param e
		 * 
		 */		
		private function collectionDeleted(e:Event):void {
			// Lets reload the collections and diplay them.
			trace("Collection Deleted")
			loadAllMyCollections();
		}
		
		/**
		 * Called when asset tile is clicked. 
		 * Goes to Asset Display View
		 */		
		private function assetBrowserMediaClicked(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Get out the clicked assets data
			var assetData:Model_Media = e.data.assetData;
			
//			// We are going to make the asset ID negative, if we are making a clean copy
//			// otherwise, we leave it as positive (its just an easy flag to do)
//			if(currentCollectionID == ALLASSETID) {
//				assetData.base_asset_id = assetData.base_asset_id * -1;
//			}
//			
			// CHeck if the shelf is on
			if(getShelfOn()) {
				// The shelf is on, so lets check if we have already added this item to the shelfAssets, and its there remove it
				if(findAndRemoveAssetFromShelf(assetData.base_asset_id, BrowserController.shelfAssets)) {
					// we found and removed it,
					// so its already on the shelf, lets tell the view to remove it.
					trace('Removing asset from shelf', assetData.base_asset_id);
					currentView.removeAssetFromShelf(assetData.base_asset_id);
				} else {
					// Isn't in the shelf, so lets add it.
					shelfAssets.push(assetData);
					trace('Adding asset to shelf', assetData.base_asset_id);
					currentView.addAssetToShelf(assetData);
				}
				
				// Changes the number on the "New Collection" button
				currentView.updateNewCollectionButton();
				
				return;
			} else if (getEditOn()) {
				// Edit is on, so lets check if we have already added this item to the editAssets, and its there remove it
				if(findAndRemoveAssetFromShelf(assetData.base_asset_id, BrowserController.editAssets)) {
					// we found and removed it,
					// so its already on the shelf, lets tell the view to remove it.
					trace('Removing asset from shelf', assetData.base_asset_id);
					currentView.removeAssetFromShelf(assetData.base_asset_id);
				} else {
					// Isn't in the shelf, so lets add it.
					editAssets.push(assetData);
					trace('Adding asset to shelf', assetData.base_asset_id);
					currentView.addAssetToShelf(assetData);
				}
				return;
			}
			
			// We want to see the asset
			// Disable the shelf so its not on when we come back next time
			this.setCollectionCreationMode(false);
			
			// TODO REMOVE THIS
			var viewURL:String = "";
			currentMediaData = assetData;
			currentMediaData.base_asset_id = Math.abs(currentMediaData.base_asset_id);
			//if(assetData.type == "image" || assetData.type == "video" || assetData.type == "audio") {
			// Show the asset view
				viewURL = 'view/' + Math.abs(assetData.base_asset_id);
			//} else {
		//		viewURL = 'view_old/' + assetData.base_asset_id;
		//	}
			Dispatcher.call(viewURL);
		}
		
		private function shelfMediaClicked(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Get out the clicked assets data
			var assetData:Model_Media = e.data.assetData;
			
			if(BrowserController.getEditOn()) {
				// The shelf must be on, otherwose, how did we clicked it
				if(findAndRemoveAssetFromShelf(assetData.base_asset_id, BrowserController.editAssets)) {
					// we found and removed it,
					// so its already on the shelf, lets tell the view to remove it.
					trace('Removing asset from shelf', assetData.base_asset_id);
					currentView.removeAssetFromShelf(assetData.base_asset_id);
				}
			} else if (BrowserController.getShelfOn()) {
				// The shelf must be on, otherwose, how did we clicked it
				if(findAndRemoveAssetFromShelf(assetData.base_asset_id, BrowserController.shelfAssets)) {
					// we found and removed it,
					// so its already on the shelf, lets tell the view to remove it.
					trace('Removing asset from shelf', assetData.base_asset_id);
					currentView.removeAssetFromShelf(assetData.base_asset_id);
				}
				currentView.updateNewCollectionButton();
			}
			
		}
		
		/**
		 * Removes all the current assets from the shelf. Either the collection creation or the
		 * edit shelf. 
		 * @param e
		 * 
		 */		
		private function shelfClearClicked(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Get out the clicked assets data
			var assetData:Model_Media = e.data.assetData;
			
			// Empty whatever shelf we are looking at
			if(BrowserController.getEditOn()) {
				editAssets = new Array();
				currentView.removeShelfMedia();
			} else if (BrowserController.getShelfOn()) {
				shelfAssets = new Array();
				currentView.removeShelfMedia();
			}
			// Update the New Collection button to show it has 0 assets in it
			currentView.updateNewCollectionButton();
		}
		
		/**
		 * Called when All Assets Collection Item is clicked.
		 * Changes assets being displayed to all assets.
		 * Well actually, it just gets the assets, another function does the display @see collectionMediaLoaded
		 * @param e
		 * 
		 */		
		private function showAllAssetsClicked(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Save the Collections ID (-1)
			this.saveCurrentCollectionID(e.data.assetID);
				
			currentView.highlightCollectionListItem(currentCollectionID);
		
			loadAllMyMedia();
		}
		
		/**
		 * Called when Shared With Me Collection item is clicked.
		 * Loads the shared items 
		 * @param e
		 */		
		private function showSharedWithMeClicked(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Save the Collections ID (-2)
			this.saveCurrentCollectionID(e.data.assetID);
			// Highlight this collection (to show we clicked it);
			currentView.highlightCollectionListItem(currentCollectionID);

			//currentView.setToolbarToFixedCollectionMode();
			loadShared();
		}

//		private function showShelfCollectionClicked(e:RecensioEvent):void {
//			var currentView:BrowserView = (view as Browser).craigsbrowser;
//			
//			// Save the Collections ID
//			this.saveCurrentCollectionID(e.data.assetID);
//			// Highlight this collection (to show we clicked it);
//			currentView.highlightCollectionListItem(currentCollectionID);
//			
//			currentView.setToolbarToRegularCollectionMode();
//			
//			// Remove current tiles
//			currentView.clearMediaAssets();
//			
//			// Set the items in the current view, to be the items in the shelf? weird.
//			currentView.addMediaAssets(shelfAssets);
//		}
		
		/**
		 * Called when CollectionListItem is clicked.
		 * Changes assets being displayed to assets inside collection.
		 * Well actually, it just gets the assets, another function does the display @see collectionMediaLoaded
		 * @param e
		 * 
		 */		
		private function assetCollectionClicked(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			// Save the Collections ID
			this.saveCurrentCollectionID(e.data.assetID);
			this.modifyAccess = e.data.access;
			collectionData = e.data.collectionData;
			
			trace("Saving current collection name", e.data.collectionName);
			this.saveCurrentCollectionName(e.data.collectionName);
			
			// Highlight the collection we clicked (in the sidebar)
			currentView.highlightCollectionListItem(currentCollectionID);
			
			//currentView.setToolbarToRegularCollectionMode();
			loadAssetsInCollection(e.data.assetID);
			trace("A Collection was clicked");
		}
		
		
		
		/**
		 * Called when save is clicked in the shelf. 
		 * @param e
		 * 
		 */		
		private function saveCollection(e:IDEvent):void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			currentView.showMediaLoading();
			
			if(BrowserController.getShelfOn()) { // && BrowserController.shelfAssets.length > 0) {
				// We are in Collection Creation Mode
				// There can be no assets in the collection, as a user might want to create a blank collection
				// and share it with others, so they can add stuff to it
				var collectionTitle:String = e.data.collectionTitle;
				
				if(collectionTitle != "") {
					// Save the collection title as the current collection title (so when it loads
					// after saving, and someone hits edit, its all set nicely :)
					trace("The current collection name is set as", BrowserController.currentCollectionTitle);
					this.saveCurrentCollectionName(collectionTitle);
					AppModel.getInstance().createCollection(collectionTitle, shelfAssets, collectionCreated);
					
					// Clear the collection cache, since we are going to be updating it
					clearCachedCollections();
				} else {
					return;
				}
			} else if (BrowserController.getEditOn()) {
				// We are in Edit Mode
				trace("Hello, you are in edit mode, and you hit save. lovely");
				collectionTitle = e.data.collectionTitle;
				// Save the collection title as the current collection title (so when it loads
				// after saving, and someone hits edit, its all set nicely :)
				trace("The current collection name is set as", BrowserController.currentCollectionTitle, " - ", collectionTitle);
				this.saveCurrentCollectionName(collectionTitle);
				AppModel.getInstance().saveCollection(collectionBeingEditedID, collectionTitle, editAssets, collectionUpdated);
				
				// Clear the collection cache, since are going to be updating it
				clearCachedCollections();
				this.clearCachedCollectionMedia(collectionBeingEditedID);
			}
		}
		
		/**
		 * Saves a comment 
		 * @param e	e.data.commentText - Contains the comment text, e.data.newCommentObject=the
		 * actual comment.
		 * 
		 */		
		private function saveComment(e:IDEvent):void {
			trace('Saving comment: ', e.data.commentText, 'in reply to asset:', currentCollectionID, 'reply to comment:', e.data.replyingToID);
			
			AppModel.getInstance().saveNewComment(	e.data.commentText, currentCollectionID, e.data.replyingToID,
													e.data.newCommentObject, commentSaved);
		}
		
		/**
		 * Deletes a comment 
		 * @param e
		 * 
		 */		
		private function deleteComment(e:IDEvent):void {
			trace("Deleting a comment:", e.data.assetID);
			AppModel.getInstance().deleteComment(e.data.assetID);
		}

		/**
		 * Changes the Sharing information for a collection.
		 * 
		 * Grants/Revokes access to a collection, and to all of its children assets.
		 *  
		 * @param e.username	The username whose access has changed.
		 * @param e.access		The access ('no-access', 'read' or 'read-write')
		 * 
		 */				
		private function sharingInfoChanged(e:IDEvent):void {
			var username:String = e.data.username;
			var access:String = e.data.access;
			AppModel.getInstance().changeAccess(currentCollectionID, username, "system", access, true, sharingInfoUpdated);
			
			// DIsable the logout button, until the sharing is complete.
			super.removeLogoutListener();
//			trace("********** LOGOUT BUTTON IS", layout.header.logoutButton.enabled);
		}
		
		
		// Sets up the "add media asset" button
//		private function setupAddButtons():void {
//			addButton = new SmallButton("New Media Asset",true);
//			addButton.toolTip = "Upload and create a new media asset";
//			addButton.width = 180;
//			addButton.height = 22;
//			addButton.x = -1;
//			addButton.y = 57;
//			addButton.addEventListener(MouseEvent.MOUSE_UP,addButtonClicked);
//			(view as Browser).addElement(addButton);
//		}
		
		// Used for the 'my collections' page
		// Loads the collections created by the user
//		private function loadCollections():void {
//			LoadAnim.show((view as Browser),(view as Browser).width/2,(view as Browser).height/2+(view as Browser).navbar.height,0x999999,2);
//			(view as Browser).browser.hide(true);
//			(view as Browser).collectionbrowser.hide(false);
//			addButton.setText("New Collection");
//			addButton.toolTip = "Create a new collection of media assets";
//			Model.AppModel.getInstance().getAllAssets(assetsForCollectionsLoaded);
//		}
		
		// Called when the array of assets for the user is ready (for collections)
//		public function assetsForCollectionsLoaded(e:Event):void {
//			var assets:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Media);
//			(view as Browser).collectionbrowser.setAssetData(assets);
//			Model.AppModel.getInstance().getCollections(collectionsLoaded);
//			LoadAnim.hide();
//		}
		
		

		

		
		
		/* ==================================================  HELPER FUNCTIONS ================================================== */
		/**
		 * Checks if asset is already on shelf and removes it if its found.
		 * @param assetID the asset id of the asset to check for
		 * @return true if the asset is on the shelf or false if its not.
		 * 
		 */				
		private function findAndRemoveAssetFromShelf(assetID:Number, arrayToSearch:Array):Boolean {
			var returnValue:Boolean = false;
			
			var newShelfAssetsArray:Array = new Array();
			
			for(var i:Number = 0; i < arrayToSearch.length; i++) {
				// The asset does not match the given asset id to remove
				if(assetID != (arrayToSearch[i] as Model_Media).base_asset_id) {
					// Add it to the new shelf assets array
					newShelfAssetsArray.push((arrayToSearch[i] as Model_Media));
				} else {
					// It did match, ignore it, and set the 'was found' value to true
					returnValue = true;
				}
			}
			
			if(arrayToSearch == BrowserController.editAssets) {
				BrowserController.editAssets = newShelfAssetsArray;
			} else if (arrayToSearch == BrowserController.shelfAssets) {
				BrowserController.shelfAssets = newShelfAssetsArray;
			}
			return returnValue;
		}
		
		/**
		 * Called when the browser is loaded, and we try and reload all the items that were
		 * in the shelf before we left to view an asset etc
		 */
		private function reAddAssetsToShelf():void {
			var currentView:BrowserView = (view as Browser).craigsbrowser;
			
			for(var i:Number = 0; i < shelfAssets.length; i++) {
				currentView.addAssetToShelf(shelfAssets[i]);
			}
		}
		
		/* ====== CACHING FUNCTIONS ======== */
		/**
		 * Stores the collections in a cache. 
		 * @param e	The event returned when all collections are retrieved
		 * 
		 */		
		private function cacheCollections(e:Event):void {
			cachedCollections = e
		}
		/**
		 * Clears the cache of collections 
		 * 
		 */		
		private function clearCachedCollections():void {
			cachedCollections = null;
		}
		/**
		 * Loads the cache of collections and displays them. 
		 * 
		 */		
		private function loadCachedCollections():void {
			if(cachedCollections && cachedCollections != null) {
				collectionAssetsLoaded(cachedCollections);
			}
		}
		private function cacheCollectionMedia(collectionID:Number, e:Event):void {
			// Save the collection media
			clearCachedCollectionMedia(collectionID);
			var cacheCollection:Array = new Array();
			cacheCollection.push(collectionID);
			cacheCollection.push(e);
			cachedCollectionMedia.push(cacheCollection);
		}
		
		public static function clearCurrentCollectionMedia():void {
			trace("clearCachedCollectionMedia -", BrowserController.currentCollectionID);
			for (var i:Number = 0; i < cachedCollectionMedia.length; i++) {
				var cacheCollection:Array = cachedCollectionMedia[i];
				var cacheCollectionID:Number = cacheCollection[0];
				if(cacheCollectionID == BrowserController.currentCollectionID) {
					trace("Found collection to remove", BrowserController.currentCollectionID, "- now removing", cachedCollectionMedia.length);
					cachedCollectionMedia.splice(i, 1);		
					trace("Found collection to remove", BrowserController.currentCollectionID ,"- removed", cachedCollectionMedia.length);
				}
			}
		}

		private function loadCachedCollectionMedia(collectionID:Number):void {
			// Check if we dont have this collection cached
			for each(var cacheCollection:Array in cachedCollectionMedia) {
				var cacheCollectionID:Number = cacheCollection[0];
				var cacheCollectionEvent:Event = cacheCollection[1];
				if(cacheCollectionEvent != null) {
					if(cacheCollectionID == collectionID) {
						if(collectionID == ALLASSETID) {
							fixedCollectionAssetsLoaded(cacheCollectionEvent);
						} else {
							collectionMediaLoaded(cacheCollectionID, cacheCollectionEvent);
						}
						break;
					}
				}
			}
		}
		
		private function clearCachedCollectionMedia(collectionID:Number):void {
			trace("clearCachedCollectionMedia -", collectionID);
			for (var i:Number = 0; i < cachedCollectionMedia.length; i++) {
				var cacheCollection:Array = cachedCollectionMedia[i];
				var cacheCollectionID:Number = cacheCollection[0];
				if(cacheCollectionID == collectionID) {
					trace("Found collection to remove", collectionID, "- now removing", cachedCollectionMedia.length);
					cachedCollectionMedia.splice(i, 1);		
					trace("Found collection to remove", collectionID ,"- removed", cachedCollectionMedia.length);
				}
			}
		}



		
		// Called when the collections are loaded 
//		public function collectionsLoaded(e:Event):void {
//			(view as Browser).collectionbrowser.removeCollections();
//			var collections:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Collection);
//			for each(var collectionData:Model_Collection in collections) {
//				(view as Browser).collectionbrowser.addCollection(collectionData);
//			}
//			(view as Browser).collectionbrowser.refreshView();
//		}
		

		
		// Sets up the navigation bar
//		private function setupNavbar():void {
//			(view as Browser).navbar.addButton("my media","left",true);
//			(view as Browser).navbar.addButton("shared","left");
//			(view as Browser).navbar.addButton("my collections","left");
//			(view as Browser).navbar.addSearchBox();
//			(view as Browser).navbar.addResizer();
//			(view as Browser).navbar.defaultSelect("my media");
//		}
		
		// Called when the add button (either new media or new collection) is clicked
		/*private function addButtonClicked(e:MouseEvent):void {
			if(addButton.getText() == "New Collection") {
				(view as Browser).collectionbrowser.createNewCollection();
			} else {
				Dispatcher.call("newasset");
			}
		}*/
		

		
		// Called when the search button is clicked (not visible in this version - see liveSearchChanged)
		private function searchClicked(e:IDEvent):void {
//			(view as Browser).browser.filter(e.data.query);
//			(view as Browser).collectionbrowser.filter(e.data.query);
		}
		
		// Called when the search text input is changed
		private function liveSearchChanged(e:IDEvent):void {
//			(view as Browser).browser.filter(e.data.query);
//			(view as Browser).collectionbrowser.filter(e.data.query);
		}
		
		// Called when the scroller for asset preview size is changed
		private function assetPreviewResize(e:IDEvent):void {
//			(view as Browser).browser.setAssetPreviewSize(e.data.value);
//			(view as Browser).collectionbrowser.setAssetPreviewSize(e.data.value);
		}
		
		// Called when a button on the navigation bar is clicked
		/*private function navBarClicked(e:RecensioEvent):void {
			switch(e.data.buttonName) {
				case 'my media':
					loadAllMyMedia();
					(view as Browser).navbar.clearSearch();
					break;
				case 'my collections':
					loadCollections();
					(view as Browser).navbar.clearSearch();
					break;
				case 'shared':
					loadShared();
					(view as Browser).navbar.clearSearch();
					break;
			}
		}*/
		
//		// Called when a collection is to be deleted
//		private function deleteCollection(e:RecensioEvent):void {
//			collectionToDelete = e.data.assetID;
//			collectionDelete_Alert();
//		}
//		
//		// Called when a collection is to be saved
//		private function saveCollection(e:RecensioEvent):void {
//			if(e.data.assetID == -1) {
//				AppModel.getInstance().createCollection(e.data,collectionCreated);
//				(view as Browser).navbar.clearSearch();
//			} else {
//				AppModel.getInstance().saveCollection(e.data,collectionSaved);
//				if(e.data.hasChild.length == 0) {
//					(view as Browser).collectionbrowser.removeCollectionById(e.data.assetID);
//				}
//			}
//		}
		
		// Called when a colleciton is successfully saved
		private function collectionSaved():void {
			//trace("COLLECTION SAVED");
		}
		
//		// Called when a new colleciton is successfully saved (so the right class in mediaflux can be added) 
//		private function collectionCreated(e:Event):void {
//			AppModel.getInstance().setCollectionClass(e);
//			var dataXML:XML = XML(e.target.data);
//			(view as Browser).collectionbrowser.saveNewCollectionId(dataXML.reply.result.id);
//			loadCollections();
//		}
		
		// Alert dialog to confirm whether a collection should be deleted
		private function collectionDelete_Alert():void {
			var myAlert:Alert = Alert.show("Are you sure you wish to delete this collection?", "Delete Collection", Alert.OK | Alert.CANCEL, null, collectionDelete_Confirm, null, Alert.CANCEL);
			myAlert.height=100;
			myAlert.width=300;
		}
		
		// Deletes the collection
		private function collectionDelete_Confirm(e:CloseEvent):void {
//			if (e.detail==Alert.OK) {
//				(view as Browser).collectionbrowser.removeCollectionById(collectionToDelete);
//				AppModel.getInstance().deleteCollection(collectionToDelete);
//			}
//			collectionToDelete = 0;
		}
		
		
		// Getters/Setters for setting private static variables edit and shelf
		public static function getEditOn():Boolean {
			return editOn;
		}
		public static function getShelfOn():Boolean {
			return shelfOn;
		}

		public static function getShelfAssets():Array {
			return shelfAssets;
		}
		
		public static function getEditAssets():Array {
			return editAssets;
		}
		
		public function setEdit(value:Boolean):void {
			editOn = value;
		}
		public function setCollectionCreationMode(value:Boolean):void {
			shelfOn = value;
		}
		
		/**
		 * Saves the current collection we are showing (so we can go back to it, after going into an asset
		 * and so we can highlight the correct collection in the collection list). 
		 * @param id	The collection ID.
		 * 
		 */		
		private function saveCurrentCollectionID(id:Number):void {
			currentCollectionID = id;
		}
		
		private function saveCurrentCollectionName(name:String):void {
			currentCollectionTitle = name;
		}
	}
}