package View.components.CollectionList
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import Lib.LoadingAnimation.LoadAnim;
	
	import Model.Model_Collection;
	import Model.Model_Media;
	
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
	import mx.core.IUIComponent;
	import mx.effects.Fade;
	import mx.events.DragEvent;
	import mx.graphics.SolidColor;
	import mx.managers.DragManager;
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
		private var data:Number;
		private var file:Model_Media;
		private var shared:Boolean;
		/**
		 * The button that shows in the Discussion sidebar.  
		 * @param shared		Has this Discussion been shared wth the current users?
		 * @param modify		Does the current user have modify access
		 * @param isFile		Is this a file?
		 * @param data			For a file, its the files id, and for a discussion, its the discussion count		
		 * 
		 */
		public function CollectionListItemButton(shared:Boolean, modify:Boolean, isFile:Boolean, data:Number, file:Model_Media=null)
		{
			super(0xFFFFFF, 1);
			this.data = data;
			this.file = file;
			this.shared = shared;
			
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
				// Filei
				if(file != null) {
//					trace("*****************`", file.type);
					if(file.type == "video") {
						if(shared) {
							myIcon.source = AssetLookup.getVideoFileIconSmallOthers();
							
						} else {
							myIcon.source = AssetLookup.getVideoFileIconSmallYours();
						}
						myIcon.width = 15;
						myIcon.height = 12;
					} else if (file.type == "image") {
						if(shared) {
							myIcon.source = AssetLookup.getImageFileIconSmallOthers();
							
						} else {
							myIcon.source = AssetLookup.getImageFileIconSmallYours();
						}
						myIcon.width = 15;
						myIcon.height = 12;
					} else if (file.type == "audio") {
						if(shared) {
							myIcon.source = AssetLookup.getAudioFileIconSmallOthers();
							
						} else {
							myIcon.source = AssetLookup.getAudioFileIconSmallYours();
						}
						myIcon.width = 13;
						myIcon.height = 13;
					} else if (file.type == "document") {
						if(shared) {
							myIcon.source = AssetLookup.getGenericFileIconSmallOthers();
							
						} else {
							myIcon.source = AssetLookup.getGenericFileIconSmallYours();
						}
						myIcon.width = 15;
						myIcon.height = 12;
					}
				} else {
//					if(shared) {
//						myIcon.source = AssetLookup.getGenericFileIconSmallOthers();
						myIcon.source = AssetLookup.getAllFileIcon();	
//					} else {
//						myIcon.source = AssetLookup.getGenericFileIconSmallYours();
//					}
				}
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
				itemCountLabel.text = data + "";
				itemCountLabel.setStyle('textAlign', TextAlign.RIGHT); 
				background.addElement(itemCountLabel);
			}
			
//			background.addEventListener(DragEvent.DRAG_ENTER, function(e:DragEvent):void {
//				DragManager.acceptDragDrop(e.currentTarget as IUIComponent);
//			});
//			
//			background.addEventListener(DragEvent.DRAG_DROP, function(e:DragEvent):void {
//				DragManager.doDrag(e.currentTarget as IUIComponent, null, e);	
//			});
			
			background.addEventListener(MouseEvent.CLICK, labelClicked);
		}
		
		private function labelClicked(e:MouseEvent):void {
			trace("CollectionListItemButton:labelClicked");
			var activate:IDEvent = new IDEvent(IDEvent.COLLECTION_CLICKED, true);
			//activate.data.file_id = data;
			activate.data.file = file;
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
		
		public function showEditIcon():void {
			myIcon.source = AssetLookup.getEditDiscussionIcon();
			myLabel.setStyle("color", "0xFF0000");
			myLabel.setStyle("fontWeight", "bold");
		}
		
		public function hideEditIcon():void {
			myLabel.setStyle('color', '0x000000');
			myLabel.setStyle("fontWeight", "normal");
			if(shared) {
				myIcon.source = AssetLookup.getCollectionSharedIconClass();
			} else {
				myIcon.source = AssetLookup.getCollectionIconClass();
			}
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