package Model.Transactions.ERAProject
{
	import flash.events.Event;

	public class Transaction_StayActiveRequest
	{
		public function Transaction_StayActiveRequest(_connection)
		{
			var baseXML:XML = _connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.size = 1;

			_connection.sendRequest(baseXML, stayingAlive);		
		}
		private function stayingAlive(e:Event):void {
		}
	}
}