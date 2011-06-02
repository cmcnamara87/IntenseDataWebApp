package Model.Objects
{
	public class Annotations
	{
		
		/**
		 * Saves a new pen annotation. 
		 * @param mediaAssetID	The ID of the media asset which the annotation is on
		 * @param path			The string that contains the path of the pen annotations (in XML)
		 * @param text			The text to be associated with the annotation
		 * @param callback		The function to call when the saving is complete.
		 * 
		 */
		public static function saveNewPenAnnotation(mediaAssetID:Number, path:String, text:String, callback:Function):void {
			trace("- App Model: Saving Pen annotation...");	
			
			var baseXML:XML = setupAnnotation(mediaAssetID);
			
			// Set All of the annotations data
			baseXML.service.args["meta"]["r_annotation"]["path"] = path;
			if(text != "") {
				baseXML.service.args["meta"]["r_annotation"]["text"] = text;
			}
			
			// This annotation is a 'Annotation' annotation, lol, not a comment
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.ANNOTATION_PEN_TYPE_ID;
			
			
			// Try and save, then call the callback.
			if(_connection.sendRequest(baseXML, callback)) {
				trace("- App Model: Annotation Saved");
				//All good
			} else {
				Alert.show("Could not save annotation");
			}
			
		}
		
		public static function saveNewHighlightAnnotation(mediaAssetID:Number, xCoor:Number, yCoor:Number, page1:Number, startTextIndex:Number, 
												   endTextIndex:Number, text:String, callback:Function):void {
			
			var baseXML:XML = setupAnnotation(mediaAssetID);
			
			// Set All of the annotations data
			baseXML.service.args["meta"]["r_annotation"]["x"] = xCoor;
			baseXML.service.args["meta"]["r_annotation"]["y"] = yCoor;
			baseXML.service.args["meta"]["r_annotation"]["start"] = startTextIndex;
			baseXML.service.args["meta"]["r_annotation"]["end"] = endTextIndex;
			baseXML.service.args["meta"]["r_annotation"]["text"] = text;
			baseXML.service.args["meta"]["r_annotation"]["lineNum"] = page1; // We are storing the page number, in the lin num variable
			
			// This annotation is a 'Annotation' annotation, lol, not a comment
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.ANNOTATION_HIGHLIGHT_TYPE_ID + "";
			
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
		public static function saveNewBoxAnnotation(	mediaAssetID:Number, xCoor:Number, yCoor:Number,
												annotationWidth:Number, annotationHeight:Number,
												startTime:Number, endTime:Number,
												annotationText:String, callback:Function):void {
			
			trace("- App Model: Saving box annotation...");
			
			var baseXML:XML = setupAnnotation(mediaAssetID);
			
			// Set All of the annotations data
			baseXML.service.args["meta"]["r_annotation"]["x"] = xCoor;
			baseXML.service.args["meta"]["r_annotation"]["y"] = yCoor;
			baseXML.service.args["meta"]["r_annotation"]["width"] = Math.round(annotationWidth);
			baseXML.service.args["meta"]["r_annotation"]["height"] = Math.round(annotationHeight);
			baseXML.service.args["meta"]["r_annotation"]["start"] = startTime;
			baseXML.service.args["meta"]["r_annotation"]["end"] = endTime;
			baseXML.service.args["meta"]["r_annotation"]["text"] = annotationText;
			
			// This annotation is a 'Annotation' annotation, lol, not a comment
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.ANNOTATION_BOX_TYPE_ID + "";
			
			// Try and save, then call the callback.
			if(_connection.sendRequest(baseXML, function(e:Event):void {
				setClassAndCreateNotification(mediaAssetID, e, callback);
			})) {
				trace("- App Model: Annotation Saved");
				//All good
			} else {
				Alert.show("Could not save annotation");
			}
		}
		
		/* ================================== HELPER FUNCTIONS ========================================== */
		private static function setupAnnotation(mediaAssetID:Number):XML {
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
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			
			return baseXML;
		}
		
		private static function setClassAndCreateNotification(mediaAssetID:Number, e:Event, callback:Function):void {
			var dataXML:XML = XML(e.target.data);
			if(dataXML.reply.@type != "result") {
				callback(e);
			} else {
				AppModel.getInstance().sendNotification(mediaAssetID, Model_Notification.ANNOTATION_ON_MEDIA, dataXML.reply.result.id);
				AppModel.getInstance().setAnnotationClassForID(dataXML.reply.result.id, function(event:Event):void {
					callback(e);	
				});
			}
		}
	}
}