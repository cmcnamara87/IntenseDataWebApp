package Controller.Utilities {
	import Controller.*;
	import Controller.ERA.Admin.CaseCreatorController;
	import Controller.ERA.Admin.DashboardController;
	import Controller.ERA.Admin.ERASetupController;
	import Controller.ERA.Admin.UserAdminController;
	import Controller.ERA.AppSauce;
	import Controller.ERA.CaseController;
	import Controller.ERA.FileController;
	import Controller.ERA.RecoverController;
	import Controller.ERA.SplashScreen;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import mx.controls.Alert;
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	public class Router extends EventDispatcher {
		
		private static var _instance:Router;
		private var _bm:IBrowserManager;
		// The first route that is loaded after login (if no previous)
		public static var defaultURL:String = "splash";
		// The title for the default Route
		private static var defaultTitle:String = "Intense Data - Browse";
		
		// Stores all the previous routes called
		private static var historyArray:Array = new Array();
		
		
		// The valid routes/controllers for the application
		private static var routes:Array = new Array(
			{
				url: 'splash',
				title: 'nQuisitor',
				classname: SplashScreen
			},
			{
				url:'browse',
				title:'Browse',
				classname:BrowserController
			},
			{
				url: 'recover',
				title: 'Recover Password',
				classname: RecoverController
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
				url: 'applesauce',
				title: 'Profile View',
				classname: AppSauce
			},
			{
				url: 'dashboard',
				title: 'Admin Dashboard',
				classname: DashboardController
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
				title: 'Case Manager',
				classname: CaseController
			},
			{
				url: 'file',
				title: 'File Viewer',
				classname: FileController
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
//				trace("looking at route", routes[i].url, url);
				if(routes[i].url == url) {
					newController = routes[i].classname;
//					trace("MATCH FOUND", newController);
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
					newTitle = Recensio_Flex_Beta.NAME + " :: "+routes[i].title;
				}
			}
			_bm.setTitle(newTitle);
			
			addHistory(newURL);
		}
		
		/**
		 * Get the previous url in the history chain 
		 * @return The previous url in the history chain
		 * 
		 */		
		public function getPreviousURL():String {
			trace("getting history url");
			historyArray.pop();
			return historyArray.pop();
		}
		
		public function showPreviousURL():String {
			return historyArray[historyArray.length - 2];
		}
		
		/**
		 * Adds a url to the history chain 
		 * @param url
		 * 
		 */		
		private function addHistory(url:String):void {
			trace("saving history url", url);
			historyArray.push(url);
		}
		
		// Called when the URL is manually changed by the user
		private function urlChanged(e:BrowserChangeEvent):void {
			trace("***********************THE URL HAS CHANGED!!!!!!***************************");
			this.dispatchEvent(new IDEvent(IDEvent.URL_CHANGED));
		}
	}
}

// Singleton Enforcer Class
class SingletonEnforcer {
	
}