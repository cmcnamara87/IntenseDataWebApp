package View.components.AssetTile
{
	import Controller.BrowserController;
	import Controller.Utilities.AssetLookup;
	
	import Lib.it.transitions.Tweener;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.effects.Resize;
	import mx.graphics.BitmapFill;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	public class AssetTileImage extends BorderContainer
	{	
		
		private var loader:Loader;
		private var size:Number = 112; // This is the height/width is pixels of the image
		private var editingOverlay:BorderContainer; // The Overlay that appears when editing, says 'add' or 'remove'
													// and is black or red respectively
		private var overlayLabel:Label;
		
		private var icon:BitmapFill;
		
		private var type:String; // The type of icon, eg. picture, video, audio etc
		
		/**
		 * Creates an Image for the AssetTile of size width/height. 
		 * @param 	type	The type of the tile (e.g. video, image, document etc)
		 */		
		public function AssetTileImage(type:String, url:String = "")
		{			
			super();
			
			this.type = type;
			
			// Setup Size of the tile (width and height includes the text and picture)
			this.width = size;
			this.height = size;
			
			this.borderStroke = new SolidColorStroke(0xFFFFFF, 1, 0);
			
			// Setup background icon
			// if its an image, try and...get a screenshot
			// TODO WORK OUT HOW TO GET LOW RES COPIES OF THE IMAGES
			if(url != "") {
				trace(url);
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, backgroundImageLoaded);
				loader.load(new URLRequest(url));
			}
			
			// Get and fill the asset icon for this type of asset
			icon = new BitmapFill();
			icon.source = AssetLookup.getAssetImage(type);
			this.backgroundFill = icon;
			
			// Setup the overlay that shows either 'Share' or 'Unshare' in make collection mode (also edit if i ever do it)
			editingOverlay = new BorderContainer();
			// Setup Size
			editingOverlay.height = 25;
			editingOverlay.percentWidth = 100;
			editingOverlay.setStyle('cornerRadius',3);
			// Setup Stroke
			editingOverlay.borderStroke = new SolidColorStroke(0xFFFFFF, 1, 0);
			// Setup Positioning
			editingOverlay.bottom = 20;
			editingOverlay.visible = false;
			// Setup Layout
			var overlayLayout:HorizontalLayout = new HorizontalLayout();
			overlayLayout.verticalAlign = "middle"
			editingOverlay.layout = overlayLayout;
			this.addElement(editingOverlay);
			
			overlayLabel = new Label();
			overlayLabel.setStyle('textAlign', TextAlign.CENTER);
			overlayLabel.percentWidth = 100;
			editingOverlay.addElement(overlayLabel);
		}
		
		/**
		 * Shows the overlay that says 'Add to Collection' used when editing/creating a new collection 
		 * Turned on/off by @see AssetTile
		 * 
		 */		
		public function setAddOverlay():void {
			// Setup Background
			editingOverlay.backgroundFill = new SolidColor(0x000000, 0.7);
			overlayLabel.setStyle('color', 'white');
			if(BrowserController.currentCollectionID == BrowserController.ALLASSETID) {
				overlayLabel.text = "Copy New To " + BrowserController.PORTAL;	
			} else {
				overlayLabel.text = "Add To " + BrowserController.PORTAL;
			}
			
			// Make its alpha 0, so we can fade it in.
			editingOverlay.alpha = 0;
			editingOverlay.visible = true;
			Lib.it.transitions.Tweener.addTween(editingOverlay,{transition:"easeInOutCubic",time:0.2,alpha:1});
		}
		
		/**
		 * Shows the overlay that says 'Remove'. Used when editing/creating a new collection 
		 * Turned on/off by @see AssetTile
		 */		
		public function setRemoveOverlay():void {
			editingOverlay.backgroundFill = new SolidColor(0xFF0000, 0.9);
			overlayLabel.setStyle('color', 'black');
			overlayLabel.text = "Remove";
			// Fade it out
			Lib.it.transitions.Tweener.addTween(editingOverlay,{transition:"easeInOutCubic",time:0.2,alpha:1});
		}
		
		public function hideOverlay():void {
			//editingOverlay.visible = false;
			Lib.it.transitions.Tweener.addTween(editingOverlay,{transition:"easeInOutCubic",time:0.5,alpha:0});
		}
		
		private function hideTest(e:MouseEvent):void {
			editingOverlay.visible = false;
		}
		
		private function showTest(e:MouseEvent):void {
			editingOverlay.visible = true;
		}
		
		private function backgroundImageLoaded(e:Event):void {
			var myFill:BitmapFill = new BitmapFill();
			myFill.source = loader.content as Bitmap
			this.backgroundFill = myFill;
		}

		/**
		 * Called by @see AssetTile when the tile is clicked on.
		 * Switches the icon to a 'inset' looking icon. 
		 * 
		 */		
		public function showClickedIcon():void {
			trace("Changing background image", type);
			// Get and fill the asset icon for this type of asset
			icon.source = AssetLookup.getAssetImageClicked(type);
		}
		
		public function showRegularIcon():void {
			icon.source = AssetLookup.getAssetImage(type);
		}
		
		
		/**
		 * Changes the width, height of this tile to be newSize px 
		 * @param newSize the new width/height of the tile
		 * 
		 */		
		public function changeImageSize(newSize:Number):void {
			trace("changing tile size to: ", newSize);
			size = newSize;
			this.width = size;
			this.height = size;
		}
	}
}