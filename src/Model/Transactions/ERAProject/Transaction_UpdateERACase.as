package Model.Transactions.ERAProject
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERACase;
	import Model.Model_ERAProject;
	import Model.Model_ERARoom;
	import Model.Model_ERAUser;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_UpdateERACase
	{
		private var year:String;
		private var caseID:Number;
		private var rmCode:String;
		private var title:String;
		private var fileCount:Number;
		private var researcherArray:Array;
		private var qutSchool:String;
		private var forArray:Array;
		private var categoryArray:Array;
		private var productionManagerArray:Array;
		private var productionTeamArray:Array;
		private var connection:Connection;
		private var callback:Function;
		
		private var newERACaseID:Number;
		private var roomBeingMadeIndex:Number; //the index for the room we are currently making in @see Model_ERARoom
		
		// okay, all of these users need to have their notifications removed for this case
		private var removedUserList:Array = new Array();
		
		
		public function Transaction_UpdateERACase(year:String,
												  caseID:Number,
												  rmCode:String, 
												  title:String,
												  fileCount:Number,
												  researcherArray:Array,
												  qutSchool:String, 
												  forArray:Array,
												  categoryArray:Array,
												  productionManagerArray:Array,
												  productionTeamArray:Array,
												  connection:Connection, 
												  callback:Function)
		{
			this.year = year;
			this.caseID = caseID;	
			this.rmCode = rmCode;
			this.title = title;
			this.fileCount = fileCount;
			this.researcherArray = researcherArray;
			this.qutSchool = qutSchool;
			this.forArray = forArray;
			this.categoryArray = categoryArray;
			this.productionManagerArray = productionManagerArray;
			this.productionTeamArray = productionTeamArray;
			this.connection = connection;
			this.callback = callback;
			
			updateERACase();
		}
		
		private function updateERACase():void {
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;

			argsXML.id = caseID;
			
			//			// Set this as a collection (cause we are going to put the case elements inside)
			//			argsXML.collection = true;
			//			
			// Setup the era meta-data
			argsXML.meta.@action = "replace";
			argsXML.meta["ERA-case"]["RM_code"] = this.rmCode;
			
			if(this.title != "") {
				argsXML.meta["ERA-case"]["title"] = this.title;
			}
			
			argsXML.meta["ERA-case"]["file_count"] = this.fileCount;
			
			// setup the researchers
			for each(var researcher:Model_ERAUser in researcherArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<researcher_username><username>" + researcher.username + "</username><first_name>"+researcher.firstName+"</first_name><last_name>"+researcher.lastName+"</last_name></researcher_username>"));
			}
			
			if(this.qutSchool != "") {
				argsXML.meta["ERA-case"]["qut_school"] = this.qutSchool;
			}
			
			// setup for codes/percentages
			for each(var forElementArray:Array in forArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<for><for_code>" + forElementArray["for_code"] + "</for_code><percentage>" + forElementArray["percentage"] + "</percentage></for>"));
			}
			
			// setup categories
			for each(var category:String in categoryArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<category>" + category + "</category>"));
			}
			
			// setup production manager usernames
			for each(var productionManager:Model_ERAUser in productionManagerArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<production_manager_username><username>" + productionManager.username + "</username><first_name>"+productionManager.firstName+"</first_name><last_name>"+productionManager.lastName+"</last_name></production_manager_username>"));
			}
			
			// setup production team usernames
			for each(var productionTeam:Model_ERAUser in productionTeamArray) {
				argsXML.meta["ERA-case"].appendChild(XML("<production_team_username><username>" + productionTeam.username + "</username><first_name>"+productionTeam.firstName+"</first_name><last_name>"+productionTeam.lastName+"</last_name></production_team_username>"));
			}

			connection.sendRequest(baseXML, eraCaseUpdated);			
		}
		
		private function eraCaseUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating era case", e)) == null) {
				callback(false, null);
				return;
			}
			
			// Update the ACLS in case the users have changed
			var baseXML:XML = connection.packageRequest("asset.acl.describe", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;
			
			connection.sendRequest(baseXML, gettingACLS);
		}
		
		private function gettingACLS(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("geting era acls", e)) == null) {
				callback(false, null);
				return;
			}
			
			// we need to go through,  and find all the users we have removed
			var aclList:XMLList = data.reply.result.asset.acl;
			
			for each(var aclXML:XML in aclList) {
			
				if(aclXML.actor.@type == "user") {
					// we need to check if they are in the new list
					var keepingUser:Boolean = false;
					
					for each(var researcher:Model_ERAUser in researcherArray) {
						if(aclXML.actor == "system:" + researcher) keepingUser = true;
					}
					
					for each(var productionManager:Model_ERAUser in productionManagerArray) {
						if(aclXML.actor == "system:" + productionManager) keepingUser = true;
					}
					
					for each(var productionTeam:Model_ERAUser in productionTeamArray) {
						if(aclXML.actor == "system:" + productionTeam) keepingUser = true;
					}
					
					if(!keepingUser) {
						removedUserList.push(aclXML.actor);
					}
				}
			}
			
			// Now remove everyones access, we will grant the new people access in a bit
			var baseXML:XML = connection.packageRequest("asset.acl.revoke", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;
			

			// only the researchers specified
			var foundUserToRemove:Boolean = false;
			for each(var aclXML:XML in aclList) {
				if(aclXML.actor.@type == "user") {
					foundUserToRemove = true;
					argsXML.appendChild(XML('<acl><actor type="user">' + aclXML.actor + '</actor></acl>'));
				}
			}

			if(foundUserToRemove) {
				trace('acls to remove', argsXML);
				connection.sendRequest(baseXML, aclsRemoved);
			} else {
				grantAccess();
			}
		}
		
		private function aclsRemoved(e:Event):void{
			var data:XML;
			if((data = AppModel.getInstance().getData("removing era acls - Transaction_UpdateERACase", e)) == null) {
				cleanUpACLS();
				return;
			}
			
			grantAccess();
		}
		
		/**
		 * Finds all instances where the actor for an ACL is invalid
		 * and removes the ACL (doesnt just do it for this user, but works on all invalids acls) 
		 * 
		 */		
		private function cleanUpACLS():void {
			var baseXML:XML = connection.packageRequest("asset.acl.invalid.remove", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;
			connection.sendRequest(baseXML, aclsCleanedUp);
		}
		
		private function aclsCleanedUp(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("cleaning up", e)) == null) {
				callback(false, null);
				return;
			}
			grantAccess();
		}
		
		private function grantAccess():void {
			// Now grant the new acls
			var baseXML:XML = connection.packageRequest("asset.acl.grant", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = caseID;
	
			// only the researchers specified
			for each(var researcher:Model_ERAUser in researcherArray) {
				argsXML.appendChild(XML('<acl><actor type="user">system:' + researcher.username + '</actor><access>read-write</access></acl>'));
			}
			
			// only the production managers specified
			for each(var productionManager:Model_ERAUser in productionManagerArray) {
				argsXML.appendChild(XML('<acl><actor type="user">system:' + productionManager.username + '</actor><access>read-write</access></acl>'));
			}
			
			// only the production team specificed
			for each(var productionTeam:Model_ERAUser in productionTeamArray) {
				argsXML.appendChild(XML('<acl><actor type="user">system:' + productionTeam.username + '</actor><access>read-write</access></acl>'));
			}
			
			trace('granting acls', argsXML);
			connection.sendRequest(baseXML, aclsUpdated);
		}
		
		private function aclsUpdated(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("updating era acls", e)) == null) {
				callback(false, null);
				return;
			}
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = caseID;
			
			connection.sendRequest(baseXML, eraCaseRetrieved);
		}
		
		private function eraCaseRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting updated era case", e)) == null) {
				callback(false, null);
				return
			}
			
			var eraCase:Model_ERACase = new Model_ERACase();
			eraCase.setData(data.reply.result.asset[0]);
			
			removeNotificationAccess();
			
			// Since we dont want to wait for all the notification stuff, we just return
			callback(true, eraCase);
		}
		
		private function removeNotificationAccess():void {
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "type>=ERA/notification and related to{notification_case} (id=" + caseID + ")";
			
			connection.sendRequest(baseXML, gotNotifications);
		}
		
		private function gotNotifications(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("got notifications", e)) == null) {
				callback(false, null);
				return
			}
			
			for each(var caseID:Number in data.reply.result.id) {
				//  remove access for this id
				if(removedUserList.length > 0) {
					
					var baseXML:XML = connection.packageRequest("asset.acl.revoke", new Object(), true);
					var argsXML:XMLList = baseXML.service.args;
					argsXML.id = caseID;
					
					// only the researchers specified
					for each(var username:String in removedUserList) {
						argsXML.appendChild(XML('<acl><actor type="user">' + username + '</actor></acl>'));
					}
					
					trace('acls to remove', argsXML);
					connection.sendRequest(baseXML, notificationAccessRemoved);
				}
			}
		}
		
		private function notificationAccessRemoved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("removing notifications access", e)) == null) {
				return
			}
		}
	}
}