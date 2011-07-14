package Model.Utilities {
	import Controller.Dispatcher;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	public class Connection extends Object {
		
		//Mediaflux connection details
		private var _serverAddress:String;
		private var _serverPort:Number;
		private var _mfServiceAddress:String = "";
		private var _mfContentAddress:String = "";
		private var _mfNamespace:String = "";
		
		private static var _req:String = "";
		
		private static var connectionErrorShown:Boolean = false;
		
		// Initialise the collection
		public function Connection(serverAddress:String,serverPort:Number) {
			this._serverAddress = serverAddress;
			this._serverPort = serverPort;
			this.setServerPaths();
			super();
		}
		
		// Packages up a request based on the mediaflux XML format
		public function packageRequest(service:String,args:Object,useSession:Boolean = true,extraXML:XML=null):XML {
			var reqXML:XML = 
				<request>
					<service name="">
						<args>
						</args>
					</service>		    
				</request>;
			reqXML.service.@name = service;
			reqXML.service.@session = Auth.getInstance().getSessionID();
			for (var arg:* in args) {
				reqXML.service.args[arg] = args[arg];
			}
			if(extraXML) {
				reqXML.service.args.appendChild(extraXML);
			}
			_req = reqXML.toString();
			return reqXML;
		}
		
		// Sends a XML request off to mediaflux and catches errors in the process
		public function sendRequest(req:XML, handler:Function):Object {
			var result:Object = new Object();
			var request:URLRequest = new URLRequest(_mfServiceAddress);
			request.contentType = "text/xml";
			XML.prettyPrinting = false; 
			request.data = req.toXMLString();
			request.method = URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			if(handler != null) {
				loader.addEventListener(Event.COMPLETE, handler);
			}
			try {
				loader.addEventListener(IOErrorEvent.IO_ERROR,loadError);
				loader.load(request);
				result.success = true;			    
			} catch (error:ArgumentError) {
				trace("An ArgumentError has occurred.");
				result.success = false;
				result.message = "Argument Error";
			} catch (error:SecurityError) {
				trace("A SecurityError has occurred.");
				result.success = false;
				result.message = "Security Error";
			}
			return result;
		} 

		// Sends a XML request (*with* data attached) off to mediaflux and catches errors in the process
		public function uploadFile(file:FileReference, req:XML, handler:Function):Object {
			var result:Object = new Object();
			req.service.attachment.size = file.size;
			req.service.attachment.type = AssetLookup.getMimeFromFileType(file.name);
			req.service.attachment.ctype = AssetLookup.getMimeFromFileType(file.name);
			req.service.type = AssetLookup.getMimeFromFileType(file.name);
			req.service.ctype = AssetLookup.getMimeFromFileType(file.name);
			req.service.args.type = AssetLookup.getMimeFromFileType(file.name);
			req.service.args.ctype = AssetLookup.getMimeFromFileType(file.name);
			var params:URLVariables = new URLVariables();
			params.request = req;
			var request:URLRequest = new URLRequest(_mfServiceAddress);
			request.method = URLRequestMethod.POST;
			request.data = params;
			try {
				trace("$$$$$"+req);
				file.addEventListener(IOErrorEvent.IO_ERROR,loadError);
				file.upload(request);
				result.success = true;
			} catch (error:ArgumentError) {
				trace("An ArgumentError has occurred.");
				result.success = false;
				result.message = "Argument Error";
			} catch (error:SecurityError) {
				trace("A SecurityError has occurred.");
				result.success = false;
				result.message = "Security Error";
			}
			return result;
		} 
		
		
		// If a load error occurs
		private function loadError(e:*):void {
			if(!connectionErrorShown) {
				// Only show the connection error message, if one already isnt showing
				connectionErrorShown = true;
				
				var myAlert:Alert = Alert.show("Please check your internet settings", "Connection Error", Alert.OK, null, function(e:CloseEvent):void {
					if(e.detail == Alert.OK) {
						// They clicked okay, now we can show it again if needback
						connectionErrorShown = false;
						Dispatcher.dumpOut();
					}
				}, null, Alert.OK);	
			}
					
		}
		
		// Sets the server paths to mediaflux and its content
		public function setServerPaths():void {
			_mfServiceAddress = "http://" + _serverAddress + ":" + _serverPort + "/__mflux_svc__";
			_mfContentAddress = "http://" + _serverAddress + ":" + _serverPort + "/mflux/content.mfjp";
			_mfNamespace = "recensio";
		}
	}
}