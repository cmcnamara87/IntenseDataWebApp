package View.components.CollectionList
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	
	import Model.Model_Collection;
	
	import View.BrowserView;
	import View.Element.Collection;
	import View.components.PanelElement;
	import View.components.SubToolbar;
	import View.components.Toolbar;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.ToggleButton;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Line;
	
	public class CollectionList extends BorderContainer
	{
		
		private var myScroller:Scroller; // Adds scrollbars
		private var fixedCollectionListItems:VGroup; // the list of fixed collections
		private var regularCollectionListItems:VGroup; // Where all the non-fxied collection list elements sit
		private var createCollectionButton:ToggleButton // The create collection button
		private var searchInput:TextInput; // The search input text box for the panel
		private const PLACEHOLDERTEXT:String = "Search";
		private const BUTTON_TEXT_REGULAR:String =  "New " + BrowserController.PORTAL;
		private const BUTTON_TEXT_CLICKED:String = "Hide New " + BrowserController.PORTAL;
		private var newButtonText:String = BUTTON_TEXT_REGULAR; // Stores the label for the new collection button
		private var mediaCount:Number = 0; // Stores the number of assets currently on the shelf
		
		/**
		 * The collection list sits on the left side on the main asset browser 
		 * and shows all the collections the user has.
		 * 
		 * Contains a Scroller, which has a group, where the collection list items live.
		 */		
		public function CollectionList()
		{
			super();
			
			// Setup the height and width
			this.minWidth = 300;
			this.percentHeight = 100;

			// Setup the layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Set the backgrond colour & border collect
			this.backgroundFill = new SolidColor(0xFFFFFF);
			this.borderStroke = new SolidColorStroke(0xCCCCCC,1,1);
			
			
			// Add a toolbar, work out what to put in it later
			var myToolbar:Toolbar = new Toolbar();
			this.addElement(myToolbar);
			
			// Add The panel heading
			var heading:Label = new Label();
			heading.text = BrowserController.PORTAL + "s";
			heading.setStyle('textAlign', 'left');
			heading.setStyle('color', 0x333333);
			heading.setStyle('fontSize', 16);
			heading.percentWidth = 100;
			myToolbar.addElement(heading);
			
			// Add 'Create Collection' Button
			// Add the Shelf Button
			createCollectionButton = new ToggleButton();
			setButtonLabel();
			createCollectionButton.selected = false;
			createCollectionButton.percentHeight = 100;
			myToolbar.addElement(createCollectionButton);
			
			// Add in the search collections box
			var searchToolbar:SubToolbar = new SubToolbar();
			searchToolbar.setStyle("resizeEffect", null);
			searchToolbar.setStyle("borderVisible", false);
			searchToolbar.setColor(SubToolbar.GREY);
			this.addElement(searchToolbar);
			// Add the search input;
			searchInput = new TextInput();
			searchInput.text = "Search";
			searchInput.percentWidth = 100;
			searchInput.percentHeight = 100;
			searchToolbar.addElement(searchInput);
			
			// Create the space for the fixed collections (these wont scroll)
			fixedCollectionListItems = new VGroup();
			fixedCollectionListItems.percentWidth = 100;
			fixedCollectionListItems.gap = 0;
//			fixedCollectionListItems.paddingLeft = 10;
//			fixedCollectionListItems.paddingRight = 10;
//			fixedCollectionListItems.paddingTop = 10;
//			fixedCollectionListItems.paddingBottom = 10;
			this.addElement(fixedCollectionListItems);
			
			// Add the 'All Assets' and 'Shared Assets' to the fixed collections part of the list.
			var originalFileCollection:CollectionListItemFixed = new CollectionListItemFixed(BrowserController.ALLASSETID, 
				'Your Original Files', IDEvent.ASSET_COLLECTION_ALL_MEDIA);
			originalFileCollection.percentWidth = 100;
			originalFileCollection.addEventListener(MouseEvent.CLICK, showLoadingOnClick);
			fixedCollectionListItems.addElement(originalFileCollection);
			
//			fixedCollectionListItems.addElement(new CollectionListItemFixed(BrowserController.SHAREDID, 
//				'Shared With Me', IDEvent.ASSET_COLLECTION_SHARED_WITH_ME));
//			
			
			// Add a line to separate the 'smart collections' and the regular collections
			var hLine:Line = new Line();
			hLine.percentWidth = 100;
			hLine.stroke = new SolidColorStroke(0xEEEEEE,1,1);
			this.addElement(hLine);
			

			
			// lets add a scroller, so it...scrolls lol
			myScroller = new Scroller();
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
			
			// create a content group so we can put it inside the scroll
			regularCollectionListItems = new VGroup(); 

			regularCollectionListItems.gap = 0;
			// Add the content group to the scroller
			myScroller.viewport = regularCollectionListItems;
			
			// Add the scroller to the list
			this.addElement(myScroller);
			
			
			// Add 'Toolbar' to the bottom
			// Will include a 'Add Folder' button in the future TODO
			var newFolderToolbar:Toolbar = new Toolbar();
			var newFolderButton:spark.components.Button = new spark.components.Button();
			newFolderButton.label = "New Folder";
			newFolderToolbar.addElement(newFolderButton);
			//this.addElement(newFolderToolbar);
			
			
			// Event Listeners
			createCollectionButton.addEventListener(MouseEvent.CLICK, createCollectionButtonClicked);
			
			// Listen for search input focus/lost focus
			searchInput.addEventListener(FocusEvent.FOCUS_IN, searchInputHasFocus);
			searchInput.addEventListener(FocusEvent.FOCUS_OUT, searchInputHasLostFocus);
			
			// Listen for Text Input
			searchInput.addEventListener(Event.CHANGE, searchTermEntered);

		}
		
		/**
		 * Takes an array of collection data, and creates CollectionListItems 
		 * and adds them to this list.
		 * 
		 * Can be a empty collection.
		 * 
		 * @param collectionArray The array of collection data for various collections
		 * 
		 */		
		public function addCollections(collectionArray:Array):void {
			for(var i:Number = 0; i < collectionArray.length; i++) {
				// TODO REMOVE THIS Check that the collection has some items in it otherwise, ignore it.
				//if ((collectionArray[i] as Model_Collection).numberOfChildren()) {
					
					var newCollectionListItem:CollectionListItemRegular = new CollectionListItemRegular(collectionArray[i]);
//					newCollectionListItem.toolTip = newCollectionListItem.getCollectionName();
					regularCollectionListItems.addElement(newCollectionListItem);	
				//} 
					
					
					
					
					
					newCollectionListItem.addEventListener(MouseEvent.CLICK, showLoadingOnClick);
				
			}
		}

		public function hideAllLoadingAnimations():void {
			for(var i:Number = 0; i < regularCollectionListItems.numElements; i++) {
				(regularCollectionListItems.getElementAt(i) as CollectionListItem).hideLoading();
			}
			for(i = 0; i < fixedCollectionListItems.numElements; i++) {
				(fixedCollectionListItems.getElementAt(i) as CollectionListItem).hideLoading();
			}
		}
		
		private function showLoadingOnClick(e:MouseEvent):void {
			hideAllLoadingAnimations();
			(e.target as CollectionListItem).showLoading();
		}
		
		public function updateNewCollectionButton():void {
			mediaCount = BrowserController.getShelfAssets().length;
			setButtonLabel();
		}
		
		/**
		 * When we are in edit mode, any collection that is 'read only' should not be able to be accessed
		 */		
		public function enterEditMode():void {
			// DEPRECATED - opted instead just to disable the assets, not hte collections
			// solves problems when we are in a collection, and hit 'new collection' and the collection should be
			// disabled.
			
//			for(var i:Number = 0; i < regularCollectionListItems.numElements; i++) {
//				var regularListItem:CollectionListItemRegular = regularCollectionListItems.getElementAt(i) as CollectionListItemRegular;
//				if(!regularListItem.getAccess()) {
//					regularListItem.toolTip = "Read Only Access";
//					regularListItem.enabled = false;
//				}
//			}
		}
		
		public function exitEditMode():void {
//			for(var i:Number = 0; i < regularCollectionListItems.numElements; i++) {
//				var regularListItem:CollectionListItemRegular = regularCollectionListItems.getElementAt(i) as CollectionListItemRegular;
//				regularListItem.toolTip = regularListItem.getCollectionName();
//				regularListItem.enabled = true;
//			}
		}
		
		/**
		 * Removes all collections from list.
		 */		
		public function clearCollections():void {
			regularCollectionListItems.removeAllElements();
		}
		
	
		/**
		 * Highlights a specific collection (used when a collection is clicked) 
		 * @param collectionID	The ID of the collection to highlight
		 * 
		 */		
		public function highlightCollectionListItem(collectionID:Number):void {
			// Highlight/remove highlight for All Asset ID
			trace("Highlighting", collectionID);

			// Highlight the collection if its a fixed one, or, unhighlight them
			for(var i:Number = 0; i < fixedCollectionListItems.numElements; i++) {
				var myListItem:CollectionListItemFixed = (fixedCollectionListItems.getElementAt(i) as CollectionListItemFixed);
				if(myListItem.getCollectionID() == collectionID) {
					myListItem.setSelected();
				} else {
					myListItem.unSelect();
				}
			}
			
			// Do the same for all the other collections
			for(i = 0; i < regularCollectionListItems.numElements; i++) {
				var myListItem2:CollectionListItemRegular = (regularCollectionListItems.getElementAt(i) as CollectionListItemRegular);
				if(myListItem2.getCollectionID() == collectionID) {
					// This was the selected one, so selected it
					myListItem2.setSelected();
				} else {
					// It wasnt selected, so unselect it (may have been selected the previous time)
					myListItem2.unSelect();
				}
			}
		}
		
		/**
		 * Make create collection button pop out. Use when you click 'save collection'
		 * as the collection shelf needs to close. 
		 * 
		 */		
		public function unsetCreateCollectionButton():void {
			createCollectionButton.selected = false;
			newButtonText = BUTTON_TEXT_REGULAR;
			setButtonLabel();
		}
		
		
		/* ============= EVENT LISTENER FUNCTIONS ================== */
		/**
		 * Called when the Create Collection button is clicked. Passed to the controller which switches modes etc.
		 * @param e	The Click mouse event
		 * 
		 */		
		// TODO change all 'shelf' to create collection
		private function createCollectionButtonClicked(e:MouseEvent):void {
			trace("Shelf Button Clicked.");
			
			// Change the button label to say 'hide collection' if its selected
			if(createCollectionButton.selected) {
				newButtonText = BUTTON_TEXT_CLICKED;
				updateNewCollectionButton();
			} else {
				trace("button clicked");
				newButtonText = BUTTON_TEXT_REGULAR;
				updateNewCollectionButton();
			}
			
			var clickEvent:IDEvent = new IDEvent(IDEvent.SHELF_CLICKED, true);
			// Pass through the shelfs boolean value (true or false, shown or not shown)
			clickEvent.data.shelfState = createCollectionButton.selected;
			this.dispatchEvent(clickEvent);
		}
		
		private function setButtonLabel():void {
			trace("setting button label", newButtonText + " (" + mediaCount + ")");
			createCollectionButton.label = newButtonText;
			if(mediaCount > 0) {
				createCollectionButton.label = newButtonText + " (" + mediaCount + ")";
			}
		}
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
		
		/**
		 * Called when search term is etnered. Passed to @see AssetBrowser 
		 * @param e
		 * 
		 */		
		private function searchTermEntered(e:Event):void {
			trace('Searching for: ', (e.target as TextInput).text);
			
			// Searches the fixed Collection List for matches
			for(var i:Number = 0; i < fixedCollectionListItems.numElements; i++) {
				var element:PanelElement = fixedCollectionListItems.getElementAt(i) as PanelElement;
				if(!element.searchMatches((e.target as TextInput).text)) {
					fixedCollectionListItems.getElementAt(i).visible = false;
					fixedCollectionListItems.getElementAt(i).includeInLayout = false;
				} else {
					fixedCollectionListItems.getElementAt(i).visible = true;
					fixedCollectionListItems.getElementAt(i).includeInLayout = true;
				}
			}
			
			// Searches the regular collection list for matches
			for(i = 0; i < regularCollectionListItems.numElements; i++) {
				element = regularCollectionListItems.getElementAt(i) as PanelElement;
				if(!element.searchMatches((e.target as TextInput).text)) {
					regularCollectionListItems.getElementAt(i).visible = false;
					regularCollectionListItems.getElementAt(i).includeInLayout = false;
				} else {
					regularCollectionListItems.getElementAt(i).visible = true;
					regularCollectionListItems.getElementAt(i).includeInLayout = true;
				}
			}
		}
		
	}
}