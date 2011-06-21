package Controller {
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import Model.AppModel;
	import Model.Model_User;
	
	import View.Profile;
	import View.ProfileView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	public class ProfileController extends AppController {
		
		
		private var profileView:ProfileView;
		
		// The minimum lenght of the users password
		private var minimum_pass_length:Number = 4;
		
		// The currently selected user's name
		private var selectedusername:String = "";
		private var isAdmin:Boolean = false;

		// The list of users for the system
		private var userList:ArrayList;

		//PASSWORD RESET: error: executing user.password.reset: [arc.mf.server.Services$ExServiceError]: call to service 'user.password.reset' failed: 530 5.7.0 Must issue a STARTTLS command first. p13sm1925764qcu.17
		
		
		//Calls the superclass and shows the logout button
		public function ProfileController() {
			//view = new Profile();
			profileView = new ProfileView();
			view = profileView;
			super();
		}
		
		//INIT
		override public function init():void {
			// Set the currently selected user, as the user that is logged in
			selectedusername = Auth.getInstance().getUsername();
			if(selectedusername == "manager") {
				isAdmin = true;
				// Get hte list of users of the system
				AppModel.getInstance().getUserList(userListReceived);
			}
			setupEventListeners();
			 
			AppModel.getInstance().getUserDetails(selectedusername, "system", userDetailsReceived);
		}
		
		// Setup specific event listeners
		private function setupEventListeners():void {
			profileView.addEventListener(IDEvent.USER_CHANGED, userChanged);
			profileView.addEventListener(IDEvent.USER_DETAILS_SAVED, userDetailsSaveButtonClicked);
			profileView.addEventListener(IDEvent.NEW_USER_DETAILS_SAVED, saveNewUserClicked);
			// Listen for the delete user button being clicked
			profileView.addEventListener(IDEvent.DELETE_USER_BUTTON_CLICKED, deleteUserClicked);
			// Listne for the suspend user button being clicked
			profileView.addEventListener(IDEvent.SUSPEND_USER_BUTTON_CLICKED, suspendUserClicked);
			profileView.addEventListener(IDEvent.UNSUSPEND_USER_BUTTON_CLICKED, unsuspendUserClicked);
			
			// Listen for users changing their password
			profileView.addEventListener(IDEvent.CHANGE_PASSWORD_CLICKED, changeUserPasswordClicked);
		} 
		
		
		/* ================ CALLS TO THE DATABSE ============== */
		private function saveNewUserClicked(e:IDEvent):void {
			trace("- Save Button Event Caught");
			var data:Object = e.data;
		
			AppModel.getInstance().createUser(	data.username,
												data.password,
												data.email,
												"system",
												data,
												userCreated);
												
		}
		
		/**
		 * Delete the current user 
		 * @param e
		 * 
		 */		
		private function deleteUserClicked(e:IDEvent):void {
			
			AppModel.getInstance().deleteUser(selectedusername, "system", userDeleted);
		}
		
		/**
		 * Suspend the current user 
		 * @param e
		 * 
		 */		
		private function suspendUserClicked(e:IDEvent):void {
			trace("Suspend clicked");
			AppModel.getInstance().suspendUser(selectedusername, "system", userSuspended);
		}
		
		private function unsuspendUserClicked(e:IDEvent):void {
			trace("unsuspend clicked");
			AppModel.getInstance().unsuspendUser(selectedusername, "system", userSuspended);
		}
		
		/**
		 * The user has clicked the change password button. We need to tell the database
		 * to change the password. 
		 * @param e.newPassword	The users new password for their account
		 * 
		 */		
		private function changeUserPasswordClicked(e:IDEvent):void {
			trace("Change password button clicked");
			//user.password.set :domain system :user coke :old-password test :password test2
			var newPassword:String = e.data.newPassword;
			var username:String = e.data.username;
			AppModel.getInstance().changePassword("system", username, newPassword, passwordChanged);

		}		
		
		/**
		* The save button was clicked. Save the users new details. 
		* @param e
		* 
		*/		
		private function userDetailsSaveButtonClicked(e:IDEvent):void {
			//			details["meta_firstname"] = (view as Profile).meta_firstname.text;
			//			details["meta_lastname"] = (view as Profile).meta_lastname.text;
			//			details["meta_email"] = (view as Profile).meta_email.text;
			//			
			//			details["meta_initial"] = (view as Profile).meta_initial.text;
			//			details["meta_organisation"] = (view as Profile).meta_organisation.text;
			//			details["meta_url"] = (view as Profile).meta_url.text;
			//			details["meta_tel_business"] = int((view as Profile).meta_tel_business.text);
			//			details["meta_tel_home"] = int((view as Profile).meta_tel_home.text);
			//			details["meta_tel_mobile"] = int((view as Profile).meta_tel_mobile.text);
			//			details["meta_Address_1"] = (view as Profile).meta_Address_1.text;
			//			details["meta_Address_2"] = (view as Profile).meta_Address_2.text;
			//			details["meta_Address_3"] = (view as Profile).meta_Address_3.text;
			trace("- Caught Saved Button");
			if(e.data.meta_initial == '') {e.data.meta_initial = ' ' }
			if(e.data.meta_organisation == '') {e.data.meta_organisation = ' ' }
			if(e.data.meta_url == '') {e.data.meta_url = ' ' }
			if(e.data.meta_Address_1 == '') {e.data.meta_Address_1 = ' ' }
			if(e.data.meta_Address_2 == '') {e.data.meta_Address_2 = ' ' }
			if(e.data.meta_Address_3 == '') {e.data.meta_Address_3 = ' ' }
			
			AppModel.getInstance().saveProfile(e.data, e.data.username, profileSaved);
		}
		
		/* ========================================= CALLBACKS FROM THE DATABASE ========================================= */
		/**
		 * Called when the new user has finished being created 
		 * @param newUsername	The username of the new user
		 * 
		 */		
		private function userCreated(newUsername:String):void {
			trace("- User Saved: ", newUsername);
			trace("**************");
			// Set the selected user as the new username
			selectedusername = newUsername;
			
			// Tell toolbar to go green and save
			profileView.changeCompleted();
			
			// Refresh the display
			AppModel.getInstance().getUserList(userListReceived);
			AppModel.getInstance().getUserDetails(selectedusername, "system", userDetailsReceived);
		}
		
		private function userDeleted(e:Event):void {
			trace("- User Deleted: ", selectedusername);
			trace("**************");
			// Set the selected user as the current logged in username
			selectedusername = Auth.getInstance().getUsername();

			// Refresh the display
			AppModel.getInstance().getUserList(userListReceived);
			AppModel.getInstance().getUserDetails(selectedusername, "system", userDetailsReceived);
		}
		
		private function userSuspended(e:Event):void {
			trace("- User Role Changed: ", selectedusername);
			trace("**************");
		
			// Set the selected user as the current logged in username
			//selectedusername = Auth.getInstance().getUsername();
			
			// Refresh the display
			AppModel.getInstance().getUserList(userListReceived);
			AppModel.getInstance().getUserDetails(selectedusername, "system", userDetailsReceived);
		}
		
		/**
		 * The user has been changed. Reload the new users details. 
		 * @param e
		 * 
		 */		
		private function userChanged(e:IDEvent):void {
			selectedusername = e.data.username;
			AppModel.getInstance().getUserDetails(selectedusername, "system", userDetailsReceived);
		}

		/**
		 * The list of users has been retrieved from the database. Pass the usernames
		 * to the view. 
		 * @param e
		 * 
		 */		
		private function userListReceived(e:Event):void {
			// Add the current username to the list
			userList = new ArrayList();
			userList.addItem(selectedusername);
			var data:XML = XML(e.target.data);
			
			for each(var _user:XML in data.reply.result.user) {
				if(_user.@user != selectedusername) {
					// If they aren't the logged in user
					// Add the users name to the user list
					var userstring:String = _user.@user;
					userList.addItem(userstring);
				}
			}
			profileView.addUsers(userList);
			
			//profileView.addUsers(userList);
				
				
				
			trace("- User List Retrieved");
//			(view as Profile).userselect.dataProvider = userlist;
//			(view as Profile).userselect.visible = true;
//			(view as Profile).userselect.selectedIndex = 0;
		}
		
		/**
		 * The details for a given users have been loaded.  
		 * @param e
		 * 
		 */		
		private function userDetailsReceived(e:Event):void {
			// Get out the Users details from the response
			trace("- Received User Data", e.target.data);
			trace("- Stuff:", e);
			var dataXML:XML = XML(e.target.data);
			var userdetailsArray:Array = AppModel.getInstance().parseResults(XML(e.target.data), Model_User);
			trace("- details array length:", userdetailsArray);
			if(userdetailsArray.length > 0) {
				// Get out the 1 specific user details
				var userDetails:Model_User;	
				userDetails = userdetailsArray[0];
				trace(userDetails.meta_firstname);
				
				profileView.switchToViewMode();
				
				profileView.addDetails(userDetails);
			} else {
				trace(dataXML);
				Dispatcher.call("browse");
			}
			if(selectedusername == Auth.getInstance().getUsername()) {
//				(view as Profile).passForm.visible = true;
//				(view as Profile).resetPassForm.visible = false;
			} else {
//				(view as Profile).passForm.visible = false;
//				(view as Profile).resetPassForm.visible = true;
			}
			
			trace("- Users Details Received");
		}
		
		
		// Profile has been saved
		private function profileSaved(e:Event):void {
			
			var dataXML:XML = XML(e.target.data);
			if (dataXML.reply.@type == "result") {
				trace("- Profile Updated");
				trace("*****************");
				profileView.changeCompleted("Profile Updated");
				//(view as Profile).profilevalidation.setStyle("color","0x00930a");
				//(view as Profile).profilevalidation.text = "Profile Updated";
			} else {
				trace("ProfileController:profileSaved - Failed to save", e.target.data);
				trace("*****************");
				profileView.changeFailed("Error: "+dataXML.reply.message);
				//				(view as Profile).profilevalidation.setStyle("color","0xFF000");
				//				(view as Profile).profilevalidation.text = "Error: "+dataXML.reply.message;
			}
		}
		
		private function passwordChanged(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			if(dataXML.reply.@type == "result") {
				trace("- Password changed", e.target.data);
				profileView.changeCompleted("Profile Updated");
				trace("------------------------");
			} else {
				trace("Failed to save", e.target.data);
				profileView.changeFailed("Error: "+dataXML.reply.message);
				trace("---------------------");
			}
		}
		
		
//		private function setupNavbar():void {
//			(view as Profile).navbar.addButton("back","left",true);
//			(view as Profile).navbar.addHeading("Profile for "+selectedusername);
//		}
		

		

		

		
		// Triggered when update profile button is clicked
		private function updateProfile(e:MouseEvent):void {
//			if(
//				((view as Profile).meta_firstname.text.length > 0) &&
//				((view as Profile).meta_lastname.text.length > 0) &&
//				((view as Profile).meta_email.text.length > 0)
//			) {
//				(view as Profile).profilevalidation.setStyle("color","0x00930a");
//				(view as Profile).profilevalidation.text = "Updating profile...";
//				saveProfile();
//			} else {
//				(view as Profile).profilevalidation.setStyle("color","0xFF0000");
//				(view as Profile).profilevalidation.text = "All marked fields are required";
//			}
		}
//		
//		// Triggered when change password button is clicked
//		private function changePassword(e:MouseEvent):void {
//			if((view as Profile).password.text.length >= minimum_pass_length) {
//				if((view as Profile).password.text == (view as Profile).confirm_password.text) {
//					(view as Profile).passwordvalidation.setStyle("color","0x00930a");
//					(view as Profile).passwordvalidation.text = "Changing password...";
//					savePassword();
//				} else {
//					(view as Profile).passwordvalidation.setStyle("color","0xFF0000");
//					(view as Profile).passwordvalidation.text = "Passwords do not match";
//				}
//			} else {
//				(view as Profile).passwordvalidation.setStyle("color","0xFF0000");
//				(view as Profile).passwordvalidation.text = "Password must be at least "+minimum_pass_length+" characters";
//			}
//		}
//		
//		// Triggered when the reset password button is clicked
//		private function resetPassword(e:MouseEvent):void {
//			trace("RESETTING PASSWORD");
//		}
//		
//		// Saves the profile information
//		private function saveProfile():void {
//			var details:Array = new Array();
//			details["meta_firstname"] = (view as Profile).meta_firstname.text;
//			details["meta_lastname"] = (view as Profile).meta_lastname.text;
//			details["meta_email"] = (view as Profile).meta_email.text;
//			
//			details["meta_initial"] = (view as Profile).meta_initial.text;
//			details["meta_organisation"] = (view as Profile).meta_organisation.text;
//			details["meta_url"] = (view as Profile).meta_url.text;
//			details["meta_tel_business"] = int((view as Profile).meta_tel_business.text);
//			details["meta_tel_home"] = int((view as Profile).meta_tel_home.text);
//			details["meta_tel_mobile"] = int((view as Profile).meta_tel_mobile.text);
//			details["meta_Address_1"] = (view as Profile).meta_Address_1.text;
//			details["meta_Address_2"] = (view as Profile).meta_Address_2.text;
//			details["meta_Address_3"] = (view as Profile).meta_Address_3.text;
//			
//			if(details["meta_initial"] == '') {details["meta_initial"] = ' ' }
//			if(details["meta_organisation"] == '') {details["meta_organisation"] = ' ' }
//			if(details["meta_url"] == '') {details["meta_url"] = ' ' }
//			if(details["meta_Address_1"] == '') {details["meta_Address_1"] = ' ' }
//			if(details["meta_Address_2"] == '') {details["meta_Address_2"] = ' ' }
//			if(details["meta_Address_3"] == '') {details["meta_Address_3"] = ' ' }
//			
//			AppModel.getInstance().saveProfile(details,selectedusername,profileSaved);
//		}
//		
//		// Saves the new password
//		private function savePassword():void {
//			if(Auth.getInstance().getUsername() != "manager") {
//				AppModel.getInstance().changePassword((view as Profile).password.text,passwordChanged);
//			} else {
//				(view as Profile).passwordvalidation.setStyle("color","0xFF000");
//				(view as Profile).passwordvalidation.text = "Do not change manager password";
//			}
//		}
//		
		
//		
//		// Password has been changed
//		private function passwordChanged(e:Event):void {
//			var dataXML:XML = XML(e.target.data);
//			if (dataXML.reply.@type == "result") {
//				(view as Profile).passwordvalidation.setStyle("color","0x00930a");
//				(view as Profile).passwordvalidation.text = "Password Changed";
//			} else {
//				(view as Profile).passwordvalidation.setStyle("color","0xFF000");
//				(view as Profile).passwordvalidation.text = "Error: "+dataXML.reply.message;
//			}
//		}
//		
//		// Called when a button on the navigation bar is clicked
//		private function navBarClicked(e:RecensioEvent):void {
//			switch(e.data.buttonName) {
//				case 'back':
//					Dispatcher.call("browse");
//					break;
//			}
//		}
	}
}