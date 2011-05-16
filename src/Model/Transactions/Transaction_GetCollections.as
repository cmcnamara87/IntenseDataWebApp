package Model.Transactions {
	
	import Controller.Utilities.Auth;
	
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_GetCollections {
		
		private var _connection:Connection;
		private var _callback:Function;
		private var _collectionsXML:XML;
		
		public function Transaction_GetCollections(connection:Connection,callback:Function=null) {
			_connection = connection;
			_callback = callback;
			getCollections();
		}
		
		public function getCollections():void {
			var args:Object = new Object();
			args.where = "namespace = recensio and r_base/active=true and class>='recensio:base/resource/collection' and xpath(mf-revision-history/user/name)='"+Auth.getInstance().getUsername()+"'";
			args.action = "get-meta";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),collectionsLoaded)) {
				//All good
			} else {
				Alert.show("Could not get collections");
			}
		}
		
		public function collectionsLoaded(e:Event):void {
			_collectionsXML = XML(e.target.data);
			var assetsXML:XMLList = _collectionsXML.reply.result.asset;
			for each(var assetXML:XML in assetsXML) {
				getCollectionChildren(assetXML.@id);
			}
			trace("COLLECTIONS DONE");
		}
		
		public function getCollectionChildren(collectionID:Number):void {
			var args:Object = new Object();
			args.where = "namespace=recensio and class>='recensio:base/resource/media' and related to (id="+collectionID+")";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),collectionLoaded)) {
				//All good
			} else {
				Alert.show("Could not get collections");
			}
		}
		
		private function collectionLoaded(e:Event):void {
			trace(e.target.data);
		}
	}
}