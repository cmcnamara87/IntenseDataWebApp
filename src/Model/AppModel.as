package Model {
	
	import Controller.Dispatcher;
	import Controller.Utilities.Auth;
	
	import Model.Transactions.Transaction_ChangePassword;
	import Model.Transactions.Transaction_CreateUser;
	import Model.Transactions.Transaction_GetAccess;
	import Model.Transactions.Transaction_GetCollections;
	import Model.Transactions.Transaction_GetThisCollectionsMediaAssets;
	import Model.Transactions.Transaction_SaveCollection;
	import Model.Transactions.Transaction_SaveNewComment;
	import Model.Transactions.Transaction_SetAccess;
	import Model.Transactions.Transaction_SuspendUser;
	import Model.Transactions.Transaction_UnsuspendUser;
	import Model.Utilities.Connection;
	
	import View.Element.Comment;
	import View.components.Comments.NewComment;
	import View.components.Sharing.SharingPanel;
	
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
			var args:Object = new Object();
			
			args.where = "namespace = recensio and r_base/active = true and class >= 'recensio:base/resource/annotation' " +
				"and related to{is_child} (id="+assetID+")";
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
		
		public function changeAccess(collectionID:Number, username:String, domain:String, access:String, callback:Function=null):void {
			var args:Object = new Object();
			
			trace("Changing access on collection", collectionID);
			trace("Access for", domain, username, access);
			var baseXML:XML;
			
			if(access == SharingPanel.NOACCESS) {
				trace("Should be revoking access");
				// We want to revoke a users access to this asset
				baseXML = _connection.packageRequest('asset.acl.revoke', args, true);
				baseXML.service.args.acl.id = collectionID;
				baseXML.service.args.acl.actor = domain + ":" + username;
				baseXML.service.args.acl.actor.@type = "user";
				// Update all the related assets
				baseXML.service.args.related = true;
			} else {
				trace("Should be granting access");
				// We are granting access to the asset for a user
				// Example mediaflux statement asset.acl.grant :acl < :id 1718 :actor system:coke -type user :access read-write >
				baseXML = _connection.packageRequest('asset.acl.grant', args, true);
				baseXML.service.args.acl.id = collectionID;
				baseXML.service.args.acl.actor = domain + ":" + username;
				baseXML.service.args.acl.actor.@type = "user";
				baseXML.service.args.acl.access = access;
				// Update all the related assets
				baseXML.service.args.related = true;
			}
			
			// Send the connection
			if(_connection.sendRequest(baseXML, callback)) {
				//All good
			} else {
				Alert.show("Could not change access properties");
			}
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
		/**
		 * Saves a new Box Annotation. 
		 * @param mediaAssetID	The ID of the media asset, the annotation is on
		 * @param percentX		The x (top left) of the annotation box (in relation to the assets size, e.g. 0.5 for 50%)
		 * @param percentY		The y (top right) of the annotation box (same as above)
		 * @param percentWidth	The width of the annotation box (50% is now 50 not, 0.5)
		 * @param percentHeight The height of the annotation box
		 * @param startTime		The time where the box first appears
		 * @param endTime		The time where the box disappears
		 * @param annotationText	The text that is part of the annotation
		 * @param callback			The function to call when the anntoation is saved
		 * 
		 */		
		public function saveNewBoxAnnotation(	mediaAssetID:Number, percentX:Number,percentY:Number,
											percentWidth:Number, percentHeight:Number,
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
			baseXML.service.args["meta"]["r_annotation"]["x"] = percentX;
			baseXML.service.args["meta"]["r_annotation"]["y"] = percentY;
			baseXML.service.args["meta"]["r_annotation"]["width"] = Math.round(percentWidth);
			baseXML.service.args["meta"]["r_annotation"]["height"] = Math.round(percentHeight);
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
		public function setAnnotationClassForID(annotationID:Number):void {
			trace("- App Model: Setting Annotation Class");
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.class.add',args,true);
			baseXML.service.args["scheme"] = "recensio";
			baseXML.service.args["class"] = "base/resource/annotation";
			baseXML.service.args["id"] = annotationID;
			_connection.sendRequest(baseXML,null);
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
			
			if(_connection.sendRequest(baseXML, null)) {
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
		public function setCollectionClass(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			if (dataXML.reply.@type == "result") {
				trace("DONG DONG");
				trace(dataXML.reply.result.id);
				var args:Object = new Object();
				var baseXML:XML = _connection.packageRequest('asset.class.add',args,true);
				baseXML.service.args["scheme"] = "recensio";
				baseXML.service.args["class"] = "base/resource/collection";
				baseXML.service.args["id"] = dataXML.reply.result.id;
				_connection.sendRequest(baseXML,null);
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
			baseXMLUpdate.service.args["meta"]["r_resource"]["title"] = assetData.meta_title;
			baseXMLUpdate.service.args["meta"]["r_resource"]["description"] = assetData.meta_description;
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"] = "";
			baseXMLUpdate.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="Subject">'+assetData.meta_subject+'</property>'));
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
		
		// Deletes an asset
		public function deleteAsset(assetID:Number):void {
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
			baseXML.service.args["id"] = assetID;
			if(_connection.sendRequest(baseXML,assetDeleted)) {
				//All good
			} else {
				Alert.show("Could not delete asset");
			}
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
		
		// Deletes an annotation
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
		
		// Deletes a comment
		public function deleteComment(assetID:Number):void {
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
			baseXML.service.args["id"] = assetID;
			if(_connection.sendRequest(baseXML,null)) {
				//All good
			} else {
				Alert.show("Could not delete comment");
			}
		}
		
		// Debug callback for functions which do not have their own callback
		private function debugCallback(e:Event):void {
			trace(e.target.data);
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
			
			// Build up the collection object
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			baseXML.service.args["meta"]["r_base"]["obtype"] = "10";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			// Set creator as the current user
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_base"].@id = 2;
			baseXML.service.args["meta"]["r_resource"]["title"] = collectionTitle;
			
			baseXML.service.args["meta"]["r_media"].@id = 4;
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			baseXML.service.args["related"] = "";
			
			// Link the collection to all the assets on the shelf.
			for(var i:Number = 0; i < shelfAssets.length; i++) {
				baseXML.service.args["related"].appendChild(XML('<to relationship="has_child">' + (shelfAssets[i] as Model_Media).base_asset_id + '</to>'));
			}
			
			// Set the description, to be the number of items in the collection
			baseXML.service.args["meta"]["r_resource"]["description"] = shelfAssets.length;
			
			if(_connection.sendRequest(baseXML,callback)) {
				trace("SENDING NEW COLLECTION");
				//All good
			} else {
				Alert.show("Could not save collection");
			}
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
		public function deleteCollection(assetID:Number, callback:Function):void {
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.destroy',args,true);
			baseXML.service.args["id"] = assetID;
			if(_connection.sendRequest(baseXML, callback)) {
				//All good
			} else {
				Alert.show("Could not delete collection");
			}
		}
		
		
		
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
				if(asset.annotationType == Model_Commentary.ANNOTATION_BOX_TYPE_ID || asset.annotationType == Model_Commentary.ANNOTATION_PEN_TYPE_ID) {
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
			var useID:Boolean = true;
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create',args,true);
			if(useID) {
				baseXML = _connection.packageRequest('id.asset.create',args,true);
			}
			baseXML.service.args["meta"]["r_base"].@id = "2";
			baseXML.service.args["meta"]["r_base"]["obtype"] = "7";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			baseXML.service.args["meta"]["r_base"]["properties"] = "";
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="Subject">'+data.meta_subject+'</property>'));
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="Keywords">'+data.meta_keywords+'</property>'));
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="DatePublished">'+data.meta_datepublished+'</property>'));
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="OtherContrib">'+data.meta_othercontrib+'</property>'));
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="SponsorFunder">'+data.meta_sponsorfunder+'</property>'));
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkSubType">'+data.meta_creativeworksubtype+'</property>'));
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="CreativeWorkType">'+data.meta_creativeworktype+'</property>'));
			baseXML.service.args["meta"]["r_base"]["properties"].appendChild(XML('<property name="AuthorCreator">'+data.meta_BLBK+'</property>'));
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			baseXML.service.args["meta"]["r_resource"].@id = "3";
			baseXML.service.args["meta"]["r_resource"]["title"] = data.meta_title;
			baseXML.service.args["meta"]["r_resource"]["description"] = data.meta_description;
			baseXML.service.args["meta"]["r_media"].@id = "4";
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			trace(baseXML);
			if(_connection.uploadFile(data.file,baseXML,debugCallback)) {
				//All good
			} else {
				Alert.show("Could not save asset");
			}
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
			// user.destroy :domain system :user g
			trace("- Deleting user database call", username, domain);
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('user.destroy',args,true);
			baseXML.service.args["user"] = username;
			baseXML.service.args["domain"] = domain;
			if(_connection.sendRequest(baseXML,callback)) {
				//All good
			} else {
				Alert.show("Could not delete user");
				trace("Could not delete user");
			}
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
		public function changePassword(domain:String, newPassword:String, callback:Function):void {
			var transaction:Transaction_ChangePassword = new Transaction_ChangePassword(domain, newPassword, callback, _connection);
		}
	}
		
}

// Singleton Enforcer Class
class SingletonEnforcer {
	
}