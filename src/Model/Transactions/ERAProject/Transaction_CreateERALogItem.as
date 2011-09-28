package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERALogItem;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	/**
	 * Creates an ERA log item.
	 * 
	 * Stores in mflux a piece of evidence (before its been uploaded etc)
	 *  
	 * @author cmcnamara87
	 * 
	 */
	public class Transaction_CreateERALogItem
	{
		private var year:String;
		private var caseID:Number;
		private var type:String;
		private var title:String;
		private var description:String;
		
		private var callback:Function;
		private var connection:Connection;
		
		private var logItemID:Number; // id returned after saved
			
		/**
		 * Creates an ERA log Item
		 *  
		 * @param caseID
		 * @param type
		 * @param title
		 * @param description
		 * @param connection
		 * @param callback
		 * 
		 */
		public function Transaction_CreateERALogItem(year:String, caseID:Number, type:String, title:String, description:String, connection:Connection, callback:Function):void {
			this.year = year;
			this.caseID = caseID;
			this.type = type;
			this.title = title;
			this.description = description;
			
			this.connection = connection;
			this.callback = callback;
			
			createERALogItem();
			
		}

		

		private function createERALogItem():void {
			var baseXML:XML = connection.packageRequest("asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create a namespace for this era
			argsXML.namespace = "ERA/" + this.year;
			
			argsXML.type = "ERA/logitem";
			
			// Setup the era meta-data
			argsXML.meta["ERA-log"]["type"] = this.type;
			argsXML.meta["ERA-log"]["title"] = this.title;
			if(description != "") {
				argsXML.meta["ERA-case"]["description"] = this.description;
			}
			argsXML.meta["ERA-log"]["useful"] = false;
			argsXML.meta["ERA-log"]["processed"] = false;
			argsXML.meta["ERA-log"]["uploadable"] = false;
			argsXML.meta["ERA-log"]["uploaded"] = false;
			argsXML.meta["ERA-log"]["returned"] = false;

			connection.sendRequest(baseXML, eraLogItemCreated);
		}
		
		private function eraLogItemCreated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("era log item created", e)) == null) {
				callback(false, null);
				return;
			}	
			
			logItemID = data.reply.result.id;
			
			// Get out the ERA log item
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = logItemID;
			
			connection.sendRequest(baseXML, eraLogItemRetrieved);
		}
		
		private function eraLogItemRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting era log item", e)) == null) {
				callback(false, null);
				return
			}
			
			var eraLogItem:Model_ERALogItem = new Model_ERALogItem();
			eraLogItem.setData(data.reply.result.asset[0]);
			
			callback(true, eraLogItem);
		}
		
	}
}