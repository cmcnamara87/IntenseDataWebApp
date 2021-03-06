package Controller.Utilities {
	
	import View.ModuleWrapper.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	
	public class AssetLookup extends Object {
		
		// Image Icon Assets - Normal and Clicked
		[Embed(source="Assets/Template/assets/image2.png")] 
		private static var Asseticon_image:Class;
		private static var Asseticon_image_data:BitmapData;
		[Embed(source="Assets/Template/assets/image_clicked.png")] 
		private static var Asseticon_image_clicked:Class;
		private static var Asseticon_image_clicked_data:BitmapData = (new Asseticon_image_clicked as Bitmap).bitmapData;
		
		// Video Assets - Normal
		[Embed(source="Assets/Template/assets/video2.png")] 
		private static var Asseticon_video:Class;
		private static var Asseticon_video_data:BitmapData;
		[Embed(source="Assets/Template/assets/video_clicked.png")] 
		private static var Asseticon_video_clicked:Class;
		private static var Asseticon_video_clicked_data:BitmapData = (new Asseticon_video_clicked as Bitmap).bitmapData;
		
		
		
		[Embed(source="Assets/Template/assets/audio2.png")] 
		private static var Asseticon_audio:Class;
		private static var Asseticon_audio_data:BitmapData;
		[Embed(source="Assets/Template/assets/audio_clicked.png")] 
		private static var Asseticon_audio_clicked:Class;
		private static var Asseticon_audio_clicked_data:BitmapData = (new Asseticon_audio_clicked as Bitmap).bitmapData;
		
		
		[Embed(source="Assets/Template/assets/document2.png")] 
		private static var Asseticon_document:Class;
		private static var Asseticon_document_data:BitmapData;
		
		[Embed(source="Assets/Template/assets/general_file_icon_small_yours.png")]
		private static var Generic_File_Icon_Small_Yours:Class;
		
		[Embed(source="Assets/Template/assets/general_file_icon_small_others.png")]
		private static var Generic_File_Icon_Small_Others:Class;
		
		// Video icons
		[Embed(source="Assets/Template/assets/video_file_icon_small_others.png")]
		private static var Video_File_Icon_Small_Others:Class;
		
		[Embed(source="Assets/Template/assets/video_file_icon_small_yours.png")]
		private static var Video_File_Icon_Small_Yours:Class;

		// Image icons
		[Embed(source="Assets/Template/assets/image_file_icon_small_others.png")]
		private static var Image_File_Icon_Small_Others:Class;
		
		[Embed(source="Assets/Template/assets/image_file_icon_small_yours.png")]
		private static var Image_File_Icon_Small_Yours:Class;
		
		// Audio Icons
		[Embed(source="Assets/Template/assets/audio_file_icon_small_others.png")]
		private static var Audio_File_Icon_Small_Others:Class;
		
		[Embed(source="Assets/Template/assets/audio_file_icon_small_yours.png")]
		private static var Audio_File_Icon_Small_Yours:Class;
		
		[Embed(source="Assets/Template/assets/edit_discussion_icon.png")]
		private static var Edit_Discussion_Icon:Class;
		
		[Embed(source="Assets/Template/assets/all_file_icon.png")]
		private static var All_File_Icon:Class;
		
		[Embed(source="Assets/Template/assets/glyphicons_244_conversation_shared.png")]
		private static var Asseticon_collection_shared:Class;
		private static var Asseticon_collection_shared_data:BitmapData;
		
		[Embed(source="Assets/Template/assets/triangle_dropdown.png")]
		private static var Triangle_Dropdown:Class;
		private static var Triangle_Dropdown_Data:BitmapData;
		
		[Embed(source="Assets/Template/assets/glyphicons_244_conversation.png")]
		private static var Asseticon_collection:Class;
//		private static var Asseticon_collection_data:BitmapData;
		
		[Embed(source="Assets/Template/postit_icon1.png")]
		private static var Postit_icon:Class;
		private static var Postit_icon_data:BitmapData = (new Postit_icon as Bitmap).bitmapData;
		
		[Embed(source="Assets/Template/loader.gif")] 
		private static var Loadericon:Class;
		private static var Loadericon_data:BitmapData = (new Loadericon as Bitmap).bitmapData;
		
		// Icon for Reply Button
		[Embed(source="Assets/Template/reply_icon.png")]
		private static var Buttonicon_reply:Class;
		private static var Buttonicon_reply_data:BitmapData = (new Buttonicon_reply as Bitmap).bitmapData;
		
		[Embed(source="Assets/Template/edit_icon.png")]
		private static var Buttonicon_edit:Class;
		private static var Buttonicon_edit_data:BitmapData = (new Buttonicon_edit as Bitmap).bitmapData;
		
		[Embed(source="Assets/Template/delete_icon2.png")]
		private static var Buttonicon_delete:Class;
		private static var Buttonicon_delete_data:BitmapData = (new Buttonicon_delete as Bitmap).bitmapData;
		
		[Embed(source="Assets/Template/user_icon.jpg")]
		private static var Buttonicon_user:Class;
		private static var Buttonicon_user_data:BitmapData = (new Buttonicon_user as Bitmap).bitmapData;
		
		[Embed(source="Assets/Template/add_comment_icon.png")]
		private static var Buttonicon_add_comment:Class;
		private static var Buttonicon_add_comment_data:BitmapData = (new Buttonicon_add_comment as Bitmap).bitmapData;
		
		private static var imagesSetup:Boolean = false;
		
		//File formats that can be uploaded
//		private static var allFilters:FileFilter = new FileFilter("All Accepted File Types", "*.jpg;*.gif;*.png;*.jpeg;*.bmp;*.mov;*.flv;*.mp4;*.avi;*.mpg;*.mpeg;*.mp3;*.wma;*.wavDocument;*.pdf;*.swf;");
		private static var allFilters:FileFilter = new FileFilter("All Accepted File Types", "*.jpg;*.gif;*.png;*.jpeg;*.bmp;*.mov;*.flv;*.mp4;*.avi;*.mpg;*.mpeg;*.mp3;*.pdf;");//*.swf;");
		private static var imageFilters:FileFilter = new FileFilter("Images (jpg, gif, png, jpeg)","*.jpg;*.gif;*.png;*.jpeg;*.bmp");
		private static var videoFilters:FileFilter = new FileFilter("Video (mov, flv, mp4, avi, mpg, mpeg)","*.mov;*.flv;*.mp4;*.avi;*.mpg;*.mpeg;");
		private static var audioFilters:FileFilter = new FileFilter("Audio (mp3)","*.mp3;");
		private static var documentFilters:FileFilter = new FileFilter("Document (pdf, swf)","*.pdf;");//*.swf");
		
		//Types of creative work types and subtypes
		public static var creativeworktypeLookup:ArrayCollection = new ArrayCollection(
			["Not Applicable","Original Creative Work","Curated Exhibition or Event","Recorded Performance Work","Live Performance"]
		);
		public static var creativeworksubtypeLookup:ArrayCollection = new ArrayCollection(
			["Not Applicable","2 Dimensional","3 Dimensional","Textural","Exhibition","Web Based","Festival","Recorded Work-electronic","Recorded Work-interactive","Recorded Work-other media","Music","Theatre","Live Art","Dance","Other"]
		);
		
		public function AssetLookup() {
			super();
		}
		
		//Returns the appropriate module loader (in src/View/ModuleWrapper)
		public static function getClass(type:String):Class {
			switch(type) {
				case 'image':
					return Module_Image;
					break;
				case 'video':
					return Module_Video;
					break;
				case 'audio':
					return Module_Audio;
					break;
				case 'document':
					return Module_PDF;
					break;
			}
			return Module_Missing;
		}	
		
		//Gets the common type from a MIME type
		public static function getCommonType(realType:String):String {
			var type:String = "";
			switch(realType) {
				case "video/flv":
				case "video/mp4":
				case "video/wmv":
				case "video/avi":
				case "video/quicktime":
				case "video/mpeg":
				case "application/x-troff-msvideo":	
				case "video/x-msvideo":
					type = 'video';
					break;
				case "audio/wav":
				case "audio/x-wav":
				case "audio/wma":
				case 'audio/mp3':
				case 'audio/mpeg':
					type = 'audio';
					break;
				case "image/gif":
				case 'image/jpg':
				case "image/jpeg":
				case 'image/png':
					type = 'image';
					break;
				case "application/pdf":
				case 'application/x-shockwave-flash':
					type = 'document';
					break;
				default:
					throw new Error(realType+" is not a valid type");
			}
			return type;
		}
		
		//Setup for the image icons so there is no duplication of loading
		private static function setupImageData():void {
			Asseticon_image_data = (new Asseticon_image as Bitmap).bitmapData;
			Asseticon_video_data = (new Asseticon_video as Bitmap).bitmapData;
			Asseticon_audio_data = (new Asseticon_audio as Bitmap).bitmapData;
			Asseticon_document_data = (new Asseticon_document as Bitmap).bitmapData;
//			Asseticon_collection_data = (new Asseticon_collection as Bitmap).bitmapData;
			imagesSetup = true;
		}
		
		//Gets the appropriate icon for a media type
		public static function getAssetImage(type:String):BitmapData {
			if(!imagesSetup) {
				setupImageData();
			}
			switch(type) {
				case 'image':
					return Asseticon_image_data;
					break;
				case 'video':
					return Asseticon_video_data;
					break;
				case 'audio':
					return Asseticon_audio_data;
					break;
				case 'document':
					return Asseticon_document_data;
				case 'collection':
//					return Asseticon_collection_data;
					break;
				
			}
			return Asseticon_image_data;
		}
		
		/**
		 * Gets the Clicked Version of the icon for a media asset 
		 * @param type	The type of media asset
		 * @return 		The bitmap data for the icon
		 * 
		 */		
		public static function getAssetImageClicked(type:String):BitmapData {
			if(!imagesSetup) {
				setupImageData();
			}
			switch(type) {
				case 'image':
					return Asseticon_image_clicked_data;
					break;
				case 'video':
					return Asseticon_video_clicked_data;
					break;
				case 'audio':
					return Asseticon_audio_clicked_data;
					break;
				case 'document':
					return Asseticon_document_data;
				case 'collection':
//					return Asseticon_collection_data;
					break;
			}
			return Asseticon_image_data;
		}
		
		public static function getTriangleClass():Class {
			return Triangle_Dropdown;
		}
		public static function getCollectionIconClass():Class {
			return Asseticon_collection;
		}
		
		public static function getCollectionSharedIconClass():Class {
			return Asseticon_collection_shared;
		}
		
		public static function getGenericFileIconSmallYours():Class {
			return Generic_File_Icon_Small_Yours;			
		}
		public static function getGenericFileIconSmallOthers():Class {
			return Generic_File_Icon_Small_Others;
		}
		public static function getVideoFileIconSmallOthers():Class {
			return Video_File_Icon_Small_Others;
		}
		public static function getVideoFileIconSmallYours():Class {
			return Video_File_Icon_Small_Yours;
		}
		public static function getImageFileIconSmallOthers():Class {
			return Image_File_Icon_Small_Others;
		}
		public static function getImageFileIconSmallYours():Class {
			return Image_File_Icon_Small_Yours;
		}
		public static function getAudioFileIconSmallOthers():Class {
			return Audio_File_Icon_Small_Others;
		}
		public static function getAudioFileIconSmallYours():Class {
			return Audio_File_Icon_Small_Yours;
		}
		public static function getAllFileIcon():Class {
			return All_File_Icon;
		}
		public static function getLoadingIconClass():Class {
			return Loadericon;
		}
		public static function getEditDiscussionIcon():Class { 
			return Edit_Discussion_Icon;
		}
		
		
		public static function getPostItIconClass():Class {
			return Postit_icon;
		}
		public static function getPostItIcon():BitmapData {
			return Postit_icon_data;
		}
		
		/**
		 * Gets the icon for a certain button type.
		 * 
		 * @param 	buttonType 	the type of button e.g. 'reply', 'edit' etc
		 * @return 	bitmap data for button image or null of no image found.
		 */
		public static function getButtonImage(buttonType:String):BitmapData {
			buttonType = buttonType.toLowerCase();
			
			switch(buttonType) {
				case 'reply':
					return Buttonicon_reply_data;
					break;
				case 'edit':
					return Buttonicon_edit_data;
					break;
				case 'delete':
					return Buttonicon_delete_data;
					break;
				case 'profile':
					return Buttonicon_user_data;
					break;
				default:
					return null;
			}
			return null;
		}
		
		//Returns all acceptable file types for uploading
		public static function getFileTypes():Array {
			var fileTypes:Array = new Array(allFilters, imageFilters, videoFilters, audioFilters, documentFilters);
			return fileTypes;
		}
		
		//Checks what filter was used
		public static function checkFileFilterType(testFilter:FileFilter):String {
			if(testFilter == imageFilters) {
				return "image";
			}
			if(testFilter == videoFilters) {
				return "video";
			}
			if(testFilter == audioFilters) {
				return "audio";
			}
			if(testFilter == documentFilters) {
				return "document";
			}
			return "";
		}
		
		//Returns the MIME type based on its extension
		public static function getMimeFromFileType(fileName:String):String {
			var mimeType:String = "";
			switch (fileName.substr(fileName.lastIndexOf(".")+1,fileName.length).toLowerCase()) {
				case "gif" : mimeType ="image/gif"; break;
				case "jpg" : mimeType ="image/jpg"; break;
				case "jpeg": mimeType ="image/jpeg"; break
				case "png" : mimeType ="image/png"; break;					
				case "flv" : mimeType ="video/flv"; break;
				case "mp4" : mimeType ="video/mp4"; break;
				case "wmv" : mimeType ="video/wmv"; break;
				case "avi" : mimeType ="video/avi"; break;
				case "mov" : mimeType ="video/quicktime"; break;
				case "mpg": mimeType ="video/mpeg"; break;
				case "mpeg": mimeType ="video/mpeg"; break;
				case "pdf" : mimeType = "application/pdf"; break;
				case "mp3" : mimeType ="audio/mp3"; break;
				case "wav" : mimeType ="audio/wav"; break;
				case "wma" : mimeType ="audio/wma"; break;		
				
				case "swf" : mimeType = "application/x-shockwave-flash"; break;
			}
			
			return mimeType; 
		}
	}
}