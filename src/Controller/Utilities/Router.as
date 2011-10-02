package Controller.Utilities {
	import Controller.*;
	import Controller.ERA.Admin.CaseCreatorController;
	import Controller.ERA.Admin.DashboardController;
	import Controller.ERA.Admin.ERAEditController;
	import Controller.ERA.Admin.ERASetupController;
	import Controller.ERA.Admin.UserAdminController;
	import Controller.ERA.CaseController;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	public class Router extends EventDispatcher {
		
		private static var _instance:Router;
		private var _bm:IBrowserManager;
		// The first route that is loaded after login (if no previous)
		public static var defaultURL:String = "browse";
		// The title for the default Route
		private static var defaultTitle:String = "Intense Data - Browse";
		
		// The valid routes/controllers for the application
		private static var routes:Array = new Array(
			{
				url:'browse',
				title:'Browse',
				classname:BrowserController
			},
			{
				url:'login',
				title:'Login',
				classname:LoginController
			},
			{
				url:'view',
				title:'View Asset',
				classname:MediaController
			},
			{
				url:'newasset',
				title:'New Media File',
				classname:NewAssetController
			},
			{
				url: 'profile',
				title: 'Edit Profile',
				classname:ProfileController
			},
			{
				url: 'dashboard',
				title: 'Admin Dashboard',
				classname: DashboardController
			},
			{
				url: 'era',
				title: 'ERA Details',
				classname: ERAEditController
			},
			{
				url: 'erasetup',
				title: 'Era Setup',
				classname: ERASetupController
			},
			{
				url: 'useradmin',
				title: 'User Admin',
				classname: UserAdminController
			},
			{
				url: 'casecreator',
				title: 'Case Creator',
				classname: CaseCreatorController
			},
			{
				url: 'case',
				title: 'Case',
				classname: CaseController
			}
		);
		
		// Singleton protection
		public function Router(enforcer:SingletonEnforcer) {
			super();
			if(!enforcer) {
				throw new Error("Router must be called from getInstance()");
			}
		}
		
		// Singleton instance
		public static function getInstance():Router {
			if(!_instance) {
				_instance = new Router(new SingletonEnforcer);
			}
			return _instance;
		}
		
		// Starts the URL Manager
		public function start():void {
			_bm = BrowserManager.getInstance();
			_bm.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, urlChanged);
			_bm.init();
		}
		
		// Gets the controller appropriate for the URL
		public function getController(url:String):Class {
			var newController:Class = null;
			for(var i:Number=0; i<routes.length; i++) {
				if(routes[i].url == url) {
					newController = routes[i].classname;
				}
			}
			return newController;
		}
		
		// Get the URL, taking into account 404's
		public function getURL():String {
			var urlArray:Array = _bm.fragment.split("/");
			var theURL:String = urlArray[0];
			if(theURL == "") {
				theURL = defaultURL;
			}
			return theURL;
		}
		
		public function getURLFragment():String {
			return _bm.fragment;
		}
		
		
		// Get the Arguments in the URL
		public function getArgs():Array {
			var urlArray:Array = _bm.fragment.split("/");
			urlArray.splice(0,1);
			return urlArray;
		}
		
		// Sets the URL and the title appropriately
		public function setURL(newURL:String):void {
			var newTitle:String = "BAD BAD BAD";
			_bm.setFragment(newURL);
			for(var i:Number=0; i<routes.length; i++) {
				if(routes[i].url == getURL()) {
					newTitle = "Intense Data :: "+routes[i].title;
				}
			}
			_bm.setTitle(newTitle);
		}
		
		// Called when the URL is manually changed by the user
		private function urlChanged(e:BrowserChangeEvent):void {
			this.dispatchEvent(new IDEvent(IDEvent.URL_CHANGED));
		}
	}
}

// Singleton Enforcer Class
class SingletonEnforcer {
	
}