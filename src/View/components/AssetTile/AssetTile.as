package View.components.AssetTile
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import Lib.it.transitions.Tweener;
	
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import View.Element.BackgroundImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.effects.Fade;
	import mx.effects.Resize;
	import mx.graphics.BitmapFill;
	
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.effects.Fade;
	import spark.effects.Resize;
	
	public class AssetTile extends VGroup
	{
		
		private var imageSize:Number = 112; // the size of the icon. 112 as default
											// as the icon has the 'remove'/'add' overlay
											// which is in a bordercontainer
											// which has a min-wdith of 112
		private var image:AssetTileImage; // the assets icon
		private var caption:spark.components.Label; // The caption for the tile (asset title)
		private var assetData:Model_Media // the data for the asset 
		private var eventToThrowWhenClicked:String;
		
		public function AssetTile(assetData:Model_Media, eventToThrowWhenClicked:String)
		{
			super();
			this.assetData = assetData;
			this.eventToThrowWhenClicked = eventToThrowWhenClicked;
			
			// Setup size
			this.width = imageSize;//AssetTileImage.size;
			
			// Setup hand cursor
			this.useHandCursor = true;
			this.buttonMode = true;

			// Setup Image
			image = new AssetTileImage(assetData.type);
			this.addElement(image);
			
			// Are we in Edit/Shelf Mode???
			showOverlay();
					
			// Add the caption
			caption = new spark.components.Label();
			
			caption.text = assetData.meta_title;
			caption.setStyle('textAlign', TextAlign.CENTER);
			//caption.setStyle('fontWeight', 'bold');
			caption.percentWidth = 100;
			this.addElement(caption);
			
			// Listen for the asset being clicked
			// Change icon to 'clicked' version on mouse down
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, assetTileClicked);
			// Listen for mouse over
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOvered);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			
		}
		
		public function hide():void {
			this.visible = false;
			this.includeInLayout = false;
		}
		public function show():void {
			this.visible = true;
			this.includeInLayout = true;
		}
		
		/**
		 * Shows the overlay that has 'add' or 'remove' 
		 * 
		 */		
		public function showOverlay():void {
			
			var assetsToMatch:Array;
			
			if(BrowserController.getEditOn()) {
				// If we are in Edit Mode
				trace("In Edit Mode");
				assetsToMatch = BrowserController.getEditAssets();
				
				
			} else if (BrowserController.getShelfOn()) {
				// if we are in collection create mode
				trace("In Creation Mode");
				assetsToMatch = BrowserController.getShelfAssets();
			} 
			
			if(BrowserController.getEditOn() || BrowserController.getShelfOn()) {
				// Sets the add overlay to be on
				image.setAddOverlay();
				
				// Check if this tile is in the Collection Creator or Collection Editor,
				// If it is, then we want to display 'remove' on the image
				// instead of add.
				for(var i:Number = 0; i < assetsToMatch.length; i++) {
					
					var assetID:Number = (assetsToMatch[i] as Model_Media).base_asset_id;
					trace("Asset In Edit", assetID);
					if(assetID == this.assetData.base_asset_id) {
						image.setRemoveOverlay();
					}
				}
			} else {
				// Its neither add mode, or edit mode, so lets remove the overlay all together.
				image.hideOverlay();
			}
		}
		
		/**
		 * Appends the words 'Annotation In' to the title of the tile
		 * This is used when searching from the @see AssetBrowser
		 * and when in the @see AssetDisplayer, the search only matches
		 * the assets annotation data, and not title etc
		 * 
		 */		
		public function appendAnnotationIn():void {
			caption.text = 'Annotation in ' + assetData.meta_title;
		}
		
		public function resetTitle():void {
			caption.text = assetData.meta_title;
		}
		
		/**
		 * Changes the size of the image (and thus, the tile) 
		 * @param size the size in pixels of the image size x size
		 * 
		 */		
		public function changeImageSize(size:Number):void {
			trace('tile size changing to ', size);
			imageSize = size;
			this.width = imageSize;
			image.changeImageSize(size);
		}
		
		/**
		 * Called by AssetDisplayer when new tiles are loading.
		 * These tiles are still displayed, but we remove the ability to click them. 
		 * 
		 */		
		public function removeClickListener():void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, assetTileClicked);
			this.useHandCursor = true;
			this.buttonMode = true;
		}
		
		/* ============ EVENT LISTENER FUNCTIONS ================= */
		/**
		 * The asset tile was clicked, tell its parent (asset browser, shelf or edit). 
		 * @param e click event.
		 * 
		 */		
		private function assetTileClicked(e:MouseEvent):void {
			trace('Asset ', assetData.base_asset_id, ' was clicked.');
			
			image.showRegularIcon();

			// Make new asset clicked event
			var clickEvent:IDEvent = new IDEvent(eventToThrowWhenClicked, true);
			// Include ALL media data (so we can add to shelf/edit with all the data it needs), or, its just ignored if we are going to the asset
			clickEvent.data.assetData = assetData;
			this.dispatchEvent(clickEvent);
			
			showOverlay();
		}
		
		private function mouseDown(e:MouseEvent):void {
			image.alpha = 1;
			image.showClickedIcon();
		}
		
		private function mouseOvered(e:MouseEvent):void {
			image.alpha = 0.8
		}
		
		private function mouseOut(e:MouseEvent):void {
			image.alpha = 1;
		}
		
		
		/* ============= GETTERS ===================== */
		/**
		 * Gets the ID for this asset
		 */		
		public function getAssetID():Number {
			return assetData.base_asset_id;
		}
		
		public function getTitle():String {
			return assetData.meta_title;
		}
		
		public function getDescription():String {
			return assetData.meta_description;
		}
		
		public function getCommentString():String {
			var returnString:String = "";
			for(var i:Number = 0; i < assetData.annotationsAndComments.length; i++) {
				var currentAnnotation:Model_Commentary = assetData.annotationsAndComments[i] as Model_Commentary;
				returnString += " " + currentAnnotation.annotation_text.toLowerCase();
			}
			return returnString;
		}
	}
}