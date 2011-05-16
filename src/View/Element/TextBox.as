package View.Element {
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class TextBox extends RecensioUIComponent {
		
		private var defaultText:String = "";
		private var isPassword:Boolean = false;
		private var textField:TextField = new TextField();
		private var textFormat:TextFormat = new TextFormat();
		private var padding:Number = 5;
		
		public function TextBox() {
			setupTextField();
			this.addEventListener(MouseEvent.CLICK,focusIn);
			this.textField.addEventListener(FocusEvent.FOCUS_OUT,focusOut);
			super();
		}
		
		// Whether the text in the textbox shows like a password
		public function showAsPassword(isPassword:Boolean):void {
			this.isPassword = isPassword;
		}
		
		// When the textbox receives focus
		private function focusIn(e:MouseEvent):void {
			setTextFocus();
		}
		
		// When the textbox looses focus
		private function focusOut(e:FocusEvent):void {
			if(textField.text == "") {
				textField.text = defaultText;
				if(isPassword) {
					textField.displayAsPassword = false;
				}
			}
		}
		
		// Redraws the text box
		override protected function draw():void {
			drawBackground();
			repositionTextField();
		}
		
		// Sets up the text area
		private function setupTextField():void {
			this.addChild(textField);
			textFormat.size = 36;
			textFormat.font = "Helvetica";
			textField.embedFonts = true;
			textField.selectable = true;
			textFormat.color = 0x999999;
			textField.type = TextFieldType.INPUT;
			textField.setTextFormat(textFormat);
			textField.defaultTextFormat = textFormat;
		}
		
		// Repositions the text area (after redraw/reposition)
		private function repositionTextField():void {
			textField.width = this.width-padding*2;
			textField.height = this.height-padding*2;
			textField.x = padding;
			textField.y = padding/2;
		}
		
		// Redraws the background
		private function drawBackground():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.lineStyle(1,0xd3d5d6);
			this.graphics.drawRect(0,0,this.width,this.height);
			this.graphics.lineStyle(1,0x6d6f70);
			this.graphics.moveTo(0,0);
			this.graphics.lineTo(this.width,0);
		}
		
		// Sets the default text of the box
		public function setDefaultText(newText:String):void {
			defaultText = newText;
			textField.text = defaultText;
		}
		
		// Gets the text
		public function getText():String {
			return textField.text;
		}
		
		// Sets the focus of the text to the box
		public function setTextFocus():void {
			this.stage.focus = textField;
			if(textField.text == defaultText) {
				textField.text = "";
				if(isPassword) {
					textField.displayAsPassword = true;
				}
			}
		}
	}
}