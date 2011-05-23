package Module.PDFViewer {
	
	import Controller.Dispatcher;
	
	import Lib.it.transitions.Tweener;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextSnapshot;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;

	public class PDF extends Sprite {
		
		private var swfURL:String = "";
		private var pdfScale:Number = 100;
		private var PDF1:MovieClip;
		
		private var PDFPageSpace:Number = 20;
		
		public var PDFContainer:MovieClip = new MovieClip;
		public var PDFLoaded:Boolean = false;
		
		//Selection Variables
		private var mySnapArray:Array = new Array();
		
		private var mySnap:TextSnapshot;
		private var snapCount:int;
		private var startSelectPos:Number = 0;
        private var stopSelectPos:Number = 0;
        private var isSelecting:Boolean = false;
        private var selectedText:String = '';
        private var selectAccuracy:uint;
        private var selectColour:uint;
        private var highlightColour:uint = 0xFFFF00;
        private var annotationColor:uint = 0x00FF00;
        
        private var currentSnap:TextSnapshot;
        private var currentObject:MovieClip; 
        
        private var totalPages:Number = 0;       
        
        //Move Variables
        private var moveTimer:Timer = new Timer(30);
        private var lastMovePosition:Point = new Point();
        
        private var annotationsContainer:Array = new Array();
        
		
		private var SWFLoader:Loader;
		private var viewer:PDFViewer;
		
		private var annotationsInsert:Array = new Array();
		public var loadedAnnotations:Boolean = false;
		
		private var SWFData:URLLoader;
		
		private var pageTimeoutTimer:Timer = new Timer(2000);
		private var retries:Number = 0;
		
		public function PDF(swfURL:String,viewer:PDFViewer,selectColour:uint,selectAccuracy:uint) {
			this.swfURL = swfURL;//"http://recensio.acid.net.au:5080/oflaDemo/streams/837.swf";
			//Alert.show("swfURL: "+swfURL );//
			//this.swfURL = "http://recensio.acid.net.au:5080/oflaDemo/streams/837.swf";
			this.viewer = viewer;
			this.selectColour = selectColour;
			this.selectAccuracy = selectAccuracy;
			this.addChild(PDFContainer);
			PDFContainer.tabChildren = false;
			loadSWF();
		}
		
		public function zoomWidth(zoomWidth:Number):void {
			pdfScale = zoomWidth / (PDFContainer.width / PDFContainer.scaleX) * 100;
			setZoomLevel();
		}
		
		public function zoom(zoomValue:Number):void {
			pdfScale = zoomValue;
			setZoomLevel();
		}
		
		public function createScrollAnnotation(theannotation:PDFAnnotation):void {
			viewer.createScrollAnnotation(theannotation);
		}
		
		public function gotoNext():Number {
			var newPage:Number = currentPage() + 1;
			if(newPage > PDF1.totalFrames) {
				newPage = PDF1.totalFrames;
			} else {
			}
			var moveY:Number = PDFContainer.getChildAt(newPage-1).y*-1*PDFContainer.scaleY;
			Tweener.addTween(this,{'y':moveY,'time':1,'onUpdate':updateScrollbars});
			return newPage;
		}
		
		public function gotoPrevious():Number {
			var newPage:Number = currentPage() - 1;
			if(newPage < 1) {
				newPage = 1;
			}
			var moveY:Number = PDFContainer.getChildAt(newPage-1).y*-1*PDFContainer.scaleY;
			Tweener.addTween(this,{'y':moveY,'time':1,'onUpdate':updateScrollbars});
			return newPage;
		}
		
		public function currentPage():Number {
			var currentY:Number = this.y*-1;
			var thepage:Number = 1;
			for(var i:Number=0; i<PDF1.totalFrames; i++) {
				if(currentY+10 < PDFContainer.getChildAt(i).y*PDFContainer.scaleY) {
					break;
				}
				thepage = 1 +i;
			}
			return thepage;
		}
		
		public function gotoYPos(yPos:Number):void {
			this.removeDeadAnnotations();
			var yPosAccurate:Number = yPos*-1+(PDF1.height*pdfScale/200);
			if(yPosAccurate > 0) { yPosAccurate = 0; }
			Tweener.addTween(this,{'y':yPosAccurate,'time':1,'onUpdate':updateScrollbars});
		}
		
		public function getYPos():Number {
			return this.y*-1;
		}
		
		public function setYPos(yPos:Number):void {
			Tweener.addTween(this,{'y':yPos*-1,'time':1,'onUpdate':updateScrollbars});
		}
		
		public function getTotalPages():Number {
			return totalPages;
		}
		
		private function updateScrollbars():void {
			viewer.updateScrollbars();
		}
		
		public function findText(theText:String):Number {
			this.removeDeadAnnotations();
			removeHighlighting();
			checkSnapLoad();
			var numberFound:Number = 0;
			var foundone:Boolean = false;
			var currentPage:Number = 0;
			for each(var currentSnap:TextSnapshot in mySnapArray) {
				currentSnap.setSelectColor(highlightColour);
				var currentChar:Number = 0;
				var position:Number = 0;
				while(currentChar < currentSnap.charCount && position != -1) {
					position = currentSnap.findText(currentChar,theText,false);
					if(position > -1) {
						if(!foundone) {
							//Move to the first one
							var info:Array = currentSnap.getTextRunInfo(position,position+1);
							var moveY:Number = PDFContainer.getChildAt(currentPage).y*-1*PDFContainer.scaleY-info[0].matrix_ty+30*PDFContainer.scaleY;
							Tweener.addTween(this,{'y':moveY,'time':1,'onUpdate':updateScrollbars});
							foundone = true;
						}
						currentSnap.setSelected(position, position+theText.length, true);
						numberFound++;
						currentChar = position + theText.length;
					}
				}
				currentPage++;
			}
			return numberFound;
		}
		
		public function disableAnnotation():void {
			removeHighlighting();
			removeDeadAnnotations();
		}
		
		public function copyText():void {
			System.setClipboard(selectedText);
			removeDeadAnnotations();
		}
		
		private function loadSWF():void {
			SWFData = new URLLoader();
			SWFData.dataFormat = URLLoaderDataFormat.BINARY;
			SWFData.addEventListener(Event.COMPLETE,loadComplete);
			SWFData.addEventListener(IOErrorEvent.IO_ERROR, ioerror);
			SWFData.load(new URLRequest(this.swfURL));
		}
		
		private function ioerror(e:IOErrorEvent):void {
			Alert.show("This PDF is still being transcoded so we can display it. It will become available shortly.");
			Dispatcher.call('browse');
		}
		
		private function loadComplete(e:Event):void {
			SWFLoader = new Loader();
			SWFLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgressEvent );
			SWFLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,finishInitialLoad);
			SWFLoader.loadBytes(SWFData.data);
		}
		
		private function finishInitialLoad(e:Event):void {
        	e.currentTarget.content.gotoAndStop(1);
			PDF1 = e.currentTarget.content as MovieClip;
			PDFContainer.addChild(PDF1);
			if(PDF1.totalFrames > 1) {
				loadPage();
				pageTimeoutTimer.addEventListener(TimerEvent.TIMER,timedoutpage);
			} else {
				finishPDFRender();
			}
			setZoomLevel();
		}
		
		private function clone(source:Object):* {
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(source);
			myBA.position = 0;
			return(myBA.readObject());
		}
		
		public function removeDeadAnnotations():void {
			for each(var annotation:PDFAnnotation in annotationsContainer) {
				if(!annotation.checkCreation()) {
					annotationsContainer.splice(annotationsContainer.indexOf(annotation),1);
					if(PDFContainer.contains(annotation)) {
						Tweener.addTween(annotation,{'alpha':0,'scaleY':0,'time':0.5,'onComplete':removeAnnotation,'onCompleteParams':[annotation]});
					}
				} else {
					annotation.hide();
				}
			}
		}
		
		private function removeAnnotation(annotation:PDFAnnotation):void {
			if(PDFContainer.contains(annotation)) {
				PDFContainer.removeChild(annotation);
			}
		}
		
		private function loadPage():void {
			if(retries > 5) {
				Alert.show("An error occurred, could not load PDF file.");
			} else {
				var tmpLoader:Loader = new Loader();
				//tmpLoader.load(new URLRequest(this.swfURL));
				tmpLoader.loadBytes(SWFData.data);
				tmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadedPage);
				pageTimeoutTimer.start();
			}
		}
		
		private function loadedPage(e:Event):void {
			retries = 0;
			pageTimeoutTimer.stop();
			e.currentTarget.content.gotoAndStop(1);
			var newPage:MovieClip = e.currentTarget.content as MovieClip;
			PDFContainer.addChild(newPage);
			newPage.gotoAndStop(PDFContainer.numChildren);
			newPage.y = (PDFContainer.numChildren-1)*(PDF1.height+PDFPageSpace);
			if(PDFContainer.numChildren == PDF1.totalFrames) {
			//if(PDFContainer.numChildren > 4 || PDFContainer.numChildren == PDF1.totalFrames) { //debug for large pdfs	
				finishPDFRender();
			} else {
				setTimeout(loadPage,100);
				viewer.drawOverlay("Loading "+PDFContainer.numChildren+"/"+PDF1.totalFrames);
				forceRedraw();
			}
		}
		
		private function timedoutpage(e:TimerEvent):void {
			retries++;
			loadPage();
		}
		
		private function finishPDFRender():void {
			trace("FINISHING RENDER");
			PDFLoaded = true;
			totalPages = PDFContainer.numChildren;
			this.addEventListener(MouseEvent.MOUSE_DOWN,startTextSelect);
			this.addEventListener(MouseEvent.MOUSE_UP,stopTextSelect);
			this.addEventListener(MouseEvent.MOUSE_OUT,stopTextSelect);
			forceRedraw();
			loadExistingAnnotations();
		}
		
		private function forceRedraw():void {
			viewer.redrawArea(true);
		}
		
		public function setZoomLevel():void {
			var originalWidth:Number = Math.round(PDFContainer.width/PDFContainer.scaleX);
			var originalHeight:Number = Math.round(PDFContainer.height/PDFContainer.scaleY);
			var viewAreaWidth:Number = viewer.width-40;
			var viewAreaHeight:Number = viewer.height-30;
			var ratiodifference:Number = pdfScale/100 - PDFContainer.scaleY;
			if(originalHeight*pdfScale/100 < viewAreaHeight) {
				pdfScale = viewAreaHeight/originalHeight*100;
				if(originalHeight == 0) {
					pdfScale = 100;
				}
			}
			var centerY:Number = this.y;
			var newHeight:Number = originalHeight*(pdfScale/100);
			var newX:Number = (viewAreaWidth-originalWidth*pdfScale/100)/2;
			if(originalWidth*pdfScale/100 > viewAreaWidth) {
				if(originalWidth*PDFContainer.scaleX > viewAreaWidth) {
					newX = PDFContainer.x;	
				} else {
					newX = 0;
				}
			}
			var newY:Number = this.y/PDFContainer.scaleY*pdfScale/100;
			if((newY*-1)+viewer.height > newHeight) {
				newY = newHeight*-1+viewer.height;	
			}
			if(newY > 0) {
				newY = 0;
			} 
			pdfScale = Math.round(pdfScale);
			Tweener.addTween(PDFContainer,{
				'scaleX':pdfScale/100,
				'scaleY':pdfScale/100,
				'time':1,
				'onComplete':forceRedraw,
				'onUpdate':forceRedraw
			});
			Tweener.addTween(this,{
				'x':newX,
				'y':newY,
				'time':1,
				'onComplete':forceRedraw,
				'onUpdate':forceRedraw
			});
			forceRedraw();
		}
		
		private function checkSnapLoad():void {
			if(!mySnap) {
				for (var i:Number=0; i<PDF1.totalFrames; i++) {
					var tmpsnap:TextSnapshot = (PDFContainer.getChildAt(i) as MovieClip).textSnapshot;
					mySnapArray.push(tmpsnap);
				}
				mySnap = PDF1.textSnapshot;
			}
		}
		
		private function checkPage(xPos:Number,yPos:Number):Number {
			viewer.disableOverlay();
			try {
				var mypoint:Point = new Point(xPos,yPos);
				var objectsarray:Array = this.stage.getObjectsUnderPoint(mypoint);
				var theobject:* = objectsarray[objectsarray.length - 1];
				var pagenumber:Number = -1;
				while(theobject.parent != this.stage) {
					if(PDFContainer.contains(theobject.parent)) {
						try {
							pagenumber = PDFContainer.getChildIndex(theobject.parent);
						} catch(e:Error) {
							viewer.enableOverlay();
							return -1;
						}
						break;
					} else {
						theobject = theobject.parent;
					}
					
				}
				viewer.enableOverlay();
				return pagenumber+1;
			} catch (e:Error) {
				//trace("Bad object");
			}
			viewer.enableOverlay();
			return -1;
		} 
		
		private function checkRealPage(yPos:Number = 0):Number {
			var pageNum:Number = Math.ceil((this.y+30)*-1/PDF1.height);
			if(pageNum == 1) {
				pageNum = 2;
			}
			return pageNum;
		}
		
		public function removeHighlighting():void {
			for(var i:Number=0; i<mySnapArray.length; i++) {
				mySnapArray[i].setSelected(0, mySnapArray[i].charCount, false);
			}
		}
		
		public function hightlight(annotation:PDFAnnotation,startPos:Number,stopPos:Number):void {
			removeHighlighting();
			var page:Number = Math.floor(annotation.y/PDF1.height);
			checkSnapLoad();
			currentSnap = mySnapArray[page];
			try {
				currentSnap.setSelectColor(annotationColor);
				currentSnap.setSelected(startPos, stopPos, true);
			} catch (e:Error) {
				trace("Error PDF.as line 381, should fix");
			}
		}
		
		/*---
		SELECTING TEXT
		---*/
		private function startTextSelect(e:MouseEvent):void {
			if(e.target is MovieClip) {
				removeDeadAnnotations();
				//Get the text snapshot for the first time
				checkSnapLoad();
				checkPage(e.stageX,e.stageY);
				var thepage:Number = (checkPage(e.stageX,e.stageY)-1);
				trace("***"+thepage);
				if(thepage > -1) {
					currentSnap = mySnapArray[thepage];
					currentObject = (PDFContainer.getChildAt(checkPage(e.stageX,e.stageY)-1) as MovieClip);
					currentSnap.setSelectColor(selectColour);
					removeHighlighting();
					var globalpoint:Point = new Point(e.stageX, e.stageY);
					startSelectPos = currentSnap.hitTestTextNearPos(currentObject.globalToLocal(globalpoint).x,currentObject.globalToLocal(globalpoint).y,selectAccuracy);
					this.addEventListener(MouseEvent.MOUSE_MOVE,updateTextSelect);
					isSelecting = true;
				}
			} else {
				trace("NOT A MOVIE CLIP");
			}
		}
		
		private function updateTextSelect(e:MouseEvent):void {
			removeHighlighting();
			var globalpoint:Point = new Point(e.stageX, e.stageY);
			stopSelectPos = currentSnap.hitTestTextNearPos(currentObject.globalToLocal(globalpoint).x,currentObject.globalToLocal(globalpoint).y,selectAccuracy);
			if(stopSelectPos < startSelectPos) {
				currentSnap.setSelected(stopSelectPos, startSelectPos, true);
			} else {
				currentSnap.setSelected(startSelectPos, stopSelectPos, true);
			}
		}
		
		private function stopTextSelect(e:MouseEvent):void {
			if(isSelecting) {
				isSelecting = false;
				this.removeEventListener(MouseEvent.MOUSE_MOVE,updateTextSelect);
				//Check if anything is actually selected
				if(startSelectPos > -1 && currentSnap) {
					selectedText = (currentSnap.getSelectedText(true));
					//If some text has been selected, let us annotate it
					if(selectedText != '') {
						var localpoint:Point = new Point(e.localX, e.localY);
						createAnnotation(localpoint,startSelectPos,stopSelectPos);
					}
				}
			}
		}
		
		public function createAnnotation(pointOnDocument:Point,startPos:Number,stopPos:Number):void {
        	var myAnnotation:PDFAnnotation = new PDFAnnotation(this,pointOnDocument,startPos,stopPos,pointOnDocument.x,pointOnDocument.y);
        	PDFContainer.addChild(myAnnotation);
			annotationsContainer.push(myAnnotation);
        	myAnnotation.x = pointOnDocument.x;
        	myAnnotation.y = pointOnDocument.y;
        	if((pointOnDocument.y)+this.y < 170) {
	        	Tweener.addTween(this,{'y':this.y+170,'time':1,'onUpdate':updateScrollbars});
	        }
        }
        
        public function insertAnnotation(text:String,pointOnDocument:Point,startPos:Number,stopPos:Number):void {
        	var tmpAnnotation:Object = new Object();
        	tmpAnnotation.text = text;
        	tmpAnnotation.pointOnDocument = pointOnDocument;
        	tmpAnnotation.startPos = startPos;
        	tmpAnnotation.stopPos = stopPos;
        	annotationsInsert.push(tmpAnnotation);
        }
        
        public function loadExistingAnnotations():void {
        	checkSnapLoad();
        	for(var i:Number=annotationsInsert.length-1; i>-1; i--) {
        		trace(annotationsInsert[i].text);
        		var myAnnotation:PDFAnnotation = new PDFAnnotation(this,annotationsInsert[i].pointOnDocument,annotationsInsert[i].startPos,annotationsInsert[i].stopPos,annotationsInsert[i].pointOnDocument.x,annotationsInsert[i].pointOnDocument.y);
        		myAnnotation.previousComment = true;
   		     	PDFContainer.addChild(myAnnotation);
   		     	myAnnotation.x = annotationsInsert[i].pointOnDocument.x;
        		myAnnotation.y = annotationsInsert[i].pointOnDocument.y;
   		     	myAnnotation.savePreviousAnnotation(annotationsInsert[i].text);
				annotationsContainer.push(myAnnotation);
				annotationsContainer.splice(i,1);
        		if((annotationsInsert[i].pointOnDocument.y)+this.y < 170) {
	        		Tweener.addTween(this,{'y':this.y+170,'time':1,'onUpdate':updateScrollbars});
	        	}
        	}
        	removeDeadAnnotations();
        	trace("LOADING EXISTING ANNOTATIONS");
        	loadedAnnotations = true;
        }
        
        private function onProgressEvent( event:ProgressEvent ):void
        {
        	dispatchEvent( event );
        }
	}

}