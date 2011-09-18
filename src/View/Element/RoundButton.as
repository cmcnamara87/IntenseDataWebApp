package View.Element {
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	
	public class RoundButton extends RecensioUIComponent {
		
		[Embed(source="Assets/Template/button_bg.png")] 
		private var backgroundImage:Class;
		private var backgroundImageData:BitmapData;
		
		public var text:String = "";
		private var buttonTextField:TextField = new TextField();
		private var buttonTextFormat:TextFormat = new TextFormat();
		private var padding:Number = 30;
		
		private var buttonIcon:Sprite; // the image for the button icon
		private var buttonIconSize:Number = 15; // default 10px overwritten in @see drawImage()
		
		public function RoundButton() {
			super();
			backgroundImageData = (new backgroundImage as Bitmap).bitmapData;
			super.setButtonMode(true);
			setupTextField();
		}
		
		/**
		 * Redraws the button
		 * Note: 0,0 point is in the middle of the button.
		 */		
		override protected function draw():void {
			drawBackground();
			buttonTextField.x = 0-this.width/2;
			buttonTextField.y = 0-9;
			buttonTextField.backgroundColor = 0xFF0000;
			buttonTextField.width = this.width;
			buttonTextField.height = this.height;
			buttonTextField.text = text;
			
			drawImage();
		}
		
		// Sets up the text of the button
		private function setupTextField():void {
			addChild(buttonTextField);
			buttonTextFormat.align = TextFormatAlign.CENTER;
			buttonTextFormat.font = "Helvetica";
			buttonTextFormat.color = 0x333333;
			buttonTextField.selectable = false;
			buttonTextField.mouseEnabled = false;
			buttonTextFormat.size = 14;
			buttonTextFormat.bold = true;
			buttonTextField.defaultTextFormat = buttonTextFormat;
			buttonTextField.embedFonts = true;
			buttonTextField.antiAliasType = AntiAliasType.ADVANCED;
		}
		
		// Button event
		override protected function mouseOver(e:MouseEvent):void {
			buttonTextFormat.color = 0x336699;
			buttonTextField.setTextFormat(buttonTextFormat);
		}
		
		// Button event
		override protected function mouseOut(e:MouseEvent):void {
			buttonTextFormat.color = 0x333333;
			buttonTextField.setTextFormat(buttonTextFormat);
		}
		
		// Button event
		override protected function mouseDown(e:MouseEvent):void {
			this.alpha = 0.8;
		}
		
		// Button event
		override protected function mouseUp(e:MouseEvent):void {
			this.alpha = 1;
		}
		
		public function setText(newText:String,capitalise:Boolean=false):void {
			text = newText.substr(0,1).toUpperCase()+newText.substr(1);
			this.width = buttonTextField.textWidth+padding*2;
			draw();
		}
		
		// Draws the background of the button
		private function drawBackground():void {
			this.graphics.clear();
			this.graphics.beginBitmapFill(backgroundImageData,new Matrix(1,0,0,1,0,0-this.height/2));
			this.graphics.lineStyle(1,0xb9b9bb);
			this.graphics.drawRoundRect(0-this.width/2,0-this.height/2,this.width,this.height,12);
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
			var icon:BitmapData;
			if(text.toLocaleLowerCase() == Auth.getInstance().getUsername().toLocaleLowerCase()) {
				
				icon = AssetLookup.getButtonImage('profile'); // chooses the image based on button label
			}
			
//			if(icon != null) {
//				// Create new one
//				var buttonIconPadding:Number = 10;
//
//				buttonIcon = new Sprite();
//				//buttonIcon.y = (this.height - buttonIconSize)/2;
//				buttonIcon.x = 0 - (this.width/2) + buttonIconPadding;
//				buttonIcon.y = 0 - (buttonIconSize/2);
//				//buttonIcon.x = 10;
//				
//				buttonIcon.graphics.beginBitmapFill(icon);
//				buttonIcon.graphics.drawRect(0,0,buttonIconSize,buttonIconSize);
//				this.addChild(buttonIcon);
//				
//				// Move the text over
//				var buttonWidthPlusPadding:Number = buttonIconPadding + buttonIconSize; // no padding on the right, since text is centered
//				buttonTextField.x = 0-this.width/2 + buttonWidthPlusPadding;
//				buttonTextField.width = this.width - buttonWidthPlusPadding;
//			}
		}
	}
}