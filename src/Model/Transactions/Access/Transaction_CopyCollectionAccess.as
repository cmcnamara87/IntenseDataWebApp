package Model.Transactions.Access
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Media;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.controls.Alert;
	
	public class Transaction_CopyCollectionAccess
	{
		private var collectionID:Number;
		private var callback:Function;
		private var mediaAssetsIDs:Array;
		private var connection:Connection;
		private var userShareCounts:XMLList;
		private var currentUserIndex:Number = 0;
		private var mediaAssetCount:Number;
		private var removeAccess:Boolean;
		
		public function Transaction_CopyCollectionAccess(collectionID:Number, mediaAssetsIDs:Array, removeAccess:Boolean, connection:Connection, callback:Function)
		{
//			trace("Copy ACLS from", collectionID, "to", mediaAssets);
			this.collectionID = collectionID;
			this.mediaAssetsIDs = mediaAssetsIDs;
			this.removeAccess = removeAccess;
			this.connection = connection;
			this.callback = callback;
			
			if(mediaAssetsIDs.length > 0) {
				getShare();
			} else {
				trace("Transaction_CopyCollectionAccess - No media assets given");
				callback();
			}
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
			
			var shareUser:String = userShareCounts[currentUserIndex]["username"];
			var shareAccessLevel:String = userShareCounts[currentUserIndex]["access_level"];

			trace("Transaction_CopyCollectionAccess:shareWithUser - ", shareUser, shareAccessLevel);
			
			if(removeAccess && shareUser == Auth.getInstance().getUsername()) {
				// we are about to remove access to the media, for the current user
				// Dont remove access just yet
				// this is because, if they only hve t access to the asset
				// and then they remove it, they cant remove it for all the other people who have access to the collection as well
				// and we get errors
				currentUserIndex++;
				
				if(currentUserIndex == userShareCounts.length()) {
					mediaAssetCount = 1;
					currentUserIndex--;
					mediaSharedWithUser();
					return;
				}
				
				shareUser = userShareCounts[currentUserIndex]["username"];
				shareAccessLevel = userShareCounts[currentUserIndex]["access_level"];
				trace("Transaction_CopyCollectionAccess:shareWithUser Skipping current user - ", shareUser, shareAccessLevel);
			}

			mediaAssetCount = mediaAssetsIDs.length;
			
			for each(var mediaID:Number in mediaAssetsIDs) {
				// For each media (since we can only be writing to it once, otherwise we get collisions)
				// share it with a single user, then move onto the next user, when they all have completed
				
				
				if(removeAccess) {
					var transaction:Transaction_ChangeAccess = new Transaction_ChangeAccess(connection);
					transaction.changeAccess(mediaID, collectionID, shareUser, "system", SharingPanel.NOACCESS, false, mediaSharedWithUser);
				} else {
					transaction = new Transaction_ChangeAccess(connection);
					transaction.changeAccess(mediaID, collectionID, shareUser, "system", shareAccessLevel, false, mediaSharedWithUser);
				}
			}			
		}
		
		private function mediaSharedWithUser(e:Event = null):void {
			mediaAssetCount--;
			if(mediaAssetCount == 0) {
				// All the assets have been successfully shared, and have come back
				// so lets increment currentUserIndex and do it all again for the next user
				currentUserIndex++;
				
				if(currentUserIndex == userShareCounts.length()) {
					// we have finished sharing
					if(removeAccess) {
						// now remove access for the current user, sicn all the other users are finished
						for each(var mediaID:Number in mediaAssetsIDs) {
							var transaction:Transaction_ChangeAccess = new Transaction_ChangeAccess(connection);
							transaction.changeAccess(mediaID, collectionID, Auth.getInstance().getUsername(), "system", SharingPanel.NOACCESS, false, copyComplete);
						}
					} else {
						copyComplete();
					}
				} else {
					// Share it again for the enxt user
					shareWithUser();
				}
			}
		}
		
		private function copyComplete(e:Event = null):void {
			trace("Transaction_CopyCollectionAccess:changeShareCount - Sharing Finished");
			callback();
		}
	}
}