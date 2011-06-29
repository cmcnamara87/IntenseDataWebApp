package View.components.AssetBrowser
{
	import Controller.IDEvent;
	
	import View.BrowserView;
	import View.Element.AssetBrowser;
	import View.components.AssetDisplayer;
	import View.components.CollectionList.CollectionList;
	
	import flash.events.Event;
	
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.utils.SHA256;
	
	import spark.components.BorderContainer;
	import spark.components.TextInput;
	import spark.layouts.VerticalLayout;
	
	public class AssetBrowser extends BorderContainer
	{
		
		private var myAssetDisplayer:AssetDisplayer; // Displays the assets as tiles
		
		public function AssetBrowser()
		{
			super();
			
			// Setup size
			this.minWidth = 300;
			
			// Set the backgrond colour & border collect
			this.backgroundFill = new SolidColor(0xFFFFFF);
			this.setStyle("borderVisible", false);
			
			// Setup the layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
//			// Add the Search Toolbar
//			myAssetBrowserToolbar = new AssetBrowserToolbar();
//			this.addElement(myAssetBrowserToolbar);
			
			// Add the AssetBrowser
			// Pass in the Event to run when an item in teh browser is clicked
			myAssetDisplayer = new AssetDisplayer(IDEvent.ASSET_BROWSER_MEDIA_CLICKED);
			// Setup the size
			myAssetDisplayer.percentHeight = 100;
			myAssetDisplayer.percentWidth = 100;
			this.addElement(myAssetDisplayer);
		}
		
		/**
		 * Adds media tiles to the display 
		 * @param 	assetArray	An array of media objects
		 * 
		 */	
		public function addMediaAssets(assetArray:Array):void {
			myAssetDisplayer.addMediaAssets(assetArray);
		}
		
		/**
		 * Removes the current Assets being displayed 
		 */		
		public function clearMediaAssets():void {
			myAssetDisplayer.clearMediaAssets();
		}
		
		/**
		 * Disables any tiles that are read-only. Used when 
		 * we are in edit mode, as these files cannot be moved/added to collection etc 
		 * 
		 */		
		public function lockReadOnlyFiles():void {
			myAssetDisplayer.lockReadOnlyFiles();
		}
		
		public function unlockFiles():void {
			myAssetDisplayer.unlockFiles();
		}
		
		/**
		 * Updates a specific asset tile. This is called when we want to display
		 * either the 'Add' or 'Remove' when using the shelf. Calling 'update'
		 * tells the tile to check if we are in shelf mode, then change its appearance
		 * according to whether it is in the shelf or not. 
		 * @param assetID	The ID of the asset to update.
		 * 
		 */		
		public function updateAssetTile(assetID:Number):void {
			myAssetDisplayer.updateAssetTile(assetID);
		}
		
		/**
		 * Same as @see updateAssetTile but updates ALL assets 
		 * 
		 */		
		public function refreshMediaAssetsDisplay():void {
			myAssetDisplayer.refreshMediaAssetsDisplay();
		}
		
		public function showMediaLoading():void {
			myAssetDisplayer.loadingContent();
		}

		/* ===== FUNCTIONS FOR TOOL BAR ===== */
//		/**
//		 * Unpops the Edit button 
//		 */		
//		public function unsetEditButton():void {
//			myAssetBrowserToolbar.unsetEditButton();
//		}
//		
//		
//		public function setToolbarToFixedCollectionMode():void {
//			myAssetBrowserToolbar.setToolbarToFixedCollectionMode();
//		}
//		
//		public function setToolbarToRegularCollectionMode():void {
//			myAssetBrowserToolbar.setToolbarToRegularCollectionMode();
//		}
//		
//		/**
//		 * Comment button says 'Comments (0)'. We have to set that number,
//		 * to be the number of comments. 
//		 * @param commentCount	The numbero f comments.
//		 * 
//		 */		
//		public function setCommentCount(commentCount:Number):void {
//			myAssetBrowserToolbar.setCommentCount(commentCount);
//		}
//		
		/**
		 * Buts the browser in edit mode, that is, all the tiles display either "ADD" or "REMOVE"
		 * based on if they are or arent in the assetsInShelf array 
		 */		
		public function setEditMode(assetsInShelf:Array):void {
			
		}
		
		public function searchForAsset(searchTerm:String):void {
			myAssetDisplayer.searchForAssets(searchTerm);
		}

	}
}