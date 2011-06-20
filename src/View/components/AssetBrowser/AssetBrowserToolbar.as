package View.components.AssetBrowser
{
	import Controller.BrowserController;
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import View.BrowserView;
	import View.components.IDGUI;
	import View.components.Toolbar;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Line;
	
	public class AssetBrowserToolbar extends Toolbar
	{
		
		private var searchInput:TextInput;
		private var shelfButton:ToggleButton; 			// Used to turn on/off the shelf
		private var shareButton:Button; 			// Used to turn on/off the sharing panel for a collection
														// not shown when in either of the Fixed Collections (all assets, shared with me)
		private var commentsButton:Button 		// Used to turn on/off the comment panel for a collection.
														// Not shown for fixed collections.
		private var editButton:ToggleButton;			// TODO add comments for these buttons
														// when they are integrated.
		private var deleteButton:Button;		
		
		private var searchEditLine:Line;				// Line between search and edit buttons
		private var deleteShareLine:Line;				// Line between delete and share buttons
		private var uploadNewAssetButton:Button;
		private var uploadSearchLine:Line;
		
		private const PLACEHOLDERTEXT:String = "Search for Media";
		/**
		 * The toolbar for the asset browser
		 * Has search box, search button, shelf button, and maybe some other...buttons lol
		 * 
		 */		
		public function AssetBrowserToolbar()
		{
			super();
			
			// The toolbar consists of 2 parts
			// 1) upload and search box
			// 2) the context senstive buttons (share, delete, comment etc)
			
			// Create Upload New Asset Button
			uploadNewAssetButton = IDGUI.makeButton("Upload Asset");
			this.addElement(uploadNewAssetButton);				
			
			uploadSearchLine = new Line();
			uploadSearchLine.percentHeight = 100;
			uploadSearchLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			this.addElement(uploadSearchLine);
			
			// Add the search input;
			searchInput = new TextInput();
			searchInput.text = "Search for Media";
			searchInput.percentWidth = 100;
			searchInput.percentHeight = 100;
			this.addElement(searchInput);
			
			/* ============== ADD BUTTONS ============== */
			
			// Add the search button
//			var searchButton:Button = new Button();
//			searchButton.label = "Search";
//			searchButton.percentHeight = 100;
//			this.addElement(searchButton);
			
			// Add a line to separate the search button and the shelf button
//			var vLine:Line = new Line();
//			vLine.percentHeight = 100;
//			vLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
//			this.addElement(vLine);
			
//			// Add the Shelf Button
//			shelfButton = new ToggleButton();
//			shelfButton.label = "Create Collection";
//			shelfButton.selected = false;
//			shelfButton.percentHeight = 100;
//			this.addElement(shelfButton);
			
			// Add a line to separate the search button and the edit button
			searchEditLine = IDGUI.makeLine(0xBBBBBB, false, false);
			this.addElement(searchEditLine);
			
			// Add the Edit Button
			editButton = IDGUI.makeToggleButton('Edit ' + BrowserController.PORTAL, false, false, false);
			this.addElement(editButton);
			
			// Add the Delete
			deleteButton = IDGUI.makeButton('Delete ' + BrowserController.PORTAL, false, false);
			this.addElement(deleteButton);
			
			// Add a line to separate the delete and share button
			deleteShareLine = IDGUI.makeLine(0xBBBBBB, false, false);
			this.addElement(deleteShareLine);
			
			// Add the Share Button
//			shareButton = IDGUI.makeButton('Share ' + , false, false);
			shareButton = IDGUI.makeButton('+ Add People', false, false);
			this.addElement(shareButton);
			
			// Add the Comments
			commentsButton = IDGUI.makeButton('Comments (0)', false, false);
			this.addElement(commentsButton);

			/* ============== ADD EVENT LISTENERS ============== */
			
			// Listen for Shelf Button CLick
//			shelfButton.addEventListener(MouseEvent.CLICK, shelfButtonClicked);
			
			// Listen for Edit Button to be clicked.
			editButton.addEventListener(MouseEvent.CLICK, editButtonClicked);
			
			// Listen for Delete button to be clicked.
			deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked);
			
			// Listen for Text Input
			searchInput.addEventListener(Event.CHANGE, searchTermEntered);
			
			// Listen for Comments Clicked
			commentsButton.addEventListener(MouseEvent.CLICK, commentsButtonClicked);
			
			// Listen for Share Clicked
			shareButton.addEventListener(MouseEvent.CLICK, shareButtonClicked);
			
			// Listen for Uplaod Cclicked
			uploadNewAssetButton.addEventListener(MouseEvent.CLICK, uploadNewAssetButtonClicked);
			
			// Listen for search input focus/lost focus
			searchInput.addEventListener(FocusEvent.FOCUS_IN, searchInputHasFocus);
			searchInput.addEventListener(FocusEvent.FOCUS_OUT, searchInputHasLostFocus);
			
		}
		
		/* ========= CHANGING TOOLBAR/BUTTONS (CALLED FROM OTHER PLACES) ============ */
		/**
		 * Set the toolbar to show all buttons, except Share, Comments, Edit and Delete
		 * This is used for collections like, All Assets, and Shared with Me 
		 * 
		 */		
		public function setToolbarToFixedCollectionMode():void {
			
//			uploadNewAssetButton.visible = false;
//			uploadNewAssetButton.includeInLayout = false;
//			uploadSearchLine.visible = false;
//			uploadSearchLine.includeInLayout = false;
			
			searchEditLine.visible = false;
			searchEditLine.includeInLayout = false;
			
			editButton.visible = false;
			editButton.includeInLayout = false;
			
			deleteButton.visible = false;
			deleteButton.includeInLayout = false;
			
			deleteShareLine.visible = false;
			deleteShareLine.includeInLayout = false;
			
			shareButton.visible = false;
			shareButton.includeInLayout = false;
			
			commentsButton.visible = false;
			commentsButton.includeInLayout = false;
		}
		
		public function unsetEditButton():void {
			editButton.selected = false;
			deleteButton.enabled = true;
		}
		
		/**
		 * Shows all buttons on the toolbar. Used for regular collections. 
		 * 
		 */		
		public function setToolbarToRegularCollectionMode(modifyAccess:Boolean):void {
			trace("Setting toolbar to regular collection mode, access type", modifyAccess);
			if(modifyAccess) {
				// We have Full access to the collection
				uploadNewAssetButton.visible = true;
				uploadNewAssetButton.includeInLayout = true;
				
				uploadSearchLine.visible = true;
				uploadSearchLine.includeInLayout = true;
				
				searchEditLine.visible = true;
				searchEditLine.includeInLayout = true;
				
				editButton.visible = true;
				editButton.includeInLayout = true;
				
				deleteButton.visible = true;
//				deleteButton.label = "Delete Collection";
				deleteButton.includeInLayout = true;
				
				deleteShareLine.visible = true;
				deleteShareLine.includeInLayout = true;
				
				shareButton.visible = true;
				shareButton.includeInLayout = true;
				
				commentsButton.visible = true;
				commentsButton.includeInLayout = true;
			} else {
				// We only have view access to the collection
				uploadNewAssetButton.visible = false;
				uploadNewAssetButton.includeInLayout = false;
				
				uploadSearchLine.visible = false;
				uploadSearchLine.includeInLayout = false;
				
				searchEditLine.visible = true;
				searchEditLine.includeInLayout = true;
				
				editButton.visible = false;
				editButton.includeInLayout = false;
				
				deleteButton.visible = true;
//				deleteButton.label = "Remove Collection";
				deleteButton.includeInLayout = true;
				
				deleteShareLine.visible = true;
				deleteShareLine.includeInLayout = true;
				
				shareButton.visible = true;
				shareButton.includeInLayout = true;
				
				commentsButton.visible = true;
				commentsButton.includeInLayout = true;
			}
			
			// If we arent the author of the collection, make it say 'remove' instead of delete
			// We need to check if the collectionData is null, cause it could mean we are making a 
			// collection while on a fixed collection (and there is no data) ... TODO fix this up
			if((BrowserController.collectionData != null) && (BrowserController.collectionData.base_creator_username != Auth.getInstance().getUsername())) {
				trace("AssetBrowserToolbar: Collection author is", BrowserController.collectionData.base_creator_username, Auth.getInstance().getUsername());
				deleteButton.label = "Remove " + BrowserController.PORTAL;
			} else {
//				trace("AssetBrowserToolbar: Collection author is", BrowserController.collectionData.meta_username, Auth.getInstance().getUsername());
				deleteButton.label = "Delete " + BrowserController.PORTAL;
			}
		}
		
		/**
		 * Comment button says 'Comments (0)'. We have to set that number,
		 * to be the number of comments. 
		 * @param commentCount	The numbero f comments.
		 * 
		 */		
		public function setCommentCount(commentCount:Number):void {
			commentsButton.label = "Comments (" + commentCount + ")";
		}
		
		/* ======== CALLED BY EVENT LISTENERS =========== */
//		/**
//		 * Called when the Shelf button is clicked. Passed to the controller which switches modes etc.
//		 * @param e
//		 * 
//		 */		
//		private function shelfButtonClicked(e:MouseEvent):void {
//			trace("Shelf Button Clicked.");
//			var shelfClicked:RecensioEvent = new RecensioEvent(RecensioEvent.SHELF_CLICKED, true);
//			// Pass through the shelfs boolean value (true or false, shown or not shown)
//			shelfClicked.data.shelfState = shelfButton.selected;
//			
//			this.dispatchEvent(shelfClicked);
//		}
		
		private function uploadNewAssetButtonClicked(e:MouseEvent):void {
			trace("Upload New Asset Button Clicked");
			Dispatcher.call("newasset");
		}
		
		private function shareButtonClicked(e:MouseEvent):void {
			trace("Share button clicked.");
			var shareClicked:IDEvent = new IDEvent(IDEvent.SHARE_BUTTON_CLICKED, true);
//			// Pass through the shelfs boolean value (true or false, shown or not shown)
//			shareClicked.data.buttonState = shareButton.selected;
			this.dispatchEvent(shareClicked);
		}
		
		/**
		 * Called when the Comments button is clicked. Passed to the controller which makes
		 * the comments appear
		 * @param e The mouse event
		 * 
		 */		
		private function commentsButtonClicked(e:MouseEvent):void {
			trace("Comments Button Clicked.");
			var commentsButtonClicked:IDEvent = new IDEvent(IDEvent.COMMENT_NAV_CLICKED, true);
//			// Pass through the shelfs boolean value (true or false, shown or not shown)
//			commentsButtonClicked.data.buttonState = commentsButton.selected;
			
			this.dispatchEvent(commentsButtonClicked);
		}
		
		/**
		 * Called when Edit Button is clicked. Passed to browser controller which handles editing
		 * collections.
		 *  
		 * @param e
		 * 
		 */		
		private function editButtonClicked(e:MouseEvent):void {
			trace("Edit Button Clicked");
			
			// Disable the 'delete button'
			// As you cant delete any collection while in 'edit mode'
			deleteButton.enabled = false;
			
			var editClicked:IDEvent = new IDEvent(IDEvent.COLLECTION_EDIT_BUTTON_CLICKED, true);
			// Pass through the shelfs boolean value (true or false, shown or not shown)
			editClicked.data.editState = editButton.selected;
			
			this.dispatchEvent(editClicked);
		}
		
		private function deleteButtonClicked(e:MouseEvent):void {
			trace("Delete Button Clicked");
			
			var deleteClicked:IDEvent = new IDEvent(IDEvent.COLLECTION_DELETE_BUTTON_CLICKED, true);
			// Pass through the shelfs boolean value (true or false, shown or not shown)
			
			this.dispatchEvent(deleteClicked);
		}
		
		/**
		 * Called when search term is etnered. Passed to @see AssetBrowser 
		 * @param e
		 * 
		 */		
		private function searchTermEntered(e:Event):void {
			trace('Searching for: ', (e.target as TextInput).text);
			var searchEvent:IDEvent = new IDEvent(IDEvent.LIVE_SEARCH, true);
			searchEvent.data.searchTerm =  (e.target as TextInput).text;
			this.dispatchEvent(searchEvent);
		}
		
//		private function commentsButtonClicked(e:MouseEvent):void {
//			trace('Comments Button Clicked');
//			var searchEvent:RecensioEvent = new RecensioEvent(RecensioEvent., true);
//			searchEvent.data.searchTerm =  (e.target as TextInput).text;
//			this.dispatchEvent(searchEvent);
//		}
		
		private function searchInputHasFocus(e:FocusEvent):void {
			if(searchInput.text == PLACEHOLDERTEXT) {
				searchInput.text = "";
			}
		}
		
		private function searchInputHasLostFocus(e:FocusEvent):void {
			if(searchInput.text == "") {
				searchInput.text = PLACEHOLDERTEXT;
			}
		}
		
	}
}