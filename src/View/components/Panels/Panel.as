package View.components.Panels
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.core.UIComponent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	import View.components.PanelElement;
	import View.components.SubToolbar;
	import View.components.Toolbar;
	
	public class Panel extends BorderContainer
	{
		protected var myScroller:Scroller; // Adds scrollbars
		protected var content:VGroup; 	// Where all the panels content sits
										// Its protected so the sub-classes can add/remove
										// from it easily
		
		protected var toolbar:Toolbar; 	// The toolbar at the top of the panel
										// Protected so subclasses can use it easily
		protected var subToolbar:SubToolbar; // The subtoolbar is displayed under the regular toolbar
											// It can be used for notifications and can also have buttons
		
		private var heading:Label; // The heading at the top of the panel
		
		private var searchInput:TextInput; // The search input text box for the panel
				
		protected const PLACEHOLDERTEXT:String = "Search";
		public static const DEFAULT_WIDTH:Number = 300; // The width of side panels e.g. sharing, comments etc
		public static const EXPANDED_WIDTH:Number = 500;
		
		protected var modifyAccess:Boolean = false;
		
		/**
		 * A Panel sits on the right side of the Browser view.
		 * 
		 * Contains a Scroller, which has a group, where the comments live.
		 */		
		public function Panel()
		{
			super();
			
			// Setup the height
			this.percentHeight = 100;
			
			// Setup the layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Set the backgrond colour & border collect
			this.backgroundFill = new SolidColor(0xFFFFFF);
			this.setStyle("borderVisible", false);
//			this.borderStroke = new SolidColorStroke(0xAAAAAA,1,1);
			
			// Add the Toolbar at the top of the panel
			toolbar = new Toolbar();
			this.addElement(toolbar);
			
			// Add The panel heading
			heading = new Label();
			heading.text = "";
			heading.setStyle('fontWeight', 'bold');
			heading.setStyle('textAlign', 'left');
			heading.setStyle('color', 0x999999);
			heading.setStyle('fontSize', 16);
			heading.percentWidth = 100;
			toolbar.addElement(heading);
			
			var searchToolbar:SubToolbar = new SubToolbar();
			searchToolbar.setStyle("resizeEffect", null);
			searchToolbar.setColor(SubToolbar.GREY);
			this.addElement(searchToolbar);
			// Add the search input;
			searchInput = new TextInput();
			searchInput.text = "Search";
			searchInput.percentWidth = 100;
			searchInput.percentHeight = 100;
			searchToolbar.addElement(searchInput);
			
			
			subToolbar = new SubToolbar();
			subToolbar.height = 0;
			subToolbar.visible = false;
			this.addElement(subToolbar);
			
			// lets add a scroller, so it...scrolls lol
			myScroller = new Scroller();
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
		
			// create a content group so we can put it inside the scroll
			content = new VGroup();
			content.gap = 0;
			
			// Add the content group to the scroller
			myScroller.viewport = content;
			
			// Add the scroller to the panel
			this.addElement(myScroller);
			
			// Listen for search input focus/lost focus
			searchInput.addEventListener(FocusEvent.FOCUS_IN, searchInputHasFocus);
			searchInput.addEventListener(FocusEvent.FOCUS_OUT, searchInputHasLostFocus);
			
			// Listen for Text Input
			searchInput.addEventListener(Event.CHANGE, searchTermEntered);
		}
		
		protected function addPanelItem(item:UIComponent):void {
			item.enabled = modifyAccess;
			content.addElement(item);
		}
		
		protected function addPanelItemAtIndex(item:UIComponent, index:Number):void {
			item.enabled = modifyAccess;
			content.addElementAt(item, index);
		}
		
		/**
		 * Sets the heading of the panel
		 * @param heading
		 * 
		 */		
		protected function setHeading(heading:String):void {
			this.heading.text = heading;
		}
		
		private function searchInputHasFocus(e:FocusEvent):void {
			if(searchInput.text == PLACEHOLDERTEXT) {
				searchInput.text = "";
			}
		}
		
		private function searchInputHasLostFocus(e:FocusEvent):void {
			if(searchInput.text == "") {
				searchInput.text = PLACEHOLDERTEXT;
			}
		}
		
		/**
		 * Called when search term is etnered. Passed to @see AssetBrowser 
		 * @param e
		 * 
		 */		
		private function searchTermEntered(e:Event):void {
			trace('Searching for: ', (e.target as TextInput).text);
			for(var i:Number = 0; i < content.numElements; i++) {
				var element:PanelElement = content.getElementAt(i) as PanelElement;
				if(!element.searchMatches((e.target as TextInput).text)) {
					content.getElementAt(i).visible = false;
					content.getElementAt(i).includeInLayout = false;
				} else {
					content.getElementAt(i).visible = true;
					content.getElementAt(i).includeInLayout = true;
				}
			}
		}
		
		public function setUserAccess(modify:Boolean):void {
			modifyAccess = modify;
			
			for(var i:Number = 0; i < content.numElements; i++) {
				var element:UIComponent = content.getElementAt(i) as UIComponent;
				element.enabled = modifyAccess;
			}
		}
		
	}
}