package Model.Transactions
{
	import Model.AppModel;
	import Model.Model_Media;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.controls.Alert;
	
	public class Transaction_CopyCollectionAccess
	{
		private var collectionID:Number;
		private var callback:Function;
		private var mediaAssets2:Array;
		private var connection:Connection;
		private var userShareCounts:XMLList;
		private var currentUserIndex:Number = 0;
		private var mediaAssetCount:Number;
		
		public function Transaction_CopyCollectionAccess(collectionID:Number, mediaAssets:Array, connection:Connection, callback:Function)
		{
//			trace("Copy ACLS from", collectionID, "to", mediaAssets);
			this.collectionID = collectionID;
			this.mediaAssets2 = mediaAssets;
			this.connection = connection;
			this.callback = callback;
			
			getShare();
		}
		
		private function getShare():void {
			trace("Transaction_CopyCollectionAccess: Getting share data for", collectionID);
			
			var args:Object = new Object();
			args.id = collectionID;
			
			if(connection.sendRequest(connection.packageRequest('asset.get',args,true), changeShareCount)) {
				//All good
			} else {
				Alert.show("Could not get share count");
			}
		}
		
		private function changeShareCount(e:Event):void {
			
			if(!AppModel.getInstance().callSuccessful(e)) {
				// We failed to get the assets meta-data, so we should throw an error.
				trace("Transaction_CopyCollectionAccess:changeShareCount - Failed to get asset meta-data", e.target.data);
				return;
			}
			
//			trace("Transaction_CopyCollectionAccess:changeShareCount Changing the sharing data");
			
			var data:XML = XML(e.target.data);
			
			// Get out the current asset count for this user
			userShareCounts = data.reply.result.asset.meta.id_sharing.user_share_count;
			
			shareWithUser();
		}
		
		private function shareWithUser(e:Event=null):void {

			mediaAssetCount = mediaAssets2.length;
			
			for each(var media:Model_Media in mediaAssets2) {
				// For each media (since we can only be writing to it once, otherwise we get collisions)
				// share it with a single user, then move onto the next user, when they all have completed
				var shareUser:String = userShareCounts[currentUserIndex]["username"];
				var shareViaAsset:Number = userShareCounts[currentUserIndex]["via_asset"];
				var shareAccessLevel:String = userShareCounts[currentUserIndex]["access_level"];
				
				var transaction:Transaction_ChangeAccess = new Transaction_ChangeAccess(connection);
				transaction.changeAccess(media.base_asset_id, collectionID, shareUser, "system", shareAccessLevel, false, mediaSharedWithUser);
				
			}
		}
		
		private function mediaSharedWithUser(e:Event):void {
			mediaAssetCount--;
			if(mediaAssetCount == 0) {
				// All the assets have been successfully shared, and have come back
				// so lets increment currentUserIndex and do it all again for the next user
				currentUserIndex++;
				
				if(currentUserIndex == userShareCounts.length()) {
					// we have finished sharing
					trace("Transaction_CopyCollectionAccess:changeShareCount - Sharing Finished");
					callback();
				} else {
					// Share it again for the enxt user
					shareWithUser();
				}
			}
		}
	}
}