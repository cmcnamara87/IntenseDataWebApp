package Module.PDFViewer 
{
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.TextInput;
	import mx.events.FlexEvent;
	import mx.events.SliderEvent;
	import mx.controls.Button;
	import spark.components.HSlider;

	public class PDFToolbar extends Canvas {
		
		private var viewer:PDFViewer;
		private var buttonsDrawn:Boolean = false;
		
		public var buttonDrawModes:Boolean = true;
		private var buttonModeMove:Button;
		private var buttonModeAnnotate:Button;
		
		public var buttonDrawFind:Boolean = true;
		private var buttonFindTextField:TextInput;
		
		public var buttonDrawPageNav:Boolean = true;
		private var buttonPagePrev:Button;
		private var buttonPageNext:Button;
		
		public var buttonDrawZoom:Boolean = true;
		private var buttonZoomAll:Button;
		private var buttonZoomFull:Button;
		private var buttonZoomIn:Button;
		private var buttonZoomSlider:HSlider;
		private var buttonZoomOut:Button;
		
		private var highlightColourGood:uint = 0xFFFF33;
		private var highlightColourBad:uint = 0xFF9999;
		
		public function PDFToolbar(viewer:PDFViewer) {
			this.viewer = viewer;
			super();
			setStyles();
			this.addEventListener(Event.RESIZE, resizeHandler);
			addEventListener(FlexEvent.INITIALIZE, initializeHandler);
		}
				
		private function setStyles():void {
			setStyle("width", "100%");
			setStyle("height", "30");
			setStyle("backgroundColor", "#DDDDDD");
			setStyle("borderThickness",0); 
			setStyle("borderStyle","solid");
			setStyle("borderColor","#666666");
			//setStyle("cornerRadius",10);
			setStyle("dropShadowEnabled",false);
		}
		
		private function initializeHandler(event:FlexEvent):void {
			this.drawButtons();
		}
		
		private function resizeHandler(e:Event):void {
			this.graphics.clear();
			this.graphics.beginFill(this.getStyle("backgroundColor"),1);
			this.graphics.drawRect(0,this.height-this.getStyle("cornerRadius"),this.getStyle("cornerRadius"),this.getStyle("cornerRadius"));
			this.graphics.drawRect(this.width-this.getStyle("cornerRadius"),this.height-this.getStyle("cornerRadius"),this.getStyle("cornerRadius"),this.getStyle("cornerRadius"));
			if(this.width < 740) {
				if(contains(buttonPagePrev)) {
					removeChild(buttonPagePrev);
				}
				if(contains(buttonPageNext)) {
					removeChild(buttonPageNext);
				}
			} else {
				if(!contains(buttonPagePrev)) {
					addChild(buttonPagePrev);
				}
				if(!contains(buttonPageNext)) {
					addChild(buttonPageNext);
				}
			}
			if(this.width < 540) {
				if(contains(buttonZoomIn)) {
					removeChild(buttonZoomIn);	
				}
				if(contains(buttonZoomSlider)) {
					removeChild(buttonZoomSlider);	
				}
				if(contains(buttonZoomOut)) {
					removeChild(buttonZoomOut);	
				}
			} else {
				if(!contains(buttonZoomIn)) {
					addChild(buttonZoomIn);	
				}
				if(!contains(buttonZoomSlider)) {
					addChild(buttonZoomSlider);	
				}
				if(!contains(buttonZoomOut)) {
					addChild(buttonZoomOut);	
				}
			}		
		}
		
		private function delegate(buttonCall:String):void {
			viewer.buttonClicked(buttonCall);
		}
		
		/*---
		This is just the buttons implementation
		---*/
		
		private function buttonModeChange(e:FlexEvent):void {
			if(e.target.name == "Move") {
				this.delegate("moveMode");
				buttonModeMove.selected = true;
				buttonModeAnnotate.selected = false;
			} else {
				this.delegate("annotateMode");
				buttonModeMove.selected = false;
				buttonModeAnnotate.selected = true;
			}
		}
		
		private function buttonClick(e:FlexEvent):void {
			switch(e.target.name) {
				case "Previous Page":
					this.delegate("previous");
					break;
				case "Next Page":
					this.delegate("next");
					break;
				case "-":
					buttonZoomSlider.value -= 25;
					changedZoom();
					break;
				case "+":
					buttonZoomSlider.value += 25;
					changedZoom();
					break;
				case "All":
					this.delegate("zoomall");
					buttonZoomSlider.value = 160;
					break;
				case "100%":
					buttonZoomSlider.value = 100;
					changedZoom();
					break;
			}
	
		}
		
		private function changedZoom():void {
			this.delegate("zoom:"+buttonZoomSlider.value);
		}
		
		private function searchPDF(e:Event):void {
			this.delegate("find:"+buttonFindTextField.text);
		}
		
		public function searchboxHighlight(numberFound:Number):void {
			if(numberFound > 0) {
				buttonFindTextField.setStyle("backgroundColor",Number(highlightColourGood));
				buttonFindTextField.setStyle("borderColor",Number(highlightColourGood));
			} else if(numberFound == 0 && buttonFindTextField.text.length > 0) {
				buttonFindTextField.setStyle("backgroundColor",Number(highlightColourBad));
				buttonFindTextField.setStyle("borderColor",Number(highlightColourBad));
			} else {
				buttonFindTextField.setStyle("backgroundColor",Number(0xFFFFFF));
				buttonFindTextField.setStyle("borderColor",Number(0xFFFFFF));
			}
		}
		
		private function zoomSliderChanged(e:Event):void {
			changedZoom();
		}
		
		private function drawButtons():void {
			//Move Button
			if(buttonDrawModes) {
				buttonModeMove = new Button();
				buttonModeMove.label = "View";
				buttonModeMove.name = "Move";
				buttonModeMove.styleName="textViewMoveBtn"
				buttonModeMove.width = 50;
				buttonModeMove.setStyle("top",6);
				buttonModeMove.setStyle("left",7);
				buttonModeMove.selected = true; 
				buttonModeMove.addEventListener(FlexEvent.BUTTON_DOWN,buttonModeChange);
				this.addChild(buttonModeMove);
				
				buttonModeAnnotate = new Button();
				buttonModeAnnotate.label = "Annotate";
				buttonModeAnnotate.name = "Annotate";
				buttonModeAnnotate.styleName="textViewAnnotateBtn";
				buttonModeAnnotate.setStyle("paddingLeft",3);
				buttonModeAnnotate.setStyle("paddingRight",3);
				buttonModeAnnotate.setStyle("top",6);
				buttonModeAnnotate.setStyle("left",65);
				buttonModeAnnotate.addEventListener(FlexEvent.BUTTON_DOWN,buttonModeChange);
				this.addChild(buttonModeAnnotate);
			}
			
			if(buttonDrawFind) {
				buttonFindTextField = new TextInput();
				buttonFindTextField.styleName="textViewFindBtn";
				buttonFindTextField.setStyle("top",6);
				buttonFindTextField.setStyle("cornerRadius",4);
				buttonFindTextField.setStyle("borderStyle","solid");
				buttonFindTextField.setStyle("borderThickness",2);
				buttonFindTextField.setStyle("borderColor","0xFFFFFF");
				buttonFindTextField.setStyle("paddingLeft",2);
				buttonFindTextField.setStyle("right",6);
				buttonFindTextField.addEventListener(Event.CHANGE,searchPDF);
				this.addChild(buttonFindTextField);
			}
			
			if(buttonDrawPageNav) {
				buttonPagePrev = new Button();
				buttonPagePrev.buttonMode=true;buttonPagePrev.useHandCursor=true;
				buttonPagePrev.label = "Previous";
				buttonPagePrev.name = "Previous Page";
				buttonPagePrev.styleName="textViewPreviousBtn";
				buttonPagePrev.setStyle("paddingLeft",3);
				buttonPagePrev.setStyle("paddingRight",3);
				buttonPagePrev.setStyle("top",6);
				buttonPagePrev.setStyle("left",170);
				buttonPagePrev.width = 70;
				buttonPagePrev.addEventListener(FlexEvent.BUTTON_DOWN,buttonClick);
				this.addChild(buttonPagePrev);
				
				buttonPageNext = new Button();
				buttonPageNext.buttonMode=true;buttonPageNext.useHandCursor=true;
				buttonPageNext.label = "Next";
				buttonPageNext.name = "Next Page";
				buttonPageNext.styleName="textViewNextBtn";
				buttonPageNext.setStyle("paddingLeft",3);
				buttonPageNext.setStyle("paddingRight",3);
				buttonPageNext.setStyle("top",6);
				buttonPageNext.setStyle("left",249);
				buttonPageNext.width = 50;
				buttonPageNext.addEventListener(FlexEvent.BUTTON_DOWN,buttonClick);
				this.addChild(buttonPageNext);
			}
			
			if(buttonDrawZoom) {
				buttonZoomIn = new Button();
				buttonZoomIn.label = "-";
				buttonZoomIn.name = "-";
				buttonZoomIn.styleName="textViewZoomInBtn";
				buttonZoomIn.width = 28;
				buttonZoomIn.setStyle("paddingLeft",0);
				buttonZoomIn.setStyle("paddingRight",0);
				buttonZoomIn.setStyle("top",6);
				buttonZoomIn.setStyle("right",409);
				buttonZoomIn.addEventListener(FlexEvent.BUTTON_DOWN,buttonClick);
				this.addChild(buttonZoomIn);
				
				buttonZoomSlider = new HSlider();
				buttonZoomSlider.styleName="textViewZoomSlideBtn";
				buttonZoomSlider.setStyle("top",6);
				buttonZoomSlider.setStyle("right",332);
				buttonZoomSlider.width = 68;
				buttonZoomSlider.height = 22;
				buttonZoomSlider.minimum = 10;
				buttonZoomSlider.maximum = 300;
				buttonZoomSlider.value = 100;
				//buttonZoomSlider.addEventListener(SliderEvent.CHANGE,zoomSliderChanged);
				buttonZoomSlider.addEventListener(Event.CHANGE,zoomSliderChanged);
				this.addChild(buttonZoomSlider);
				
				buttonZoomOut = new Button();
				buttonZoomOut.label = "+";
				buttonZoomOut.name = "+";
				buttonZoomOut.styleName="textViewZoomOutBtn";
				buttonZoomOut.width = 28;
				buttonZoomOut.setStyle("paddingLeft",0);
				buttonZoomOut.setStyle("paddingRight",0);
				buttonZoomOut.setStyle("top",6);
				buttonZoomOut.setStyle("right",294);
				buttonZoomOut.addEventListener(FlexEvent.BUTTON_DOWN,buttonClick);
				this.addChild(buttonZoomOut);
				
				buttonZoomFull = new Button();
				buttonZoomFull.label = "100%";
				buttonZoomFull.name = "100%";
				buttonZoomFull.styleName="textViewZoom100Btn";
				buttonZoomFull.width = 55;
				buttonZoomFull.setStyle("paddingLeft",3);
				buttonZoomFull.setStyle("paddingRight",3);
				buttonZoomFull.setStyle("top",6);
				buttonZoomFull.setStyle("right",230);
				buttonZoomFull.addEventListener(FlexEvent.BUTTON_DOWN,buttonClick);
				this.addChild(buttonZoomFull);
								
				buttonZoomAll = new Button();
				buttonZoomAll.label = "Fit";
				buttonZoomAll.name = "All";
				buttonZoomAll.styleName="textViewZoomAllBtn";
				buttonZoomAll.width = 40;
				buttonZoomAll.setStyle("paddingLeft",3);
				buttonZoomAll.setStyle("paddingRight",3);
				buttonZoomAll.setStyle("top",6);
				buttonZoomAll.setStyle("right",182);
				buttonZoomAll.addEventListener(FlexEvent.BUTTON_DOWN,buttonClick);
				this.addChild(buttonZoomAll);
				
			}
		}
	}
}