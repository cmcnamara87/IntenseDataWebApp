package Model.Transactions
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_CopyAccess
	{
		private var copyFromID:Number;
		private var copyToID:Number;
		private var connection:Connection;
		
		public function Transaction_CopyAccess(copyFromID:Number, copyToID:Number, connection:Connection)
		{
			trace("Copy ACLS from", copyFromID, "to", copyToID);
			this.copyFromID = copyFromID;
			this.copyToID = copyToID;
			this.connection = connection;
			
			getFromACLs();
		}

		private function getFromACLs():void {
			var args:Object = new Object();
			args.id = copyFromID;
			connection.sendRequest(
				connection.packageRequest('asset.acl.describe', args, true), 
				setToACLs
			);
		}
		
		private function setToACLs(e:Event):void {
			trace("Transaction_CopyAccess:setToACLs - users to copy to", e.target.data);
			
			// Get out the ACL from the media object in the reply
			var acls:XMLList = XML(e.target.data).reply.result.asset.acl;
			
			// Set the same ACLs for the notification
			var baseXML:XML = connection.packageRequest('asset.acl.grant', new Object(), true);
			baseXML.service.args.id = copyToID;
			
			for each(var acl:XML in acls) {
				baseXML.service.args.appendChild(XML('<acl><actor type="user">' + acl.actor + '</actor><access>'+ acl.content +'</access></acl>'));
			}
			
			trace("set users request", baseXML);
			connection.sendRequest(baseXML, function(e:Event):void {
				trace("access granted to copyfromid", e.target.data);
				
			});
		}		
		
	}
}