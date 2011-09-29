package Model {
	
	public class Model_ERALogItem extends Model_Base {
		
		public var type:String;
		public var title:String;
		public var description:String = "";
		public var useful:Boolean;
		public var processed:Boolean;
		public var uploadedable:Boolean;
		public var uploaded:Boolean;
		public var returned:Boolean;
		
		
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
			this.useful = eraLogItem["useful"];
			
			
			// set if this item has been processed
			this.processed = eraLogItem["processed"];
			
			// show if this item is uploadable
			this.uploadedable = eraLogItem["uploadable"];
			
			// show if this item has been uploaded
			this.uploaded = eraLogItem["uploaded"];
			
			// show if this item has been returned
			this.returned = eraLogItem["returned"];
		}
	}
}