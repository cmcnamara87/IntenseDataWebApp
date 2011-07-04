package Model {
	
	import Controller.Dispatcher;
	import Controller.Utilities.Auth;
	
	import Model.Transactions.Access.Transaction_ChangeAccess;
	import Model.Transactions.Access.Transaction_CopyAccess;
	import Model.Transactions.Access.Transaction_CopyCollectionAccess;
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
	import Model.Transactions.Transaction_SaveCollection;
	import Model.Transactions.Transaction_SaveNewComment;
	import Model.Transactions.Transaction_SetAccess;
	import Model.Transactions.Transaction_SuspendUser;
	import Model.Transactions.Transaction_UnsuspendUser;
	import Model.Utilities.Connection;
	
	import View.Element.Comment;
	import View.components.Panels.Comments.NewComment;
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
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
		public function getThisAssetsCommentary(assetID:Number, callback:Function):void {
			trace("AppModel getThisAssetsCommentary: Getting Commentary for Asset", assetID);
			
			var args:Object = new Object();
			
			args.where = "namespace = recensio and r_base/active = true and class >= 'recensio:base/resource/annotation' " +
				"and related to{is_child} (id="+assetID+")";
			
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
		public function saveNewComment(commentText:String, commentParentID:Number, 
									   replyingToID:Number,
									   newCommentObject:NewComment, callback:Function):void {
			var saveCommentTransaction:Transaction_SaveNewComment = new Transaction_SaveNewComment(_connection, commentText, commentParentID, replyingToID,
																									newCommentObject, callback);
		}
		
		// DEKKERS COMMENT FUNCTION, saveNewComment is my comment function
		// Saves a comment (reply, new or updated comment)
		public function saveComment(assetData:Object):void {
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
		}
		
		/**
		 * Saves a new pen annotation. 
		 * @param mediaAssetID	The ID of the media asset which the annotation is on
		 * @param path			The string that contains the path of the pen annotations (in XML)
		 * @param text			The text to be associated with the annotation
		 * @param callback		The function to call when the saving is complete.
		 * 
		 */
		public function saveNewPenAnnotation(mediaAssetID:Number, path:String, text:String, callback:Function):void {
			trace("- App Model: Saving Pen annotation...");	
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			
			// Set the annotations parent media asset
			baseXML.service.args["related"]["to"] = mediaAssetID;
			baseXML.service.args["related"]["to"].@relationship = "is_child";
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
		
		public function saveNewHighlightAnnotation(mediaAssetID:Number, xCoor:Number, yCoor:Number, page1:Number, startTextIndex:Number, 
													endTextIndex:Number, text:String, callback:Function):void {
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			
			// Set the annotations parent media asset
			baseXML.service.args["related"]["to"] = mediaAssetID;
			baseXML.service.args["related"]["to"].@relationship = "is_child";
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
		public function saveNewBoxAnnotation(	mediaAssetID:Number, xCoor:Number, yCoor:Number,
											annotationWidth:Number, annotationHeight:Number,
											startTime:Number, endTime:Number,
											annotationText:String, callback:Function):void {
			
			trace("- App Model: Saving box annotation...");
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			
			// Set the annotations parent media asset
			baseXML.service.args["related"]["to"] = mediaAssetID;
			baseXML.service.args["related"]["to"].@relationship = "is_child";
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
		
		public function copyAccess(copyFromID:Number, copyToID:Number):void {
			var transaction:Transaction_CopyAccess = new Transaction_CopyAccess(copyFromID, copyToID, _connection);
		}
		
		// Saves an annotation
		public function saveAnnotation(assetData:Object):void {
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			baseXML.service.args["related"]["to"] = assetData.parentID;
			baseXML.service.args["related"]["to"].@relationship = "is_child";
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
			if(_connection.sendRequest(baseXML,setAnnotationClass)) {
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
					callback(e);
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
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
			baseXML.service.args["id"] = assetID;
			if(_connection.sendRequest(baseXML, callback)) {
				//All good
			} else {
				Alert.show("Could not delete asset");
			}
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
				AppModel.getInstance().assetDestroy(assetID, null);
				return;
			}
			
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.set', args, true);
			baseXML.service.args["id"] = assetID;
			baseXML.service.args["meta"]["r_annotation"]["text"] = "Comment Removed";
			
			if(_connection.sendRequest(baseXML,null)) {
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
			var path:String = '';
			switch(assetType) {
				case Model_Media:
					path = 'asset';
					break;
				case Model_Commentary:
					path = 'asset';
					break;
				case Model_User:
					path = 'user';
					break;
				default:
					path = 'asset';
			}
			var assets:Array = new Array();
			var assetsXML:XMLList = data.reply.result[path];
			for each(var assetXML:XML in assetsXML) {
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
		 * Takes an XML for a collection, and extracts out all the assets and puts them
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
//			}
			baseXML.service.args["meta"]["r_base"].@id = "2";
			baseXML.service.args["meta"]["r_base"]["obtype"] = "7";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			
			if(data.meta_subjects != "" ||
				data.meta_keywords != "" ||
				data.meta_datepublished != "" ||
				data.meta_othercontrib != "" ||
				data.meta_sponsorfunder != "" ||
				data.meta_creativeworksubtype != "" ||
				data.meta_creativeworktype != "" ||
				data.meta_BLBK != "") {
				
				baseXML.service.args["meta"]["r_base"]["properties"] = "";
				
			}
			if(data.meta_subject != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="Subject">'+data.meta_subject+'</property>'));
			}
			if(data.meta_keywords != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="Keywords">'+data.meta_keywords+'</property>'));
			}
			if(data.meta_datepublished != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="DatePublished">'+data.meta_datepublished+'</property>'));
			}
			if(data.meta_othercontrib != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="OtherContrib">'+data.meta_othercontrib+'</property>'));
			}
			if(data.meta_sponsorfunder != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="SponsorFunder">'+data.meta_sponsorfunder+'</property>'));
			}
			if(data.meta_creativeworksubtype != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkSubType">'+data.meta_creativeworksubtype+'</property>'));
			}
			if(data.meta_creativeworktype != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkType">'+data.meta_creativeworktype+'</property>'));
			}
			if(data.meta_BLBK != "") {
				baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="AuthorCreator">'+data.meta_BLBK+'</property>'));
			}
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_resource"].@id = "3";
			baseXML.service.args["meta"]["r_resource"]["title"] = data.meta_title;
			if(data.meta_description) {
				baseXML.service.args["meta"]["r_resource"]["description"] = data.meta_description;
			}
			baseXML.service.args["meta"]["r_media"].@id = "4";
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			trace(baseXML);
			if(_connection.uploadFile(data.file,baseXML, function(e:Event):void {
				trace("Upload complete", e.target.data);
			})) {
				//All good
			} else {
				Alert.show("Could not save asset");
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
	}
		
}

// Singleton Enforcer Class
class SingletonEnforcer {
	
}