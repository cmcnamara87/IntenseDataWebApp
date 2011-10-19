package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERALogItem;
	import Model.Model_ERANotification;
	import Model.Utilities.Connection;
	
	import View.ERA.components.EvidenceItem;
	
	import flash.events.Event;

	public class Transaction_UpdateLogItemBooleanValue
	{
		private var year:String;
		private var roomID:Number;
		private var logItemID:Number;
		private var elementName:String;
		private var value:Boolean;
		private var connection:Connection;
		private var evidenceItem:EvidenceItem;
		private var callback:Function;
	
		public function Transaction_UpdateLogItemBooleanValue(year:String, roomID:Number, logItemID:Number, elementName:String, value:Boolean, evidenceItem:EvidenceItem, _connection:Connection, callback:Function):void {
			this.year = year;
			this.roomID = roomID;
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
			
			// send notifications if they are marked as for collection or collected
			if(elementName == Model_ERALogItem.FOR_COLLECTION) {
				AppModel.getInstance().createERANotification(this.year, this.roomID, Auth.getInstance().getUsername(), 
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, Model_ERANotification.EVIDENCE_READY_FOR_COLLECTION, 0, logItemID);
			} else if (elementName == Model_ERALogItem.COLLECTED) {
				AppModel.getInstance().createERANotification(this.year, this.roomID, Auth.getInstance().getUsername(), 
					Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, Model_ERANotification.EVIDENCE_COLLECTED, 0, logItemID);
			}
			
			var eraLogItem:Model_ERALogItem = new Model_ERALogItem();
			eraLogItem.setData(data.reply.result.asset[0]);
			
			callback(true, eraLogItem, evidenceItem);
		}
		
	}
}