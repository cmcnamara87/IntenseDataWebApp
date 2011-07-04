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
			
			findAssetsWithSharing();
				
			// 1. delete the user from the system
			// 2. remove any acls that user had on the system
			// 3. delete all assets uploaded by that user (where they are the creator of)
			// 4. remove share access in share object for the user
		}
		
		private function deleteUserObjectFromSystem():void {
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest('user.destroy',args,true);
			baseXML.service.args["user"] =  this.username;
			baseXML.service.args["domain"] = this.domain;
			if(connection.sendRequest(baseXML,callback)) {
				//All good
			} else {
				Alert.show("Could not delete user");
				trace("Could not delete user");
			}
		}
		
		/**
		 * Finds all instances where the actor for an ACL is invalid
		 * and removes the ACL (doesnt just do it for this user, but works regardless) 
		 * 
		 */		
		private function removeUsersACLsOnAssets():void {
			var args:Object = new Object();
			args.where = '"acl actor invalid"';
			args.action = "pipe";
			var baseXML:XML = connection.packageRequest("asset.query", args, true);
			baseXML.service.args.service.@name = "asset.acl.invalid.remove";
			if(connection.sendRequest(baseXML,callback)) {
				//All good
			} else {
				Alert.show("Could not remove user acls");
				trace("Could not remove user acls");
			}
		}
		
		/**
		 * Deletes all the assets that were created by this user 
		 * 
		 */		
		private function deleteAllUsersAssets():void {
			// doesnt work at the moment!!! RAARRR!!!!
		}
		
		private function findAssetsWithSharing():void {
			//asset.query :where id_sharing/user_share_count/username='andrewb'
			var args:Object = new Object();
			args.where = "id_sharing/user_share_count/username='" + this.username + "'";
			var baseXML:XML = connection.packageRequest("asset.query", args, true);
			if(connection.sendRequest(baseXML, removeSharing)) {
				// All good
			} else {
				Alert.show("Could not remove sharing");
				trace("Could not remove sharing");
			}
		}
		
		private function removeSharing(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				callback(e);
				return;
			}
			trace("removeSharing:", e.target.data);
			
			var dataXML:XML = XML(e.target.data);
			var assets:Array = new Array();
			var assetsXML:XMLList = dataXML.reply.result.id;
			assetsWithSharingCount = assetsXML.length();
			
			for each(var id:Number in assetsXML) {
				// Remove the users access to this asset
				trace("Sharing", id);
				var transaction:Transaction_RemoveShare = new Transaction_RemoveShare(username, id, connection, sharingRemoved);
			}
		}
		
		private function sharingRemoved(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				
			}
			assetsWithSharingCount--;
			if(assetsWithSharingCount == 0) {
				trace("All assets sharing has been removed");
				callback(e);
			}
		}
	}
}