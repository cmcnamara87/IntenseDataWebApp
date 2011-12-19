package Controller.ERA.Admin
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	import Model.Model_ERAUser;
	import Model.Model_User;
	
	import View.ERA.UserAdminView;
	import View.ERA.components.ERARole;
	import View.ERA.components.UserListItem;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.components.VGroup;
	
	public class UserAdminController extends AppController
	{
		private var userAdminView:UserAdminView;
		private var usersArray:Array; // All the current users on the system
		
		public function UserAdminController()
		{
			userAdminView = new UserAdminView();
			view = userAdminView;
			super();
		}
		
		override public function init():void {
			layout.header.unhighlightAllButtons();
			layout.header.userAdminButton.setStyle("chromeColor", "0x000000");
			
			getUsersOnSystem();
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			userAdminView.currentYear = AppController.currentEraProject.year;
			
			// Add user to role
			view.addEventListener(IDEvent.ERA_ADD_USER_TO_ROLE, addUserToRole);
			
			// Create user
			userAdminView.createUserButton.addEventListener(MouseEvent.CLICK, createNewUser);

			// Listen for user being deleted
			userAdminView.addEventListener(IDEvent.ERA_DELETE_USER, deleteUser);
			
			// Listen for user being removed from a role
			userAdminView.addEventListener(IDEvent.ERA_REMOVE_USER_FROM_ROLE, removeUserFromRole);
			
			userAdminView.addEventListener(IDEvent.ERA_CHANGE_ERA_EMAIL_OPTIONS, changeEmailOptions, false, 0, true);
		}
		
		/* ========================================== CREATING ERA USER ========================================== */
		private function createNewUser(e:MouseEvent):void {
			var qutUsername:String = userAdminView.qutUsername.text;
			var firstName:String = userAdminView.firstName.text;
			var lastName:String = userAdminView.lastName.text;
			
			if(qutUsername == "") {
				layout.notificationBar.showError("Please fill in a QUT email address");
				return;
			}
			// Check that it is a qut email address
			if(Recensio_Flex_Beta.serverAddress == Recensio_Flex_Beta.QUT_IP) {
				var qutUsernameParts:Array = qutUsername.split("@");
				if(qutUsernameParts.length != 2) {
					layout.notificationBar.showError("Please fill in a QUT email address");
					return;
				}
				if(qutUsernameParts[1] != "qut.edu.au") {
					layout.notificationBar.showError("Please fill in a QUT email address");
					return;
				}
			}
			
			if(firstName == "") {
				layout.notificationBar.showError("Please fill out the first name");
				return;
			}
			if(lastName == "") {
				layout.notificationBar.showError("Please fill out the last name");
				return;
			}
			
			userAdminView.createUserPanel.enabled = false;
			
			layout.notificationBar.showProcess("Creating User...");
			
			AppModel.getInstance().createERAUser(qutUsername, firstName, lastName, eraUserCreated);
		}
		private function eraUserCreated(status:Boolean, eraUser:Model_ERAUser=null):void {
			if(status) {
				layout.notificationBar.showGood("User Created");
				
				// Add user to saved user array
				this.usersArray.unshift(eraUser);
				userAdminView.addERAUsers(usersArray);
				userAdminView.closeCreateUserPanel();

			} else {
				layout.notificationBar.showError("User Creation Failed");
			}
		}
		/* ======================================= END OF CREATING ERA USER ========================================== */
		
		
		/* ========================================== ADD ROLE TO USER ========================================== */
		private function addUserToRole(e:IDEvent):void {
			// Add user to role
			var eraUserData:Model_ERAUser = e.data.eraUserData as Model_ERAUser;
			var role:String = e.data.role;
			var roleComponent:ERARole = e.data.roleComponent
			AppModel.getInstance().addRoleToERAUser(eraUserData, role, AppController.currentEraProject.year, roleComponent, roleAddedToUser);
		}
		private function roleAddedToUser(status:Boolean, userData:Model_ERAUser=null, roleComponent:ERARole=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to give role to " + userData.username);
				return;
			}
			
			layout.notificationBar.showGood("User added to role");
			
			roleComponent.addUserWithRole(userData);
		}
		/* ========================================== END OF ADD ROLE TO USER ========================================== */
		
		
		/* ========================================== DELETE A USER ========================================== */
		private function deleteUser(e:IDEvent):void {
			var username:String = e.data.username;
			
			var myAlert:Alert = Alert.show(
				"Are you sure you wish to delete user: " + username, "Delete User", Alert.OK | Alert.CANCEL, null, function(e:CloseEvent):void {
					if (e.detail==Alert.OK) {
						layout.notificationBar.showProcess("Deleting " + username);
						
						AppModel.getInstance().deleteERAUser(username, userDeleted);
					}
				}, null, Alert.CANCEL);
		}
		private function userDeleted(status:Boolean, username:String=""):void {
			if(!status) {
				layout.notificationBar.showError("Failed to delete user");
				return;
			}
			
			layout.notificationBar.showGood("User " + username + " deleted");
			
			for(var i:Number = 0; i < this.usersArray.length; i++) {
				var deletedERAUser:Model_ERAUser = this.usersArray[i] as Model_ERAUser;
				if(deletedERAUser.username == username) {
					this.usersArray.splice(i, 1);
					break;
				}
			}
			
			// Add the updated list of users to the view
			userAdminView.addERAUsers(this.usersArray);
			
		}
		/* ========================================== END OF DELETE A USER ========================================== */
		
		
		/* ========================================== REMOVING A ROLE FROM A USER ========================================== */
		private function removeUserFromRole(e:IDEvent):void {
			trace("Removing user from role");
			var username:String = e.data.username;
			var roleComponent:ERARole = e.data.roleComponent;
			var role:String = e.data.role;
			
			var myAlert:Alert = Alert.show(
				"Are you sure you wish to remove user: " + username + " from " + Model_ERAUser.getRolePrettyName(role), "Remove User", Alert.OK | Alert.CANCEL, null, function(e:CloseEvent):void {
					if (e.detail==Alert.OK) {
						layout.notificationBar.showProcess("Removing " + username);

						roleComponent.removeUser(username);
						
						AppModel.getInstance().removeRoleFromERAUser(username, role, roleComponent, userRemovedFromRole);
					}
				}, null, Alert.OK);
		}
			
			
		private function userRemovedFromRole(status:Boolean, username:String="", roleComponent:ERARole=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to remove role for " + username);
				return;
			}
			layout.notificationBar.showGood("Role removed from " + username);
//			roleComponent.removeUser(username);
			
		}
		/* ========================================== END OF REMOVING A ROLE FROM A USER ========================================== */
		
		/* ========================================== CHANGE EMAIL OPTIONS ========================================== */
		private function changeEmailOptions(e:IDEvent):void {
			trace("Changing email options");
			var role:String = e.data.role;
			var enabled:Boolean = e.data.enabled;
			var username:String = "";
			if(e.data.username) {
				username = e.data.username;
			}
			
			trace("changing email option", role, enabled ? 'true' : 'false', username);
			AppModel.getInstance().changeEmailOptions(role, username, enabled, emailOptionsChanged);
		}
		
		
		private function emailOptionsChanged(status:Boolean, eraProject:Model_ERAProject=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to change email options");
				return;
			}
			layout.notificationBar.showGood("Email options changed.");
			// Update the current era project
			AppController.currentEraProject = eraProject;
		}
		/* ========================================== END OF CHANGE EMAIL OPTIONS ========================================== */
		
		
		
		/* ======================================= GET USERS WITH ROLE ========================================== */
		/**
		 * Get all the users with the roles (roles are stored in an array in the app controller) @see AppController 
		 * 
		 */
		private function getUsersWithRoles():void {
			for each(var role:String in Model_ERAUser.ERARoles) {
				// Get all the users that have the role
				AppModel.getInstance().getERAUsersWithRole(role, AppController.currentEraProject.year, gotUsersWithRole);
			}
		}
		/**
		 * Got a list of users for a given role. Add them to the view 
		 * @param status
		 * @param role
		 * @param usersArray
		 * 
		 */
		private function gotUsersWithRole(status:Boolean, role:String="", roleERAUserArray:Array=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get " + role + " users");
				return;
			}
			
			userAdminView.addRole(role, roleERAUserArray, this.usersArray);
		}
		/* ======================================= END OF GET USERS WITH ROLE ========================================== */		
	
		
		/* ======================================= GET USERS ON SYSTEM ========================================== */
		private function getUsersOnSystem():void {
			AppModel.getInstance().getERAUsers(gotUsers);
		}
		
		private function gotUsers(status:Boolean, usersArray:Array=null):void {
			if(!status) {
				layout.notificationBar.showError("Failed to get users");
				return;
			}
			
			this.usersArray = usersArray;
			trace("users count", usersArray.length);
			
			userAdminView.addERAUsers(usersArray);
			
			getUsersWithRoles();
		}
		/* ======================================= END OF GET USERS ON SYSTEM ========================================== */
		
	}
}