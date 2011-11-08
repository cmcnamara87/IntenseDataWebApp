package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Utilities.Connection;
	
	import View.ERA.components.EvidenceItem;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	
	public class Transaction_UploadFileVersion
	{
		private var year:String;
		private var roomID:Number;
		private var type:String;
		private var title:String;
		private var description:String;
		private var version:Number;
		private var oldFileID:Number;
		private var originalFileID:Number;
		private var fileReference:FileReference;
		private var connection:Connection;
		private var ioErrorCallback:Function;
		private var progressCallback:Function;
		private var completeCallback:Function;
		
		
		private var newFileID:Number;
		
		public function Transaction_UploadFileVersion(year:String, roomID:Number, oldFileID:Number, originalFileID:Number, type:String, title:String, description:String, fileReference:FileReference, connection:Connection, ioErrorCallback:Function, progressCallback:Function, completeCallback:Function) {
			this.year = year;
			this.roomID = roomID;
			this.version = version;
			this.type = type;
			this.title = title;
			this.oldFileID = oldFileID;
			this.originalFileID = originalFileID;
			this.description = description;
			this.fileReference = fileReference;
			this.connection = connection;
			this.ioErrorCallback = ioErrorCallback;
			this.progressCallback = progressCallback;
			this.completeCallback = completeCallback;
			
			// Setup event listeners
			fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadComplete);
			
			// Work out version
			determineVersion();

		}
		
		private function progressHandler(event:ProgressEvent):void {
			var percentProgress:Number = Math.round(event.bytesLoaded/event.bytesTotal*100);
			progressCallback(percentProgress);
		}
		private function ioErrorHandler(event:IOErrorEvent):void {
			ioErrorCallback(event);
		}
		
		/**
		 * Get all the different files that have the same original files.
		 * We are going to count these up, and that will be the version number 
		 * 
		 */
		private function determineVersion():void {
			var baseXML:XML = connection.packageRequest("asset.query", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.where = "related to{originalfile} (id=" + originalFileID + ")";
			
			connection.sendRequest(baseXML, gotVersionedFiles);
		}			
		private function gotVersionedFiles(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("getting versioned files", e)) == null) {
				completeCallback(false);
				return;
			}
			
			var idList:XMLList = data.reply.result.id;

			this.version = idList.length() + 1;
			
			uploadFile();
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
			argsXML.meta["ERA-evidence"]["version"] = this.version;
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
			
			// It was successful, so lets get it out
			newFileID = xml.reply.result.id;
			
			// this function only  works if its a video file, so its okay if it does it
			AppModel.getInstance().createF4V(newFileID);
			
			var baseXML:XML = connection.packageRequest("asset.set", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			// Setup the era meta-data
			argsXML.id = newFileID;
			argsXML.related = "";
			argsXML.related.appendChild(XML('<to relationship="originalfile">' + oldFileID + '</to>'));
			argsXML.related.appendChild(XML('<to relationship="room">' + roomID + '</to>'));
			
			connection.sendRequest(baseXML, relationshipsAdded);		
		}
		
		private function relationshipsAdded(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("adding relationships", e)) == null) {
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
			
			// change the temperature of the old file to cold
			AppModel.getInstance().updateERAFileTemperature(oldFileID, false, temperatureUpdated);
		}
		
		private function temperatureUpdated(status:Boolean):void {
			if(!status) {
				completeCallback(false);
				return;
			}
			
			// make the old file as no longer checked out
			AppModel.getInstance().updateERAFileCheckOutStatus(oldFileID, false, checkoutUpdated);
		}
		
		private function checkoutUpdated(status:Boolean):void {
			if(!status) {
				completeCallback(false);
				return;
			}
			
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
			
			completeCallback(true, eraEvidence);
		}
	}
}