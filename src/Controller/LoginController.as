package Controller {
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import Model.AppModel;
	import Model.Model_ERAProject;
	
	import View.Login;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	public class LoginController extends AppController {
		
		private var _authOverride:Boolean = false;
		
		private var quickLogin:Boolean = false;
		private var assetID:Number = -1;
		 
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
			
			layout.header.visible = false;
			layout.header.includeInLayout = false;
			if(quickLogin) {
				Auth.getInstance().login("cmcnamara87","test1");
			}
		}
		
		// Setup specific event listeners
		private function setupEventListeners():void {
			(view as Login).loginbox.addEventListener(IDEvent.LOGIN_CLICKED,loginClicked);
			Auth.getInstance().addEventListener(IDEvent.LOGIN_RESPONSE, loginResponse);
		} 
		
		// Called when the login button is clicked.  Will automatically login with manager credentials if autologin is set
		private function loginClicked(e:*):void {
			AppController.layout.notificationBar.showProcess("Logging in...");
//			(view as Login).loginbox.setNotification("Logging in...");
			if(!_authOverride) {
				Auth.getInstance().login((view as Login).loginbox.usernameBox.getText(),(view as Login).loginbox.passwordBox.getText());
			} else {
				Auth.getInstance().login("cmcnamara87","test1");
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
			
			
			if(e.data.success) {
				// The user has successfully logged in
				loginSuccessful();
				AppController.layout.notificationBar.showGood("Logging in");
				//(view as Login).loginbox.setNotification(e.data.message);
			} else {
				// The user was suspended or gave an incorrect username/password
				trace("***"+e.data.message);
				AppController.layout.notificationBar.showError("Incorrect username/password");
				loginAlreadyReceived = false;
			}
		}
		
		/**
		 * Login to MFLUX was successful. Get out all the ERA projects 
		 * 
		 */		
		private function loginSuccessful():void {
			trace("- Login Successful, redirecting");
			
			// Get out all ERA projects
			AppModel.getInstance().getERAProjects(gotERAProjects);
			
		}
		/**
		 * Got all the ERA projects, set the most recent one was the current ERA project 
		 * @param status			True if we successfully retrieved all the ERA proejcts
		 * @param eraProjectArray	Array of era projects
		 * 
		 */
		private function gotERAProjects(status:Boolean, eraProjectArray:Array):void {
			
			// Hide the logging in notification bar
			AppController.layout.notificationBar.hide();
			
			
			if(eraProjectArray.length == 0) {
				// There are no eras setup, so lets do that
				if(Auth.getInstance().isSysAdmin()) {
					Dispatcher.call("erasetup");
				} else {
					Dispatcher.call("case");
				}
			} else {
				// There are eras setup
				// so lets save them
				trace("ERA Count", eraProjectArray.length);
				var yearFound:Number = 0;
				
				// Save the list of all the ERAs
				AppController.eraProjectArray = eraProjectArray;
				
				// Pick out the newest ERA, and set it as the current
				for each(var eraProject:Model_ERAProject in eraProjectArray) {
					trace("Era year", yearFound, Number(eraProject.year));
					if(Number(eraProject.year) > yearFound) {
						trace("Era found");
						
						AppController.currentEraProject = eraProject;
						yearFound = Number(eraProject.year);
					}
				}
				trace("Era saved is",AppController.currentEraProject); 
				redirect();
			}
			
		}
		
		// Log in was successful, so redirect to either the default route or the last used route
		private function redirect():void {
			if(quickLogin && assetID != -1) {
				var redirectURL:String = "view/" + assetID;
				Dispatcher.call(redirectURL);
				return;
			} else {
				redirectURL = Auth.getInstance().getRedirectURL();
			}
			trace("redirectURL", redirectURL);
			if(redirectURL == 'login') {
				redirectURL = Router.defaultURL;
				trace("must be here", redirectURL);
				Dispatcher.call(redirectURL);
				return;
			}
			trace("did it get to here");
			//Dispatcher.call(redirectURL);
//			Dispatcher.call('browse');
//			Dispatcher.call('case');
			Dispatcher.call('splash');
		}
	}
}