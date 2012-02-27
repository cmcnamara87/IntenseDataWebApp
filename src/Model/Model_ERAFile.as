package Model {
	import Controller.AppController;
	import Controller.Dispatcher;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	public class Model_ERAFile extends Model_Base {

		public var rootMetaType:String;
		public var type:String;
		public var fileName:String; // the name of the file (the original file name)
		public var fileType:String; // the type of the file (from the evidence manager drop down list)
		public var title:String; // the title for the file
		public var downloadTitle:String;
		public var description:String;
		
		public var fileExt:String = "Unknown"; // the file extension
		
		public var fileSize:Number; // the file size in bytes
		
		public var hot:Boolean = true; // if the file is hot or cold (active or inactive)
		public var version:Number = 0; // the number to append to the end of the file name
		public var originalFileID:Number = 0; // the id of the origianl file it was a version of
		public var checkedOut:Boolean = false; // if the file has been downloaded (and its awaiting upload)
		public var checkedOutUsername:String = ""; // the username of the person who checked out the file
		
		public var meta_media_uri:String;
		public var transcoded:Boolean = true;
		public var mimetype:String;
		
		public var notificationCount:Number = 0;
		public var notificationArray:Array = new Array();
		public var screeningCount:Number = 0;
		public var exhibitionCount:Number = 0;
		
		public var researcherApproved:Array = new Array();
		public var researcherNotApproved:Array = new Array();
		
		public var monitorApproved:Array = new Array();
		public var monitorNotApproved:Array = new Array();
		
		public var lockedOut:Boolean = false;
		
		public var thumbnailURL:String = "";
		
		public function Model_ERAFile() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			
			this.mimetype = rawData.type;
			
			this.fileType = AssetLookup.getCommonType(rawData.type);
			
			// grab out the case info
			var eraEvidenceItem:XML = rawData.meta["ERA-evidence"][0];
			
			// set the type of the item (e.g. video, image etc)
			this.type = eraEvidenceItem["type"];
			
			this.fileName = eraEvidenceItem["file_name"];
			
			// set the title of the item
			this.title = eraEvidenceItem["title"];
			
			this.downloadTitle = eraEvidenceItem["download_title"];
			
			this.description = eraEvidenceItem["description"];
			
			meta_media_uri = rawData.meta.r_media.uri;
			
			this.rootMetaType = AssetLookup.getCommonType(rawData.type);
			
			// if its video, we need to store whether its successfully been transcoded or not
			// we dont really care for other medias
			if(this.rootMetaType == "video" || this.rootMetaType == "document") {
				this.transcoded = rawData.meta.r_media.transcoded == "true";
			}
			
			// get the thumbnail if its there
			if(rawData.meta["ERA-thumbnail"].length()) {
				this.thumbnailURL = "http://" + Recensio_Flex_Beta.serverAddress + "/Media/thumbnails/" + rawData.meta["ERA-thumbnail"].uri;
			} else if (this.rootMetaType == "image" && (this.mimetype != "image/jpeg" && this.mimetype != "image/jpg")) { 
//				trace("MIME TYPE IS", this.mimetype);
				this.thumbnailURL = 'http://' + Recensio_Flex_Beta.serverAddress + ':' + Recensio_Flex_Beta.serverPort + '/mflux/icon.mfjp?_skey=' + Auth.getInstance().getSessionID() + '&id=' + this.base_asset_id + '&version=0&size=100'
			}
			
			
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
			
			// Store if the file is locked for the current user
			if(eraEvidenceItem["locked_for_user"].length()) {
				for each(var lockedUsername:String in eraEvidenceItem["locked_for_user"]) {
					if(lockedUsername == Auth.getInstance().getUsername()) {
						this.lockedOut = true;
					}
				}
			}
			
			if(eraEvidenceItem["exhibition_approval"].length()) {
//				trace("approval xml found", base_asset_id);
				for each(var approvalXML:XML in eraEvidenceItem["exhibition_approval"]) {
//					trace("xml is", approvalXML.role, approvalXML.approval == true ? 'approved' : 'not approved');
//					trace("xml is", approvalXML.role, approvalXML.role == Model_ERAUser.MONITOR ? 'MONITOR' : 'NOT MONITOR', approvalXML.approval == true ? 'approved' : 'not approved');
					var approvalString:String = approvalXML.name + " (" + approvalXML.username + ") - " + approvalXML.date;
					if(approvalXML.role == Model_ERAUser.RESEARCHER && (approvalXML.approval == "true" || approvalXML.approval == true)) {
						this.researcherApproved.push(approvalString);
					} else if(approvalXML.role == Model_ERAUser.RESEARCHER && (approvalXML.approval == "false" || approvalXML.approval == false)) {
						this.researcherNotApproved.push(approvalString);
						
						// NOTE: the reason the quotes are around the roles is, i wrote a lot of these approvals manually into mediaflux using aterm
						// and i put quotes around the monitor role, so they have quotes around it
					} else if ((approvalXML.role == Model_ERAUser.MONITOR || approvalXML.role == "'" + Model_ERAUser.MONITOR + "'") && (approvalXML.approval == "true" || approvalXML.approval == true)) {
//						trace("pushing monitor approval");
						this.monitorApproved.push(approvalString);
					} else if ((approvalXML.role == Model_ERAUser.MONITOR || approvalXML.role == "'" + Model_ERAUser.MONITOR + "'") && (approvalXML.approval == "false" || approvalXML.approval == false)) {
						this.monitorNotApproved.push(approvalString);
					}
				}
			} else {
				trace("no approval xml");
			}
			
			if(eraEvidenceItem["review_count"].length()) {
				this.screeningCount = Number(eraEvidenceItem["review_count"]);
			}
			
			if(eraEvidenceItem["exhibition_count"].length()) {
				this.exhibitionCount = Number(eraEvidenceItem["exhibition_count"]);
			}
			
			/*this.researcherApproved = new Array();
			this.researcherNotApproved = new Array();
			this.monitorApproved = new Array();
			this.monitorNotApproved = new Array();
			
			case Model_ERANotification.FILE_APPROVED_BY_RESEARCHER:
			this.researcherApproved.push(notificationData.firstName + " " + notificationData.lastName + " (" + notificationData.username + ")");
			break;
			case Model_ERANotification.FILE_NOT_APPROVED_BY_RESEARCHER:
			this.researcherNotApproved.push(notificationData.firstName + " " + notificationData.lastName + " (" + notificationData.username + ")");
			break;
			case Model_ERANotification.FILE_APPROVED_BY_MONITOR:
			this.monitorApproved.push(notificationData.firstName + " " + notificationData.lastName + " (" + notificationData.username + ")");
			break;
			case Model_ERANotification.FILE_NOT_APPROVED_BY_MONITOR:
			this.monitorNotApproved.push(notificationData.firstName + " " + notificationData.lastName + " (" + notificationData.username + ")");
			break;
			default:
			break;*/
			
			updateNotificationCount();
		}
		
		public function updateNotificationCount():void {
			// Count up the number of notifications this file has
			this.notificationCount = 0;
			
			// Count up the number of notifications this file has
			for each(var notificationData:Model_ERANotification in AppController.notificationsArray) {
				if(!notificationData.file || notificationData.read || notificationData.username == Auth.getInstance().getUsername()) continue;
				
				if(notificationData.file.base_asset_id == this.base_asset_id) {
					this.notificationCount++;
					this.notificationArray.push(notificationData);
				}
			}
			
			/*this.screeningCount = 0;
			this.exhibitionCount = 0;
			
			for each(var notificationData:Model_ERANotification in AppController.allNotificationsArray) {
				if(notificationData.file && notificationData.file.base_asset_id == this.base_asset_id) {
					switch(notificationData.type) {
						case Model_ERANotification.FILE_MOVED_TO_SCREENING_LAB:
							this.screeningCount++;
							break;
						case Model_ERANotification.FILE_MOVED_TO_EXHIBITION:
							this.exhibitionCount++;
							break;
					}
				}
			}*/
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
				trace("RAW DATA");
				trace(rawData.meta["r_media"]);
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