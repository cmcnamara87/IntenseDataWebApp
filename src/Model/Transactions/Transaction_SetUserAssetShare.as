package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_SetUserAssetShare
	{
		
		private var username:String;
		private var assetID:Number;
		private var viaAsset:Number;
		private var accessLevel:String;
		private var currentShareCount:Number = 0;
		private var connection:Connection;
		private var callback:Function;
		private var highestAccessLevel:String = SharingPanel.NOACCESS;
		
		public function Transaction_SetUserAssetShare(username:String, assetID:Number, viaAsset:Number, accessLevel:String, connection:Connection, callback:Function = null)
		{
			this.username = username;
			this.assetID = assetID;
			this.viaAsset = viaAsset;
			this.accessLevel = accessLevel;
			this.connection = connection;
			this.callback = callback;
			
			getShare();
		}
		
		private function getShare():void {
			trace("Transaction_SetUserAssetShareCount: Getting share data");
			
			var args:Object = new Object();
			args.id = assetID;

			if(connection.sendRequest(connection.packageRequest('asset.get',args,true), changeShareCount)) {
				//All good
			} else {
				Alert.show("Could not get share count");
			}
		}
		
		private function changeShareCount(e:Event):void {
			var data:XML = XML(e.target.data);
			if(data.reply.@type != "result") {
				// We failed to get the assets meta-data, so we should throw an error.
				trace("Transaction_SetUserAssetShareCount: Failed to get asset meta-data", e.target.data);
//				callback(e);
			}
			trace("Transaction_SetUserAssetShareCount: Got the sharing data");
			
			// Get out the current asset count for this user
			var userShareCounts:XMLList = data.reply.result.asset.meta.id_sharing.user_share_count;

			var args:Object = new Object();
			
			
			var baseXML:XML = connection.packageRequest('asset.set', new Object(), true);
			baseXML.service.args.id = assetID;

			var alreadySharedWithUser:Boolean = false;
			
			baseXML.service.args["meta"]["id_sharing"] = "";				
			for(var i:Number = 0; i < userShareCounts.length(); i++) {
				// Get out the share info
				var shareUser:String = userShareCounts[i]["username"];
				var shareViaAsset:Number = userShareCounts[i]["via_asset"];
				var shareAccessLevel:String = userShareCounts[i]["access_level"];
				
				if(shareUser == username) {
					
					if(shareViaAsset == viaAsset) {
						// We have found some share data for this user on this asset (via the asset it was shared through)
						// so lets update it to what it is now
						shareAccessLevel = accessLevel;
						
						alreadySharedWithUser = true;
					}
					
					// Lets work out the highest access level this user has
					if(shareAccessLevel == SharingPanel.READWRITE) {
						// This is the highest access level, so we can always set it
						highestAccessLevel = SharingPanel.READWRITE;
					} else if (shareAccessLevel == SharingPanel.READ && highestAccessLevel == SharingPanel.NOACCESS) {
						highestAccessLevel = SharingPanel.READ;
					}
				}

				baseXML.service.args["meta"]["id_sharing"].appendChild(XML(
					'<user_share_count>' +
						'<username>' + shareUser + '</username>' +
						'<via_asset>'+ shareViaAsset +'</via_asset>' +
						'<access_level>'+ shareAccessLevel +'</access_level>' +
					'</user_share_count>'
				));					
			}
			
			if(!alreadySharedWithUser) {
				// We havent already shared it, so we can just set its share acces slevel to be whatever it should be
				baseXML.service.args["meta"]["id_sharing"].appendChild(XML(
					'<user_share_count>' +
						'<username>' + username + '</username>' +
						'<via_asset>'+ viaAsset +'</via_asset>' +
						'<access_level>'+ accessLevel +'</access_level>' +
					'</user_share_count>'
				));		
				highestAccessLevel = accessLevel;
			}
			
			// We need to get out the highest access level for this user
			// So that we can set the acls to that e.g. if the access levels for a user, via different assets are
			// read, read, read-write, read - we need to set the acl to be 'read-write' so it all still works				
			
			
			connection.sendRequest(baseXML, function(e:Event):void {
				trace("Transaction_SetUserAssetShareCount: ", e.target.data);
				callback(highestAccessLevel);
			});
		}
	}
}