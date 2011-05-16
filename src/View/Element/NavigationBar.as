package View.Element {
	import Controller.RecensioEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import spark.components.TextInput;

	public class NavigationBar extends RecensioUIComponent {
	
		private var defaultHeight:Number = 40;
		private var defaultAssetPreviewWidth:Number = 250;
		
		private var leftButtons:Array = new Array();
		private var rightButtons:Array = new Array();
		private var background:Sprite = new Sprite();
		private var buttonHolder:Sprite = new Sprite();
		private var searchBox:SearchBox = new SearchBox();
		private var assetResizer:AssetResizer = new AssetResizer();
		private var heading:TextField = new TextField();
		public var overwriteSelection:Boolean = false;
		private var widthSet:Boolean = false;
		
		public function NavigationBar() {
			super();
			addChild(background);
			this.height = defaultHeight;
		}
		
		// Clears the text input of the search box
		public function clearSearch():void {
			searchBox.clearSearch();
		}
		
		// Adds the search box to the navigation bar
		public function addSearchBox():void {
			addChild(searchBox);
			searchBox.toolTip = "Filter media based on search terms";
			searchBox.addEventListener(Event.ADDED_TO_STAGE,searchboxadded);
			searchBox.addEventListener(RecensioEvent.SEARCH,searchboxclicked);
			searchBox.addEventListener(RecensioEvent.LIVE_SEARCH,searchboxchanged);
		}
		
		// Adds the asset preview resize scroller to the navigation bar
		public function addResizer():void {
			addChild(assetResizer);
			assetResizer.toolTip = "Change the size of the media previews";
			assetResizer.setSize(defaultAssetPreviewWidth);
			AssetPreview.assetWidth = defaultAssetPreviewWidth;
			assetResizer.addEventListener(RecensioEvent.ASSET_RESIZER,assetPreviewResize);
		}
		
		// Adds the heading to the navigation bar
		public function addHeading(headingName:String):void {
			heading.text = headingName;
			heading.selectable = false;
			heading.embedFonts = true;
			heading.antiAliasType = AntiAliasType.ADVANCED;
			heading.width = 400;
			//heading.x = 5;
			heading.x = 100;
			heading.y = 3;
			var headingFormat:TextFormat = new TextFormat();
			headingFormat.font = "HelveticaBold";
			headingFormat.size = 24;
			headingFormat.color = 0x333333;
			heading.defaultTextFormat = headingFormat;
			heading.setTextFormat(headingFormat);
			addChild(heading);
		}
		
		// Sets the text heading of the navigation bar
		public function setHeading(headingName:String):void {
			heading.text = headingName;
		}
		
		// Changes the background of a specific button
		public function setButtonColour(buttonName:String,colour:String):void {
			for(var i:Number=0; i<leftButtons.length; i++) {
				if((leftButtons[i] as NavigationBarButton).getText() == buttonName) {
					(leftButtons[i] as NavigationBarButton).setColour(colour);
				}
			}
			for(var j:Number=0; j<rightButtons.length; j++) {
				if((rightButtons[j] as NavigationBarButton).getText() == buttonName) {
					(rightButtons[j] as NavigationBarButton).setColour(colour);
				}
			}
		}
		
		// Changes a specific button name
		public function changeButtonName(buttonName:String,newButtonName:String):void {
			for(var i:Number=0; i<leftButtons.length; i++) {
				if((leftButtons[i] as NavigationBarButton).getText() == buttonName) {
					(leftButtons[i] as NavigationBarButton).setButtonName(newButtonName);
				}
			}
			for(var j:Number=0; j<rightButtons.length; j++) {
				if((rightButtons[j] as NavigationBarButton).getText() == buttonName) {
					(rightButtons[j] as NavigationBarButton).setButtonName(newButtonName);
				}
			}
		}
		
		// Called when the search box button is clicked
		private function searchboxclicked(e:RecensioEvent):void {
			var searchEvent:RecensioEvent = new RecensioEvent(RecensioEvent.SEARCH);
			searchEvent.data.searchType = e.data.searchType;
			searchEvent.data.query = e.data.query;
			this.dispatchEvent(searchEvent);
		}
		
		// Called when the search box input changes
		private function searchboxchanged(e:RecensioEvent):void {
			var searchEvent:RecensioEvent = new RecensioEvent(RecensioEvent.LIVE_SEARCH);
			searchEvent.data.searchType = e.data.searchType;
			searchEvent.data.query = e.data.query;
			this.dispatchEvent(searchEvent);
		}
		
		// Called when the asset resize slider is interacted with
		private function assetPreviewResize(e:RecensioEvent):void {
			var sliderChangedEvent:RecensioEvent = new RecensioEvent(RecensioEvent.ASSET_RESIZER);
			sliderChangedEvent.data.value = e.data.value;
			this.dispatchEvent(sliderChangedEvent);
		}
		
		// Adds a new button (and sets it position and curved corners)
		public function addButton(buttonName:String,position:String="left",round:Boolean=false):void {
			round = false;
			var tmpButton:NavigationBarButton = new NavigationBarButton(buttonName,position,round);
			tmpButton.addEventListener(MouseEvent.MOUSE_UP,navButtonClicked);
			switch(position) {
				case 'left':
					leftButtons.push(tmpButton);
					break;
				case 'right':
					rightButtons.push(tmpButton);
					break;
			}
			addChild(tmpButton);
		}
		
		// Removes a specific button by name
		public function removeButton(buttonName:String):void {
			var button:NavigationBarButton;
			for(var i:Number=0; i<leftButtons.length; i++) {
				if((leftButtons[i] as NavigationBarButton).getText() == buttonName) {
					button = (leftButtons[i] as NavigationBarButton);
					break;
				}
			}
			for(var j:Number=0; j<rightButtons.length; j++) {
				if((rightButtons[j] as NavigationBarButton).getText() == buttonName) {
					button = (rightButtons[j] as NavigationBarButton);
					break;
				}
			}
			if(button.hasEventListener(MouseEvent.MOUSE_UP)) {
				button.removeEventListener(MouseEvent.MOUSE_UP,navButtonClicked);
			}
			if(leftButtons.indexOf(button) > -1) {
				leftButtons.splice(leftButtons.indexOf(button),1);
			}
			if(rightButtons.indexOf(button) > -1) {
				rightButtons.splice(rightButtons.indexOf(button),1);
			}
			if(contains(button)) {
				removeChild(button);
			}
			flash.utils.setTimeout(refresh,100);
			flash.utils.setTimeout(refresh,150);
		}
		
		// Force redraw
		private function refresh():void {
			this.stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		// Sets the default button to be selected
		public function defaultSelect(buttonName:String):void {
			for(var i:Number=0; i<leftButtons.length; i++) {
				if((leftButtons[i] as NavigationBarButton).getText() == buttonName) {
					selectButton((leftButtons[i] as NavigationBarButton));
				}
			}
			for(var j:Number=0; j<rightButtons.length; j++) {
				if((rightButtons[j] as NavigationBarButton).getText() == buttonName) {
					selectButton((rightButtons[j] as NavigationBarButton));
				}
			}
		}
		
		// Called when a button on the navigation bar is clicked
		private function navButtonClicked(e:MouseEvent):void {
			var selectedButton:NavigationBarButton = (e.target as NavigationBarButton);
			if(!overwriteSelection) {
				selectButton(selectedButton);
			}
			var buttonText:String = selectedButton.getText();
			var navButtonClick:RecensioEvent = new RecensioEvent(RecensioEvent.NAV_CLICKED);
			navButtonClick.data.buttonName = buttonText;
			this.dispatchEvent(navButtonClick);
		}
		
		// Deselects all buttons
		public function deselectButtons():void {
			for each (var button:NavigationBarButton in leftButtons) {
				button.deselect();
			}
			for each (var rightButton:NavigationBarButton in rightButtons) {
				rightButton.deselect();
			}
		}
		
		// Tells a specific button on the navigation bar to deselect (by name)
		public function deselectButtonName(selectedButton:String):void {
			for each (var button:NavigationBarButton in leftButtons) {
				if(button.getText() == selectedButton) {
					button.deselect();
				}
			}
			for each (var rightButton:NavigationBarButton in rightButtons) {
				if(rightButton.getText() == selectedButton) {
					rightButton.deselect();
				}
			}
		}
		
		// Tells a specific button on the navigation bar to select (by name) - no deleselection
		public function selectButtonName(selectedButton:String):void {
			for each (var button:NavigationBarButton in leftButtons) {
				if(button.getText() == selectedButton) {
					button.select();
				}
			}
			for each (var rightButton:NavigationBarButton in rightButtons) {
				if(rightButton.getText() == selectedButton) {
					rightButton.select();
				}
			}
		}
		
		// Tells a specific button on the navigation bar to select - with deselection
		private function selectButton(selectedButton:NavigationBarButton):void {
			for each (var button:NavigationBarButton in leftButtons) {
				if(button != selectedButton) {
					button.deselect();
				} else {
					button.select();
				}
			}
			for each (var rightButton:NavigationBarButton in rightButtons) {
				if(rightButton != selectedButton) {
					rightButton.deselect();
				} else {
					rightButton.select();
				}
			}
		}
		
		// Redraw
		override protected function draw():void {
			drawBackground();
			repositionButtons();
		}
		
		// Called when the search box has been added
		private function searchboxadded(e:Event):void {
			setTimeout(draw,100);
		}
		
		// Repositions the buttons on the navigation bar (redraw)
		private function repositionButtons():void {
			var leftx:Number = 0;
			var rightx:Number = this.width;
			if(leftButtons.length > 0) {
				for each (var button:NavigationBarButton in leftButtons) {
					button.x = leftx;
					leftx += button.buttonWidth;
				}
			}
			if(rightButtons.length > 0) {
				for each (var rightButton:NavigationBarButton in rightButtons) {
					rightButton.x = rightx - rightButton.buttonWidth;
					rightx -= rightButton.buttonWidth;
				}
			}
			searchBox.x = this.width-searchBox.getFullWidth();
			assetResizer.x = searchBox.x - assetResizer.defaultWidth;
			heading.width = rightx;
		}
		
		// Redraws the background
		private function drawBackground():void {
			background.graphics.clear();
			background.graphics.lineStyle(1,0xb9b9bb);
			background.graphics.beginFill(0xdddddf,1);
			background.graphics.drawRoundRect(0,0,this.width, this.height, 16);
			
			// Add Second inner white border
			background.graphics.lineStyle(1,0xEEEEEE,1);
			background.graphics.beginFill(0xdddddf,1);
			background.graphics.drawRoundRect(1, 1, this.width - 2, this.height - 2,12);
		}
	}
}