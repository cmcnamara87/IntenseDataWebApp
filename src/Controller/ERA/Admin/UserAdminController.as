package Controller.ERA.Admin
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Model_User;
	
	import View.ERA.UserAdminView;
	import View.ERA.components.ERARole;
	import View.components.Admin.UserListItem;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	
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
			getUsersOnSystem();
			setupEventListeners();
		}
		
		private function setupEventListeners():void {
			// Add user to role
			view.addEventListener(IDEvent.ERA_ADD_USER_TO_ROLE, addUserToRole);
			
			// Create user
			userAdminView.createUserButton.addEventListener(MouseEvent.CLICK, createNewUser);
			
			// Listen for user being deleted
			userAdminView.addEventListener(IDEvent.ERA_DELETE_USER, deleteUser);
		}
		
		/* ========================================== CREATING ERA USER ========================================== */
		private function createNewUser(e:MouseEvent):void {
			var qutUsername:String = userAdminView.qutUsername.text;
			var firstName:String = userAdminView.firstName.text;
			var lastName:String = userAdminView.lastName.text;
			
			if(qutUsername == "") {
				layout.notificationBar.showError("Please fill in a QUT username");
				return;
			}
			if(firstName == "") {
				layout.notificationBar.showError("Please fill out the first name");
				return;
			}
			if(lastName == "") {
				layout.notificationBar.showError("Please fill out the last name");
				return;
			}
			
			AppModel.getInstance().createERAUser(qutUsername, firstName, lastName, eraUserCreated);
		}
		private function eraUserCreated(status:Boolean, eraUser:Model_ERAUser):void {
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
			var username:String = e.data.username;
			var role:String = e.data.role;
			
			AppModel.getInstance().addRoleToERAUser(username, role, AppController.currentEraProject.year, roleAddedToUser);
		}
		private function roleAddedToUser(status:Boolean):void {
			if(status) {
				layout.notificationBar.showGood("User added to role");
			} else {
				layout.notificationBar.showError("Failed");
			}
		}
		/* ========================================== END OF ADD ROLE TO USER ========================================== */
		
		
		/* ========================================== DELETE A USER ========================================== */
		private function deleteUser(e:IDEvent):void {
			var username:String = e.data.username;
			AppModel.getInstance().deleteERAUser(username, userDeleted);
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
		
		
		/* ======================================= GET USERS WITH ROLE ========================================== */
		/**
		 * Get all the users with the roles (roles are stored in an array in the app controller) @see AppController 
		 * 
		 */
		private function getUsersWithRoles():void {
			for each(var role:String in AppController.ERARoles) {
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
		private function gotUsersWithRole(status:Boolean, role:String, roleERAUserArray:Array):void {
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
		
		private function gotUsers(status:Boolean, usersArray:Array):void {
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