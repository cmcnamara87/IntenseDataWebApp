package Model {
	
	public class Model_ERAProject extends Model_Base {
	
		public var dueDate:String;
		public var packageSize:String;
		public var day:String;
		public var month:String;
		public var year:String;
		
		public function Model_ERAProject() {
			super();
		}
		
		// Sets the specific data for the collection type
		override protected function setSpecificData():void {		
			this.dueDate = rawData.meta["ERA-project"]["due_date"];
			this.packageSize = rawData.meta["ERA-project"]["package_size"];
			
			var dateArray:Array = dueDate.split("-");
			this.day = dateArray[0];
			this.month = dateArray[1];
			
			var yearArray:Array = (dateArray[2] as String).split(" ");
			this.year = yearArray[0];
			
		}
	}
}