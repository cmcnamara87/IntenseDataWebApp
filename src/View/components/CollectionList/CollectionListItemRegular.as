package View.components.CollectionList
{
	import Controller.RecensioEvent;
	import Controller.Utilities.AssetLookup;
	
	import Model.Model_Collection;
	
	import View.Element.Collection;
	import View.components.CollectionList.CollectionList;
	
	import flash.events.MouseEvent;
	
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
	
	public class CollectionListItemRegular extends CollectionListItem
	{
		private var collectionData:Model_Collection; // Stores the data for this collection
		private var itemCountLabel:spark.components.Label;
		
		/**
		 * Creates a new collection list item for the collection list (in left sidebar)
		 * @param 	collectionData	Data containing the asset id, title etc for the collection
		 * 
		 */		
		public function CollectionListItemRegular(collectionData:Model_Collection) {
			super();
			
			this.collectionData = collectionData;
			
			// List Label
			setLabel(collectionData.meta_title);
			
			// Add Item Count TODO make this not 'numberofChildren' but number of annotations
			itemCountLabel = new spark.components.Label();
			itemCountLabel.text = collectionData.meta_description + "";
			itemCountLabel.percentWidth = 100;
			itemCountLabel.setStyle('textAlign', TextAlign.RIGHT); 
			this.addElement(itemCountLabel);
			
			// Listen for click
			this.addEventListener(MouseEvent.CLICK, collectionListItemClicked);
		}
		
		/**
		 * This collection was clicked on, throw a RecensioEvent.ASSET_COLLECTION_CLICKED event.
		 * This is called from the CollectionList. We listen in there, so we can turn off the bold/etc for the selection on all
		 * the other list items...if that makes sense, i dont know, its late.
		 * The @BrowserController is listening for this, and will change the assets being displayed. 
		 * @param e
		 * 
		 */		
		public function collectionListItemClicked(e:MouseEvent):void {
			trace('collection clicked id: ', collectionData.base_asset_id);
			var clickEvent:RecensioEvent = new RecensioEvent(RecensioEvent.ASSET_COLLECTION_CLICKED,true);
			clickEvent.data.assetID = collectionData.base_asset_id;
			clickEvent.data.access = collectionData.access_modify;
			clickEvent.data.collectionName = collectionData.meta_title;
			this.dispatchEvent(clickEvent);
			
		}
		
		override public function getCollectionID():Number {
			return collectionData.base_asset_id;
		}
	}
}