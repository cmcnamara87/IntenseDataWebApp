package Controller {
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import View.Login;
	
	import flash.events.MouseEvent;
	
	public class LoginController extends AppController {
		
		private var _authOverride:Boolean = false;
		
		private var quickLogin:Boolean = true;
		private var assetID:Number = 2149;
		 
		// TODO For some reason, the login is being received twice, i cant work out why, so this
		// test it hasnt been recieved twice, needs to really be fixed.
		public static var loginAlreadyReceived:Boolean = false;
		
		//Calls the superclass and shows the logout button
		public function LoginController() {
			_authOverride = Dispatcher.getAuthOverride();
			view = new Login();
			super();
			showLogoutButton = false;
			super.setLogoutButton();
		}
		
		//INIT
		override public function init():void {
			setupEventListeners();
			if(quickLogin) {
				Auth.getInstance().login("cmcnamara87","test");
			}
		}
		
		// Setup specific event listeners
		private function setupEventListeners():void {
			(view as Login).loginbox.addEventListener(IDEvent.LOGIN_CLICKED,loginClicked);
			Auth.getInstance().addEventListener(IDEvent.LOGIN_RESPONSE, loginResponse);
		} 
		
		// Called when the login button is clicked.  Will automatically login with manager credentials if autologin is set
		private function loginClicked(e:*):void {
			(view as Login).loginbox.setNotification("Logging in...");
			if(!_authOverride) {
				Auth.getInstance().login((view as Login).loginbox.usernameBox.getText(),(view as Login).loginbox.passwordBox.getText());
			} else {
				Auth.getInstance().login("manager","change_me");
			}
		}
		
		// Response whether login was successful
		private function loginResponse(e:IDEvent):void {
			trace("- Login Response Received", loginAlreadyReceived);
			// TODO need to fix this. (described by static variable at the top)
			if(loginAlreadyReceived) {
				trace("- Already Received");
				return;
			}
			loginAlreadyReceived = true;
			(view as Login).loginbox.setNotification(e.data.message);
			if(e.data.success) {
				loginSuccessful();
			} else {
				trace("***"+e.data.message);
				loginAlreadyReceived = false;
			}
		}
		
		// Called if login was successful
		private function loginSuccessful():void {
			trace("- Login Successful, redirecting");
			redirect();
		}
		
		// Log in was successful, so redirect to either the default route or the last used route
		private function redirect():void {
			if(quickLogin && assetID != -1) {
				var redirectURL:String = "view/" + assetID;
			} else {
				redirectURL = Auth.getInstance().getRedirectURL();
			}
			trace("redirectURL", redirectURL);
			if(redirectURL == 'login') {
				redirectURL = Router.defaultURL;
			}
			Dispatcher.call(redirectURL);
		}
	}
}