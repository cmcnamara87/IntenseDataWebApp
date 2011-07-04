package Model.Transactions.Share
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	public class Transaction_RemoveShare
	{
		
		private var username:String;
		private var assetID:Number;
		private var connection:Connection;
		private var callback:Function;
		private var highestAccessLevel:String = SharingPanel.NOACCESS;
		
		private var userShareCounts:XMLList; // holds the sharing info for an asset
		
		public function Transaction_RemoveShare(username:String, assetID:Number, connection:Connection, callback:Function = null)
		{
			this.username = username;
			this.assetID = assetID;
			this.connection = connection;
			this.callback = callback;
			
			getShare();
		}
		
		private function getShare():void {
			trace("Transaction_RemoveShare: Getting share data for", username, assetID);
			
			var args:Object = new Object();
			args.id = assetID;
			
			if(connection.sendRequest(connection.packageRequest('asset.get',args,true), removeIDSharingMeta)) {
				//All good
			} else {
				Alert.show("Could not get share count");
			}
		}
		
		private function removeIDSharingMeta(e:Event):void {
			if(AppModel.getInstance().callFailed("getShare", e)) {
				callback(e);
				return;
			}	
			
			// save the user share counts
		 	userShareCounts = XML(e.target.data).reply.result.asset.meta.id_sharing.user_share_count;
		
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest('asset.set', new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = assetID;
			argsXML.meta.id_sharing = "";	
			argsXML.meta.@action = "remove";
			
			connection.sendRequest(baseXML, changeShareCount);
		}
		
		private function changeShareCount(e:Event):void {
			if(AppModel.getInstance().callFailed("removeIDSharingMeta " + assetID, e)) {
				callback(e);
				return;
			}
			
			var args:Object = new Object();
			
			
			var baseXML:XML = connection.packageRequest('asset.set', new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = assetID;
			
			var alreadySharedWithUser:Boolean = false;
			
			argsXML.meta.id_sharing = "";	
			for(var i:Number = 0; i < userShareCounts.length(); i++) {
				// Get out the share info
				var shareUser:String = userShareCounts[i]["username"];
				var shareViaAsset:Number = userShareCounts[i]["via_asset"];
				var shareAccessLevel:String = userShareCounts[i]["access_level"];
				
				// Add only the users that arent the current user
				if(shareUser != this.username) {
					trace("Transaction_RemoveShare:changeShareCount -", assetID, "Adding stuff for user", shareUser); 
					baseXML.service.args["meta"]["id_sharing"].appendChild(XML(
						'<user_share_count>' +
						'<username>' + shareUser + '</username>' +
						'<via_asset>'+ shareViaAsset +'</via_asset>' +
						'<access_level>'+ shareAccessLevel +'</access_level>' +
						'</user_share_count>'
					));	
				} else {
					trace("Transaction_RemoveShare:changeShareCount -", assetID, "Not including stuff for user", shareUser);
				}
			}

			connection.sendRequest(baseXML, function(e:Event):void {
				if(AppModel.getInstance().callFailed("removingAccess " + assetID, e)) {
				}
				callback(e);
			});
		}
	}
}