package View.Element {
	import Controller.RecensioEvent;
	
	import Model.Model_Collection;
	
	import flash.utils.setTimeout;
	
	import mx.containers.VBox;
	import mx.core.Container;
	
	public class CollectionBrowser extends RecensioUIComponent {
		
		private var container:Container = new Container();
		private var innerContainer:RecensioUIComponent = new RecensioUIComponent();
		private var hidden:Boolean = true;
		private var assetsData:Array = new Array();
		private var collections:Array = new Array();
		private var padding:Number = 10;
		private var searchTerm:String = "";
		private var incomingNewCollection:Boolean = false;
		
		public function CollectionBrowser() {
			super();
			addChild(container);
			container.addChild(innerContainer);
		}
		
		// Add a collection to the collection browser
		public function addCollection(_collectionData:Model_Collection,isNew:Boolean=false):void {
			if(isNew) {
				incomingNewCollection = true;
			}
			if(_collectionData.numberOfChildren() > 0 || isNew) {
				var newcollection:Collection = new Collection();
				newcollection.setNewCollection(isNew);
				newcollection.setCollectionData(_collectionData);
				newcollection.setAssetsData(assetsData);
				newcollection.addEventListener(RecensioEvent.COLLECTION_CLICKED,collectionClicked);
				newcollection.addEventListener(RecensioEvent.ASSET_MEDIA_CLICKED,assetClicked);
				newcollection.addEventListener(RecensioEvent.COLLECTION_DELETED,collectionDeleted);
				newcollection.addEventListener(RecensioEvent.COLLECTION_SAVE,collectionSave);
				if(isNew) {
					collections = collections.reverse();
					collections.push(newcollection);
					collections = collections.reverse();
				} else {
					collections.push(newcollection);	
				}
				refreshView();
			}
		}
		
		// Redraw when expanding or hiding a collection (from titlebar)
		private function collectionClicked(e:RecensioEvent):void {
			refreshView(false);
		}
		
		// Redraw the collections based on a filter
		public function filter(searchTerm:String):void {
			this.searchTerm = searchTerm;
			refreshView();
		}
		
		// Set the asset data of potential assets for a collection
		public function setAssetData(_assetsData:Array):void {
			assetsData = _assetsData;
		}
		
		// Resize the asset preview width
		public function setAssetPreviewSize(newSize:Number):void {
			AssetPreview.assetWidth = newSize;
			for(var i:Number=0; i<collections.length; i++) {
				collections[i].assetsResized();
			}
			refreshView();
		}
		
		// Redraw
		override protected function draw():void {
			if(!hidden) {
				refreshView(false);
				drawBackground();
				resizeContainer();
			} else {
				restart();
			}
		}
		
		// Hide the collection browser
		private function restart():void {
			this.height = 0;
			container.graphics.clear();
		}
		
		// Remove all collections
		public function removeCollections():void {
			for(var i:Number=collections.length-1; i>-1; i--) {
				removeCollection(collections[i]);
			}
			refreshView(false);
		}
		
		// Remove a collection by its asset ID
		public function removeCollectionById(assetID:Number):void {
			if(getCollectionById(assetID)) {
				removeCollection(getCollectionById(assetID));
			}
			refreshView();
		}
		
		// Find a collection by its asset ID
		private function getCollectionById(assetID:Number):Collection {
			for(var i:Number=collections.length-1; i>-1; i--) {
				if((collections[i] as Collection).getID() == assetID) {
					return collections[i];
				}
			}
			return null;
		}
		
		// Remove a collection
		private function removeCollection(collection:Collection):void {
			if(collection.hasEventListener(RecensioEvent.COLLECTION_CLICKED)) {
				collection.removeEventListener(RecensioEvent.COLLECTION_CLICKED,collectionClicked);
			}
			if(collection.hasEventListener(RecensioEvent.ASSET_MEDIA_CLICKED)) {
				collection.removeEventListener(RecensioEvent.ASSET_MEDIA_CLICKED,assetClicked);
			}
			if(collection.hasEventListener(RecensioEvent.COLLECTION_DELETED)) {
				collection.removeEventListener(RecensioEvent.COLLECTION_DELETED,collectionDeleted);
			}
			collections.splice(collections.indexOf(collection),1);
		}
		
		// Called when an asset preview within a collection is clicked
		private function assetClicked(e:RecensioEvent):void {
			var clickEvent:RecensioEvent = new RecensioEvent(RecensioEvent.ASSET_MEDIA_CLICKED);
			clickEvent.data.assetID = e.data.assetID;
			this.dispatchEvent(clickEvent);
		}
		
		// Called when a collection is deleted
		private function collectionDeleted(e:RecensioEvent):void {
			if(e.data.assetID == -1) {
				removeCollectionById(-1);
				refreshView();
			} else {
				var deleteEvent:RecensioEvent = new RecensioEvent(RecensioEvent.COLLECTION_DELETED);
				deleteEvent.data.assetID = e.data.assetID;
				this.dispatchEvent(deleteEvent);
				refreshView();
			}
		}
		
		// Called when a collection is updated
		private function collectionSave(e:RecensioEvent):void {
			var saveEvent:RecensioEvent = new RecensioEvent(RecensioEvent.COLLECTION_SAVE);
			saveEvent.data = e.data;
			this.dispatchEvent(saveEvent);
		}
		
		// Called when a collection is created
		public function saveNewCollectionId(newID:String):void {
			incomingNewCollection = false;
			getCollectionById(-1).setAssetID(newID);
		}
		
		// Create a new collection
		public function createNewCollection():void {
			removeCollectionById(-1);
			var _col:Model_Collection = new Model_Collection();
			_col.meta_title = "New Collection";
			_col.base_asset_id = -1;
			_col.hasChild = new Array();
			addCollection(_col,true);
		}
		
		// Hide the collection browser (usually when the asset browser is shown)
		public function hide(isHidden:Boolean):void {
			hidden = isHidden;
			if(hidden) {
				removeCollections();
			}
			draw();
		}
		
		// Resize the collections browser
		private function resizeContainer():void {
			container.width = this.width;
			container.height = this.height;
		}
		
		// Redraw the background
		private function drawBackground():void {
			container.graphics.clear();
			container.graphics.lineStyle(1,0xCCCCCC);
			container.graphics.drawRect(-1,-1,this.width,this.height);
		}
		
		// Refresh the collections and reposition them
		public function refreshView(redrawCollections:Boolean = true):void {
			if(!incomingNewCollection) {
				collections.sortOn("title",Array.CASEINSENSITIVE);
			}
			Collection.theWidth = this.width-padding*2;
			if(redrawCollections) {
				innerContainer.removeAllChildren();
			}
			var currentYPos:Number = padding;
			for each (var collection:Collection in collections) {
				if(searchTerm != "") {
					if(!collection.hasTerm(searchTerm)) {
						continue;
					}
				}
				collection.x = padding;
				collection.y = currentYPos;
				currentYPos += collection.theheight+padding;
				if(redrawCollections) {
					innerContainer.addChild(collection);
				}
			}
			innerContainer.height = currentYPos;
		}
	}
}