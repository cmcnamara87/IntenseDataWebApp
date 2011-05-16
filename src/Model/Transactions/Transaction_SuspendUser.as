package Model.Transactions
{
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_SuspendUser
	{
		private var username:String;
		private var domain:String;
		private var callback:Function;
		private var connection:Connection;
		
		// The string to set a user's password to, when they are suspended
		// TODO THIS IS DISGUSTING BUT IT BEATS DEALING WITH MEDIAFLUX !!!!!
		private static var SUSPENDED_PASSWORD_STRING:String = '6194489882';
		
		public function Transaction_SuspendUser(username:String, domain:String, callback:Function, connection:Connection):void
		{
			trace("suspending user");
			this.username = username;
			this.domain = domain;
			this.callback = callback;
			this.connection = connection;
			
			revokeIDUserRole();
		}
		

		/**
		 * Revoke ID User role
		 * 
		 */		
		private function revokeIDUserRole():void {
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest('actor.revoke', args, true);
			// The username of the user (we append the domain as mediaflux requires it)
			baseXML.service.args.name = domain + ":" + username;
			// The we are removing a actor of type USER
			baseXML.service.args.type = "user";
			
			// We are going to remove the USER role
			baseXML.service.args.role = "iduser";
			// And we are removing a role
			baseXML.service.args.role.@type = "role";
			
			connection.sendRequest(baseXML, setMetaSuspended);
		}
		
		private function setMetaSuspended(e:Event):void {
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest('user.set',args,true);
			baseXML.service.args["user"] = username;
			baseXML.service.args["domain"] = "system";
			baseXML.service.args["meta"]["r_user"]["password"] = "suspended";
			connection.sendRequest(baseXML, callback);
		}
	}
}