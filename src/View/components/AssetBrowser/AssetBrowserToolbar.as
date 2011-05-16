package View.components.AssetBrowser
{
	import Controller.Dispatcher;
	import Controller.RecensioEvent;
	
	import View.BrowserView;
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
			var uploadNewAssetButton:Button = new Button();
			uploadNewAssetButton.label = "Upload Asset";
			uploadNewAssetButton.percentHeight = 100;
			this.addElement(uploadNewAssetButton);				
			
			var uploadSearchLine:Line = new Line();
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
			searchEditLine = new Line();
			searchEditLine.percentHeight = 100;
			searchEditLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			
			
			// Add the Edit Button
			editButton = new ToggleButton();
			editButton.label = "Edit Collection";
			editButton.selected = false;
			editButton.percentHeight = 100;
			
			// Add the Delete
			deleteButton = new Button();
			deleteButton.label = "Delete Collection";
			deleteButton.percentHeight = 100;
			
			// Add a line to separate the delete and share button
			deleteShareLine = new Line();
			deleteShareLine.percentHeight = 100;
			deleteShareLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			
			// Add the Share Button
			shareButton = new Button();
			shareButton.label = "Share Collection";
			shareButton.percentHeight = 100;
			
			// Add the Comments
			commentsButton = new Button();
			commentsButton.label = "Comments (0)";
			commentsButton.percentHeight = 100;
			
			
			
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
			if(this.contains(editButton)) {
				this.removeElement(editButton);
			}
			if(this.contains(deleteButton)) {
				this.removeElement(deleteButton);
			}
			if(this.contains(shareButton)) {
				this.removeElement(shareButton);
			}
			if(this.contains(commentsButton)) {
				this.removeElement(commentsButton);
			}
			if(searchEditLine.parent) {
				this.removeElement(searchEditLine);
			}
			if(deleteShareLine.parent) {
				this.removeElement(deleteShareLine);
			}
		}
		
		public function unsetEditButton():void {
			editButton.selected = false;
			deleteButton.enabled = true;
		}
		
		/**
		 * Shows all buttons on the toolbar. Used for regular collections. 
		 * 
		 */		
		public function setToolbarToRegularCollectionMode():void {
			this.addElement(searchEditLine);
			this.addElement(editButton);
			this.addElement(deleteButton);
			this.addElement(deleteShareLine);
			this.addElement(shareButton);
			this.addElement(commentsButton);
			
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
			var shareClicked:RecensioEvent = new RecensioEvent(RecensioEvent.SHARE_BUTTON_CLICKED, true);
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
			var commentsButtonClicked:RecensioEvent = new RecensioEvent(RecensioEvent.COMMENT_NAV_CLICKED, true);
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
			
			var editClicked:RecensioEvent = new RecensioEvent(RecensioEvent.COLLECTION_EDIT_BUTTON_CLICKED, true);
			// Pass through the shelfs boolean value (true or false, shown or not shown)
			editClicked.data.editState = editButton.selected;
			
			this.dispatchEvent(editClicked);
		}
		
		private function deleteButtonClicked(e:MouseEvent):void {
			trace("Delete Button Clicked");
			
			var deleteClicked:RecensioEvent = new RecensioEvent(RecensioEvent.COLLECTION_DELETE_BUTTON_CLICKED, true);
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
			var searchEvent:RecensioEvent = new RecensioEvent(RecensioEvent.LIVE_SEARCH, true);
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