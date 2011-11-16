package Model.Transactions.ERAProject
{
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Model_ERANotification;
	import Model.Utilities.Connection;
	
	import View.ERA.components.EvidenceItem;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;

	public class Transaction_UploadERAFile
	{
		private var year:String;
		private var logItemID:Number;
		private var evidenceRoomID:Number;
		private var forensicLabID:Number;
		private var type:String;
		private var title:String;
		private var description:String;
		private var version:Number;
		private var fileReference:FileReference;
		private var evidenceItem:EvidenceItem;
		private var connection:Connection;
		private var ioErrorCallback:Function;
		private var progressCallback:Function;
		private var completeCallback:Function;
		
		
		private var newFileID:Number;
		
		private var bytesLoadedSoFar:Number = 0;
		
		public function Transaction_UploadERAFile(year:String, evidenceRoomID:Number, forensicLabID:Number, logItemID:Number, type:String, title:String, description:String, version:Number, fileReference:FileReference, evidenceItem:EvidenceItem, connection:Connection, ioErrorCallback:Function, progressCallback:Function, completeCallback:Function) {
			this.year = year;
			this.evidenceRoomID = evidenceRoomID;
			this.forensicLabID = forensicLabID;
			this.version = version; // todo remove version for upload (since its only ever for new files)
			this.logItemID = logItemID;
			this.type = type;
			this.title = title;
			this.description = description;
			this.fileReference = fileReference;
			this.evidenceItem = evidenceItem;
			this.connection = connection;
			this.ioErrorCallback = ioErrorCallback;
			this.progressCallback = progressCallback;
			this.completeCallback = completeCallback;
			
			// Setup event listeners
			fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadComplete);

			uploadFile();
		}
		
		private function progressHandler(event:ProgressEvent):void {
//			var byteJustLoaded:Number = event.bytesLoaded
			var percentProgress:Number = event.bytesLoaded/event.bytesTotal*100;
			
			progressCallback(percentProgress, logItemID);
		}
		private function ioErrorHandler(event:IOErrorEvent):void {
			Auth.getInstance().decActiveUploadCount();
			ioErrorCallback(event, evidenceItem);
		}
		
		private function uploadFile():void {
			var baseXML:XML = connection.packageRequest("id.asset.create", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Create a namespace for this era
			argsXML.namespace = "ERA/" + this.year;

			// Setup the era meta-data
			argsXML.meta["ERA-evidence"]["type"] = this.type
			argsXML.meta["ERA-evidence"]["file_name"] = fileReference.name;
			argsXML.meta["ERA-evidence"]["title"] = this.title;
			argsXML.meta["ERA-evidence"]["description"] = this.description;
			// make sure this file is set to active
			argsXML.meta["ERA-evidence"]["version"] = 0;
			argsXML.meta["ERA-evidence"]["hot"] = true;
			argsXML.meta["ERA-evidence"]["checked_out"] = false;
			
			
			// Keeping some of the OLD mediaflux stuff
			// just makes things easier
			argsXML.meta["r_base"]["creator"] = Auth.getInstance().getUsername();
			argsXML["meta"]["r_base"]["obtype"] = "7";
			argsXML["meta"]["r_base"]["active"] = "true";
			
			argsXML.meta["r_media"]["file_title"] = this.title;
			argsXML.meta["r_media"].@id = "4";
			argsXML.meta["r_media"]["transcoded"] = "false";
			
			// Store that we are currently uploading, so a message can be displayed on attempt to log out
			Auth.getInstance().incActiveUploadCount();
			connection.uploadFile(fileReference, baseXML, null);
		}
		
		private function uploadComplete(e:DataEvent):void {
			// Get out the XML data from the Mediaflux response
			var xml:XML = XML(e.data);
			if(xml.reply.@type != "result") {
				trace("uploading file: FAILED", xml);
				completeCallback(false);
				return;
			}
			trace("uploading file: SUCCESS", xml);
			
			Auth.getInstance().decActiveUploadCount();
			
			// It was successful, so lets get it out
			newFileID = xml.reply.result.id;
			
			
			
			
			
			var baseXML:XML = connection.packageRequest("asset.relationship.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = newFileID;
			argsXML.to = evidenceRoomID;
			argsXML.to.@relationship = "room";
			
			connection.sendRequest(baseXML, addedEvidenceRoom);
		}
		
		private function addedEvidenceRoom(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("adding relationship to evidnece room", e)) == null) {
				completeCallback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("asset.relationship.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = newFileID;
			argsXML.to = forensicLabID;
			argsXML.to.@relationship = "room";
			
			connection.sendRequest(baseXML, addedForensicLabRoom);
		}
		
		private function addedForensicLabRoom(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("adding relationship to forensic lab", e)) == null) {
				completeCallback(false);
				return;
			}
			
			var baseXML:XML = connection.packageRequest("asset.relationship.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = newFileID;
			argsXML.to = logItemID;
			argsXML.to.@relationship = "logitem";
			
			connection.sendRequest(baseXML, addToLogItem);
		}
		
		private function addToLogItem(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("adding relationship to log item", e)) == null) {
				completeCallback(false);
				return;
			}
			
			// Give it a media class, this ia just a precaution
			var baseXML:XML = connection.packageRequest("asset.class.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.scheme = "recensio";
			argsXML["class"] = "base/resource/media";
			argsXML.id = newFileID;
			
			connection.sendRequest(baseXML, classAdded);

		}
		
		private function classAdded(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("adding media class", e)) == null) {
				completeCallback(false);
				return;
			}
			
			// SEND THE NOTIFICATION
			sendNotification();
			
			// Get out the ERA object
			var baseXML:XML = connection.packageRequest("asset.get", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			trace("***** FILE ID IS", newFileID);
			argsXML.id = newFileID;
			
			connection.sendRequest(baseXML, eraFileRetrieved);
		}
		
		private function eraFileRetrieved(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting era evidence item", e)) == null) {
				completeCallback(false);
			}
			
			var eraEvidence:Model_ERAFile = new Model_ERAFile();
			eraEvidence.setData(data.reply.result.asset[0]);
			
			// Do the conversion if we need to
			// this function only  works if its a video file, so its okay if it does it
			if(eraEvidence.rootMetaType == "video" || eraEvidence.rootMetaType == "document" || eraEvidence.rootMetaType == "image") {
				AppModel.getInstance().createF4V(newFileID);
			}
			
			completeCallback(true, evidenceItem.getID(), eraEvidence.base_asset_id)
		}
		
		private function sendNotification():void {
			trace('sending notification', evidenceRoomID, newFileID);
			AppModel.getInstance().createERANotification(year, evidenceRoomID, Auth.getInstance().getUsername(),
				Auth.getInstance().getUserDetails().firstName, Auth.getInstance().getUserDetails().lastName,
				Model_ERANotification.FILE_UPLOADED, 0, newFileID, 0);
		}
	}
}