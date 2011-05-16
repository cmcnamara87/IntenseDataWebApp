package Module.ImageViewer {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	
	public class NewImageAnnotation extends UIComponent {
		
		private var textInput:TextInput = new TextInput();
		private var textInputPadding:Number = 8;
		private var addAnnotationButton:Sprite = new Sprite();
		private var addAnnotationTextField:TextField = new TextField();
		private var addAnnotationTextFieldFormat:TextFormat = new TextFormat();
		public var annotationWidth:Number = 20;
		public var annotationHeight:Number = 20;
		
		public function NewImageAnnotation(annWidth:Number,annHeight:Number) {
			annotationWidth = annWidth;
			annotationHeight = annHeight;
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			super();
		}
		
		// Draws a new annotation interface
		private function init(e:Event):void {
			this.graphics.clear();
			this.graphics.lineStyle(1,0xFFFFFF,1);
			this.graphics.beginFill(0xFF0000,0.8);
			this.graphics.drawRect(0-annotationWidth/2,0-annotationHeight/2,annotationWidth,annotationHeight);
			this.graphics.lineStyle(0,0xFFFFFF,0);
			this.graphics.beginFill(0x000000,1);
			this.graphics.drawRoundRect(-200,-140,400,100,8);
			this.graphics.moveTo(-10,-40);
			this.graphics.lineTo(0,-20);
			this.graphics.lineTo(10,-40);
			textInput.text = "";
			textInput.width = 400-textInputPadding*2;
			textInput.x = -200+textInputPadding;
			textInput.y = -140+textInputPadding;
			textInput.height = 50;
			textInput.setStyle("focusAlpha",0);
			textInput.setStyle("contentBackgroundColor",0xBBBBBB);
			textInput.setStyle("fontSize","18");
			textInput.setStyle("font","Helvetica");
			addChild(textInput);
			this.stage.focus = textInput;
			
			addAnnotationTextField.text = "Add Annotation";
			addAnnotationTextField.embedFonts = true;
			addAnnotationTextField.selectable = false;
			addAnnotationTextField.antiAliasType = AntiAliasType.ADVANCED;
			addAnnotationTextFieldFormat.color = 0xFFFFFF;
			addAnnotationTextFieldFormat.size = 16;
			addAnnotationTextFieldFormat.align = TextFormatAlign.CENTER;
			addAnnotationTextFieldFormat.font = "HelveticaBold";
			addAnnotationTextField.setTextFormat(addAnnotationTextFieldFormat);
			addAnnotationTextField.defaultTextFormat = addAnnotationTextFieldFormat;
			addAnnotationTextField.mouseEnabled = false;
			addAnnotationButton.graphics.beginFill(0x000000,1);
			addAnnotationButton.graphics.drawRect(-200,-70,400,30);
			addAnnotationTextField.width = 400;
			addAnnotationTextField.height = 30;
			addAnnotationTextField.x = -200;
			addAnnotationTextField.y = -75;
			addAnnotationButton.addEventListener(MouseEvent.MOUSE_UP,addAnnotation);
			addChild(addAnnotationButton);
			addAnnotationButton.addChild(addAnnotationTextField);
			
		}
		
		// Dispatches an even to ImageView
		private function addAnnotation(e:Event):void {
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		// Returns the text of an annotation
		public function getText():String {
			return textInput.text;
		}
	}
}