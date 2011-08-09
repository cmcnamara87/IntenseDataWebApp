package View.components.CollectionList
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import Lib.LoadingAnimation.LoadAnim;
	
	import Model.Model_Collection;
	
	import View.Element.Collection;
	import View.components.GoodBorderContainer;
	import View.components.PanelElement;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.effects.Fade;
	import mx.graphics.SolidColor;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Rect;
	
	public class CollectionListItemButton extends GoodBorderContainer implements PanelElement
	{
		private var myLabel:spark.components.Label; // The collection list label
		private const LABEL_CHARACTER_LENGTH:Number = 27; 	// The number of characters of text the label can dsiplay
		// Before it is chopped and '...' is appended.
		private var myIcon:Image;
		private var loaderIcon:LoadAnim;
		private var expanded:Boolean = false; // if the triangle is pointing right or down
		private var triangle:Image;
		/**
		 * Creates a new collection list item for the collection list (in left sidebar)
		 */		
		public function CollectionListItemButton(shared:Boolean, modify:Boolean, isFile:Boolean, fileCount:Number)
		{
			super(0xFFFFFF, 1);
			// Setup the size
			this.percentWidth = 100;
			
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = "middle";
			layout.gap = 3;
			layout.paddingBottom = 10;
			layout.paddingLeft = 10;
			layout.paddingRight = 10;
			layout.paddingTop = 10;
			this.layout = layout;
			
			if(!isFile) {
				// Create drowndown triangle
				triangle = new Image();
				triangle.source = AssetLookup.getTriangleClass();
				triangle.width = 15;
				triangle.height = 15;
				this.addElement(triangle);
				triangle.rotation = -90;
				
				// set up triangle button
				triangle.useHandCursor = true;
				triangle.buttonMode = true;
				triangle.addEventListener(MouseEvent.CLICK, triangleClicked);
			}
			
			var background:GoodBorderContainer = new GoodBorderContainer(0xFFFFFF, 1);
			background.percentWidth = 100;
			this.addElement(background);
			
			
			// Setup the layout
			var layout2:HorizontalLayout = new HorizontalLayout();
			layout2.verticalAlign = "middle";
			layout2.gap = 10;
			background.layout = layout2;

			// List Icon
			myIcon = new Image();
			if(isFile) {
				// File
				if(shared) {
					myIcon.source = AssetLookup.getGenericFileIconSmallOthers();
					
				} else {
					myIcon.source = AssetLookup.getGenericFileIconSmallYours();
				}
				myIcon.width = 11;
				myIcon.height = 15;	
			} else {
				// Discussion
				if(shared) {
					myIcon.source = AssetLookup.getCollectionSharedIconClass();
				} else {
			
					myIcon.source = AssetLookup.getCollectionIconClass();
				}
				myIcon.width = 21;
				myIcon.height = 14;
			}
			
			background.addElement(myIcon);
			
			if(!modify) {
				myIcon.alpha = 0.5;
			}
			
			loaderIcon = new LoadAnim(0x000000);
			loaderIcon.scaleX = 0.85;
			loaderIcon.scaleY = 0.85;
			loaderIcon.visible = false;
			loaderIcon.toolTip = "Grabbing the latest version from the database";
			loaderIcon.includeInLayout = false;
			background.addElement(loaderIcon);
			
			// List Label
			myLabel = new spark.components.Label();
			myLabel.setStyle('fontSize', 12);
			myLabel.percentWidth = 100;
			background.addElement(myLabel);
			// Label text is set in extended classes
			
			if(!isFile) {
				var itemCountLabel:spark.components.Label = new spark.components.Label();
				itemCountLabel.text = fileCount + "";
				itemCountLabel.setStyle('textAlign', TextAlign.RIGHT); 
				background.addElement(itemCountLabel);
			}
			
			background.addEventListener(MouseEvent.CLICK, labelClicked);
		}
		
		private function labelClicked(e:MouseEvent):void {
			trace("CollectionListItemButton:labelClicked");
			var activate:IDEvent = new IDEvent(IDEvent.COLLECTION_CLICKED, true);
			this.setSelected();
			this.dispatchEvent(activate);
		}
		private function triangleClicked(e:MouseEvent):void {
			if(!expanded) {
				trace("CollectionListItemButton:triangleClicked - Expanding");
				expanded = true;
				triangle.rotation = 0;
//				triangle.setBackground(0xFF0000, 1);
				var expandEvent:Event = new Event(Event.OPEN, true);
				this.dispatchEvent(expandEvent);
			} else {
				trace("CollectionListItemButton:triangleClicked - Closing");
				expanded = false;
				triangle.rotation = -90;
//				triangle.setBackground(0x000000, 1);
				expandEvent = new Event(Event.CLOSE, true);
				this.dispatchEvent(expandEvent);
			}
		}
		// Sets the text for the label for this list item
		public function setLabel(label:String):void {
			
			if(label.length > LABEL_CHARACTER_LENGTH) {
				label = label.substr(0, LABEL_CHARACTER_LENGTH) + "...";
			}
			this.myLabel.text = label;
		}
		
		public function showLoading():void {
			myIcon.visible = false;
			myIcon.includeInLayout = false;
			loaderIcon.visible = true;
			loaderIcon.includeInLayout = true;
			loaderIcon.startAnim();
		}
		
		public function hideLoading():void {
			myIcon.visible = true;
			myIcon.includeInLayout = true;
			loaderIcon.visible = false;
			loaderIcon.includeInLayout = false;
			loaderIcon.stopAnim();
		}
		
		/**
		 * Highlight this collection list element 
		 * 
		 */		
		public function setSelected():void {
			// Make this collection bold
			myLabel.setStyle("fontWeight", "bold");
//			super.setBackground(0xF2F9FF, 1);
		}
		
		/**
		 * Remove the highlight on this collection list item 
		 * 
		 */		
		public function unSelect():void {
			myLabel.setStyle("fontWeight", "normal");
//			super.setBackground(0xFFFFFF, 1);
		}	
		
		public function closeTriangle():void {
//			trace("closing triangle");
//			triangle.setBackground(0x000000, 1);
			triangle.rotation = -90;
			expanded = false;
		}
		
		public function searchMatches(search:String):Boolean {
			if(this.myLabel.text.toLowerCase().indexOf(search.toLowerCase()) == -1) {
				return false;
			} else {
				return true;
			}
		}
	}
}