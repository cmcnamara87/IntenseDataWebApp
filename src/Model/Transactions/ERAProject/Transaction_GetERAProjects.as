package Model.Transactions.ERAProject
{
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetERAProjects
	{
		private var connection:Connection; 
		private var callback:Function;
		
		public function Transaction_GetERAProjects(connection:Connection, callback:Function)
		{
			this.connection = connection;
			this.callback = callback;
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "namespace>=ERA and type=ERA-project";
			argsXML.action = "get-meta";
			
			connection.sendRequest(baseXML, gotERAProjects);
		}
		
		private function gotERAProjects(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting era projects", e)) == null) {
				callback(false, null);
				return;
			}
			
			var ERAProjectArray:Array = AppModel.getInstance().extractAssetsFromXML(data, Model_ERAProject);
			
			ERAProjectArray.sortOn(["year"], [Array.DESCENDING]);
			
			callback(true, ERAProjectArray);
		}
	}
}