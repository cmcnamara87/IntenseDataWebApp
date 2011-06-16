package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;

	/**
	 * Deletes media from a user. If the user is the creator of the media, the only user with access to the file,
	 * or the system administrator, the file will be deleted from the system. Otherwise, the user will just
	 * have their access to the file revoked, so they can no longer see it.
	 * 
	 * @author cmcnamara87
	 * 
	 */	
	public class Transaction_DeleteMediaFromUser
	{
		private var assetID:Number;
		private var creatorUsername:String;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_DeleteMediaFromUser(assetID:Number, creatorUsername:String, connection:Connection, callback:Function)
		{
			trace("Deleting a file", assetID);
			this.assetID = assetID;
			this.creatorUsername = creatorUsername;
			this.connection = connection;
			this.callback = callback;
			
			if(Auth.getInstance().isSysAdmin() || creatorUsername == Auth.getInstance().getUsername()) {
				trace("Either the sys admin, or, the current user is the creator of the file, so delete it");
				AppModel.getInstance().assetDestroy(assetID, deleteComplete);
			} else {
				// get the users that have access to this file
				trace("Getting people who have access to this file");
				getUsersWithAccessToThisAsset();
			}
		}
		
		private function getUsersWithAccessToThisAsset():void {
			var args:Object = new Object();
			args.id = this.assetID;
			connection.sendRequest(
				connection.packageRequest('asset.acl.describe', args, true), 
				gotUserList
			);
		}
			
		private function gotUserList(e:Event):void {
			trace("get users with access", e.target.data);
			
			// Get out the ACL from the media object in the reply
			var acls:XMLList = XML(e.target.data).reply.result.asset.acl;
			
			if(acls.length() == 1) {
				// There is only one user with access to this file, it must be the current user
				// otherwise how could they see it
				// <= just as a precaution
				trace("Only one user has access to file", acls[0].actor, "current user is", Auth.getInstance().getUsername());
				AppModel.getInstance().assetDestroy(assetID, deleteComplete);
			} else if (acls.length() == 0) {
				trace("No user has access to this file, destroying it");
				AppModel.getInstance().assetDestroy(assetID, deleteComplete);
			} else {
				// Other people are still using this file, only
				// remove this current users access to it, so it remains unchanged for others
				AppModel.getInstance().changeAccess(assetID, Auth.getInstance().getUsername(),
					"system", SharingPanel.NOACCESS, false, deleteComplete);
				
				
			}
		}
			
		private function deleteComplete(e:Event):void {
			trace("delete compelte", e.target.data);
			callback(e);
			
		}
		
	}
}