package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERALogItem;
	import Model.Utilities.Connection;
	
	import View.ERA.components.EvidenceItem;
	
	import flash.events.Event;

	public class Transaction_UpdateLogItemBooleanValue
	{
		private var logItemID:Number;
		private var elementName:String;
		private var value:Boolean;
		private var connection:Connection;
		private var evidenceItem:EvidenceItem;
		private var callback:Function;
	
		public function Transaction_UpdateLogItemBooleanValue(logItemID:Number, elementName:String, value:Boolean, evidenceItem:EvidenceItem, _connection:Connection, callback:Function):void {
			this.logItemID = logItemID;
			this.elementName = elementName;
			this.value = value;
			this.evidenceItem = evidenceItem;
			this.connection = _connection;
			this.callback = callback;
			
			updateLogItem();
		}
		
		private function updateLogItem():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = logItemID;
				
			// Setup the era meta-data
			argsXML.meta["ERA-log"][elementName] = value;
			
			connection.sendRequest(baseXML, eraLogItemUpdated);	
		}			
		
		private function eraLogItemUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating log item", e)) == null) {
				callback(false, null);
				return;
			}
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = logItemID;
			
			connection.sendRequest(baseXML, eraLogItemRetrieved);
		}
		
		private function eraLogItemRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting updated log item", e)) == null) {
				callback(false);
				return
			}
			
			var eraLogItem:Model_ERALogItem = new Model_ERALogItem();
			eraLogItem.setData(data.reply.result.asset[0]);
			
			callback(true, eraLogItem, evidenceItem);
		}
		
	}
}