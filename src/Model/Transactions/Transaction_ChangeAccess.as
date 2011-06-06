package Model.Transactions
{
	import Model.AppModel;
	import Model.Model_Notification;
	import Model.Utilities.Connection;
	
	import View.components.Sharing.SharingPanel;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_ChangeAccess
	{
		private var connection:Connection;
		private var access:String;
		private var assetID:Number;
		private var username:String;
		private var callback:Function;
		
		public function Transaction_ChangeAccess(connection:Connection)
		{
			this.connection = connection;
		}
		
		/**
		 * Changes the access (ACL) for a given asset. (collection, media, etc) 
		 * @param collectionID	The ID of the collection where we want to grant/restrict access
		 * @param username		The username of the user to be granted/restricted access
		 * @param domain		The domain of that user
		 * @param access		The access for that users, @see SharingPanel consts (e.g. READ, READWRITE, NOACESS)
		 * @param related		Change the access for related assets, e.g. TRUE for a collection, since we want 
		 * 						it to propogate to the assets inside it, but FALSE for a mediaAsset since we dont want the ACLS
		 * 						on our annotations.
		 * @param callback		The function to call when the access has be chagned.
		 * 
		 */		
		public function changeAccess(assetID:Number, username:String, domain:String, access:String, related:Boolean, callback:Function=null):void {
			this.assetID = assetID;
			this.username = username;
			this.access = access;
			
			var args:Object = new Object();
			
			trace("Changing access on asset", assetID);
			trace("Access for", domain, username, access);
			var baseXML:XML;
			
			if(access == SharingPanel.NOACCESS) {
				trace("Should be revoking access");
				// We want to revoke a users access to this asset
				baseXML = connection.packageRequest('asset.acl.revoke', args, true);
				baseXML.service.args.acl.id = assetID;
				baseXML.service.args.acl.actor = domain + ":" + username;
				baseXML.service.args.acl.actor.@type = "user";
				// Update all the related assets
				baseXML.service.args.related = related;
				
				
			} else {
				trace("Should be granting access");
				// We are granting access to the asset for a user
				// Example mediaflux statement asset.acl.grant :acl < :id 1718 :actor system:coke -type user :access read-write >
				baseXML = connection.packageRequest('asset.acl.grant', args, true);
				baseXML.service.args.acl.id = assetID;
				baseXML.service.args.acl.actor = domain + ":" + username;
				baseXML.service.args.acl.actor.@type = "user";
				baseXML.service.args.acl.access = access;
				// Update all the related assets
				baseXML.service.args.related = related;
			}
			
			// Send the connection
			if(connection.sendRequest(baseXML, callback)) {
				//All good
			} else {
				Alert.show("Could not change access properties");
			}
		}
		
		private function notify(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			if(dataXML.reply.@type == "result") {
				// The annotation saved successfully
				trace("- Access Chnanged");
				trace("****************************");
				//AppModel.getInstance().sendNotification(mediaID, Model_Notification.MEDIA_SHARED, annotationID);
			}
			// Either it saved successfully, or it didnt, either way, tell the controller	
			callback(e);
		}
		
	}
}