package Model {
	
	import Controller.AppController;
	import Controller.Dispatcher;
	import Controller.Utilities.Auth;
	
	import Model.Transactions.Access.Transaction_ChangeAccess;
	import Model.Transactions.Access.Transaction_CopyAccess;
	import Model.Transactions.Access.Transaction_CopyCollectionAccess;
	import Model.Transactions.ERAProject.Reports.Transaction_GetCasesInExhibition;
	import Model.Transactions.ERAProject.Reports.Transaction_GetCasesNotCollected;
	import Model.Transactions.ERAProject.Reports.Transaction_GetCasesWithEvidenceUnderReview;
	import Model.Transactions.ERAProject.Reports.Transaction_GetCasesWithoutEvidence;
	import Model.Transactions.ERAProject.Reports.Transaction_GetCheckedInOutFilesPerCase;
	import Model.Transactions.ERAProject.Reports.Transaction_GetResearcherInvolvement;
	import Model.Transactions.ERAProject.Reports.Transaction_GetResearchersInSchools;
	import Model.Transactions.ERAProject.Transaction_AddRoleToUser;
	import Model.Transactions.ERAProject.Transaction_ChangeEmailOptions;
	import Model.Transactions.ERAProject.Transaction_ChangeEmailOptionsUserArray;
	import Model.Transactions.ERAProject.Transaction_ChangeFileCount;
	import Model.Transactions.ERAProject.Transaction_CreateConversation;
	import Model.Transactions.ERAProject.Transaction_CreateERACase;
	import Model.Transactions.ERAProject.Transaction_CreateERALogItem;
	import Model.Transactions.ERAProject.Transaction_CreateERANotification;
	import Model.Transactions.ERAProject.Transaction_CreateERAProject;
	import Model.Transactions.ERAProject.Transaction_CreateERAUser;
	import Model.Transactions.ERAProject.Transaction_CreateF4V;
	import Model.Transactions.ERAProject.Transaction_CreateRoom;
	import Model.Transactions.ERAProject.Transaction_DeleteERACase;
	import Model.Transactions.ERAProject.Transaction_DeleteERALogItem;
	import Model.Transactions.ERAProject.Transaction_DeleteERAProject;
	import Model.Transactions.ERAProject.Transaction_DeleteERAUser;
	import Model.Transactions.ERAProject.Transaction_DeleteRelatedNotifications;
	import Model.Transactions.ERAProject.Transaction_DownloadExhibitionFiles;
	import Model.Transactions.ERAProject.Transaction_ERAChangeUserPassword;
	import Model.Transactions.ERAProject.Transaction_GetAllCases;
	import Model.Transactions.ERAProject.Transaction_GetAllConversation;
	import Model.Transactions.ERAProject.Transaction_GetAllFilesInRoom;
	import Model.Transactions.ERAProject.Transaction_GetAllLogItems;
	import Model.Transactions.ERAProject.Transaction_GetAllNotifications;
	import Model.Transactions.ERAProject.Transaction_GetAllRooms;
	import Model.Transactions.ERAProject.Transaction_GetAllUsers;
	import Model.Transactions.ERAProject.Transaction_GetAudioSegment;
	import Model.Transactions.ERAProject.Transaction_GetERAProjects;
	import Model.Transactions.ERAProject.Transaction_GetERAUserRoles;
	import Model.Transactions.ERAProject.Transaction_GetFile;
	import Model.Transactions.ERAProject.Transaction_GetUser;
	import Model.Transactions.ERAProject.Transaction_GetUsersWithRole;
	import Model.Transactions.ERAProject.Transaction_GetVideoSegment;
	import Model.Transactions.ERAProject.Transaction_MoveAllFiles;
	import Model.Transactions.ERAProject.Transaction_MoveFile;
	import Model.Transactions.ERAProject.Transaction_RecoverPassword;
	import Model.Transactions.ERAProject.Transaction_RemoveRoleFromUser;
	import Model.Transactions.ERAProject.Transaction_RemoveUserFromCase;
	import Model.Transactions.ERAProject.Transaction_SendMailFromNotification;
	import Model.Transactions.ERAProject.Transaction_UpdateCheckoutStatus;
	import Model.Transactions.ERAProject.Transaction_UpdateERACase;
	import Model.Transactions.ERAProject.Transaction_UpdateERAProject;
	import Model.Transactions.ERAProject.Transaction_UpdateFileLockOutStatus;
	import Model.Transactions.ERAProject.Transaction_UpdateFileTemperature;
	import Model.Transactions.ERAProject.Transaction_UpdateLogItemBooleanValue;
	import Model.Transactions.ERAProject.Transaction_UpdateNotificationReadStatus;
	import Model.Transactions.ERAProject.Transaction_UploadERAFile;
	import Model.Transactions.ERAProject.Transaction_UploadFileVersion;
	import Model.Transactions.Share.Transaction_SetUserAssetShare;
	import Model.Transactions.Transaction_ChangePassword;
	import Model.Transactions.Transaction_CloneMedia;
	import Model.Transactions.Transaction_CreateCollection;
	import Model.Transactions.Transaction_CreateUser;
	import Model.Transactions.Transaction_DeleteMediaFromUser;
	import Model.Transactions.Transaction_DeleteUserFromSystem;
	import Model.Transactions.Transaction_GetAccess;
	import Model.Transactions.Transaction_GetCollections;
	import Model.Transactions.Transaction_GetPeopleAndCollectionNames;
	import Model.Transactions.Transaction_GetThisCollectionsMediaAssets;
	import Model.Transactions.Transaction_Notification;
	import Model.Transactions.Transaction_SaveCollection;
	import Model.Transactions.Transaction_SaveNewComment;
	import Model.Transactions.Transaction_SetAccess;
	import Model.Transactions.Transaction_SuspendUser;
	import Model.Transactions.Transaction_UnsuspendUser;
	import Model.Utilities.Connection;
	
	import View.ERA.components.ERARole;
	import View.ERA.components.EvidenceItem;
	import View.Element.Comment;
	import View.components.Panels.Comments.NewComment;
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.FileReference;
	import flash.net.URLVariables;
	import flash.utils.setInterval;
	
	import mx.charts.AreaChart;
	import mx.controls.Alert;
	
	public class AppModel extends EventDispatcher {
		
		private static var _instance:AppModel;
		
		//The mediaflux connection
		private var _connection:Connection;
		
		//Singleton protection
		public function AppModel(enforcer:SingletonEnforcer) {
			super();
			if(!enforcer) {
				throw new Error("Router must be called from getInstance()");
			}
		}
		
		//Singleton protection
		public static function getInstance():AppModel {
			if(!_instance) {
				_instance = new AppModel(new SingletonEnforcer);
			}
			return _instance;
		}
		
		
		/* ======================= LOGIN/LOGOUT FUNCTION ======================= */
		//Logs into the server
		public function login(username:String, password:String, handler:Function, domain:String="system"):void {
			var args:Object = new Object();
			args.user = username;
			args.password = password;
			args.domain = domain;
			var loginPackage:XML = _connection.packageRequest("system.logon",args,false);
			trace("trying to login");
			_connection.sendRequest(loginPackage, handler);
		}
		
		//Logs out of the server
		public function logout():void {
			var args:Object = new Object();
			
			_connection.sendRequest(_connection.packageRequest("system.logoff",args,false),this.debugCallback);
		}
		
		/**
		 * Gets out the roles for the current user.  
		 * 
		 */		
		public function getUserRoles(callback:Function):void {
			var args:Object = new Object();
			_connection.sendRequest(
				_connection.packageRequest("actor.self.describe", args, true),
				callback
			);
		}
		
		//Initialises the server connection
		public function setServerConfig(serverAddress:String,serverPort:Number):Boolean {
			_connection = new Connection(serverAddress,serverPort);
			return true;
		}
		
		/* ==================================== BROWSER CONTROLLER FUNCTIONS ======================================== */
		/**
		 * Gets all collections created by the user
		 * @param 	callback	The function to call when asset lookup is completed	
		 */		
		public function getCollections(callback:Function):void {
			var args:Object = new Object();
			//args.where = "namespace = recensio and r_base/active=true and class>='recensio:base/resource/collection' and xpath(mf-revision-history/user/name)='"+Auth.getInstance().getUsername()+"'";
			args.where = "namespace = recensio and r_base/active=true and class>='recensio:base/resource/collection'";
			
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			args.action = "get-meta";
			
			args['get-related-meta'] = true;
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not get collections");
			}
		}
		
		/**
		 * Gets all the assets (including shared assets) for the user
		 *  
		 * @param 	callback	The function to call when asset lookup is completed	
		 */		
		public function getAllMediaAssets(callback:Function):void {
			trace("Getting all media assets");
			var args:Object = new Object();
			args.where = "namespace = recensio and r_base/active = true and class >= 'recensio:base/resource/media'";
			
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			// Dont just get the media assets data, get out all the data for all of its children
			// that is, all the comments/annotations on all the assets
			args['related-type'] = "has_child";			
			args['get-related-meta'] = true;
			
			args.action = "get-meta";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not get assets");
			}
		}
		
		/**
		 * Gets all assets *not* owned by the user but those which the user has access to
		 * @param callback
		 * 
		 */		
		public function getSharedAssets(callback:Function):void {
			var args:Object = new Object();
			args.where = "namespace = recensio and r_base/active=true and " +
				"class >= 'recensio:base/resource/media' and xpath(mf-revision-history/user/name)!='"+Auth.getInstance().getUsername()+"'";
			
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			args.action = "get-meta";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not get shared assets");
			}
		}
		
		/**
		 * Gets all the assets for this collection (media and annotation)
		 * Can filter out annotation with @see parseResultsChildren()
		 * 
		 * @param 	callback	The function to call when asset lookup is completed	 
		 */		
		public function getThisCollectionsMediaAssets(collectionID:Number, callback:Function):void {
			var transaction:Transaction_GetThisCollectionsMediaAssets = new
					Transaction_GetThisCollectionsMediaAssets(collectionID, callback, _connection);
		}
		
		/**
		 * Gets out all the commentary data for this Asset (either a Media or Collection
		 * asset). The commentary is either Comments or Annotations 
		 * @param assetID
		 * @return 
		 * 
		 */		
		public function getThisAssetsCommentary(objectID:Number, roomID:Number, callback:Function):void {
			trace("AppModel getThisAssetsCommentary: Getting Commentary for Asset", objectID);
			
			var args:Object = new Object();
			
			
			args.where = "namespace = recensio and r_base/active = true and class >= 'recensio:base/resource/annotation' " +
				"and related to{room} (id=" + roomID + ") and related to{object} (id=" + objectID + ")";
			
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			args.action = "get-meta";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not load annotations");
			}
		}
		
		public function getThisAssetsCommentaryWithRoomArray(objectID:Number, roomIDArray:Array, callback:Function):void {
			trace("AppModel getThisAssetsCommentary: Getting Commentary for Asset", objectID);
			
			var args:Object = new Object();
			
			
			args.where = "namespace = recensio and r_base/active = true and class >= 'recensio:base/resource/annotation' " +
				"and related to{object} (id=" + objectID + ") and (";
		
			for(var i:Number = 0; i < roomIDArray.length; i++) {
				if(i > 0) {
					args.where += " or ";
				}
				args.where += "related to{room} (id=" + roomIDArray[i] + ")";
			}
			args.where += ")";
			
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			args.action = "get-meta";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not load annotations");
			}
		}
		
		
		//Gets all assets owned by the user
		/*public function getAllAssets(callback:Function):void {
			var args:Object = new Object();
			args.where = "namespace = recensio and r_base/active=true and class>='recensio:base/resource/media' and xpath(mf-revision-history/user/name)='"+Auth.getInstance().getUsername()+"'";
			args.action = "get-meta";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not get assets");
			}
		}*/
		
		
		
		
		/* ==================================== MEDIA CONTROLLER FUNCTIONS ======================================== */
		
	
		public function getAsset(assetID:Number,callback:Function):void {
			var args:Object = new Object();
			args.where = "namespace = recensio and r_base/active=true and class>='recensio:base/resource/media' and id="+assetID;
			args.action = "get-meta";
			
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not load asset");
			}
		}
		
		/**
		 * Get the Meta Data for the Media Asset, and all the Annotations for the Media Asset
		 * @param assetID		The ID of the asset to retrieve the data for
		 * @param callback		The function to callback after the data is retrieved.
		 * 
		 */	
		public function getThisMediasData(assetID:Number, callback:Function):void {
			var args:Object = new Object();
			
			// Get out all the assets that are a child of this collection
			args.where = "namespace = recensio and r_base/active=true and id =  " + assetID;
			
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			// Get out the meta data for these assets
			args.action = "get-meta";	
			
			// But, dont just get the asset data, get the data for all of its children
			// That is, all the comments/annotations on all the assets
			args['related-type'] = "has_child";			
			args['get-related-meta'] = true;
			
			//"id = " + collectionID + " and namespace = recensio and r_base/active=true";
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not get assets");
			}
		}	
		
		//asset.query :where namespace=recensio and class>='recensio:base/resource/media' and related to (id=1247)
		public function getAssetIdsForCollection(collectionID:Number,callback:Function):void {
			
		}
		
		// Gets the annotations and comments for a specific asset
		public function getAnnotations(assetID:Number,callback:Function):void {
			var args:Object = new Object();
			args.where = "namespace = recensio and r_base/active=true and class>='recensio:base/resource/annotation' and related to{is_child} (id="+assetID+")";
			args.action = "get-meta";
			// By default, asset.query limits it to 100 results
			// this means we will get them all TODO change this so it paginates basically
			args.size = "infinity";
			
			if(_connection.sendRequest(_connection.packageRequest('asset.query',args,true),callback)) {
				//All good
			} else {
				Alert.show("Could not load annotations");
			}
		}
		
		// Gets the access information for a specific asset
		public function getAccess(assetID:Number,callback:Function):void {
			var transaction:Transaction_GetAccess = new Transaction_GetAccess(_connection,assetID,callback);
		}
		
		// Sets the access information for a specific asset
		public function setAccess(assetID:Number,access:Array,callback:Function=null):void {
			var transaction:Transaction_SetAccess = new Transaction_SetAccess(_connection,assetID,access,callback);
		}
		
		public function getPeople(people:XMLList, callback:Function):void {
			var transaction:Transaction_GetPeopleAndCollectionNames = new Transaction_GetPeopleAndCollectionNames(_connection);
			transaction.getPeopleAndCollectionNames(people, callback);
		}
		
		/**
		 * Changes access to an asset 
		 * @param assetID		The Asset ID
		 * @param username		The username to change access for
		 * @param domain		The domain of the user
		 * @param access		The access level
		 * @param isCollection	Whether the asset is a collection or not
		 * @param callback		Function to call when complete
		 * 
		 */		
		public function changeAccess(assetID:Number, username:String, domain:String, access:String, isCollection:Boolean, callback:Function=null):void {
			var transaction:Transaction_ChangeAccess = new Transaction_ChangeAccess(_connection);
			transaction.changeAccess(assetID, assetID, username, domain, access, isCollection, callback);
		}
		/**
		 * Saves a new comment, either a reply or a new comment
		 * @param commentText		The text of the new comment
		 * @param commentParentID	The parent of the new comment (either an assetID for an
		 * 							asset, for the collectionID for a collection
		 * @param newCommentObject	The new comment object (the one that will be replaced with an 
		 * 							actual comment when this all returns)
		 * @param callback			The function to call when the datbase call is complete
		 * 
		 */		
		public function saveNewComment(commentText:String, roomID:Number, objectID:Number, 
									   replyingToID:Number,
									   newCommentObject:NewComment, callback:Function):void {
			var saveCommentTransaction:Transaction_SaveNewComment = new Transaction_SaveNewComment(_connection, commentText, roomID, objectID, replyingToID,
																									newCommentObject, callback);
		}
		
		// DEKKERS COMMENT FUNCTION, saveNewComment is my comment function
		// Saves a comment (reply, new or updated comment)
		/*public function saveComment(assetData:Object):void {
			trace('about to call database, comment is:', assetData.commentText);
			var args:Object = new Object();
			if(assetData.assetID == -1) {
				args.namespace = "recensio";
				var baseXML:XML = _connection.packageRequest('asset.create',args,true);
				baseXML.service.args["related"]["to"] = assetData.parentID;
				baseXML.service.args["related"]["to"].@relationship = "is_child";
				baseXML.service.args["meta"]["r_base"]["obtype"] = "4";
				baseXML.service.args["meta"]["r_base"]["active"] = "true";
				baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
				baseXML.service.args["meta"]["r_base"].@id = 2;
				if(assetData.reply_id > 0) {
					baseXML.service.args["meta"]["r_resource"]["title"] = "comment";
				} else {
					baseXML.service.args["meta"]["r_resource"]["title"] = "commentReply";
				}
				baseXML.service.args["meta"]["r_resource"]["description"] = " ";
				baseXML.service.args["meta"]["r_annotation"]["x"] = "0";
				baseXML.service.args["meta"]["r_annotation"]["y"] = "0";
				baseXML.service.args["meta"]["r_annotation"]["start"] = "" + assetData.reply_id;
				baseXML.service.args["meta"]["r_annotation"]["text"] = assetData.annotation_text;
				trace("Im saving teh comment text", assetData.annotation_text);
				baseXML.service.args["meta"]["r_annotation"]["annotationType"] = "3";
				baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
				if(_connection.sendRequest(baseXML,(assetData.commentObject as Comment).commentSaved)) {
					//All good
				} else {
					Alert.show("Could not save comment");
				}
			} else {
				var baseXMLUpdate:XML = _connection.packageRequest('asset.set',args,true);
				baseXMLUpdate.service.args["id"] = assetData.assetID;
				baseXMLUpdate.service.args["meta"]["r_annotation"]["text"] = assetData.annotation_text;
				if(_connection.sendRequest(baseXMLUpdate,debugCallback)) {
					//All good
				} else {
					Alert.show("Could not update comment");
				}
			}
		}*/
		
		/**
		 * Saves a new pen annotation. 
		 * @param mediaAssetID	The ID of the media asset which the annotation is on
		 * @param path			The string that contains the path of the pen annotations (in XML)
		 * @param text			The text to be associated with the annotation
		 * @param callback		The function to call when the saving is complete.
		 * 
		 */
		public function saveNewPenAnnotation(mediaAssetID:Number, roomID:Number, path:String, text:String, callback:Function):void {
			trace("- App Model: Saving Pen annotation...");	
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			
			// Set the annotations parent media asset
//			baseXML.service.args["related"]["to"] = mediaAssetID;
//			baseXML.service.args["related"]["to"].@relationship = "is_child";
			baseXML.service.args.related = "";
			baseXML.service.args.related.appendChild(XML('<to relationship="room">' + roomID + '</to>'));
			baseXML.service.args.related.appendChild(XML('<to relationship="object">' + mediaAssetID + '</to>'));
			
			baseXML.service.args["meta"]["r_base"]["obtype"] = "4";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			
			// Set the creator to be the current user
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_base"].@id = 2;
			
			// Set it as an annotation
			baseXML.service.args["meta"]["r_resource"]["title"] = "Annotation";
			baseXML.service.args["meta"]["r_resource"]["description"] = " ";
			
			// Set All of the annotations data
			baseXML.service.args["meta"]["r_annotation"]["path"] = path;
			if(text != "") {
				baseXML.service.args["meta"]["r_annotation"]["text"] = text;
			}

			// This annotation is a 'Annotation' annotation, lol, not a comment
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.ANNOTATION_PEN_TYPE_ID;
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";

			// Try and save, then call the callback.
			if(_connection.sendRequest(baseXML, callback)) {
				trace("- App Model: Annotation Saved");
				//All good
			} else {
				Alert.show("Could not save annotation");
			}
			
		}
		
		public function saveNewHighlightAnnotation(mediaAssetID:Number, roomID:Number, xCoor:Number, yCoor:Number, page1:Number, startTextIndex:Number, 
													endTextIndex:Number, text:String, callback:Function):void {
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			
			// Set the annotations parent media asset
			baseXML.service.args.related = "";
			baseXML.service.args.related.appendChild(XML('<to relationship="room">' + roomID + '</to>'));
			baseXML.service.args.related.appendChild(XML('<to relationship="object">' + mediaAssetID + '</to>'));
//			baseXML.service.args["related"]["to"] = mediaAssetID;
//			baseXML.service.args["related"]["to"].@relationship = "is_child";
			baseXML.service.args["meta"]["r_base"]["obtype"] = "4";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			
			// Set the creator to be the current user
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_base"].@id = 2;
			
			// Set it as an annotation
			baseXML.service.args["meta"]["r_resource"]["title"] = "Annotation";
			baseXML.service.args["meta"]["r_resource"]["description"] = " ";
			
			// Set All of the annotations data
			baseXML.service.args["meta"]["r_annotation"]["x"] = xCoor;
			baseXML.service.args["meta"]["r_annotation"]["y"] = yCoor;
			baseXML.service.args["meta"]["r_annotation"]["start"] = startTextIndex;
			baseXML.service.args["meta"]["r_annotation"]["end"] = endTextIndex;
			baseXML.service.args["meta"]["r_annotation"]["text"] = text;
			baseXML.service.args["meta"]["r_annotation"]["lineNum"] = page1; // We are storing the page number, in the lin num variable
			
			// I have absolutely no idea what this is, so im commenting it out for now
			//			if(assetData.path != "") {
			//				baseXML.service.args["meta"]["r_annotation"]["path"] = assetData.path;
			//			}
			
			// This annotation is a 'Annotation' annotation, lol, not a comment
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.ANNOTATION_HIGHLIGHT_TYPE_ID + "";
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			trace(baseXML);
			
			// Try and save, then call the callback.
			if(_connection.sendRequest(baseXML, callback)) {
				trace("- App Model: Annotation Saved");
				//All good
			} else {
				Alert.show("Could not save annotation");
			}
			
		}
		/**
		 * Saves a new Box Annotation. 
		 * @param mediaAssetID	The ID of the media asset, the annotation is on
		 * @param xCoor 		The x (top left) of the annotation box
		 * @param yCoor			The y (top right) of the annotation box
		 * @param width			The width of the annotation box
		 * @param height		The height of the annotation box
		 * @param startTime		The time where the box first appears
		 * @param endTime		The time where the box disappears
		 * @param annotationText	The text that is part of the annotation
		 * @param callback			The function to call when the anntoation is saved
		 * 
		 */		
		public function saveNewBoxAnnotation(	mediaAssetID:Number, roomID:Number, xCoor:Number, yCoor:Number,
											annotationWidth:Number, annotationHeight:Number,
											startTime:Number, endTime:Number,
											annotationText:String, callback:Function):void {
			
			trace("- App Model: Saving box annotation...");
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			
			// Set the annotations parent media asset
			baseXML.service.args.related = "";
			baseXML.service.args.related.appendChild(XML('<to relationship="room">' + roomID + '</to>'));
			baseXML.service.args.related.appendChild(XML('<to relationship="object">' + mediaAssetID + '</to>'));
			
//			baseXML.service.args["related"]["to"] = mediaAssetID;
//			baseXML.service.args["related"]["to"].@relationship = "is_child";
			baseXML.service.args["meta"]["r_base"]["obtype"] = "4";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			
			// Set the creator to be the current user
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_base"].@id = 2;
			
			// Set it as an annotation
			baseXML.service.args["meta"]["r_resource"]["title"] = "Annotation";
			baseXML.service.args["meta"]["r_resource"]["description"] = " ";
			
			// Set All of the annotations data
			baseXML.service.args["meta"]["r_annotation"]["x"] = xCoor;
			baseXML.service.args["meta"]["r_annotation"]["y"] = yCoor;
			baseXML.service.args["meta"]["r_annotation"]["width"] = Math.round(annotationWidth);
			baseXML.service.args["meta"]["r_annotation"]["height"] = Math.round(annotationHeight);
			baseXML.service.args["meta"]["r_annotation"]["start"] = startTime;
			baseXML.service.args["meta"]["r_annotation"]["end"] = endTime;
			baseXML.service.args["meta"]["r_annotation"]["text"] = annotationText;
			
			// I have absolutely no idea what this is, so im commenting it out for now
//			if(assetData.path != "") {
//				baseXML.service.args["meta"]["r_annotation"]["path"] = assetData.path;
//			}
		
			// This annotation is a 'Annotation' annotation, lol, not a comment
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.ANNOTATION_BOX_TYPE_ID + "";
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			trace(baseXML);
			
			// Try and save, then call the callback.
			if(_connection.sendRequest(baseXML, callback)) {
				trace("- App Model: Annotation Saved");
				//All good
			} else {
				Alert.show("Could not save annotation");
			}
			
		}

		/**
		 * Copy the access that is on one asset, to another 
		 * @param copyFromID			The ID to copy from
		 * @param copyToID				The ID to copy to
		 * @param ignoreCurrentUser		True if we should not copy across the current user's acls
		 * 
		 */
		public function copyAccess(copyFromID:Number, copyToID:Number, ignoreCurrentUser:Boolean = false):void {
			var transaction:Transaction_CopyAccess = new Transaction_CopyAccess(copyFromID, copyToID, ignoreCurrentUser, _connection);
		}
		
		// Saves an annotation
		public function saveAnnotation(assetData:Object, roomID:Number):void {
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			
			baseXML.service.args.related = "";
			baseXML.service.args.related.appendChild(XML('<to relationship="room">' + roomID + '</to>'));
			baseXML.service.args.related.appendChild(XML('<to relationship="object">' + assetData.parentID + '</to>'));
			
//			baseXML.service.args["related"]["to"] = assetData.parentID;
//			baseXML.service.args["related"]["to"].@relationship = "is_child";
			baseXML.service.args["meta"]["r_base"]["obtype"] = "4";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_base"].@id = 2;
			baseXML.service.args["meta"]["r_resource"]["title"] = "Annotation";
			baseXML.service.args["meta"]["r_resource"]["description"] = " ";
			baseXML.service.args["meta"]["r_annotation"]["x"] = assetData.x;
			baseXML.service.args["meta"]["r_annotation"]["y"] = assetData.y;
			baseXML.service.args["meta"]["r_annotation"]["width"] = assetData.width;
			baseXML.service.args["meta"]["r_annotation"]["height"] = assetData.height;
			baseXML.service.args["meta"]["r_annotation"]["start"] = assetData.start;
			baseXML.service.args["meta"]["r_annotation"]["end"] = assetData.end;
			baseXML.service.args["meta"]["r_annotation"]["text"] = assetData.text;
			if(assetData.path != "") {
				baseXML.service.args["meta"]["r_annotation"]["path"] = assetData.path;
			}
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = "2";
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			trace(baseXML);
			if(_connection.sendRequest(baseXML,function(e:Event):void {
				trace(e.target.data);
				var dataXML:XML = XML(e.target.data);
				if (dataXML.reply.@type == "result") {
					
					var new_id:Number = dataXML.reply.result.id;
					
					// Send a notification
					AppModel.getInstance().createERANotification(AppController.currentEraProject.year, roomID, Auth.getInstance().getUsername(), Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, Model_ERANotification.ANNOTATION, 0, assetData.parentID, new_id);
					
					AppModel.getInstance().setAnnotationClassForID(new_id);
					//AppModel.getInstance().copyAccess(assetData.parentID, new_id);
				}
			})) {
				trace("ALL GOOD");
				//All good
			} else {
				Alert.show("Could not save annotation");
			}
		}
		
		// Sets a saved annotation to have the correct class
		public function setAnnotationClass(e:Event):void {
			trace("- App Model: Setting Annotation Class");
			trace(e.target.data);
			var dataXML:XML = XML(e.target.data);
			if (dataXML.reply.@type == "result") {
				var args:Object = new Object();
				var baseXML:XML = _connection.packageRequest('asset.class.add',args,true);
				baseXML.service.args["scheme"] = "recensio";
				baseXML.service.args["class"] = "base/resource/annotation";
				baseXML.service.args["id"] = dataXML.reply.result.id;
				_connection.sendRequest(baseXML,null);
			} else {
				Alert.show("Could not save annotation class");
			}
		}
		
		/**
		 * Set the Annotation asset we just created, to have the Annotation Classification
		 * @param annotationID	the ID of the annotation to set
		 * 
		 */		
		public function setAnnotationClassForID(annotationID:Number, callback:Function = null):void {
			trace("- App Model: Setting Annotation Class");
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.class.add',args,true);
			baseXML.service.args["scheme"] = "recensio";
			baseXML.service.args["class"] = "base/resource/annotation";
			baseXML.service.args["id"] = annotationID;
			_connection.sendRequest(baseXML, callback);
		}
		
		// Sets a saved asset to have the correct class
		public function setMediaClass(e:DataEvent):void {
			trace("- Setting Media Class");
			var dataXML:XML = XML(e.data);
			//if (dataXML.reply.@type == "result") {
				var args:Object = new Object();
				var baseXML:XML = _connection.packageRequest('asset.class.add',args,true);
				baseXML.service.args["scheme"] = "recensio";
				baseXML.service.args["class"] = "base/resource/media";
				baseXML.service.args["id"] = dataXML.reply.result.id;
				
				if(_connection.sendRequest(baseXML, null)) {
					trace("- MediaClass Set");
				} else {
					trace("- Failed to set MediaClass");
					Alert.show("Failed to set MediaClass");
				};
				
			//} else {
//				trace("File did not upload???");
//				trace(e);
//				Alert.show("Could not set media class");
//			}
		}
		
		
		/**
		 * CRAIG
		 * Sets the ACL for a file or collection asset 
		 * @param id
		 * @return 
		 * 
		 */		
		public function setOwnerACL(id:Number):void {
			// Create the args for asset.acl.grant
			var args:Object = new Object();
			// Create the request
			var baseXML:XML = _connection.packageRequest('asset.acl.grant', args, true);
			baseXML.service.args["id"] = id;
			baseXML.service.args.appendChild(XML('<acl><actor type="user">system:'+Auth.getInstance().getUsername()+'</actor><access>read-write</access></acl>'));
			
			if(_connection.sendRequest(baseXML, function(e:Event):void {
				trace("setting own for", id, "status", e.target.data);
			})) {
				trace("- Owner Set");
			} else {
				trace("- Failed to set owner");
				Alert.show("Failed to set Owner");
			}
		}
		
		// DEKKER Sets a saved asset to have a correct ACL for the owner (force ACL)
//		public function setOwner(e:Event):void {
//			trace(" Setting ACL for Asset");
//			var dataXML:XML = XML(e.target.data);
//			//if (dataXML.reply.@type == "result") {
//				var args:Object = new Object();
//				var baseXML:XML = _connection.packageRequest('asset.acl.grant',args,true);
//				baseXML.service.args["id"] = dataXML.reply.result.id;
//				baseXML.service.args.appendChild(XML('<acl><actor type="user">system:'+Auth.getInstance().getUsername()+'</actor><access>read-write</access></acl>'));
//				
//				if(_connection.sendRequest(baseXML, callbackTemp)) {
//					trace("- Owner Set");
//				} else {
//					trace("- Failed to set owner");
//					Alert.show("Failed to set Owner");
//				};
//			//} else {
////				trace("File did not upload???");
////				//trace("Could not set owner:", e);
////				Alert.show("Could not set owner");
////			}
//		}
		
		// Sets a saved collection to have the correct class
		public function setCollectionClass(e:Event, callback:Function):void {
			var dataXML:XML = XML(e.target.data);
			if (dataXML.reply.@type == "result") {
				trace("DONG DONG");
				trace(dataXML.reply.result.id);
				var args:Object = new Object();
				var baseXML:XML = _connection.packageRequest('asset.class.add',args,true);
				baseXML.service.args["scheme"] = "recensio";
				baseXML.service.args["class"] = "base/resource/collection";
				baseXML.service.args["id"] = dataXML.reply.result.id;
				_connection.sendRequest(baseXML, callback);
			} else {
				Alert.show("Could not set collection type");
			}
		}

		// Updates the information for a previously saved asset
		public function updateAsset(assetData:Object, callback:Function=null):void {
			var args:Object = new Object();
			var baseXMLUpdate:XML = _connection.packageRequest('asset.set',args,true);
			baseXMLUpdate.service.args["id"] = assetData.assetID;
			
			
			trace("saving", assetData.assetID, assetData.meta_title, assetData.meta_description);
			
			// The title is compulsory, so if its not there, it should error.
			baseXMLUpdate.service.args["meta"]["r_resource"]["title"] = assetData.meta_title;
			
			// Cause for some fucking reason
			// mediaflux doesnt let you delete a entry
			// it also doesnt allow you to set it to be "" or even " ";
			if(assetData.meta_description == "") assetData.meta_description = "*";
			if(assetData.meta_subject == "") assetData.meta_subject = "*";
			if(assetData.meta_keywords == "") assetData.meta_keywords = "*";
			if(assetData.meta_datepublished == "") assetData.meta_datepublished = "*";
			if(assetData.meta_othercontrib == "") assetData.meta_othercontrib = "*";
			if(assetData.meta_sponsorfunder == "") assetData.meta_sponsorfunder = "*";
			if(assetData.meta_creativeworksubtype == "") assetData.meta_creativeworksubtype = "*";
			if(assetData.meta_creativeworktype == "") assetData.meta_creativeworktype = "*";
		
			baseXMLUpdate.service.args.meta.r_resource.description = assetData.meta_description;	
			
			baseXMLUpdate.service.args.meta.r_base.properties = "";
			
			baseXMLUpdate.service.args.meta.r_base.properties.appendChild(XML('<property name="Subject">'+assetData.meta_subject+'</property>'));
			
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="Keywords">'+assetData.meta_keywords+'</property>'));
				
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="DatePublished">'+assetData.meta_datepublished+'</property>'));
				
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="OtherContrib">'+assetData.meta_othercontrib+'</property>'));
						
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="SponsorFunder">'+assetData.meta_sponsorfunder+'</property>'));
			
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkSubType">'+assetData.meta_creativeworksubtype+'</property>'));
			
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkType">'+assetData.meta_creativeworktype+'</property>'));
						
			if(_connection.sendRequest(baseXMLUpdate, callback)) {
				//All good
			} else {
				Alert.show("Could not update asset information");
			}
		}
		
		/**
		 * Removes access to an collection for a user (or deletes the asset, if
		 * the current user is the creator) 
		 * @param assetID				The ID of the asset to delete
		 * @param creator_username		The creator of the asset
		 * 
		 */	
		public function deleteCollection(assetID:Number, creatorUsername:String, callback:Function):void {
			trace("AppModel deleteCollection: Deleting Asset:", assetID, ", creator is: ", creatorUsername);
			if(Auth.getInstance().isSysAdmin() || creatorUsername == Auth.getInstance().getUsername()) {
				trace("AppModel deleteCollection: Either the sys admin, or, the current user is the creator of the collection, so delete it");
				AppModel.getInstance().assetDestroy(assetID, callback);
			} else {
				// get the users that have access to this file
				trace("AppModel deleteCollection: Not the creator, removing access to collection");
				AppModel.getInstance().changeAccess(assetID, Auth.getInstance().getUsername(), "system", 
					SharingPanel.NOACCESS, true, callback);
			}
		}
		
		/**
		 * Removes access to media for a user (or deletes the asset, if
		 * the current user is the creator) 
		 * @param assetID				The ID of the asset to delete
		 * @param creator_username		The creator of the asset
		 * 
		 */	
		public function deleteMedia(assetID:Number, creatorUsername:String):void {
			trace("AppModel deleteMedia: Deleting Asset:", assetID, ", creator is: ", creatorUsername);
			if(Auth.getInstance().isSysAdmin() || creatorUsername == Auth.getInstance().getUsername()) {
				trace("AppModel deleteMedia: Either the sys admin, or, the current user is the creator of the file, so delete it");
				AppModel.getInstance().assetDestroy(assetID, assetDeleted);
			} else {
				// get the users that have access to this file
				trace("AppModel deleteCollection: Not the creator, removing access to media");
				AppModel.getInstance().changeAccess(assetID, Auth.getInstance().getUsername(), "system", 
					SharingPanel.NOACCESS, false, assetDeleted);
			}
		}
		
			
//		public function deleteAsset(assetID:Number, creatorUsername:String):void {
//			var transaction:Transaction_DeleteMediaFromUser = new Transaction_DeleteMediaFromUser(
//				assetID,
//				creatorUsername,
//				_connection,
//				assetDeleted
//			);
//		}
		
		/**
		 * Deletes an asset from the database. 
		 * @param assetID
		 * @param callback
		 * 
		 */		
		public function assetDestroy(assetID:Number, callback:Function):void {
			trace("Destroying asset", assetID);
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
			baseXML.service.args["id"] = assetID;
		
			_connection.sendRequest(baseXML, function(e:Event):void {
				trace("Deleting clones of", assetID);
				var args:Object = new Object();
				args.where = "r_resource/clone_of_id=" + assetID;
				args.action = "pipe";
				args.size = "infinity";
				var baseXML:XML = _connection.packageRequest('asset.query',args,true);
				baseXML.service.args.service.@name = "asset.destroy";
				
				_connection.sendRequest(baseXML, function(e:Event):void {
					if(callback) {
						callback(e);
					}
				});
			});
		}
		
		// Deletes an annotation
		public function deleteAnnotation(assetID:Number):void {
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
			baseXML.service.args["id"] = assetID;
			if(_connection.sendRequest(baseXML,null)) {
				//All good
			} else {
				Alert.show("Could not delete asset");
			}
		}
		
		// Deletes an annotatio
		public function deleteAnnotation2(assetID:Number, callback:Function):void {
			AppModel.getInstance().deleteRelatedERANotifications(assetID, function(status:Boolean):void {
				if(!status) trace("failed to delete annotations for notifiaction", assetID);
				var args:Object = new Object();
				var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
				baseXML.service.args["id"] = assetID;
				if(_connection.sendRequest(baseXML, callback)) {
					//All good
				} else {
					Alert.show("Could not delete asset");
				}
			
			});
			
		}
		
		// Reply when an asset is deleted
		private function assetDeleted(e:Event):void {
			Dispatcher.call("browse");
		}
		
		/**
		 * Removes a comment. 
		 * 
		 * If the user is the sys-admin, the comment is actually deleted,
		 * if the user is not a sys-admin, the comment text is replaced with 'comment removed'.
		 * @param assetID
		 * 
		 */		
		public function deleteComment(assetID:Number):void {
			
			if(Auth.getInstance().isSysAdmin()) {
				AppModel.getInstance().deleteRelatedERANotifications(assetID, function(status:Boolean):void {
					if(!status) trace("failed to remove notifications");
					AppModel.getInstance().assetDestroy(assetID, null);	
				});
			
				return;
			}
			
			AppModel.getInstance().editComment(assetID, "Comment Removed");
			
		}
		
		public function editComment(commentID:Number, commentText:String, callback:Function = null):void {
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.set', args, true);
			baseXML.service.args["id"] = commentID;
			baseXML.service.args["meta"]["r_annotation"]["text"] = commentText;
			
			if(_connection.sendRequest(baseXML, callback)) {
				//All good
			} else {
				Alert.show("Could not delete comment");
			}
			
		}
		
		// Debug callback for functions which do not have their own callback
		private function debugCallback(e:Event):void {
			trace("Returned Data", e.target.data);
		}
		
		
		/* ==================================== COLLECTION FUNCTIONS ========================================== */
		/**
		 * Creates a new collection. 
		 * @param collectionTitle	The title of the collection
		 * @param shelfAssets		An array of Model_Media assets to be in the collection
		 * @param callback	The callback
		 * 
		 */		
		public function createCollection(collectionTitle:String, shelfAssets:Array, callback:Function):void {
			trace("Creating collection");
			var transaction:Transaction_CreateCollection = new Transaction_CreateCollection(_connection);
			transaction.createCollection(collectionTitle, shelfAssets, callback);
//			// Build up the collection object
//			var args:Object = new Object();
//			args.namespace = "recensio";
//			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
//			baseXML.service.args["meta"]["r_base"]["obtype"] = "10";
//			baseXML.service.args["meta"]["r_base"]["active"] = "true";
//			// Set creator as the current user
//			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
//			baseXML.service.args["meta"]["r_base"].@id = 2;
//			baseXML.service.args["meta"]["r_resource"]["title"] = collectionTitle;
//			
//			baseXML.service.args["meta"]["r_media"].@id = 4;
//			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
//			baseXML.service.args["related"] = "";
//			
//			// Link the collection to all the assets on the shelf.
//			for(var i:Number = 0; i < shelfAssets.length; i++) {
//				trace("Including asset", (shelfAssets[i] as Model_Media).base_asset_id);
//				baseXML.service.args["related"].appendChild(XML('<to relationship="has_child">' + Math.abs((shelfAssets[i] as Model_Media).base_asset_id) + '</to>'));
//				var transaction:Transaction_CloneMedia = new Transaction_CloneMedia(_connection);
//				transaction.cloneMedia(Math.abs((shelfAssets[i] as Model_Media).base_asset_id), function(assetID:Number):void {
//					trace("WOOOOO!!!! *****************************************", assetID);
//				});
//			}
//			
//			// Set the description, to be the number of items in the collection
//			baseXML.service.args["meta"]["r_resource"]["description"] = shelfAssets.length;
//			
//			if(_connection.sendRequest(baseXML,function(e:Event):void {
////				AppModel.getInstance().setUserAssetShareCount(
//				
//				if(!callSuccessful(e)) {
//					trace("AppModel:createCollection - Failed to Create collection", e.target.data);
//					callback(e);
//					return;
//				}
//				
//				// Set this user as the owner of the collection
//				AppModel.getInstance().changeAccess(XML(e.target.data).reply.result.id, Auth.getInstance().getUsername(), 
//					"system", SharingPanel.READWRITE, true, function(k:Event):void {
//						trace("**********************************");
//						trace("AppModel:createCollection - Finished Creating the Collection");
//						
//					// Update the Collection Class so it is a 'collection'
//					AppModel.getInstance().setCollectionClass(e, function(j:Event):void {
//						callback(e);					
//					});
//				});
//				
//			})) {
//				trace("SENDING NEW COLLECTION");
//				//All good
//			} else {
//				Alert.show("Could not save collection");
//			}
		}
		
		/**
		 * Saves an Existing Collection that has been updated. 
		 * @param collectionID	The ID of the collection to be updated
		 * @param mediaAssets	The new media assets to be attached to this collection.
		 * @param callback		@see collectionUpdated in BrowserController
		 * 
		 */		
		public function saveCollection(collectionID:Number, collectionTitle:String, mediaAssets:Array,callback:Function):void {
			new Transaction_SaveCollection(_connection, collectionID, collectionTitle, mediaAssets, callback);
		}
		
		// Deletes a collection
//		public function deleteCollection(assetID:Number, callback:Function):void {
//			var args:Object = new Object();
//			var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
//			baseXML.service.args["id"] = assetID;
//			if(_connection.sendRequest(baseXML, callback)) {
//				//All good
//			} else {
//				Alert.show("Could not delete collection");
//			}
//		}
		
		
		
		/* ================================== HELPER FUNCTIONS =============================== */
		
		
		// Parse the results of a response
		public function parseResults(data:XML,assetType:Class):Array {
//			trace("DATA IS", data);
			var path:String = '';
			switch(assetType) {
				case Model_Media:
					path = 'asset';
					break;
				case Model_Commentary:
					path = 'asset';
					break;
				case Model_User:
				case Model_ERAUser:
					path = 'user';
					break;
				default:
					path = 'asset';
			}
			var assets:Array = new Array();
			var assetsXML:XMLList = data.reply.result[path];
			for each(var assetXML:XML in assetsXML) {
//				trace("PARSING", assetType, assetXML);
				var asset:Model_Base = new assetType();
				asset.setData(assetXML);
				assets.push(asset);
			}
			return assets;
		}
		
		/**
		 * Gets out the 1 collection that is inside the XML 
		 * @param data
		 * @return 
		 * 
		 */		
		public function extractCollection(data:XML):Model_Collection {
			var assetXML:XMLList = data.reply.result.asset;
			var asset:Model_Collection = new Model_Collection();
			asset.setData(assetXML[0]);
			return asset;
		}
		
		/**
		 * Gets out the 1 media asset inside the XML that has been returned. 
		 * @param data
		 * @return 
		 * 
		 */		
		public function extractMedia(data:XML):Model_Media {
			var assetXML:XMLList = data.reply.result.asset;
			var asset:Model_Media = new Model_Media();
			asset.setData(assetXML[0]);
			return asset;
		}
		
		/**
		 * Takes a list of XML media objects, and converts them to an array of Model_Media 
		 * @param mediaXMLList	An XML list of media objects
		 * @return				An array of Model_Media
		 * 
		 */		
		public function convertXMLtoCollectionObjectsWithMedia(collectionXMLList:XMLList):Array {
			var collectionObjectArray:Array = new Array();
			
			//trace("AppModel:convertXMLtoCollectionObjectsWithMedia - Collection count", collectionXMLList.length());
			
			for each(var collectionXML:XML in collectionXMLList) {
				
				var collectionAndFileArray:Object = new Object();
				
				// Get out the asset and add it to our return array
				var collectionObject:Model_Collection = new Model_Collection();
				collectionObject.setData(collectionXML);
				
				collectionAndFileArray.collection = collectionObject;
				
				collectionAndFileArray.files = new Array();
				
				//trace("AppModel:convertXMLtoCollectionObjectsWithMedia - File count", collectionXML.related.asset.length());
				for each(var fileXML:XML in collectionXML.related.asset) {
					
					if(fileXML.type.toString()) {
						// We do this to filter out getting any comments
						// since (at least for now), comments dont have a file type set
						// so if there is a filetype, it must be a bit of media
						var fileObject:Model_Media = new Model_Media();
						fileObject.setData(fileXML);
						(collectionAndFileArray.files as Array).push(fileObject);
					}
				}
				
				collectionObjectArray.push(collectionAndFileArray);
			}
			return collectionObjectArray;
		}
		
		/**
		 * Takes an XML for files in a collection (that also have the comment meta attached),
		 *  and extracts out all the assets and puts them
		 * into assetType classes. This does not check the asset is that type.
		 *  
		 * @param data	an XML for a collection, with all the asset + annotations in the related fields.
		 * @return An array of assets (Model_Media) inside this collection
		 */		
		public function extractAssetsFromXML(data:XML, assetType:Class):Array {
			var assets:Array = new Array();
			// Get out a list of XML objects, (each one is an asset)
			var assetsXML:XMLList = data.reply.result.asset;
			trace("Looking at asset list", assetsXML.length());
			for each(var assetXML:XML in assetsXML) {
				// Get out the asset and add it to our return array
				var asset:Model_Base = new assetType();
				asset.setData(assetXML);
				assets.push(asset);
			
			}
			return assets;
		}
		
		public function extractCommentsFromXML(data:XML):Array {
			var assets:Array = new Array();
			// Get out a list of XML objects, (each one is an asset)
			var assetsXML:XMLList = data.reply.result.asset;
			
			for each(var assetXML:XML in assetsXML) {
				// Get out the asset and make it a Model_Commentary
				var asset:Model_Commentary = new Model_Commentary();
				asset.setData(assetXML);
				
				// Only add it to the return array if its a Comment
				if(asset.annotationType == Model_Commentary.COMMENT_TYPE_ID) {
					assets.push(asset);
				}
				
			}
			return assets;	
		}
		
		public function extractAnnotationsFromXML(data:XML):Array {
			var assets:Array = new Array();
			// Get out a list of XML objects, (each one is an asset)
			var assetsXML:XMLList = data.reply.result.asset;
			
			for each(var assetXML:XML in assetsXML) {
				// Get out the asset and make it a Model_Commentary
				var asset:Model_Commentary = new Model_Commentary();
				asset.setData(assetXML);
				
				// Only add it to the return array if its a Annotation
				if(asset.annotationType == Model_Commentary.ANNOTATION_BOX_TYPE_ID || asset.annotationType == Model_Commentary.ANNOTATION_PEN_TYPE_ID
						|| asset.annotationType == Model_Commentary.ANNOTATION_HIGHLIGHT_TYPE_ID) {
					assets.push(asset);
				}
				
			}
			return assets;	
		}
		
//	   /*
//		* Takes an XML for a collection, and extracts out all of the Annotations
//		*  
//		* @param data	A list of XML assets, both media and annotation
//		* @return An array of assets (Model_Media) inside this collection
//		*/		
//		public function extractAnnotationsFromFlatXML(data:XML):Array {
//			var assets:Array = new Array();
//			//var assetsXML:XMLList = data.reply.result.asset.related.asset;
//			var assetsXML:XMLList = data.reply.result.asset;
//			
//			for each(var assetXML:XML in assetsXML) {
//				
//				// So because we are getting children,
//				// we are actually also getting annotations/commennts
//				// as well as assets.
//				// so anno/comments dont have a type field,
//				// so we can just filter by that.
//				if(!assetXML.type.toString()) {
//					var asset:Model_Commentary = new Model_Commentary();
//					asset.setData(assetXML);
//					assets.push(asset);
//				}
//			}
//			return assets;
//		}
//		
//		/*
//		* Takes an XML for a collection, and extracts out all of the Annotations
//		*  
//		* @param data	an XML for a collection, with all the asset + annotations in the related fields.
//		* @return An array of assets (Model_Media) inside this collection
//		*/		
//		public function extractAnnotationsFromNestedXML(data:XML):Array {
//			var assets:Array = new Array();
//			var assetsXML:XMLList = data.reply.result.asset.related.asset;
//			//var assetsXML:XMLList = data.reply.result.asset;
//			
//			for each(var assetXML:XML in assetsXML) {
//				
//				// So because we are getting children,
//				// we are actually also getting annotations/commennts
//				// as well as assets.
//				// so anno/comments dont have a type field,
//				// so we can just filter by that.
//				if(!assetXML.type.toString()) {
//					var asset:Model_Commentary = new Model_Commentary();
//					asset.setData(assetXML);
//					assets.push(asset);
//				}
//			}
//			return assets;
//		}
//		
		
		// Parse the response of all assets being returned
		public function response_AllAssets(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			var assets:Array = new Array();
			var assetsXML:XMLList = dataXML.reply.result.asset;
			for each(var assetXML:XML in assetsXML) {
				var asset:Model_Media = new Model_Media();
				asset.setData(assetXML);
				assets.push(asset);
			}
		}
		
		// Uploads and saves a new media asset
		public function startFileUpload(data:Object):void {
//			var useID:Boolean = true;
			var args:Object = new Object();
			args.namespace = "recensio";
//			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
//			if(useID) {
			var baseXML:XML = _connection.packageRequest('id.asset.create',args,true);
			var argsXML:XMLList = baseXML.service.args;
//			}
			argsXML["meta"]["r_base"].@id = "2";
			argsXML["meta"]["r_base"]["obtype"] = "7";
			argsXML["meta"]["r_base"]["active"] = "true";
			
			if(data.meta_subjects != "" ||
				data.meta_keywords != "" ||
				data.meta_datepublished != "" ||
				data.meta_othercontrib != "" ||
				data.meta_sponsorfunder != "" ||
				data.meta_creativeworksubtype != "" ||
				data.meta_creativeworktype != "" ||
				data.meta_BLBK != "") {
				
				argsXML["meta"]["r_base"]["properties"] = "";
				
			}
			if(data.meta_subject != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="Subject">'+data.meta_subject+'</property>'));
			}
			if(data.meta_keywords != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="Keywords">'+data.meta_keywords+'</property>'));
			}
			if(data.meta_datepublished != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="DatePublished">'+data.meta_datepublished+'</property>'));
			}
			if(data.meta_othercontrib != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="OtherContrib">'+data.meta_othercontrib+'</property>'));
			}
			if(data.meta_sponsorfunder != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="SponsorFunder">'+data.meta_sponsorfunder+'</property>'));
			}
			if(data.meta_creativeworksubtype != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkSubType">'+data.meta_creativeworksubtype+'</property>'));
			}
			if(data.meta_creativeworktype != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkType">'+data.meta_creativeworktype+'</property>'));
			}
			if(data.meta_BLBK != "") {
				argsXML["meta"]["r_base"]["properties"].appendChild(XML('<property name="AuthorCreator">'+data.meta_BLBK+'</property>'));
			}
			argsXML["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			argsXML["meta"]["r_resource"].@id = "3";
			argsXML["meta"]["r_resource"]["title"] = data.meta_file_title;
			if(data.meta_description) {
				argsXML["meta"]["r_resource"]["description"] = data.meta_description;
			}
			argsXML.meta.r_media.file_title = data.meta_file_title;
			argsXML.meta.r_media.@id = "4";
			argsXML.meta.r_media.transcoded = "false";
			trace(baseXML);
			if(_connection.uploadFile(data.file,baseXML, function(e:Event):void {
				trace("Upload complete", e.target.data);
			})) {
				//All good
			} else {
				Alert.show("Sorry, an error occured and we couldn't upload the file.");
			}
		}
		
		/**
		 * Generates a thumbnail for a given image medias ID.
		 * @require the ID is for an image asset, not video etc
		 * @param imageID the Asset ID of the image asset
		 * 
		 */		
		public function generateThumbnail(imageID:Number):void {
			var args:Object = new Object();
			args.id = imageID;
//			args.out = imageID + ".jpg";
			args.size = 112;
			var baseXML:XML = _connection.packageRequest('asset.icon.get',args,true);
			_connection.sendRequest(baseXML, function(e:Event):void {
				trace("AppModel:generateThumbnail - thumbnail generated", e.target.data);
			})
		}
		/* ====================== USER FUNCTIONS =========================== */
		
		/**
		 * Creates a new User for a given domain. 
		 * @param username	The username of the new user
		 * @param password	The password
		 * @param domain	The domain of the user (normally system? need to work on this TODO)
		 * @param details	An object of meta data described for the user (as per r_user doc type)
		 * @param callback	The function to call when the creation is complete
		 * @param email		The email address of the user (opt)
		 */
		public function createUser(username:String,
								   password:String,
								   email:String,
								   domain:String,
								   details:Object,
								   callback:Function):void {
			
			var transaction:Transaction_CreateUser = new Transaction_CreateUser(
															username,
															password,
															email,
															domain,
															details,
															_connection,
															callback);
		}
		
		/**
		 * Deletes a user from a given domain. 
		 * @param username	The username of the user to deltee
		 * @param domain	The domain of the user
		 * @param callback	Function to call when request is completed
		 * 
		 */		
		public function deleteUser(username:String, domain:String, callback:Function):void {
			
			var transaction:Transaction_DeleteUserFromSystem = new Transaction_DeleteUserFromSystem(username, domain, callback, _connection);
			
			// user.destroy :domain system :user g
//			trace("- Deleting user database call", username, domain);
//			var args:Object = new Object();
//			var baseXML:XML = _connection.packageRequest('user.destroy',args,true);
//			baseXML.service.args["user"] = username;
//			baseXML.service.args["domain"] = domain;
//			if(_connection.sendRequest(baseXML,callback)) {
//				//All good
//			} else {
//				Alert.show("Could not delete user");
//				trace("Could not delete user");
//			}
		}
			
		/**
		 * Suspends the user by removing the USER role 
		 * @param username	The name of the user to suspend
		 * @param domain	The domain of the user to suspend
		 * @param callback	The function to call after the request is completed
		 * 
		 */		
		public function suspendUser(username:String, domain:String, callback:Function):void {
			// THE CORRECT WAY TO DO IT, BUT NEED TO CHANGE THE USER ROLE TO ANOTHER ROLE AND MOVE
			// ALL THE PERMISSIONS ACROSS
			// Mediaflux - actor.revoke :name system:johnsmith :role system-administrator -type role :type user
			
//			
//			// Quick fix
//			// We just change the password
			var blah:Transaction_SuspendUser = new Transaction_SuspendUser(username, domain, callback, _connection);
//			
		}
		
		public function unsuspendUser(username:String, domain:String, callback:Function):void {
			// actor.grant :type user :name system:johnsmith :role userid -type role
			var blah:Transaction_UnsuspendUser = new Transaction_UnsuspendUser(username, domain, callback, _connection);
		}
		
		
		//Gets the details for the current user
		public function getUserDetails(username:String, domain:String, callback:Function):void {
			trace("Getting User Details");
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('user.get',args,true);
			baseXML.service.args["user"] = username;
			baseXML.service.args["domain"] = domain;
			_connection.sendRequest(baseXML,callback);
		}
		
		//Updates the users profile details
		public function saveProfile(details:Object,username:String,callback:Function):void {
			trace("- Saving Profile");
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('user.set',args,true);
			baseXML.service.args["user"] = username;
			baseXML.service.args["domain"] = "system";
			baseXML.service.args["email"] = details.meta_email;
			
			if(details.meta_firstname == "") 	details.meta_firstname = " ";
			if(details.meta_lastname == "") 	details.meta_lastname = " ";
			if(details.meta_email == "") 		details.meta_email = " ";
			if(details.meta_initial == "") 		details.meta_initial = " ";
			if(details.meta_organisation == "") details.meta_organisation = " ";
			if(details.meta_url == "") 			details.meta_url = " ";
			if(details.meta_tel_business == "") details.meta_tel_business = " ";
			if(details.meta_tel_home == "") 	details.meta_tel_home = " ";
			if(details.meta_tel_mobile == "") 	details.meta_tel_mobile = " ";
			if(details.meta_Address_1 == "") 	details.meta_Address_1 = " ";
			if(details.meta_Address_2 == "") 	details.meta_Address_2 = " ";
			if(details.meta_Address_3 == "") 	details.meta_Address_3 = " ";
			
			baseXML.service.args["meta"]["r_user"]["firstname"] = details.meta_firstname;
			baseXML.service.args["meta"]["r_user"]["lastname"] = details.meta_lastname;
			baseXML.service.args["meta"]["r_user"]["email"] = details.meta_email;
			baseXML.service.args["meta"]["r_user"]["initial"] = details.meta_initial;
			baseXML.service.args["meta"]["r_user"]["organisation"] = details.meta_organisation;
			baseXML.service.args["meta"]["r_user"]["url"] = details.meta_url;
			baseXML.service.args["meta"]["r_user"]["tel_business"] = details.meta_tel_business;
			baseXML.service.args["meta"]["r_user"]["tel_home"] = details.meta_tel_home;
			baseXML.service.args["meta"]["r_user"]["tel_mobile"] = details.meta_tel_mobile;
			baseXML.service.args["meta"]["r_user"]["Address_1"] = details.meta_Address_1;
			baseXML.service.args["meta"]["r_user"]["Address_2"] = details.meta_Address_2;
			baseXML.service.args["meta"]["r_user"]["Address_3"] = details.meta_Address_3;
			_connection.sendRequest(baseXML,callback);
		}
		
		//Gets all users
		public function getUserList(callback:Function):void {
			trace("Getting User List");
			var args:Object = new Object();
			args.domain = "system";
			var baseXML:XML = _connection.packageRequest('user.describe',args,true);
			if(_connection.sendRequest(baseXML,callback)) {
				//All good
			} else {
				Alert.show("Could not get user list");
			}
		}
		
		/**
		 * Changes the password of the currently logged in user 
		 * @param domain		The domain for the currently logged in user
		 * @param newPassword	The new password for this users account
		 * @param callback		The function to call when its completed
		 * 
		 */		
		public function changePassword(domain:String, username:String, newPassword:String, callback:Function):void {
			var transaction:Transaction_ChangePassword = new Transaction_ChangePassword(domain, username, newPassword, callback, _connection);
		}
		
		public function setUserAssetShareCount(username:String, assetID:Number, viaAsset:Number, accessLevel:String, callback:Function):void
		{
			var transaction:Transaction_SetUserAssetShare = new Transaction_SetUserAssetShare(username, assetID, viaAsset, accessLevel, _connection, callback);
			
		}
		
		public function callSuccessful(e:Event):Boolean {
			var dataXML:XML = XML(e.target.data);
			return (dataXML.reply.@type == "result");
		}
		
		public function callFailed(functionName:String, e:Event):Boolean {
			var dataXML:XML = XML(e.target.data);
			if(dataXML.reply.@type == "result") {
				trace(functionName + ": SUCCESS", e.target.data);
			} else {
				trace(functionName + ": FAILED", e.target.data);
			}
			return (dataXML.reply.@type != "result");
		}
		
		/**
		 * Get the data out of the response 
		 * @param e
		 * @return 
		 * 
		 */
		public function getData(functionName:String, e:Event):XML {
			var dataXML:XML = XML(e.target.data);
			if(dataXML.reply.@type != "result") {
				trace(functionName + ": FAILED", e.target.data, functionName);
				
				
//				AppController.layout.header.mything.text += e.target.data;
				return null;
			}
//			trace(functionName + ": SUCCESS", e.target.data);
			return dataXML;
		}
		
		/* =============================================== NOTIFICATIONS =============================================== */
		/**
		 * Sends a notification to users who have access to this media asset
		 * @param mediaID 	The ID of the media that was affected. e.g. If someone comments on an image, this is the image's ID
		 * @param type		The type of notification (see Notification_Model)
		 * @param assetID	(opt) The ID of the asset that as added/changed (e.g. the ID of the comment)
		 * 
		 */		
		public function sendNotification(mediaID:Number, type:String, assetID:Number = 0):void {
			var transaction:Transaction_Notification = new Transaction_Notification(_connection);
			transaction.sendNotification(mediaID, type, assetID);
		}
		
		/**
		 * Get all the notifications on the system (that the current user can access) 
		 * @param callback
		 * 
		 */
		public function getNotifications(callback:Function):void {
			var args:Object = new Object();
			args.where = "class>='recensio:base/notification'";
			args.action = "get-meta";
			args['get-related-meta'] = true;
			var baseXML:XML = _connection.packageRequest('asset.query', args, true);
			_connection.sendRequest(baseXML, callback);
		}
		
		/**
		 * Removes a notification for a user 
		 * @param notificationID
		 * 
		 */
		public function deleteNotification(notificationID:Number):void {
			var transaction:Transaction_Notification = new Transaction_Notification(_connection);
			transaction.deleteNotificationForUser(notificationID);
		}
		
		/* =============== SEND AN EMAIL THROUGH MEDIADFLUX ================ */
		public function sendEmail(emailAddress:String, subject:String, body:String):void {
			var baseXML:XML = _connection.packageRequest("mail.send", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.to = emailAddress;
			argsXML.subject = subject;
			argsXML.body = body;
			_connection.sendRequest(baseXML, mailSent);
		}
		
		private function mailSent(e:Event):void {
			trace("mail sent");
			var data:XML;
			if((data = AppModel.getInstance().getData("sending mail", e)) == null) {
				trace("Done: MAIL FAILED TO SEND");
				return;
			} else {
				trace("Done: MAIL SENT SUCCESSFULLY");
				return;
			}
		}
		/* =============== END OF SEND AN EMAIL THROUGH MEDIADFLUX ================ */
		
		/* =============================================== ERA STUFF =============================================== */
		/**
		 * Make a new ERA project 
		 * @param day			The day the era project is due
		 * @param month			The month the era project is due
		 * @param year			The year the era project is due
		 * @param packageSize	The size of the package for era
		 * @param callback		
		 * 
		 */
		public function makeERAProject(day:String, month:String, year:String, packageSize:String, callback:Function):void {
			var newERA:Transaction_CreateERAProject = new Transaction_CreateERAProject(day, month, year, packageSize, _connection, callback);
		}
		public function updateERAProject(eraProjectID:Number, day:String, month:String, year:String, packageSize:String, callback:Function):void {
			var updateERA:Transaction_UpdateERAProject = new Transaction_UpdateERAProject(eraProjectID, day, month, year, packageSize, _connection, callback);
		}
		public function deleteERAProject(eraProjectID:Number, callback:Function):void {
			var deleteERA:Transaction_DeleteERAProject = new Transaction_DeleteERAProject(eraProjectID, _connection, callback);
		}
		
		public function getERAProjects(callback:Function):void {
			var allProjects:Transaction_GetERAProjects = new Transaction_GetERAProjects(_connection, callback);
		}
		
		/**
		 * Get all the users on the system 
		 * @param callback
		 * 
		 */
		public function getERAUsers(callback:Function):void {
			var getAllUsers:Transaction_GetAllUsers = new Transaction_GetAllUsers(_connection, callback);
		}
		
		
		/**
		 * Get all the users on the system that have a specific role 
		 * @param role					The role to search for
		 * @param year					The year the 
		 * @param gotUsersWithRole
		 * 
		 */
		public function getERAUsersWithRole(role:String, year:String, callback:Function):void {
			var getUsersWithRole:Transaction_GetUsersWithRole = new Transaction_GetUsersWithRole(role, year, _connection, callback);
		}
		
		public function addRoleToERAUser(userData:Model_ERAUser, role:String, year:String, roleComponent:ERARole, callback:Function):void {
			var addRoleToUser:Transaction_AddRoleToUser = new Transaction_AddRoleToUser(userData, role, year, roleComponent, _connection, callback);
		}
		public function removeRoleFromERAUser(username:String, role:String, roleComponent:ERARole, callback:Function):void {
			var removeRoleFromUser:Transaction_RemoveRoleFromUser = new Transaction_RemoveRoleFromUser(username, role, AppController.currentEraProject.year, roleComponent, _connection, callback);
		}
		
		public function createERAUser(qutUsername:String, firstName:String, lastName:String, callback:Function):void {
			var createERAUser:Model.Transactions.ERAProject.Transaction_CreateERAUser = new Transaction_CreateERAUser(qutUsername, firstName, lastName, _connection, callback);
		}
		public function deleteERAUser(qutUsername:String, callback:Function):void {
			var deleteERAUser:Transaction_DeleteERAUser = new Transaction_DeleteERAUser(qutUsername, _connection, callback);
		}
		public function getERAUser(username:String, callback:Function):void {
			var getERAUser:Transaction_GetUser = new Transaction_GetUser(username, _connection, callback);
		}
		public function changeERAUserPassword(newPassword:String, callback:Function):void {
			var username:String = Auth.getInstance().getUsername();
			var oldPassword:String = Auth.getInstance().getPassword();
			var whatever:Transaction_ERAChangeUserPassword = new Transaction_ERAChangeUserPassword(username, oldPassword, newPassword, _connection, callback);
//			var changeUserERAPassword:Transaction_ChangeERAPassword = Transaction_ChangeERAPassword(username, password, newPassword, _connection, callback);  
		}
		public function getAllERACases(eraID:Number, callback:Function):void {
			var getAllERACases:Transaction_GetAllCases = new Transaction_GetAllCases(eraID, _connection, callback);
		}
		
		public function createERACase(year:String,
									  rmCode:String, 
									  title:String,
									  fileCount:Number,
									  researcherArray:Array,
									  qutSchool:String, 
									  forArray:Array,
									  categoryArray:Array,
									  productionManagerUsernameArray:Array,
									  productionTeamUsernameArray:Array,
									  callback:Function):void {
			var createERACase:Transaction_CreateERACase = new Transaction_CreateERACase(AppController.currentEraProject.base_asset_id, year, rmCode, title, fileCount, researcherArray, qutSchool, forArray, categoryArray, productionManagerUsernameArray, productionTeamUsernameArray, _connection, callback);
		}
		public function updateERACase(caseID:Number, rmCode:String, title:String, fileCount:Number, researcherArray:Array, qutSchool:String, forArray:Array, categoryArray:Array, productionManagerArray:Array, productionTeamArray:Array, callback:Function):void {
			var updateERACase:Transaction_UpdateERACase = new Transaction_UpdateERACase(AppController.currentEraProject.year, caseID, rmCode, title, fileCount, researcherArray, qutSchool, forArray, categoryArray, productionManagerArray, productionTeamArray, _connection, callback); 
		}
		public function deleteERACase(caseID:Number, callback:Function):void {
			var deleteERACase:Transaction_DeleteERACase = new Transaction_DeleteERACase(caseID, _connection, callback);
		}
		
		public function createRoomInCase(caseID:Number, roomType:String, callback:Function):void {
			var createRoomInCase:Transaction_CreateRoom = new Transaction_CreateRoom(AppController.currentEraProject.year, caseID, roomType, _connection, callback);
		}
		public function getAllRoomsInCase(caseID:Number, callback:Function):void {
			var getAllRoomsInCase:Transaction_GetAllRooms = new Transaction_GetAllRooms(caseID, _connection, callback);
		}
		public function createERALogItem(roomID:Number, type:String, title:String, description:String, evidenceItem:EvidenceItem, callback:Function):void {
			var createERALogItem:Transaction_CreateERALogItem = new Transaction_CreateERALogItem(AppController.currentEraProject.year, roomID, type, title, description, evidenceItem, _connection, callback);
		}
		public function deleteERALogItem(logItem:Model_ERALogItem, callback:Function):void {
			var deleteERALogItem:Transaction_DeleteERALogItem = new Transaction_DeleteERALogItem(logItem, _connection, callback);
		}
		public function updateLogItemBooleanValue(year:String, roomID:Number, logItemID:Number, elementName:String, value:Boolean, evidenceItem:EvidenceItem, callback:Function):void {
			var updateLogItemBooleanValue:Transaction_UpdateLogItemBooleanValue = new Transaction_UpdateLogItemBooleanValue(year, roomID, logItemID, elementName, value, evidenceItem, _connection, callback);
		}
		public function getAllERALogItemsInRoom(roomID:Number, callback:Function):void {
			var getERALogItems:Transaction_GetAllLogItems = new Transaction_GetAllLogItems(roomID, _connection, callback);
		}
		public function getAllERAFilesInRoom(roomID:Number, callback:Function):void {
			var getERAFiles:Transaction_GetAllFilesInRoom = new Transaction_GetAllFilesInRoom(roomID, _connection, callback);
		}
		public function uploadERAFile(evidenceRoomID:Number, forensicLabID:Number, logItemID:Number, type:String, title:String, description:String, version:Number, fileReference:FileReference, evidenceItem:EvidenceItem, ioErrorCallback:Function, progressCallback:Function, completeCallback:Function):void {
			var uploadERAFile:Transaction_UploadERAFile = new Transaction_UploadERAFile(AppController.currentEraProject.year, evidenceRoomID, forensicLabID, logItemID, type, title, description, version, fileReference, evidenceItem, _connection, ioErrorCallback, progressCallback, completeCallback);
		}
		public function uploadERAFileVersion(roomID:Number, oldFileID:Number, originalFileID:Number, type:String, title:String, description:String, fileReference:FileReference, ioErrorCallback:Function, progressCallback:Function, completeCallback:Function):void {
			var uploadERAVersion:Transaction_UploadFileVersion = new Transaction_UploadFileVersion(AppController.currentEraProject.year, roomID, oldFileID, originalFileID, type, title, description, fileReference, _connection, ioErrorCallback, progressCallback, completeCallback);
		}
		public function createF4V(videoFileID:Number):void {
			var createF4V:Transaction_CreateF4V = new Transaction_CreateF4V(videoFileID, _connection);
		}
		
		public function getVideoSegment(videoID:Number, startTime:Number, length:Number, callback:Function):void {
			var getVideoSegment:Transaction_GetVideoSegment = new Transaction_GetVideoSegment(videoID, startTime, length, _connection, callback);
		}
		public function getAudioSegment(audioID:Number, startTime:Number, length:Number, callback:Function):void {
			var getVideoSegment:Transaction_GetAudioSegment = new Transaction_GetAudioSegment(audioID, startTime, length, _connection, callback);
		}
		public function getERAFile(fileID:Number, callback:Function):void {
			var getERAFile:Transaction_GetFile = new Transaction_GetFile(fileID, _connection, callback);
		}
		public function moveAllERAFiles(fileIDArray:Array, fromRoomID:Number, toRoomID:Number, toRoomType:String, callback:Function):void {
			var moveERAFiles:Transaction_MoveAllFiles= new Transaction_MoveAllFiles(fileIDArray, fromRoomID, toRoomID, toRoomType, _connection, callback);
		}
		public function moveERAFile(fileID:Number, fromRoomID:Number, toRoomID:Number, toRoomType:String, callback:Function, sendNotification:Boolean=true):void {
			var moveERAFile:Transaction_MoveFile = new Transaction_MoveFile(fileID, fromRoomID, toRoomID, toRoomType, sendNotification, _connection, callback);
		}
		public function updateERAFileTemperature(fileID:Number, hot:Boolean, callback:Function):void {
			var updateERAFile:Transaction_UpdateFileTemperature = new Transaction_UpdateFileTemperature(fileID, hot, _connection, callback);
		}
		public function updateERAFileCheckOutStatus(fileID:Number, checkedOut:Boolean, callback:Function):void {
			var updateERAFile:Transaction_UpdateCheckoutStatus = new Transaction_UpdateCheckoutStatus(fileID, checkedOut, Auth.getInstance().getUsername(), _connection, callback);
		}
		public function updateFileLockOutStatus(roomID:Number, notificationType:String, caseID:Number, fileID:Number, callback:Function):void {
			var updateFile:Transaction_UpdateFileLockOutStatus = new Transaction_UpdateFileLockOutStatus(AppController.currentEraProject.year, roomID, Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName, notificationType, caseID, fileID, Auth.getInstance().getUsername(), _connection, callback);
		}
			
		public function createERAConversation(objectID:Number, roomID:Number, inReplyToID:Number, text:String, callback:Function):void {
			var createERAConversation:Transaction_CreateConversation = new Transaction_CreateConversation(AppController.currentEraProject.year, objectID, roomID, inReplyToID, text, _connection, callback);
		}
		public function getAllConversationOnOject(objectID:Number, roomID:Number, callback:Function):void {
			var getConverstion:Transaction_GetAllConversation = new Transaction_GetAllConversation(AppController.currentEraProject.year, objectID, roomID, _connection, callback);
		}
		
		public function getAllNotifications(readStatus:String, callback:Function):void {
			var getAllNotifications:Transaction_GetAllNotifications = new Transaction_GetAllNotifications(readStatus, _connection, callback);
		}
		public function createERANotification(year:String, roomID:Number, username:String, firstName:String, lastName:String, type:String, caseID:Number=0, fileID:Number=0, commentID:Number=0) {
			var createERANotification:Transaction_CreateERANotification = new Transaction_CreateERANotification(year, roomID, username, firstName, lastName, type, _connection, caseID, fileID, commentID);
		}
		public function deleteRelatedERANotifications(objectID:Number, callback:Function):void {
			var deleteNotifications:Transaction_DeleteRelatedNotifications = new Transaction_DeleteRelatedNotifications(objectID, callback, _connection);
		}

		public function updateNotificationReadStatus(notificationID:Number, readStatus:Boolean, callback:Function):void {
			trace('yoyo yo', readStatus ? 'yes' : 'no');
			var updateNotificationReadStatus:Transaction_UpdateNotificationReadStatus = new Transaction_UpdateNotificationReadStatus(
				notificationID,
				readStatus,
				_connection,
				callback);
		}
		public function sendMailFromNotification(notificationID:Number):void {
			trace("sending email");
			var sendMail:Transaction_SendMailFromNotification = new Transaction_SendMailFromNotification(_connection);
			sendMail.sendMailFromNotification(notificationID);
		}			
		
		public function removeUserFromCase(caseID:Number, removeUsername:String, callback:Function):void {
			var removeUserFromCase:Transaction_RemoveUserFromCase = new Transaction_RemoveUserFromCase(caseID, removeUsername, _connection, callback);
		}
		
		public function recoverPassword(username:String, callback:Function):void {
			var transaction:Transaction_RecoverPassword = new Transaction_RecoverPassword(username, _connection, callback);
		}
		
		public function getResearchersInSchools(schoolsArray:Array, callback:Function):void {
			var transaction:Transaction_GetResearchersInSchools = new Transaction_GetResearchersInSchools(schoolsArray, _connection, callback);
		}
		public function getCasesInExhibition(callback:Function):void {
			var transaction:Transaction_GetCasesInExhibition = new Transaction_GetCasesInExhibition(_connection, callback);
		}
		public function getCasesNotCollection(callback:Function):void {
			var transaction:Transaction_GetCasesNotCollected = new Transaction_GetCasesNotCollected(_connection, callback);
		}
		public function getCasesWithoutEvidence(callback:Function):void {
			var transaction:Transaction_GetCasesWithoutEvidence = new Transaction_GetCasesWithoutEvidence(_connection, callback);
		}
		public function getCheckedInOutFilesPerCase(callback:Function):void {
			var transaction:Transaction_GetCheckedInOutFilesPerCase = new Transaction_GetCheckedInOutFilesPerCase(AppController.currentEraProject.year, _connection, callback);
		}
		public function getCasesWithEvidenceUnderReview(callback:Function):void {
			var transaction:Transaction_GetCasesWithEvidenceUnderReview = new Transaction_GetCasesWithEvidenceUnderReview(AppController.currentEraProject.year, _connection, callback);
		}
		public function getCasesResearchersNoInvolvement(callback:Function):void {
			var transaction:Transaction_GetResearcherInvolvement = new Transaction_GetResearcherInvolvement(AppController.currentEraProject.year, _connection, callback);
		}
		public function changeEmailOptions(role:String, username:String, enabled:Boolean, callback:Function):void {
			var transaction:Transaction_ChangeEmailOptions = new Transaction_ChangeEmailOptions(AppController.currentEraProject.base_asset_id, role, username, enabled, _connection, callback);
		}
		public function changeEmailOptionsUserArray(role:String, usernameArray:Array, callback:Function) {
			var transaction:Transaction_ChangeEmailOptionsUserArray = new Transaction_ChangeEmailOptionsUserArray(AppController.currentEraProject.base_asset_id, role, usernameArray, _connection, callback);
		}
		public function getERAUserRoles(username:String, callback:Function):void {
			var transaction:Transaction_GetERAUserRoles = new Transaction_GetERAUserRoles(username, _connection, callback);
		}
		public function downloadExhibitionFiles(caseID:Number, downloaderUsername:String, callback:Function):void {
			var transaction:Transaction_DownloadExhibitionFiles = new Transaction_DownloadExhibitionFiles(caseID, downloaderUsername, _connection, callback);
		}
		public function eraChangeFileCountForCase(caseID:Number, fileCount:Number, callback:Function):void {
			var transaction:Transaction_ChangeFileCount = new Transaction_ChangeFileCount(caseID, fileCount, _connection, callback);
		}
	}
		
}

// Singleton Enforcer Class
class SingletonEnforcer {
	
}