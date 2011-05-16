package Controller {
	
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	import Controller.Utilities.UserPreferences;
	
	import Lib.it.transitions.Tweener;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import Module.AudioViewer.AudioView;
	import Module.PDFViewer.PDFViewer;
	
	import View.AssetView;
	import View.Element.AssetOptionsForm;
	import View.ModuleWrapper.*;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class AssetViewMediaController extends AppController {
		
		private var assetID:Number = 0;
		private var assetData:Model_Media;
		private var comments:Array = new Array();
		private var annotations:Array = new Array();
		private var module:UIComponent;
		private var optionsHeight:Number = 200;
		private var commentToDelete:Number = 0;
		private var moduleInstance:*;
		private var ModuleClass:Class;
		
		//Calls the superclass, sets the AssetID
		public function AssetViewMediaController() {
			assetID = Dispatcher.getArgs()[0];
			view = new AssetView();
			super();
		}
		
		//INIT
		override public function init():void {
			setupEventListeners();
			setupNavbar();
			loadData();
			(view as AssetView).commentsholder.width = UserPreferences.commentsWidth;
		}
		
		// Loads the asset information, the annotations for the asset, and the current users in mediaflux (for sharing)
		private function loadData():void {
			AppModel.getInstance().getAsset(assetID,assetLoaded);
			AppModel.getInstance().getAnnotations(assetID,annotationsLoaded);
			AppModel.getInstance().getAccess(assetID,userListLoaded);
			(view as AssetView).navbar.overwriteSelection = true;
		}
		
		// Called when the current users is returned, and passes them to the sharing view
		private function userListLoaded(userData:Array):void {
			(view as AssetView).assetsharing.setShared(userData);
		}
		
		// Called when the asset is loaded, validates the asset and then calls loadModule
		private function assetLoaded(e:Event):void {
			trace(e.target.data);
			var assets:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Media);
			assetData = assets[0];
			if(assetData) {
				(view as AssetView).navbar.setHeading(assetData.meta_title);
				setTimeout(loadModule,100);
				(view as AssetView).assetoptions.setFormValuesMedia(assetData);
				(view as AssetView).stage.dispatchEvent(new Event(Event.RESIZE));
			} else {
				Alert.show("Could not access asset");
				Dispatcher.call("browse");
			}
			setAccess();
		}
		
		private function setAccess():void {
			if(!assetData.access_modify) {
				(view as AssetView).navbar.removeButton("share");
				(view as AssetView).navbar.removeButton("edit");
				(view as AssetView).navbar.removeButton("delete");
			}
		}
		
		// Loads the module for the specific asset media type
		// load() addAnnotations() and annotationSave=myFunction();
		private function loadModule():void {
			var type:String = AssetLookup.getCommonType(assetData.base_type);
			ModuleClass = AssetLookup.getClass(type);
			if(ModuleClass) {
				moduleInstance = new ModuleClass();
				try {
					(moduleInstance as ModuleClass).viewer.addEventListener(RecensioEvent.MODULE_FAIL,moduleFail);
					if((moduleInstance as ModuleClass).external) {
						trace("its a 'internal' thing");
						var uri:String = (moduleInstance as ModuleClass).formatURI(assetData.meta_media_uri);
						(moduleInstance as ModuleClass).viewer.load(uri);
					} else {
						trace("its a 'external' thing");
						(moduleInstance as ModuleClass).viewer.load(assetData.generateMediaURL());
					}
					(moduleInstance as ModuleClass).viewer.annotationSave = saveAnnotation;
					(moduleInstance as ModuleClass).viewer.annotationDelete = deleteAnnotation;
				} catch (e:Error) {
					ModuleClass = Module_Missing;
					moduleInstance = new Module_Missing();
					(moduleInstance as Module_Missing).failureDescription.text = e.message;
				}
				(view as AssetView).viewWrapper.addElement(moduleInstance);
				if(annotations.length > 0) {
					try {
						(moduleInstance as ModuleClass).viewer.addAnnotations(annotations);
					} catch (e:Error) {
						Alert.show(e.message);
						Dispatcher.call("browse");
					}
				}
			}
		}
		
		//Called when a module encounters an error
		private function moduleFail(e:RecensioEvent):void {
			trace("DING DING DING");
			(view as AssetView).viewWrapper.removeAllElements();
			ModuleClass = Module_Missing;
			moduleInstance = new Module_Missing();
			(moduleInstance as Module_Missing).failureDescription.text = e.data.code;
			(view as AssetView).viewWrapper.addElement(moduleInstance);
			trace(e.data.code);
		}
		
		// Called when an annotation is saved.  Sets the data correctly and pushes the information to the model
		private function saveAnnotation(items:Array):void {
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
		}
		
		private function deleteAnnotation(annotationID:Number):void {
			AppModel.getInstance().deleteAnnotation(annotationID);
		}
		
		// Called when the annotations and comments are loaded from mediaflux.  Pushes the annotations and comments to the module and the view respectively.
		private function annotationsLoaded(e:Event):void {
			removeAnnotations();
			var annotationsData:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Commentary);
			for(var i:Number=0; i<annotationsData.length; i++) {
				if((annotationsData[i] as Model_Commentary).isAnnotation()) {
					annotations.push(annotationsData[i]);
				} else {
					comments.push(annotationsData[i]);
				}
			}
			(view as AssetView).comments.addComments(comments);
			try {
				(moduleInstance as ModuleClass).viewer.addAnnotations(annotations);
			} catch (e:Error) {
				trace(e.message);
				trace("Not sure whats happening here");
			}
		}
		
		// Called when the comments and annotations should be cleared out.
		public function removeAnnotations():void {
			comments = new Array();
			annotations = new Array();
		}
		
		// Sets up event listeners for the view
		private function setupEventListeners():void {
			(view as AssetView).navbar.addEventListener(RecensioEvent.NAV_CLICKED,navBarClicked);
			(view as AssetView).comments.addEventListener(RecensioEvent.COMMENT_NAV_CLICKED,commentNavClicked);
			(view as AssetView).assetoptions.addEventListener(RecensioEvent.ASSET_UPDATE,optionsUpdated);
			(view as AssetView).assetsharing.addEventListener(RecensioEvent.SHARED_SAVED,sharedUpdated);
		}
		
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
			(view as AssetView).navbar.deselectButtonName("edit");
			(view as AssetView).navbar.setHeading(e.data.meta_title);
		}
		
		// When a comments menu navigation is clicked.  Deletes and saves comments where appropriate
		private function commentNavClicked(e:RecensioEvent):void {
			switch(e.data.action) {
				case 'Reply':
				case 'Save':
					e.data.parentID = assetID;
					AppModel.getInstance().saveComment(e.data);
					break;
				case 'Delete':
					commentToDelete = int(e.data.assetID);
					commentDelete_Alert();
					break;
			}
		}
		
		// Sets up the navigation bar
		private function setupNavbar():void {
			(view as AssetView).navbar.addHeading("Loading...");
			(view as AssetView).navbar.addButton("comments","right",true);
			(view as AssetView).navbar.addButton("share","right");
			(view as AssetView).navbar.addButton("edit","right");
			(view as AssetView).navbar.addButton("delete","right");
			(view as AssetView).navbar.addButton("back","left",true);
			(view as AssetView).navbar.defaultSelect("comments");
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
			(view as AssetView).navbar.deselectButtons();
			var myAlert:Alert = Alert.show("Are you sure you wish to delete this comment?", "Delete Comment", Alert.OK | Alert.CANCEL, null, commentDelete_Confirm, null, Alert.CANCEL);
			myAlert.height=100;
			myAlert.width=300;
		}
		
		// Deletes a comment
		private function commentDelete_Confirm(e:CloseEvent):void {
			if (e.detail==Alert.OK) {
				AppModel.getInstance().deleteComment(commentToDelete);
				(view as AssetView).comments.removeCommentById(commentToDelete);
			}
			commentToDelete = 0;
		}
		
		// Alert dialog to confirm whether the asset should be deleted
		private function assetDelete_Alert():void {
			(view as AssetView).navbar.deselectButtons();
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
			if((view as AssetView).share.width > 0) {
				toggleShare();
			}
			if((view as AssetView).comments.width == 0) {
				showComments();
				(view as AssetView).navbar.selectButtonName("comments");
			} else {
				hideComments();
				(view as AssetView).navbar.deselectButtonName("comments");
			}
		}
		
		// Shows or hides the shared access window
		private function toggleShare():void {
			if((view as AssetView).comments.width > 0) {
				toggleComments();
			}
			if((view as AssetView).share.width == 0) {
				showSharing();
				(view as AssetView).navbar.selectButtonName("share");
			} else {
				hideSharing();
				(view as AssetView).navbar.deselectButtonName("share");
			}
		}
		
		// Shows or hides the options/edit window
		private function toggleOptions():void {
			if((view as AssetView).options.height == 0) {
				showOptions();
				(view as AssetView).navbar.selectButtonName("edit");
			} else {
				hideOptions();
				(view as AssetView).navbar.deselectButtonName("edit");
			}
		}
		
		// Animation which hides the comments view
		private function hideComments():void {
			UserPreferences.commentsWidth = (view as AssetView).commentsholder.width;
			Lib.it.transitions.Tweener.addTween((view as AssetView).commentsholder,{width:0,transition:"easeInOutCubic",time:0.5,alpha:0});
		}
		
		// Animation which shows the comments view
		private function showComments():void {
			Lib.it.transitions.Tweener.addTween((view as AssetView).commentsholder,{width:UserPreferences.commentsWidth,transition:"easeInOutCubic",time:0.5,alpha:1});
		}
		
		// Animation which hides the shared access view
		private function hideSharing():void {
			Lib.it.transitions.Tweener.addTween((view as AssetView).share,{width:0,transition:"easeInOutCubic",time:0.5,alpha:0});
		}
		
		// Animation which shows the shared access view
		private function showSharing():void {
			Lib.it.transitions.Tweener.addTween((view as AssetView).share,{width:UserPreferences.commentsWidth,transition:"easeInOutCubic",time:0.5,alpha:1});
		}
		
		// Animation which hides the options/edit view
		private function hideOptions():void {
			Lib.it.transitions.Tweener.addTween((view as AssetView).options,{height:0,transition:"easeInOutCubic",time:0.5,alpha:0});
		}
		
		// Animation which shows the options/edit view
		private function showOptions():void {
			Lib.it.transitions.Tweener.addTween((view as AssetView).options,{height:optionsHeight,transition:"easeInOutCubic",time:0.5,alpha:1});
		}
	}
}