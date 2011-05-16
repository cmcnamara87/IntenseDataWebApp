// ActionScript file
package Module.PDFViewer {
	
	import Controller.MediaController;
	
	import Lib.it.transitions.Tweener;
	
	import Model.Model_Commentary;
	
	import View.MediaView;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.MediaViewerInterface;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.system.*;
	import flash.text.*;
	
	import mx.containers.VBox;
	import mx.controls.ProgressBar;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	
	import spark.layouts.VerticalLayout;
	
	//public class PDFViewer extends VBox {
	public class PDFViewer extends MediaViewer implements MediaViewerInterface {		 
		[Embed(source="Assets/Module/cursorComment.png")]
            [Bindable]
			public var addAnnotationCursor:Class; 
		
		//The base area for the main bit
		private var TheStage:UIComponent = new UIComponent();
		
		private var viewerOverlay:Sprite = new Sprite();
		private var viewerOverlayText:TextField = new TextField;
		private var viewerOverlayTextFormat:TextFormat = new TextFormat;
		
		public var scrollingContainerHeight:Number = 10;
        
        //Loading the PDF
		public var thePDF:PDF; 
		private var PDFMask:Sprite = new Sprite();
		private var scrollingContainer:PDFScrollArea;
		
		public var _pdfurl:String = "";//assets/blah.swf";


		
		
		private var topOffset:Number = -6;
		
		public var annotationSave:Function = MediaView.saveAnnotationFunction;
		public var annotationDelete:Function;
        
        //Toolbar
        private var toolbar:PDFToolbar;
        
        //Where the annotation should sit next to the toolbar;
        private var sideAnnotationWidth:Number = 25;
        private var sideAnnotationsSprite:PDFSideAnnotationContainer;
        
        //Scrollbar
        private var scrollColours:Array = new Array(0x222222,0xFFFFFF,0x666666,0x999999,0x2222FF);
		
		public function PDFViewer() {
			super();
			
			
			var myLayout:VerticalLayout = new VerticalLayout();
			this.layout = myLayout;
			
			//annotationSave();
			//annotationSave();
			addEventListener(FlexEvent.INITIALIZE, initializeHandler);
		    

		}
		
		
		
		override public function load(pdfurl:String):void {
			_pdfurl = pdfurl;
			trace("pdf url", pdfurl);
			//_pdfurl = "http://recensio.dyndns.org/blah.swf";
			
			loadPDF();
			
		}
		
		public  function loadPDF():void {
			
			// Generate a new swf from a pdf maybe?? (craig)
			thePDF = new PDF(this._pdfurl,this,getStyle("selectionColor"),getStyle("selectionAccuracy"));
			scrollingContainer = new PDFScrollArea(thePDF,this.width - getStyle("borderThickness")*2-sideAnnotationWidth,this.height - getStyle("toolbarHeight") - getStyle("borderThickness")*2,15,'y',true,0.95,false,false,true,scrollColours);
			TheStage.addChild(scrollingContainer);
			scrollingContainer.y = topOffset;
			sideAnnotationsSprite = new PDFSideAnnotationContainer(this);
			TheStage.addChild(sideAnnotationsSprite);
			thePDF.addEventListener(ProgressEvent.PROGRESS, onProgressEvent );
			
			
		}
		
		
		//.cs.jvm
		
		
		
		
		
		
		
		override protected function measure():void {
            super.measure();
        }
		
		override public function addAnnotations(annotations:Array):void {
			trace("DING DING");
			trace(annotations);
			trace("DING DING");
			for(var i:Number=0; i<annotations.length; i++) {
				
				addComment(
					(annotations[i] as Model_Commentary).annotation_text,
					(annotations[i] as Model_Commentary).annotation_x,
					(annotations[i] as Model_Commentary).annotation_y,
					(annotations[i] as Model_Commentary).annotation_start,
					(annotations[i] as Model_Commentary).annotation_end
				);
			}
			if(thePDF.PDFLoaded) {
				// If we have added some annotations,
				// add them to the display
				thePDF.loadExistingAnnotations();
			}
		}
        
        public function addComment(content:String,xPos:Number,yPos:Number,startTextPos:Number,stopTextPos:Number):void {
        	thePDF.insertAnnotation(content,new Point(xPos,yPos),startTextPos,stopTextPos);
        }
        
        public function finishedLoadingComments():void {
        	if(thePDF.loadedAnnotations) {
        		thePDF.loadExistingAnnotations();
        	}
        }
        
        public function getPDFOffset():Number {
        	return thePDF.getYPos();
        }
        
        public function setPDFOffset(newOffset:Number):void {
        	thePDF.setYPos(newOffset);
        }
		
		public function createScrollAnnotation(theannotation:PDFAnnotation):void {
			if(!theannotation.previousComment) {
				exportAnnotation(theannotation.getExportData());
			}
			var mySideAnnotation:PDFAnnotationSideMarker = new PDFAnnotationSideMarker(thePDF,theannotation);
			sideAnnotationsSprite.add(mySideAnnotation,theannotation.y/thePDF.height);
		}
		
		public function exportAnnotation(data:Object):void {
			data.x = data.xPos; 
			data.y = data.yPos;
			data.start = data.startTextPos;
			data.end = data.stopTextPos;
			data.text = data.text; 
			var annotationArray:Array = new Array(data);
			annotationSave(annotationArray);
		}
		
		private function initializeHandler(event:FlexEvent):void {
			this.addEventListener(Event.RESIZE, resizeHandler);
			setDefaultStyles();
			setupToolbar();
			this.addElement(TheStage);
//			loadPDF(); // ends up calling paint
        }
        
        private function setupToolbar():void {
        	toolbar = new PDFToolbar(this);
			toolbar.percentWidth = 100;
			toolbar.height = getStyle("toolbarHeight");
			this.addElement(toolbar);
			setupOverlay();
        }
        
        private function setupOverlay():void {
        	viewerOverlayText = new TextField();
        	viewerOverlayText.mouseEnabled = false;
        	viewerOverlayText.selectable = false;
        	viewerOverlay.mouseChildren = false;
        	viewerOverlay.mouseEnabled = false;
        	viewerOverlayTextFormat = new TextFormat();
        	viewerOverlayTextFormat.align = TextFormatAlign.CENTER;
        	viewerOverlayTextFormat.color = 0xFFFFFF;
        	viewerOverlayTextFormat.font = "Arial";
        	viewerOverlayTextFormat.bold = true;
        	viewerOverlayTextFormat.size = 30;
        }
        
        public function drawOverlay(textToOverlay:String):void {
        	viewerOverlay.graphics.clear();
        	var overlayWidth:Number = 240;
        	var overlayHeight:Number = 40;
        	viewerOverlay.graphics.beginFill(0x000000,0.7);
        	viewerOverlay.graphics.drawRoundRect((this.width/2-overlayWidth/2),(this.height-overlayHeight*3),overlayWidth,overlayHeight,20);
        	viewerOverlayText.x = (this.width/2-overlayWidth/2);
        	viewerOverlayText.y = (this.height-overlayHeight*3);
        	viewerOverlayText.width = overlayWidth;
        	viewerOverlayText.blendMode = BlendMode.LAYER;
        	viewerOverlay.addChild(viewerOverlayText);
        	TheStage.addChild(viewerOverlay);
        	viewerOverlayText.text = textToOverlay;
        	viewerOverlayText.setTextFormat(viewerOverlayTextFormat);
        	Tweener.addTween(viewerOverlay,{'alpha':1,'time':0.5,'onComplete':hideOverlay});
        }
        
        public function disableOverlay():void {
        	if(TheStage.contains(viewerOverlay)) {
        		TheStage.removeChild(viewerOverlay);
        	}
        }
        
        public function enableOverlay():void {
        	TheStage.addChild(viewerOverlay);
        }
        
        private function hideOverlay():void {
        	Tweener.addTween(viewerOverlay,{'alpha':0,'time':1,'delay':0.5});
        }
		

        
        private function resizeHandler(e:Event):void {
        	if(thePDF) {
	        	thePDF.setZoomLevel();
    	    	redrawArea();
        	}
        }
        
        public function updateScrollbars():void {
        	scrollingContainer.updateScrollbarX();
        	scrollingContainer.updateScrollbarY();
        }
        
        public function buttonClicked(buttonCall:String):void {
        	if(buttonCall.substr(0,5) == 'zoom:') {
        		thePDF.zoom(Number(buttonCall.substr(5)));
        	} else if(buttonCall.substr(0,5) == 'find:') {
        		var numresults:Number = thePDF.findText(buttonCall.substr(5));
        		toolbar.searchboxHighlight(numresults);
        		drawOverlay("Found: "+numresults);
        	}else {
   	     		switch(buttonCall) {
   	     			case 'zoomall':
   	     				thePDF.zoomWidth(this.width-sideAnnotationWidth-10);
   	     				break;
   	     			case 'next':
   	     				var pageNumber:Number = thePDF.gotoNext();
   	     				drawOverlay('Page '+pageNumber+'/'+thePDF.getTotalPages());
   	     				break;
   	     			case 'previous':
   	     				var pageNumberP:Number = thePDF.gotoPrevious();
   	     				drawOverlay('Page '+pageNumberP+'/'+thePDF.getTotalPages());
   	     				break;
   	     			case 'annotateMode':
   	     				scrollingContainer.disableTouch();
   	     				CursorManager.setCursor(addAnnotationCursor);
   	     				break;
   	     			case 'moveMode':
   	     				thePDF.disableAnnotation();
   	     				scrollingContainer.enableTouch();
   	     				CursorManager.removeAllCursors();
   	     				break;
        		}
        	}
        }
        
        public function redrawArea(forced:Boolean = false):void {
        	scrollingContainerHeight = this.height - getStyle("toolbarHeight") - getStyle("borderThickness")*2;
        	scrollingContainer.refresh(forced,this.width - getStyle("borderThickness")*2-sideAnnotationWidth,scrollingContainerHeight);
        	sideAnnotationsSprite.resize();
        	CursorManager.removeAllCursors();
        }
		
		/* These are the default recommended styles */
		private function setDefaultStyles():void {
			setStyle("dropShadowEnabled",true);
			setStyle("backgroundColor","#666666");
			setStyle("backgroundAlpha",0.7);
			 
			setStyle("borderThickness",1); 
			setStyle("borderStyle","solid"); 
			setStyle("borderColor","#DDDDDD"); 
			//setStyle("cornerRadius",10);
			
			setStyle("paddingLeft", 0);
            setStyle("paddingRight", 0);
            setStyle("paddingTop", 0);
            setStyle("paddingBottom", 0);
            
            setStyle("selectionColor",0xAAAAFF);
            setStyle("selectionAccuracy",50);
            setStyle("toolbarHeight",35);
		}
			//
			//added 2009.10.09.cogs.jvm
			//@note: this really should be managed better
			private var progressBar:ProgressBar;
			private var progressBarPopup:IFlexDisplayObject;
			private function doAddProgressBar():void
			{
                //progressBarPopup = PopUpManager.createPopUp(this, ProgressBar, false) as ProgressBar;
                progressBar	=	new ProgressBar();
                this.addChild( progressBar );
                progressBar.move(parentApplication.width/2, parentApplication.height/2);
                //progressBarPopup	=	PopUpManager.addPopUp( progressBar, this, true);
                //PopUpManager.centerPopUp( progressBarPopup );
			}
			private function onProgressEvent(event:ProgressEvent):void
			{
				var bytesLoaded:uint	=	event.bytesLoaded;
				var totalBytes:uint	=	event.bytesTotal;
				
				if(progressBar)
				{
					if(bytesLoaded==totalBytes)
					{
						//PopUpManager.removePopUp( progressBar );
						this.removeChild( progressBar );
						progressBar	=	null;//yuk?
					}
				}
					
				if(progressBar)
				{
					progressBar.setProgress( bytesLoaded, totalBytes );
				}
				
				
				
			}
	}
}