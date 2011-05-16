package Controller {
	
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	import Controller.Utilities.UserPreferences;
	
	import Lib.LoadingAnimation.LoadAnim;
	import Lib.it.transitions.Tweener;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Model_Collection;
	import Model.Model_Media;
	
	import Module.AudioViewer.AudioView;
	import Module.PDFViewer.PDFViewer;
	
	import View.AssetCollectionView;
	import View.AssetView;
	import View.Browser;
	import View.Element.AssetOptionsForm;
	import View.Element.SmallButton;
	import View.ModuleWrapper.*;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class AssetViewCollectionController extends AppController {
		
		private var assetID:Number = 0; // The ID of the asset
		private var assetData:Model_Collection; // The data associated with the asset
		private var comments:Array = new Array(); // Comments assoc. with the asset
		
		
		private var optionsHeight:Number = 200;
		private var commentToDelete:Number = 0;
		
		
		
		
		//private var collectionToDelete:Number = 0;
		//private var addButton:SmallButton;
		
		public function AssetViewCollectionController() {
			// Get the assets ID
			assetID = Dispatcher.getArgs()[0];
			
			// Create a new AssetCollectionView
			view = new AssetCollectionView();
			
			trace("this assets ID is " + assetID);
			super();
		}
	
		//INIT
		override public function init():void {
			setupEventListeners();
			setupNavbar();
			
			// This simulates the browser being resized, so it makes everything go 100% width, cause its fucked.
			(view as AssetCollectionView).stage.dispatchEvent(new Event(Event.RESIZE));
			
			loadData();
			(view as AssetCollectionView).commentsholder.width = UserPreferences.commentsWidth;
		}
		
		// Sets up all the event listeners
		private function setupEventListeners():void {
			// Asset Browser
			// Listen for Media Asset being clicked
			(view as AssetCollectionView).browser.addEventListener(RecensioEvent.ASSET_MEDIA_CLICKED,assetMediaClicked);
			(view as AssetCollectionView).navbar.addEventListener(RecensioEvent.NAV_CLICKED,navBarClicked);
			(view as AssetCollectionView).comments.addEventListener(RecensioEvent.COMMENT_NAV_CLICKED,commentNavClicked);
			(view as AssetCollectionView).assetoptions.addEventListener(RecensioEvent.ASSET_UPDATE,optionsUpdated);
			(view as AssetCollectionView).assetsharing.addEventListener(RecensioEvent.SHARED_SAVED,sharedUpdated);
			
			// Nav Bar
			// CRAIG  - WORK OUT WHAT YOU ARE GOING TO DO ABOUT THIS
			/*
			(view as Browser).navbar.addEventListener(RecensioEvent.SEARCH,searchClicked);
			(view as Browser).navbar.addEventListener(RecensioEvent.LIVE_SEARCH,liveSearchChanged);
			(view as Browser).navbar.addEventListener(RecensioEvent.NAV_CLICKED,navBarClicked);
			(view as Browser).navbar.addEventListener(RecensioEvent.ASSET_RESIZER,assetPreviewResize);*/
		}
		
		// Sets up the navigation bar
		private function setupNavbar():void {
			(view as AssetCollectionView).navbar.addHeading("Loading...");
			(view as AssetCollectionView).navbar.addButton("comments","right",true);
			(view as AssetCollectionView).navbar.addButton("share","right");
			//(view as AssetCollectionView).navbar.addButton("edit","right");
			(view as AssetCollectionView).navbar.addButton("delete","right");
			(view as AssetCollectionView).navbar.addButton("back","right");
			(view as AssetCollectionView).navbar.defaultSelect("comments");
		}
		
		// Loads the asset information, the annotations for the asset, and the current users in mediaflux (for sharing)
		private function loadData():void {
			//AppModel.getInstance().getAsset(assetID,assetLoaded);
			
			AppModel.getInstance().getAccess(assetID,userListLoaded);
			AppModel.getInstance().getAnnotations(assetID,annotationsLoaded);
			
			setTimeout(loadThisCollectionsMedia,100);
			
			(view as AssetCollectionView).navbar.overwriteSelection = true;
		}
		
		/**
		 * Loads all media assets inside this collection.
		 */		
		private function loadThisCollectionsMedia():void {
			// Do something
			//LoadAnim.show((view as Browser),(view as Browser).width/2,(view as Browser).height/2+(view as Browser).navbar.height,0x999999,2);
			// Hide the browser?
			(view as AssetCollectionView).browser.hide(false);

			// Get all the assets! weeeeeee
			Model.AppModel.getInstance().getThisCollectionsMediaAssets(assetID, mediaAssetsLoaded);
		}
		
		/**
		 * Loads all collection assets owned by the user. 
		 */		
		private function loadAllMyCollections():void {
			//LoadAnim.show((view as Browser),(view as Browser).width/2,(view as Browser).height/2+(view as Browser).navbar.height,0x999999,2);
			//(view as Browser).browser.hide(true);
			//(view as Browser).collectionbrowser.hide(false);
			//addButton.setText("New Collection");
			//addButton.toolTip = "Create a new collection of media assets";
			//Model.AppModel.getInstance().getCollections(collectionAssetsLoaded);
		}
		
		/**
		 * Called when the assets are loaded (both their own or shared assets)
		 * @param e
		 */		
		// 
		public function mediaAssetsLoaded(e:Event):void {
			// Remove current tiles
			(view as AssetCollectionView).browser.removeAssets();
		
			// Convert XML returned to Model_Media classes
			var data:XML = XML(e.target.data);
			var collectionAsset:Model_Collection = AppModel.getInstance().parseResults(data, Model_Collection)[0];
			
			var mediaInCollection:Array = new Array();//AppModel.getInstance().parseResultChildren(data, Model_Media);
			
			assetData = collectionAsset;
			// Did we find any assets?
			if(assetData) {
				(view as AssetCollectionView).navbar.setHeading(assetData.meta_title);
				//setTimeout(loadModule,100);
				(view as AssetCollectionView).assetoptions.setFormValuesCollection(assetData);
				
				// Sort Alphabetically
				mediaInCollection.sortOn(["meta_title"],[Array.CASEINSENSITIVE]);
				
				// Add each asset
				for each(var media:Model_Media in mediaInCollection) {
					(view as AssetCollectionView).browser.addMediaAsset(media);
					trace('adding asset ' + media.meta_title);
				}
				
				(view as AssetCollectionView).stage.dispatchEvent(new Event(Event.RESIZE));
				
			} else {
				Alert.show("Could not access asset");
				Dispatcher.call("browse");
			}
			

			
			// Refresh the view.
			(view as AssetCollectionView).browser.refreshView();
			LoadAnim.hide();
			
			// Set access ???
			setAccess();
		}
		
		
		// Called when the annotations and comments are loaded from mediaflux.  Pushes the annotations and comments to the module and the view respectively.
		private function annotationsLoaded(e:Event):void {
			removeAnnotations();
			var annotationsData:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Commentary);
			for(var i:Number=0; i<annotationsData.length; i++) {
				if((annotationsData[i] as Model_Commentary).isAnnotation()) {
				//	annotations.push(annotationsData[i]);
				} else {
					comments.push(annotationsData[i]);
				}
			}
			(view as AssetCollectionView).comments.addComments(comments);
			/*try {
				(moduleInstance as ModuleClass).viewer.addAnnotations(annotations);
			} catch (e:Error) {
				trace(e.message);
				trace("Not sure whats happening here");
			}*/
		}
		
		// Called when the comments and annotations should be cleared out.
		public function removeAnnotations():void {
			comments = new Array();
			//annotations = new Array();
		}

		
		// Sets up the navigation bar
		/*private function setupNavbar():void {
		(view as Browser).navbar.addButton("my media","left",true);
		(view as Browser).navbar.addButton("shared","left");
		(view as Browser).navbar.addButton("my collections","left");
		(view as Browser).navbar.addSearchBox();
		(view as Browser).navbar.addResizer();
		(view as Browser).navbar.defaultSelect("my media");
		}*/
		
		// Called when the add button (either new media or new collection) is clicked
		/*private function addButtonClicked(e:MouseEvent):void {
		if(addButton.getText() == "New Collection") {
		(view as Browser).collectionbrowser.createNewCollection();
		} else {
		Dispatcher.call("newasset");
		}
		}*/
		
		// Called when an asset is clicked
		private function assetMediaClicked(e:RecensioEvent):void {
			var viewURL:String = 'view/'+e.data.assetID;
			Dispatcher.call(viewURL);
		}
		
		// Called when an asset is clicked
		/*private function assetCollectionClicked(e:RecensioEvent):void {
		trace("A Collection was clikced");
		var viewURL:String = 'view_collection/'+e.data.assetID;
		Dispatcher.call(viewURL);
		}*/
		
		// Called when the search button is clicked (not visible in this version - see liveSearchChanged)
		/*private function searchClicked(e:RecensioEvent):void {
		(view as Browser).browser.filter(e.data.query);
		(view as Browser).collectionbrowser.filter(e.data.query);
		}
		
		// Called when the search text input is changed
		private function liveSearchChanged(e:RecensioEvent):void {
		(view as Browser).browser.filter(e.data.query);
		(view as Browser).collectionbrowser.filter(e.data.query);
		}
		
		// Called when the scroller for asset preview size is changed
		private function assetPreviewResize(e:RecensioEvent):void {
		(view as Browser).browser.setAssetPreviewSize(e.data.value);
		(view as Browser).collectionbrowser.setAssetPreviewSize(e.data.value);
		}
		
		// Called when a button on the navigation bar is clicked
		private function navBarClicked(e:RecensioEvent):void {
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
		}
		
		// Called when a collection is to be deleted
		private function deleteCollection(e:RecensioEvent):void {
		collectionToDelete = e.data.assetID;
		collectionDelete_Alert();
		}
		
		// Called when a collection is to be saved
		private function saveCollection(e:RecensioEvent):void {
		if(e.data.assetID == -1) {
		AppModel.getInstance().createCollection(e.data,collectionCreated);
		(view as Browser).navbar.clearSearch();
		} else {
		AppModel.getInstance().saveCollection(e.data,collectionSaved);
		if(e.data.hasChild.length == 0) {
		(view as Browser).collectionbrowser.removeCollectionById(e.data.assetID);
		}
		}
		}
		
		// Called when a colleciton is successfully saved
		private function collectionSaved():void {
		//trace("COLLECTION SAVED");
		}
		
		// Called when a new colleciton is successfully saved (so the right class in mediaflux can be added) 
		private function collectionCreated(e:Event):void {
		AppModel.getInstance().setCollectionClass(e);
		var dataXML:XML = XML(e.target.data);
		(view as Browser).collectionbrowser.saveNewCollectionId(dataXML.reply.result.id);
		loadCollections();
		}
		
		// Alert dialog to confirm whether a collection should be deleted
		private function collectionDelete_Alert():void {
		var myAlert:Alert = Alert.show("Are you sure you wish to delete this collection?", "Delete Collection", Alert.OK | Alert.CANCEL, null, collectionDelete_Confirm, null, Alert.CANCEL);
		myAlert.height=100;
		myAlert.width=300;
		}
		
		// Deletes the collection
		private function collectionDelete_Confirm(e:CloseEvent):void {
		if (e.detail==Alert.OK) {
		(view as Browser).collectionbrowser.removeCollectionById(collectionToDelete);
		AppModel.getInstance().deleteCollection(collectionToDelete);
		}
		collectionToDelete = 0;
		}
		*/
		

		
		//INIT

		

		
		// Called when the current users is returned, and passes them to the sharing view
		private function userListLoaded(userData:Array):void {
			(view as AssetCollectionView).assetsharing.setShared(userData);
		}
		
		// Called when the asset is loaded, validates the asset and then calls loadModule
		/*private function assetLoaded(e:Event):void {
			trace(e.target.data);
			var assets:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Media);
			assetData = assets[0];
			if(assetData) {
				(view as AssetCollectionView).navbar.setHeading(assetData.meta_title);
				setTimeout(loadModule,100);
				(view as AssetCollectionView).assetoptions.setFormValues(assetData);
				(view as AssetCollectionView).stage.dispatchEvent(new Event(Event.RESIZE));
			} else {
				Alert.show("Could not access asset");
				Dispatcher.call("browse");
			}
			setAccess();
		}*/
		
		private function setAccess():void {
			if(!assetData.access_modify) {
				(view as AssetCollectionView).navbar.removeButton("share");
				(view as AssetCollectionView).navbar.removeButton("edit");
				(view as AssetCollectionView).navbar.removeButton("delete");
			}
		}
		
		// Loads the module for the specific asset media type
		// load() addAnnotations() and annotationSave=myFunction();
		/*private function loadModule():void {
			var type:String = AssetLookup.getCommonType(assetData.base_type);
			ModuleClass = AssetLookup.getClass(type);
			if(ModuleClass) {
				moduleInstance = new ModuleClass();
				try {
					(moduleInstance as ModuleClass).viewer.addEventListener(RecensioEvent.MODULE_FAIL,moduleFail);
					if((moduleInstance as ModuleClass).external) {
						var uri:String = (moduleInstance as ModuleClass).formatURI(assetData.meta_media_uri);
						(moduleInstance as ModuleClass).viewer.load(uri);
					} else {
						(moduleInstance as ModuleClass).viewer.load(assetData.generateMediaURL());
					}
					(moduleInstance as ModuleClass).viewer.annotationSave = saveAnnotation;
				} catch (e:Error) {
					ModuleClass = Module_Missing;
					moduleInstance = new Module_Missing();
					(moduleInstance as Module_Missing).failureDescription.text = e.message;
				}
				(view as AssetCollectionView).viewWrapper.addElement(moduleInstance);
				if(annotations.length > 0) {
					try {
						(moduleInstance as ModuleClass).viewer.addAnnotations(annotations);
					} catch (e:Error) {
						Alert.show(e.message);
						Dispatcher.call("browse");
					}
				}
			}
		}*/
		
		//Called when a module encounters an error
		/*private function moduleFail(e:RecensioEvent):void {
			trace("DING DING DING");
			(view as AssetCollectionView).viewWrapper.removeAllElements();
			ModuleClass = Module_Missing;
			moduleInstance = new Module_Missing();
			(moduleInstance as Module_Missing).failureDescription.text = e.data.code;
			(view as AssetCollectionView).viewWrapper.addElement(moduleInstance);
			trace(e.data.code);
		}*/
		
		// Called when an annotation is saved.  Sets the data correctly and pushes the information to the model
		/*private function saveAnnotation(items:Array):void {
			for(var i:Number=0; i<items.length; i++) {
				if(!items[i].x) {
					items[i].x = 0;
				}
				if(!items[i].y) {
					items[i].y = 0;
				}
				if(!items[i].width) {
					items[i].width = 0;
				}
				if(!items[i].height) {
					items[i].height = 0;
				}
				if(!items[i].start) {
					items[i].start = 0;
				}
				if(!items[i].end) {
					items[i].end = 0;
				}
				if(!items[i].text) {
					items[i].text = "";
				}
				if(!items[i].path) {
					items[i].path = "";
				}
				if(!items[i].annotationType) {
					items[i].annotationType = 2;
				}
				items[i].parentID = assetID;
				AppModel.getInstance().saveAnnotation(items[i]);
			}
		}*/
		
		// Called when the comments and annotations should be cleared out.
		/*public function removeAnnotations():void {
			comments = new Array();
			annotations = new Array();
		}*/
		

		
		// Called when the update shared information button is clicked.  Sends the new access rights to the model and hides the sharing view
		private function sharedUpdated(e:RecensioEvent):void {
			AppModel.getInstance().setAccess(assetID,e.data.access);
			toggleComments();
		}
		
		// Called when the update options button is clicked.  Sends the new options meta-information to the model and hides the options view
		private function optionsUpdated(e:RecensioEvent):void {
			e.data.assetID = assetID;
			AppModel.getInstance().updateAsset(e.data);
			hideOptions();
			(view as AssetCollectionView).navbar.deselectButtonName("edit");
			(view as AssetCollectionView).navbar.setHeading(e.data.meta_title);
		}
		
		// When a comments menu navigation is clicked.  Deletes and saves comments where appropriate
		private function commentNavClicked(e:RecensioEvent):void {
//			switch(e.data.action) {
//				case 'Reply':
//				case 'Save':
//					e.data.parentID = assetID;
//					AppModel.getInstance().saveComment(e.data);
//					break;
//				case 'Delete':
//					commentToDelete = int(e.data.assetID);
//					commentDelete_Alert();
//					break;
//			}
		}
		

		
		// Called when a button on the navigation bar is clicked
		private function navBarClicked(e:RecensioEvent):void {
			switch(e.data.buttonName) {
				case 'back':
					Dispatcher.call("browse");
					break;
				case 'delete':
					assetDelete_Alert();
					break;
				case 'comments':
					toggleComments();
					break;
				case 'edit':
					toggleOptions();
					break;
				case 'share':
					toggleShare();
					break;
			}
		}
		
		// Alert dialog to confirm whether a comment should be deleted
		private function commentDelete_Alert():void {
			(view as AssetCollectionView).navbar.deselectButtons();
			var myAlert:Alert = Alert.show("Are you sure you wish to delete this comment?", "Delete Comment", Alert.OK | Alert.CANCEL, null, commentDelete_Confirm, null, Alert.CANCEL);
			myAlert.height=100;
			myAlert.width=300;
		}
		
		// Deletes a comment
		private function commentDelete_Confirm(e:CloseEvent):void {
			if (e.detail==Alert.OK) {
				AppModel.getInstance().deleteComment(commentToDelete);
				(view as AssetCollectionView).comments.removeCommentById(commentToDelete);
			}
			commentToDelete = 0;
		}
		
		// Alert dialog to confirm whether the asset should be deleted
		private function assetDelete_Alert():void {
			(view as AssetCollectionView).navbar.deselectButtons();
			var myAlert:Alert = Alert.show("Are you sure you wish to delete this asset?", "Delete Asset", Alert.OK | Alert.CANCEL, null, assetDelete_Confirm, null, Alert.CANCEL);
			myAlert.height=100;
			myAlert.width=300;
		}
		
		// Deletes an asset
		private function assetDelete_Confirm(e:CloseEvent):void {
			if (e.detail==Alert.OK) {
				AppModel.getInstance().deleteAsset(assetData.base_asset_id);
			}
		}
		
		// Shows or hides the comments window
		private function toggleComments():void {
			// If the 'share' panel is up, hide it
			if((view as AssetCollectionView).share.width > 0) {
				toggleShare();
			}
			if((view as AssetCollectionView).comments.width == 0) {
				showComments();
				(view as AssetCollectionView).navbar.selectButtonName("comments");
			} else {
				hideComments();
				(view as AssetCollectionView).navbar.deselectButtonName("comments");
			}
		}
		
		// Shows or hides the shared access window
		private function toggleShare():void {
			// if the comment panel is visible, hide it.
			try {
				if((view as AssetCollectionView).comments.width > 0) {
					toggleComments();
				}			
				if((view as AssetCollectionView).share.width == 0) {
					showSharing();
						(view as AssetCollectionView).navbar.selectButtonName("share");
				} else {
					hideSharing();
					(view as AssetCollectionView).navbar.deselectButtonName("share");
				}
			} catch (e:Error) { trace("#43278 NEED TO FIX THIS"); }
		}
		
		// Shows or hides the options/edit window
		private function toggleOptions():void {
			if((view as AssetCollectionView).options.height == 0) {
				showOptions();
				(view as AssetCollectionView).navbar.selectButtonName("edit");
			} else {
				hideOptions();
				(view as AssetCollectionView).navbar.deselectButtonName("edit");
			}
		}
		
		// Animation which hides the comments view
		private function hideComments():void {
			UserPreferences.commentsWidth = (view as AssetCollectionView).commentsholder.width;
			Lib.it.transitions.Tweener.addTween((view as AssetCollectionView).commentsholder,{width:0,transition:"easeInOutCubic",time:0.5,alpha:0});
		}
		
		// Animation which shows the comments view
		private function showComments():void {
			Lib.it.transitions.Tweener.addTween((view as AssetCollectionView).commentsholder,{width:UserPreferences.commentsWidth,transition:"easeInOutCubic",time:0.5,alpha:1});
		}
		
		// Animation which hides the shared access view
		private function hideSharing():void {
			(view as AssetCollectionView).assetsharing.hideButton();
			Lib.it.transitions.Tweener.addTween((view as AssetCollectionView).share,{width:0,transition:"easeInOutCubic",time:0.5,alpha:0});
		}
		
		// Animation which shows the shared access view
		private function showSharing():void {
			(view as AssetCollectionView).assetsharing.showButton();
			Lib.it.transitions.Tweener.addTween((view as AssetCollectionView).share,{width:UserPreferences.commentsWidth,transition:"easeInOutCubic",time:0.5,alpha:1});
			
		}
		
		// Animation which hides the options/edit view
		private function hideOptions():void {
			Lib.it.transitions.Tweener.addTween((view as AssetCollectionView).options,{height:0,transition:"easeInOutCubic",time:0.5,alpha:0});
		}
		
		// Animation which shows the options/edit view
		private function showOptions():void {
			Lib.it.transitions.Tweener.addTween((view as AssetCollectionView).options,{height:optionsHeight,transition:"easeInOutCubic",time:0.5,alpha:1});
		}
	}
}