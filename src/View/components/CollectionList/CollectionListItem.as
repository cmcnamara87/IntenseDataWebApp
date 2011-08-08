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

	public class CollectionListItem implements PanelElement
	{
		private var myLabel:spark.components.Label; // The collection list label
		private const LABEL_CHARACTER_LENGTH:Number = 27; 	// The number of characters of text the label can dsiplay
															// Before it is chopped and '...' is appended.
		private var myIcon:Image;
		private var loaderIcon:LoadAnim;
		/**
		 * Creates a new collection list item for the collection list (in left sidebar)
		 */		
		public function CollectionListItem(shared:Boolean, modify:Boolean)
		{
		}
		
//		// Sets the text for the label for this list item
//		public function setLabel(label:String):void {
//			
//			if(label.length > LABEL_CHARACTER_LENGTH) {
//				label = label.substr(0, LABEL_CHARACTER_LENGTH) + "...";
//			}
//			this.myLabel.text = label;
//		}
//		
//		public function showLoading():void {
//			myIcon.visible = false;
//			myIcon.includeInLayout = false;
//			loaderIcon.visible = true;
//			loaderIcon.includeInLayout = true;
//			loaderIcon.startAnim();
//		}
//		
//		public function hideLoading():void {
//			myIcon.visible = true;
//			myIcon.includeInLayout = true;
//			loaderIcon.visible = false;
//			loaderIcon.includeInLayout = false;
//			loaderIcon.stopAnim();
//		}
//		
//		public function setSelected():void {
//			// Make this collection bold
//			super.setBackground(0xF2F9FF, 1);
////			this.setStyle('fontWeight', 'bold');
//		}
//		
//		public function unSelect():void {
//			super.setBackground(0xFFFFFF, 1);
////			this.setStyle('fontWeight', 'normal');
//		}
//		
//		public function getCollectionID():Number {
//			throw new Error("getCollectionID() must be overwritten by subclasses");
//		}
//		
//		public function searchMatches(search:String):Boolean {
//			if(myLabel.text.toLowerCase().indexOf(search.toLowerCase()) == -1) {
//				return false;
//			} else {
//				return true;
//			}
//		}
		
	}
}