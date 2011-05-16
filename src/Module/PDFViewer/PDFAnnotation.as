package Module.PDFViewer {
	
	import Lib.it.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.controls.Button;
	
	public class PDFAnnotation extends Sprite {
		
		[Embed(source="Assets/Module/annotation_large.png")]
        public var Annotation_icon:Class;
		
		private var annotationBackground:Sprite = new Sprite();
		private var annotationContent:Sprite = new Sprite();
		private var annotationWidth:Number = 255;
		private var annotationHeight:Number = 30;
		private var fullAnnotationHeight:Number = 150;
		private var annotationPadding:Number = 5;
		private var annotationArrowSize:Number = 15;
		public var isCreated:Boolean = false;
		private var addAnnotationButton:Sprite = new Sprite();
		private var copyTextButton:Sprite = new Sprite();
		private var createAnnotationButton:Sprite = new Sprite();
		private var buttonTextFormat:TextFormat = new TextFormat();
		private var annotationTextArea:TextField = new TextField();
		private var annotationTextFormat:TextFormat = new TextFormat();
		private var thePDF:PDF;
		private var startPos:Number;
		private var stopPos:Number;
		private var myRealX:Number;
		private var myRealY:Number;
		
		public var previousComment:Boolean = false;
		
		private var myIcon:DisplayObject;
		
		public function PDFAnnotation(thePDF:PDF,pointOnDocument:Point,startPos:Number,stopPos:Number,myRealX:Number,myRealY:Number) {
			this.myRealX = myRealX;
			this.myRealY = myRealY;
			this.startPos = startPos;
			this.stopPos = stopPos;
			this.thePDF = thePDF;
			createBackground();
			createButtons();
			this.alpha = 0;
			this.scaleY = 0.1;
			Tweener.addTween(this,{'alpha':1,'scaleY':1,'time':0.5});
			this.addEventListener(KeyboardEvent.KEY_UP,resetFormat);
		}
		
		public function getExportData():Object {
			var exportObject:Object = new Object();
			exportObject.text = annotationTextArea.text;
			exportObject.xPos = myRealX;
			exportObject.yPos = myRealY;
			exportObject.startTextPos = startPos;
			exportObject.stopTextPos = stopPos;
			return exportObject;
		}
		
		public function checkCreation():Boolean {
			return isCreated;
		}
		
		private function createBackground():void {
			annotationBackground.graphics.beginFill(0x333333,0.9);
			annotationBackground.graphics.drawRoundRect(annotationWidth/-2,annotationHeight*-1-annotationArrowSize,annotationWidth,annotationHeight,10);
			annotationBackground.graphics.moveTo(0-annotationArrowSize/1.5,0-annotationArrowSize);
			annotationBackground.graphics.lineTo(0,0);
			annotationBackground.graphics.lineTo(0+annotationArrowSize/1.5,0-annotationArrowSize);
			annotationContent.addChild(annotationBackground);
			var myButton:Button = new Button();
			addChild(annotationContent);
		}
		
		private function createButtons():void {
			buttonTextFormat.font = "Arial";
			buttonTextFormat.size = 14;
			buttonTextFormat.color = 0xFFFFFF;
			buttonTextFormat.bold = true;
			buttonTextFormat.align = TextFormatAlign.CENTER;
			
			var addAnnotationText:TextField = new TextField();
			addAnnotationText.text = "Add Annotation";
			addAnnotationText.setTextFormat(buttonTextFormat);
			addAnnotationText.width = 120;
			addAnnotationText.height = 20;
			addAnnotationText.selectable = false;
			addAnnotationText.mouseEnabled = false;
			addAnnotationButton.graphics.beginFill(0x111111);
			addAnnotationButton.graphics.drawRoundRect(0,0,120,20,5);
			addAnnotationButton.addChild(addAnnotationText);
			annotationContent.addChild(addAnnotationButton);
			addAnnotationButton.x = annotationWidth/-2+annotationPadding;
			addAnnotationButton.y = annotationHeight*-1-annotationArrowSize+annotationPadding;
			addAnnotationButton.addEventListener(MouseEvent.CLICK,addAnnotation);
			
			var copyTextText:TextField = new TextField();
			copyTextText.text = "Copy Text";
			copyTextText.setTextFormat(buttonTextFormat);
			copyTextText.width = 120;
			copyTextText.height = 20;
			copyTextText.selectable = false;
			copyTextText.mouseEnabled = false;
			copyTextButton.graphics.beginFill(0x111111);
			copyTextButton.graphics.drawRoundRect(0,0,120,20,5);
			copyTextButton.addChild(copyTextText);
			annotationContent.addChild(copyTextButton);
			copyTextButton.x = annotationWidth/-2+annotationPadding*2+addAnnotationButton.width;
			copyTextButton.y = annotationHeight*-1-annotationArrowSize+annotationPadding;
			copyTextButton.addEventListener(MouseEvent.CLICK,copyText);
		}
		
		private function addAnnotation(e:MouseEvent):void {
			annotationBackground.graphics.clear();
			annotationBackground.graphics.beginFill(0x333333,0.9);
			annotationBackground.graphics.drawRoundRect(annotationWidth/-2,fullAnnotationHeight*-1-annotationArrowSize,annotationWidth,fullAnnotationHeight,10);
			annotationBackground.graphics.moveTo(0-annotationArrowSize/1.5,0-annotationArrowSize);
			annotationBackground.graphics.lineTo(0,0);
			annotationBackground.graphics.lineTo(0+annotationArrowSize/1.5,0-annotationArrowSize);
			if(annotationContent.contains(copyTextButton)) {
				annotationContent.removeChild(copyTextButton);
				annotationContent.removeChild(addAnnotationButton);
			}
			addAnnotationTextArea();
			addCreateAnnotationButton();
		}
		
		private function addAnnotationTextArea():void {
			annotationTextFormat = new TextFormat();
			annotationTextFormat.font = "Arial";
			annotationTextFormat.size = 16;
			annotationTextFormat.color = 0x333333;
			annotationTextArea.width = annotationWidth - annotationPadding*2;
			annotationTextArea.height = fullAnnotationHeight - 20 - annotationPadding*3;
			annotationTextArea.border = true;
			annotationTextArea.backgroundColor = 0xEEEEEE;
			annotationTextArea.background = true;
			annotationTextArea.x = annotationWidth/-2+annotationPadding;
			annotationTextArea.y = fullAnnotationHeight*-1-annotationArrowSize+annotationPadding;
			annotationTextArea.selectable = true;
			annotationTextArea.maxChars = 140;
			annotationTextArea.type = TextFieldType.INPUT;
			annotationTextArea.wordWrap = true;
			annotationTextArea.multiline = true;
			annotationTextArea.addEventListener(Event.CHANGE,stopPropagation);
			annotationContent.addChild(annotationTextArea);
			annotationTextArea.setTextFormat(annotationTextFormat);
			try {
				annotationTextArea.stage.focus = annotationTextArea;	
			} catch (e:Error) {}
			annotationTextArea.setTextFormat(annotationTextFormat); 
		}
		
		private function stopPropagation(e:Event):void {
			e.stopImmediatePropagation();
		}
		
		private function addCreateAnnotationButton():void {
			var createAnnotationText:TextField = new TextField();
			createAnnotationText.text = "Save Annotation";
			createAnnotationText.setTextFormat(buttonTextFormat);
			createAnnotationText.width = 120;
			createAnnotationText.height = 20;
			createAnnotationText.selectable = false;
			createAnnotationText.mouseEnabled = false;
			createAnnotationButton.graphics.beginFill(0x111111);
			createAnnotationButton.graphics.drawRoundRect(0,0,120,20,5);
			createAnnotationButton.addChild(createAnnotationText);
			annotationContent.addChild(createAnnotationButton);
			createAnnotationButton.x = annotationWidth/-2+annotationPadding*2+addAnnotationButton.width;
			createAnnotationButton.y = annotationHeight*-1-annotationArrowSize+annotationPadding;
			createAnnotationButton.addEventListener(MouseEvent.CLICK,saveAnnotation);
		}
		
		private function addIcon():void {
			myIcon = new Annotation_icon() as DisplayObject;
			addChild(myIcon);
			myIcon.x = 0-myIcon.width/2;
			myIcon.y = 0-myIcon.height/2;
			myIcon.alpha = 0.8;
			myIcon.scaleX = 0.15;
			myIcon.scaleY = 0.15;
			this.addEventListener(MouseEvent.CLICK,toggleShown);
			this.addEventListener(MouseEvent.MOUSE_OVER,mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,mouseOut);
		}
		
		private function mouseOver(e:MouseEvent):void {
			myIcon.scaleX = 0.2;
			myIcon.scaleY = 0.2;
			myIcon.x = 0-myIcon.width/2-1;
			myIcon.y = 0-myIcon.height/2-1;
		}
		
		private function mouseOut(e:MouseEvent):void {
			myIcon.scaleX = 0.15;
			myIcon.scaleY = 0.15;
			myIcon.x = 0-myIcon.width/2;
			myIcon.y = 0-myIcon.height/2;
		}
		
		private function resetFormat(e:KeyboardEvent):void {
			annotationTextArea.setTextFormat(annotationTextFormat);
		}
		
		private function toggleShown(e:MouseEvent):void {
			thePDF.removeDeadAnnotations();
			thePDF.removeHighlighting();
			if(annotationContent.alpha == 0) {
				show();
			} else {
				hide();
			}
		}
		
		private function copyText(e:MouseEvent):void {
			e.stopImmediatePropagation();
			thePDF.copyText();
		}
		
		private function saveAnnotation(e:MouseEvent):void {
			if(annotationContent.contains(createAnnotationButton)) {
				annotationContent.removeChild(createAnnotationButton);
			}
			annotationTextArea.selectable = false;
			annotationTextArea.textColor = 0xFFFFFF;
			annotationTextArea.background = false;
			annotationTextArea.border = false;
			isCreated = true;
			addIcon();
			hide();
			thePDF.createScrollAnnotation(this);
		}
		
		public function savePreviousAnnotation(text:String):void {
			annotationBackground.graphics.clear();
			annotationBackground.graphics.beginFill(0x333333,0.9);
			annotationBackground.graphics.drawRoundRect(annotationWidth/-2,fullAnnotationHeight*-1-annotationArrowSize,annotationWidth,fullAnnotationHeight,10);
			annotationBackground.graphics.moveTo(0-annotationArrowSize/1.5,0-annotationArrowSize);
			annotationBackground.graphics.lineTo(0,0);
			annotationBackground.graphics.lineTo(0+annotationArrowSize/1.5,0-annotationArrowSize);
			if(annotationContent.contains(copyTextButton)) {
				annotationContent.removeChild(copyTextButton);
				annotationContent.removeChild(addAnnotationButton);
			}
			addAnnotationTextArea();
			annotationTextArea.text = text;
			annotationTextArea.selectable = false;
			annotationTextArea.textColor = 0xFFFFFF;
			annotationTextArea.background = false;
			annotationTextArea.border = false;
			isCreated = true;
			addIcon();
			hide();
			thePDF.createScrollAnnotation(this);
			myIcon.scaleX = 0.15;
			myIcon.scaleY = 0.15;
			myIcon.x = 0-myIcon.width/2;
			myIcon.y = 0-myIcon.height/2;
			annotationTextArea.setTextFormat(annotationTextFormat);
			annotationTextArea.textColor = 0xFFFFFF;
		}
		
		public function hide():void {
			Tweener.addTween(annotationContent,{'alpha':0,'scaleY':0,'scaleX':0,'time':1});
			thePDF.removeHighlighting();
		}
		
		public function show():void {
			Tweener.addTween(annotationContent,{'alpha':1,'scaleY':1,'scaleX':1,'time':1});
			thePDF.hightlight(this,startPos,stopPos);
		}

	}
}