package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_CreateRoom
	{
		private var connection:Connection; 
		private var callback:Function;
		private var caseID:Number;
		private var roomType:String;
		private var year:String; // ERA year		
		
		private var newRoomID:Number;
		/**
		 * Creates a Room 
		 * @param caseID		The ID of the case to put the room in
		 * @param roomType		The type of the room @see Model_ERARoom
		 * @param connection	The connection to mflux
		 * @param callback
		 * 
		 */
		public function Transaction_CreateRoom(year:String, caseID:Number, roomType:String, connection:Connection, callback:Function)
		{
			this.year = year;
			this.caseID = caseID;
			this.roomType = roomType;
			this.connection = connection;
			this.callback = callback;
			
			createRoom();
		}
		
		private function createRoom():void {
			var baseXML:XML = connection.packageRequest("asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create a namespace for this era
			argsXML.namespace = "ERA/" + this.year;
			
			argsXML.type = "ERA/room";
			
			// Make this a collection
			argsXML.collection = true;
			
			// Setup the era meta-data
			argsXML.meta["ERA-room"]["room_type"] = roomType;
			
			trace("CREATING ROOM", baseXML);
			connection.sendRequest(baseXML, eraRoomCreated);
		}
		
		private function eraRoomCreated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("creating era room", e)) == null) {
				callback(false);
				return;
			}
			
			newRoomID = data.reply.result.id;
			
			addRoomToCase();
		}
		private function addRoomToCase():void {
			var baseXML:XML = connection.packageRequest("asset.collection.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = caseID;
			argsXML.member = newRoomID;
			
			connection.sendRequest(baseXML, roomAddedToCase);
		}
		
		private function roomAddedToCase(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("adding room to case", e)) == null) {
				callback(false);
				return;
			} else {
				callback(true);
				return;
			}
		}
	}
}