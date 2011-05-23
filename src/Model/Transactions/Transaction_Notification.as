package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	/**
	 * Creates a new Notification and saves it in the Mediaflux database. 
	 * @author cmcnamara87
	 * 
	 */	
	public class Transaction_Notification
	{
		private var mediaID:Number;
		private var username:String;
		private var msg:String;
		private var connection:Connection;
		private var assetID:Number;
		private var userList:Array; // The list of users that has access to mediaID
		private var notificationID:Number; //
		/**
		 *  
		 * @param mediaID 	The ID of the media that was affected. e.g. If someone comments on an image, this is the image's ID
		 * @param msg		A msg that describes the change (e.g. Added a comment)
		 * @param connection The connection to use when making the notificoatn
		 * @param assetID	(opt) The ID of the asset that as added/changed (e.g. the ID of the comment)
		 * 
		 */		
		public function Transaction_Notification(mediaID:Number, msg:String, connection:Connection, assetID:Number = 0)
		{
			this.mediaID = mediaID;
			this.username = Auth.getInstance().getUsername();
			this.msg = msg;
			this.connection = connection;
			this.assetID = assetID;
			
			createNotification();
		}
		
		private function createNotification():void {
			var args:Object = new Object();
			
			// Set the assets namespace as 'recensio'
			args.namespace = "recensio";
			var baseXML:XML = connection.packageRequest('asset.create', args, true);
			
			// Set the namespace for the asset (i think this is how it silos assets)
			baseXML.service.args.namespace = "recensio";
			
			// Set the notifications relationship to other assets
			baseXML.service.args.related.to = mediaID;
			baseXML.service.args.related.to.@relationship = "NOTIFICATION_ON";
			
			// if we have the id of the asset, put that in as well, (things like a comments ID, but wont 
			// be there for things like sharing)
			if(assetID != 0) {
				// We have to write it this way, since if you do [0] [1] fucking as3 puts in these xmlns attributes
				// that break mediaflux.
				baseXML.service.args.related.appendChild(XML("<to relationship='NOTIFICATION_OF'>"+assetID+"</to>"));
			}
			
			baseXML.service.args.meta.id_notification.username = Auth.getInstance().getUsername();
			if(msg != "") {
				baseXML.service.args.meta.id_notification.message = msg;
			}
			baseXML.service.args.meta.id_notification.controller = "view";
			var now:Date = new Date();
			
			baseXML.service.args.meta.id_notification.date = "now";
			
			if(connection.sendRequest(baseXML, notificationCreated)) {
				//All good
			} else {
				Alert.show("Could not save comment");
			}
		}
		
		private function notificationCreated(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			// Check that the notification was created successfully
			if(dataXML.reply.@type == "result") {
				trace("Notification created");
				// Get out the new notifications ID
				this.notificationID = dataXML.reply.result.id;
				
				getUsersToNotify();
				setNotificationClassification();
			} else {
				trace("Failed to create notification", e.target.data);
			}
		}
		/**
		 * Called when comment has finished saving in database. Converts the data returned
		 * to a Model_annotation. Calls @see BrowserController.commentSaved
		 * @param e
		 * 
		 */		
		private function setNotificationClassification():void {

				// Add the 'Notification' Classification to the notification asset
				var args:Object = new Object();
				var baseXML:XML = connection.packageRequest('asset.class.add',args,true);
				baseXML.service.args.scheme = "recensio";
				baseXML.service.args["class"] = "base/notification";
				baseXML.service.args.id = notificationID;
				// Send the request
				connection.sendRequest(baseXML, null);
		}

		private function getUsersToNotify():void {
			var args:Object = new Object();
			args.id = mediaID;
			connection.sendRequest(
				connection.packageRequest('asset.acl.describe', args, true), 
				setUsersToNotify
			);
		}
		
		private function setUsersToNotify(e:Event):void {
			trace("users to notify", e.target.data);

			// Get out the ACL from the media object in the reply
			var acls:XMLList = XML(e.target.data).reply.result.asset.acl;

			// Set the same ACLs for the notification
			var baseXML:XML = connection.packageRequest('asset.acl.grant', new Object(), true);
			baseXML.service.args.id = notificationID;
			
			for each(var acl:XML in acls) {
				if("system:" + Auth.getInstance().getUsername() != acl.actor) {
					baseXML.service.args.appendChild(XML('<acl><actor type="user">' + acl.actor + '</actor><access>'+ acl.content +'</access></acl>'));
				}
			}

			trace("set users request", baseXML);
			connection.sendRequest(baseXML, function(e:Event):void {
				trace("access granted to notification", e.target.data);
				
			});
		}		
	}
}