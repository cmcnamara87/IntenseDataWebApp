package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_ERAChangeUserPassword
	{
		private var domain:String;
		private var username:String;
		private var newPassword:String;
		private var oldPassword:String;
		private var callback:Function;
		private var connection:Connection;
		
		public function Transaction_ERAChangeUserPassword(username:String, oldPassword:String, newPassword:String, connection:Connection, callback:Function) {
			this.username = username;
			this.oldPassword = oldPassword;
			this.newPassword = newPassword;
			this.connection = connection;
			this.callback = callback;
			
			changePassword();
		}
		
		private function changePassword():void {
			var baseXML:XML = connection.packageRequest("user.password.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create teh sys-admin role
			argsXML.user = username;
			argsXML.domain = "system";
			argsXML["old-password"] = oldPassword;
			argsXML.password = newPassword
			
			// Send the request
			connection.sendRequest(baseXML, passwordUpdated);
		}
		
		private function passwordUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("user password changed", e)) == null) {
				callback(false);
				return;
			} else {
				Auth.getInstance().setPassword(newPassword);
				callback(true);
				return;
			}
			
		}
	}
}