package View.components.MediaViewer.PDFViewer {
	
	import Controller.Dispatcher;
	import Controller.ERA.FileController;
	import Controller.IDEvent;
	
	import Lib.it.transitions.Tweener;
	
	import Module.PDFViewer.PDFAnnotation;
	
	import View.components.MediaViewer.Viewer;
	
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
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	/**
	 * Holds a PDF (read from a swf file created when the pdf was uploaded) 
	 * @author cmcnamara87
	 * 
	 */	
	public class PDF extends UIComponent {
		
		private var swfURL:String = "";
		private var pdfScale:Number = 100;
		private var PDF1:MovieClip;
		
		private var pdfPageSpaceBottom:Number = 10;
		private var pdfPageSpaceTop:Number = 10;
		
		public var pdfContainer:MovieClip = new MovieClip;
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
		private var viewer:Viewer;
		
		private var annotationsInsert:Array = new Array();
		public var loadedAnnotations:Boolean = false;
		
		private var SWFData:URLLoader;
		
		private var pageTimeoutTimer:Timer = new Timer(2000);
		private var retries:Number = 0;
		
		
		// CRAIGS VARIABLES
		private var pageLoader:Loader;
		private var pageNumberBeingLoaded:Number = 1; // The page of the pdf we are currently loading. Starts at 1
		private var textSnapshotArray:Array = new Array(); // Stores the text snapshot for each page we have. We need to store the text
															// snapshots otherwise they get garbage collected and the highlighting
															// will disappear. This is a bug.
		private var pageHeight:Number = 0;
		private var pageWidth:Number = 0;
		private var pdfPageHeightWithSpace:Number = 0; // The number of pixels in height for the current pdf page + the spacer
		private var startTextIndex:Number; // The index of what point in the document we are starting highlighting (e.g. character 112)
		private var endTextIndex:Number; // The index of what point in the document we are finishing highlighting (e.g. character 120)
		private var selectionPage:Number; // The page where the selection starts
		private var pageArray:Array = new Array(); // An array of all the pages in the pdf
		
		public function PDF(sourceURL:String) {
			super();
			// we need to strip out the %
			var newURL:String = sourceURL.substr(0, sourceURL.indexOf("%"));
			trace("new PDF URL is", newURL);
			this.swfURL = newURL;
			this.addChild(pdfContainer);
			loadSWF();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, unloadPDF);
			this.addEventListener(FlexEvent.HIDE, unloadPDF);
		}
		
		private function unloadPDF(e:Event):void {
			pageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, savePage);
		}
		
		/**
		 * Loads the SWF file from the supplied URL. 
		 * 
		 */		
		private function loadSWF():void {
			pageLoader = new Loader();
			var pageRequest:URLRequest = new URLRequest(this.swfURL + pageNumberBeingLoaded + ".swf");
			pageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				// The loading has progressed. 
//				trace("loading event 2", e.bytesLoaded, e.bytesTotal);
//				dispatchEvent(e);
			});
			pageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				if(pageNumberBeingLoaded == 1) {
					// We couldnt load the first page, probably means its still being transcoded
					Alert.show("This PDF is still being transcoded so we can display it. It will become available shortly.");
					Dispatcher.call('case/' + FileController.caseID + "/" + FileController.roomType);
				} else {
					// There are no more pages to load, so lets stop trying.
					// We've loaded the last page
					trace("FINISHING RENDER");
					
					PDFLoaded = true;
					
					// Add all the pages to the stage
					addPagesToStage();
				}
			});
			// Once the page has loaded, save it.
			pageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, savePage);
			pageLoader.load(pageRequest);
			
//			
//			
//			SWFData = new URLLoader();
//			SWFData.dataFormat = URLLoaderDataFormat.BINARY;
//			
//			SWFData.addEventListener(Event.COMPLETE, loadComplete);
//
//			// Listen for errors (which in most cases, means the PDF is still being converted to a SWF)
//			SWFData.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
//				Alert.show("This PDF is still being transcoded so we can display it. It will become available shortly.");
//				Dispatcher.call('browse');
//			});
//			
//			// Load the SWF
//			SWFData.load(new URLRequest(this.swfURL + "1.swf"));
		}
		
		private function savePage(e:Event):void {
			var page:MovieClip = e.currentTarget.content as MovieClip;
			// Store hte page
			pageArray.push(page);
			
			// Throw an event that shows we are loading pages.
			var pageLoadEvent:IDEvent = new IDEvent(IDEvent.PAGE_LOADED, true);
			pageLoadEvent.data.page = pageNumberBeingLoaded;
			pageLoadEvent.data.totalPages = pageNumberBeingLoaded + 1;
			this.dispatchEvent(pageLoadEvent);
			
			// Use this page to adjust the max height of a pdf page
			pageHeight = Math.max(pageHeight, page.height); 
			pageWidth = Math.max(pageWidth, page.width);
			pdfPageHeightWithSpace = Math.max(pdfPageHeightWithSpace, page.height + pdfPageSpaceBottom); 
			trace("max page Height is", pageHeight, "pdf height per page is", pdfPageHeightWithSpace);
			
			// Load the next page
			pageNumberBeingLoaded++;
			loadSWF();
		}
//			
//		/**
//		 * The SWF for hte pdf has finished downloaded. We saved the SWF as bytes, and then load from this 
//		 * repeatedly to get the individual pages (flash does not allow you to copy the object, always
//		 * pass by reference)
//		 *  
//		 * @param e	The load complet event.
//		 * 
//		 */		
//		private function loadComplete(e:Event):void {
//			SWFLoader = new Loader();
//			SWFLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
//				// The loading has progressed. 
//				trace("loading event 2", e.bytesLoaded, e.bytesTotal);
//				dispatchEvent(e);
//			});
//			
//			SWFLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addPageToStage);
//			SWFLoader.loadBytes(SWFData.data);
//		}
//		
		
		private function addPagesToStage():void {
			var pageLoadEvent:IDEvent = new IDEvent(IDEvent.PAGE_LOADED, true);
			pageLoadEvent.data.page = 1;
			pageLoadEvent.data.totalPages = 1;
			this.dispatchEvent(pageLoadEvent);
			
			for (var i:Number = 0; i < pageArray.length; i++) {
				var page:MovieClip = pageArray[i];
				// Go to page we should be looking at
				//fullPDF.gotoAndStop(pageNumberBeingLoaded);
				page.gotoAndStop(1);
				
				// Position the page on the screen
				//fullPDF.y = pdfPageSpaceTop + ((pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom));
				page.y = i * pdfPageHeightWithSpace;
				trace("page y is ", page.y);
				//			fullPDF.y = (pdfPageSpaceTop * pageNumberBeingLoaded) + ((pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom));
				trace("ading page" + i);
				
				// Add this page
				pdfContainer.addChild(page);
				pdfContainer.graphics.lineStyle(1, 0x999999);
				//			pdfContainer.graphics.drawRect(-1, pdfPageSpaceTop + ((pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom) - 1), fullPDF.width + 2, fullPDF.height + 2)
				pdfContainer.graphics.drawRect(-1, (i * pdfPageHeightWithSpace - 1), page.width + 2, page.height + 2)
				// Add this page's text snapshot to our storage array
				// We need to do this, so that the text snapshot isnt garbage collected (its a bug!)
				textSnapshotArray.push(page.textSnapshot);
				
				// we have added new page, so make sure this (the PDF container) is the right size
				//			this.height = (pageNumberBeingLoaded) * (fullPDF.height + pdfPageSpaceBottom);
				this.height = (i + 1) * pdfPageHeightWithSpace;
				trace("height is", this.height);
				//			this.height = ((pdfPageSpaceTop + 1) * pageNumberBeingLoaded) + ((pageNumberBeingLoaded) * (fullPDF.height + pdfPageSpaceBottom));
				this.width = pageWidth;
			}
			
			// Tell the PDFViewer that the PDF has finished loading
			var myEvent:IDEvent = new IDEvent(IDEvent.MEDIA_LOADED, true);
			dispatchEvent(myEvent);
			totalPages = pageNumberBeingLoaded - 1;	
			
		}
		
//		/**
//		 * Finished reading the SWF's bytes. Load it as a movie clip, go to the page we are up to, and add that
//		 * one to the display. 
//		 * 
//		 * @param e
//		 * 
//		 */		
//		private function addPageToStage(e:Event):void {
//			var fullPDF:MovieClip = e.currentTarget.content as MovieClip;
//			
//			// Throw an event that shows we are loading pages.
//			var pageLoadEvent:IDEvent = new IDEvent(IDEvent.PAGE_LOADED, true);
//			pageLoadEvent.data.page = pageNumberBeingLoaded;
//			pageLoadEvent.data.totalPages = fullPDF.totalFrames;
//			this.dispatchEvent(pageLoadEvent);
//			
//			// Go to page we should be looking at
//			//fullPDF.gotoAndStop(pageNumberBeingLoaded);
//			fullPDF.gotoAndStop(1);
//			
//			// Position the page on the screen
//			//fullPDF.y = pdfPageSpaceTop + ((pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom));
//			fullPDF.y = (pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom);
////			fullPDF.y = (pdfPageSpaceTop * pageNumberBeingLoaded) + ((pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom));
//			trace("ading page" + pageNumberBeingLoaded);
//			
//			// Add this page
//			pdfContainer.addChild(fullPDF);
//			pdfContainer.graphics.lineStyle(1, 0x999999);
////			pdfContainer.graphics.drawRect(-1, pdfPageSpaceTop + ((pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom) - 1), fullPDF.width + 2, fullPDF.height + 2)
//			pdfContainer.graphics.drawRect(-1, ((pageNumberBeingLoaded - 1) * (fullPDF.height + pdfPageSpaceBottom) - 1), fullPDF.width + 2, fullPDF.height + 2)
//			// Add this page's text snapshot to our storage array
//			// We need to do this, so that the text snapshot isnt garbage collected (its a bug!)
//			textSnapshotArray.push(fullPDF.textSnapshot);
//			
//			// we have added new page, so make sure this (the PDF container) is the right size
////			this.height = (pageNumberBeingLoaded) * (fullPDF.height + pdfPageSpaceBottom);
//			this.height = pageNumberBeingLoaded * (fullPDF.height + pdfPageSpaceBottom);
////			this.height = ((pdfPageSpaceTop + 1) * pageNumberBeingLoaded) + ((pageNumberBeingLoaded) * (fullPDF.height + pdfPageSpaceBottom));
//			this.width = fullPDF.width;
//			
//			// Save the PDF height
//			pdfHeight = fullPDF.height + pdfPageSpaceBottom; 
//			
//			
//			pageNumberBeingLoaded++;
//			loadSWF();
//			/*// Have we loaded the last page?
//			if(fullPDF.totalFrames > pageNumberBeingLoaded) {
//				// More pages to load
//				pageNumberBeingLoaded++;
//				
//				var tmpLoader:Loader = new Loader();
//				tmpLoader.loadBytes(SWFData.data);
//				tmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addPageToStage);
//			} else {
//				// We've loaded the last page
//				trace("FINISHING RENDER");
//				
//				PDFLoaded = true;
//				
//				// Tell the PDFViewer that the PDF has finished loading
//				var myEvent:IDEvent = new IDEvent(IDEvent.MEDIA_LOADED, true);
//				this.dispatchEvent(myEvent);
//				totalPages = pdfContainer.numChildren;	
//			}*/
//		}
		
		
		/* =============== ANNOTATION STUFF ============ */
		/**
		 * Highlights or unhighlights text from text indexes (NOTE - DOES NOT NOT WORK MULTIPLE PAGES CURRENTLY, EVEN THOUGH IT CAN TAKE THE ARGUMENTS)
		 * @param page1				The page to start highlighting on (the indexes are per page, not for the whole document, e.g.
		 * 							page 2 + index 10-30, is 10-30 on that page, not 10-30 on the whole document
		 * @param startTextIndex	The index where to start highlighting from on the page
		 * @param finishTextIndex	The index where to finish highlighting
		 * @param highlight			Whether we should highlight or unhighlight
		 * @param page2				TODO add in a highlight over multiple pages (not used currently)
		 * 
		 */		
		public function highlightFromIndexes(page1:Number, startTextIndex:Number, finishTextIndex:Number, highlight:Boolean, page2:Number=0):void {
			var currentSnapshot:TextSnapshot = textSnapshotArray[page1] as TextSnapshot;
			currentSnapshot.setSelectColor(0xfceb6d);
			currentSnapshot.setSelected(startTextIndex, finishTextIndex, highlight);
		}
		
		/**
		 * Highlights text between x,y coordinate pairs.  
		 * @param startX	The X Coordinate of where we started to highlight
		 * @param startY	The Y Coordinate of where we started to highlight
		 * @param finishX	The X coordinate of where we finished highlighting
		 * @param finishY	The Y Coordinate of where we finished highlighting
		 * 
		 */		
		public function highlightFromCoordinates(startX:Number, startY:Number, finishX:Number, finishY:Number):void {
			
			var accuracy:Number = 1;
			
			trace("Highlighting start:", startX, startY, "end:", finishX, finishY);
			
			// We need to know which page we started highlighting on, and which page we finished on
			var startPage:Number = Math.floor(startY / pdfPageHeightWithSpace);
			var finishPage:Number = Math.floor(finishY / pdfPageHeightWithSpace);
			trace("highlight on pages", startPage, finishPage);
			
			if(startPage != finishPage) {
				Alert.show("Annotations cannot span multiple pages");
				return;
			}
			
			this.selectionPage = startPage;
			// Get out the snapshot for hte current page we are on
			var currentSnapshot:TextSnapshot = textSnapshotArray[startPage] as TextSnapshot;
			trace("current snapshot is", currentSnapshot);
			
//			if(startPage == finishPage) {
				// We started and finished highlight on the same page
				
				// Convert the x,y to an index number of hte text
				trace("new x y", startX, startY - (startPage * pdfPageHeightWithSpace));
				var startTextIndex:Number = currentSnapshot.hitTestTextNearPos(startX, startY  - (startPage * pdfPageHeightWithSpace), accuracy);
				var endTextIndex:Number = currentSnapshot.hitTestTextNearPos(finishX, finishY - (startPage * pdfPageHeightWithSpace), accuracy);
				
				trace("indexes", startTextIndex, endTextIndex);
				// Make sure we are highlighting the right way (in case people drag backwards etc)
				if(startTextIndex < endTextIndex) {
					// dragged left to right
					currentSnapshot.setSelected(startTextIndex, endTextIndex + 1, true);
					this.startTextIndex = startTextIndex;
					this.endTextIndex = endTextIndex + 1;
				} else {
					// dragged right to left
					currentSnapshot.setSelected(endTextIndex, startTextIndex + 1, true);
					this.startTextIndex = endTextIndex;
					this.endTextIndex = startTextIndex + 1;
				}	
			
//			} else if (startPage < finishPage) {
//				// We started highlighting on 1 page, and went onto the next
//				trace("highlighting between two different pages");
//				var startTextIndex:Number = currentSnapshot.hitTestTextNearPos(startX, startY - (startPage * pdfHeight), 10);
//				
//				// Highlight from where we started, to the end of the page
//				currentSnapshot.setSelected(startTextIndex, currentSnapshot.charCount, 10);
//				
//				for(var i:Number = startPage + 1; i < finishPage; i++) {
//					var currentSnapshot:TextSnapshot = textSnapshotArray[finishPage] as TextSnapshot;
//					currentSnapshot.setSelected(0, currentSnapshot.charCount, 10);
//				}
//				// Get out the snapshot for hte current page we are on
//				var currentSnapshot:TextSnapshot = textSnapshotArray[finishPage] as TextSnapshot;
//				
//				var endTextIndex:Number = currentSnapshot.hitTestTextNearPos(finishX, finishY - (finishPage * pdfHeight), 10);
//				currentSnapshot.setSelected(0, endTextIndex, 10);
//				
//				// Get the finish coordatines
////				var endTextIndex:Number = currentSnapshot.hitTestTextNearPos(finishX, finishY, 
//			} else if (startPage > finishPage) {
//				// We started highlighting on 1 page, and went onto the next
//				trace("highlighting between two different pages");
//				var endTextIndex:Number = currentSnapshot.hitTestTextNearPos(startX, startY - (startPage * pdfHeight), 10);
//				currentSnapshot.setSelected(0, endTextIndex, 10);
//				
//				for(var i:Number = startPage - 1; i > finishPage; i--) {
//					var currentSnapshot:TextSnapshot = textSnapshotArray[finishPage] as TextSnapshot;
//					currentSnapshot.setSelected(0, currentSnapshot.charCount, 10);
//				}
//				// Get out the snapshot for hte current page we are on
//				var currentSnapshot:TextSnapshot = textSnapshotArray[finishPage] as TextSnapshot;
//				
//				var startTextIndex:Number = currentSnapshot.hitTestTextNearPos(finishX, finishY - (finishPage * pdfHeight), 10);
//				
//				// Highlight from where we started, to the end of the page
//				currentSnapshot.setSelected(startTextIndex, currentSnapshot.charCount, 10);
//				
//			}
			
			
		}
		
		public function clearHighlight():void {
			trace("clearing highlighting");
			for(var i:Number = 0; i < textSnapshotArray.length; i++) {
				var currentSnapshot:TextSnapshot = textSnapshotArray[i] as TextSnapshot;
				currentSnapshot.setSelected(0, currentSnapshot.charCount, false);
			}
			
			this.startTextIndex = -1;
			this.endTextIndex = -1;
		}
		
		/**
		 * Searches for text in the PDF document and highlights all occurences of the text. 
		 * @param text The text to search for
		 * @return An array of y positions in the PDF document for the beginning of each matched string
		 * 
		 */		
		public function searchForText(text:String):Array {
			trace("Searching for text", text);
			clearHighlight();
			
			var yPositionsForMatches:Array = new Array();
			
			for(var page:Number = 0; page < textSnapshotArray.length; page++) {
				var currentSnapshot:TextSnapshot = textSnapshotArray[page] as TextSnapshot;
				//trace("looking at page", i);
				// Start looking from index 0
				var index:Number = 0;
				//trace("index is", index, "charcount is", currentSnapshot.charCount);
				// If we havent reached the end of this page, keep looking
				while(index <= currentSnapshot.charCount) {
					var foundIndex:Number = currentSnapshot.findText(index, text, false);
					if(foundIndex != -1) {
						// We found some text
						currentSnapshot.setSelected(foundIndex, foundIndex + text.length, true);
						index += foundIndex + text.length;
						
						var matchInfoForFirstLetter:Object = currentSnapshot.getTextRunInfo(foundIndex, foundIndex + text.length)[0];
						var firstLetterYPosInPage:Number = matchInfoForFirstLetter.matrix_ty;
						var firstLetterXPosInPage:Number = matchInfoForFirstLetter.matrix_tx;
						// Now work out the y position in the entire document (and save that)
						yPositionsForMatches.push(firstLetterYPosInPage + (page * pdfPageHeightWithSpace));
						
					} else {
//						trace("No match found, going to next page");
						break;
					}
				}
			}
			return yPositionsForMatches;
		}
		/**
		 * Gets the height of the pages in the document 
		 * @return 
		 * 
		 */		
		public function getPageHeight():Number {
			return pdfPageHeightWithSpace;
		}
		/**
		 * Gets the start index for the current text highlighted by the user 
		 * @return The start index
		 * 
		 */		
		public function getStartTextIndex():Number {
			return this.startTextIndex;
		}
		
		/**
		 * Gets the end index for the current text highlighted by the user 
		 * @return The end index
		 * 
		 */		
		public function getEndTextIndex():Number {
			return this.endTextIndex;
		}
		
		/**
		 * Gets the page for the current highlighted text by hte user 
		 * @return The page number
		 * 
		 */		
		public function getSelectionPage():Number {
			return this.selectionPage;
		} 
		
		/**
		 * Gets the text that the user selected 
		 * @return 
		 * 
		 */		
		public function getSelectedText():String {
			return (textSnapshotArray[selectionPage] as TextSnapshot).getText(startTextIndex, endTextIndex);
		}	
	}
}