package Model {
	
	import Controller.Dispatcher;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.utils.describeType;
	
	public class Model_Media extends Model_Base {
		
		public var type:String = "";
		
		/* BASIC */
		public var base_type:String;
		public var base_modifier_id:Number;
		
		/* META */
		public var meta_user_id:Number;
		//public var meta_username:String;
		public var meta_obtype:String;
		public var meta_active:Boolean;
		public var meta_subject:String;
		public var meta_keywords:String;
		public var meta_datepublished:String;
		public var meta_authorcreated:String;
		public var meta_othercontrib:String;
		public var meta_sponsorfunder:String;
		public var meta_creativeworktype:String;
		public var meta_creativeworksubtype:String;
		//public var meta_title:String;
		//public var meta_description:String;
		public var meta_media_id:Number;
		public var meta_media_trancoded:Boolean;
		public var meta_media_uri:String;
		
		public var meta_users_access:XMLList;
		
		public var meta_media_access_level:String = SharingPanel.NOACCESS;
	 
		/* CONTENT */
		public var content_id:Number;
		public var content_type:String;
		public var content_size:Number;
		public var content_csum:String;
		public var content_store:String;
		public var content_url:String;
		
		/* RELATIONSHIPS */
		public var hasChild:Array;
		public var belongsTo:Array;
		
		
		public var annotationsAndComments:Array = new Array(); // Type: Model_Annotation
		
		public function Model_Media() {
			super();
		}
		
		// Sets the specific data for the media type
		override protected function setSpecificData():void {
			base_type = rawData.type;
			base_modifier_id = rawData.modifier.@id;
			meta_user_id = rawData.meta["mf-revision-history"].user.@id;
			meta_username = rawData.meta["mf-revision-history"].user.name;
			meta_obtype = rawData.meta.r_base.obtype;
			meta_active = stringToBool(rawData.meta.r_base.active);
			
			
			meta_subject = rawData.meta.r_base.properties.property.(@name=="Subject");
			meta_keywords = rawData.meta.r_base.properties.property.(@name=="Keywords");
			meta_datepublished = rawData.meta.r_base.properties.property.(@name=="DatePublished");
			meta_authorcreated = rawData.meta.r_base.properties.property.(@name=="AuthorCreator");
			meta_othercontrib = rawData.meta.r_base.properties.property.(@name=="OtherContrib");
			meta_sponsorfunder = rawData.meta.r_base.properties.property.(@name=="SponsorFunder");
			meta_creativeworktype = rawData.meta.r_base.properties.property.(@name=="CreativeWorkType");
			meta_creativeworksubtype = rawData.meta.r_base.properties.property.(@name=="CreativeWorkSubType");
			meta_description = rawData.meta.r_resource.description;
			
//			* is used a a filler character, when we want to store a blank entry, mediaflux problem TODO
			if(meta_subject == "*") 			meta_subject = "";
			if(meta_keywords == "*") 			meta_keywords = "";
			if(meta_datepublished == "*") 		meta_datepublished = "";
			if(meta_authorcreated == "*") 		meta_authorcreated = "";
			if(meta_othercontrib == "*") 		meta_othercontrib = "";
			if(meta_sponsorfunder == "*") 		meta_sponsorfunder = "";
			if(meta_creativeworktype == "*")	meta_creativeworktype = "";
			if(meta_creativeworksubtype == "*") meta_creativeworksubtype = "";
			if(meta_description == "*") 		meta_description = "";
//				
				
			meta_title = rawData.meta.r_resource.title;
			
			meta_media_id = rawData.meta.r_media.@id;
			meta_media_trancoded = stringToBool(rawData.meta.r_media.transcoded);
			meta_media_uri = rawData.meta.r_media.uri;
			content_id = rawData.content.@id;
			content_type = rawData.content.type;
			content_size = rawData.content.size;
			content_csum = rawData.content.csum;
			content_store = rawData.content.store;
			content_url = rawData.content.url;
			belongsTo = xmlToArray(rawData.related.(@type=="is_child").to);
			hasChild = xmlToArray(rawData.related.(@type=="has_child").to);
			type = AssetLookup.getCommonType(base_type);
			
			meta_users_access = rawData.meta.id_sharing.user_share_count;
			
			for each(var userShareCount:XML in rawData.meta.id_sharing.user_share_count) {
				// Get out the access level we have for this asset (via the asset alone)	
				if(userShareCount.username == Auth.getInstance().getUsername() && userShareCount.via_asset == base_asset_id) {
					meta_media_access_level = userShareCount.access_level;
					break;
				}
			}
			
			
			// If this media has the data for the annotations/comments on it as well
			// we can also store that
			// Quick way to convert from a xml list to an array
			var annotationOrCommentList:XMLList = rawData.related.asset;
			
			// For each XML of the annotations/comments
			for each(var annotationOrCommentXML:XML in annotationOrCommentList) {
				
				// Just checking it doesnt have a type (means its not a media, so
				// just kinda assuming its a comment/annotation
				if(!annotationOrCommentXML.type.toString()) {
					// Create a new annotation for this data
					var annotationOrComment:Model_Commentary = new Model_Commentary();
					annotationOrComment.setData(annotationOrCommentXML);
					// Save it.
					annotationsAndComments.push(annotationOrComment);
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
			if(type == "video") {
				//return "rtmp://recensio.dyndns.org/vod/" + meta_media_uri
				trace("Media Media URI:", meta_media_uri);
				return meta_media_uri
			} else if(type == "document") {
				return "http://recensio.dyndns.org/" + meta_media_uri;
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
			mediaURL = mediaURL + "&disposition=" + "attachment";
			return mediaURL;
		}
	}
	
}