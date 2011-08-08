package Model {
	
	public class Model_Collection extends Model_Base {
		
		public var acl_actor_id:String;
		public var acl_username:String;
		public var acl_metadata:String;
		public var acl_content:String;
		
		public var meta_user_id:String;
		public var meta_obtype:String;
		public var meta_active:Boolean;
		public var meta_creator:String;
		public var meta_contributer:String;
		
		//public var meta_title:String;
		//public var meta_description:String;
		
		public var hasChild:Array;
		public var assets:Array;
		public var comments:Array;
		
		public function Model_Collection() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			
			acl_actor_id = rawData.acl.actor.@id;
			acl_username = rawData.acl.actor.(@type=="user");
			acl_metadata = rawData.acl.metadata;
			acl_content = rawData.acl.content;
			
			meta_user_id = rawData.meta["mf-revision-history"].user.@id;
			meta_obtype = rawData.meta.r_base.obtype;
			meta_active = stringToBool(rawData.meta.r_base.active);
			meta_creator = rawData.meta.r_base.creator;
			meta_contributer = rawData.meta.r_base.properties.property.(@name=="Contributor");
			
			
			
			hasChild = xmlToArray(rawData.related.(@type=="has_child").to);
			
			// Set description of collection to be number of items
			setDescription();
		}
		
		public function setDescription():void {
			if(rawData.meta.r_resource.description == "") {
				// Because we werent setting this intially, we can just echo out the number of children
				// this isnt accurate, as it includes comments etc in the children count
				if(numberOfChildren() == 1) {
					meta_description = numberOfChildren()  + " file."
				} else {
					meta_description = numberOfChildren()  + " files."
				}
			} else {
				if(rawData.meta.r_resource.description == 1) {
					meta_description = rawData.meta.r_resource.description + " file."
				} else {
					meta_description = rawData.meta.r_resource.description + " files."
				}
			}
		}
		
		// Returns the number of assets within a collection
		public function numberOfChildren():Number {
			return hasChild.length;
		}
	}
}