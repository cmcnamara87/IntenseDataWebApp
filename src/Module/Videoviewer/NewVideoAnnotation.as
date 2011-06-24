package Module.Videoviewer {
	
	import Controller.IDEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	
	import spark.components.Button;
	
	public class NewVideoAnnotation extends UIComponent {
		
		private var textInput:TextInput = new TextInput();
		private var textInputPadding:Number = 8;
		private var addAnnotationButton:Sprite = new Sprite();
		private var addAnnotationTextField:TextField = new TextField();
		private var addAnnotationTextFieldFormat:TextFormat = new TextFormat();
		
		private var startingX:Number = 0; // The X Coordinate where the annotation was started to be drawn from
		private var startingY:Number = 0; // // The Y Coordinate where the annotation was started to be drawn from
		private var finishingX:Number = 0; // The X Coordinate where the annotation drawing ended.
		private var finishingY:Number = 0; // The X Coordinate where the annotation drawing ended.
		
		// Width/Height of annotation
		
		public function NewVideoAnnotation(_startingX:Number, _startingY:Number, _finishingX:Number, _finishingY:Number) {
			
			// Save the starting/finishing x,y coordinates for the annotation.
			this.startingX = _startingX;
			this.startingY = _startingY;
			this.finishingX = _finishingX;
			this.finishingY = _finishingY;
			
			// Calculate this annotations x,y centre point
			// The position should be in the center of the annotation...
			this.x = (startingX + finishingX)/2;
			this.y = (startingY + finishingY)/2;

			this.addEventListener(Event.ADDED_TO_STAGE,init);
			super();
		}
		
		private function init(e:Event):void {
			
			this.graphics.clear();
			//NOTE TO CRAIG, this is not your code, you just commented it.
			
			// Draw Annotation Box
			this.graphics.lineStyle(1,0xFFFFFF,0.8);
			this.graphics.beginFill(0xFF0000,0.2);
			this.graphics.drawRect(0 - getWidth()/2, 0 - getHeight()/2, getWidth(), getHeight());
			
			
			// Draw Annotation Entry Area
			this.graphics.lineStyle(0,0xFFFFFF,0);
			this.graphics.beginFill(0x000000,1);
			this.graphics.drawRoundRect(-200,-140,400,100,8);
//			this.graphics.moveTo(-10,-40);
//			this.graphics.lineTo(0,-20);
//			this.graphics.lineTo(10,-40);
			
			// Set annotation input text box
			textInput.text = "";
			textInput.width = 400-textInputPadding*2;
			//textInput.percentWidth = 100;
			textInput.x = -200+textInputPadding;
			textInput.y = -140+textInputPadding;
			textInput.height = 50;
			textInput.setStyle("focusAlpha",0);
			textInput.setStyle("contentBackgroundColor",0xBBBBBB);
			textInput.setStyle("fontSize","18");
			textInput.setStyle("font","Helvetica");
			addChild(textInput);
			this.stage.focus = textInput;
			
			// Set annotation label says 'Add Annotation'
			
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
			
			/*addAnnotationButton.graphics.beginFill(0x000000,1);
			addAnnotationButton.graphics.drawRect(-200,-70,400,30);
			addAnnotationTextField.width = 400;
			addAnnotationTextField.height = 30;
			addAnnotationTextField.x = -200;
			addAnnotationTextField.y = -75;
			addAnnotationButton.addChild(addAnnotationTextField);*/
			
			
			// Create the Set Start time position of the annotation button
			var setStart:Button = new Button();
			setStart.label = "1. Set Start";
			setStart.width = 100;
			setStart.height = 30;
			setStart.x = -190;
			setStart.y = -75;
			addChild(setStart);
			
			// Create the set end position
			var setEnd:Button = new Button();
			setEnd.label = "2. Set End";
			setEnd.width = 80;
			setEnd.height = 30;
			setEnd.x = -80;
			setEnd.y = -75;
			addChild(setEnd);
			
			// Create the Save Annotation button
			var addAnnotationButton:Button = new Button();
			addAnnotationButton.label = '3. Save Annotation';
			addAnnotationButton.width = 180;
			addAnnotationButton.height = 30;
			addAnnotationButton.x = 10;
			addAnnotationButton.y = -75;
			addAnnotationButton.addEventListener(MouseEvent.MOUSE_UP,addAnnotation);
			addChild(addAnnotationButton);
			
			
			/* Setup Event Listeners */
			setStart.addEventListener(MouseEvent.CLICK, setStartClicked);
			setEnd.addEventListener(MouseEvent.CLICK, setEndClicked);
		
		}
		
		public function getWidth():Number {
			return Math.abs(finishingX - startingX);
		}
		
		public function getHeight():Number {
			return Math.abs(finishingY - startingY);
		}
		
		/* ========= EVENT LISTENER FUNCTIONS ============= */
		/**
		 * The Set start button was clicked. Tells the VideoView the button was clicked.
		 * Caught by @see setAnnotationStart in Videoview
		 * 
		 */		
		private function setStartClicked(e:MouseEvent):void {
			trace("set Start was clicked");
			var event:IDEvent = new IDEvent(IDEvent.ANNOTATION_START_SET);
			dispatchEvent(event);
		}
		
		/**
		 * The Set end button was clicked. Tells the VideoView the button was clicked.
		 * Caught by @see setAnnotationEnd in Videoview
		 * 
		 */		
		private function setEndClicked(e:MouseEvent):void {
			trace("set end was clicked");
			var event:IDEvent = new IDEvent(IDEvent.ANNOTATION_END_SET);
			dispatchEvent(event);
			
		}
		
		
		// Dispatches an even to ImageView
		private function addAnnotation(e:Event):void {
			trace('you clicked me');
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		// Returns the text of an annotation
		public function getText():String {
			return textInput.text;
		}
	}
}