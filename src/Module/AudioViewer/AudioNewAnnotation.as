package Module.AudioViewer
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.UIComponent;

	public class AudioNewAnnotation extends UIComponent {
		
		private var _leftPosition:Number;
		private var _rightPosition:Number;
		private var _arrow:Sprite = new Sprite();
		private var _annotationBox:Sprite = new Sprite();
		private var _annotationText:TextField = new TextField();
		private var _annotationTextFormat:TextFormat = new TextFormat();
		private var _annotationButton:Sprite = new Sprite();
		private var _annotationButtonText:TextField = new TextField();
		private var _viewer:AudioView;
		
		private var _leftPercentage:Number;
		private var _rightPercentage:Number;
		
		public function AudioNewAnnotation(viewer:AudioView,firstPercentage:Number,lastPercentage:Number,firstpos:Number,lastpos:Number,middleY:Number,distance:Number) {
			_viewer = viewer;
			if(firstpos > lastpos) {
				_leftPosition = lastpos;
				_rightPosition = firstpos;
				_leftPercentage = lastPercentage;
				_rightPercentage = firstPercentage;
			} else {
				_leftPosition = firstpos;
				_rightPosition = lastpos;
				_leftPercentage = firstPercentage;
				_rightPercentage = lastPercentage;
			}
			if(distance < 30) {
				_arrow.alpha = 0;
			}
			_arrow.y = middleY;
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(e:Event):void {
			drawGraphics();
			this.addEventListener(MouseEvent.MOUSE_DOWN,stopEvent);
			_annotationButton.addEventListener(MouseEvent.MOUSE_UP,buttonUp);
		}
		
		private function stopEvent(e:MouseEvent):void {
			if(e.target != _annotationText) {
				e.stopPropagation();
			}
		}
		
		private function buttonUp(e:MouseEvent):void {
			_viewer.saveAnnotation(_leftPercentage,_rightPercentage,_annotationText.text);
		}
		
		private function drawGraphics():void {
			_arrow.graphics.beginFill(0x000000,0.8);
			_arrow.graphics.moveTo(_leftPosition,0);
			_arrow.graphics.lineTo(_leftPosition+10,10);
			_arrow.graphics.lineTo(_leftPosition+10,5);
			_arrow.graphics.lineTo(_rightPosition-10,5);
			_arrow.graphics.lineTo(_rightPosition-10,10);
			_arrow.graphics.lineTo(_rightPosition,0);
			_arrow.graphics.lineTo(_rightPosition-10,-10);
			_arrow.graphics.lineTo(_rightPosition-10,-5);
			_arrow.graphics.lineTo(_leftPosition+10,-5);
			_arrow.graphics.lineTo(_leftPosition+10,-10);
			this.addChild(_arrow);
			_annotationBox.graphics.beginFill(0x000000,0.8);
			var middle:Number = (_rightPosition-_leftPosition)/2+_leftPosition;
			_annotationBox.graphics.drawRoundRect(middle-100,-170,200,140,10);
			_annotationBox.graphics.moveTo(middle-10,-30);
			_annotationBox.graphics.lineTo(middle,-10);
			_annotationBox.graphics.lineTo(middle+10,-30);
			_annotationBox.graphics.beginFill(0xCCCCCC,0.8);
			_annotationBox.graphics.drawRect(middle-95,-165,190,100);
			_annotationBox.y = _arrow.y;
			this.addChild(_annotationBox);
			drawTextBox(middle-95,-165);
			drawButton(middle-95,-60);
		}
		
		private function drawTextBox(xPos:Number,yPos:Number):void {
			_annotationText.x = xPos;
			_annotationText.y = yPos;
			_annotationText.mouseEnabled = false;
			_annotationText.width = 190;
			_annotationText.height = 100;
			_annotationText.backgroundColor = 0xFF0000;
			_annotationText.text = "";
			_annotationText.type = TextFieldType.INPUT;
			_annotationText.addEventListener(Event.CHANGE,setFormat);
			_annotationText.multiline = true;
			_annotationTextFormat.font = "Arial";
			_annotationTextFormat.color = 0x000000;
			_annotationTextFormat.size = 14;
			_annotationText.setTextFormat(_annotationTextFormat);
			_annotationBox.addChild(_annotationText);
			this.stage.focus = _annotationText;
		}
		
		private function setFormat(e:Event):void {
			_annotationTextFormat.color = 0x000000;
			_annotationTextFormat.bold = false;
			_annotationTextFormat.align = TextFormatAlign.LEFT;
			_annotationText.setTextFormat(_annotationTextFormat);
			e.stopImmediatePropagation();
		}
	
		private function drawButton(xPos:Number,yPos:Number):void {
			_annotationButton.x = xPos;
			_annotationButton.y = yPos;
			_annotationButton.graphics.beginFill(0x000000,1);
			_annotationButton.graphics.drawRect(0,0,190,25);
			_annotationBox.addChild(_annotationButton);
			_annotationButtonText.text = "Add Annotation";
			_annotationButtonText.width = 190;
			_annotationButtonText.height = 30;
			_annotationButtonText.y = 3;
			_annotationButtonText.selectable = false;
			_annotationTextFormat.bold = true;
			_annotationTextFormat.color = 0xFFFFFF;
			_annotationTextFormat.align = TextFormatAlign.CENTER;
			_annotationButtonText.setTextFormat(_annotationTextFormat);
			_annotationButton.addChild(_annotationButtonText);
		}
	}
}