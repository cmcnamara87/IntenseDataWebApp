package Model {
	import Controller.Dispatcher;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	public class Model_ERAFile extends Model_Base {
		
		public var rootMetaType:String;
		public var type:String;
		public var fileName:String; // the name of the file (the original file name)
		public var fileType:String; // the type of the file (from the evidence manager drop down list)
		public var title:String; // the title for the file
		public var description:String;
		
		public var fileExt:String = "Unknown"; // the file extension
		
		public var fileSize:Number; // the file size in bytes
		
		public var hot:Boolean = true; // if the file is hot or cold (active or inactive)
		public var version:Number = 0; // the number to append to the end of the file name
		public var originalFileID:Number = 0; // the id of the origianl file it was a version of
		public var checkedOut:Boolean = false; // if the file has been downloaded (and its awaiting upload)
		public var checkedOutUsername:String = ""; // the username of the person who checked out the file
		
		public var meta_media_uri:String;
		
		
		public function Model_ERAFile() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			
			this.fileType = AssetLookup.getCommonType(rawData.type);
			
			// grab out the case info
			var eraEvidenceItem:XML = rawData.meta["ERA-evidence"][0];
			
			// set the type of the item (e.g. video, image etc)
			this.type = eraEvidenceItem["type"];
			
			this.fileName = eraEvidenceItem["file_name"];
			
			// set the title of the item
			this.title = eraEvidenceItem["title"];
			
			this.description = eraEvidenceItem["description"];
			
			meta_media_uri = rawData.meta.r_media.uri;
			
			this.rootMetaType = AssetLookup.getCommonType(rawData.type);
			
			if(rawData.content) {
				this.fileExt = rawData.content.type.@ext;
				this.fileSize = rawData.content.size;
			}
			
			if(eraEvidenceItem["hot"]) {
				this.hot = eraEvidenceItem["hot"] == "true";
			}
			if(eraEvidenceItem["version"]) {
				this.version = eraEvidenceItem["version"];
			}
			
			// show if this item has been uploaded
			// we know its been uploaded, if it has a relationship to its data item
			var originalFileNumber:Number = Number(rawData.related.(@type=="originalfile").to);
			if(originalFileNumber > 0) {
				originalFileID = originalFileNumber;
			} else {
				originalFileID = this.base_asset_id;
			}
			
			if(eraEvidenceItem["checked_out"]) {
				this.checkedOut = eraEvidenceItem["checked_out"] == "true";
				if(this.checkedOut) {
					this.checkedOutUsername = eraEvidenceItem["checked_out_username"];
				}
			}
		}
		
		/**
		 * Gets the URL to this media asset.
		 * Video's use a different URL to all other media types. 
		 * @return 
		 * 
		 */		
		public function generateMediaURL():String {
			trace("Generating Media URL");
			if(rootMetaType == "video") {
				//return "rtmp://recensio.dyndns.org/vod/" + meta_media_uri
				trace("Media Media URI:", meta_media_uri);
				return meta_media_uri
			} else if(rootMetaType == "document") {
				trace("******PDF URL IS", "http://"+Recensio_Flex_Beta.serverAddress+"/" + meta_media_uri);
				return "http://"+Recensio_Flex_Beta.serverAddress+"/" + meta_media_uri;
			} else {
				var mediaURL:String = "http://"+Dispatcher.getServerDetails()+"/mflux/content.mfjp?";
				mediaURL = mediaURL + "_skey=" + Auth.getInstance().getSessionID();
				mediaURL = mediaURL + "&id=" + this.base_asset_id;
				mediaURL = mediaURL + "&version=" + this.base_asset_version;
				mediaURL = mediaURL + "&disposition=" + "attachment";
				return mediaURL;
			}
		}
		
		/**
		 * Gets the URL where the assets content can be downloaded from. 
		 * @return 
		 * 
		 */		
		public function getDownloadURL():String {
			var mediaURL:String = "http://"+Dispatcher.getServerDetails()+"/mflux/content.mfjp?";
			mediaURL = mediaURL + "_skey=" + Auth.getInstance().getSessionID();
			mediaURL = mediaURL + "&id=" + this.base_asset_id;
			mediaURL = mediaURL + "&version=" + this.base_asset_version;
			mediaURL = mediaURL + "&filename=" + this.fileName;
			mediaURL = mediaURL + "&disposition=" + "attachment";
			return mediaURL;
		}
	}
}