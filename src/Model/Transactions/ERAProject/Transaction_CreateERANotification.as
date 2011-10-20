package Model.Transactions.ERAProject
{
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
			if(caseID == 0) {
				// We need to the case id from somewhere
				getRoomDetails();
			} else {
				getCaseUsers();
			}
		}
		
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

			var eraRoom:Model_ERARoom = new Model_ERARoom();
			eraRoom.setData(data.reply.result.asset[0]);
			
			caseID = eraRoom.caseID;

			getCaseUsers();
		}
		
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
			
			
			var eraCase:Model_ERACase = new Model_ERACase();
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
			
			// Setup the access for the admin for the year
			argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.SYS_ADMIN + "_" + year + '</actor><access>read-write</access></acl>'));
			
//			argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.VIEWER + "_" + year + '</actor><access>read-write</access></acl>'));
			
			
			// Set up access for production managers
			for each(var productionManager:Model_ERAUser in eraCase.productionManagerArray) {
				if(productionManager.username == Auth.getInstance().getUsername()) continue;
				argsXML.appendChild(XML('<acl><actor type="user">system:' + productionManager.username + '</actor><access>read-write</access></acl>'));	
			}
			
			for each(var productionTeamMember:Model_ERAUser in eraCase.productionTeamArray) {
				if(productionTeamMember.username == Auth.getInstance().getUsername()) continue;
				argsXML.appendChild(XML('<acl><actor type="user">system:' + productionTeamMember.username + '</actor><access>read-write</access></acl>'));	
			}
			
			// If we are adding it to the screening room, we need to notify the researcher
			if(type == Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB || type == Model_ERANotification.EVIDENCE_READY_FOR_COLLECTION) {
				for each(var researcher:Model_ERAUser in eraCase.researchersArray) {
					if(researcher.username == Auth.getInstance().getUsername()) continue;
					argsXML.appendChild(XML('<acl><actor type="user">system:' + researcher.username + '</actor><access>read-write</access></acl>'));
				}
			}
			
			if(type == Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB || Model_ERANotification.FILE_MOVED_TO_EXHIBITION) {
				// Notify the monitor when fiels are ready to be screened or exhibited
				argsXML.appendChild(XML('<acl><actor type="role">' + Model_ERAUser.MONITOR + "_" + year + '</actor><access>read-write</access></acl>'));
			}

			//trace("era notification", argsXML);
			// todo mail goes in here!!
			connection.sendRequest(baseXML, notificationCreated);
		}
		
		private function notificationCreated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("creating era notification", e)) == null) {
				return;
			}
			
			// Send mail
			
		}
	}
}