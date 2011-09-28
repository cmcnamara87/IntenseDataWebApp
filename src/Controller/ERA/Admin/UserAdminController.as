package Controller.ERA.Admin
{
	import Controller.AppController;
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAUser;
	import Model.Model_User;
	
	import View.UserAdminView;
	import View.components.Admin.UserListItem;
	import View.components.ERARole;
	
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
			view.addEventListener(IDEvent.ADD_USER_TO_ROLE, addUserToRole);
			userAdminView.createUserButton.addEventListener(MouseEvent.CLICK, createNewUser);
		}
		
		/* ========================================== CREATING ERA USER ========================================== */
		private function createNewUser(e:MouseEvent):void {
			var qutUsername:String = userAdminView.qutUsername.text;
			var firstName:String = userAdminView.firstName.text;
			var lastName:String = userAdminView.lastName.text;
			
			AppModel.getInstance().createERAUser(qutUsername, firstName, lastName, eraUserCreated);
		}
		private function eraUserCreated(status:Boolean):void {
			if(status) {
				layout.notificationBar.showGood("User Created");
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
		
		private function getUsersWithRoles():void {
			for each(var role:String in AppController.ERARoles) {
				// Get all the users that have the role
				AppModel.getInstance().getERAUsersWithRole(role, AppController.currentEraProject.year, gotUsersWithRole);
			}
		}
		private function gotUsersWithRole(status:Boolean, role:String, usersArray:Array):void {
			var roleBox:ERARole = new ERARole();
			roleBox.percentWidth = 100;
			roleBox.percentHeight = 100;
			userAdminView.roles.addElement(roleBox);
			
			roleBox.roleTitle.text = role;
			
			var formattedArray:ArrayList = new ArrayList();
			for each(var eraUser:Model_ERAUser in this.usersArray) {
				formattedArray.addItem(eraUser.username);
			}
			roleBox.allUsers.dataProvider = formattedArray;
			
//			for each(var user:Model_ERAUser in usersArray) {
//				trace("user list", user.firstName);
//				var userListItem:UserListItem = new UserListItem();
//				userListItem.firstName = user.firstName;
//				userListItem.lastName = user.lastName;
//				userListItem.username = user.username;
//				roleBox.addElement(userListItem);
//			}
			for each(var user:String in usersArray) {
				var userListItem:UserListItem = new UserListItem();
				userListItem.username = user;
				roleBox.currentUsers.addElement(userListItem);
			}
		}
		
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
			
			for each(var user:Model_ERAUser in usersArray) {
				var userListItem:UserListItem = new UserListItem();
				userListItem.firstName = user.firstName;
				userListItem.lastName = user.lastName;
				userListItem.username = user.username;
				userAdminView.allUsers.addElement(userListItem);
			}
			
			getUsersWithRoles();
		}
		
	}
}