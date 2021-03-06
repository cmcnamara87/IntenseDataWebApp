package View.components
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import Lib.LoadingAnimation.LoadAnim;
	
	import Model.Model_Collection;
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import View.Element.Collection;
	import View.components.AssetTile.AssetTile;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.events.SliderEvent;
	import mx.graphics.BitmapFill;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.HSlider;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class AssetDisplayer extends BorderContainer implements LoadableContent
	{
		private var myScroller:Scroller; // Adds scrollbars
		private var content:TileGroup; // Where all the asset tiles sit
		private var assetsInCollection:Array = new Array(); 	// All the data for all the assets in ths collection
												// need to save this, so we can restore the elements, after we remove them during search.
		
		private var eventToThrowWhenAssetClicked:String 	// The name of the event to throw when a tile is clicked
													// this is so we can distinguish between a shelf tile being clicked, and a browser tile etc
		
		
		[Embed(source="Assets/Template/background.png")] 
		private static var background:Class;
		private static var background_data:BitmapData = (new background as Bitmap).bitmapData;
		
		private var loadingLabel:spark.components.Label;
		

		public function AssetDisplayer(eventToThrowWhenAssetClicked:String, darkBackground:Boolean = false)
		{
			super();
			this.eventToThrowWhenAssetClicked = eventToThrowWhenAssetClicked;
			
			// Setup background
			if(!darkBackground) {
				var hello:BitmapFill = new BitmapFill();
				hello.source = background_data;
				hello.fillMode = BitmapFillMode.REPEAT;
				this.backgroundFill = hello;
			} else {
//				this.backgroundFill = new SolidColor(0xCCCCCC, 1);
				this.backgroundFill = new SolidColor(0xFFFFDD, 1);
			}
			// Setup the border
			//this.borderStroke = new SolidColorStroke(0x000000,1,0);
			this.setStyle("borderVisible", false);
			
			// Setup the Loading label
			var loadingGroup:HGroup = new HGroup();
			loadingGroup.percentWidth = 100;
			loadingGroup.percentHeight = 100;
			loadingGroup.verticalAlign = "middle";
			loadingGroup.gap = 0;
			this.addElement(loadingGroup);
			
			loadingLabel = new spark.components.Label();
			loadingLabel.text = "Loading...";
			loadingLabel.setStyle('fontSize', 30);
			loadingLabel.setStyle('fontWeight', 'bold');
			loadingLabel.setStyle('textAlign', 'center');
			loadingLabel.setStyle('color', 0x999999);
			loadingLabel.visible = false;
			loadingLabel.percentWidth = 100;
			loadingGroup.addElement(loadingLabel);
			
			// List Icon
//			LoadAnim.show(loadingGroup,0,0,0x000000,1);
			
//			var myIcon:Image = new Image();
//			myIcon.source = AssetLookup.getLoadingIconClass();
//			myIcon.width = 126;
//			myIcon.height = 22;
//			loadingGroup.addElement(myIcon);
			
			
			// Add a VGroup inside this broder container.
			// That way we can add the 'Loading' to the AssetDisplayer,
			// and not to the VGroup.
			var scrollerAndResizer:VGroup = new VGroup();
			scrollerAndResizer.percentWidth = 100;
			scrollerAndResizer.percentHeight = 100;
			scrollerAndResizer.gap = 0;
			this.addElement(scrollerAndResizer);
			
			// lets add a scroller, so it...scrolls lol
			myScroller = new Scroller();
			myScroller.minViewportInset = 10;
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
			// Add the scroller to the list
			scrollerAndResizer.addElement(myScroller);
			
			// create a content group so we can put it inside the scroll
			// its ia tile layout....because they look like tiles :P
			content = new TileGroup(); 
			content.verticalGap = 10;
			content.verticalGap = 10;
			
			// Add the content to the scroller
			myScroller.viewport = content;
			
			// Now we are going to add a bordercontainer at the bottom
			// to have the slider/resizer
			var sliderResizerContainer:BorderContainer = new BorderContainer();
			sliderResizerContainer.percentWidth = 100;
			sliderResizerContainer.height = 40;
			
			// Set the resizers containers background and stroke
			sliderResizerContainer.backgroundFill = new SolidColor(0xDDDDDD, 1);
			sliderResizerContainer.borderStroke = new SolidColorStroke(0xDDDDDD,1,1);
			var bottomLayout:VerticalLayout = new VerticalLayout();
			bottomLayout.paddingRight = 20;
			bottomLayout.verticalAlign = "middle";
			bottomLayout.horizontalAlign = "right";
			sliderResizerContainer.layout = bottomLayout;
			
			// Create the slider/resizer
			var slider:HSlider = new HSlider();
			slider.maximum = 300;
			slider.minimum = 112;
			slider.snapInterval = 10;
			sliderResizerContainer.addElement(slider);
			
			//scrollerAndResizer.addElement(sliderResizerContainer);
			
			// Event Listenrs
			slider.addEventListener(Event.CHANGE, resizeTiles);
		}
		
		/**
		 * Takes an array of media data objects, and creates asset tiles 
		 * and adds them to this tile layout.
		 * 
		 * @param assetArray The array of asset data for various assets
		 * 
		 */		
		public function addMediaAssets(assetArray:Array):void {
			
			// Remove any loading message thats being displayed
			loadingContentComplete();
			
			// Save the array
			this.assetsInCollection = assetArray;
			
			// Add the elements to the display
			for(var i:Number = 0; i < assetArray.length; i++) {
				content.addElement(new AssetTile(assetArray[i], eventToThrowWhenAssetClicked));	
			}
			
			if(BrowserController.getEditOn() || BrowserController.getShelfOn()) {
				lockReadOnlyFiles();
			}
		}
		
		/**
		 * Takes 1 Media asset, and adds it to the display.
		 * 
		 * @param asset The asset to be added
		 * 
		 */		
		public function addMediaAsset(asset:Model_Media):void {
			// Save in the array
			this.assetsInCollection.push(asset);
			
			// Add the element to the display
			content.addElement(new AssetTile(asset, eventToThrowWhenAssetClicked));	
		}
		
		public function removeMediaAsset(assetID:Number, mtime:String):void {
			// Find the asset in the collection data
			for(var i:Number = 0; i < assetsInCollection.length; i++) {
				if((assetsInCollection[i] as Model_Media).base_asset_id == assetID && 
					(assetsInCollection[i] as Model_Media).base_mtime == mtime) {
					assetsInCollection.splice(i, i);
				}
			}
			
			// Find the asset in the visual data
			for(i = 0; i < content.numElements; i++) {
				if((content.getElementAt(i) as AssetTile).getAssetID() == assetID &&
					(content.getElementAt(i) as AssetTile).getModTime() == mtime) {
					content.removeElementAt(i);	
				}
			}
		}
		
		public function clearMediaAssets():void {
			content.removeAllElements();
		}
		
		/**
		 * Called when Shelf is turned on 
		 * It removes all the items, then readds them, with the 'add to shelf' turned on. 
		 * 
		 */		
		public function refreshMediaAssetsDisplay():void {
			// Find the asset in the visual data
			for(var i:Number = 0; i < content.numElements; i++) {
				(content.getElementAt(i) as AssetTile).showOverlay();	
			}
		}
		
		
		public function updateAssetTile(assetID:Number):void {
			// Find the asset in the visual data
			for(var i:Number = 0; i < content.numElements; i++) {
				if((content.getElementAt(i) as AssetTile).getAssetID() == assetID) {
					(content.getElementAt(i) as AssetTile).showOverlay();	
				}
			}
		}
		
		/**
		 * Resizes the tiles/tile images to the size value from the hslider
		 * @param e Slider Change event
		 * 
		 */		
		private function resizeTiles(e:Event):void {
			for(var i:Number = 0; i < content.numElements; i++) {
				(content.getElementAt(i) as AssetTile).changeImageSize(	
					(e.target as HSlider).value
				);
			}
		}
		
		
		/**
		 * Removes assets that don't match the search term. 
		 * @param searchTerm
		 * 
		 */		
		public function searchForAssets(searchTerm:String):void {
			if(searchTerm == "") {
				// No search, add back in all the assets
				trace("making all visible");
				for(var i:Number = 0; i < content.numElements; i++) {
					var tile1:AssetTile = (content.getElementAt(i) as AssetTile); 
					tile1.visible = true;
					tile1.includeInLayout = true;
					// Remove the 'annotation in' if its there
					tile1.resetTitle();
				}
				//addMediaAssets(assetsInCollection);
				return;
			}
			
			// Convert serachTerm to lower case (will do same with searchable data, so we can compare them);
			searchTerm = searchTerm.toLowerCase();
			
			// Remove all current tiles
			//clearMediaAssets();
			for(var j:Number = 0; j < content.numElements; j++) {
				var searchableData:String = ""; // Used to build up the search string
				// Get out the tile we are looking at
				var tile:AssetTile = content.getElementAt(j) as AssetTile;
				
				var title:String = tile.getTitle().toLowerCase();
				var description:String = tile.getDescription().toLowerCase();
				var commentString:String = tile.getCommentString().toLowerCase();
				searchableData += title + " " + description + " " + commentString;
				
				if(searchableData.indexOf(searchTerm) != -1) {
					trace("Match found", title, description);
					
					tile.show();

					if(commentString.indexOf(searchTerm) != -1 && title.indexOf(searchTerm) == -1 && description.indexOf(searchTerm) == -1) {
						// Set it to show its only a match in annotation
						// Puts the words 'Annotation in' in front of the title
						//						trace("In Annotation");
						tile.appendAnnotationIn();
					} else if (commentString.indexOf(searchTerm) == -1 && title.indexOf(searchTerm) != -1 || description.indexOf(searchTerm) != -1) {
						tile.resetTitle();
					}
				} else {
					trace("No Match", title, description);
					//tile.visible = false;
					//tile.includeInLayout = false;
					tile.hide();
				}	
			}
			
		}
		
		public function fadeIcons():void {
			for(var i:Number = 0; i < content.numElements; i++) {
				(content.getElementAt(i) as AssetTile).alpha = 0.3;
			}
		}
		
		/**
		 * Disables all tiles for files that are read-only.
		 * 
		 * Used when we are editing/creating a new collection, we need to disable
		 * all tiles that we dont have the rights to access // RIGHTS MANAGEMENT 
		 * 
		 */		
		public function lockReadOnlyFiles():void {
			for(var i:Number = 0; i < content.numElements; i++) {
				var assetTile:AssetTile = content.getElementAt(i) as AssetTile;
				
				if(!assetTile.getAccess()) {
					assetTile.enabled = false;
				}
			}
		}
		
		/**
		 * Enables all tiles. 
		 * 
		 */		
		public function unlockFiles():void {
			for(var i:Number = 0; i < content.numElements; i++) {
				(content.getElementAt(i) as AssetTile).enabled = true;
			}
		}
		
		/* ============== LOADABLE CONTENT INTERFACE FUNCTIONS ================ */
		/**
		 * Disables the tiles and shows the loading message. 
		 * 
		 */		
		public function loadingContent():void {
			for(var i:Number = 0; i < content.numElements; i++) {
				(content.getElementAt(i) as AssetTile).enabled = true;
				(content.getElementAt(i) as AssetTile).alpha = 0.1;
				(content.getElementAt(i) as AssetTile).removeClickListener();
			}

			loadingLabel.visible = true;
			
		}
		
		public function loadingContentComplete():void {
			trace("loading content complete");
			loadingLabel.visible = false;
		}
		
	}
}