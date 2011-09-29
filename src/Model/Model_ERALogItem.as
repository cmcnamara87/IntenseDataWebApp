package Model {
	
	public class Model_ERALogItem extends Model_Base {
		
		public var type:String;
		public var title:String;
		public var description:String = "";
		public var useful:Boolean;
		public var processed:Boolean = false;
		public var uploadedable:Boolean = false;
		public var uploaded:Boolean = false;
		public var returned:Boolean = false;
		
		
		public function Model_ERALogItem() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {
			// grab out the case info
			var eraLogItem:XML = rawData.meta["ERA-log"][0];
			
			// set the type of the item (e.g. video, image etc)
			this.type = eraLogItem["type"];
			
			// set the title of the item
			this.title = eraLogItem["title"];
			
			// set the description if  its there (optional)
			if(eraLogItem["description"]) {
				this.description = eraLogItem["description"];
			}
			
			// set if this item is useful
			this.useful = eraLogItem["useful"] == "true";
			
			
			// set if this item has been processed
			this.processed = eraLogItem["processed"] == "true";
			
			// show if this item is uploadable
			this.uploadedable = eraLogItem["uploadable"] == "true";
			
			// show if this item has been uploaded
			this.uploaded = eraLogItem["uploaded"] == "true";
			
			// show if this item has been returned
			this.returned = eraLogItem["returned"] == "true";
		}
	}
}