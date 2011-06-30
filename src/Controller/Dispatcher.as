package Controller {
	import Controller.Utilities.Auth;
	import Controller.Utilities.Router;
	
	import Lib.flashfuck.debugger.FlexFPSMonitor;
	
	import Model.AppModel;
	
	import View.Layout;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.BrowserChangeEvent;
	import mx.events.ResizeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	
	import spark.components.Group;

	public class Dispatcher extends EventDispatcher {
		
		private static var currentController:AppController;
		private static var layout:Layout;
		private static var stage:Recensio_Flex_Beta;
		private static var useFPSMonitor:Boolean = false;
		public static var _serverAddress:String = "127.0.0.1";
		public static var _serverPort:Number = 8082;
		private static var _autoLogin:Boolean = false;
		
		// Setup the URL controller listener
		public static function start(stage:Recensio_Flex_Beta):void {
			connectToServer();
			Dispatcher.stage = stage;
			Router.getInstance().addEventListener(IDEvent.URL_CHANGED,URLChanged);
			Router.getInstance().start();
			setupLayout();
			addMonitor();
		}
		
		// Sets the server details for the mediaflux connection
		public static function setServerDetails(serverAddress:String,serverPort:Number):void {
			_serverAddress = serverAddress;
			_serverPort = serverPort;
		}
		
		// Sets whether to use debugging functionality
		public static function debug(FPSMonitor:Boolean,autoLogin:Boolean):void {
			useFPSMonitor = FPSMonitor;
			_autoLogin = autoLogin;
		}
		
		// Return the server information
		public static function getServerDetails():String {
			return _serverAddress+":"+_serverPort;
		}
		
		// Connect to mediaflux
		private static function connectToServer():void {
			AppModel.getInstance().setServerConfig(_serverAddress,_serverPort);
		}
		
		// Adds the FPS Monitor in the top left hand corner for debugging purposes
		private static function addMonitor():void {
			if(useFPSMonitor) {
				Dispatcher.stage.addElement(new FlexFPSMonitor());
			}
		}
		
		// Sets up the layout of the view
		private static function setupLayout():void {
			layout = new Layout();
			AppController.layout = layout; 
			layout.addEventListener(Event.ADDED_TO_STAGE,init);
			Dispatcher.stage.addElement(layout);
		}
		
		// Called on first load
		private static function init(e:Event):void {
			URLChanged(new IDEvent(IDEvent.URL_CHANGED));
		}
		
		// Called on logout
		public static function logout():void {
			Auth.getInstance().logout();
			call(Router.getInstance().getURL());
		}
		
		// Get the URL Arguments
		public static function getArgs():Array {
			return Router.getInstance().getArgs();
		}
		
		// Called when the user manually switches URLs
		private static function URLChanged(e:IDEvent):void {
			Dispatcher.call(Router.getInstance().getURL());
		}
		
		// Loads a new controller
		public static function call(url:String):void {
			if(!Auth.getInstance().hasSession()) {
				Auth.getInstance().setRedirectURL(url);
				url = "login";
			}
			Router.getInstance().setURL(url);
			url = Router.getInstance().getURL();
			loadController(Router.getInstance().getController(url));
			forceRedraw();
		}
		
		//Called when Recensio_UI_Component's are not getting the correct width/height on draw()
		public static function forceRedraw():void {
			setTimeout(redraw,500);
		}
		
		//Sends a redraw event to the stage
		private static function redraw():void {
			Dispatcher.stage.dispatchEvent( new Event( Event.RESIZE ));
		}
		
		// Gets rid of the old controller and inits the new controller
		private static function loadController(newController:Class):void {
			if(currentController) {
				currentController.dealloc();
			}
			currentController = new newController();
			currentController.init();
		}
		
		// Returns whether the system should automatically login
		public static function getAuthOverride():Boolean {
			return _autoLogin;
		}
	}
}