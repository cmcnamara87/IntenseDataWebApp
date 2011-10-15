package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERAConversation;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_CreateConversation
	{
		private var objectID:Number; // the object we are commenting on, might be a room id, or comment id
		private var roomID:Number;
		private var text:String;
		private var year:String;
		private var inReplyToID:Number;
		private var connection:Connection;
		private var callback:Function;
		
		private var newCommentID:Number;
		
		public function Transaction_CreateConversation(year:String, objectID:Number, roomID:Number, inReplyToID:Number, text:String, connection:Connection, callback:Function)
		{
			this.text = text; // the comment text
			this.objectID = objectID;
			this.roomID = roomID;
			this.inReplyToID = inReplyToID;
			this.connection = connection;
			this.year = year;
			this.callback = callback;
			
			createComment();
		}

		private function createComment():void {
			var baseXML:XML = connection.packageRequest("asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create a namespace for this era
			argsXML.namespace = "ERA/" + this.year;
			
			argsXML.type = "ERA/conversation/comment";
			
			// The person who made the comment
			argsXML.meta["ERA-conversation"]["creator"] = Auth.getInstance().getUsername();
			
			// set the annotation text
			argsXML.meta["ERA-conversation"]["text"] = text;
	
			argsXML.related = "";
			argsXML.related.appendChild(XML('<to relationship="room">' + roomID + '</to>'));
			argsXML.related.appendChild(XML('<to relationship="object">' + objectID + '</to>'));
			if(inReplyToID != 0) {
				argsXML.related.appendChild(XML('<to relationship="in_reply_to">' + inReplyToID + '</to>'));
			}
		
			connection.sendRequest(baseXML, commentCreated);
		}
		
		private function commentCreated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("creating an era comment", e)) == null) {
				callback(false, null);
				return;
			}
			
			newCommentID = data.reply.result.id;
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = newCommentID;
			
			connection.sendRequest(baseXML, commentRetrieved);
		}
		
		private function commentRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting era comment", e)) == null) {
				callback(false, null);
			}
			
			
			var eraConversation:Model_ERAConversation = new Model_ERAConversation();
			eraConversation.setData(data.reply.result.asset[0]);
			
			// Add in the user data
			eraConversation.userDetails = Auth.getInstance().getUserDetails();
			
			callback(true, eraConversation);
		}
	}
}