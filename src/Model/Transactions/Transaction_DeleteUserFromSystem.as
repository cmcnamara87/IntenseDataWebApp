package Model.Transactions
{
	import Model.AppModel;
	import Model.Transactions.Share.Transaction_RemoveShare;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	/**
	 * Removes a user from the system. Destroys all assets they have uploaded
	 * and removes access and sharing to any assets they have access to. 
	 * @author cmcnamara87
	 * 
	 */	
	public class Transaction_DeleteUserFromSystem
	{
		private var username:String; // The username of the user to delete
		private var domain:String; // The domain of the user (e.g. System)
		private var connection:Connection;
		private var callback:Function;
		
		private var assetsWithSharingCount:Number = 0; // Number of assets with sharing
		
		public function Transaction_DeleteUserFromSystem(username:String, domain:String, callback:Function, connection:Connection)
		{
			this.username = username;
			this.domain = domain;
			this.connection = connection;
			this.callback = callback;
			
			//deleteUserObjectFromSystem();
			
//			deleteUserObjectFromSystem();
			
			deleteAllUsersAssets();
				
			
			// 3. delete all assets uploaded by that user (where they are the creator of)
			// 4. remove share access in share object for the user
			// 2. remove any acls that user had on the system
			// 1. delete the user from the system
			
		}
		
		/**
		 * Deletes all the assets that were created by this user 
		 * 
		 */		
		private function deleteAllUsersAssets():void {
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.where = "r_base/creator='" + username + "'";
			argsXML.action = "pipe";
			argsXML.service.@name = "asset.destroy";
			if(!connection.sendRequest(baseXML, findSharedAssets)) {
				Alert.show("Failed to delete all user assets");
			}	
		}
		
		
		/**
		 * Find the list of assets where the user has a share
		 * 
		 */		
		private function findSharedAssets(e:Event):void {
			if(AppModel.getInstance().callFailed("deleteAllUsersAssets", e)) {
				callback(e);
				return;
			}
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest("asset.query", args, true);
			var argsXML:XMLList = baseXML.service.args;			
			argsXML.where = "id_sharing/user_share_count/username='" + this.username + "'";
			if(connection.sendRequest(baseXML, removeSharing)) {
				//All good
			} else {
				Alert.show("Could not remove user acls");
				trace("Could not remove user acls");
			}
		}
		
		private function removeSharing(e:Event):void {
			if(AppModel.getInstance().callFailed("findSharedAssets", e)) {
				callback(e);
				return;
			} 
			
			// Get out the list of asset IDs that have sharing infp
			var dataXML:XML = XML(e.target.data);
			var assets:Array = new Array();
			var assetsXML:XMLList = dataXML.reply.result.id;
			// Store how many asest we have to remove the sharing on, so we can count down
			// to them all being down
			assetsWithSharingCount = assetsXML.length();
			
			if(assetsWithSharingCount == 0) {
				// Don't need to change access to anything
				deleteUserObjectFromSystem(e);
			}
			
			for each(var id:Number in assetsXML) {
				// Remove the sharing for htis asset
				trace("Sharing", id);
				var transaction:Transaction_RemoveShare = new Transaction_RemoveShare(username, id, connection, sharingRemoved);

				// Remove the ACL for this asset
				var baseXML:XML = connection.packageRequest("asset.acl.revoke", new Object(), true);
				var argsXML:XMLList = baseXML.service.args;			
				argsXML.acl.id = id;
				argsXML.acl.actor = domain + ":" + username;
				argsXML.acl.actor.@type = "user";

				if(connection.sendRequest(baseXML, function(e:Event):void {
					if(AppModel.getInstance().callFailed("removingACLs", e)) {
						// dont really care to be honest.
					} 
				})) {
					//All good
				} else {
					Alert.show("Could not change access properties");
				}
				
			}
		}
		
		private function sharingRemoved(e:Event):void {
			if(AppModel.getInstance().callFailed("removeSharing", e)) {
				callback(e);
				return;
			}
			assetsWithSharingCount--;
			if(assetsWithSharingCount == 0) {
				trace("All assets sharing has been removed");
				deleteUserObjectFromSystem(e);
			}
		}
		
		
		/**
		 * Deletes a user from the system. 
		 * 
		 */		
		private function deleteUserObjectFromSystem(e:Event = null):void {
			if(e != null && AppModel.getInstance().callFailed("sharingRemoved", e)) {
				callback(e);
				return;
			}
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest('user.destroy',args,true);
			baseXML.service.args["user"] =  this.username;
			baseXML.service.args["domain"] = this.domain;
			if(connection.sendRequest(baseXML, removeUsersACLsOnAssets)) {
				//All good
			} else {
				Alert.show("Could not delete user");
				trace("Could not delete user");
			}
		}
		
		/**
		 * Finds all instances where the actor for an ACL is invalid
		 * and removes the ACL (doesnt just do it for this user, but works on all invalids acls) 
		 * 
		 */		
		private function removeUsersACLsOnAssets(e:Event):void {
			if(AppModel.getInstance().callFailed("deleteUserObjectFromSystem", e)) {
				callback(e);
				return;
			}
			
			var args:Object = new Object();
			args.where = "acl actor invalid";
			args.action = "pipe";
			var baseXML:XML = connection.packageRequest("asset.query", args, true);
			baseXML.service.args.service.@name = "asset.acl.invalid.remove";
			if(connection.sendRequest(baseXML, removeComplete)) {
				//All good
			} else {
				Alert.show("Could not remove user acls");
				trace("Could not remove user acls");
			}
		}
		
		private function removeComplete(e:Event):void {
			if(AppModel.getInstance().callFailed("removeUsersACLsOnAssets", e)) {
				callback(e);
				return;
			}
			callback(e);
		}
		
		

	}
}