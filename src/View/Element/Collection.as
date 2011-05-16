package View.Element {
	import Controller.RecensioEvent;
	
	import Lib.it.transitions.Tweener;
	
	import Model.Model_Collection;
	import Model.Model_Media;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Collection extends RecensioUIComponent {
		
		public static var theWidth:Number = 0;
		public static var titlebarHeight:Number = 40;
		private var titlebar:CollectionTitlebar = new CollectionTitlebar();
		public var theheight:Number = 40;
		private var assetArea:RecensioUIComponent = new RecensioUIComponent();
		private var collectionData:Model_Collection;
		private var mediaData:Array;
		private var assets:Array = new Array();
		private var padding:Number = 10;
		private var editMode:Boolean = false;
		private var showAssetsType:String = "none";
		private var _newCollection:Boolean = false;
		private var assetsChosen:Number = 0;
		
		public function Collection() {
			theheight = titlebarHeight;
			this.height = titlebarHeight;
			super();
			setupAssetArea();
			setupTitlebar();
		}
		
		// Gets the title for the collection
		public function get title():String {
			return collectionData.meta_title;
		}
		
		// Sets whether the collection is new
		public function setNewCollection(isNew:Boolean):void {
			_newCollection = isNew;
			if(isNew) {
				titlebar.setNewMode(true);
				editMode = true;
				showAssets();
			}
		}
		
		// Sets up the title bar and event listeners
		private function setupTitlebar():void {
			addChild(titlebar);
			titlebar.addEventListener(RecensioEvent.COLLECTION_CLICKED,toggleAssets);
			titlebar.addEventListener(RecensioEvent.COLLECTION_NAV_CLICKED,toggleCollectionMode);
		}
		
		// Sets up the asset area
		private function setupAssetArea():void {
			addChild(assetArea);
			assetArea.width = theWidth;
			assetArea.y = titlebarHeight;
		}
		
		// Gets the asset ID of the collection
		public function getID():Number {
			return collectionData.base_asset_id;
		}
		
		// Sets the asset ID of the collection
		public function setAssetID(newID:String):void {
			collectionData.base_asset_id = Number(newID);
		}
		
		// Redraws the collection
		override protected function draw():void {
			theheight = titlebarHeight+assetArea.height;
			titlebar.forceDraw();
			drawAssets();
			if(_newCollection) {
				if(assetArea.height > 101) {
					this.dispatchEvent(new RecensioEvent(RecensioEvent.COLLECTION_CLICKED));
				}
			}
			assetArea.width = theWidth;
			assetArea.graphics.clear();
			assetArea.graphics.lineStyle(1,0xCCCCCC,1);
			assetArea.graphics.beginFill(0xEEEEFF,1);
			assetArea.graphics.drawRect(0,0,assetArea.width,assetArea.height);
		}
		
		// Sets the data of the collection
		public function setCollectionData(data:Model_Collection):void {
			collectionData = data;
			titlebar.setTitle(data.meta_title);
		}
		
		// Sets the data of all potential assets in a collection (for edit mode)
		public function setAssetsData(data:Array):void {
			mediaData = data;
			for(var i:Number=0; i<mediaData.length; i++) {
				addAsset(mediaData[i]);
			}
		}
		
		// Sets the mode of the collection (editing or viewing)
		private function showAssets():void {
			if(editMode) {
				showAssetsType = "edit";
				drawAssets();
			} else {
				showAssetsType = "collection";
				drawAssets();
			}
			assetArea.alpha = 0;
			Tweener.addTween(assetArea,{height:assetArea.height,transition:"easeInOutCubic",time:0.5,alpha:1,onUpdate:draw});
			draw();
			this.dispatchEvent(new RecensioEvent(RecensioEvent.COLLECTION_CLICKED));
		}
		
		// Draws each of the asset previews for the collection (or all assets if in editing mode)
		private function drawAssets():void {
			var type:String = showAssetsType;
			assetArea.removeAllChildren();
			if(type != 'none') {
				var xPos:Number = padding;
				var yPos:Number = padding;
				for(var i:Number=0; i<assets.length; i++) {
					var showAsset:Boolean = false;
					if(type == 'edit') {
						showAsset = true;
						assets[i].setEditMode(true);
					} else if (type == 'collection') {
						assets[i].setEditMode(false);
						if(in_collection(""+(assets[i] as AssetPreviewMedia).getID())) {
							showAsset = true;
						}
					}
					if(showAsset) {
						assetArea.addChild(assets[i]);
						if(in_collection(""+(assets[i] as AssetPreviewMedia).getID())) {
							assets[i].selectedAsset(true);
						} else {
							assets[i].selectedAsset(false);
						}
						assets[i].x = xPos;
						assets[i].y = yPos;
						(assets[i] as AssetPreview).forceDraw();
						xPos += AssetPreview.assetWidth + padding;
						if((xPos + AssetPreview.assetWidth + padding) > theWidth) {
							xPos = padding;
							yPos += AssetPreview.assetHeight + padding;
						}
					}
				}
				assetArea.height = yPos + AssetPreview.assetHeight+padding;
			}
		}
		
		// Adds a new asset to the collection
		public function addAsset(assetDetails:Model_Media):void {
			var newasset:AssetPreviewMedia = new AssetPreviewMedia(assetDetails);
			//newasset.setData(assetDetails);
			newasset.addEventListener(MouseEvent.MOUSE_UP,assetClicked);
			assets.push(newasset);
		}
		
		// Called when an asset preview is clicked
		private function assetClicked(e:MouseEvent):void {
			if(editMode) {
				if((e.target as AssetPreviewMedia).isSelected()) {
					(e.target as AssetPreviewMedia).selectedAsset(false);
					assetsChosen--;
					if(assetsChosen < 1) {
						titlebar.showSaveButton(false);
					}
				} else {
					(e.target as AssetPreviewMedia).selectedAsset(true);
					titlebar.showSaveButton(true);
					assetsChosen++;
				}
				//need to save this to a changed datastructure
			} else {
				var assetID:Number = (e.target as AssetPreviewMedia).getID();
				var clickEvent:RecensioEvent = new RecensioEvent(RecensioEvent.ASSET_MEDIA_CLICKED);
				clickEvent.data.assetID = assetID;
				this.dispatchEvent(clickEvent);
			}
		}
		
		// Called when the assets are resized
		public function assetsResized():void {
			draw();
		}
		
		// Returns whether the collection matches a search term
		public function hasTerm(term:String):Boolean {
			for (var i:Number=0; i<assets.length; i++) {
				if(in_collection(""+(assets[i] as AssetPreviewMedia).getID())) {
					if((assets[i] as AssetPreviewMedia).matchesString(term)) {
						return true;
					}
				}
			}
			return false;
		}
		
		// Hides the assets in a collection (usually when the titlebar has been clicked to hide the assets)
		private function hideAssets():void {
			Tweener.removeAllTweens();
			showAssetsType = "none";
			drawAssets();
			assetArea.height = 0;
			draw();
			this.dispatchEvent(new RecensioEvent(RecensioEvent.COLLECTION_CLICKED));
		}
		
		// Toggles whether the assets are shown or hidden
		private function toggleAssets(e:Event=null):void {
			trace(this.collectionData.base_asset_id);
			if(editMode) {
				editMode = false;
				titlebar.setEditMode(editMode);
			}
			if(assetArea.height == 0) {
				showAssets();
			} else {
				hideAssets();
			}
		}
		
		// Toggles between a new collection, or editing or viewed, or deleted
		private function toggleCollectionMode(e:RecensioEvent):void {
			switch(e.data.buttonName) {
				case 'Create':
					editMode = false;
					showAssets();
					saveCollection(e.data.updatedTitle);
					break;
				case 'Edit':
					editMode = true;
					showAssets();
					break;
				case 'Delete':
					//Delete the collection
					deleteCollection();
					break;
				case 'Save':
					//Save the collection
					saveCollection(e.data.updatedTitle);
					editMode = false;
					showAssets();
					break;
				case 'Cancel':
					editMode = false;
					showAssets();
					break;
				case 'Cancel ':
					deleteCollection();
					break;
			}
			titlebar.setEditMode(editMode);
		}
		
		// Packages up the collection information and dispatches it
		private function saveCollection(newTitle:String):void {
			collectionData.meta_title = newTitle;
			titlebar.setTitle(newTitle);
			collectionData.hasChild = new Array();
			for (var i:Number=0; i<assets.length; i++) {
				if((assets[i] as AssetPreviewMedia).isSelected()) {
					collectionData.hasChild.push(""+(assets[i] as AssetPreviewMedia).getID());
				}
			}
			collectionData.meta_description = collectionData.numberOfChildren()+"";
			var saveEvent:RecensioEvent = new RecensioEvent(RecensioEvent.COLLECTION_SAVE);
			saveEvent.data.assetID = collectionData.base_asset_id;
			saveEvent.data.meta_title = collectionData.meta_title;
			saveEvent.data.meta_description = collectionData.meta_description;
			saveEvent.data.hasChild = collectionData.hasChild;
			dispatchEvent(saveEvent);
		}
		
		// Called when the collection is to be deleted
		private function deleteCollection():void {
			var deleteEvent:RecensioEvent = new RecensioEvent(RecensioEvent.COLLECTION_DELETED);
			deleteEvent.data.assetID = collectionData.base_asset_id;
			this.dispatchEvent(deleteEvent);
		}
		
		// Checks whether an asset is in the collection
		private function in_collection(theAssetID:String):Boolean {
			if(collectionData.hasChild.indexOf(theAssetID) > -1) {
				return true;
			}
			return false;
		}
	}
}