package View.components.MediaViewer
{
	import Lib.it.transitions.Tweener;
	
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

	public class PDFViewer extends Viewer
	{
		private var searchInput:TextInput; // The search box
		
		public function PDFViewer(mediaType:String)
		{
			super(mediaType);
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
			//resizeSlider.liveDragging = true;
			//			slider.snapInterval = 1;
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
			
			searchInput = new TextInput();
			searchInput.text = "Search";
			searchInput.width = 100;
			searchInput.percentHeight = 100;
			sliderResizerContainer.addElement(searchInput);
			
			
			resizeSlider.addEventListener(Event.CHANGE, resizeImage);
			fitWidthButton.addEventListener(MouseEvent.CLICK, fitWidthButtonClicked);
			fitPageButton.addEventListener(MouseEvent.CLICK, fitPageButtonClicked);
			nextPageButton.addEventListener(MouseEvent.CLICK, nextPageButtonClicked);
			prevPageButton.addEventListener(MouseEvent.CLICK, prevPageButtonClicked);
			
			// Listen for search input focus/lost focus
			searchInput.addEventListener(FocusEvent.FOCUS_IN, searchInputHasFocus);
			searchInput.addEventListener(FocusEvent.FOCUS_OUT, searchInputHasLostFocus);
			
			// Listen for Text Input
			searchInput.addEventListener(Event.CHANGE, searchTermEntered);
			
		}
		
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
			trace('Searching for: ', (e.target as TextInput).text);
			var yPosOfFirstMatch:Number = media.searchForText((e.target as TextInput).text);
			if(yPosOfFirstMatch != -1) {
				trace("Match found");
				myScroller.verticalScrollBar.value = (yPosOfFirstMatch - 30) * media.scaleY;
			} else {
				trace("No match found");
			}
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
			media.scaleX = resizeFactor;
			media.scaleY = resizeFactor; 
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
			media.scaleX = (scrollerAndOverlayGroup.width - scrollbarWidth) / media.width;
			media.scaleY = (scrollerAndOverlayGroup.width - scrollbarWidth) / media.width;
			resizeSlider.value = (scrollerAndOverlayGroup.width - 30) / media.width * 100;
			
			// Go back to the page we were on
			this.gotoPage(currentPageBeforeResize);
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
			media.scaleX = scrollerAndOverlayGroup.height / media.getFitHeightSize();
			media.scaleY = scrollerAndOverlayGroup.height / media.getFitHeightSize();
			resizeSlider.value = scrollerAndOverlayGroup.height / media.getFitHeightSize() * 100;

			// Go back to the page we were on
			this.gotoPage(currentPageBeforeResize);
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
			myScroller.verticalScrollBar.value = page * media.getFitHeightSize() * media.scaleY - (borderThickness * media.scaleY);
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