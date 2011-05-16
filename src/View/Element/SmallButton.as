package View.Element {
	import Controller.Utilities.AssetLookup;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class SmallButton extends RecensioUIComponent {
		
		[Embed(source="Assets/Template/commentmenu_bg.png")] 
		private var backgroundImage:Class;
		private var backgroundImageData:BitmapData;
		
		private var buttonText:TextField = new TextField();
		private var buttonTextFormat:TextFormat = new TextFormat();
		private var text:String = "";
		private var showAllBorders:Boolean = false;
		
		private var buttonIcon:Sprite; // the image for the button icon
		private var buttonIconSize:Number = 12; // default 10px overwritten in @see drawImage()
		
		private const PADDING:Number = 10; // 10px padding on small buttons
		
		public function SmallButton(_text:String, _showAllBorders:Boolean=false, hasButton:Boolean=false) {
			this.showAllBorders = _showAllBorders;
			//this.text = _text;
			super();
			backgroundImageData = (new backgroundImage as Bitmap).bitmapData;
			super.setButtonMode(true);
			this.mouseChildren = false;
			
			// Set the background and text formatting of the button
			setupButton();
			setText(_text);
		}
		
		// Gets the text of the button
		public function getText():String {
			return text;
		}
		
		// Craig Added
		public function getTextWidth():Number {
			return buttonText.textWidth;
		}
		
		// Sets the text of the button
		public function setText(newText:String):void {
			text = newText;
			buttonText.text = newText;
			buttonText.setTextFormat(buttonTextFormat);
			//this.width = buttonText.textWidth + PADDING*
		}
		
		// Sets up the background and text of the button
		private function setupButton():void {
			//buttonText.text = text;
			buttonText.embedFonts = true;
			buttonText.selectable = false;
			buttonTextFormat.font = "Helvetica";
			buttonTextFormat.size = 14;
			buttonText.height = 14;
			buttonTextFormat.align = TextFormatAlign.CENTER;
			buttonText.setTextFormat(buttonTextFormat);
			buttonText.defaultTextFormat = buttonTextFormat;
			buttonText.antiAliasType = AntiAliasType.ADVANCED;
			addChild(buttonText);
			textYOffset(2);
		}
		
		// Redraws the button (including mouse event effects)
		override protected function draw():void {
			this.graphics.clear();
			if(!showAllBorders) {
				this.graphics.beginBitmapFill(backgroundImageData);
				this.graphics.drawRect(0,0,this.width,this.height);
				this.graphics.lineStyle(1,0xc4c4c4);
				this.graphics.moveTo(0,0);
				this.graphics.lineTo(0,this.height);
				this.graphics.moveTo(this.width,0);
				this.graphics.lineTo(this.width,this.height);
			} else {
				this.graphics.lineStyle(1,0xc4c4c4);
				this.graphics.beginBitmapFill(backgroundImageData);
				this.graphics.drawRect(0,0,this.width,this.height);
			}
			this.graphics.lineStyle(0,0xc4c4c4);
			buttonText.width = this.width;	
			
			// If button text isnt blank (as it is when first drawn),
			// add image.
			if(getText() != "") {
				
				drawImage();
			}
		}
		
		// Button event
		override protected function mouseOver(e:MouseEvent):void {
			e.stopImmediatePropagation();
			buttonTextFormat.color = 0x336699;
			buttonText.setTextFormat(buttonTextFormat);
		}
		
		// Button event
		override protected function mouseOut(e:MouseEvent):void {
			e.stopImmediatePropagation();
			buttonTextFormat.color = 0x333333;
			buttonText.setTextFormat(buttonTextFormat);
		}
		
		// Button event
		override protected function mouseDown(e:MouseEvent):void {
			e.stopImmediatePropagation();
			this.alpha = 0.8;
		}
		
		// Button event
		override protected function mouseUp(e:MouseEvent):void {
			e.stopImmediatePropagation();
			this.alpha = 1;
		}
		
		// Moves the text higher and lower than default on the button
		public function textYOffset(newYOffset:Number):void {
			buttonText.y = newYOffset;
		}
		
		/**
		 * Draws the image for the button type
		 *  
		 * @see	AssetLookup.getButtonImage()
		 */		
		private function drawImage():void {
			// Remove current button icon if it exists
			if(buttonIcon && this.contains(buttonIcon)) { 
				removeChild(buttonIcon); 
			}
			
			// Set up the assets image
			var icon:BitmapData = AssetLookup.getButtonImage(getText()); // chooses the image based on button label
			if(icon != null) {
				// Create new one
				buttonIcon = new Sprite();
				buttonIcon.y = (this.height - buttonIconSize)/2;
				buttonIcon.x = 10;
				
				buttonIcon.graphics.beginBitmapFill(icon);
				buttonIcon.graphics.drawRect(0,0,buttonIconSize,buttonIconSize);
				addChild(buttonIcon);
				
				// Move the text over
				var buttonWidthPlusPadding:Number = buttonIcon.x  + buttonIconSize;
				buttonText.width = this.width - buttonWidthPlusPadding;	
				buttonText.x = buttonWidthPlusPadding;
			}
		}
	}
}