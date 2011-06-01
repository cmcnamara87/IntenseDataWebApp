package Controller {
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Notification;
	
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
	
	import spark.components.Group;
	
	// All controllers extend this class
	public class AppController extends Object {
		
		//The layout for the application
		public static var layout:Layout; 
		//The specific view
		protected var view:UIComponent;
		//Whether the logout button is shown or not
		protected static var showLogoutButton:Boolean = true;
		
		private var notifications:XML;
		
		public function AppController() {
			trace("App Controller Called");
			setLogoutButton();
			getNotifications();
			loadView();
			super();
		}
		
		//Whether the logout button is shown or not
		protected function setLogoutButton():void {
			trace("Setting Logout Button");
			if(layout) {
				trace("layout exists");
				if(layout.header.logoutButton) {
					trace("Logout button exists");
					layout.header.logoutButton.visible = showLogoutButton;
					layout.header.logoutButton.addEventListener(MouseEvent.MOUSE_UP,logoutClicked);
					layout.header.profileButton.visible = showLogoutButton;
					layout.header.profileButton.label = Auth.getInstance().getUsername();
					
					trace("Trying to remove event listener for profile button");
					layout.header.profileButton.removeEventListener(MouseEvent.CLICK, profileClicked);
					
//					if(layout.header.profileButton222.hasEventListener(MouseEvent.CLICK)) {
//						trace("Profile button already has click event");
//					} else {
//						trace("Profile button adding mouse clicked event");
						layout.header.profileButton.addEventListener(MouseEvent.CLICK, profileClicked);
//						layout.header.profileButton222.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
//							trace("you clicked the profile button");
//						});
//					}
					
					layout.header.notificationButton.addEventListener(MouseEvent.CLICK, showNotifications);
					
					layout.header.notificationButton.visible = showLogoutButton; 
				} else {
					trace("Logout button does not exists");
				}
			}
		}
		
		//Calls the logout method
		private function logoutClicked(e:MouseEvent):void {
			trace("log out button clicked");
			layout.header.notificationButton.visible = false;
			layout.header.profileButton.visible = false;
			layout.header.logoutButton.visible = false;
			
			Dispatcher.logout();
		}
		
		//Calls the profile controller
		private function profileClicked(e:MouseEvent):void {
			trace("profile clicked");
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
		
		//When the controller is destroyed/switched
		public function dealloc():void {
			if(layout) {
				if(layout.header.logoutButton) {
					if(layout.header.logoutButton.hasEventListener(MouseEvent.MOUSE_UP)) {
						layout.header.logoutButton.removeEventListener(MouseEvent.MOUSE_UP,logoutClicked);
						layout.header.profileButton.removeEventListener(MouseEvent.CLICK, profileClicked);
						layout.header.notificationButton.removeEventListener(MouseEvent.CLICK, showNotifications);
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
		
		/**
		 * Get the notification for a the current user from the database. 
		 * 
		 */		
		private function getNotifications():void {
			AppModel.getInstance().getNotifications(gotNotifications);
		}
		
		/**
		 * Got notifications for a user.
		 * Stores the notifications and updates the notification button to show a notification
		 * count.
		 *  
		 * @param e
		 * 
		 */		
		private function gotNotifications(e:Event):void {
			trace("got notifications", e.target.data);
			var dataXML:XML = XML(e.target.data);
			if(dataXML.reply.@type == "result") {
				// Save the notifications, and get the notification count
				this.notifications = dataXML;
				var notificationsList:XMLList = dataXML.reply.result.asset
				layout.header.notificationButton.label = "Notifications (" + notificationsList.length() + ")";
			} else {
				trace("Could not get notifications");
			}
		}
		
		/**
		 * Show the notifications for the current user. Called after the notification button was clicked. 
		 * @param e
		 * 
		 */		
		private function showNotifications(e:MouseEvent):void {
			trace("stuff", layout.notificationPanel, "visible", layout.notificationPanel.visible);
			if(!layout.notificationPanel.visible) {
				layout.notificationPanel.visible = true;
				layout.notificationPanel.x = layout.header.notificationButton.x + layout.header.notificationButton.width - layout.notificationPanel.width;
				layout.notificationPanel.y = layout.header.notificationButton.y + layout.header.notificationButton.height;
			} else {
				layout.notificationPanel.visible = false;
			}
			
			if(notifications) {
				trace("We have some notifications");
				var notificationArray:Array = AppModel.getInstance().extractAssetsFromXML(notifications, Model_Notification);
				notificationArray = notificationArray.reverse();
				layout.header.notificationButton.label = "Notifications (" + notificationArray.length + ")";
				
				layout.notificationPanel.addNotifications(notificationArray);
			} else {
				trace("Something went wrong, and we dont have any notifications stored");
			}
		
		}
	}
}