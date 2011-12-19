package Model.Transactions.ERAProject
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_SendMailFromNotification
	{
		private var toEmail:String;
		private var subject:String;
		private var body:String;
		private var connection:Connection;
		private var notificationData:Model_ERANotification;
		
		private var rolesArray:Array = new Array();
		private var rolesCounter:Number = 0;
		
		private var addressesToEmailArray:Array = new Array();
		
		public function Transaction_SendMailFromNotification(connection:Connection)
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
			
			notificationData = new Model_ERANotification();
			notificationData.setData(data.reply.result.asset[0]);
			
			
			for each(var aclXML:XML in data.reply.result.asset.acl) {
				if(aclXML.actor.@type == "user") {
					// remove system:
					var email:String = aclXML.actor.substring(7);
					
					// Store hte email to sed the notification to
					addressesToEmailArray.push(email);
//					var transaction:Transaction_SendNotificationEmailToUser = new Transaction_SendNotificationEmailToUser(email, notificationData, connection, mailSent);
					
				} else if(aclXML.actor.@type == "role"){
					rolesArray.push(aclXML.actor);
//					sendMailToRole(aclXML.actor, "", subject, body);
				}
			}
			
			getEmailsFromRoles();			
		}
		
		private function getEmailsFromRoles() {
			if(rolesCounter >= rolesArray.length) {
				// we have finished with the roles
				// send the emails
				sendEmailToUniqueUsers();
				return;
			}
			
			// get out the roles for the current user
			AppModel.getInstance().getERAUsersWithRole(rolesArray[rolesCounter], "", gotUsers);
		}
		
		
		private function gotUsers(status:Boolean, role:String, userArray:Array=null):void {
			if(!status) return;
			
			for each(var user:Model_ERAUser in userArray) {
				addressesToEmailArray.push(user.username);
			}
			
			rolesCounter++;
			getEmailsFromRoles();
		}
		
		private function sendEmailToUniqueUsers():void {
			var uniqueEmails:Array = new Array();
			trace("FINDING UNIQUE EMAILS");
			// lets get out the unique email address (no need to send it twice)
			for each(var email:String in addressesToEmailArray) {
				trace("checking", email, "for duplicate");
				var emailFound:Boolean = false;
				for each(var uniqueEmail:String in uniqueEmails) {
					if(uniqueEmail == email) {
						trace("duplicate found");
						emailFound = true;
						break;
					}
				}
				if(!emailFound) {
					trace("no duplicate found");
					uniqueEmails.push(email);
				}
			}
			
			// now lets send out all the unique emails
			for each(var uniqueEmail2:String in uniqueEmails) {
				trace("UNiQUE EMAIL", uniqueEmail2);
				var transaction:Transaction_SendNotificationEmailToUser = new Transaction_SendNotificationEmailToUser(uniqueEmail2, notificationData, connection, mailSent);
			}			
		}
		
		private function mailSent(status:Boolean):void {
			trace("YELLOW");
		}
		
		
	}
}