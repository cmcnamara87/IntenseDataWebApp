package Model.Transactions {
	import Model.AppModel;
	import Model.Model_Media;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	public class Transaction_SaveCollection {
		
		private var collectionID:Number;
		private var mediaAssets:Array;
		//private var _assetData:Object;
		private var collectionTitle:String;
		private var _callback:Function;
		private var _connection:Connection;
		private var mediaToRemoveCount:Number = 0;
//		private var newCollectionAssets:Array = new Array();
		
		
		private var addMediaAssetsIDs:Array = new Array();
		private var addMediaAssetsClonedIDs:Array = new Array();
		private var currentMediaAssetsIDs:Array = new Array();
		private var removeMediaAssetsIDs:Array = new Array();
		
		// Constructor (calls getCurrentAssets())
		public function Transaction_SaveCollection(connection:Connection, collectionID:Number, collectionTitle:String, mediaAssets:Array, callback:Function) {
			_connection = connection;
			this.collectionID = collectionID;
			this.collectionTitle = collectionTitle;
			this.mediaAssets = mediaAssets;
			_callback = callback;
			
			getCurrentAssets();
	
			trace("Saving Colleciton");
		}
	
		// Asks mediaflux for the current MEDIA assets within a collection
		private function getCurrentAssets():void {
			trace("- Finding assets currently in collection");
			var args:Object = new Object();

			// Find all Media assets for this collection.
			args.where = "namespace=recensio and class>='recensio:base/resource/media' and related to (id=" + collectionID + ")";
			var baseXML:XML = _connection.packageRequest('asset.query',args,true);
			
			if(_connection.sendRequest(baseXML,assetsRetrieved)) {
				//All good
			} else {
				error();
			}
		}
		
		/**
		 * The assets for a collection have been retrieved. 
		 * Now removes all the relationships between the Collection and its Media
		 * @param e
		 * 
		 */		
		private function assetsRetrieved(e:Event):void {
			
			var dataXML:XML = XML(e.target.data);
			trace("- Assets Found" + dataXML);
			if (dataXML.reply.@type == "result") {
				//var items:XMLList = (dataXML.reply.result.related.(@type=="has_child").to as XMLList);
				var items:XMLList = (dataXML.reply.result.id as XMLList);
				

				// for each asset in media assets
				// We are going to see if its in the new list
				// but not the old one (means we have to add it)
				for each(var media:Model_Media in mediaAssets) {
					var found:Boolean = false;
					for each(var item:XML in items) {
						var assetID:Number = item.toString();
						if(assetID == media.base_asset_id) {
							// We found the asset in the current collection
							// so it doesnt need to be added
							found = true;
							break;
						}
					}
					if(!found) {
						// Its in our list of new assets, but not in the current ones
						// so we have to add it
						addMediaAssetsIDs.push(media.base_asset_id);
					}
				}
				
				// going to see if its in the current list, but not the new one,
				// so we have to remove it
				for each(item in items) {
					var found:Boolean = false;
					var assetID:Number = item.toString();
					var currentMedia:Model_Media = new Model_Media();
					currentMedia.base_asset_id = assetID;
					
					for each(var media:Model_Media in mediaAssets) {
						if(assetID == media.base_asset_id) {
							// we found it in the new collection
							found = true;
							currentMediaAssetsIDs.push(assetID);
						}
					}
					
					if(!found) {
						// we didnt find it in the new collection, so we have to remove it
						// create a dummy model media asset for it
						removeMediaAssetsIDs.push(assetID);
					}
				}

				mediaToRemoveCount = removeMediaAssetsIDs.length; //items.length();
				
				
				// Remove all the media we need to remove
				if(mediaToRemoveCount > 0) {
					trace("- Deleting Existing Asset Relationships");
					for each(var mediaID:Number in removeMediaAssetsIDs) {
						deleteRelationship(mediaID);
					}
				} else {
					trace("- No assets currently in collection");
					createNewClonesIfNeeded();
				}
			} else {
				error();
			}
		}
		
		// Removes the relationship between a collection and an asset
		private function deleteRelationship(assetID:Number):void {
			var args:Object = new Object();
			args.id = collectionID;
			var baseXML:XML = _connection.packageRequest('asset.relationship.remove',args,true);
			baseXML.service.args["to"].@relationship = "has_child";
			baseXML.service.args["to"] = assetID;
			if(_connection.sendRequest(baseXML,relationshipDeleted)) {
			} else {
				error();
			}
		}
		
		// Called once the collection no longer has any assets, so that the updated assets list can be re-added
		private function relationshipDeleted(e:Event):void {
			mediaToRemoveCount--;
			if(mediaToRemoveCount == 0) {
				trace("- All existing relationships removed", e.target.data);
				var transaction:Transaction_CopyCollectionAccess = new Transaction_CopyCollectionAccess(collectionID, removeMediaAssetsIDs, true, _connection, function():void {
					createNewClonesIfNeeded();
					_callback(collectionID);	
				});	
			}
		}

	
		/**
		 * Creates copies of assets, if those assets were added from 'your assets'.
		 * We know this, because the assetIDs will be negative numbers 
		 * @return 
		 * 
		 */		
		private function createNewClonesIfNeeded():void {
			for(var i:Number = 0; i < addMediaAssetsIDs.length; i++) {
				var currentAssetID:Number = addMediaAssetsIDs[i];
				if(currentAssetID < 0) {
					var transaction:Transaction_CloneMedia = new Transaction_CloneMedia(_connection);
					transaction.cloneMedia(Math.abs(currentAssetID), mediaCloned);
				} else {
					addMediaAssetsClonedIDs.push(currentAssetID);
				}
			}
			
			// If they are the asme length, it means we didnt need to make a copy of anything
			// so we can just go make the collection straight away
			if(addMediaAssetsClonedIDs.length == addMediaAssetsIDs.length) {
				createNewRelationships();
			}
		}
		
		private function mediaCloned(newMediaID:Number):void {
			if(newMediaID == -1) {
				_callback(-1);	
				return;
			}
			
			addMediaAssetsClonedIDs.push(newMediaID);
			trace("Transaction_CreateCollection:mediaClone -", newMediaID);
			if(addMediaAssetsClonedIDs.length == addMediaAssetsIDs.length) {
				createNewRelationships();
			}
		}
		
		// Creates new relationships between the new list of assets and the collection
		private function createNewRelationships():void {
			
			// delete relationships to those that have to be removed
			// remove access to those being removed
			
			// look through list of assets to add for clones
			// clone in necessary
			// construct a new list of assets to add, with their new cloned ids
			// merge this list, with the list of assets already in the current collection
			// give that to the create new relationships
			// whne thats finished, give the add list, (with the new clone ids) to copy access
			
			
			
			
			trace("- Creating new relationships");
			var args:Object = new Object();
			args.id = collectionID;
			var baseXML:XML = _connection.packageRequest('asset.set',args,true);
			
			// Set the title of the collection
			baseXML.service.args["meta"]["r_resource"]["title"] = collectionTitle;
			// Set the number of media in the collection
			baseXML.service.args["meta"]["r_resource"]["description"] = mediaAssets.length + "";
			
			if(addMediaAssetsClonedIDs.length) {
				// We are going to add some number media assets
				// So to use 'appendChild' in the next line,
				// we need to set 'related' to be the empty string
				baseXML.service.args["related"] = "";
				
				for each (var mediaID:Number in addMediaAssetsClonedIDs) {
					trace("- Adding relationship to:", mediaID);
					baseXML.service.args["related"].appendChild(XML('<to relationship="has_child">' + mediaID + '</to>'));
				}
			}
			
			if(_connection.sendRequest(baseXML, relationshipsAdded)) {
				
			} else {
				error();
			}
		}
		
		// Returns the information back to the controller which called it
		private function relationshipsAdded(e:Event):void {
			trace("Transaction_SaveCollection:relationshipsAdded", e.target.data);
//			for each(var mediaAsset:Model_Media in mediaAssets) {
//				trace("Transaction_SaveCollection:Copy Collection Access to", mediaAsset.base_asset_id);
			var transaction:Transaction_CopyCollectionAccess = new Transaction_CopyCollectionAccess(collectionID, addMediaAssetsClonedIDs, false, _connection, function():void {
				trace("*****************************");
				trace("Finished Copying COllection Access");
				_callback(collectionID);	
			});
//			}
		}
		
		// Called if an error occurs
		private function error():void {
			Alert.show("Could not save collection");
		}
	}
}