package View.Element {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class NavigationBarButton extends RecensioUIComponent {
		
		private var textField:TextField = new TextField();
		private var textFieldFormat:TextFormat = new TextFormat();
		private var padding:Number = 20;
		public var buttonWidth:Number = 0;
		private var background:Sprite = new Sprite();
		private var backgroundMask:Sprite = new Sprite();
		private var roundCorners:Boolean = false;
		private var side:String = "left";
		private var selected:Boolean = false;
		
		[Embed(source="Assets/Template/navbutton_bg.png")] 
		private var backgroundImage:Class;
		private var backgroundImageData:BitmapData;
		
		[Embed(source="Assets/Template/navbutton_selected_bg.png")] 
		private var backgroundSelectedImage:Class;
		private var backgroundSelectedImageData:BitmapData;
		private var _colour:String = "";
		
		public function NavigationBarButton(buttonName:String,side:String,roundCorners:Boolean=false) {
			this.roundCorners = roundCorners;
			this.side = side;
			super();
			backgroundImageData = (new backgroundImage as Bitmap).bitmapData;
			backgroundSelectedImageData = (new backgroundSelectedImage as Bitmap).bitmapData;
			addChild(background);
			if(roundCorners) {
				addChild(backgroundMask);
				background.mask = backgroundMask;
			}
			super.setButtonMode(true);
			setupButtonText(buttonName);
			setupTooltip(buttonName);
		}
		
		private function setupTooltip(buttonName:String):void {
			switch(buttonName) {
				case 'my media':
					this.toolTip = "View all media items created by me";
					break;
				case 'shared':
					this.toolTip = "View media that others have shared with me";
					break;
				case 'my collections':
					this.toolTip = "View all media collections created by me";
					break;
				case 'my media':
					this.toolTip = "Go back to the media browser";
					break;
				case 'delete':
					this.toolTip = "Delete this asset permantently";
					break;
				case 'edit':
					this.toolTip = "View and change information about this media";
					break;
				case 'share':
					this.toolTip = "View and change who has access to this media";
					break;
				case 'comments':
					this.toolTip = "View or hide comments about this media";
					break;
				//case '
			}
		}
		
		// Set the text for the navigation button
		public function setButtonName(newName:String):void {
			textField.text = newName;
			draw();
		}
		
		// Gets the text for the navigation button
		public function getText():String {
			return textField.text;
		}
		
		// Sets the background colour of the navigation button
		public function setColour(colour:String):void {
			_colour = colour;
			draw();
		}
		
		// Initial setup of the button text
		private function setupButtonText(buttonName:String):void {
			textField.text = buttonName;
			this.mouseChildren = false;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.embedFonts = true;
			textFieldFormat.font = "HelveticaBold";
			textFieldFormat.size = 16;
			textFieldFormat.align = TextFormatAlign.CENTER;
			textField.selectable = false;
			textField.x = padding-2;
			textField.y = 9;
			addChild(textField);
		}
		
		// Redraws the button (including mouse event effects)
		override protected function draw():void {
			if(_colour == "") {
				if(selected) {
					textFieldFormat.color = 0xFFFFFF;
				}
			} else {
				if(_colour == "yellow") {
					textFieldFormat.color = 0x000000;
				}
				if(_colour == "green") {
					textFieldFormat.color = 0xFFFFFF;
					if(selected) {
						textFieldFormat.color = 0xFFFFFF;
					}
				}
			}
			textField.setTextFormat(textFieldFormat);
			drawBackground();
		}
		
		// Redraws the button background (including colour) 
		private function drawBackground():void {
			buttonWidth = textField.width+padding*2;
			background.graphics.clear();
			if(_colour == "") {
				if(!selected) {
					background.graphics.beginBitmapFill(backgroundImageData);
				} else {
					background.graphics.beginBitmapFill(backgroundSelectedImageData);
				}
			} else {
				if(_colour == "yellow") {
					background.graphics.beginFill(0xFFFF00);
				}
				if(_colour == "green") {
					if(!selected) {
						background.graphics.beginFill(0x5ab65a);
					}
				}
			}
			textField.width = textField.textWidth+5;
			try {
				textField.height = this.parent.height;
			} catch (e:Error) {}
			background.graphics.lineStyle(0,0x000000,0);
			background.graphics.drawRect(0,1,buttonWidth,this.parent.height-1);
			background.graphics.lineStyle(1,0xb9b9bb);
			if(side == 'left') {
				background.graphics.moveTo(buttonWidth-1,1);
				background.graphics.lineTo(buttonWidth-1,this.parent.height);
			} else if (side == 'right') {
				background.graphics.moveTo(0,1);
				background.graphics.lineTo(0,this.parent.height);
			}
			if(roundCorners) {
				if (side == 'left') {
					backgroundMask.graphics.clear();
					backgroundMask.graphics.beginFill(0xFF0000,1);
					backgroundMask.graphics.drawRoundRect(1,1,buttonWidth+12,this.parent.height-1,12);
				} else if (side == 'right') {
					backgroundMask.graphics.clear();
					backgroundMask.graphics.beginFill(0xFF0000,1);
					backgroundMask.graphics.drawRoundRect(1-12,1,buttonWidth+12,this.parent.height-1,20);
				}
			}
		}
		
		// Button event
		override protected function mouseOver(e:MouseEvent):void {
			if(_colour == "") {
				if(!selected) {
					textFieldFormat.color = 0x336699;
					textField.setTextFormat(textFieldFormat);
				}
			} else {
				if(!selected && _colour == "green") {
					textFieldFormat.color = 0xbcffbc;
					textField.setTextFormat(textFieldFormat);
				}
			}
		}
		
		// Button event
		override protected function mouseOut(e:MouseEvent):void {
			if(_colour == "") {
				if(!selected) {
					textFieldFormat.color = 0x333333;
					textField.setTextFormat(textFieldFormat);
				}
			} else {
				if(!selected && _colour == "green") {
					textFieldFormat.color = 0xFFFFFF;
					textField.setTextFormat(textFieldFormat);
				}
			}
		}
		
		// Button event
		override protected function mouseDown(e:MouseEvent):void {
			if(!selected) {
				this.alpha = 0.8;
			}
		}
		
		// Button event
		override protected function mouseUp(e:MouseEvent):void {
			this.alpha = 1;
		}
		
		// Deselects the button
		public function deselect():void {
			selected = false;
			textFieldFormat.color = 0x333333;
			draw();
		}
		
		// Selects the button
		public function select():void {
			selected = true;
			draw();
		}
	}
}