package Model {
	
	public class Model_ERALogItem extends Model_Base {
		
		public var type:String;
		public var title:String;
		public var description:String = "";
		public var useful:Boolean;
		public var processed:Boolean = false;
		public var uploaded:Boolean = false;
		public var returned:Boolean = false;
		public var collected:Boolean = false;
		public var dataItemID:Number = 0;
		
		public static const USEFUL:String = "useful";
		public static const PROCESSED:String = "processed";
		public static const FOR_COLLECTION:String = "returned";
		public static const COLLECTED:String = "collected";
		
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

			// show if this item has been uploaded
			// we know its been uploaded, if it has a relationship to its data item
			var dataFileNumber:Number = Number(rawData.related.(@type=="datafile").to);
			if(dataFileNumber > 0) {
				dataItemID = dataFileNumber;
				this.uploaded = true;
			}
			
			// show if this item has been returned
			this.returned = eraLogItem["returned"] == "true";
			
			this.collected = eraLogItem["collected"] == "true";
		}
	}
}