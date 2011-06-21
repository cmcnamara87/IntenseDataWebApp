package View
{
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_User;
	
	import View.components.IDButton;
	import View.components.IDGUI;
	import View.components.SubToolbar;
	import View.components.Toolbar;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;

	public class ProfileView  extends BorderContainer
	{
		// Instance Variables
		private var heading:Label; // The heading of the page
		private var addUserButton:Button; // The add user button
		private var suspendUserButton:Button; // The suspend user button
		private var deleteUserButton:Button; // The deltee user button
		private var saveButton:Button;
		
		private var userListComboBox:ComboBox; // Has a list of all the users retrieved from the database
		private var userDetailsView:Profile; // Has the form for entering/displaying users data
		private var newUserView:NewProfile; // Has the form for creating a new user
		private var discardButton:Button; // The discard/cancel button on the sub-toolbar. 
									// says 'discard' when editing, 'cancel' when creating a new user.
		private var mySubToolbar:SubToolbar; // The toolbar that shows the 'save' and 'discard' buttons
		
		private var userDetails:Model_User; // The details for the current user being displayed
		
		private var admin:Boolean = Auth.getInstance().isSysAdmin(); // Whether the current user is a manager of not
		
		private var isCurrentUserSuspended:Boolean = false; // Shows whether the current user we are viewing is suspended
		
		
		
		private var addingUser:Boolean; // We are adding a new user, changes function of sub-toolbar buttons
		private var userList:ArrayList;
		private var userDetailsGroup:VGroup;
		private var myScroller:Scroller;
		
		private var subToolbarLabel:Label;
		
		private var centeringGroup:VGroup
		
		public function ProfileView()
		{
			// Setup size
			this.percentHeight = 100;
			this.percentWidth = 100;

			// Setup layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Add toolbar
			var myToolbar:Toolbar = new Toolbar();
			this.addElement(myToolbar);
			
			// Add a Back button
			var backButton:Button = new Button();
			backButton.label = 'Back';
			backButton.percentHeight = 100;
			myToolbar.addElement(backButton);
			
			if(admin) {
				// If the user is an administrator
				// Create the heading label
				var heading:Label = new Label();
				heading.text = "Profile Manager ";
				heading.setStyle('fontWeight', 'bold');
				heading.setStyle('textAlign', 'left');
				heading.setStyle('color', 0x999999);
				heading.setStyle('fontSize', 16);
				myToolbar.addElement(heading);
				
				var uploadSearchLine:Line = IDGUI.makeLine();
				myToolbar.addElement(uploadSearchLine);
				
				// Add Add User button
				addUserButton = new IDButton('Add User');
				addUserButton.enabled = false;
				myToolbar.addElement(addUserButton);

				var addUserLine:Line = IDGUI.makeLine();
				myToolbar.addElement(addUserLine);
				
				// Create user dropdown list here
				// Has all the users in the database
				// Lets the user change between users to edit their details
				userListComboBox = new ComboBox();
				userListComboBox.enabled = false;
				userListComboBox.percentHeight = 100;
				userListComboBox.percentWidth = 100;
				myToolbar.addElement(userListComboBox);
				
				// Create the suspend user button
				suspendUserButton = new IDButton('Suspend User');
				suspendUserButton.enabled = false;
				myToolbar.addElement(suspendUserButton);
				
				// Create the delete user button
				deleteUserButton = new IDButton('Delete User');
				deleteUserButton.enabled = false;
				myToolbar.addElement(deleteUserButton);
				
			} else {
				// Create a heading for the toolbar for a non-admin user
				heading = new Label();
				heading.text = "Profile Manager for " + Auth.getInstance().getUsername();
				heading.setStyle('fontWeight', 'bold');
				heading.setStyle('textAlign', 'left');
				heading.setStyle('color', 0x999999);
				heading.setStyle('fontSize', 16);
				heading.percentWidth = 100;
				myToolbar.addElement(heading);
			}
			
			
			// Has the user details, and the yellow 'save changes' bar
			userDetailsGroup = new VGroup();
			userDetailsGroup.gap = 0;
			userDetailsGroup.percentWidth = 100;
			userDetailsGroup.percentHeight = 100;
			this.addElement(userDetailsGroup);
			
			// Create the sub-toolbar
			// Has the save and discard changes buttons
			mySubToolbar = new SubToolbar();
			//mySubToolbar.changeColor(0xAFAFAF);
			userDetailsGroup.addElement(mySubToolbar);
			
			mySubToolbar.height = 0 
			mySubToolbar.visible = false;
			// Takes up all the space on the left, so we can push the save and dsicard buttons to the right
			subToolbarLabel = new Label();
			subToolbarLabel.setStyle('fontWeight', 'bold');
			subToolbarLabel.setStyle('textAlign', 'left');
			subToolbarLabel.setStyle('color', 0x000000);
			subToolbarLabel.setStyle('fontSize', 14);
			subToolbarLabel.percentWidth = 100;
			mySubToolbar.addElement(subToolbarLabel);
			
			// the Save button for the sub-toolbar
			saveButton = new Button();
			saveButton.percentHeight = 100;
			saveButton.label = 'Save Changes';
			mySubToolbar.addElement(saveButton);
			
			// The discard changes button for the sub-toolbar
			discardButton = new Button();
			discardButton.percentHeight = 100;
			discardButton.label = 'Discard Changes';
			mySubToolbar.addElement(discardButton);
			
			// Create a scroller for the form
			myScroller = new Scroller();
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
			userDetailsGroup.addElement(myScroller);
			
			// Add box to center user details
			centeringGroup = new VGroup();
			centeringGroup.percentHeight = 100;
			centeringGroup.percentWidth = 100;
			centeringGroup.horizontalAlign = HorizontalAlign.CENTER;
			myScroller.viewport = centeringGroup;
			
			// Add users details for the scroller
			userDetailsView = new Profile();
			centeringGroup.addElement(userDetailsView);
			
//			myScroller.viewport = userDetailsView;
			this.disableUserDetailsView();

			// Setup Event Listeners
			backButton.addEventListener(MouseEvent.CLICK, backButtonClicked);
			if(admin) {
				// Listen for the user being viewed being changed
				userListComboBox.addEventListener(Event.CHANGE, userListComboBoxChanged);
				addUserButton.addEventListener(MouseEvent.CLICK, addUserButtonClicked);
				deleteUserButton.addEventListener(MouseEvent.CLICK, deleteUserButtonClicked);
				suspendUserButton.addEventListener(MouseEvent.CLICK, suspendUserButtonClicked);
			}
			saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			discardButton.addEventListener(MouseEvent.CLICK, discardButtonClicked);
			userDetailsView.updateProfileInformation.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			userDetailsView.changePassword.addEventListener(MouseEvent.CLICK, changePasswordButtonClicked);
			//userDetails.addEventListener(FocusEvent.FOCUS_IN, userDetailsHaveFocus);
			//userDetails.addEventListener(FocusEvent.FOCUS_OUT, userDetailsLostFocus);
		}
		
		// PUBLIC FUNCTIONS
		
		/**
		 * Adds a list of users to the dropdown box 
		 * @param userList	The list of usernames
		 * 
		 */		
		public function addUsers(userList:ArrayList):void {
			userListComboBox.enabled = true;
			userListComboBox.selectedIndex = -1;
			userListComboBox.dataProvider = userList;	
			userListComboBox.selectedIndex = 0;
		}
		
		/**
		 * Adds the users details for a specific user. 
		 * @param userDetails	The details for the user
		 * 
		 */		
		public function addDetails(userDetails:Model_User):void {
			// We have new details, enable the user view
			this.enableUserDetailsView();
			
			// If the current user is the admin user
			if(admin) {
				
				suspendUserButton.enabled = true
				deleteUserButton.enabled = true;
				addUserButton.enabled = true;
				
				// Show the password reset form only if the user selected is them
				// Or if its the first time this has loaded (since userDetails will == null)
				// We know if then must be the manager signed in
				if(userListComboBox.selectedItem == Auth.getInstance().getUsername() || !this.userDetails) {
					userDetailsView.passForm.visible = true;
					
					suspendUserButton.enabled = false;
					deleteUserButton.enabled = false;
					
				} else {
					// The user is not the currently logged in user,
					// Hide the reset form (for now! sicne its a mediaflux bug that you cant reset
					// other users password // TODO
//					userDetailsView.passForm.visible = false;
					userDetailsView.passForm.visible = true;
				}
			} else {
				// They arent the admin user, so they can also see the details for themselves
				// So they can see the password reset form at all times
				userDetailsView.passForm.visible = true;
			}
			
			// Change the color of the sub-toolbar back to normal (in case we had just added a user and its green)
			mySubToolbar.setColor(0xAFAFAF);
			
			// Save the current users details
			// This is so we can revert back to them easily when a user clicks the
			// 'discard changes' button
			this.userDetails = userDetails;
			
			// Add all the details to the view
			userDetailsView.meta_firstname.text = userDetails.meta_firstname;
			userDetailsView.meta_lastname.text = userDetails.meta_lastname;
			userDetailsView.meta_email.text = userDetails.meta_email;
			
			userDetailsView.meta_initial.text = userDetails.meta_initial;
			userDetailsView.meta_organisation.text = userDetails.meta_organisation;
			userDetailsView.meta_url.text = userDetails.meta_url;
			userDetailsView.meta_tel_business.text = userDetails.meta_tel_business+"";
			userDetailsView.meta_tel_home.text = userDetails.meta_tel_home+"";
			userDetailsView.meta_tel_mobile.text = userDetails.meta_tel_mobile+"";
			userDetailsView.meta_Address_1.text = userDetails.meta_Address_1;
			userDetailsView.meta_Address_2.text = userDetails.meta_Address_2;
			userDetailsView.meta_Address_3.text = userDetails.meta_Address_3;
			
			//  Check if the user has been suspended
			// We can tell this if her password has been chaned to the fixed
			// 'suspended password' in app model (so wrong!! NEED TO CHANGE IT!!! TODO)
			trace("suspend??", userDetails.meta_password);
			if(admin) {
				if(userDetails.meta_password == "suspended") {
					// The user is suspended
					suspendUserButton.label = "Unsuspend";
					isCurrentUserSuspended = true;
				} else {
					suspendUserButton.label = "Suspend";
					isCurrentUserSuspended = false;
				}
			}
		}
		
		/**
		 * Called by the Controller when changes were successfully saved 
		 * 
		 */		
		public function changeCompleted(msg:String = ""):void {
			this.showSubToolbar(0x00FF00, "Saved.", false);
			setTimeout(hideSubToolbar, 2000);
		}
		
		public function changeFailed(msg:String):void {
			this.showSubToolbar(0xFF0000, "Failed.", false);
			setTimeout(hideSubToolbar, 2000);
		}
		
		// EVENT LISTENER FUNCTIONS
		/**
		 * The back button was clicked. So back to the browser controller
		 * @param e
		 * 
		 */		
		private function backButtonClicked(e:MouseEvent):void {
			Dispatcher.call("browse");
		}
		
		/**
		 * THE USER LIST COMBO BOX WAS CHANGED.
		 * @param e
		 * 
		 */		
		private function userListComboBoxChanged(e:Event):void {
			if(userListComboBox.selectedIndex >= 0) {
				
				addUserButton.enabled = false;
				suspendUserButton.enabled = false;
				deleteUserButton.enabled = false;
				
				var newUser:String = userListComboBox.selectedItem;
								
				var myEvent:IDEvent = new IDEvent(IDEvent.USER_CHANGED);
				myEvent.data.username = newUser;
				this.dispatchEvent(myEvent);
				
				// Disable the user details while we load new details
				this.disableUserDetailsView();
			} else {
				Alert.show("User not found");
				trace("Username not valid");
			}
		}
		
		/**
		 * The add user button was clicked. Show the Add User view. 
		 * @param e
		 * 
		 */		
		private function addUserButtonClicked(e:MouseEvent):void {
			// Disable all the other managerment features
			// Like switching users etc, while we are in user creation mode
			switchToNewUserMode();
		}
		
		/**
		 * The Delete button was clicked. Tell the controller .
		 * @param e
		 * 
		 */		
		private function deleteUserButtonClicked(e:MouseEvent):void {
			trace("Delete User Button Clicked");
			var myEvent:IDEvent = new IDEvent(IDEvent.DELETE_USER_BUTTON_CLICKED);
			this.dispatchEvent(myEvent);
			
			// Disable user details while we load knew details
			this.disableUserDetailsView();
			
		}
		
		/**
		 * The Suspend user button was clicked. Tell the controller to suspend this user 
		 * @param e
		 * 
		 */		
		private function suspendUserButtonClicked(e:MouseEvent):void {
			trace("Suspend User Button Clicked");
			if(isCurrentUserSuspended) {
				// current user is suspended, unsuspend them
				myEvent = new IDEvent(IDEvent.UNSUSPEND_USER_BUTTON_CLICKED);
				this.dispatchEvent(myEvent);
				
			} else {
				// current user is unsuspended, suspend them
				var myEvent:IDEvent = new IDEvent(IDEvent.SUSPEND_USER_BUTTON_CLICKED);
				this.dispatchEvent(myEvent);
			}
			
			// Disable user details while we suspend users, and go back to the current users page
			this.disableUserDetailsView();
			
		}
		/**
		 * The save changes button was clicked. 
		 * @param e
		 * 
		 */		
		private function saveButtonClicked(e:MouseEvent):void {
			trace("Save button clicked");
			// The save button was clicked
			// Change the sub-toolbar to 'yellow' for processing
			mySubToolbar.setColor(0xFFFF00);
			
			if(addingUser) {
				// We are processing the request for a new user
				trace("We are adding a user");
			
				if(	newUserView.username.text != "" &&
					newUserView.password.text != "" &&
					newUserView.confirm_password.text != "" &&
					newUserView.password.text == newUserView.confirm_password.text) {
					
					var myEvent:IDEvent = new IDEvent(IDEvent.NEW_USER_DETAILS_SAVED);
					myEvent.data.username = newUserView.username.text;
					myEvent.data.password = newUserView.password.text;
					myEvent.data.email = newUserView.email.text;
					
					myEvent.data.meta_firstname = newUserView.meta_firstname.text;
					myEvent.data.meta_initial = newUserView.meta_initial.text;
					myEvent.data.meta_lastname = newUserView.meta_lastname.text;
					myEvent.data.meta_email = newUserView.email.text;
					
					myEvent.data.meta_organisation = newUserView.meta_organisation.text;
					myEvent.data.meta_url = newUserView.meta_url.text;
					myEvent.data.meta_tel_business = newUserView.meta_tel_business.text;
					myEvent.data.meta_tel_home = newUserView.meta_tel_home.text;
					myEvent.data.meta_tel_mobile = newUserView.meta_tel_mobile.text;
					myEvent.data.meta_Address_1 = newUserView.meta_Address_1.text;
					myEvent.data.meta_Address_2 = newUserView.meta_Address_2.text;
					myEvent.data.meta_Address_3 = newUserView.meta_Address_3.text;
					
					trace("- Dispatching Save Button Click Event");
					this.dispatchEvent(myEvent);
					
					// Remove save and cancel button from toolbar while we are saving
					saveButton.visible = false;
					discardButton.visible = false;
					subToolbarLabel.text = "Saving...";
				} else {
					// Some of the input details are inccorect
					// Change the sub-toolbar to red
					mySubToolbar.setColor(0xFF0000);
					trace("username or password incorrect");
					if(newUserView.password.text == newUserView.confirm_password.text) {
						Alert.show("Please fill in your username");
					} else {
						Alert.show("Your passwords do not match");
					}
				}
			} else {
				// Check that first name, last name and email are filled in
				if(	userDetailsView.meta_firstname.text != "" &&
					userDetailsView.meta_lastname.text != "" &&
					userDetailsView.meta_email.text != "") {
					
					trace("Updating User Profile");
					myEvent = new IDEvent(IDEvent.USER_DETAILS_SAVED);
					
					if(admin) {
						myEvent.data.username = userListComboBox.selectedItem;
					} else {
						myEvent.data.username = Auth.getInstance().getUsername();
					}
					myEvent.data.meta_firstname = userDetailsView.meta_firstname.text;
					myEvent.data.meta_initial = userDetailsView.meta_initial.text;
					myEvent.data.meta_lastname = userDetailsView.meta_lastname.text;
					myEvent.data.meta_email = userDetailsView.meta_email.text;
					
					
					myEvent.data.meta_organisation = userDetailsView.meta_organisation.text;
					myEvent.data.meta_url = userDetailsView.meta_url.text;
					myEvent.data.meta_tel_business = userDetailsView.meta_tel_business.text;
					myEvent.data.meta_tel_home = userDetailsView.meta_tel_home.text;
					myEvent.data.meta_tel_mobile = userDetailsView.meta_tel_mobile.text;
					myEvent.data.meta_Address_1 = userDetailsView.meta_Address_1.text;
					myEvent.data.meta_Address_2 = userDetailsView.meta_Address_2.text;
					myEvent.data.meta_Address_3 = userDetailsView.meta_Address_3.text;
					
					trace("- Dispatching User Details Saved Event");
					this.dispatchEvent(myEvent);
					
					this.showSubToolbar(SubToolbar.YELLOW, "Saving...", false);
				} else {
					// Either the first name, last name, or email are blank
					// Show an error.
					trace("first name last name email not correct");
				}	
			}
		}
		
		/**
		 * The change password button was clicked.
		 * 
		 * The user needs to provide their old password, as well as their new password
		 * @param e
		 * 
		 */		
		private function changePasswordButtonClicked(e:MouseEvent):void {
			// Check that the password and their confirm password box match
			if(userDetailsView.password.text != userDetailsView.confirm_password.text) {
				Alert.show("Passwords do not match");
				return;
			}
			if(userDetailsView.password.text == "") {
				Alert.show("Your password is blank");
				return;
			}
			
			this.showSubToolbar(0xFFFF00, 'Saving...', false);
			
			// Set the password and the old-password off to hte controller
			var changePasswordEvent:IDEvent = new IDEvent(IDEvent.CHANGE_PASSWORD_CLICKED);
			if(Auth.getInstance().isSysAdmin()) {
				changePasswordEvent.data.username = userListComboBox.selectedItem;
			} else {
				changePasswordEvent.data.username = Auth.getInstance().getUsername();
			}
			changePasswordEvent.data.newPassword = userDetailsView.password.text;
			this.dispatchEvent(changePasswordEvent);
			
			// Clear the stuff that was entered
			userDetailsView.password.text = "";
			userDetailsView.confirm_password.text = "";
		}
		
		/**
		 * The discard button on the sub-toolbar was clicked
		 * This is changed to 'cancel' when creating a new user (instead of discard) 
		 * @param e
		 * 
		 */		
		private function discardButtonClicked(e:MouseEvent):void {
			if(addingUser) {
				// We are adding a user, so the 'discard' button 
				// Is now the 'cancel' button
				userListComboBox.enabled = true;
				switchToViewMode();
				this.addDetails(this.userDetails);
			} else {
				// Replace the current details, with the ones saved
				this.addDetails(this.userDetails);
			}
		}
		
		public function switchToNewUserMode():void {
			// Say we are in editing a user mode
			addingUser = true;
			// Show the sub-toolbar
			showSubToolbar(0xAFAFAF, "", true);
			
			// Change the label on the sub-toolbar to be 'cancel' TODO 
			discardButton.label = "Cancel";
			newUserView = new NewProfile();
				
			centeringGroup.removeAllElements();
			centeringGroup.addElement(newUserView);
//			myScroller.viewport = newUserView;
		
			if(admin) {
				addUserButton.enabled = false;
				userListComboBox.enabled = false;	
				suspendUserButton.enabled = false;
				deleteUserButton.enabled = false;
			}
		} 
		
		public function switchToViewMode():void {
			addingUser = false;
			// Hide the toolbar
			mySubToolbar.height = 0;
			
			userDetailsView = new Profile();
			
			centeringGroup.removeAllElements();
			centeringGroup.addElement(userDetailsView);
			
//			myScroller.viewport = userDetailsView;
			
			// Make sure the button on the profile when you click it, it updates
			userDetailsView.updateProfileInformation.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			userDetailsView.changePassword.addEventListener(MouseEvent.CLICK, changePasswordButtonClicked);
			
			
			// Check if 
			if(admin) {
				addUserButton.enabled = true;
//				userListComboBox.enabled = true;	
				if(userListComboBox.selectedItem != Auth.getInstance().getUsername()) {
					suspendUserButton.enabled = true;
					deleteUserButton.enabled = true;
				}
			}
			mySubToolbar.height = 0;
			mySubToolbar.visible = false;
			
			addingUser = false;
			
		}
		
		
		
		/* HELPER FUNCTIONS */
		private function disableUserDetailsView():void {
			userDetailsView.alpha = 0.3;
			userDetailsView.enabled = false;
		}
		
		private function enableUserDetailsView():void {
			userDetailsView.alpha = 1;
			userDetailsView.enabled = true;
		}
		
		private function showSubToolbar(color:uint, text:String = "", buttonsVisible:Boolean = false):void {
			mySubToolbar.setColor(color);
			if(buttonsVisible) {
				saveButton.visible = true;
				discardButton.visible = true;
			} else {
				saveButton.visible = false;
				discardButton.visible = false;
			}
			subToolbarLabel.visible = true;
			subToolbarLabel.text = text;	
			mySubToolbar.height = SubToolbar.SUB_TOOLBAR_HEIGHT;
			mySubToolbar.visible = true;
		}
		
		private function hideSubToolbar():void {
			mySubToolbar.height = 0;
			subToolbarLabel.visible = false;
		}
		/**
		 * Clear the user data fields 
		 * 
		 */		
		private function clearUserDetails():void {
			userDetailsView.meta_firstname.text = "";
			userDetailsView.meta_lastname.text = "";
			userDetailsView.meta_email.text = "";
			
			userDetailsView.meta_initial.text = "";
			userDetailsView.meta_organisation.text = "";
			userDetailsView.meta_url.text = "";
			userDetailsView.meta_tel_business.text = "";
			userDetailsView.meta_tel_home.text = "";
			userDetailsView.meta_tel_mobile.text = "";
			userDetailsView.meta_Address_1.text = "";
			userDetailsView.meta_Address_2.text = "";
			userDetailsView.meta_Address_3.text = "";
		}
	}
}