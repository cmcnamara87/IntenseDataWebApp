package Controller {
	
	import flash.events.Event;
	
	import mx.messaging.channels.StreamingAMFChannel;
	
	/**
	 * All the custom events
	 * @author cmcnamara87
	 * 
	 */
	public class IDEvent extends Event {
		
		//Stores data being sent with a RecensioEvent
		public var data:Object = new Object();
		
		//Event calls
			//When a media asset is clicked
			public static var ASSET_MEDIA_CLICKED:String = "recensio_assetMediaClicked";
			//When a media asset is clicked inside the asset browser
			public static var ASSET_BROWSER_MEDIA_CLICKED:String = "recensio_assetBrowserMediaClicked";
			//When a media asset is clicked inside the shelf
			public static var SHELF_MEDIA_CLICKED:String = "recensio_shelfMediaClicked";
			
			// Called when the Create Collection button is clicked, in the collection toolbar
			public static var SHELF_CLICKED:String = "recensio_shelfClicked";
			
			public static var MEDIA_ASSET_DELETE_BUTTON_CLICKED:String = 'recensio_mediaAssetDeleteButtonClicked';
			
			public static var COLLECTION_EDIT_BUTTON_CLICKED:String = "recensio_collectionEditButtonClicked"
			public static var COLLECTION_DELETE_BUTTON_CLICKED:String = "recensio_collectionDeleteButtonClicked"
			// Call when the Share Button is clicked in the Browser Toolbar
			public static var SHARE_BUTTON_CLICKED:String = "recensio_shareButtonClicked";
			
			
			public static var SHELF_CLOSE_BUTTON_CLICKED:String = "id_shelfCloseButtonClicked"; 
			public static var SHELF_CLEAR_BUTTON_CLICKED:String = "Id_shelfClearButtonClicked";
			
			//When a collection list item is clicked
			public static var ASSET_COLLECTION_CLICKED:String = "recensio_assetCollectionClicked";
			//When the all assets collection tab is clicked
			public static var ASSET_COLLECTION_ALL_MEDIA:String = "recensio_assetCollectionAllMedia";
			//When the assets shared with me collection tab is clicked
			public static var ASSET_COLLECTION_SHARED_WITH_ME:String = "recensio_assetCollectionSharedWithMe";
			//When the shelf collection tab is clicked (this is not the shelf button...which i may rename 'quick shelf')
//			public static var ASSET_COLLECTION_SHELF:String = "recensio_assetCollectionShelf";
			
			//When the search is triggered
			public static var SEARCH:String = "recensio_search";
			
			//Live search event
			public static var LIVE_SEARCH:String = "recensio_livesearch";
			
			// Comment saved button clicked.
			public static var COMMENT_SAVED:String = "recensio_CommentSaved";
			// Comment cancelled button clicked.
			public static var COMMENT_CANCELLED:String = "recensio_CommentCancelled";
			// Comment reply button clicked
			public static var COMMENT_REPLY:String = "recensio_CommentReply";
			// Comment delete button clicked
			public static var COMMENT_DELETE:String = "recensio_commentDelete";
			// Comment was edited and saved
			public static var COMMENT_EDITED:String = "id_commentEdited";
			
			
			// When the user is changed in user manager section
			public static var USER_CHANGED:String = 'recensio_userChanged';
			// When the user details have been saved
			public static var USER_DETAILS_SAVED:String = 'recensio_userDetailsSaved';
			// When a new users details have been saved
			public static var NEW_USER_DETAILS_SAVED:String = 'recensio_newUserDetailsSaved';
			// Delete user button clicked
			public static var DELETE_USER_BUTTON_CLICKED:String = 'recensio_deleteUserButtonClicked';
			// Suspend user button clicked
			public static var SUSPEND_USER_BUTTON_CLICKED:String = 'recensio_suspendUserButtonClicked';
			public static var UNSUSPEND_USER_BUTTON_CLICKED:String = 'recensio_unsuspendUserButtonClicked';
			public static var CHANGE_PASSWORD_CLICKED:String = 'recensio_changePasswordClicked';
			
			//When the URL/controller is changed
			public static var URL_CHANGED:String = "recensio_urlChanged";
			//When the navigation bar is clicked
			public static var NAV_CLICKED:String = "recensio_navbarClicked";
			//When login is checked
			public static var LOGIN_RESPONSE:String = "recensio_loginResponse";
			//When resize happens
			public static var ASSET_RESIZER:String = "recensio_asset_resize";
			//When a comment button is clicked
			public static var COMMENT_NAV_CLICKED:String = "recensio_commentbuttonclicked";
			//When a collection is clicked
			public static var COLLECTION_CLICKED:String = "recensio_collectionclicked";
			//When a collection is clicked
			public static var COLLECTION_NAV_CLICKED:String = "recensio_collectionnavclicked";
			//When a collection delete is clicked
			public static var COLLECTION_DELETED:String = "recensio_collectiondelete";
			//When a collection save is clicked
			public static var COLLECTION_SAVE:String = "recensio_collectionsave";
			
			
			//When an assets information is updated
			public static var ASSET_UPDATE:String = "recensio_assetupdate";
			
			
			//When upload button clicked
			public static var UPLOAD_CLICKED:String = "recensio_uploadclicked";
			//When a form gets changed
			public static var FORM_CHANGED:String = "recensio_formchanged";
			//When shared user data is saved
			public static var SHARED_SAVED:String = "recensio_sharedsaved";
			public static var SHARING_CHANGED:String = 'recensio_sharingChanged';
			//When the login button or enter is clicked
			public static var LOGIN_CLICKED:String = "recensio_loginclicked";
			//When a module fails
			public static var MODULE_FAIL:String = "recensio_module_fail";
			
			public static var PAGE_LOADED:String = "id_pageLoaded";
			
			// ANNOTATION STUFF
			public static var SHOW_ANNOTATION_TEXT_ENTRY:String = "id_showAnnotationTextEntry";
			public static var ANNOTATION_MOUSE_OVER:String = "id_annotationMouseOver";
			public static var ANNOTATION_MOUSE_OUT:String = "id_annotationMouseOut";
			
			// Called when we find the annotation that was moused over, and we 
			// want to send back its y position to the viewer so it can scroll to it
			public static var SCROLL_TO_ANNOTATION:String = "id_scrollToAnnotation";
			
			// When the save button is clicked
			public static var ANNOTATION_SAVE_CLICKED:String = "recensio_annotationSaveClicked";
			// Clear any non-saved annotations from the screen
			public static var ANNOTATION_CLEAR_CLICKED:String = 'recensio_annotationClearClicked';
			// When the annotation is actually ready to be saved.
			public static var ANNOTATION_SAVE_BOX:String = "recensio_annotationSaveBox";
			public static var ANNOTATION_SAVE_PEN:String = "recensio_annotationSavePen";
			public static var ANNOTATION_SAVE_HIGHLIGHT:String = "recensio_annotationSaveHighlight";
			
			public static var ANNOTATION_LIST_ITEM_MOUSEOVER:String = "recensio_annotationListItemMouseOver";
			public static var ANNOTATION_LIST_ITEM_MOUSEOUT:String = "recensio_annotationListItemMouseOut";
			
			public static var ANNOTATION_DELETED:String = "recensio_annotationDeleted";
			
			// Called when a user sets the start of an annotation
			public static var ANNOTATION_START_SET:String = "recensio_annotationStartSet";
			// Called when a user sets the end of an annotation
			public static var ANNOTATION_END_SET:String = "recensio_annotationEndSet";
		
			public static var OPEN_REF_PANEL:String = "id_asdfasdadsfopenRefPanel";
			public static var CLOSE_REF_PANEL:String = "id_closeRefPanel";
			
			public static var ASSET_ADD_AS_REF_COMMENT:String = "id_assetAddAsRef";
			public static var ASSET_ADD_AS_REF_ANNOTATION:String = "id_assetAddAsRefAnnotation";
			// The PDF has loaded and finished being displayed on screen
			public static var MEDIA_LOADED:String = "id_pdfLoaded"; 
			
			
			// ERA EVENTS
			// Called when the a user is being added to a role (in the user admin)
			public static var ERA_ADD_USER_TO_ROLE:String = "id_addUserToRole";
			// Call when we are initially saving a evidence log item
			public static var ERA_SAVE_LOG_ITEM:String = "id_saveLogItem";
			public static var ERA_SAVE_FILE:String = "id_saveFile";
			public static var ERA_DELETE_USER:String = "era_deleteUser";
			
		public function IDEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}