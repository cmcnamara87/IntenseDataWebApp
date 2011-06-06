package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Model_Notification;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_Annotations
	{
		
		private var connection:Connection;
		private var mediaID:Number;
		private var annotationID:Number;
		private var callback:Function;
		
		public function Transaction_Annotations(connection:Connection) {
			this.connection = connection;
		}
		
		private function setupAnnotation(mediaAssetID:Number):XML {
			var args:Object = new Object();
			args.namespace = "recensio";
			var baseXML:XML = connection.packageRequest('asset.create',args,true);
			
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
			this.mediaID = mediaAssetID;
			this.callback = callback;
			
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
			sendRequestToDatabase(baseXML);
			
		}
		
		public function saveNewHighlightAnnotation(mediaAssetID:Number, xCoor:Number, yCoor:Number, page1:Number, startTextIndex:Number, 
												   endTextIndex:Number, text:String, callback:Function):void {
			
			this.mediaID = mediaAssetID;
			this.callback = callback;
			
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
			
			sendRequestToDatabase(baseXML);
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
			
			this.mediaID = mediaAssetID;
			this.callback = callback;
			
			var baseXML:XML = setupAnnotation(mediaAssetID);
			
			// Set All of the annotations data
			baseXML.service.args["meta"]["r_annotation"]["path"] = path;
			if(text != "") {
				baseXML.service.args["meta"]["r_annotation"]["text"] = text;
			}
			
			// This annotation is a 'Annotation' annotation, lol, not a comment
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.ANNOTATION_PEN_TYPE_ID;
			
			sendRequestToDatabase(baseXML);
		}
		
		private function sendRequestToDatabase(baseXML:XML):void {
			if(connection.sendRequest(baseXML, setClassAccessNotification)) {
				//All good
			} else {
				Alert.show("Could not save annotation");
				trace("Could not save annotation");
				trace("************************");
			}
		}		
		private function setClassAccessNotification(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			if(dataXML.reply.@type == "result") {
				// The annotation saved successfully
				trace("- App Model: Annotation Saved");
				trace("****************************");
				this.annotationID = dataXML.reply.result.id;
				AppModel.getInstance().copyAccess(mediaID, annotationID);
				AppModel.getInstance().sendNotification(mediaID, Model_Notification.ANNOTATION_ON_MEDIA, annotationID);
				AppModel.getInstance().setAnnotationClassForID(annotationID, annotationClassSaved);
			} else {
				// Annotation didnt save successfully
				// Tell the controller the message
				callback(e);
			}
		}
		private function annotationClassSaved(e:Event):void {
			// The annotation class has been saved, send this back to the controller
			// We have to wait for the annotation class to be saved, so we can make sure the
			// annotation appears on the display when they are all reloaded after each save
			callback(e);
		}
	}
}