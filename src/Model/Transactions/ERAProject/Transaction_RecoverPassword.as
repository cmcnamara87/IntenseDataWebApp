package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_RecoverPassword
	{
		private var username:String;
		private var connection:Connection;
		private var callback:Function;
		
		private var sessionID:String = "";
		
		public function Transaction_RecoverPassword(username:String, connection:Connection, callback:Function)
		{
			this.username = username;
			this.connection = connection;
			this.callback = callback;
			
			loginAsRecoverer();
		}
		
		private function loginAsRecoverer():void {
			// so what we need to do is
			// first log in as an password resetter account (only has access tor eset password)
			// run the reset
			// then log back out
			AppModel.getInstance().login("password_resetter", "resetter", loginCallback); 
		}
		
		//Returned from the login mediaflux call.  Returns a Session ID if successful
		private function loginCallback(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			trace("login callback", e.target.data);
			if (dataXML.reply.@type == "result") {
				
				// get out the session ID we need to do the reset
				trace("session is", dataXML..session);
				Auth.getInstance().setSessionID(dataXML..session);
				trace("session saved", Auth.getInstance().getSessionID());
				
				// Successfully logged in
				resetPassword();
				
			} else {			
				callback(false, "Failed to change password");
			}
		}
		
		private function resetPassword():void {
			var baseXML:XML = connection.packageRequest("user.password.reset", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// put it in the namespace for this era
			argsXML.domain = "system";
			argsXML.user = username;
			argsXML.subject = "nQuisitor Password Reset";
			argsXML.body = "Hi $${user}$$, Your nQuisitor password has been reset to: $${password}$$";
			
			trace("reset request:", baseXML);
			connection.sendRequest(baseXML, passwordReset);
		}
		
		private function passwordReset(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("resetting password", e)) == null) {
				callback(false, "Failed to change password");
			} else {
				trace("Change password successful");
				callback(true, "Password sent to your email address");
				Auth.getInstance().setSessionID("");
			}
		}
	}
}