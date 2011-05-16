package Model.Transactions {
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	public class Transaction_SetAccess {
		
		private var _assetID:Number;
		private var _access:Array;
		private var _callback:Function;
		private var _connection:Connection;
		
		// Constructor (calls revokeAccess())
		public function Transaction_SetAccess(connection:Connection,assetID:Number,access:Array,callback:Function) {
			_connection = connection;
			_assetID = assetID;
			_access = access;
			_callback = callback;
			revokeAccess();
		}
		
		//Asks mediaflux to revoke all access from this asset
		private function revokeAccess():void {
			var args:Object = new Object();
			args.id = _assetID;
			var baseXML:XML = _connection.packageRequest('asset.acl.revoke',args,true);
			for(var i:Number=0; i<_access.length; i++) {
				//trace("Removing access for:", _access[i][0]);
				baseXML.service.args.appendChild(XML('<acl><actor type="user">system:'+_access[i][0]+'</actor></acl>'));
			}
			if(_connection.sendRequest(baseXML,accessRevoked)) {
				//All good
			} else {
				Alert.show("Could not change access properties");
			}
		}
		
		// Called when all access has been revoked, then calls grant access for appropriate parties
		private function accessRevoked(e:Event):void {
			grantAccess();
		}
		
		// Creates new ACLs for users who now have access to the asset
		private function grantAccess():void {
			var args:Object = new Object();
			args.id = _assetID;
			var baseXML:XML = _connection.packageRequest('asset.acl.grant',args,true);
			for(var i:Number=0; i<_access.length; i++) {
				if(_access[i][1] != "none") {
					//trace("Granting access for:", _access[i][0], _access[i][1] );
					baseXML.service.args.appendChild(XML('<acl><actor type="user">system:'+_access[i][0]+'</actor><access>'+_access[i][1]+'</access></acl>'));
				}
			}
			if(_connection.sendRequest(baseXML,accessGranted)) {
				//All good
			} else {
				Alert.show("Could not change access properties");
			}
		}
		
		// Returns the information back to the controller which called it
		private function accessGranted(e:Event):void {
			if(_callback != null) {
				_callback(e);
			}
		}		
	}
}