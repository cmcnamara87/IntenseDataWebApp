package View
{
	import Controller.IDEvent;
	
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import View.components.AssetBrowser.AssetBrowser;
	import View.components.AssetBrowser.AssetBrowserToolbar;
	import View.components.CollectionList.CollectionList;
	import View.components.GoodBorderContainer;
	import View.components.Panels.Comments.CommentsPanel;
	import View.components.Panels.Comments.NewComment;
	import View.components.Panels.MediaLinkPanel;
	import View.components.Panels.Panel;
	import View.components.Panels.Sharing.SharingPanel;
	import View.components.Shelf;
	
	import mx.effects.Effect;
	import mx.effects.Move;
	import mx.effects.Resize;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.effects.Resize;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	public class BrowserView extends BorderContainer
	{		
		public static const TOOLBARHEIGHT:Number = 40; // the height of all toolbars in the browser view
		private var myCollectionList:CollectionList; // Displays the list of collections
		private var myAssetBrowser:AssetBrowser; // Displays all the assets for the collection
		private var myShelf:Shelf; // Is...the shelf where you can put assets
		private var myCommentsPanel:CommentsPanel;	// The Comments panel
		private var mySharingPanel:SharingPanel;	// The sharing panel
		private var myAssetBrowserToolbar:AssetBrowserToolbar;
		private var otherVGroup:VGroup;
		private var commentCount:Number = 0;
		private var myMediaLinkPanel:MediaLinkPanel;
		
		public function BrowserView()
		{
			super();
			
			// The Browser Viewer is Full Screen Size
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			// Set the backgrond colour & border collect
			this.backgroundFill = new SolidColor(0xFFFFFF);
			this.borderStroke = new SolidColorStroke(0xEEEEEE,1,0);
			
			var verticalBox:VGroup = new VGroup();
			verticalBox.percentHeight = 100;
			verticalBox.percentWidth = 100;
			verticalBox.gap = 0;
			this.addElement(verticalBox);
			
			var horizontalBox:HGroup = new HGroup();
			horizontalBox.percentHeight = 100;
			horizontalBox.percentWidth = 100;
			horizontalBox.gap = 0;
			verticalBox.addElement(horizontalBox);
			
			myMediaLinkPanel = new MediaLinkPanel();
			verticalBox.addElement(myMediaLinkPanel);

			// Lets add the Collection List
			myCollectionList = new CollectionList();
			horizontalBox.addElement(myCollectionList);
			
			var test:VGroup = new VGroup();
			test.percentHeight = 100;
			test.percentWidth = 100;
			test.gap = 0;
			horizontalBox.addElement(test);
			
			// Add the Shelf
			myShelf = new Shelf();
			myShelf.height = 0; // set at 0 at first, cause its not displayed
			myShelf.percentWidth = 100;
			myShelf.visible = true;
			myShelf.setStyle("resizeEffect", new mx.effects.Resize());
			test.addElement(myShelf);
			
			otherVGroup = new VGroup();
			otherVGroup.gap = 0;
			otherVGroup.percentWidth = 100;
			otherVGroup.percentHeight = 100;
			test.addElement(otherVGroup);
			
			// Add the Search Toolbar
			myAssetBrowserToolbar = new AssetBrowserToolbar();
			otherVGroup.addElement(myAssetBrowserToolbar);

			var myAssetBrowserAndPanels:HGroup = new HGroup();
			myAssetBrowserAndPanels.percentHeight = 100;
			myAssetBrowserAndPanels.percentWidth = 100;
			myAssetBrowserAndPanels.gap = 0;
			otherVGroup.addElement(myAssetBrowserAndPanels);
			
			// Now lets create a VGroup for the AssetBrowser and the Shelf/Edit box
//			var myVGroup:VGroup = new VGroup();
//			myVGroup.percentHeight = 100;
//			myVGroup.percentWidth = 100;
//			myVGroup.gap = 0;
//			myAssetBrowserAndPanels.addElement(myVGroup);
			
//			// Add the Shelf
//			myShelf = new Shelf();
//			myShelf.height = 0; // set at 0 at first, cause its not displayed
//			myShelf.percentWidth = 100;
//			myShelf.visible = true;
//			myShelf.setStyle("resizeEffect", new mx.effects.Resize());
//			myVGroup.addElement(myShelf);
			
			// And add the Asset Browser (includes the asset tiles, search box etc)
			myAssetBrowser = new AssetBrowser();
			myAssetBrowser.percentWidth = 100; // set externally as it changes (with shelf/comments shown etc)
			myAssetBrowser.percentHeight = 100;
			//myAssetBrowser.setStyle("resizeEffect", new mx.effects.Resize());
			myAssetBrowserAndPanels.addElement(myAssetBrowser);
			
	
			// Lets add the Comments Panel
			myCommentsPanel = new CommentsPanel();
			myCommentsPanel.hide();
			myAssetBrowserAndPanels.addElement(myCommentsPanel);
			
			// Lets add the Sharing Panel
			mySharingPanel = new SharingPanel();
			mySharingPanel.hide();
			myAssetBrowserAndPanels.addElement(mySharingPanel);
				
			// Listen for Comments Button being clicked (done in here, 
			// instead of the controller, cause it doesnt really need to save stuff like it does
			// with the shelf).
			this.addEventListener(IDEvent.COMMENT_NAV_CLICKED, commentsButtonClicked);
			this.addEventListener(IDEvent.SHARE_BUTTON_CLICKED, shareButtonClicked);
			// Listen for Search Term Entry
			this.addEventListener(IDEvent.LIVE_SEARCH, searchTermEntered);
			
			// Asset Ref Code
			this.addEventListener(IDEvent.OPEN_REF_PANEL, function(e:IDEvent):void {
				myMediaLinkPanel.show();
			});
			
			this.addEventListener(IDEvent.CLOSE_REF_PANEL, function(e:IDEvent):void {
				myMediaLinkPanel.hide();
			});
			
//			this.addEventListener(IDEvent.ASSET_ADD_AS_REF_COMMENT, function(e:IDEvent):void {
//				myCommentsPanel.addReferenceTo(e.data.assetData);
//			})
			
			this.addEventListener(IDEvent.COMMENT_EDITED, function(e:IDEvent):void {
				myMediaLinkPanel.hide();
			});
			
		}
		
		/**
		 * Adds collections to the collection list 
		 * @param 	collectionArray	An array of collections
		 * 
		 */		
		public function addCollections(collectionArray:Array):void {
			myCollectionList.addCollections(collectionArray);
		}
		
		/**
		 * Adds media tiles to the display 
		 * @param 	assetArray	An array of media objects
		 * 
		 */		
		public function addMediaAssets(assetArray:Array):void {
			myCollectionList.hideAllLoadingAnimations();
			myAssetBrowser.addMediaAssets(assetArray);
			myMediaLinkPanel.hide();
			myMediaLinkPanel.addMedia(assetArray);
		}
		
		
		/**
		 * Adds the comments for the collection clicked to the comment panel
		 * Also sets the Comment(0) <-- that number, to be the number of comments 
		 * @param annotationnsArray
		 * 
		 */		
		public function addComments(annotationnsArray:Array):void {
			myCommentsPanel.addComments(annotationnsArray);
			this.setCommentCount(annotationnsArray.length);
		}
		
		
		/**
		 * Removes all the media tiles being displayed (note, this doesnt remove the data, only visually....maybe cause problems perhaps?)
		 * 
		 */		
		public function clearMediaAssets():void {
			myAssetBrowser.clearMediaAssets();
		}
		
		/**
		 * Highlights an collection in the colleciton list.
		 * Called by @see BrowserController when a collection is clicked. 
		 * @param collectionID
		 * 
		 */		
		public function highlightCollectionListItem(collectionID:Number):void {
			myCollectionList.highlightCollectionListItem(collectionID);
		}
		
		/**
		 * Removes all collections from the collection list. 
		 * 
		 */		
		public function clearCollections():void {
			myCollectionList.clearCollections();
		}
		
		/**
		 * Changes the browser into SHELF MODE.
		 * Makes the browser smaller and the shelf appear.
		 * Puts each tile in 'edit mode' 
		 */		
		public function showShelf():void {
			// Resize the browser/shelf
			// Make browser and shelf 50-50 respectively
			otherVGroup.percentHeight = 55;
			
			myAssetBrowser.refreshMediaAssetsDisplay();
			
			myAssetBrowser.lockReadOnlyFiles();
			
			myAssetBrowserToolbar.disableUpload();
				
			myShelf.percentHeight = 45;
			myShelf.refreshMediaAssetsDisplay();
			myShelf.enableButtons();
			this.myShelf.visible = true;
			
			myCollectionList.enterEditMode();
			// Set all the tiles into edit mode
			//myAssetBrowser.setEditMode(assetsInShelf);
		}
		
		public function hideShelf():void {
			// Make browser fullsize, and shelf 0
			myShelf.height = 0;
			otherVGroup.percentHeight = 100;
			
			myAssetBrowser.unlockFiles();
			
			myAssetBrowserToolbar.enableUpload();
			
			// Pop both the buttons that could be down, up.
			myCollectionList.unsetCreateCollectionButton();
			this.unsetEditButton();
			
			// Removes the overlays (it does this based on the values in the browser controller
			// so you have to make sure the edit and collection creation are set to false)
			myAssetBrowser.refreshMediaAssetsDisplay();
			
//			myCollectionList.exitEditMode();
		}
		
		public function unsetCreateCollectionButton():void {
			myCollectionList.unsetCreateCollectionButton();
		}
		
		public function setDiscussionShowEditIcon(discussionID:Number):void {
			myCollectionList.setDiscussionShowEditIcon(discussionID);
		}
		
		public function removeDiscussionEditIcon():void {
			myCollectionList.removeDiscussionEditIcon();
		}
//		public function unsetEditButton():void {
//			myAssetBrowser.unsetEditButton();
//		}
		
		/**
		 * Removes media from the shelf (not Titlte) 
		 * 
		 */		
		public function removeShelfMedia():void {
			myAssetBrowser.refreshMediaAssetsDisplay();
			myShelf.clearMediaAssets(true);
		}
		/**
		 * Removes all media AND title from the shelf
		 */		
		public function clearShelf():void {
			// Removes the overlays (it does this based on the values in the browser controller
			// so you have to make sure the edit and collection creation are set to false)
			myAssetBrowser.refreshMediaAssetsDisplay();
			myShelf.clearMediaAssets();
		}
		
		public function setShelfCollectionName(name:String):void {
			trace("Self collection name set as:", name);
			myShelf.setCollectionName(name);
		}

		/**
		 * Adds a single asset to the shelf view 
		 * @param asset the model_media of the asset to be added
		 * 
		 */		
		public function addAssetToShelf(asset:Model_Media):void {
			myShelf.addMediaAsset(asset);
		}
		
		/**
		 * Removes a single asset from the shlef 
		 * @param assetID	The ID of the asset to remove from the shelf.
		 * 
		 */		
		public function removeAssetFromShelf(assetID:Number, mtime:String):void {
			myShelf.removeMediaAsset(assetID, mtime);
			myAssetBrowser.updateAssetTile(assetID);
			
		}
		
		public function updateNewCollectionButton():void {
			myCollectionList.updateNewCollectionButton();
		}
		
		/**
		 * Called by Controller when the sharing info for the asset has been loaded.
		 * Passes the data to the sharing panel. 
		 * @param	sharingData	An array of data with user+access information.
		 */		
		public function setupAssetsSharingInformation(sharingData:Array, assetCreatorUsername:String):void {
			mySharingPanel.setupAssetsSharingInformation(sharingData, assetCreatorUsername);
		}
		
		/**
		 * Tells the Asset Browser that new assets are being loaded
		 * So show the loading animation. Called from @see BrowserController 
		 * 
		 */		
		public function showMediaLoading():void {
			myAssetBrowser.showMediaLoading();
		}
		
		/* Functions for Comment Panel */
		/**
		 * The comment has been saved, so tell the comments panel to make it appear
		 * as a regular comment, not a new one. 
		 * @param newCommentObject	The comment that has been saved.
		 * 
		 */		
		public function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void {
			this.setCommentCount(commentCount + 1);
			myCommentsPanel.commentSaved(commentID, commentText, newCommentObject);
		}
		
		
		/**
		 * Unpops the Edit button 
		 */		
		public function unsetEditButton():void {
			myAssetBrowserToolbar.unsetEditButton();
		}
		
		
		public function setToolbarToFixedCollectionMode():void {
			myAssetBrowserToolbar.setToolbarToFixedCollectionMode();
		}
		
		public function setToolbarToRegularCollectionMode(modifyAccess:Boolean):void {
			myCommentsPanel.setUserAccess(modifyAccess);
			mySharingPanel.setUserAccess(modifyAccess);
			myAssetBrowserToolbar.setToolbarToRegularCollectionMode(modifyAccess);
		}
		
		/**
		 * Comment button says 'Comments (0)'. We have to set that number,
		 * to be the number of comments. We save this number.
		 * @param commentCount	The numbero f comments.
		 * 
		 */		
		public function setCommentCount(commentCount:Number):void {
			this.commentCount = commentCount;
			myAssetBrowserToolbar.setCommentCount(commentCount);
		}
		
		public function unlockSharingPanelUsers():void {
			mySharingPanel.unlockUsers();
		}
		/**
		 * Hides all the panels being displayed.
		 * 
		 * Used when we switch to a fixed collection, like All Assets, or Shared with Me 
		 * 
		 */		
		public function hideAllPanels():void {
			myCommentsPanel.hide();
			mySharingPanel.hide();
		}
		
		
		/* ============== EVENT LISTENER FUNCTIONS ==================== */
		private function commentsButtonClicked(e:IDEvent):void {
//			if(e.data.buttonState) {
				mySharingPanel.hide();
				
				myCommentsPanel.show();
//			} else {
//				myCommentsPanel.width = 0;
//			}
		}
		
		private function shareButtonClicked(e:IDEvent):void {
//			if(e.data.buttonState) {
				myCommentsPanel.hide();
				
				mySharingPanel.show();
//			} else {
//				mySharingPanel.width = 0;
//			}
		}
		
		/**
		 * Some text was entered in the search input. Grab the text, and pass it into the displayer
		 * to search for elements. 
		 * @param e
		 * 
		 */		
		private function searchTermEntered(e:IDEvent):void {
			trace("Search Event Caught");
			var searchTerm:String = e.data.searchTerm;
			myAssetBrowser.searchForAsset(searchTerm);
		}
	}
}