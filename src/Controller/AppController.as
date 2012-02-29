package Controller {
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import Model.AppModel;
	import Model.Model_ERANotification;
	import Model.Model_ERAProject;
	import Model.Model_ERAUser;
	import Model.Model_Notification;
	
	import View.Layout;
	import View.components.IDGUI;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.events.IndexChangeEvent;
	
	// All controllers extend this class
	public class AppController extends Object {
		
		//The layout for the application
		public static var layout:Layout; 
		//The specific view
		protected var view:UIComponent;
		//Whether the logout button is shown or not
		protected var showLogoutButton:Boolean = true;
		
		// Store current notifications for hte user
		public static var allNotificationsArray:Array = new Array();
		public static var notificationsArray:Array = new Array();
		
		public static var eraProjectArray:Array = new Array(); // an array of all the era projects in the system
		[Bindable]
		public static var currentEraProject:Model_ERAProject; // the current era project we are looking at
//		public static var ERARoles:Array = new Array("sys_admin", "monitor", "researcher", "production_manager", "production_team", "viewer");
		
		
		private static var notificationTimer:Timer = new Timer(300000);
		private static var timeoutAvoidanceTimer:Timer = new Timer(600000);
		
		public function AppController() {
			setLogoutButton();
			loadView();
			
			layout.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void {
				// The layout has finished drawing
				// Setup Event Listeners
				setupEventListeners();
			});
			
			notificationTimer.addEventListener(TimerEvent.TIMER, updateNotifications);
			notificationTimer.start();
			
			timeoutAvoidanceTimer.addEventListener(TimerEvent.TIMER, timeoutUpdate);
			timeoutAvoidanceTimer.start();
			
			// The content has finished loading
			// means we have gone to another page, so lets update whats on the buttons
			layout.content.addEventListener(FlexEvent.CONTENT_CREATION_COMPLETE, function(e:FlexEvent):void {
				setupButtons();
			});
			
			layout.addEventListener(IDEvent.ERA_CHANGE_NOTIFICATION_READ_STATUS, notificationStatusChanged);
			layout.addEventListener(IDEvent.ERA_MARK_ALL_NOTIFICATIONS_AS_READ, markAllAsReadButtonClicked);
			
			super();
		}
	
		private static function timeoutUpdate(e:TimerEvent):void {
			AppModel.getInstance().stayActiveRequest();
		}
		
		private static function setupEventListeners():void {
			layout.header.logoutButton.addEventListener(MouseEvent.CLICK, logoutButtonClicked);
			layout.header.notificationButton.addEventListener(MouseEvent.MOUSE_DOWN, notificationButtonClicked);
			layout.header.profileButton.addEventListener(MouseEvent.MOUSE_UP,profileButtonClicked);
			
			// Mode switching buttons
			layout.header.adminToolsButton.addEventListener(MouseEvent.CLICK, adminToolsButtonClicked);
			layout.header.productionToolsButton.addEventListener(MouseEvent.CLICK, productionToolsButtonClicked);
			
			// Admin buttons
			layout.header.newERAButton.addEventListener(MouseEvent.CLICK, newEraButtonClicked);
			layout.header.dashboardButton.addEventListener(MouseEvent.CLICK, dashboardButtonClicked);
			layout.header.userAdminButton.addEventListener(MouseEvent.CLICK, userAdminButtonClicked);
			layout.header.caseCreatorButton.addEventListener(MouseEvent.CLICK, caseCreatorButtonClicked);
			layout.header.reportButton.addEventListener(MouseEvent.CLICK, reportButtonClicked, false, 0, true);
			
			// Changing ERA years
			layout.header.eraDropDown.addEventListener(IndexChangeEvent.CHANGE, eraChanged);
		}
		
		
		private static function logoutButtonClicked(e:MouseEvent):void {
			trace("Logout button clicked");
			Dispatcher.logout();
		}
		private static function notificationButtonClicked(e:MouseEvent):void {
			if(AppController.notificationsArray.length == 0) {
				hideNotifications();
				return;
			}
			
			if(layout.notificationPanel.visible == false) {
				showNotifications();
			} else {
				hideNotifications();
			}
		}
		private static function profileButtonClicked(e:MouseEvent):void {
			trace("Profile button clicked");
			Dispatcher.call("profilepage");
		}
		
		/**
		 * The Admin Tools button was clicked 
		 * @param e		Mouse Click Event
		 * 
		 */
		private static function adminToolsButtonClicked(e:MouseEvent):void {
			// Show the admin tool buttons
			showAdminToolButtons();
			
			// load the Dashboard (which is the default admin tool)
			if(Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, currentEraProject.year)) {
				Dispatcher.call("reports");
			} else {
				Dispatcher.call("casecreator");
			}
		}
		
		/**
		 * Updates the ERA dropdown list to be whatevers in the ERA array 
		 * 
		 */
		public static function updateERADropdownList():void {
			layout.header.addERAProjects(AppController.eraProjectArray);	
			if(AppController.eraProjectArray.length == 0) {
				layout.header.eraDropDown.enabled = false;
				layout.header.caseCreatorButton.enabled = false;
				layout.header.userAdminButton.enabled = false;
			} else {
				layout.header.eraDropDown.enabled = true;
				layout.header.caseCreatorButton.enabled = true;
				layout.header.userAdminButton.enabled = true ;
			}
		}
		
		/**
		 * Shows the admin tool buttons 
		 * 
		 */
		private static function showAdminToolButtons():void {
			
			// Show the admin tools buttons
			layout.header.adminToolsButton.setStyle("chromeColor", 0x000000);
			layout.header.productionToolsButton.setStyle("chromeColor", 0x222222);
			
			// make them visible
			layout.header.adminToolButtons.visible = true;
			layout.header.adminToolButtons.includeInLayout = true;
			
			// special stuff for a monitor
			if(Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, currentEraProject.year) && !Auth.getInstance().isSysAdmin()) {
				layout.header.newERAButton.visible = false;
				layout.header.newERAButton.includeInLayout = false;
				
				layout.header.userAdminButton.visible = false;
				layout.header.userAdminButton.includeInLayout = false;
				
				layout.header.caseCreatorButton.visible = false;
				layout.header.caseCreatorButton.includeInLayout = false;
				
				layout.header.eraDropDown.visible = false;
				layout.header.eraDropDown.includeInLayout = false;
			} else {
				layout.header.newERAButton.visible = true;
				layout.header.newERAButton.includeInLayout = true;
				
				layout.header.userAdminButton.visible = true;
				layout.header.userAdminButton.includeInLayout = true;
				
				layout.header.caseCreatorButton.visible = true;
				layout.header.caseCreatorButton.includeInLayout = true;
				
				layout.header.eraDropDown.visible = true;
				layout.header.eraDropDown.includeInLayout = true;
			}
			
			// Add the era to the list
			updateERADropdownList();
		}
		
		/**
		 * Hide the admin tool buttons 
		 * 
		 */
		private static function hideAdminToolButtons():void {
			layout.header.adminToolsButton.setStyle("chromeColor", 0x222222);
			layout.header.productionToolsButton.setStyle("chromeColor", 0x000000);
			
			layout.header.adminToolButtons.visible = false;
			layout.header.adminToolButtons.includeInLayout = false;
		}
		
		
		private static function productionToolsButtonClicked(e:MouseEvent):void {
			hideAdminToolButtons();
			//Dispatcher.call("browse");
			Dispatcher.call("case");
		}
		
		private static function eraChanged(e:IndexChangeEvent):void {
			var dropdownList:DropDownList = (e.target as DropDownList);
			
			// Grab out the selected era's data
			var eraProject:Model_ERAProject = dropdownList.selectedItem.data;
			// Set it as the new current era
			currentEraProject = eraProject;
			
			// Refresh the page
			var currentURL:String = Router.getInstance().getURL();
			Dispatcher.call(currentURL);
		}
		private static function newEraButtonClicked(e:MouseEvent):void {
			Dispatcher.call("erasetup");
		}
		private static function dashboardButtonClicked(e:MouseEvent):void {
			Dispatcher.call("dashboard");
		}
		private static function userAdminButtonClicked(e:MouseEvent):void {
			Dispatcher.call("useradmin");
		}
		private static function caseCreatorButtonClicked(e:MouseEvent):void {
			Dispatcher.call("casecreator");
		}
		private static function reportButtonClicked(e:MouseEvent):void {
			Dispatcher.call("reports");
		}
		
		
		/**
		 * Updates the buttons whenever we load a new page
		 * 
		 */
		private static function setupButtons():void {
			if(Auth.getInstance().isSysAdmin() || (AppController.currentEraProject != null && Auth.getInstance().hasRoleForYear(Model_ERAUser.MONITOR, AppController.currentEraProject.year))) {
				layout.header.adminToolButtons.visible = true;
				layout.header.adminToolButtons.includeInLayout = true;
				layout.header.adminToolsButton.includeInLayout = true;
				layout.header.adminToolsButton.visible = true;
				if(eraProjectArray == null || eraProjectArray.length == 0) {
					layout.header.eraDropDown.enabled = false;
					layout.header.caseCreatorButton.enabled = false;
					layout.header.userAdminButton.enabled = false;
				}
			} else {
				layout.header.adminToolButtons.visible = false;
				layout.header.adminToolButtons.includeInLayout = false;
				layout.header.adminToolsButton.includeInLayout = false;
				layout.header.adminToolsButton.visible = false;
				layout.notificationPanel.visible = false;
			}
			if(Auth.getInstance().getSessionID() != "") {
				// Only if we have logged in, show the buttons
				
				layout.header.globalButtonGroup.visible = true; 
				layout.header.profileButton.label = Auth.getInstance().getUsername();
				
				// Get the notifications everytime we load a new page
				getNotifications();
				
				layout.header.visible = true;
				layout.header.includeInLayout = true;
				
				// Set the notification timer (if its not already started)
//				notificationTimer.start();
			}
		}
		
		/* ============================ CHANGING READ STATUS =========================== */
		private static function markAllAsReadButtonClicked(e:IDEvent):void {
			if(notificationsArray != null) {
				AppModel.getInstance().markAllNotificationsAsRead(notificationsArray, markedAllAsRead);
			}
		}
		private static function markedAllAsRead(status:Boolean):void {
			if(!status) {
				layout.notificationBar.showError("Failed to mark all as read");
			} else {
				layout.notificationBar.showGood("Marked all as Read");
				layout.header.notificationButton.setStyle('chromeColor', "0x222222");
				layout.header.notificationButton.setStyle('font-weight', "normal");
				layout.header.notificationButton.label = "0";
			}
		}
		
		/**
		 * The user has changed the read status of a notification 
		 * @param e
		 * 
		 */		
		private static function notificationStatusChanged(e:IDEvent):void {
			var notificationID:Number = e.data.notificationID;
			var readStatus:Boolean = e.data.readStatus;

			trace("notifiaction status", readStatus ? 'yes' : 'no');
			AppModel.getInstance().updateNotificationReadStatus(notificationID, readStatus, notificationReadStatusUpdated);
		}
		private static function notificationReadStatusUpdated(status:Boolean):void {
			if(!status) {
				layout.notificationBar.showError("Failed to Changed Read Status");
			} else {
				layout.notificationBar.showGood("Read Status Changed");
			}
		}
		/* ============================ END OF CHANGING READ STATUS =========================== */
		
		private static function updateNotifications(e:TimerEvent):void {
			getNotifications();
		}
		
		/**
		 * Get the notification for a the current user from the database. 
		 * 
		 */		
		public static function getNotifications():void {
			trace("@@@@@@@@@@@@@@@@@ Getting Notifications");
			AppModel.getInstance().getAllNotifications(Model_ERANotification.SHOW_UNREAD, gotNotifications);
		}
		
		/**
		 * Got notifications for a user.
		 * Stores the notifications and updates the notification button to show a notification
		 * count.
		 *  
		 * @param e
		 * 
		 */		
		private static function gotNotifications(status:Boolean, notificationsArray:Array=null):void {
			trace("@@@@@@@@@@@@@@@@@ Got Notifications");
			if(!status) return;
			
			allNotificationsArray = notificationsArray;
			
			// strip out the read ones
			var unreadNotificationCount:Number = 0;
			
			var someArray:Array = new Array();
			for each(var notificationData:Model_ERANotification in notificationsArray) {
				if(notificationData.username != Auth.getInstance().getUsername()) {
					// its not by the current user, so add it (only a problem for the sys-admin)
					someArray.push(notificationData);	
					
					// if we havent read it, update the count
					if(!notificationData.read) unreadNotificationCount++;
				}
			}
			AppController.notificationsArray = someArray.reverse(); 
			
			updateNotificationButtonColour(unreadNotificationCount);
			
			layout.notificationPanel.addNotifications(AppController.notificationsArray);
			
		}
		private static function updateNotificationButtonColour(unreadNotificationCount:Number) {
			// Setup the colour of the button
			layout.header.notificationButton.label = unreadNotificationCount + "";
			if(unreadNotificationCount > 0) {
				layout.header.notificationButton.setStyle('chromeColor', "0x649ccf");
				layout.header.notificationButton.setStyle('font-weight', "bold");
			} else {
				layout.header.notificationButton.setStyle('chromeColor', "0x222222");
				layout.header.notificationButton.setStyle('font-weight', "normal");
			}
		}
		
		/**
		 * Show the notifications for the current user. Called after the notification button was clicked. 
		 * @param e
		 * 
		 */		
		private static function showNotifications():void {
						
			// show the panel
			layout.notificationPanel.showAllUnreadNotifications();
			layout.notificationPanel.showPanel();
			// position it near the notifiaction panel button
			AppController.layout.notificationPanel.x = 	IDGUI.localToLocal(AppController.layout.header.logoNotificationGroup, AppController.layout, new Point(AppController.layout.header.notificationButton.x, 0)).x - AppController.layout.header.notificationButton.width/2;
			AppController.layout.notificationPanel.x -= 28;
			
			/*trace("&&&&&&&", AppController.layout.header.notificationButton.x);
			trace("local", IDGUI.localToLocal(AppController.layout.header.globalButtonGroup, AppController.layout, new Point(AppController.layout.header.notificationButton.x, 0)).x);*/
		}
		
		private static function hideNotifications():void {
			layout.notificationPanel.hidePanel();
//			getNotifications();
		}
		
		private function deleteNotification(e:IDEvent):void {
			trace("Deleting notification", e.data.notificationID);
			var notificationID:Number = e.data.notificationID;
			AppModel.getInstance().deleteNotification(notificationID);
			// remove the notification from the notificationsarray
			var tempArray:Array = new Array();
			for(var i:Number = 0; i < notificationsArray.length; i++) {
				if(notificationsArray[i].base_asset_id != notificationID) {
					tempArray.push(notificationsArray[i]);
				}
			}
			notificationsArray = tempArray;
			layout.header.notificationButton.label = notificationsArray.length + "";
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

		
		
		//When the controller is destroyed/switched
		public function dealloc():void {
			if(layout) {
				layout.content.removeAllElements();
			}
			view = null;
		}
		
		//Protection to ensure controllers take advantage of the init method
		public function init():void {
			var classname:String = getQualifiedClassName(this);
			throw new Error(classname+" must implement the init() method");
		}
	}
}