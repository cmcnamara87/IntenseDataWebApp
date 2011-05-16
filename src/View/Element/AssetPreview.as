package View.Element {
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Model.Model_Base;
	import Model.Model_Media;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.controls.Image;
	
	/**
	 * Displays the Assets (Both Media & Collection) as 
	 * Tiles with Title, Description and a Icon representing the 
	 *  
	 * @author cmcnamara87
	 * 
	 */	
	public class AssetPreview extends RecensioUIComponent {
		
		public static var assetWidth:Number = 250; // The default width of the preview tile
		public static var assetHeight:Number = 81; // The default height of the preview tile
		
		protected var _data:Model_Base; // The data for the asset
		
		protected var imageSize:Number = 60; // The size of the icon
		protected var image:Sprite; // The actual icon
		
		private var titleText:TextField; // The title field of the tile
		private var titleTextFormat:TextFormat; // The formatting for the title field
		
		private var descriptionText:TextField; // The description of the asset
		private var descriptionTextFormat:TextFormat; // The formatting for the description field
		
		private var selectedSwitch:Boolean = false; // Not sure what this does?
		
		// The background image for the tile
		[Embed(source="Assets/Template/assetpreview_bg.png")] 
		private var backgroundAssetImage:Class;
		private var backgroundAssetImageData:BitmapData;
		
		// Tick for when asset is selected in collection adding etc
		[Embed(source="Assets/Template/asset_selected.png")] 
		private var assetSelectedImage:Class; // tick file
		private var assetSelectedImageData:BitmapData; // tick bitmap
		private var selected:Sprite = new Sprite(); // sprite that holds the bitmap
		
		private var isEditing:Boolean = false; // Editing mode???
		
		private var mouseOverToggle:Boolean = false; // Is the mouse 
		
		
		public function AssetPreview(assetData:Model_Base) {
			super(); // Make it a RecensioUI Component - allows....it to do stuff.
			
			// Setup the background image
			backgroundAssetImageData = (new backgroundAssetImage as Bitmap).bitmapData;
			// Setup the tick (selected) little icon overlay
			assetSelectedImageData = (new assetSelectedImage as Bitmap).bitmapData;
			
			// Don't know what this does
			this.mouseChildren = false;
			
			// Don't know what this does either.
			setButtonMode(true);
			
			// Add image container to the tile
			addImageContainer();
			
			// Add the text fields to the tile
			addTextFields();
			
			// Sets the data, and fills in all the stuff (like the image, textfields etc)
			setDataAndRefreshDisplay(assetData);
		}
		
		/**
		 * Sets/Updates the asset preview data. 
		 * @param 	theData	The Model_Media data used to construct the preview
		 * 
		 */		
		public function setDataAndRefreshDisplay(theData:Model_Base):void {
			this._data = theData;
			refreshDisplay();
		}
		
		/**
		 * Refreshs the asset preview. 
		 * 
		 * Updates the title, description and image, based
		 * on the provided data. 
		 */		
		private function refreshDisplay():void {
			titleText.text = _data.meta_title;
			this.toolTip = _data.meta_title;
			if(mouseOverToggle) {
				titleTextFormat.color = 0x2c78bf;
				descriptionTextFormat.color = 0x2c78bf;
			} else {
				titleTextFormat.color = 0x333333;
				descriptionTextFormat.color = 0x333333;
			}
			titleText.setTextFormat(titleTextFormat);
			titleText.defaultTextFormat = titleTextFormat;
			descriptionText.text = _data.meta_description;
			descriptionText.setTextFormat(descriptionTextFormat);
			descriptionText.defaultTextFormat = descriptionTextFormat;
			titleText.width = assetWidth-titleText.x;
			descriptionText.width = assetWidth-descriptionText.x;			
			resizeText();
			
			drawImageIcon();
		}
		
		/**
		 * ABSTRACT FUNCTION
		 * This function must be overwritten in extending classes 
		 * @return 
		 * 
		 */		
		protected function drawImageIcon():void {
			trace("DRAW IMAGE ICON MUST BE OVERWRITTEN");
		}
		

		
		// Sets whether the asset preview is in editing mode (for collections)
		public function setEditMode(_isEditing:Boolean):void {
			isEditing = _isEditing;
			if(isEditing) {
				addChild(selected);
			} else {
				if(contains(selected)) {
					removeChild(selected);
				}
				this.alpha = 1;
			}
		}
		
		// Selects or deselects the asset (editing mode in collections)
		public function selectedAsset(_isSelected:Boolean):void {
			if(isEditing) {
				if(_isSelected) {
					addChild(selected);
					this.alpha = 1;
					selectedSwitch = true;
				} else {
					if(contains(selected)) {
						removeChild(selected);
					}
					selectedSwitch = false;
					this.alpha = 0.5;
				}
			}
		}
		
		// Returns the ID of the asset preview
		public function getID():Number {
			if(_data) {
				return _data.base_asset_id;
			} else {
				return -1;
			}
		}
		
		/**
		 * Draws the background for the asset tile
		 * 
		 * Has grey border, and adds a 2px thick blue border when mouse hovers. 
		 */		
		private function drawBackground():void {
			this.graphics.clear();
			if(mouseOverToggle) {
				// Mouse hover, add 2px blue border
				this.graphics.lineStyle(2,0x2c78bf,1);
			} else {
				this.graphics.lineStyle(1,0xb5b8ba,1);
			}
			// Fill first filling with grey border
			this.graphics.beginBitmapFill(backgroundAssetImageData);
			this.graphics.drawRoundRect(0,0,AssetPreview.assetWidth,AssetPreview.assetHeight,12);
			
			// Add Second inner white border
			this.graphics.lineStyle(1,0xFFFFFF,1);
			
			// Was the asset created by this user?
			if(_data.meta_username == Auth.getInstance().getUsername()) {
				// Yes, give it the normal background
				this.graphics.beginBitmapFill(backgroundAssetImageData);
			} else {
				// No, must be a shared asset
				this.graphics.beginFill(0xFFFFFF);
			}
			
			if(mouseOverToggle) {
				// Has to be 1px smaller, as blue border is twice as wide
				this.graphics.drawRoundRect(1,1,AssetPreview.assetWidth - 3,AssetPreview.assetHeight - 3,12);
			} else {
				this.graphics.drawRoundRect(1,1,AssetPreview.assetWidth - 2,AssetPreview.assetHeight - 2,12);
			}
			selected.x = AssetPreview.assetWidth - selected.width - 5;
			selected.y = AssetPreview.assetHeight - selected.height - 5;
		}
		
		// Force redraws the asset preview
		public function forceDraw():void {
			drawBackground();
			titleText.width = assetWidth-titleText.x;
			descriptionText.width = assetWidth-descriptionText.x;
			resizeText();
		}
		
		/**
		 * Drops letters in text based on resizing.
		 * 
		 * When asset tiles are resized, any text in either
		 * the title or description that cannot fit is dropped
		 * and '...' is added.
		 * 
		 */
		public function resizeText():void {
			titleText.text = _data.meta_title;
			descriptionText.text = _data.meta_description;
			var titleTextExtended:Boolean = false;
			var descriptionTextExtended:Boolean = false;
			if(titleText.width > 40) {
				while(titleText.textWidth > titleText.width-40) {
					titleText.text = titleText.text.substring(0,titleText.text.length-1);
					titleTextExtended = true;
				}
				while(descriptionText.textWidth > descriptionText.width-40) {
					descriptionText.text = descriptionText.text.substring(0,descriptionText.text.length-1);
					descriptionTextExtended = true;
				}
			} else {
				titleText.text = "";
				descriptionText.text = "";
			}
			// If the text was dropped, append '...'
			if(titleTextExtended) {
				titleText.appendText("...");
			}
			if(descriptionTextExtended) {
				descriptionText.appendText("...");
			}
			if(titleText.text.length < 4) {
				// Only 1 letter remaining, so lets just clear it.
				titleText.text = "";
				descriptionText.text = "";
			}
		}
		
		// Draws the icon for the asset
		private function addImageContainer():void {
			image = new Sprite();
			image.y = (AssetPreview.assetHeight - imageSize)/2;
			image.x = image.y;
			image.graphics.beginFill(0x000000,0.1);
			image.graphics.drawRect(0,0,imageSize,imageSize);
			addChild(image);
			
			selected.graphics.beginBitmapFill(assetSelectedImageData);
			selected.graphics.drawRect(0,0,29,29);
		}
		
		// Returns whether the asset is selected (for collections)
		public function isSelected():Boolean {
			return selectedSwitch;
		}
		
		// Redraws the text
		private function addTextFields():void {
			titleText = new TextField();
			titleText.text = "";
			
			// Setup X and Y Position
			titleText.x = image.x*1.5 + image.width;
			titleText.y = image.y+5;
			titleText.embedFonts = true;
			titleText.selectable = false;
			titleText.antiAliasType = AntiAliasType.ADVANCED;
			titleTextFormat = new TextFormat();
			titleTextFormat.font = "HelveticaBold";
			titleTextFormat.size = 16;
			titleText.setTextFormat(titleTextFormat);
			titleText.height = 30;
			addChild(titleText); 
			
			descriptionText = new TextField();
			descriptionText.text = "";
			descriptionText.x = titleText.x;
			descriptionText.y = image.height - image.y-5;
			descriptionText.embedFonts = true;
			descriptionText.selectable = false;
			descriptionText.antiAliasType = AntiAliasType.ADVANCED;
			descriptionTextFormat = new TextFormat();
			descriptionTextFormat.font = "Helvetica";
			descriptionTextFormat.size = 12;
			descriptionText.setTextFormat(descriptionTextFormat);
			descriptionText.height = 30;
			addChild(descriptionText);
		}
		
		// Button event
		override protected function mouseOver(e:MouseEvent):void {
			mouseOverToggle = true;
			drawBackground();
			refreshDisplay();
		}
		
		// Button event
		override protected function mouseOut(e:MouseEvent):void {
			mouseOverToggle = false;
			drawBackground();
			refreshDisplay();
			if(isEditing && !isSelected()) {
				this.alpha = 0.5;
			} else {
				this.alpha = 1;
			}
		}
		
		// Button event
		override protected function mouseDown(e:MouseEvent):void {
			this.alpha = 0.6;
		}
		
		// Button event
		override protected function mouseUp(e:MouseEvent):void {
			this.alpha = 1;
		}
		
		// Says whether a term matches this asset
		public function matchesString(term:String):Boolean {
			trace("MATCHES STRING MUST BE OVERWRITTEN");
			return false;
		}
	}
}