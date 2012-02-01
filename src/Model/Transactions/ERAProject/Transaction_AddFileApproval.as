package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_AddFileApproval
	{
		private var year:String;
		private var roomID:Number;
		private var fileID:Number;
		private var caseID:Number;
		private var role:String;
		private var approval:Boolean;
		private var connection:Connection;
		private var callback:Function;
		
		public function Transaction_AddFileApproval(year:String, caseID:Number, roomID:Number, fileID:Number, role:String, approval:Boolean, connection:Connection, callback:Function)
			// year:String, roomID:Number, firstName:String, lastName:String, notificationType:String, caseID:Number, fileID:Number, username:String, connection:Connection, callback:Function)
		{
			this.year = year;
			this.caseID = caseID;
			this.roomID = roomID;
			this.fileID = fileID;
			this.role = role;
			this.approval = approval;
			this.connection = connection;
			this.callback = callback;
			
			getFile();
		}
		
		private function getFile():void {
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = fileID;
			
			connection.sendRequest(baseXML, gotFile);
		}
		
		private function gotFile(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("got the file", e)) == null) {
				callback(false);
				return;
			} 
			
			// Get out the ERA file meta-data
			var eraFileXML:XML = data.reply.result.asset[0];
			
			// We want to add the new person to the approval list
			var name:String = Auth.getInstance().getUserDetails().firstName + " " + Auth.getInstance().getUserDetails().lastName;
			var exhibitionApprovalXML:XML = new XML("<exhibition_approval><username>"+Auth.getInstance().getUsername()+"</username><name>"+name +"</name><role>"+role+"</role><approval>"+approval+"</approval><date>now</date></exhibition_approval>");
			eraFileXML.meta["ERA-evidence"].appendChild(exhibitionApprovalXML);
			
			// Now lets lock out that person, since they only get one shot and reviewing it
			eraFileXML.meta["ERA-evidence"].appendChild(XML("<locked_for_user>" + Auth.getInstance().getUsername() + "</locked_for_user>"));

			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = fileID;
			argsXML.meta["ERA-evidence"] = "";
			argsXML.meta["ERA-evidence"].appendChild(eraFileXML.meta["ERA-evidence"].exhibition_approval);
			argsXML.meta["ERA-evidence"].appendChild(eraFileXML.meta["ERA-evidence"].locked_for_user);
			
			connection.sendRequest(baseXML, fileLockOutStatusUpdated);		
		}
		
		private function fileLockOutStatusUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating lock out status", e)) == null) {
				callback(false);
				return;
			} else {
				if(role == Model_ERAUser.MONITOR && approval == true) {
					AppModel.getInstance().createERANotification(this.year, this.roomID, Auth.getInstance().getUsername(), 
						Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, Model_ERANotification.FILE_APPROVED_BY_MONITOR, this.caseID, this.fileID);	
				} else if (role == Model_ERAUser.MONITOR && approval == false) {
					AppModel.getInstance().createERANotification(this.year, this.roomID, Auth.getInstance().getUsername(), 
						Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, Model_ERANotification.FILE_NOT_APPROVED_BY_MONITOR, this.caseID, this.fileID);
				} else if (role == Model_ERAUser.RESEARCHER && approval == true) {
					AppModel.getInstance().createERANotification(this.year, this.roomID, Auth.getInstance().getUsername(), 
						Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, Model_ERANotification.FILE_APPROVED_BY_RESEARCHER, this.caseID, this.fileID);
				} else if (role == Model_ERAUser.RESEARCHER && approval == false) {
					AppModel.getInstance().createERANotification(this.year, this.roomID, Auth.getInstance().getUsername(), 
						Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER, this.caseID, this.fileID);
				}
				callback(true);
			}
		}
	}
}