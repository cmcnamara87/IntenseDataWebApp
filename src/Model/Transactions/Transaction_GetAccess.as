package Model.Transactions {
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	public class Transaction_GetAccess {
		
		private var _assetID:Number;
		private var _callback:Function;
		private var _connection:Connection;
		private var userlist:Array = new Array();
		
		// Constructor
		public function Transaction_GetAccess(connection:Connection,assetID:Number,callback:Function) {
			_connection = connection;
			_assetID = assetID;
			_callback = callback;
			getUserList();
		}
		
		// Asks mediaflux for all the users for the domain "system"
		private function getUserList():void {
			var args:Object = new Object();
			args.domain = "system";
			var baseXML:XML = _connection.packageRequest('user.describe',args,true);
			if(_connection.sendRequest(baseXML,usersLoaded)) {
				//All good
			} else {
				Alert.show("Could not get user list");
			}
		}
		
		// Called when the user list is returned.  Calls getAccessRights()
		private function usersLoaded(e:Event):void {
			var data:XML = XML(e.target.data);
			for each(var _user:XML in data.reply.result.user) {
				if(_user.@user != Auth.getInstance().getUsername()) {
					userlist.push([_user.@user,"none"]);
				}
			}
			getAccessRights();
		}
		
		// Asks mediaflux for who has what access to the asset
		private function getAccessRights():void {
			var args:Object = new Object();
			args.id = _assetID;
			var baseXML:XML = _connection.packageRequest('asset.acl.describe',args,true);
			if(_connection.sendRequest(baseXML,accessRightsLoaded)) {
				//All good
			} else {
				Alert.show("Could not get access list");
			}
		}
		
		// Updates the user list with those who have read or read-write access
		private function accessRightsLoaded(e:Event):void {
			var data:XML = XML(e.target.data);
			for each(var _acl:XML in data.reply.result.asset.acl) {
				var actorName:String = _acl.actor.toString();
				actorName = actorName.substr(actorName.indexOf(":")+1);
				for(var i:Number=0; i<userlist.length; i++) {
					if(userlist[i][0] == actorName) {
						userlist[i][1] = _acl.metadata.toString();
						break;
					}
				}
			}
			returnUserData();
		}
		
		// Returns the information back to the controller which called it
		private function returnUserData():void {
			_callback(userlist);
		}
	}
}