package Controller {
	import Controller.Utilities.Auth;
	
	import View.Layout;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	
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
			super();
		}
		
		//Whether the logout button is shown or not
		protected function setLogoutButton():void {
			if(layout) {
				if(layout.header.logoutButton) {
					layout.header.logoutButton.visible = showLogoutButton;
					layout.header.logoutButton.addEventListener(MouseEvent.MOUSE_UP,logoutClicked);
					layout.header.profileButton.visible = showLogoutButton;
					layout.header.profileButton.label = Auth.getInstance().getUsername();
					layout.header.profileButton.visible = showLogoutButton;
					layout.header.profileButton.label = Auth.getInstance().getUsername();
					layout.header.profileButton.addEventListener(MouseEvent.MOUSE_UP,profileClicked);
				}
			}
		}
		
		//Calls the logout method
		private function logoutClicked(e:MouseEvent):void {
			Dispatcher.logout();
		}
		
		//Calls the profile controller
		private function profileClicked(e:MouseEvent):void {
			Dispatcher.call("profile");
		}
		
		//Loads the view set by the controller
		private function loadView():void {
			if(layout) {
				if(view) {
					layout.content.addElement(view);
				}
			}
		}
		
		protected function removeLogoutListener():void {
			if(layout) {
				if(layout.header.logoutButton) {
					if(layout.header.logoutButton.hasEventListener(MouseEvent.MOUSE_UP)) {
						layout.header.logoutButton.alpha = 0.5;
						layout.header.logoutButton.removeEventListener(MouseEvent.MOUSE_UP,logoutClicked);
					}
				}
			}
		}
		
		protected function addLogoutListener():void {
			if(layout) {
				if(layout.header.logoutButton) {
					layout.header.logoutButton.alpha = 1;
					layout.header.logoutButton.addEventListener(MouseEvent.MOUSE_UP,logoutClicked);
				}
			}
		}
		
		
		//When the controller is destroyed/switched
		public function dealloc():void {
			if(layout) {
				if(layout.header.logoutButton) {
					if(layout.header.logoutButton.hasEventListener(MouseEvent.MOUSE_UP)) {
						layout.header.logoutButton.removeEventListener(MouseEvent.MOUSE_UP,logoutClicked);
					}
					if(layout.header.profileButton.hasEventListener(MouseEvent.MOUSE_UP)) {
						layout.header.profileButton.removeEventListener(MouseEvent.MOUSE_UP, profileClicked);
					}
				}
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