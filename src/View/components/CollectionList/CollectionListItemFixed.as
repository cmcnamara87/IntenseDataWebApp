package View.components.CollectionList
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import Model.Model_Collection;
	
	import View.Element.Collection;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Rect;
	
	public class CollectionListItemFixed extends CollectionListItem
	{
		private var collectionLabel:String; // The label for this fixed collection
		private var fixedCollectionID:Number; // the label for this fixed collection
		private var clickEventName:String; // the name of the event to call when this collection is clicked
											// @see RecensioEvent (probably RecensioEvent.ASSET_COLLECTION_ALL_MEDIA etc)
		
		/**
		 * Creates a new collection list item for Fixed collections (e.g. All Assets, Shared, and Shelf)
		 * 
		 */		
		public function CollectionListItemFixed(fixedCollectionID:Number, collectionLabel:String, clickEventName:String)
		{
			super();
			this.fixedCollectionID = fixedCollectionID;
			this.collectionLabel = collectionLabel;
			this.clickEventName = clickEventName;
			
			// List Label
			setLabel(collectionLabel);

			this.addEventListener(MouseEvent.CLICK, collectionItemClicked);
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
		
		override public function getCollectionID():Number {
			return fixedCollectionID;
		}
	}
}