package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_ChangePassword
	{
		private var domain:String;
		private var newPassword:String;
		private var callback:Function;
		private var connection:Connection;
		
		public function Transaction_ChangePassword(domain:String, newPassword:String, callback:Function, connection:Connection)
		{
			this.domain = domain;
			this.newPassword = newPassword;
			this.callback = callback;
			this.connection = connection;
			
			changePassword();
		}
		
		private function changePassword():void {
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest('user.password.set',args,true);
			// The current user
			baseXML.service.args["user"] = Auth.getInstance().getUsername();
			// The current users domain
			baseXML.service.args["domain"] = domain;
			// The old password for hte user
			baseXML.service.args["old-password"] = Auth.getInstance().getPassword();
			// The new password
			baseXML.service.args["password"] = newPassword;
			// Send the request
			connection.sendRequest(baseXML, updateAuthPassword);
		}
		
		/**
		 * Update the auth information with the new saved password (if it worked) 
		 * @param e
		 * 
		 */		
		private function updateAuthPassword(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			
			if(dataXML.reply.@type == "result") {
				// Password changed successfully,
				// Update the auth information
				Auth.getInstance().setPassword(newPassword);
			} 
			callback(e);
		}
		
	}
}