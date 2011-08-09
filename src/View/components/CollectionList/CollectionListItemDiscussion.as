package View.components.CollectionList
{
	import Controller.BrowserController;
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Lib.LoadingAnimation.LoadAnim;
	
	import Model.Model_Collection;
	import Model.Model_Media;
	
	import View.Element.Collection;
	import View.components.CollectionList.CollectionList;
	import View.components.PanelElement;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.effects.Fade;
	import mx.graphics.SolidColor;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Rect;
	
	public class CollectionListItemDiscussion extends VGroup implements PanelElement
	{
		private var listItem:CollectionListItemButton;
		private var collectionData:Model_Collection; // Stores the data for this collection
		private var itemCountLabel:spark.components.Label;
		private var fileList:VGroup;
		/**
		 * Creates a new collection list item for the collection list (in left sidebar)
		 * @param 	collectionData	Data containing the asset id, title etc for the collection
		 * 
		 */		
		public function CollectionListItemDiscussion(collectionData:Model_Collection, files:Array) {
			this.gap = 0;
			this.percentWidth = 100;
			
			this.collectionData = collectionData;
			
			if(collectionData.base_creator_username != Auth.getInstance().getUsername()) {
				var shared:Boolean = true;
			} else {
				shared = false;
			}

			listItem = new CollectionListItemButton(shared, collectionData.access_modify_content, false, files.length);		
			listItem.percentWidth = 100;
			
			// List Label
			listItem.setLabel(collectionData.meta_title);
			
//			itemCountLabel = new spark.components.Label();
//			itemCountLabel.text = collectionData.meta_description + "";
//			itemCountLabel.percentWidth = 100;
//			itemCountLabel.setStyle('textAlign', TextAlign.RIGHT); 
//			listItem.addElement(itemCountLabel);
			
			listItem.toolTip = collectionData.meta_title + "\nCreated by: " + collectionData.base_creator_username; 
			
			this.addElement(listItem);
			
			// now lets add the files
			// they are going to go into a Vgroup, so we can hide/show them all
			fileList = new VGroup();
			fileList.gap = 0;
			fileList.paddingLeft = 30;
			fileList.percentWidth = 100;
			
			for each(var file:Model_Media in files) {
				var fileItem:CollectionListItemButton = new CollectionListItemButton(shared, collectionData.access_modify_content, true, file.base_asset_id, file);
				fileItem.setLabel(file.meta_title);
				fileList.addElement(fileItem);
				fileItem.addEventListener(IDEvent.COLLECTION_CLICKED, function(e:IDEvent):void {
					trace("got an activate event for file" + e.data.file.base_asset_id);
					trace("************* for file" + file.base_asset_id);
					// Change the browser controller so the current discussion, is whatever the parent
					// of the file we clicked
					BrowserController.currentMediaData = null;
					BrowserController.currentCollectionID = collectionData.base_asset_id;
					
					Dispatcher.call("view/" + e.data.file.base_asset_id);
				});
			}
			fileList.visible = false;
			fileList.includeInLayout = false;
			this.addElement(fileList);
			
			
			
			// Listen for click
			listItem.addEventListener(IDEvent.COLLECTION_CLICKED, collectionListItemClicked);
			listItem.addEventListener(Event.OPEN, function(e:Event):void {
				fileList.visible = true;
				fileList.includeInLayout = true;
				
				for(var i:Number = 0; i < fileList.numElements; i++) {
					var fileButton:CollectionListItemButton = fileList.getElementAt(i) as CollectionListItemButton;
					fileButton.visible = true;
					fileButton.includeInLayout = true;
				}
			});
			listItem.addEventListener(Event.CLOSE, function(e:Event):void {
				fileList.visible = false;
				fileList.includeInLayout = false;
			});
		}
		
		/**
		 * This collection was clicked on, throw a RecensioEvent.ASSET_COLLECTION_CLICKED event.
		 * This is called from the CollectionList. We listen in there, so we can turn off the bold/etc for the selection on all
		 * the other list items...if that makes sense, i dont know, its late.
		 * The @BrowserController is listening for this, and will change the assets being displayed. 
		 * @param e
		 * 
		 */		
		public function collectionListItemClicked(e:Event):void {
			trace('collection clicked id: ', collectionData.base_asset_id);
			var clickEvent:IDEvent = new IDEvent(IDEvent.ASSET_COLLECTION_CLICKED,true);
			clickEvent.data.assetID = collectionData.base_asset_id;
			clickEvent.data.access = collectionData.access_modify_content;
			clickEvent.data.collectionName = collectionData.meta_title;
			clickEvent.data.collectionData = this.collectionData;
			this.dispatchEvent(clickEvent);
			
		}
		
		/**
		 * Gets if we can modify this collection. 
		 * @return 
		 * 
		 */		
		public function getAccess():Boolean {
			return collectionData.access_modify;
		}
		
		public function getCollectionName():String {
			return collectionData.meta_title;
		}
		
		public function getCollectionID():Number {
			return collectionData.base_asset_id;
		}
		
		public function setSelected():void {
			listItem.setSelected();
		}
		public function unSelect():void {
			listItem.unSelect();
		}
		public function showEdit():void {
			listItem.showEditIcon();
		}
		public function hideEdit():void {
			listItem.hideEditIcon();	
		}
		public function showLoading():void {
			listItem.showLoading();
		}
		public function hideLoading():void {
			listItem.hideLoading();
		}
		
		public function searchMatches(search:String):Boolean {
			// Search to see if we have a match in the file list
			var fileMatch:Boolean = false;
			
			// turn of all the triangles
			listItem.closeTriangle();
			
			// we have a search time, so lets search for it
			for(var i:Number = 0; i < fileList.numElements; i++) {
				var fileButton:CollectionListItemButton = fileList.getElementAt(i) as CollectionListItemButton;
				
				// if we got a blank search
				// we basically need to make them all visible again
				if(search == "") {
					fileButton.visible = true;
					fileButton.includeInLayout = true;
					continue;
				}
				
				// its a real search, so lets search for it
				if(fileButton.searchMatches(search)) {
					// the file button is a match, so show it
					fileButton.visible = true;
					fileButton.includeInLayout = true;
					fileMatch = true;
				} else {
					// its not a match, so make it invisible
					fileButton.visible = false;
					fileButton.includeInLayout = false;
				}
			}
			
			if(fileMatch && search != "") {
				fileList.visible = true;
				fileList.includeInLayout = true;
			} else {
				// there was no file match, or the search was blank
				// so we hide the list of files
				fileList.visible = false;
				fileList.includeInLayout = false;
			}
			return listItem.searchMatches(search) || fileMatch;			
		}
	}
}