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
		private var forResearcher:Boolean;
		private var connection:Connection;
		
		public function Transaction_SendMail(connection:Connection)
		{
			this.connection = connection;
		}
		
		public function sendMailFromNotification(notificationID:Number, forResearcher:Boolean):void {
			// Get out the ERA log item
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			this.forResearcher = forResearcher;
			argsXML.id = notificationID;
			argsXML["get-related-meta"] = true;
			
			connection.sendRequest(baseXML, forResearcher ? gotResearcherNotification : gotNotification);
		}
		
		private function gotResearcherNotification(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting notification for mail", e)) == null) {
				return
			}
			
			var notificationData:Model_ERANotification = new Model_ERANotification();
			notificationData.setData(data.reply.result.asset[0]);
			
			var subject:String = "nQuisitor: ";
			var body:String = "RM " + notificationData.eraCase.rmCode + " " + notificationData.eraCase.title + ":\n\n";
			
			switch(notificationData.type) {
				case Model_ERANotification.FILE_COMMENT:
					subject += "Your Research has Attracted Commentary";
					body += "An nQuisitor collaborator (" + notificationData.fullName + ") has commented in the " + notificationData.room.roomTitle + " upon a component of your research evidence (" + notificationData.file.title + ").\n\n";
					body += "\"" + notificationData.comment_file.annotation_text  + "\"\n\n";
					break;
				case Model_ERANotification.ANNOTATION:
					subject += "Your Research has Attracted Commentary";
					body += "An nQuisitor collaborator (" + notificationData.fullName + ") has annotated in the " + notificationData.room.roomTitle + " upon a component of your researcher evidence (" + notificationData.file.title + ").\n\n";
				case Model_ERANotification.ROOM_COMMENT:
					subject += "Your Research has Attracted Commentary";
					body += "An nQuisitor collaborator (" + notificationData.fullName + ") has commented in the " + notificationData.room.roomTitle + " upon a component of your research evidence (" + notificationData.file.title + ").\n\n";
					body += "\"" + notificationData.comment_room.text  + "\"\n\n";
					break;
				case Model_ERANotification.FILE_MOVED_TO_REVIEW_LAB:
					subject += "An item ERA Research Case is available for review";
					body += "An nQuisitor collaborator has placed " + notificationData.file.title + " in the review lab for your consideration.\n\n";
					break;
				case Model_ERANotification.FILE_APPROVED_BY_MONITOR:
					subject += "Researcher Approved File";
					body += "Monitor " + notificationData.fullName + " approved file " + notificationData.file.title + " in " + notificationData.room.roomTitle + " for ERA submission.";
					break;
			

				(type == Model_ERANotification.EVIDENCE_READY_FOR_COLLECTION) ||
				(type == Model_ERANotification.EVIDENCE_COLLECTED) ||
				(type == Model_ERANotification.FILE_APPROVED_BY_RESEARCHER) ||
				(type == Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER)
			){
			
			var	info += "To view this comment, please go to http://www.cifera.qut.edu.au. If you have not used the system before, you can log in using your QUT username, and the password 'changeme'";
			 			
			var signature:String = "\n\nRegards\n\n";
			signature += "Peter Hempenstall\n\n";
			signature += "Senior Research Assistant\n";
			signature += "CIF – ERA Coordinator\n";
			signature += "Non-Traditional Research Outputs\n";
			signature += "Queensland University of Technology";
			signature += "mailto:p.hempenstall@qut.edu.au\n\n\n";

			var disclaimer = "QUT disclaims all warranties with regard to this information, including all implied warranties of merchantability and fitness, in no event shall QUT be liable or any special, indirect or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether in an action of contract, negligence or other tortious action, arising out of or in connection with the use or performance of this information.\n\n";
			disclaimer = "This information may include technical inaccuracies or typographical errors.\n\n";
			disclaimer = "QUT is not responsible to you or anyone else for any loss, direct or incidental, suffered in connection with the use of this website or any of the content.\n\n";
			disclaimer = "QUT makes no warranties or representations about this website or any of the content.  We exclude, to the maximum extent permitted by law, any liability which may arise as a result of the use of this website, its content or the information on it.\n\n";
			disclaimer = "Where liability cannot be excluded, any liability incurred by us in relation to the use of this website or the content is limited as provided under the Trade Practices Act 1974 (s68A). We will never be liable for any indirect, incidental, special or consequential loss arising out of the use of this website, including loss of business profits.\n\n";
			disclaimer = "QUT may make improvements and/or changes in the information at any time.";
			
			body += info + signature;
			body += disclaimer;
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
				case Model_ERANotification.FILE_MOVED_TO_REVIEW_LAB:
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
			
			var baseXML:XML = connection.packageRequest("mail.send", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.to = toEmail;
			argsXML.subject = subject;
			argsXML.body = body;
			
			connection.sendRequest(baseXML, mailSent);	
		}
		
		private function mailSent(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("sending mail", e)) == null) {
				return;
			} else {
				return;
			}
		}
	}
}