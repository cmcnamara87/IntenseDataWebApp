package Model.Transactions.ERAProject
{
	import Model.Utilities.Connection;

	public class Transaction_CreateERAProject
	{
		private var day:String;
		private var month:String;
		private var year:String;
		private var packageSize:String;
		private var connection:Connection;
		
		public function Transaction_CreateERAProject(day:String, month:String, year:String, packageSize:String, connection:Connection)
		{
			this.day = day;
			this.month = month;
			this.year = year;
			this.packageSize = packageSize;
			this.connection = connection;
		}
		
		private function createERANamespace():void {
			var baseXML:XML = connection.packageRequest('asset.namespace.create', new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.namespace = "ERA/" + this.year;
			connection.sendRequest(baseXML, createERAProject);
		}
		
		private function createERAProject():void {
			var baseXML:XML = connection.packageRequest("asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.namespace = "ERA/" + this.year;
			argsXML.namespace.@create = true;
			
			argsXML.meta["ERA-project"]
			
		}
	}
}