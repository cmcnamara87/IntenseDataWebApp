package View.components.CollectionList
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import Model.Model_Collection;
	
	import View.Element.Collection;
	import View.components.PanelElement;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Rect;
	
	public class CollectionListItemFile extends VGroup implements PanelElement
	{
		private var collectionLabel:String; // The label for this fixed collection
		private var fixedCollectionID:Number; // the label for this fixed collection
		private var clickEventName:String; // the name of the event to call when this collection is clicked
											// @see RecensioEvent (probably RecensioEvent.ASSET_COLLECTION_ALL_MEDIA etc)
		private var fileLabel:CollectionListItemButton;
		/**
		 * Creates a new collection list item for Fixed collections (e.g. All Assets, Shared, and Shelf)
		 * 
		 */		
		public function CollectionListItemFile(fixedCollectionID:Number, collectionLabel:String, clickEventName:String)
		{
			this.percentWidth = 100;
			
			// Create the button
			fileLabel = new CollectionListItemButton(false, true);
			
			// We are creating this collection, and its the one we are loading, showi t as loading
			if(BrowserController.currentCollectionID == fixedCollectionID) {
				fileLabel.showLoading();
			}
			
			this.fixedCollectionID = fixedCollectionID;
			this.collectionLabel = collectionLabel;
			this.clickEventName = clickEventName;
			
			// List Label
			fileLabel.setLabel(collectionLabel);
			
			var itemCountLabel:spark.components.Label = new spark.components.Label();
			itemCountLabel.text = "";
			itemCountLabel.percentWidth = 100;
			itemCountLabel.setStyle('textAlign', TextAlign.RIGHT); 
			fileLabel.addElement(itemCountLabel);

			this.addElement(fileLabel);
			
			fileLabel.addEventListener(MouseEvent.CLICK, collectionItemClicked);
		}
		
		/**
		 * This collection was clicked on, throw a RecensioEvent called var clickEventName.
		 * The @BrowserController is listening for this, and will change the assets being displayed. 
		 * @param e Mouse Event Click
		 * 
		 */		
		public function collectionItemClicked(e:MouseEvent):void {
			trace(collectionLabel, "Clicked", fixedCollectionID);
			var clickEvent:IDEvent = new IDEvent(clickEventName, true);
			clickEvent.data.assetID = fixedCollectionID;
			this.dispatchEvent(clickEvent);
		}
		
		public function getCollectionID():Number {
			return fixedCollectionID;
		}
		
		public function setSelected():void {
			fileLabel.setSelected();
		}
		public function unSelect():void {
			fileLabel.unSelect();
		}
		public function showLoading():void {
			fileLabel.showLoading();
		}
		public function hideLoading():void {
			fileLabel.hideLoading();
		}
		
		public function searchMatches(search:String):Boolean {
			return fileLabel.searchMatches(search);
		}
			
	}
}