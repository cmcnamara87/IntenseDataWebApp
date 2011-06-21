package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Media;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;

	public class Transaction_CreateCollection
	{
		private var collectionTitle:String;
		private var shelfAssets:Array;
		private var newCollectionID:Number;
		private var newCollectionAssets:Array = new Array();
		private var callback:Function;
		private var connection:Connection;
		
		
		public function Transaction_CreateCollection(connection:Connection)
		{
			this.connection = connection;	
		}
		
		/**
		 * Creates a new collection. 
		 * @param collectionTitle	The title of the collection
		 * @param shelfAssets		An array of Model_Media assets to be in the collection
		 * @param callback			The callback - callback(newCollectionID:Number)
		 * 
		 */		
		public function createCollection(collectionTitle:String, shelfAssets:Array, callback:Function):void {
			this.collectionTitle = collectionTitle;
			this.shelfAssets = shelfAssets;
			this.callback = callback;
		
			createNewClonesIfNeeded();
		}
		
		/**
		 * Creates copies of assets, if those assets were added from 'your assets'.
		 * We know this, because the assetIDs will be negative numbers 
		 * @return 
		 * 
		 */		
		private function createNewClonesIfNeeded():void {
			for(var i:Number = 0; i < shelfAssets.length; i++) {
				var currentAssetID:Number = (shelfAssets[i] as Model_Media).base_asset_id;
				if(currentAssetID < 0) {
					var transaction:Transaction_CloneMedia = new Transaction_CloneMedia(connection);
					transaction.cloneMedia(Math.abs(currentAssetID), mediaCloned);
				} else {
					newCollectionAssets.push(currentAssetID);
				}
			}
			
			// If they are the asme length, it means we didnt need to make a copy of anything
			// so we can just go make the collection straight away
			if(newCollectionAssets.length == shelfAssets.length) {
				makeNewCollection();
			}
		}
		
		private function mediaCloned(newMediaID:Number):void {
			if(newMediaID == -1) {
				callback(-1);	
				return;
			}
			
			newCollectionAssets.push(newMediaID);
			trace("Transaction_CreateCollection:mediaClone -", newMediaID);
			if(newCollectionAssets.length == shelfAssets.length) {
				makeNewCollection();
			}
//			
//			
//			AppModel.getInstance().changeAccess(newMediaID, Auth.getInstance().getUsername(), "system", SharingPanel.READWRITE, false, 
//				function(e:Event):void {
//					if(!AppModel.getInstance().callSuccessful(e)) {
//						callback(-1);
//					}
//					
//					
//					
//			});
//			
			
		}
		
		private function makeNewCollection():void {
			trace("Creating collection");
			// Build up the collection object
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = connection.packageRequest('asset.create',args,true);
			baseXML.service.args["meta"]["r_base"]["obtype"] = "10";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			// Set creator as the current user
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_base"].@id = 2;
			baseXML.service.args["meta"]["r_resource"]["title"] = collectionTitle;
			
			baseXML.service.args["meta"]["r_media"].@id = 4;
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			baseXML.service.args["related"] = "";
			
			// Link the collection to all the assets on the shelf.
			for(var i:Number = 0; i < newCollectionAssets.length; i++) {
				var currentAssetID:Number = newCollectionAssets[i];
				trace("Including asset", currentAssetID);
				baseXML.service.args["related"].appendChild(XML('<to relationship="has_child">' + currentAssetID + '</to>'));
			}
			
			// Set the description, to be the number of items in the collection
			baseXML.service.args["meta"]["r_resource"]["description"] = newCollectionAssets.length;
			
			connection.sendRequest(baseXML, collectionCreated);
		}
		
		private function collectionCreated(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("AppModel:createCollection - Failed to Create collection", e.target.data);
				callback(-1);
				return;
			}
			
			
			newCollectionID = XML(e.target.data).reply.result.id;
			
			trace("Transaction_CreateCollection:CollectionCreated", newCollectionID);
			
			AppModel.getInstance().setCollectionClass(e, function(j:Event):void {
				if(!AppModel.getInstance().callSuccessful(e)) {
					trace("Failed to make collection");
				}
			});

			AppModel.getInstance().changeAccess(XML(e.target.data).reply.result.id, Auth.getInstance().getUsername(), 
				"system", SharingPanel.READWRITE, true, collectionCreationComplete);
		}
		
		private function collectionCreationComplete(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("AppModel:createCollection - Failed to Change access on collection", e.target.data);
				callback(-1);
				return;
			}
			
			callback(newCollectionID);	
		}
	}
}