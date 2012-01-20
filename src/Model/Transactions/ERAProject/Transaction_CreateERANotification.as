package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERANotification;
	import Model.Model_ERARoom;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_CreateERANotification
	{
		private var username:String;
		private var firstName:String;
		private var lastName:String;
		private var year:String;
		private var caseID:Number;
		private var type:String;
		private var connection:Connection;
		private var roomID:Number;
		private var fileID:Number;
		private var commentID:Number;
		private var eraCase:Model_ERACase;
		private var eraRoom:Model_ERARoom;
		
		public function Transaction_CreateERANotification(year:String, roomID:Number, username:String, firstName:String, lastName:String, type:String, connection:Connection, caseID:Number=0, fileID:Number=0, commentID:Number=0)
		{
			this.username = username;
			this.firstName = firstName;
			this.lastName = lastName;
			this.year = year;
			this.caseID = caseID;
			this.type = type;
			this.connection = connection;
			this.caseID = caseID;
			this.roomID = roomID;
			this.fileID = fileID;
			this.commentID = commentID;
			
			// if we havent been given a case id, we have to get it from the room, so lets do that			
//			if(caseID == 0) {
				// We need to the case id from somewhere
			getRoomDetails();
//			} else {
//				getCaseUsers();
//			}
		}
		
		/**
		 * Get the details of the room where this has happened 
		 * 
		 */		
		private function getRoomDetails():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = roomID;
			connection.sendRequest(baseXML, gotRoomDetails);
		}
		private function gotRoomDetails(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting room details", e)) == null) {
//				callback(false);
				return;
			}

			eraRoom = new Model_ERARoom();
			eraRoom.setData(data.reply.result.asset[0]);
			
			caseID = eraRoom.caseID;

			getCaseUsers();
		}
		
		/**
		 * We can now get the people involved in the case, because we found out the room, so we know the case. 
		 * 
		 */		
		private function getCaseUsers():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;
			
			connection.sendRequest(baseXML, gotCaseUsers);
		}
		
		private function gotCaseUsers(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting case details", e)) == null) {
//				callback(false, null);
				return;
			}
			
			
			eraCase = new Model_ERACase();
			eraCase.setData(data.reply.result.asset[0]);

		
			var baseXML:XML = connection.packageRequest("asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create a namespace for this era
			argsXML.namespace = "ERA/" + this.year;
			
			argsXML.type = "ERA/notification";

			// Setup the era meta-data
			argsXML.meta["ERA-notification"]["type"] = this.type;
			argsXML.meta["ERA-notification"]["username"] = this.username;
			argsXML.meta["ERA-notification"]["first_name"] = this.firstName;
			argsXML.meta["ERA-notification"]["last_name"] = this.lastName;

			// Set the notifications relationship to other assets
			argsXML.related = "";
		
			// Add compulsory room and case erlationships
			argsXML.related.appendChild(XML('<to relationship="notification_case">' + this.caseID + '</to>'));
			argsXML.related.appendChild(XML('<to relationship="notification_room">' + this.roomID + '</to>'));

			// add option file and comment relationships
			if(this.fileID != 0) {
				argsXML.related.appendChild(XML('<to relationship="notification_file">' + this.fileID + '</to>'));
			}
			if(this.commentID != 0) {
				argsXML.related.appendChild(XML('<to relationship="notification_comment">' + this.commentID + '</to>'));
			}
			
			//Setup who to notify
			var userObject:Object = Model_ERANotification.getWhoToNotify(type, eraCase, eraRoom);
			for each(var role:String in userObject.roles) {
				argsXML.appendChild(XML('<acl><actor type="role">' + role + '</actor><access>read-write</access></acl>'));
			}
			for each(var username:String in userObject.users) {
				argsXML.appendChild(XML('<acl><actor type="user">system:' + username + '</actor><access>read-write</access></acl>'));
			}

			connection.sendRequest(baseXML, notificationCreated);
		}
		
		private function notificationCreated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("creating era notification", e)) == null) {
				return;
			}
			
			var notificationID:Number = data.reply.result.id;
			
			// Send mail
			if(Recensio_Flex_Beta.serverAddress == Recensio_Flex_Beta.QUT_IP) {
				AppModel.getInstance().sendMailFromNotification(notificationID);
			}
		}
	}
}