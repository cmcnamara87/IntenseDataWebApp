package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_MoveFile
	{
		private var fileID:Number;
		private var fromRoomID:Number;
		private var toRoomID:Number;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_MoveFile(fileID:Number, fromRoomID:Number, toRoomID:Number, connection:Connection, callback:Function)
		{
			this.fileID = fileID;
			this.fromRoomID = fromRoomID;
			this.toRoomID = toRoomID;
			this.connection = connection;
			this.callback = callback;
			
			moveFile();
		}
		
		private function moveFile():void {
			// remove to relationship
			var baseXML:XML = connection.packageRequest("asset.relationship.remove", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = fileID;
			argsXML.to = fromRoomID;
			argsXML.to.@relationship = "room";
			argsXML.comment = "Changed to room " + toRoomID + " from room " + fromRoomID;

			connection.sendRequest(baseXML, fileRemovedFromRoom);			
		}
		
		private function fileRemovedFromRoom(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("removed file from room", e)) == null) {
				callback(false);
				return;
			}

			var baseXML:XML = connection.packageRequest("asset.relationship.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = fileID;
			argsXML.to = toRoomID;
			argsXML.to.@relationship = "room";
			
			connection.sendRequest(baseXML, fileAddedToRoom);
		}
		
		private function fileAddedToRoom(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("added file to room", e)) == null) {
				callback(false);
				return;
			}
			
			callback(true);
		}
	}
}