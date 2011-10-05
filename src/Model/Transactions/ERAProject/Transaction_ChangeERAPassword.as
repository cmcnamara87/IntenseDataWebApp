package Model.Transactions.ERAProject
{
	import Model.Utilities.Connection;

	public class Transaction_ChangeERAPassword
	{
		private var username:String;
		private var oldPassword:String;
		private var newPassword:String;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_ChangeERAPassword(username:String, oldPassword:String, newPassword:String, connection:Connection, callback:Function)
		{
			this.username = username;
			this.oldPassword = oldPassword;
			this.newPassword = newPassword;
			this.connection = connection;
			this.callback = callback;
			
			changePassword();
		}
		
		private function changePassword():void {
			
		}
	}
}