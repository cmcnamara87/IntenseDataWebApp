package View.Element {
	import Controller.IDEvent;
	
	import Model.Model_Collection;
	import Model.Model_Media;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.containers.HBox;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	public class AssetBrowser extends RecensioUIComponent {
		
		private var assets:Array = new Array();
		private var padding:Number = 12;
		private var container:Container = new Container();
		private var innerContainer:RecensioUIComponent = new RecensioUIComponent();
		private var searchTerm:String = "";
		private var bottomMenuHeight:Number = 0;
		private var hidden:Boolean = false;
		
		public function AssetBrowser() {
			super();
			addChild(container);
			container.addChild(innerContainer);
		}
		
		// Hide the asset browser (usually when the collection browser is shown)
		public function hide(isHidden:Boolean):void {
			hidden = isHidden;
			if(hidden) {
				removeAssets();
			}
			draw();
		}
		
		// Redraw the browser (or hide)
		override protected function draw():void {
			if(!hidden) {
				refreshView();
				drawBackground();
				resizeContainer();
			} else {
				restart();
			}
		}
		
		// Hide everything
		private function restart():void {
			this.height = 0;
			container.graphics.clear();
		}
		
		// Resizes the container
		private function resizeContainer():void {
			container.width = this.width;
			container.height = this.height-bottomMenuHeight;
		}
		
		// Draws the background of the asset browser
		private function drawBackground():void {
			container.graphics.clear();
			container.graphics.lineStyle(1,0xCCCCCC);
			container.graphics.drawRect(-1,-1,this.width,this.height);
		}
		
		// Remove all assets from the array and refresh the view
		public function removeAssets():void {
			//innerContainer.removeAllChildren();
			for(var i:Number=assets.length-1; i>-1; i--) {
				removeAsset(assets[i]);
			}
			assets = new Array();
			refreshView();
		}
		
		// Removes a single asset from the array
		private function removeAsset(asset:AssetPreview):void {
			if(asset.hasEventListener(MouseEvent.MOUSE_UP)) {
				// If there is no event listener, this has no effect
				// So lets try and remove both the media clicker listener
				// and the collection clicked listener
				// (even though it will only have 1)
				asset.removeEventListener(MouseEvent.MOUSE_UP, assetMediaClicked);
				asset.removeEventListener(MouseEvent.MOUSE_UP, assetCollectionClicked);
			}
			if(asset.parent) {
				asset.parent.removeChild(asset);
			}
			assets.splice(assets.indexOf(asset),1);
		}
		
		/**
		 * Creates a new AssetPreview for Media (e.g. video, images etc)
		 * and adds it to the list of assets to display. 
		 * 
		 * @param 	assetDetails	The details of the asset preview to create
		 * 
		 */		
		public function addMediaAsset(assetDetails:Model_Media):void {
			var newasset:AssetPreviewMedia = new AssetPreviewMedia(assetDetails);
			
			newasset.addEventListener(MouseEvent.MOUSE_UP,assetMediaClicked);
			
			assets.push(newasset);
		}
		
		/**
		 * Creates a new AssetPreview for a Collection and adds it to the
		 * list of assets to display
		 *  
		 * @param 	assetDetails	The details of the asset preview to create
		 * 
		 */		
		public function addCollectionAsset(assetDetails:Model_Collection):void {
			// Only add collections, that have some files in it
			// For some reason, you can create empty collections, 
			// so we have to filter that out.
			if(assetDetails.numberOfChildren()) {				
				var newAssetPreviewCollection:AssetPreviewCollection = new AssetPreviewCollection(assetDetails);
				
				newAssetPreviewCollection.addEventListener(MouseEvent.MOUSE_UP, assetCollectionClicked);
				
				assets.unshift(newAssetPreviewCollection);
				
				// Create a new CollectionAssetPreview
				// Add an event listener to it being clicker
				// Asset.push? does something? some kind of array of collections
			}
			//var newasset:AssetPreview = new AssetPreview(assetDetails);
			//newasset.setData(assetDetails);
			//newasset.addEventListener(MouseEvent.MOUSE_UP,assetClicked);
			//assets.push(newasset);
		}
		
		/**
		 * Called when a Media Asset Tile is clicked.
		 * Dispatches an Media Asset Clicked event 
		 * 
		 * @param 	e	The Mouse Click Event
		 * 
		 */		
		private function assetMediaClicked(e:MouseEvent):void {
			trace("MEDIA CLICKED");
			var assetID:Number = (e.target as AssetPreviewMedia).getID();
			var clickEvent:IDEvent = new IDEvent(IDEvent.ASSET_MEDIA_CLICKED);
			clickEvent.data.assetID = assetID;
			this.dispatchEvent(clickEvent);
		}
		
		/**
		 * Called when a Collection Asset Tile is clicked.
		 * Dispatches an Collection Asset Clicked event 
		 * 
		 * @param 	e	The Mouse Click Event
		 * 
		 */		
		private function assetCollectionClicked(e:MouseEvent):void {
			trace("COLLECTION CLICKED");
			var assetID:Number = (e.target as AssetPreviewCollection).getID();
			var clickEvent:IDEvent = new IDEvent(IDEvent.ASSET_COLLECTION_CLICKED);
			clickEvent.data.assetID = assetID;
			
			this.dispatchEvent(clickEvent);
			
		}
		
		// Sets the filter to only show assets which match the term
		public function filter(searchTerm:String):void {
			this.searchTerm = searchTerm;
			refreshView();
		}
		
		// Sets the new asset preview size
		public function setAssetPreviewSize(newSize:Number):void {
			AssetPreview.assetWidth = newSize;
			refreshView();
		}
		
		// Refreshes the view, removes all assets and replaces them
		public function refreshView():void {
			innerContainer.removeAllChildren();
			var currentXPos:Number = padding;
			var currentYPos:Number = padding;
			for each (var asset:AssetPreview in assets) {
				asset.forceDraw();
				var useAsset:Boolean = true;
				if(searchTerm != "") {
					useAsset = asset.matchesString(searchTerm);
				}
				if(useAsset) {
					asset.x = currentXPos;
					asset.y = currentYPos;
					currentXPos += AssetPreview.assetWidth + padding;
					if(currentXPos + AssetPreview.assetWidth + padding > this.width) {
						currentXPos = padding;
						currentYPos += AssetPreview.assetHeight + padding;
					}
					innerContainer.addChild(asset);
				}
			}
			innerContainer.width = currentXPos+AssetPreview.assetWidth;
			innerContainer.height = currentYPos+AssetPreview.assetHeight+padding;
		}
	}
}