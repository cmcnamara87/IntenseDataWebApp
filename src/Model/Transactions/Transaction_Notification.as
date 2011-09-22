package Model.Transactions
{
	import Controller.BrowserController;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Notification;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
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
		private var other_username:String;
		private var notificationType:String;
		private var connection:Connection;
		private var assetID:Number;
		private var userList:Array; // The list of users that has access to mediaID
		private var notificationID:Number; //
		
		/**
		 *  
		 * @param mediaID 		The ID of the media that was affected. e.g. If someone comments on an image, this is the image's ID
		 * @param msg			A msg that describes the change (e.g. Added a comment)
		 * @param connection 	The connection to use when making the notificoatn
		 * @param assetID		(opt) The ID of the asset that as added/changed (e.g. the ID of the comment)
		 * 
		 */		
		public function Transaction_Notification(connection:Connection) {
			this.connection = connection;	
			this.username = Auth.getInstance().getUsername();
		}
		
		/**
		 * Creates a notification, and gives anyone who has access to the aset, access to the notification 
		 * @param mediaID		The Media the notifiation is on (e.g. on an image)
		 * @param type			The type of the notification (e.g. a comment)
		 * @param assetID		The media the notification is of (e.g. the comment)
		 * 
		 */
		public function sendNotification(mediaID:Number, type:String, assetID:Number = 0):void {
			this.mediaID = mediaID;
			this.username = Auth.getInstance().getUsername();
			this.assetID = assetID;
			
			// We first need to determine if we have an ambiguous type of notification
			if(type == Model_Notification.COMMENT) {
				// Comment can be either on a collection or an asset
				// We need to determien the type of mediaID to know what the comment is on
				var args:Object = new Object();
				args.id = mediaID;
				connection.sendRequest(connection.packageRequest('asset.class.list', args, true), function(e:Event):void {
					
					var classification:String = XML(e.target.data).reply.result.asset['class'];
					
					switch(classification) {
						case 'base/resource/media':
							trace("Comment on media");
							notificationType = Model_Notification.COMMENT_ON_MEDIA;
							break;
						case 'base/resource/collection':
							trace("Comment on " + BrowserController.PORTAL);
							notificationType = Model_Notification.COMMENT_ON_COLLECTION;
							break;
						default:
							trace("oh crap");
					}
					createNotification();
				});
			} else {
				this.notificationType = type;
				createNotification();
			}
		}
		
//		public function sendSharingNotification(mediaID:Number, type:String, other_username:String):void {
//			this.mediaID = mediaID;
//			this.other_username = other_username;
//			this.assetID = assetID;
//			
//			// We first need to determine if we have an ambiguous type of notification
//			if(notificationType1 == Model_Notification.COMMENT) {
//				// Comment can be either on a collection or an asset
//				// We need to determien the type of mediaID to know what the comment is on
//				var args:Object = new Object();
//				args.id = mediaID;
//				connection.sendRequest(connection.packageRequest('asset.class.list', args, true), function(e:Event):void {
//					
//					var classification:String = XML(e.target.data).reply.result.asset['class'];
//					
//					switch(classification) {
//						case 'base/resource/media':
//							trace("Comment on media");
//							if(notificationType1 == Model_Notification.COMMENT) {
//								notificationType = Model_Notification.COMMENT_ON_MEDIA;
//							} else if (notificationType1 == Model_Notification.SHARING) {
//								notificationType = Model_Notification.MEDIA_SHARED;
//							}
//							break;
//						case 'base/resource/collection':
//							trace("Comment on collection");
//							if(notificationType1 == Model_Notification.COMMENT) {
//								notificationType = Model_Notification.COMMENT_ON_COLLECTION;
//							} else if (notificationType1 == Model_Notification.SHARING) {
//								notificationType = Model_Notification.COLLECTION_SHARED;
//							}
//							break;
//						default:
//							trace("oh crap");
//					}
//					createNotification();
//				});
//			} else {
//				this.notificationType = notificationType1
//				createNotification();
//			}
//		}
		/**
		 * Creates the Notification object in the database. 
		 * 
		 */		
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
			
			// The creator of the notification
			baseXML.service.args.meta.id_notification.username = Auth.getInstance().getUsername();
			
			// The type of then notification (see Model_Notification)
			baseXML.service.args.meta.id_notification.type = notificationType;

			baseXML.service.args.meta.id_notification.date = "now";
			
			if(connection.sendRequest(baseXML, notificationCreated)) {
				//All good
			} else {
				Alert.show("Could not save comment");
			}
		}
		
		/**
		 * The notification object was created. Now set ACLs on it (that is, who we want to notify)
		 * And set its classification to be a notification.
		 * @param e
		 * 
		 */		
		private function notificationCreated(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			// Check that the notification was created successfully
			if(dataXML.reply.@type == "result") {
				trace("Notification created");
				// Get out the new notifications ID
				this.notificationID = dataXML.reply.result.id;
				
				// Make the people who have access to this notification
				// the same people who have access to the asset (except the creator of the notification, they dont
				// need to be notified).
				AppModel.getInstance().copyAccess(mediaID, notificationID, true);
				
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
		
		
		
		public function deleteNotificationForUser(notificationID:Number):void {
			this.notificationID = notificationID;
			// Get out how many people have access
			var args:Object = new Object();
			args.id = this.notificationID;
			connection.sendRequest(
				connection.packageRequest('asset.acl.describe', args, true), 
				gotUserList
			);
		}
		
		private function gotUserList(e:Event):void {
			trace("get users with access", e.target.data);
			
			// Get out the ACL from the media object in the reply
			var acls:XMLList = XML(e.target.data).reply.result.asset.acl;
			
			if(acls.length() == 1) {
				// There is only one user with access to this file, it must be the current user
				// otherwise how could they see it
				// <= just as a precaution
				trace("Only one user has access to file", acls[0].actor, "current user is", Auth.getInstance().getUsername());
				AppModel.getInstance().assetDestroy(notificationID, deleteComplete);
			} else if (acls.length() == 0) {
				// In case something bad happens
				trace("No user has access to this file, destroying it");
				AppModel.getInstance().assetDestroy(notificationID, deleteComplete);
			} else {
				// Other people are still using this file, only
				// remove this current users access to it, so it remains unchanged for others
				AppModel.getInstance().changeAccess(notificationID, Auth.getInstance().getUsername(),
					"system", SharingPanel.NOACCESS, false, deleteComplete);
			}
		}
		
		private function deleteComplete(e:Event):void {
			trace("delete compelte", e.target.data);
		}
		
		
	}
}