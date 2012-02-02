package Model.Transactions.ERAProject
{
	import Controller.AppController;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_SendNotificationEmailToUser
	{
		private var username:String;
		private var notification:Model_ERANotification;
		private var connection:Connection;
		private var callback:Function;
		
		private var rolesArray:Array;
		private var isMonitor:Boolean = false;
		private var isLibraryAdmin:Boolean = false
		private var isResearcher:Boolean = false;
		private var isSysAdmin:Boolean = false;
		private var isProductionManager:Boolean = false;
		private var isProductionTeam:Boolean = false;
		
		public function Transaction_SendNotificationEmailToUser(username:String, notification:Model_ERANotification, connection:Connection, callback:Function)
		{
			this.username = username;
			this.notification = notification;
			this.connection = connection;
			this.callback = callback;
			
			trace("1. Sending email to: ", username);
			// we have a notification
			// lets check if they are a researcher for this case
			for each(var researcher:Model_ERAUser in notification.eraCase.researchersArray) {
				if(researcher.username == username) {
					isResearcher = AppController.currentEraProject.isEmailEnabled(Model_ERAUser.RESEARCHER, username);
				}
			}
			
			for each(var productionManager:Model_ERAUser in notification.eraCase.productionManagerArray) {
				if(productionManager.username == username) {
					isProductionManager = AppController.currentEraProject.isEmailEnabled(Model_ERAUser.PRODUCTION_MANAGER, username);
				}
			}
			
			for each(var productionTeam:Model_ERAUser in notification.eraCase.productionTeamArray) {
				if(productionTeam.username == username) {
					isProductionTeam = AppController.currentEraProject.isEmailEnabled(Model_ERAUser.PRODUCTION_TEAM, username);
				}
			}
			
			
			// Now we need to just check if they are a monitor or a sys admin
			AppModel.getInstance().getERAUserRoles(username, gotERAUserRoles);
		}
		
		private function gotERAUserRoles(status:Boolean, rolesArray:Array):void {
			if(!status) {
				callback(false);
				return;
			}
			// need to check if they are a monitor or a researcher, because they get special notifications
			for each(var role:String in rolesArray) {
				if(role == Model_ERAUser.MONITOR + "_" + AppController.currentEraProject.year) {
					isMonitor = AppController.currentEraProject.isEmailEnabled(Model_ERAUser.MONITOR, username);
				}
				if(role == Model_ERAUser.LIBRARY_ADMIN + "_" + AppController.currentEraProject.year) {
					isLibraryAdmin = AppController.currentEraProject.isEmailEnabled(Model_ERAUser.LIBRARY_ADMIN, username);
				}
				if(role == Model_ERAUser.SYS_ADMIN + "_" + AppController.currentEraProject.year) {
					trace(username, "is a sys admin");
					isSysAdmin = AppController.currentEraProject.isEmailEnabled(Model_ERAUser.SYS_ADMIN, username);
				}	
			}
			trace("Sending email to", username, 
				"researcher", isResearcher ? "yes":"no", 
				"prodman", isProductionManager ? "yes":"no", 
				"prodteam", isProductionTeam ? "yes":"no", 
				"monitor", isMonitor ? "yes":"no",
				"isSysAdmin", isSysAdmin ? "yes":"no");
			
			// lets see if we are supposed to email someone with those roles
			if(!(isSysAdmin || isProductionManager || isProductionTeam || isMonitor || isResearcher)) {
				// doesnt have any roles, so....no email for that person
				trace("user has no roles", username);
				callback(true);
			}
			
			if(isSysAdmin || isProductionManager || isProductionTeam) {
				var messageObject:Object = Model_ERANotification.getEmailMessage(notification, true, false);
				sendMailToUser(username, messageObject.subject, messageObject.body, "p.hempenstall@qut.edu.au");
			} else if(isMonitor || isResearcher || isLibraryAdmin) {
				var messageObject:Object = Model_ERANotification.getEmailMessage(notification, false, true);
				
 				// p.hempenstall@qut.edu.au
				sendMailToUser(username, messageObject.subject, messageObject.body, "p.hempenstall@qut.edu.au");
			}
			// so now we have the roles, lets get the message of what we need to say

		}
		
		private function sendMailToUser(username:String, subject:String, body:String, bcc:String=""):void {
	
			// only send an email to peter or andrew
			/*if(Recensio_Flex_Beta.serverAddress == Recensio_Flex_Beta.QUT_IP && !(username == "as.thomson@qut.edu.au" || username == "p.hempenstall@qut.edu.au")) {
				return;
			}*/
			
			trace("Final stage: Sending email to", username);
			
			var baseXML:XML = connection.packageRequest("mail.send", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.to = username;
			argsXML.subject = subject;
			argsXML.body = body;
//			argsXML.bcc = bcc
//			argsXML.appendChild(XML("<bcc>" + "cifera@qut.edu.au" + "</bcc><bcc>" + bcc + "</bcc>"));
			if(bcc != "") {
				argsXML.bcc = bcc;
			}
			
			connection.sendRequest(baseXML, mailSent);
			
		}
		
		private function mailSent(e:Event):void {
			trace("mail sent");
			var data:XML;
			if((data = AppModel.getInstance().getData("sending mail", e)) == null) {
				trace("Done: MAIL FAILED TO SEND", username);
				return;
			} else {
				trace("Done: MAIL SENT SUCCESSFULLY", username);
				return;
			}
		}
	}
}