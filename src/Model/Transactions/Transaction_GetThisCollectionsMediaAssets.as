package Model.Transactions
{
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_GetThisCollectionsMediaAssets
	{
		private var collectionID:Number; // The ID of the collection for which we want to get all the assets for
		private var callback:Function;	// The function to callback when we are finished getting the assets
		private var connection:Connection; // The connection to use for the call
		
		public function Transaction_GetThisCollectionsMediaAssets(collectionID:Number, callback:Function, connection:Connection)
		{
			this.collectionID = collectionID;
			this.callback = callback;
			this.connection = connection;
			
			getThisCollectionsMediaAssets();
		}
		
		/**
		 * Gets all the assets for this collection (media and annotation)
		 * Can filter out annotation with @see parseResultsChildren()	 
		 */		
		public function getThisCollectionsMediaAssets():void {
			var args:Object = new Object();
			
			// Get out all the media assets that are a child of this collection
			args.where = "namespace = recensio and r_base/active=true and class >= 'recensio:base/resource/media'" +
				" and related to{is_child} (id =  " + collectionID + ")";
			
			// Get out the meta data for these assets
			args.action = "get-meta";	
			
			// But, dont just get the asset data, get the data for all of its children
			// That is, all the comments/annotations on all the media assets
			args['related-type'] = "has_child";			
			args['get-related-meta'] = true;
			
			//"id = " + collectionID + " and namespace = recensio and r_base/active=true";
			if(connection.sendRequest(connection.packageRequest('asset.query',args,true), gotCollectionsMediaAssets)) {
				//All good
			} else {
				Alert.show("Could not get assets");
			}
		}
		
		private function gotCollectionsMediaAssets(e:Event):void {
			// Call the callback function, and give it the collection id, and the response we got
			// @see collectionMediaLoaded
			callback(collectionID, e);
		}
		
	}
}