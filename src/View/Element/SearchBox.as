package View.Element {
	import Controller.RecensioEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	
	import spark.components.TextInput;
	
	public class SearchBox extends RecensioUIComponent {
		
		private var searchbox:TextInput = new TextInput();
		private var padding:Number = 5;
		private var searchMe:Button = new Button();
		private var searchAll:Button = new Button();
		private var searchBoxWidth:Number = 150;
		private var searchMeWidth:Number = 120;
		private var searchAllWidth:Number = 80;
		private var searchboxHeight:Number = 30;
		// Shows the buttons for the search
		private var showButtons:Boolean = false;
		
		public function SearchBox() {
			setup();
			super();
		}
		
		// Gets the search term
		public function getSearchTerm():String {
			return searchbox.text;
		}
		
		// Clears the search term
		public function clearSearch():void {
			searchbox.text = "";
			searchBoxChanged(new Event(Event.CLEAR));
		}
		
		// Gets the full width of the search box
		public function getFullWidth():Number {
			if(showButtons) {
				return searchBoxWidth+searchMeWidth+searchAllWidth+padding*3;
			} else {
				return searchBoxWidth+padding;
			}
		}
		
		// Sets up the search box interface
		private function setup():void {
			this.y = padding;
			this.x = padding;
			searchbox.width = searchBoxWidth;
			searchbox.height = searchboxHeight;
			searchbox.setStyle("borderColor","0x999999");
			this.addChild(searchbox);
			searchbox.addEventListener(Event.CHANGE,searchBoxChanged);
			searchMe.x = searchbox.width+padding;
			searchMe.width = searchMeWidth;
			searchMe.height = searchboxHeight;
			searchMe.label = "Search My Stuff";
			searchMe.setStyle("fontFamily","Helvetica");
			searchMe.setStyle("fontWeight","bold");
			searchMe.setStyle("color","0x333333");
			if(showButtons) {
				addChild(searchMe);
			}
			searchMe.addEventListener(MouseEvent.MOUSE_UP,searchMeClicked);
			searchAll.x = searchbox.width + searchMe.width+padding*2;
			searchAll.width = searchAllWidth;
			searchAll.height = searchboxHeight;
			searchAll.label = "Search All";
			searchAll.setStyle("fontFamily","Helvetica");
			searchAll.setStyle("fontWeight","bold");
			searchAll.setStyle("color","0x333333");
			if(showButtons) {
				addChild(searchAll);
			}
			searchAll.addEventListener(MouseEvent.MOUSE_UP,searchAllClicked);
		}
		
		// Called when "search me is clicked" (currently disabled)
		private function searchMeClicked(e:MouseEvent):void {
			var searchEvent:RecensioEvent = new RecensioEvent(RecensioEvent.SEARCH);
			searchEvent.data.searchType = "me";
			searchEvent.data.query = getSearchTerm();
			this.dispatchEvent(searchEvent);
		}
		
		// Called anytime the search box changes (live search)
		private function searchBoxChanged(e:Event):void {
			var searchEvent:RecensioEvent = new RecensioEvent(RecensioEvent.LIVE_SEARCH);
			searchEvent.data.searchType = "me";
			searchEvent.data.query = getSearchTerm();
			this.dispatchEvent(searchEvent);
		}
		
		// Called when "search all is clicked" (currently disabled)
		private function searchAllClicked(e:MouseEvent):void {
			var searchEvent:RecensioEvent = new RecensioEvent(RecensioEvent.SEARCH);
			searchEvent.data.searchType = "all";
			searchEvent.data.query = getSearchTerm();
			this.dispatchEvent(searchEvent);
		}
	}
}