package Model.Transactions
{
	import Model.Utilities.Connection;
	
	import View.components.Sharing.SharingPanel;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_ChangeAccess
	{
		private var connection:Connection;
		private var callback:Function;
		private var collectionID:Number;
		private var username:String;
		private var domain:String;
		private var access:String;
		private var related:Boolean;
		
		public function Transaction_ChangeAccess(connection:Connection)
		{
			this.connection = connection;
		}
		public function changeAccess(collectionID:Number, username:String, domain:String, access:String, related:Boolean, callback:Function=null):void {
			this.collectionID = collectionID;
			this.username = username;
			this.domain = domain;
			this.access = access;
			this.related = related;
			this.callback = callback;
			
			var args:Object = new Object();
			
			trace("Changing access on collection", collectionID);
			trace("Access for", domain, username, access);
			var baseXML:XML;
			
			trace("Because Mediaflux is shit, it looks like we always need to revoke access, before granting it. SIGH!!!!!");
			// We want to revoke a users access to this asset
			baseXML = connection.packageRequest('asset.acl.revoke', args, true);
			baseXML.service.args.acl.id = collectionID;
			baseXML.service.args.acl.actor = domain + ":" + username;
			baseXML.service.args.acl.actor.@type = "user";
			// Update all the related assets
			baseXML.service.args.related = true;
			
			if(access == SharingPanel.NOACCESS) {
				trace("Only need to revoke access");
				// Send the connection
				if(connection.sendRequest(baseXML, callback)) {
					//All good
				} else {
					Alert.show("Could not change access properties");
				}
			} else {
				if(connection.sendRequest(baseXML, grantAccess)) {
					//All good
				} else {
					Alert.show("Could not change access properties");
				}
			}
		}
		
		private function grantAccess(e:Event):void {
			if(XML(e.target.data).reply.@type != "result") {
				// We couldnt successfully revoke access, tell the controller.
				callback(e);
			}
			// We revoked access successfully. Now grant access.
			var args:Object = new Object();
			
			trace("Changing access on collection", collectionID);
			trace("Access for", domain, username, access);
			var baseXML:XML;
			
			trace("Should be granting access");
			// We are granting access to the asset for a user
			// Example mediaflux statement asset.acl.grant :acl < :id 1718 :actor system:coke -type user :access read-write >
			baseXML = connection.packageRequest('asset.acl.grant', args, true);
			baseXML.service.args.acl.id = collectionID;
			baseXML.service.args.acl.actor = domain + ":" + username;
			baseXML.service.args.acl.actor.@type = "user";
			baseXML.service.args.acl.access = access;
			// Update all the related assets
			baseXML.service.args.related = true;
			
			// Send the connection
			if(connection.sendRequest(baseXML, callback)) {
				//All good
			} else {
				Alert.show("Could not change access properties");
			}
		}
	}
}