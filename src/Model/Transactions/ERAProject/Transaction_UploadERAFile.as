package Model.Transactions.ERAProject
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_ERAEvidence;
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
		private var roomID:Number;
		private var type:String;
		private var title:String;
		private var description:String;
		private var fileReference:FileReference;
		private var evidenceItem:EvidenceItem;
		private var connection:Connection;
		private var ioErrorCallback:Function;
		private var progressCallback:Function;
		private var completeCallback:Function;
		
		private var newFileID:Number;
		
		public function Transaction_UploadERAFile(year:String, roomID:Number, type:String, title:String, description:String, fileReference:FileReference, evidenceItem:EvidenceItem, connection:Connection, ioErrorCallback:Function, progressCallback:Function, completeCallback:Function) {
			this.year = year;
			this.roomID = roomID;
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
			var percentProgress:Number = Math.round(event.bytesLoaded/event.bytesTotal*100);
			progressCallback(percentProgress, evidenceItem);
		}
		private function ioErrorHandler(event:IOErrorEvent):void {
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
			
			// Keeping some of the OLD mediaflux stuff
			// just makes things easier
			argsXML.meta["r_base"]["creator"] = Auth.getInstance().getUsername();
			argsXML["meta"]["r_base"]["obtype"] = "7";
			argsXML["meta"]["r_base"]["active"] = "true";
			
			argsXML.meta["r_media"]["file_title"] = this.title;
			argsXML.meta["r_media"].@id = "4";
			argsXML.meta["r_media"]["transcoded"] = "false";
			
//			argsXML.related = "";
//			argsXML.related.appendChild(XML('<to relationship="room">' + roomID + '</to>'));

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
			
			var baseXML:XML = connection.packageRequest("asset.relationship.add", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = newFileID;
			argsXML.to = roomID;
			argsXML.to.@relationship = "room";
			
			connection.sendRequest(baseXML, addedToRoom);
		}
		
		private function addedToRoom(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("adding relationship to room", e)) == null) {
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
			if((data = AppModel.getInstance().getData("getting era project", e)) == null) {
				completeCallback(false);
			}
			
			var eraEvidence:Model_ERAEvidence = new Model_ERAEvidence();
			eraEvidence.setData(data.reply.result.asset[0]);
			
			completeCallback(true, eraEvidence, evidenceItem);
		}
	}
}