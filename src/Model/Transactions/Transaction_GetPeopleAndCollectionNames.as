package Model.Transactions
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;

	public class Transaction_GetPeopleAndCollectionNames
	{
		private var connection:Connection;
		private var collectionList:Array = new Array();
		private var returnArray:Array = new Array();
		private var callback:Function;
		
		public function Transaction_GetPeopleAndCollectionNames(connection:Connection)
		{
			this.connection = connection;
		}
		
		public function getPeopleAndCollectionNames(peopleCollectionList:XMLList, callback:Function):void {
			this.callback = callback;
			
			for each(var share:XML in peopleCollectionList) {
				var assetID:Number = share.via_asset;
				collectionList.push(assetID);
			}
			collectionList = collectionList.filter(function(e:*, i:int, a:Array):Boolean {
				// Remove duplicates
				return a.indexOf(e) == i;
			});		
				
			
			for(var i:Number = 0; i < collectionList.length; i++) {
				var args:Object = new Object();	
				trace("Transaction_GetPeopleAndCollectionNames - Getting collection name", collectionList[i]);
				args.id = collectionList[i];
				
				var baseXML:XML = connection.packageRequest('asset.get', args, true);
				
				connection.sendRequest(baseXML, function(e:Event):void {
					if(AppModel.getInstance().callSuccessful(e)) {
						var dataXML:XML = XML(e.target.data);
						var assetID:Number = XML(e.target.data).reply.result.asset.@id;
						var collectionName:String = XML(e.target.data).reply.result.asset.meta.r_resource.title;
						trace("Collection is", collectionName, assetID);
						
						// users in collection array
						var userArray:Array = new Array();
						for each(var share:XML in peopleCollectionList) {
							trace("Checking user", share.username);
							if(share.via_asset == assetID) {
								trace("Adding user", share.username);
								if(share.access_level == SharingPanel.READWRITE) {
									userArray.push(share.username + " - Full Access");
								} else {
									userArray.push(share.username + " - View Access Only");
								}
							}
						}
						
						var collectionAndPeople:Array = new Array(assetID, collectionName, userArray);
						returnArray.push(collectionAndPeople);
						
						if(returnArray.length == collectionList.length) {
							callback(returnArray);
						}
					}
				});
			}
		}
	}
}