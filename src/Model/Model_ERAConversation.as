package Model {
	
	public class Model_ERAConversation extends Model_Base {
		
		public var type:String;
		public var text:String;
		public var creatorUsername:String;
		public var userDetails:Model_ERAUser = null;
		
		public var roomID:Number;
		public var objectID:Number; // the id of the ojbect this is a comment on
		public var isReply:Boolean = false;
		public var inReplyToID:Number;
		
		
		public function Model_ERAConversation() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			// grab out the case info
			var eraConversation:XML = rawData.meta["ERA-conversation"][0];
			
			this.type = rawData.type;
			
			// set the title of the item
			this.text = eraConversation["text"];
			
			this.creatorUsername = eraConversation["creator"];
			
			this.roomID = rawData.related.(@type=="room").to;
			
			this.objectID = rawData.related.(@type=="object").to;
			
			var replyNumber:Number = Number(rawData.related.(@type=="in_reply_to").to);
			if(replyNumber > 0) {
				inReplyToID = replyNumber;
				this.isReply = true;
			}
		}
	}
}