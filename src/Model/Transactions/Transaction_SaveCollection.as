package Model.Transactions {
	import Model.Model_Media;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	public class Transaction_SaveCollection {
		
		private var collectionID:Number;
		private var mediaAssets:Array;
		//private var _assetData:Object;
		private var collectionTitle:String;
		private var _callback:Function;
		private var _connection:Connection;
		private var existingAssets:Number = 0;
		
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
				existingAssets = items.length();
				
				if(existingAssets > 0) {
					trace("- Deleting Existing Asset Relationships");
					for each(var item:XML in items) {
						deleteRelationship(item.toString());
					}
				} else {
					trace("- No assets currently in collection");
					createNewRelationships();
				}
			} else {
				error();
			}
		}
		
		// Removes the relationship between a collection and an asset
		private function deleteRelationship(assetID:String):void {
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
			existingAssets--;
			if(existingAssets == 0) {
				trace("- All existing relationships removed", e.target.data);
				createNewRelationships();
			}
		}
		
		// Creates new relationships between the new list of assets and the collection
		private function createNewRelationships():void {
			trace("- Creating new relationships");
			var args:Object = new Object();
			args.id = collectionID;
			var baseXML:XML = _connection.packageRequest('asset.set',args,true);
			
			// Set the title of the collection
			baseXML.service.args["meta"]["r_resource"]["title"] = collectionTitle;
			// Set the number of media in the collection
			baseXML.service.args["meta"]["r_resource"]["description"] = mediaAssets.length + "";
			
			if(mediaAssets.length) {
				// We are going to add some number media assets
				// So to use 'appendChild' in the next line,
				// we need to set 'related' to be the empty string
				baseXML.service.args["related"] = "";
			}
			for each (var mediaAsset:Model_Media in mediaAssets) {
				trace("- Adding relationship to:", mediaAsset.base_asset_id);
				baseXML.service.args["related"].appendChild(XML('<to relationship="has_child">' + mediaAsset.base_asset_id + '</to>'));
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
			var transaction:Transaction_CopyCollectionAccess = new Transaction_CopyCollectionAccess(collectionID, mediaAssets, _connection, function():void {
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