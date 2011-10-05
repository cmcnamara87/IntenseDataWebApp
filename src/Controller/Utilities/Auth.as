package Controller.Utilities {
	
	import Controller.AppController;
	import Controller.BrowserController;
	import Controller.IDEvent;
	import Controller.LoginController;
	
	import Model.AppModel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Auth extends EventDispatcher {
		
		private static var _instance:Auth;
		private var _sessionID:String = "";
		private var _username:String = "";
		private var _password:String = "";
		private var _redirectURL:String = "";
		private var isSystemAdministrator:Boolean = false;
		private var isUser:Boolean = false;
		
		public var userRoleArray:Array = new Array();
		
		//Singleton protection
		public function Auth(enforcer:SingletonEnforcer) {
			super();
			if(!enforcer) {
				throw new Error("Router must be called from getInstance()");
			}
		}
		
		//Singleton protection
		public static function getInstance():Auth {
			if(!_instance) {
				_instance = new Auth(new SingletonEnforcer);
			}
			return _instance;
		}
		
		//Calls the model to login
		public function login(username:String,password:String):void {
			
			if(username == "") {
				username = "username";
			}
			if(password == "") {
				password = "password";
			}
			_username = username;
			_password = password;
			AppModel.getInstance().login(_username,_password,loginCallback);			
		}
		
		//Returned from the login mediaflux call.  Returns a Session ID if successful
		public function loginCallback(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			trace("login callback", e.target.data);
			if (dataXML.reply.@type == "result") {
				// Successfully logged in
				
				// Set the session ID
				setSessionID(dataXML..session);
				
				// Now Get out the roles of the user (make sure they have the IDUSER role)
				AppModel.getInstance().getUserRoles(userRolesRetrieved);
				
			} else {			
				var response:IDEvent = new IDEvent(IDEvent.LOGIN_RESPONSE);
				response.data.success = false;
				if(dataXML.reply.message == "authentication failure") {
					response.data.message = "Username or password\n incorrect";
				} else {
					response.data.message = dataXML.reply.message;
				}
				this.dispatchEvent(response);
			}
		
		}
		
		/**
		 * We have retrieved the roles the user has. 
		 * @param e
		 * 
		 */		
		public function userRolesRetrieved(e:Event):void {
			trace("- User's Roles Retrieved");
			var dataXML:XML = XML(e.target.data);
			
			var assets:Array = new Array();
			// Get out a list of XML objects, (each one is an asset)
			var rolesXML:XMLList = dataXML.reply.result.actor.role;
			for each(var role:XML in rolesXML) {
				trace("role is", role.@type, role);
				if(role.@type == "role") {
					// Save all the users role in an array, for checking later
					userRoleArray.push(role);
					
					trace("matches a role");
					//if(role == "iduser") {
					if(role == "ERA-user") {
						trace("ID USER FOUND");
						isUser = true;
					}
					if(role == "system-administrator") {
						isSystemAdministrator = true;
					}
					if(role == "sys_admin") {
						isSystemAdministrator = true;	
					}
				}
			}
			
			if(!isUser) {
				// The user does not have the user role
				// Delete their session id, since they shouldnt be able to log in
				_sessionID = "";
				
				response = new IDEvent(IDEvent.LOGIN_RESPONSE);
				response.data.success = false;
				response.data.message = "Account suspended.";
				this.dispatchEvent(response);
				return;
			} else {
				// The user does have the user role
				// Tell the login controller all is good
				var response:IDEvent = new IDEvent(IDEvent.LOGIN_RESPONSE);
				response.data.success = true;
				response.data.message = "Successfully Logged In";
				this.dispatchEvent(response);
			}
		}
		
		//Resets all login information
		public function logout(useConnection:Boolean):void {
			// TODO this is a bug fix, since it seems to be logging in multipe times at once
			// so when we log out, we need to reset this
			LoginController.loginAlreadyReceived = false;
			this.isSystemAdministrator = false;
			this.isUser = false;
			
			// In case we are just forcing a logout, because the internet connection has been lossed
			// we only actually try to log out, if we have a connection
			if(useConnection) {
				AppModel.getInstance().logout();
			}
			
			BrowserController.resetBrowserController();
			
			_username = "";
			_password = "";
			_sessionID = "";
		}
		
		//Grab the Session ID for sending subsequent requests to mediaflux
		public function getSessionID():String {
			return _sessionID;
		}
		
		//Sets the Session ID for mediaflux
		private function setSessionID(_newSessionID:String):void {
			_sessionID = _newSessionID;
		}
		
		//Checks whether there is a Session ID
		public function hasSession():Boolean {
			if(_sessionID == "") {
				return false;
			} else {
				return true;
			}
		}
		
		//Returns the URL the user was at before login
		public function getRedirectURL():String {
			return _redirectURL;
		}
		
		//Sets the URL the user was at before login
		public function setRedirectURL(redirectURL:String):void {
			_redirectURL = redirectURL;
		}
		
		//Returns the logged in username
		public function getUsername():String {
			return _username;
		}
		
		/**
		 * Gets out if the user is a sys-admin
		 * @return TRUE is the current user is a sys-admin, FALSE othewrise 
		 * 
		 */		
		public function isSysAdmin():Boolean {
			return isSystemAdministrator;
		}
		//Returns the password (only for changing password)
		public function getPassword():String {
			return _password;
		}
		
		//Sets the new password
		public function setPassword(newpassword:String):void {
			_password = newpassword
		}
	}
}

// Singleton Enforcer Class
class SingletonEnforcer {
	
}