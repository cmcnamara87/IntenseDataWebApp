package Model.Transactions.ERAProject
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_SendMail
	{
		private var toEmail:String;
		private var subject:String;
		private var body:String;
		private var connection:Connection;
		
		public function Transaction_SendMail(connection:Connection)
		{
			this.connection = connection;
		}
		
		public function sendMailFromNotification(notificationID:Number):void {
			trace("sending mail from notification");
			// Get out the ERA log item
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = notificationID;
			argsXML["get-related-meta"] = true;
			
			connection.sendRequest(baseXML, gotNotification);
		}
		
		private function gotNotification(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting notification for mail", e)) == null) {
				return
			}
			
			var notificationData:Model_ERANotification = new Model_ERANotification();
			notificationData.setData(data.reply.result.asset[0]);
			
			var subject:String = "New nQuisitor Notification  (RM " + notificationData.eraCase.rmCode + "): ";
			var body:String = "Hi, You have a new nQuisitor Notification: ";
			
			switch(notificationData.type) {
				case Model_ERANotification.FILE_APPROVED_BY_RESEARCHER:
					subject += "Researcher Approved File";
					body += "Researcher " + notificationData.fullName + " approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					break;
				case Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER:
					subject += "Researcher Did Not Approve File";
					body += "Researcher " + notificationData.fullName + " did not approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					break;
				case Model_ERANotification.FILE_APPROVED_BY_MONITOR:
					subject += "Researcher Approved File";
					body += "Monitor " + notificationData.fullName + " approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					break;
				case Model_ERANotification.FILE_NOT_APPROVED_BY_MONITOR:
					subject += "Researcher Did Not Approve File";
					body += "Monitor " + notificationData.fullName + " did not approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					break;
				case Model_ERANotification.FILE_UPLOADED:
					subject += "New File Uploaded";
					body += "" + notificationData.fullName + " uploaded " + notificationData.file.title + " to " + notificationData.room.roomTitle + ".";
					break;
				case Model_ERANotification.ROOM_COMMENT:
					subject += "New Comment";
					body += "" + notificationData.fullName + " wrote \"" + notificationData.comment_room.text + "\" on " + notificationData.room.roomTitle + ".";
					break;
				case Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB:
				case Model_ERANotification.FILE_MOVED_TO_EXHIBITION:
				case Model_ERANotification.FILE_MOVED_TO_FORENSIC_LAB:
					subject += "File Moved";
					body += "" + notificationData.fullName + " moved " + notificationData.file.title + " to " + notificationData.room.roomTitle + ".";
					break;
				case Model_ERANotification.FILE_COMMENT:
					subject += "New Comment";
					body += "" + notificationData.fullName + " commented \"" + notificationData.comment_file.annotation_text + "\" on " + notificationData.file.title + " in " + notificationData.room.roomTitle + ".";					
					break
				case Model_ERANotification.ANNOTATION:
					subject += "New Annotation";
					body += "" + notificationData.fullName + " annotated on " + notificationData.file.title + " in " + notificationData.room.roomTitle + ".";
					break;
				case Model_ERANotification.EVIDENCE_COLLECTED:
					subject += "Evidence Collected";
					body = "" + notificationData.fullName + " marked " + notificationData.logItem.title + " as collected by a researcher in " + notificationData.room.roomTitle + ".";
					// todo fix this up so it sends
					return;
//					break;
				case Model_ERANotification.EVIDENCE_READY_FOR_COLLECTION:
					subject += "Evidence Ready for Collection";
					body += "" + notificationData.fullName + " marked " + notificationData.logItem.title + " as ready for collection in " + notificationData.room.roomTitle + ".";
					// todo fix this up so it sends
					return;
//					break;
				default:
					break;
				
			}
			
			body += "Visit nQuisitor at http://cifera.qut.edu.au/";
			
			for each(var aclXML:XML in data.reply.result.asset.acl) {
				if(aclXML.actor.@type == "user") {
					// remove system:
					var email:String = aclXML.actor.substring(7);
					sendMailToUser(email, subject, body);
				} else if(aclXML.actor.@type == "role"){
					sendMailToRole(aclXML.actor, "", subject, body);
				}
			}
		
		}
		
		private function sendMailToRole(role:String, year:String, subject:String, body:String):void {
			// get all the users with the role
			AppModel.getInstance().getERAUsersWithRole(role, "", gotUsers);
		}
		
		private function gotUsers(status:Boolean, role:String, userArray:Array=null):void {
			if(!status) return;
			
			for each(var user:Model_ERAUser in userArray) {
				sendMailToUser(user.username, subject, body);
			}
		}
		
		private function sendMailToUser(username:String, subject:String, body:String):void {
			this.toEmail = username;
			this.subject = subject;
			this.body = body;
			
			// only send an email to peter or andrew
			if(toEmail == "as.thomson@qut.edu.au" || toEmail == "p.hempenstall@qut.edu.au") {
				var baseXML:XML = connection.packageRequest("mail.send", new Object(), true);
				var argsXML:XMLList = baseXML.service.args;
				argsXML.to = toEmail;
				argsXML.subject = subject;
				argsXML.body = body;
			
				connection.sendRequest(baseXML, mailSent);
			}
		}
		
		private function mailSent(e:Event):void {
			trace("mail sent");
			var data:XML;
			if((data = AppModel.getInstance().getData("sending mail", e)) == null) {
				trace("MAIL SENT SUCCESSFULLY");
				return;
			} else {
				trace("MAIL FAILED TO SEND");
				return;
			}
		}
	}
}