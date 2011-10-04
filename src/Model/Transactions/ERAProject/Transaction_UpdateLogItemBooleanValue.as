package Model.Transactions.ERAProject
{
	import Model.Utilities.Connection;

	public class Transaction_UpdateLogItemBooleanValue
	{
		private var logItemID:Number;
		private var fieldToUpdate:String;
		private var value:Boolean;
		private var connection:Connection;
		private var callback:Function;
	
		public function Transaction_UpdateLogItemBooleanValue(logItemID:Number, fieldToUpdate:String, value:Boolean, connection:Connection, callback:Function):void {
		
		}
	}
}