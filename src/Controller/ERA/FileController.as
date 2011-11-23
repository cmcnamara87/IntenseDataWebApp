package Controller.ERA {
	
	import Controller.AppController;
	import Controller.CollabController;
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	import Controller.Utilities.UserPreferences;
	
	import Lib.it.transitions.Tweener;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Model_ERAFile;
	import Model.Model_ERANotification;
	import Model.Model_ERARoom;
	import Model.Model_ERAUser;
	import Model.Model_Media;
	
	import Module.AudioViewer.AudioView;
	import Module.ImageViewer.ImageView;
	import Module.PDFViewer.PDFViewer;
	
	import View.AssetView;
	import View.ERA.FileView;
	import View.ERA.components.TimelineAnnotation;
	import View.Element.AssetOptionsForm;
	import View.MediaView;
	import View.ModuleWrapper.*;
	import View.components.Panels.Comments.NewComment;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class FileController extends CollabController {
		
		
		//		private var assetData:Model_Media;
		private var comments:Array = new Array();
		private var annotations:Array = new Array();
		private var module:UIComponent;
		private var optionsHeight:Number = 200;
		private var commentToDelete:Number = 0;
		private var moduleInstance:*;
		private var ModuleClass:Class;
		
		// My variables
		private var fileView:FileView;	// The current view we are looking at - The Media View
		private static var currentAssetID:Number = 0;		// The ID of the media asset we are viewing.
		public static var currentMediaData:Model_ERAFile;
		
		public static var roomType:String; // the type of hte room we are in
		public static var caseID:Number; // the id of the case we are in
		public static var rmCode:String; // the code for hte rm we are in
		public static var roomID:Number; // the id of the room we are in
		
		//Calls the superclass, sets the AssetID
		public function FileController() {
			
			// Setup the View
			fileView =  new FileView(saveAnnotation);
			
			// Pass this view to the parent
			view = fileView;
			super();
		}
		
		//INIT
		override public function init():void {
			layout.header.adminToolButtons.visible = false;
			layout.header.adminToolButtons.includeInLayout = false;
			layout.header.productionToolsButton.setStyle('chromeColor', '0x000000');
			
			// Get out the assets ID
			trace("number of args", Dispatcher.getArgs().length, Dispatcher.getArgs());
			if(Dispatcher.getArgs().length != 5) {
				Dispatcher.call('case');
				return;
			}
			
			caseID = Dispatcher.getArgs()[0];
			rmCode = unescape(Dispatcher.getArgs()[1]);
			roomType = Dispatcher.getArgs()[2];
			roomID = Dispatcher.getArgs()[3];
			currentAssetID = Dispatcher.getArgs()[4];
			trace("Media Asset ID:", currentAssetID);
			
			
			setupEventListeners();
			
			loadMediaAsset();
		}
		
		/**
		 * Setup Event Listeners for the view 
		 * 
		 */		
		private function setupEventListeners():void {
			// Listen for "Save Comment" button being clicked.
			fileView.addEventListener(IDEvent.COMMENT_SAVED, saveComment);
			fileView.addEventListener(IDEvent.COMMENT_DELETE, deleteComment);
			fileView.addEventListener(IDEvent.COMMENT_EDITED, saveEditedComment);
			
			// Listen for 'Save Sharing' autosave
			fileView.addEventListener(IDEvent.SHARING_CHANGED, sharingInfoChanged);
			
			// Listen for 'Save Annotation'
			fileView.addEventListener(IDEvent.ANNOTATION_SAVE_BOX, saveNewBoxAnnotation);
			fileView.addEventListener(IDEvent.ANNOTATION_SAVE_PEN, saveNewPenAnnotation);
			fileView.addEventListener(IDEvent.ANNOTATION_SAVE_HIGHLIGHT, saveNewHighlightAnnotation);
			// Listen for 'Annotation Deleted'
			fileView.addEventListener(IDEvent.ANNOTATION_DELETED, deleteAnnotation);
			
			// Listen for Details for the Media being updated
			fileView.addEventListener(IDEvent.ASSET_UPDATE, updateMediaDetails);
			
			// Listen for Asset being deleted
			fileView.addEventListener(IDEvent.MEDIA_ASSET_DELETE_BUTTON_CLICKED, deleteAssetButtonClicked);
			
			// Listen for version being upload
			fileView.addEventListener(IDEvent.ERA_SAVE_FILE, saveFile);
			// Listne for a file being downloaded
			fileView.addEventListener(IDEvent.ERA_DOWNLOAD_FILE, downloadFile);
			
			// Listen for someone trying to download a video segment
			fileView.addEventListener(IDEvent.ERA_DOWNLOAD_SEGMENT, downloadMediaSegment);
			
			fileView.addEventListener(IDEvent.ERA_GO_BACK, goBack);
		}
		
		/* =================================== UPLOAD A NEW VERSION ========================================= */
		private function saveFile(e:IDEvent):void {
			var file:FileReference = e.data.fileReference;
			
			layout.notificationBar.showProcess("Uploading file...");
			
			// get out the room IDs
//			trace("ROOM IDS ARE: EVIDNECE ROOM", getRoom(Model_ERARoom.EVIDENCE_ROOM).base_asset_id, "FORENSIC LAB", getRoom(Model_ERARoom.FORENSIC_LAB).base_asset_id);
			trace("ORIGINAL FILE ID IS", currentMediaData.originalFileID);

			AppModel.getInstance().uploadERAFileVersion(roomID, currentMediaData.base_asset_id, currentMediaData.originalFileID, 
				currentMediaData.type, currentMediaData.title, currentMediaData.description, file, 
				uploadIOError, uploadProgress, uploadComplete);
		}
		private function uploadIOError():void {
			layout.notificationBar.showError("Failed to Upload file.");
		}
		private function uploadProgress(percentage:Number):void {
			fileView.uploadNewVersionButton.label = "Uploaded " + percentage + "%";
		}
		private function uploadComplete(status:Boolean, eraEvidence:Model_ERAFile=null):void {
			if(status) {
				layout.notificationBar.showGood("Upload Complete");
				Dispatcher.showFile(caseID, rmCode, roomType, roomID, eraEvidence.base_asset_id);
			} else {
				Alert.show("Upload failed");
			}
		}
		/* =================================== END OF UPLOAD A NEW VERSION ========================================= */
		
		private function goBack(e:IDEvent):void {
			if(roomType != Model_ERARoom.SCREENING_ROOM) {
				Dispatcher.call("case/" + FileController.caseID + "/" + FileController.roomType);
			} else {
				// its the screening lab, so we need to ask 'do they want to save changes'
				// if they are a reserachers
				trace("*************** is researcher", CaseController.isResearcher ? "yes" : "no", "is moniotor", Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year) ? "yes" : "no");
				if((CaseController.isResearcher || Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year)) && !currentMediaData.lockedOut) {
					var myAlert:Alert = Alert.show("Have you finished commenting on this file for Review?", "Finished Commenting?", Alert.YES | Alert.NO, null, finishedCommenting, null, Alert.YES);
					myAlert.height = 100;
					myAlert.width = 300;
				} else {
					Dispatcher.call("case/" + FileController.caseID + "/" + FileController.roomType);
				}
			}
		}
		
		private function finishedCommenting(e:CloseEvent):void {
			if (e.detail==Alert.YES) {
				var myAlert:Alert = Alert.show("Do you approve of this file for ERA submission?", "File Approval", Alert.YES | Alert.NO, null, fileApproved, null, Alert.YES);
				myAlert.height = 100;
				myAlert.width = 300;
			} else {
				Dispatcher.call("case/" + FileController.caseID + "/" + FileController.roomType);
			}
		}
		
		private function fileApproved(e:CloseEvent):void {
			if(e.detail == Alert.YES) {
				trace("finished commenting an approve", currentAssetID);
				
				if(CaseController.isResearcher) {
					AppModel.getInstance().updateFileLockOutStatus(roomID, Model_ERANotification.FILE_APPROVED_BY_RESEARCHER, caseID, currentAssetID, lockOutStatusUpdated);
				}
				if(Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year)) {
					AppModel.getInstance().updateFileLockOutStatus(roomID, Model_ERANotification.FILE_APPROVED_BY_MONITOR, caseID, currentAssetID, lockOutStatusUpdated);
				}
			} else {
				trace("finished commenting an DO NOT approve");
				if(CaseController.isResearcher) {
					AppModel.getInstance().updateFileLockOutStatus(roomID, Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER, caseID, currentAssetID, lockOutStatusUpdated);
				}
				if(Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year)) {
					AppModel.getInstance().updateFileLockOutStatus(roomID, Model_ERANotification.FILE_NOT_APPROVED_BY_MONITOR, caseID, currentAssetID, lockOutStatusUpdated);
				}
			}
			
			Dispatcher.call("case/" + FileController.caseID + "/" + FileController.roomType);
		}
		
		private function lockOutStatusUpdated(status:Boolean):void {
			// oh well.
		}
		
		/* =================================== DOWNLOAD A FILE ========================================= */
		private function downloadFile(e:IDEvent):void {
			var fileID:Number = e.data.fileID;
			
			// We need to mark the file as downloaded, then let the user download it
			// set the download button as 'preparing for download' while we change it status to 'checked out'
			fileView.downloadButton.label = "Preparing for Download";
			fileView.downloadButton.enabled = false;
			
			// Tell the database to mark it as 'checked out'
			AppModel.getInstance().updateERAFileCheckOutStatus(fileID, true, fileCheckedOut);
		}
		private function fileCheckedOut(status:Boolean):void {
			if(!status) {
				layout.notificationBar.showError("Sorry, Could not checkout the file for download");
				return;
			}
			
			fileView.downloadButton.label = "Checked out by " + Auth.getInstance().getUserDetails().firstName + " " + Auth.getInstance().getUserDetails().lastName;
			fileView.downloadButton.enabled = false;
			
			// Download it now
			var url:String = currentMediaData.getDownloadURL();
			var req:URLRequest = new URLRequest(url);
			navigateToURL(req, 'Download');
		}
		/* =================================== END OF DOWNLOAD A FILE ========================================= */
		
		/* =================================== DOWNLOAD A VIDEO FILE SEGMENT ========================================= */
		private function downloadMediaSegment(e:IDEvent):void {
			var timelineAnnotation:TimelineAnnotation = e.data.timelineAnnotation;
			switch(currentMediaData.rootMetaType) {
				case AssetLookup.VIDEO:
					AppModel.getInstance().getVideoSegment(timelineAnnotation.videoID, timelineAnnotation.startTime, timelineAnnotation.endTime - timelineAnnotation.startTime, segmentReady);
					break;
				case AssetLookup.AUDIO:
					break;
				default:
					break;
			}
		}
		
		private function segmentReady(status:Boolean, videoLocation:String = ""):void {
			if(!status) {
				Alert.show("Segment Extraction Failed");
				return;
			}
			trace("segment ready!!!!!");
			
			var req:URLRequest = new URLRequest("http://" + Recensio_Flex_Beta.serverAddress+ "/" + videoLocation);
			navigateToURL(req, 'Download');
		}
		
		/* ================ FUNCTIONS THAT CALL THE DATABASE ================ */
		private function loadMediaAsset():void {
			trace("Loading Media Asset...");

			trace("MediaController:loadMediaAsset - no media data saved!!! - Looking up currentAssetID" + currentAssetID);
			// For some reason, the browser doesnt have to data, so we will have to load it here
			//AppModel.getInstance().getThisMediasData(currentAssetID, mediasDataLoaded);
			AppModel.getInstance().getERAFile(currentAssetID, mediasDataLoaded);
			
			// Get all the files in the room
			AppModel.getInstance().getAllERAFilesInRoom(roomID, gotRoomFiles);
			return;

		}
		private function gotRoomFiles(status:Boolean, fileArray:Array):void {
			if(!status) {
				trace("oh no it didnt work");
				return;
			}
			trace("got room files for annotation link media panel");
			var newFileArray:Array = new Array();
			for each(var file:Model_ERAFile in fileArray) {
				if(file.base_asset_id != currentAssetID) {
					newFileArray.push(file);
				}
			}
			fileView.addMediaLinkPanelFiles(newFileArray);
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
//				BrowserController.clearCurrentCollectionMedia();
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
			
			AppModel.getInstance().saveNewComment(	e.data.commentText, roomID, currentAssetID, e.data.replyingToID,
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
				this.getCommentaryForAsset();
//				AppModel.getInstance().getThisAssetsCommentary(currentAssetID, roomID, mediasCommentaryLoaded);
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
			
			//			super.removeLogoutListener();
			
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
				roomID,
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
				roomID,
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
				roomID,
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
				trace("^^^^^^ SAVING ANNOTATION", i);
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
				AppModel.getInstance().saveAnnotation(items[i], roomID);
			}
			
			setTimeout(getAnnotations, 1500);
		}
		
		// TODO REMOVE THIS FUNCTION (ONLY SO WE CAN UPDATE ANNOTATIONS FROM DEKKERS CODE
		private function getAnnotations():void {
			this.getCommentaryForAsset();
//			AppModel.getInstance().getThisAssetsCommentary(currentAssetID, roomID, mediasCommentaryLoaded);
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
//			trace("MediaController:SharingDataLoaded - Looking at this asset in collection", BrowserController.currentCollectionID);
			
			if(currentMediaData != null) {
				fileView.setupAssetsSharingInformation(userData, currentMediaData.base_creator_username);
			} else {
				fileView.setupAssetsSharingInformation(userData, "");
			}
		}
		
		private function peopleCollectionLoaded(peopleCollection:Array):void {
			fileView.addPeople(peopleCollection);
		}
		
		private function mediasCommentaryLoaded(e:Event):void {
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			var commentsForMedia:Array = AppModel.getInstance().extractCommentsFromXML(data);
			
			var annotationsForMedia:Array = AppModel.getInstance().extractAnnotationsFromXML(data);
			// Add all the comments for this collection
			// Send the collection ID, and all the comments
			fileView.addComments(commentsForMedia);
			
			// Add all the annotations for this media
			fileView.addAnnotations(annotationsForMedia);
			
		}
		private function getCommentaryForAsset():void {
			// check if we are in the forensic lab
			if(roomID == CaseController.getRoom(Model_ERARoom.FORENSIC_LAB).base_asset_id) {
				// we are, get out the review and evidence box
				var evidenceBoxID:Number = CaseController.getRoom(Model_ERARoom.EVIDENCE_ROOM).base_asset_id;
				var reviewLabID:Number = CaseController.getRoom(Model_ERARoom.SCREENING_ROOM).base_asset_id
				AppModel.getInstance().getThisAssetsCommentaryWithRoomArray(currentAssetID, new Array(roomID, evidenceBoxID, reviewLabID), mediasCommentaryLoaded);
			} else {
				// Gets out the Commentary Data for hte asset (that is, comments and annotations
				AppModel.getInstance().getThisAssetsCommentary(currentAssetID, roomID, mediasCommentaryLoaded);
			}
		}
		
		private function mediasDataLoaded(status:Boolean, media:Model_ERAFile):void {
			currentMediaData = media;
			
			// Pass this data to the view.
			fileView.addMediaData(media);
			
			getCommentaryForAsset();
			
			
			
			// Get out the People data
//			AppModel.getInstance().getPeople(media.meta_users_access, peopleCollectionLoaded);
			
			// Load the Sharing Data
			AppModel.getInstance().getAccess(currentAssetID, sharingDataLoaded);
		}
		
		private function loadPanelData():void {
			// Gets out the Commentary Data for hte asset (that is, comments and annotations
			AppModel.getInstance().getThisAssetsCommentary(currentAssetID, roomID, mediasCommentaryLoaded);
			
			// Get out the People data
//			AppModel.getInstance().getPeople(currentMediaData.meta_users_access, peopleCollectionLoaded);
			
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
			fileView.commentSaved(commentID, commentText, newCommentObject);
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
//			AppModel.getInstance().copyAccess(currentAssetID, annotationID);
			
			AppModel.getInstance().createERANotification(AppController.currentEraProject.year, roomID, Auth.getInstance().getUsername(),
				Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
				Model_ERANotification.ANNOTATION, caseID, currentAssetID, annotationID);
			
			
			// Set the class for this annotation to be Annotation
			AppModel.getInstance().setAnnotationClassForID(annotationID, function(e:Event):void {
				// After setting the annotation class, get all the commentary for this media asset
				// And reload them so they show on the asset.
				this.getCommentaryForAsset();
//				AppModel.getInstance().getThisAssetsCommentary(currentAssetID, roomID, mediasCommentaryLoaded);	
			});
			
			// So lets just get out all the annotations/comments again
			// so we can update the display with the new annotation
			
			
			
		}
		
		public function annotationDeleted(e:Event):void {
			this.getCommentaryForAsset();
//			AppModel.getInstance().getThisAssetsCommentary(currentAssetID, roomID, mediasCommentaryLoaded);
		}
		
		private function mediaDetailsUpdated(e:Event):void {
			var baseXML:XML = XML(e.target.data);
			if(baseXML.reply.@type == "result") {
				// Successfully changed the medias data
				fileView.detailsSaved(true);
			} else {
				// Change failed
				trace("Failed to update medias details", e.target.data);
				fileView.detailsSaved(false);
			}
		}
		/**
		 * The database has replied about updating the collections shared information. 
		 * @param e
		 * 
		 */		
		private function sharingInfoUpdated(e:Event):void {
			//			super.addLogoutListener();
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			// Was the sharing update not access
			if(data.reply.@type == "result") {
				// Sharing update successfully
				trace("Sharing Updated Successfully", e.target.data);
				fileView.unlockSharingPanelUsers();
				trace("-------------------------");
			} else {
				Alert.show("Sharing Update Failed");
				trace("Sharing Update Failed", e.target.data);
			} 
		}
	}
}