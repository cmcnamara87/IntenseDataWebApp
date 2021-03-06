package Controller {
	
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	import Controller.Utilities.UserPreferences;
	
	import Lib.it.transitions.Tweener;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import Module.AudioViewer.AudioView;
	import Module.ImageViewer.ImageView;
	import Module.PDFViewer.PDFViewer;
	
	import View.AssetView;
	import View.Element.AssetOptionsForm;
	import View.MediaView;
	import View.ModuleWrapper.*;
	import View.components.Panels.Comments.NewComment;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class MediaController extends AppController {
		
		
//		private var assetData:Model_Media;
		private var comments:Array = new Array();
		private var annotations:Array = new Array();
		private var module:UIComponent;
		private var optionsHeight:Number = 200;
		private var commentToDelete:Number = 0;
		private var moduleInstance:*;
		private var ModuleClass:Class;
		
		// My variables
		private var mediaView:MediaView;	// The current view we are looking at - The Media View
		private static var currentAssetID:Number = 0;		// The ID of the media asset we are viewing.
		public static var currentMediaData:Model_Media;
		
		//Calls the superclass, sets the AssetID
		public function MediaController() {
			
			// Get out the assets ID
			currentAssetID = Dispatcher.getArgs()[0];
			trace("Media Asset ID:", currentAssetID);
			
			// Setup the View
			mediaView =  new MediaView(saveAnnotation);
			
			// Pass this view to the parent
			view = mediaView;
			super();
		}
		
		//INIT
		override public function init():void {
			setupEventListeners();
			
			loadMediaAsset();
			
			
//			setupNavbar();
//			loadData();
//			(view as AssetView).commentsholder.width = UserPreferences.commentsWidth;
		}
		
		/**
		 * Setup Event Listeners for the view 
		 * 
		 */		
		private function setupEventListeners():void {
			// Listen for "Save Comment" button being clicked.
			mediaView.addEventListener(IDEvent.COMMENT_SAVED, saveComment);
			mediaView.addEventListener(IDEvent.COMMENT_DELETE, deleteComment);
			mediaView.addEventListener(IDEvent.COMMENT_EDITED, saveEditedComment);
			
			// Listen for 'Save Sharing' autosave
			mediaView.addEventListener(IDEvent.SHARING_CHANGED, sharingInfoChanged);
			
			// Listen for 'Save Annotation'
			mediaView.addEventListener(IDEvent.ANNOTATION_SAVE_BOX, saveNewBoxAnnotation);
			mediaView.addEventListener(IDEvent.ANNOTATION_SAVE_PEN, saveNewPenAnnotation);
			mediaView.addEventListener(IDEvent.ANNOTATION_SAVE_HIGHLIGHT, saveNewHighlightAnnotation);
			// Listen for 'Annotation Deleted'
			mediaView.addEventListener(IDEvent.ANNOTATION_DELETED, deleteAnnotation);
			
			// Listen for Details for the Media being updated
			mediaView.addEventListener(IDEvent.ASSET_UPDATE, updateMediaDetails);
			
			// Listen for Asset being deleted
			mediaView.addEventListener(IDEvent.MEDIA_ASSET_DELETE_BUTTON_CLICKED, deleteAssetButtonClicked);

			
//			(view as AssetView).navbar.addEventListener(RecensioEvent.NAV_CLICKED,navBarClicked);
//			(view as AssetView).comments.addEventListener(RecensioEvent.COMMENT_NAV_CLICKED,commentNavClicked);
//			(view as AssetView).assetoptions.addEventListener(RecensioEvent.ASSET_UPDATE,optionsUpdated);
//			(view as AssetView).assetsharing.addEventListener(RecensioEvent.SHARED_SAVED,sharedUpdated);
		}
		
		
		/* ================ FUNCTIONS THAT CALL THE DATABASE ================ */
		private function loadMediaAsset():void {
			trace("Loading Media Asset...");
			
			// the browser controller knows which asset was clicked
			// get the asset data from the browser, and use that to load this asset
			currentMediaData = BrowserController.currentMediaData;
			
			if(currentMediaData == null) {
				trace("MediaController:loadMediaAsset - no media data saved!!! - Looking up currentAssetID" + currentAssetID);
				// For some reason, the browser doesnt have to data, so we will have to load it here
				AppModel.getInstance().getThisMediasData(currentAssetID, mediasDataLoaded);
				return;
			} else {
				trace("MediaController:loadMediaAsset - Saved media data " + currentMediaData.base_asset_id);
			}
			
			mediaView.addMediaData(currentMediaData);
			
			// Get the data for the panels
			loadPanelData();
			
			
			// Load the Media Asset Data
			// Gets out the Media Meta-data
//			AppModel.getInstance().getThisMediasData(currentAssetID, mediasDataLoaded);
			
			// Don't get out the comments etc here, we need to know the medias type,
			// before we can add them.
			// because we need to know what kind of ... view to make i think
			
		}
		
		/**
		 * The delete asset button was clicked. Show a confirmation window, that directs to @see deleteAsset
		 * @param e		The button click event
		 * 
		 */	
		private function deleteAssetButtonClicked(e:IDEvent):void {
			//(view as AssetView).navbar.deselectButtons();
			var myAlert:Alert = Alert.show("Are you sure you wish to delete this file?", "Delete File", Alert.OK | Alert.CANCEL, null, deleteAsset, null, Alert.CANCEL);
			myAlert.height=100;
			myAlert.width=300;
		}
		
		/**
		 * Deletes an asset (redirects to BrowserController afterwards) 
		 * @param e
		 * 
		 */		
		private function deleteAsset(e:CloseEvent):void {
			if (e.detail==Alert.OK) {
				//AppModel.getInstance().deleteAsset(currentAssetID, currentMediaData.meta_username);
				BrowserController.clearCurrentCollectionMedia();
				AppModel.getInstance().deleteMedia(currentAssetID, currentMediaData.base_creator_username);
			}
		}
		
		/**
		 * Saves a comment 
		 * @param e	e.data.commentText - Contains the comment text, e.data.newCommentObject=the
		 * actual comment.
		 * 
		 */		
		private function saveComment(e:IDEvent):void {
			trace('Saving comment: ', e.data.commentText, 'in reply to asset:', currentAssetID, 'reply to comment:', e.data.replyingToID);
			
			AppModel.getInstance().saveNewComment(	e.data.commentText, currentAssetID, e.data.replyingToID,
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
		
		private function saveEditedComment(e:IDEvent):void {
			AppModel.getInstance().editComment(e.data.commentID, e.data.commentText, function(e:Event):void {
				AppModel.getInstance().getThisAssetsCommentary(currentAssetID, mediasCommentaryLoaded);
			});
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
			
			super.removeLogoutListener();
			
			var username:String = e.data.username;
			var access:String = e.data.access;
			AppModel.getInstance().changeAccess(currentAssetID, username, "system", access, false, sharingInfoUpdated);
		}
		
		
 		//Called when an annotation is saved.  Sets the data correctly and pushes the information to the model
		private function saveNewBoxAnnotation(e:IDEvent):void {
			trace("- Media Controller: Saving Annotation...");
			// Unpack the event data
			var xCoor:Number = e.data.xCoor;
			var yCoor:Number = e.data.yCoor;
			var width:Number = e.data.width;
			var height:Number = e.data.height;
			var annotationText:String = e.data.annotationText;
			
			AppModel.getInstance().saveNewBoxAnnotation(
				currentAssetID,
				xCoor,
				yCoor,
				width,
				height,
				0,
				0,
				annotationText,
				newAnnotationSaved
			);
		}
		
		private function saveNewPenAnnotation(e:IDEvent):void {
			trace("- Media Controller: Saving Annotation...");
			// Unpack the event data
			var path:String = e.data.path;
			var text:String = e.data.text;
			AppModel.getInstance().saveNewPenAnnotation(
				currentAssetID,
				path,
				text,
				newAnnotationSaved
			);
		}
		
		private function saveNewHighlightAnnotation(e:IDEvent):void {
			trace("- Saving annotation highlight");
			var xCoor:Number = e.data.xCoor;
			var yCoor:Number = e.data.yCoor;
			var page1:Number = e.data.page1;
			var startTextIndex:Number = e.data.startTextIndex;
			var endTextIndex:Number = e.data.endTextIndex;
			var text:String = e.data.text;
			
			AppModel.getInstance().saveNewHighlightAnnotation(
				currentAssetID,
				xCoor,
				yCoor,
				page1,
				startTextIndex,
				endTextIndex,
				text,
				newAnnotationSaved
			)
		}
		
		// DEKKERS ANNOTATION CODE TODO REMOVE THIS FUNCTION
		// Called when an annotation is saved.  Sets the data correctly and pushes the information to the model
		public function saveAnnotation(items:Array):void {
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
				items[i].parentID = currentAssetID;
				AppModel.getInstance().saveAnnotation(items[i]);
			}
			
			setTimeout(getAnnotations, 1500);
		}
		
		// TODO REMOVE THIS FUNCTION (ONLY SO WE CAN UPDATE ANNOTATIONS FROM DEKKERS CODE
		private function getAnnotations():void {
			AppModel.getInstance().getThisAssetsCommentary(currentAssetID, mediasCommentaryLoaded);
		}
		
		private function deleteAnnotation(e:IDEvent):void {
			trace("Deleting Annotation");
			AppModel.getInstance().deleteAnnotation2(e.data.assetID, annotationDeleted);
		}
		
		private function updateMediaDetails(e:IDEvent):void {
			trace("Updating media details");
			AppModel.getInstance().updateAsset(e.data, mediaDetailsUpdated);
		} 
		
		/* ================ CALLBACK FUNCTIONS FROM THE DATABASE ================== */
		/**
		 * Called when the list of Users and Permissions for the current media asset
		 * is returned. 
		 * @param userData	An array of users + permissions for the asset.
		 * 
		 */		
		private function sharingDataLoaded(userData:Array):void {
			// Send the data to view
			trace("Permissions Retrieved");
			trace("MediaController:SharingDataLoaded - Looking at this asset in collection", BrowserController.currentCollectionID);
			
			if(currentMediaData != null) {
				mediaView.setupAssetsSharingInformation(userData, currentMediaData.base_creator_username);
			} else {
				mediaView.setupAssetsSharingInformation(userData, "");
			}
		}
		
		private function peopleCollectionLoaded(peopleCollection:Array):void {
			mediaView.addPeople(peopleCollection);
		}
		
		private function mediasCommentaryLoaded(e:Event):void {
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			var commentsForMedia:Array = AppModel.getInstance().extractCommentsFromXML(data);
			
			var annotationsForMedia:Array = AppModel.getInstance().extractAnnotationsFromXML(data);
			// Add all the comments for this collection
			// Send the collection ID, and all the comments
			mediaView.addComments(commentsForMedia);
			
			// Add all the annotations for this media
			mediaView.addAnnotations(annotationsForMedia);

		}
		
		private function mediasDataLoaded(e:Event):void {
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
//			trace(data);
			
			var media:Model_Media = AppModel.getInstance().extractMedia(data);
			
			currentMediaData = media;
			
			// Pass this data to the view.
			mediaView.addMediaData(media);
			
			// Gets out the Commentary Data for hte asset (that is, comments and annotations
			AppModel.getInstance().getThisAssetsCommentary(currentAssetID, mediasCommentaryLoaded);
			
			
			// Get out the People data
			AppModel.getInstance().getPeople(media.meta_users_access, peopleCollectionLoaded);
				
			// Load the Sharing Data
			AppModel.getInstance().getAccess(currentAssetID, sharingDataLoaded);
		}
		
		private function loadPanelData():void {
			// Gets out the Commentary Data for hte asset (that is, comments and annotations
			AppModel.getInstance().getThisAssetsCommentary(currentAssetID, mediasCommentaryLoaded);
			
			// Get out the People data
			AppModel.getInstance().getPeople(currentMediaData.meta_users_access, peopleCollectionLoaded);
			
			// Load the Sharing Data
			AppModel.getInstance().getAccess(currentAssetID, sharingDataLoaded);
		}
		
		/**
		 * The comment has been saved. 
		 * @param commentID			The ID for the saved comment
		 * @param commentText		The text for the saved comment
		 * @param newCommentObject	The NewCommentObject that is to be replaced by a regular comment.
		 * 
		 */		
		public function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void {
			mediaView.commentSaved(commentID, commentText, newCommentObject);
		}

		
		public function newAnnotationSaved(e:Event):void {
			// Get out the ID of this new annotation
			var dataXML:XML = XML(e.target.data);
			if (dataXML.reply.@type != "result") {
				// Failed to save.
				Alert.show("Could not save annotation");
				trace("Could not save annotation", e.target.data);
				return;
			}
			
			// The annotation was saved
			var annotationID:Number = dataXML.reply.result.id;
			
			// Copy the access from the parent media asset, to the annotation
			// TODO race issue here, if  we exit the media, before the saving is done
			AppModel.getInstance().copyAccess(currentAssetID, annotationID);
			
			// Set the class for this annotation to be Annotation
			AppModel.getInstance().setAnnotationClassForID(annotationID, function(e:Event):void {
				// After setting the annotation class, get all the commentary for this media asset
				// And reload them so they show on the asset.
				AppModel.getInstance().getThisAssetsCommentary(currentAssetID, mediasCommentaryLoaded);	
			});
			
			// So lets just get out all the annotations/comments again
			// so we can update the display with the new annotation
			
			
			
		}
		
		public function annotationDeleted(e:Event):void {
			AppModel.getInstance().getThisAssetsCommentary(currentAssetID, mediasCommentaryLoaded);
		}
		
		private function mediaDetailsUpdated(e:Event):void {
			var baseXML:XML = XML(e.target.data);
			if(baseXML.reply.@type == "result") {
				// Successfully changed the medias data
				mediaView.detailsSaved(true);
			} else {
				// Change failed
				trace("Failed to update medias details", e.target.data);
				mediaView.detailsSaved(false);
			}
		}
		/**
		 * The database has replied about updating the collections shared information. 
		 * @param e
		 * 
		 */		
		private function sharingInfoUpdated(e:Event):void {
			super.addLogoutListener();
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			// Was the sharing update not access
			if(data.reply.@type == "result") {
				// Sharing update successfully
				trace("Sharing Updated Successfully", e.target.data);
				mediaView.unlockSharingPanelUsers();
				trace("-------------------------");
			} else {
				Alert.show("Sharing Update Failed");
				trace("Sharing Update Failed", e.target.data);
			} 
		}
		
//		// Loads the asset information, the annotations for the asset, and the current users in mediaflux (for sharing)
//		private function loadData():void {
//			AppModel.getInstance().getAsset(assetID,assetLoaded);
//			AppModel.getInstance().getAnnotations(assetID,annotationsLoaded);
//			AppModel.getInstance().getAccess(assetID,userListLoaded);
//			(view as AssetView).navbar.overwriteSelection = true;
//		}
//		
//		// Called when the current users is returned, and passes them to the sharing view
//		private function userListLoaded(userData:Array):void {
//			(view as AssetView).assetsharing.setShared(userData);
//		}
//		
//		// Called when the asset is loaded, validates the asset and then calls loadModule
//		private function assetLoaded(e:Event):void {
//			trace(e.target.data);
//			var assets:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Media);
//			assetData = assets[0];
//			if(assetData) {
//				(view as AssetView).navbar.setHeading(assetData.meta_title);
//				setTimeout(loadModule,100);
//				(view as AssetView).assetoptions.setFormValuesMedia(assetData);
//				(view as AssetView).stage.dispatchEvent(new Event(Event.RESIZE));
//			} else {
//				Alert.show("Could not access asset");
//				Dispatcher.call("browse");
//			}
//			setAccess();
//		}
//		
//		private function setAccess():void {
//			if(!assetData.access_modify) {
//				(view as AssetView).navbar.removeButton("share");
//				(view as AssetView).navbar.removeButton("edit");
//				(view as AssetView).navbar.removeButton("delete");
//			}
//		}
//		
//		// Loads the module for the specific asset media type
//		// load() addAnnotations() and annotationSave=myFunction();
//		private function loadModule():void {
//			var type:String = AssetLookup.getCommonType(assetData.base_type);
//			ModuleClass = AssetLookup.getClass(type);
//			if(ModuleClass) {
//				moduleInstance = new ModuleClass();
//				try {
//					(moduleInstance as ModuleClass).viewer.addEventListener(RecensioEvent.MODULE_FAIL,moduleFail);
//					if((moduleInstance as ModuleClass).external) {
//						var uri:String = (moduleInstance as ModuleClass).formatURI(assetData.meta_media_uri);
//						(moduleInstance as ModuleClass).viewer.load(uri);
//					} else {
//						(moduleInstance as ModuleClass).viewer.load(assetData.generateMediaURL());
//					}
//					(moduleInstance as ModuleClass).viewer.annotationSave = saveAnnotation;
//					(moduleInstance as ModuleClass).viewer.annotationDelete = deleteAnnotation;
//				} catch (e:Error) {
//					ModuleClass = Module_Missing;
//					moduleInstance = new Module_Missing();
//					(moduleInstance as Module_Missing).failureDescription.text = e.message;
//				}
//				(view as AssetView).viewWrapper.addElement(moduleInstance);
//				if(annotations.length > 0) {
//					try {
//						(moduleInstance as ModuleClass).viewer.addAnnotations(annotations);
//					} catch (e:Error) {
//						Alert.show(e.message);
//						Dispatcher.call("browse");
//					}
//				}
//			}
//		}
//		
//		//Called when a module encounters an error
//		private function moduleFail(e:RecensioEvent):void {
//			trace("DING DING DING");
//			(view as AssetView).viewWrapper.removeAllElements();
//			ModuleClass = Module_Missing;
//			moduleInstance = new Module_Missing();
//			(moduleInstance as Module_Missing).failureDescription.text = e.data.code;
//			(view as AssetView).viewWrapper.addElement(moduleInstance);
//			trace(e.data.code);
//		}
//		
//		z
//		
//		private function deleteAnnotation(annotationID:Number):void {
//			AppModel.getInstance().deleteAnnotation(annotationID);
//		}
//		
//		// Called when the annotations and comments are loaded from mediaflux.  Pushes the annotations and comments to the module and the view respectively.
//		private function annotationsLoaded(e:Event):void {
//			removeAnnotations();
//			var annotationsData:Array = AppModel.getInstance().parseResults(XML(e.target.data),Model_Annotation);
//			for(var i:Number=0; i<annotationsData.length; i++) {
//				if((annotationsData[i] as Model_Annotation).isAnnotation()) {
//					annotations.push(annotationsData[i]);
//				} else {
//					comments.push(annotationsData[i]);
//				}
//			}
//			(view as AssetView).comments.addComments(comments);
//			try {
//				(moduleInstance as ModuleClass).viewer.addAnnotations(annotations);
//			} catch (e:Error) {
//				trace(e.message);
//				trace("Not sure whats happening here");
//			}
//		}
//		
//		// Called when the comments and annotations should be cleared out.
//		public function removeAnnotations():void {
//			comments = new Array();
//			annotations = new Array();
//		}
//		

//		
//		// Called when the update shared information button is clicked.  Sends the new access rights to the model and hides the sharing view
//		private function sharedUpdated(e:RecensioEvent):void {
//			AppModel.getInstance().setAccess(assetID,e.data.access);
//			toggleComments();
//		}
//		
//		// Called when the update options button is clicked.  Sends the new options meta-information to the model and hides the options view
//		private function optionsUpdated(e:RecensioEvent):void {
//			e.data.assetID = assetID;
//			AppModel.getInstance().updateAsset(e.data);
//			hideOptions();
//			(view as AssetView).navbar.deselectButtonName("edit");
//			(view as AssetView).navbar.setHeading(e.data.meta_title);
//		}
//		
//		// When a comments menu navigation is clicked.  Deletes and saves comments where appropriate
//		private function commentNavClicked(e:RecensioEvent):void {
//			switch(e.data.action) {
//				case 'Reply':
//				case 'Save':
//					e.data.parentID = assetID;
//					trace("I got:", e.data.annotation_text);
//					AppModel.getInstance().saveComment(e.data);
//					break;
//				case 'Delete':
//					commentToDelete = int(e.data.assetID);
//					commentDelete_Alert();
//					break;
//			}
//		}
//		
//		// Sets up the navigation bar
//		private function setupNavbar():void {
//			(view as AssetView).navbar.addHeading("Loading...");
//			(view as AssetView).navbar.addButton("comments","right",true);
//			(view as AssetView).navbar.addButton("share","right");
//			(view as AssetView).navbar.addButton("edit","right");
//			(view as AssetView).navbar.addButton("delete","right");
//			(view as AssetView).navbar.addButton("back","right");
//			(view as AssetView).navbar.defaultSelect("comments");
//		}
//		
//		// Called when a button on the navigation bar is clicked
//		private function navBarClicked(e:RecensioEvent):void {
//			switch(e.data.buttonName) {
//				case 'back':
//					Dispatcher.call("browse");
//					break;
//				case 'delete':
//					assetDelete_Alert();
//					break;
//				case 'comments':
//					toggleComments();
//					break;
//				case 'edit':
//					toggleOptions();
//					break;
//				case 'share':
//					toggleShare();
//					break;
//			}
//		}
//		
//		// Alert dialog to confirm whether a comment should be deleted
//		private function commentDelete_Alert():void {
//			(view as AssetView).navbar.deselectButtons();
//			var myAlert:Alert = Alert.show("Are you sure you wish to delete this comment?", "Delete Comment", Alert.OK | Alert.CANCEL, null, commentDelete_Confirm, null, Alert.CANCEL);
//			myAlert.height=100;
//			myAlert.width=300;
//		}
//		
//		// Deletes a comment
//		private function commentDelete_Confirm(e:CloseEvent):void {
//			if (e.detail==Alert.OK) {
//				AppModel.getInstance().deleteComment(commentToDelete);
//				(view as AssetView).comments.removeCommentById(commentToDelete);
//			}
//			commentToDelete = 0;
//		}
//		
//		// Alert dialog to confirm whether the asset should be deleted
//		private function assetDelete_Alert():void {
//			(view as AssetView).navbar.deselectButtons();
//			var myAlert:Alert = Alert.show("Are you sure you wish to delete this asset?", "Delete Asset", Alert.OK | Alert.CANCEL, null, assetDelete_Confirm, null, Alert.CANCEL);
//			myAlert.height=100;
//			myAlert.width=300;
//		}
//		
//		// Deletes an asset
//		private function assetDelete_Confirm(e:CloseEvent):void {
//			if (e.detail==Alert.OK) {
//				AppModel.getInstance().deleteAsset(assetData.base_asset_id);
//			}
//		}
//		
//		// Shows or hides the comments window
//		private function toggleComments():void {
//			if((view as AssetView).share.width > 0) {
//				toggleShare();
//			}
//			if((view as AssetView).comments.width == 0) {
//				showComments();
//				(view as AssetView).navbar.selectButtonName("comments");
//			} else {
//				hideComments();
//				(view as AssetView).navbar.deselectButtonName("comments");
//			}
//		}
//		
//		// Shows or hides the shared access window
//		private function toggleShare():void {
//			if((view as AssetView).comments.width > 0) {
//				toggleComments();
//			}
//			if((view as AssetView).share.width == 0) {
//				showSharing();
//				(view as AssetView).navbar.selectButtonName("share");
//			} else {
//				hideSharing();
//				(view as AssetView).navbar.deselectButtonName("share");
//			}
//		}
//		
//		// Shows or hides the options/edit window
//		private function toggleOptions():void {
//			if((view as AssetView).options.height == 0) {
//				showOptions();
//				(view as AssetView).navbar.selectButtonName("edit");
//			} else {
//				hideOptions();
//				(view as AssetView).navbar.deselectButtonName("edit");
//			}
//		}
//		
//		// Animation which hides the comments view
//		private function hideComments():void {
//			UserPreferences.commentsWidth = (view as AssetView).commentsholder.width;
//			Lib.it.transitions.Tweener.addTween((view as AssetView).commentsholder,{width:0,transition:"easeInOutCubic",time:0.5,alpha:0});
//		}
//		
//		// Animation which shows the comments view
//		private function showComments():void {
//			Lib.it.transitions.Tweener.addTween((view as AssetView).commentsholder,{width:UserPreferences.commentsWidth,transition:"easeInOutCubic",time:0.5,alpha:1});
//		}
//		
//		// Animation which hides the shared access view
//		private function hideSharing():void {
//			Lib.it.transitions.Tweener.addTween((view as AssetView).share,{width:0,transition:"easeInOutCubic",time:0.5,alpha:0});
//		}
//		
//		// Animation which shows the shared access view
//		private function showSharing():void {
//			Lib.it.transitions.Tweener.addTween((view as AssetView).share,{width:UserPreferences.commentsWidth,transition:"easeInOutCubic",time:0.5,alpha:1});
//		}
//		
//		// Animation which hides the options/edit view
//		private function hideOptions():void {
//			Lib.it.transitions.Tweener.addTween((view as AssetView).options,{height:0,transition:"easeInOutCubic",time:0.5,alpha:0});
//		}
//		
//		// Animation which shows the options/edit view
//		private function showOptions():void {
//			Lib.it.transitions.Tweener.addTween((view as AssetView).options,{height:optionsHeight,transition:"easeInOutCubic",time:0.5,alpha:1});
//		}
	}
}