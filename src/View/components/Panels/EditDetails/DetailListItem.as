package View.components.Panels.EditDetails
{
	import Controller.Utilities.AssetLookup;
	
	import View.components.PanelElement;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DateField;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.VGroup;
	import spark.primitives.Line;

	public class DetailListItem extends VGroup implements PanelElement
	{
		private var detailName:String;
		private var textArea:TextArea;
		private var dropdownArea:DropDownList;
		private var dateArea:DateField;
		private var type:String;
		
		public function DetailListItem(detailName:String, detailValue:String, type:String="text", options:ArrayCollection=null)
		{
			super();
			this.type = type;
			this.detailName = detailName;
			
			this.percentWidth = 100;
			
			// Setup layout
			this.paddingLeft = 10;
			this.paddingRight = 10;
			this.paddingTop = 10;
			this.paddingBottom = 10;
			
			var fieldName:Label = new Label();
			
			fieldName.text = detailName;
			fieldName.percentWidth = 100;
			fieldName.setStyle('color', 0x1F65A2);
			fieldName.setStyle('fontWeight', 'bold');
			this.addElement(fieldName);
			
			if(type == "text") {
				textArea = new TextArea();
				textArea.percentWidth = 100;
				textArea.height = 40;
				textArea.text = detailValue;
				this.addElement(textArea);
			} else if (type == "dropdown") {
				dropdownArea = new DropDownList();
				dropdownArea.dataProvider = options;
				dropdownArea.percentWidth = 100;
				dropdownArea.selectedItem = detailValue;
				this.addElement(dropdownArea);
			} else if (type == "date") {
				dateArea = new DateField();
				dateArea.percentWidth = 100;
				dateArea.formatString = "DD/MM/YYYY";
				dateArea.text = detailValue;
				this.addElement(dateArea);
			}
			
			// Add a horizontal rule.
			var hLine:Line = new Line();
			hLine.percentWidth = 100;
			hLine.stroke = new SolidColorStroke(0xEEEEEE,1,1);
			this.addElement(hLine);
			
		}
		
		public function getName():String {
			return detailName;
		}
		
		public function getValue():String {
			if(type == "text") {
				return textArea.text;
			} else if (type == "dropdown") {
				return dropdownArea.selectedItem;
			} else if (type == "date") {
				return dateArea.text;
			}
			return "";
		}
		
		public function searchMatches(search:String):Boolean {
			if(detailName.toLowerCase().indexOf(search.toLowerCase()) == -1) {
				return false;
			} else {
				return true;
			}
		}
	}
}