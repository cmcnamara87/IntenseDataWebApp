package Controller {
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	
	import View.Layout;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	// All controllers extend this class
	public class AppController extends Object {
		
		//The layout for the application
		public static var layout:Layout; 
		//The specific view
		protected var view:UIComponent;
		//Whether the logout button is shown or not
		protected var showLogoutButton:Boolean = true;
		
		public function AppController() {
			setLogoutButton();
			loadView();
			
			layout.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void {
				// The layout has finished drawing
				// Setup Event Listeners
				setupEventListeners();
			});
			
			// TODO whatever
			layout.content.addEventListener(FlexEvent.CONTENT_CREATION_COMPLETE, function(e:FlexEvent):void {
				setupButtons();
			});
			
			super();
		}
		
		private static function setupEventListeners():void {
			layout.header.logoutButton.addEventListener(MouseEvent.CLICK, logoutButtonClicked);
			layout.header.notificationButton.addEventListener(MouseEvent.CLICK, notificationButtonClicked);
			layout.header.profileButton.addEventListener(MouseEvent.MOUSE_UP,profileButtonClicked);
		}
		
		
		private static function logoutButtonClicked(e:MouseEvent):void {
			trace("Logout button clicked");
			Dispatcher.logout();
		}
		private static function notificationButtonClicked(e:MouseEvent):void {
			trace("Notification button clicked");
			layout.notificationBox.visible = !layout.notificationBox.visible;
		}
		private static function profileButtonClicked(e:MouseEvent):void {
			trace("Profile button clicked");
			Dispatcher.call("profile");
		}
		
		private static function setupButtons():void {
			// Listen for notification button being clicked
			trace("set up buttons!!!**************");
			layout.header.globalButtonGroup.visible = true;
			layout.header.profileButton.label = "Profile (" + Auth.getInstance().getUsername() + ")";
			
			// Get all notifications
		}
		
		
		//Whether the logout button is shown or not
		protected function setLogoutButton():void {
			if(layout) {
				if(layout.header.logoutButton) {
					setupButtons();
				}
			}
		}
		
		//Loads the view set by the controller
		private function loadView():void {
			if(layout) {
				if(view) {
					layout.content.addElement(view);
				}
			}
		}
		
//		protected function removeLogoutListener():void {
//			if(layout) {
//				if(layout.header.logoutButton) {
//					if(layout.header.logoutButton.hasEventListener(MouseEvent.MOUSE_UP)) {
//						layout.header.logoutButton.alpha = 0.5;
//						layout.header.logoutButton.removeEventListener(MouseEvent.MOUSE_UP,logoutClicked);
//					}
//				}
//			}
//		}
		
//		protected function addLogoutListener():void {
//			if(layout) {
//				if(layout.header.logoutButton) {
//					layout.header.logoutButton.alpha = 1;
//					layout.header.logoutButton.addEventListener(MouseEvent.MOUSE_UP,logoutClicked);
//				}
//			}
//		}
		
		
		//When the controller is destroyed/switched
		public function dealloc():void {
			if(layout) {
//				if(layout.header.logoutButton) {
//					if(layout.header.logoutButton.hasEventListener(MouseEvent.MOUSE_UP)) {
//						layout.header.logoutButton.removeEventListener(MouseEvent.MOUSE_UP,logoutClicked);
//					}
//					if(layout.header.profileButton.hasEventListener(MouseEvent.MOUSE_UP)) {
//						layout.header.profileButton.removeEventListener(MouseEvent.MOUSE_UP, profileClicked);
//					}
//				}
				layout.content.removeAllElements();
			}
		}
		
		//Protection to ensure controllers take advantage of the init method
		public function init():void {
			var classname:String = getQualifiedClassName(this);
			throw new Error(classname+" must implement the init() method");
		}
	}
}