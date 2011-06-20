package Model.Transactions
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Model_Media;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_ChangeAccess
	{
		private var connection:Connection; // The connection to mediaflux
		private var callback:Function; // THe callback function
		private var assetID:Number; // The ID of the asset to change the sharing for
		private var username:String;
		private var domain:String;
		private var access:String;
		private var highestAccessLevel:String;
		private var isCollection:Boolean;
		private var collectionMediaCount:Number;
		
		public function Transaction_ChangeAccess(connection:Connection)
		{
			this.connection = connection;
		}
		
		public function changeAccess(assetID:Number, viaAsset:Number, username:String, domain:String, access:String, isCollection:Boolean, callback:Function=null):void {
			this.assetID = assetID;
			this.username = username;
			this.domain = domain;
			this.access = access;
			this.isCollection = isCollection;
			this.callback = callback;
					
			trace("Transaction_ChangeAccess: Changing Access to Asset", assetID);
			// We are changing asset for either a collection or an asset for a user
			// there are now two parts to access
			// the id_sharing object, which stores the access level for each asset
			// and the acls on the object, which stores the highest access level out of all the id_sharing data for a user
			
			
			// we first need to see, if the access is higher than what we already have saved
			
			// get the current id_sharing list
			// update the list so
			// the user, access, via are updated to the new asset
			// this should return the current highest level of access the person has to the asset
			// then we update the acls to be that
			// then if its a collection, we have to do more shit, for every asset!
			
			// Returns the highest level access this person has for this asset 
			AppModel.getInstance().setUserAssetShareCount(username, assetID, viaAsset, access, setACLs);
		}
			
		private function setACLs(e:Event, highestAccessLevel:String = ""):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("Transaction_ChangeAccess: Failed to get/set Highest Access Level");
				if(callback != null) {
					callback(e);
				}
				return;
			}
			
			this.highestAccessLevel = highestAccessLevel;

			trace("Transaction_ChangeAccess: Changing access on Asset", assetID,  "for", domain, username, "with access", highestAccessLevel);
			
			if(highestAccessLevel == SharingPanel.NOACCESS) {
				if(isCollection) {
					revokeAccess(assetID, domain, username, true, changeAccessForChildren);
				} else {
					revokeAccess(assetID, domain, username, false, callback);
				}
				
			} else {
				if(isCollection) {
					grantAccess(assetID, domain, username, highestAccessLevel, true, changeAccessForChildren);
				} else {
					grantAccess(assetID, domain, username, highestAccessLevel, false, callback);
				}
			}
		}

		
		/**
		 * Changes access for all sub-elements. Used by a collection to change the access to
		 * all its comments, and all media contained within it. 
		 * @param e
		 * 
		 */		
		private function changeAccessForChildren(e:Event):void {
			var dataXML:XML = XML(e.target.data);

			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("Transaction_ChangeAccess: Failed to set Highest ACL for collection");
				if(callback != null) {
					callback(e);
				}
				return;
			}
			
//			// Tell the controller we have finished changing for this collection, but we 
//			// will keep doing stuff with the children in the background
//			if(callback != null) {
//				callback(e);
//			}
			
			trace("Transaction_ChangeAccess: This is a collection, changing access to commentary and assets");
			// needs to do 2 things
			// sets the acls for the comments on the collection
			AppModel.getInstance().getThisAssetsCommentary(assetID, setCommentaryACLs);
			// set the acls for the assets inside this collection
			AppModel.getInstance().getThisCollectionsMediaAssets(assetID, setMediaSharing);
		}
		
		private function setCommentaryACLs(e:Event):void {
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			var commentsForMedia:Array = AppModel.getInstance().extractCommentsFromXML(data);
			
			
			for(var i:Number = 0; i < commentsForMedia.length; i++) {
				var commentData:Model_Commentary = commentsForMedia[i] as Model_Commentary;
				AppModel.getInstance().copyAccess(assetID, commentData.base_asset_id);
			}			
		}
		
		private function setMediaSharing(collectionID:Number, e:Event):void {
			// Get out the returned data
			var data:XML = XML(e.target.data);
			
			var assetArray:Array = AppModel.getInstance().extractAssetsFromXML(data, Model_Media);
			
			// Save the number of media in the collection
			collectionMediaCount = assetArray.length;
			trace("Transaction_ChangeAccess:setMediaSharing - Collection", collectionID, "has", collectionMediaCount, "assets");
				
			for(var i:Number = 0; i < assetArray.length; i++) {
				var annotationData:Model_Media = assetArray[i] as Model_Media;
				
				var transaction:Transaction_ChangeAccess = new Transaction_ChangeAccess(connection);
				transaction.changeAccess(annotationData.base_asset_id, collectionID, username, domain, highestAccessLevel, false, mediaSharingSet);
			}
		}
		
		private function mediaSharingSet(e:Event):void {
			collectionMediaCount--;
			
			if(collectionMediaCount == 0) {
				callback(e);
			}
		}
		

		private function grantAccess(assetID:Number, domain:String, username:String, accessLevel:String, isCollection:Boolean, callback:Function):void {
			
			if(username == Auth.getInstance().getUsername()) {
				// TODO FIX THIS ALL UP! WITH THE REVOKE ETC!!! BLURGH MEDIAFLUX!
				trace("Transaction_ChangeAccess: Cannot change access for current user (Mediaflux problem)", assetID, domain, username);
				
				var args:Object = new Object();				
				
				// We are granting access to the asset for a user
				// Example mediaflux statement asset.acl.grant :acl < :id 1718 :actor system:coke -type user :access read-write >
				var baseXML:XML = connection.packageRequest('asset.acl.grant', args, true);
				baseXML.service.args.acl.id = assetID;
				baseXML.service.args.acl.actor = domain + ":" + username;
				baseXML.service.args.acl.actor.@type = "user";
				baseXML.service.args.acl.content = accessLevel;
				baseXML.service.args.acl.metadata = "read-write";
				// TODO work this out, we always have to keep the meta writable, since the id_sharing is in there
				// and we need to update it.
				
				
				// only update the related assets, if its not a collection
				baseXML.service.args.related = !isCollection;
				
				
				connection.sendRequest(baseXML, function(e:Event):void {
					if(callback != null) {
						callback(e);
					}
				});
				
				return;
			}
			
			// First revoke access, then grant it again (its a problem with fucking mediaflux)
			revokeAccess(assetID, domain, username, isCollection, function(e:Event):void {
				if(XML(e.target.data).reply.@type != "result") {
					trace("Transaction_ChangeAccess: Could not set revoke access for", assetID, domain, username);
					// We couldnt successfully revoke access, tell the controller.
					if(callback != null) {
						callback(e);
					}
				}
				trace("Transaction_ChangeAccess: Access revoked for", assetID, username, e.target.data);
				
				trace("Transaction_ChangeAccess: Granting access on Asset", assetID, domain, username, accessLevel);
				
				var args:Object = new Object();				
				
				// We are granting access to the asset for a user
				// Example mediaflux statement asset.acl.grant :acl < :id 1718 :actor system:coke -type user :access read-write >
				var baseXML:XML = connection.packageRequest('asset.acl.grant', args, true);
				baseXML.service.args.acl.id = assetID;
				baseXML.service.args.acl.actor = domain + ":" + username;
				baseXML.service.args.acl.actor.@type = "user";
				baseXML.service.args.acl.content = accessLevel;
				baseXML.service.args.acl.metadata = "read-write";
				// TODO work this out, we always have to keep the meta writable, since the id_sharing is in there
				// and we need to update it.
				
				
				// only update the related assets, if its not a collection
				baseXML.service.args.related = !isCollection;
				
				
				connection.sendRequest(baseXML, function(e:Event):void {
					trace("Transaction_ChangeAccess: Granting access Result", e.target.data);
					if(callback != null) {
						callback(e);
					}
				});
			});
			
			
			
		}
		
		/**
		 * Revokes access to a given asset ofr a user 
		 * @param assetID	The ID of the asset to revoke access to
		 * @param domain	The domain of the user
		 * @param username	The username of the user
		 * @param related	
		 * @param callback
		 * 
		 */		
		private function revokeAccess(assetID:Number, domain:String, username:String, isCollection:Boolean, callback:Function):void {
			
			trace("Transaction_ChangeAccess: Revoking access on Asset", assetID, domain, username);
			
			var args:Object = new Object();
			// We want to revoke a users access to this asset
			var baseXML:XML = connection.packageRequest('asset.acl.revoke', args, true);
			baseXML.service.args.acl.id = assetID;
			baseXML.service.args.acl.actor = domain + ":" + username;
			baseXML.service.args.acl.actor.@type = "user";
			// only update the related assets, if its not a collection
			baseXML.service.args.related = !isCollection;
			
			if(connection.sendRequest(baseXML, callback)) {
				//All good
			} else {
				Alert.show("Could not change access properties");
			}
		}
	}
}