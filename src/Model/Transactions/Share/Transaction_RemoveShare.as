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
			
			if(connection.sendRequest(connection.packageRequest('asset.get',args,true), changeShareCount)) {
				//All good
			} else {
				Alert.show("Could not get share count");
			}
		}
		
		private function changeShareCount(e:Event):void {
			
			if(!AppModel.getInstance().callSuccessful(e)) {
				// We failed to get the assets meta-data, so we should throw an error.
				trace("Transaction_RemoveShare: Failed to get asset meta-data", e.target.data);
				callback(e);
				return;
			}
			
			var data:XML = XML(e.target.data);
			
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
				
				if(shareUser != username) {
					
					baseXML.service.args["meta"]["id_sharing"].appendChild(XML(
						'<user_share_count>' +
						'<username>' + shareUser + '</username>' +
						'<via_asset>'+ shareViaAsset +'</via_asset>' +
						'<access_level>'+ shareAccessLevel +'</access_level>' +
						'</user_share_count>'
					));	
				}
			}

			connection.sendRequest(baseXML, function(e:Event):void {
				if(!AppModel.getInstance().callSuccessful(e)) {
					trace("Transaction_RemoveShare: Failed to Change User Access Meta");
					callback(e);
					return;
				}
				
				trace("Transaction_RemoveShare: Changed Successfully");
				callback(e);
			});
		}
	}
}