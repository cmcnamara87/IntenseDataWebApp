package Model {
	
	public class Model_ERALogItem extends Model_Base {
		
		private var type:String;
		private var title:String;
		private var description:String = "";
		private var useful:Boolean;
		private var processed:Boolean;
		private var uploadedable:Boolean;
		private var uploaded:Boolean;
		private var returned:Boolean;
		
		
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