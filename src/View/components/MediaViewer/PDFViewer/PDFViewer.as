package View.components.MediaViewer.PDFViewer
{
	import Lib.it.transitions.Tweener;
	
	import View.components.IDButton;
	import View.components.IDGUI;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Text;
	
	import spark.components.Button;
	import spark.components.HSlider;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.primitives.Line;
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	import View.components.MediaViewer.SpaceViewer;

	public class PDFViewer extends SpaceViewer
	{
		// GUI
		private var searchInput:TextInput; // The search box
		private var prevSearchResultButton:IDButton; // Button to go to previous search result
		private var nextSearchResultButton:IDButton; // Button to go to next search result
		
		// Variables
		private var searchResultYCoors:Array; // Stores the Y value for all of the 
		private var selectedSearchResult:Number; // The current number of the search result we are looking at
												// 0 <= selectedSearchResult < searchResultYCoors.length
		private var searchResultLabel:Label; 
		
		public function PDFViewer()
		{
			super(MediaAndAnnotationHolder.MEDIA_PDF);
		}
		
		override protected function makeMedia():MediaAndAnnotationHolder {
			return new MediaAndAnnotationHolder(mediaType);
		}
		
		override protected function makeBottomToolbar():void {
			var zoomOutLabel:Label = new Label();
			zoomOutLabel.text = "Zoom Out";
			sliderResizerContainer.addElement(zoomOutLabel);
			
			// Create the slider/resizer
			resizeSlider = new HSlider();
			resizeSlider.maximum = 200;
			resizeSlider.minimum = 10;
			resizeSlider.value = 100;
			sliderResizerContainer.addElement(resizeSlider);
			this.addElement(sliderResizerContainer);
			
			var zoomInLabel:Label = new Label();
			zoomInLabel.text = 'Zoom In';
			sliderResizerContainer.addElement(zoomInLabel);
			
			
			// Add 'Fit' button for the zoom
			var fitPageButton:Button = IDGUI.makeButton('Fit Page');
			sliderResizerContainer.addElement(fitPageButton);
			
			// Add '100%' button for the zoom
			var fitWidthButton:Button = IDGUI.makeButton('Fit Width');
			sliderResizerContainer.addElement(fitWidthButton);
			
			var pageControlLine:Line = IDGUI.makeLine(0xBBBBBB);
			sliderResizerContainer.addElement(pageControlLine);
			
			var prevPageButton:Button = IDGUI.makeButton("Prev Page");
			sliderResizerContainer.addElement(prevPageButton);
			
			var nextPageButton:Button = IDGUI.makeButton("Next Page");
			sliderResizerContainer.addElement(nextPageButton);
			
			var searchLine:Line = IDGUI.makeLine(0xBBBBBB);
			sliderResizerContainer.addElement(searchLine);
			
			searchInput = new TextInput();
			searchInput.text = "Search";
			searchInput.width = 150;
			searchInput.percentHeight = 100;
			sliderResizerContainer.addElement(searchInput);
			
			prevSearchResultButton = IDGUI.makeButton("«", false, false);
			prevSearchResultButton.width = 30;
			sliderResizerContainer.addElement(prevSearchResultButton);
			
			nextSearchResultButton = IDGUI.makeButton("»", false, false);
			nextSearchResultButton.width = 30;
			sliderResizerContainer.addElement(nextSearchResultButton);
			
			searchResultLabel = new Label();
			sliderResizerContainer.addElement(searchResultLabel);
			
			resizeSlider.addEventListener(Event.CHANGE, resizeImage);
			fitWidthButton.addEventListener(MouseEvent.CLICK, fitWidthButtonClicked);
			fitPageButton.addEventListener(MouseEvent.CLICK, fitPageButtonClicked);
			nextPageButton.addEventListener(MouseEvent.CLICK, nextPageButtonClicked);
			prevPageButton.addEventListener(MouseEvent.CLICK, prevPageButtonClicked);
			prevSearchResultButton.addEventListener(MouseEvent.CLICK, prevSearchResultButtonClicked);
			nextSearchResultButton.addEventListener(MouseEvent.CLICK, nextSearchResultButtonClicked);
			
			
			// Listen for search input focus/lost focus
			searchInput.addEventListener(FocusEvent.FOCUS_IN, searchInputHasFocus);
			searchInput.addEventListener(FocusEvent.FOCUS_OUT, searchInputHasLostFocus);
			
			// Listen for Text Input
			searchInput.addEventListener(Event.CHANGE, searchTermEntered);
			
		}
		
		
		/* ================== SEARCH FUNCTIONALITY ================================= */
		private function searchInputHasFocus(e:FocusEvent):void {
			if(searchInput.text == "Search") {
				searchInput.text = "";
			}
		}
		
		private function searchInputHasLostFocus(e:FocusEvent):void {
			if(searchInput.text == "") {
				searchInput.text = "Search";
			}
		}
		
		/**
		 * Called when search term is etnered. Passed to @see AssetBrowser 
		 * @param e
		 * 
		 */		
		private function searchTermEntered(e:Event):void {
			var searchBox:TextInput = e.target as TextInput;
			var searchString:String = (e.target as TextInput).text;
			
			if(searchString == "") {
				// No text entered, set the background/border back to normal
				searchBox.setStyle('borderColor', 0x888888);
				searchBox.setStyle('contentBackgroundColor', 0xFFFFFF);
				// Clear all text highlighting
				media.searchForText("");
				
				searchResultLabel.text = "";
				
				nextSearchResultButton.hide();
				prevSearchResultButton.hide();
				return;	
			}
			
			trace('Searching for: ', (e.target as TextInput).text);
			this.searchResultYCoors = media.searchForText(searchString);
			
			if(searchResultYCoors.length) {
				trace("Match found");
				
				selectedSearchResult = 0;
				
				searchResultLabel.text = "(" + (selectedSearchResult+1) + "/" + searchResultYCoors.length + ")";
				
				// Show the next buttons if there is more than 1 result (no prev, since we are at the first result)
				if(searchResultYCoors.length > 1) {
					nextSearchResultButton.show();
					prevSearchResultButton.show();
				} else {
					nextSearchResultButton.hide();
					prevSearchResultButton.hide();
				}
				
				scrollToSearchResult(selectedSearchResult);
				
				// Make the search boxes background white (in case it was red from not matching)
				searchBox.setStyle('borderColor', 0x888888);
				searchBox.setStyle('contentBackgroundColor', 0xFFFFFF);
				
			} else {
				trace("No match found");
				// Make the search boxes background red (since there was no match)
				searchBox.setStyle('borderColor', 0xFF0000);
				searchBox.setStyle('contentBackgroundColor', 0xFFBBBB);
				searchResultLabel.text = "";
				nextSearchResultButton.hide();
				prevSearchResultButton.hide();
			}
		}
		
		private function scrollToSearchResult(number:Number):void {
			// Work out where to scroll to
			var spacer:Number = 30; // the distance above the text to top (so there is a space above it when the scrolling stops)
			var xCoor:Number = myScroller.horizontalScrollBar.value;
			var yCoor:Number = searchResultYCoors[number] - spacer; // THe scale is facotred in by scrolToPoint
			scrollToPoint(xCoor, yCoor);
			
			searchResultLabel.text = "(" + (number+1) + "/" + searchResultYCoors.length + ")";
		}
		
		private function nextSearchResultButtonClicked(e:MouseEvent):void {
			scrollToSearchResult(++selectedSearchResult % searchResultYCoors.length);
		}	
		private function prevSearchResultButtonClicked(e:MouseEvent):void {
			scrollToSearchResult(--selectedSearchResult % searchResultYCoors.length);
		}
		
		/**
		 * Resizes the image when the slider is moved 
		 * @param e	The slider change event
		 * 
		 */		
		private function resizeImage(e:Event):void {
			trace("resizing", (e.target as HSlider).value);
			// Get the current position of the scrollbar as a percent
			var resizeFactor:Number = (e.target as HSlider).value / 100; 
			
			// Resize the image by the scaling facotr
			scaleMedia(resizeFactor, resizeFactor);
		}
		
		/**
		 * The resize to 100% button was clicked. Resize the image to
		 * its actual size. 
		 * @param e
		 * 
		 */		
		private function fitWidthButtonClicked(e:MouseEvent):void {
			trace("100% button clicked");
			
			// We need to save the current page, because resizing screws up what page we are on
			var currentPageBeforeResize:Number = this.getCurrentPage();
			
			var scrollbarWidth:Number = 30; // Im just guessing how big the scrollbars are
			var scaleX:Number = (scrollerAndOverlayGroup.width - scrollbarWidth) / media.width;
			var scaleY:Number = (scrollerAndOverlayGroup.width - scrollbarWidth) / media.width;
			
			// Resizes the media (using a nice tween animation)
			scaleMedia(scaleX, scaleY);
			
			resizeSlider.value = (scrollerAndOverlayGroup.width - 30) / media.width * 100;
		}
		
		/**
		 * The resize to fit the width of the screen button was clicked 
		 * @param e
		 * 
		 */		
		private function fitPageButtonClicked(e:MouseEvent):void {
			trace("Fit button clicked");
			// We need to save the current page, because resizing screws up what page we are on
			var currentPageBeforeResize:Number = this.getCurrentPage();
			
			
			// for PDF resizing,
			// Fit button - fits 1 page
			var scaleX:Number = scrollerAndOverlayGroup.height / media.getFitHeightSize();
			var scaleY:Number = scrollerAndOverlayGroup.height / media.getFitHeightSize();
			scaleMedia(scaleX, scaleY);
			
			resizeSlider.value = scrollerAndOverlayGroup.height / media.getFitHeightSize() * 100;
		}
		
		private function getCurrentPage():Number {
			trace("Page is", myScroller.verticalScrollBar.value/media.scaleY / media.getFitHeightSize());
			
			// The thickness of the grey border around our pages
			var borderThickness:Number = 1;
			// Because there are graphic errors, we want to make sure anything more than 0.99 we round up, and anything else,
			// we want to round down
			// so we need to get out the decimals
			var decimals:Number = (myScroller.verticalScrollBar.value / media.scaleY / media.getFitHeightSize()) - Math.floor(myScroller.verticalScrollBar.value / media.scaleY / media.getFitHeightSize());
			// and see if they are 0.99+
			if(decimals > 0.98) {
				// Fixes graphical errors, and rounds us up to the next page, when we are oh so close!
				// The Math.max part is so...when we are at the first page, and we are - 1 off for the 1px solid border
				// It pushes it back up to 0 (not -1)
				var currentPage:Number = Math.max(Math.ceil((myScroller.verticalScrollBar.value - (borderThickness * media.scaleY)) / media.scaleY / media.getFitHeightSize()), 0);
			} else {
				// They arent 0.99+ so we want to floor it (so it does the page we are on, and goes to the previous/next)
				currentPage = Math.max(Math.floor((myScroller.verticalScrollBar.value - (borderThickness * media.scaleY)) / media.scaleY / media.getFitHeightSize()), 0);
			}
			return currentPage;

		}
		
		private function gotoPage(page:Number):void {
			// The thickness of the grey border around the pdf pages
			var borderThickness:Number = 1;
			//myScroller.verticalScrollBar.value = page * media.getFitHeightSize() * media.scaleY - (borderThickness * media.scaleY);
			
			var xCoor:Number = myScroller.horizontalScrollBar.value;
			var yCoor:Number = page * media.getFitHeightSize() - borderThickness; // THe scale is facotred in by scrolToPoint 
			
//			myScroller.verticalScrollBar.value = page * media.getFitHeightSize() * media.scaleY - (borderThickness * media.scaleY);
//			myScroller.verticalScrollBar.value = (page * media.getFitHeightSize() - borderThickness) * media.scaleY;
			scrollToPoint(xCoor, yCoor);
		}
		
		private function prevPageButtonClicked(e:MouseEvent):void {
			var prevPage:Number = this.getCurrentPage() - 1;
			this.gotoPage(prevPage);
		}
		
		
		private function nextPageButtonClicked(e:MouseEvent):void {
			var nextPage:Number = this.getCurrentPage() + 1;
			this.gotoPage(nextPage);
		}
	}
}