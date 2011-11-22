package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAConversation;
	import Model.Model_ERAFile;
	import Model.Model_ERALogItem;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetAllConversation
	{
		private var connection:Connection;
		private var callback:Function;
		private var roomID:Number;
		private var objectID:Number;
		private var year:String;

		public function Transaction_GetAllConversation(year:String, objectID:Number, roomID:Number, connection:Connection, callback:Function)
		{
			this.year = year;
			this.connection = connection;
			this.callback = callback;
			this.objectID = objectID;
			this.roomID = roomID;
			getAllConversation();
		}
		
		private function getAllConversation():void {
			// asset.query :where asset in collection <id>
			
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.action = "get-meta";
			argsXML.size = "infinity";
			
			// Get all the media for the room
			argsXML.where = "type>=ERA/conversation and related to{room} (id=" + roomID + ") and related to{object} (id=" + objectID + ")";
			
			connection.sendRequest(baseXML, gotAllConversation);
		}
		
		private function gotAllConversation(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting conversation", e)) == null) {
				callback(false, null);
			}
			
			var conversationArray:Array = AppModel.getInstance().parseResults(data, Model_ERAConversation);
			
			callback(true, conversationArray);
			
		}
	}
}