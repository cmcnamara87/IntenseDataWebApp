package Model {
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.describeType;
	
	import mx.formatters.DateFormatter;
	
	public class Model_Base extends EventDispatcher {
		
		protected var rawData:XML;
		
		/* BASIC */
		public var base_asset_id:Number;
		public var base_asset_version:Number;
		public var base_asset_vid:Number;
		public var base_namespace:String;
		public var base_path:String;
		public var base_creator_id:Number;  //domain, user
		public var base_creator_username:String;
		public var base_ctime:String;
		public var base_ctimestring:String;
		public var base_mtime:String;
		public var base_mtimestring:String;
		public var base_stime:Number; 
		public var base_versioned:Boolean = true;
		
		/* ACL */
		public var access_access:Boolean;
		public var access_modify:Boolean;
		public var access_destroy:Boolean;
		public var access_access_content:Boolean;
		public var access_modify_content:Boolean;
		
		/* Some META stuff */
		public var meta_title:String; // The title of the asset
		public var meta_description:String; // The description of the asset
		public var meta_username:String;
		
		public function Model_Base() {
			super();
		}
		
		// Sets the general information, and then sets the specific information for the particular asset type
		public function setData(data:XML):void {
			this.rawData = data;
			setGenericData();
			setSpecificData();
		}
		
		// Sets generic information common across all mediaflux assets
		private function setGenericData():void {
			base_asset_id = rawData.@id;
			base_asset_version = rawData.@version;
			base_asset_vid = rawData.@vid;
			base_namespace = rawData.namespace;
			base_path = rawData.path;
			base_creator_id = rawData.creator.@id;
			base_creator_username = rawData.creator.user;
			base_ctime = rawData.ctime.@millisec;
			base_mtime = rawData.mtime.@millisec;
			base_ctimestring = rawData.ctime;
			base_mtimestring = rawData.mtime;
			base_stime = rawData.stime;
			base_versioned = stringToBool(rawData.versioned);
			//ACL
			access_access = stringToBool(rawData.access.access);
			access_modify = stringToBool(rawData.access.modify);
			access_destroy = stringToBool(rawData.access.destroy);
			access_access_content = stringToBool(rawData.access["access-content"]);
			access_modify_content = stringToBool(rawData.access["modify-content"]);
			
			// Set some common meta data
			meta_title = rawData.meta.r_resource.title;
			meta_description = rawData.meta.r_resource.description;
			meta_username = rawData.meta["mf-revision-history"].user.name;
		}
		
		// Gets the creation date of an asset
		public function getCreationDate():Date {
			var myDate:Date = new Date();
			myDate.setTime(base_ctime);
			return myDate;
		}
		
		// Gets the modified date of an asset
		public function getModifiedDate():Date {
			var myDate:Date = new Date();
			myDate.setTime(base_ctime);
			return myDate;
		}
		
		// Protects against models not overriding this method
		protected function setSpecificData():void {
			trace("MUST OVERRIDE THIS METHOD");
		}
		
		// Prints out all information stored in a model
		public function printData(filter:String=""):void {
			trace("=== OBJECT TYPE ASSET ===");
			var varList:XMLList = describeType(this)..variable;
			for(var i:int=0; i<varList.length(); i++) {
				var varName:String = varList[i].@name;
				if(varName.indexOf(filter) > -1) {
					trace(varName+"=>"+this[varList[i].@name]);
				}
			}
			trace("=== END OBJECT TRACE ===\n\n");
		}
		
		// Quick way to convert from a string to a boolean
		protected function stringToBool(string:String):Boolean {
			if(string=="true") {
				return true;
			}
			return false;
		}
		
		// Quick way to convert from a xml list to an array
		protected function xmlToArray(xmlList:XMLList):Array {
			var xmlArray:Array = new Array();
			for each(var child:XML in xmlList) {
				xmlArray.push(child.toString());
			}
			return xmlArray;
		}
		
		// Formats the date across the interface
		public function formatDate(theDate:Date,theFormat:String):String {
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = theFormat;
			var dateString:String = formatter.format(theDate);
			return dateString;
		}
	}
}