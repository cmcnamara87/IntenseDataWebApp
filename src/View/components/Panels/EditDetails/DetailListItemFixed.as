package View.components.Panels.EditDetails
{
	import View.components.IDGUI;
	import View.components.PanelElement;
	
	import mx.controls.DateField;
	import mx.controls.TextArea;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class DetailListItemFixed extends VGroup implements PanelElement
	{
		private var detailName:String;
		private var detailValue:String;
		private var textArea:TextArea;
		private var dropdownArea:DropDownList;
		private var dateArea:DateField;
		private var type:String;
		
		public function DetailListItemFixed(detailName:String, detailValue:String, type:String="text")
		{
			super();
			this.type = type;
			this.detailName = detailName;
			this.detailValue = detailValue;
			
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
			
			var fieldData:Label = new Label();
			fieldData.percentWidth = 100;
			fieldData.text = detailValue;
			this.addElement(fieldData);

			// Add a horizontal rule.
			var hLine:Line = IDGUI.makeLine(0xEEEEEE);
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
		
		/**
		 * Checks if either the name of the field, or the fields content
		 * matches a search string 
		 * @param search	The search string to match
		 * @return 			True if found, false if not
		 * 
		 */		
		public function searchMatches(search:String):Boolean {
			// If we cant match either the detailname or the detailvalue, return false, else, we found it
			if(detailName.toLowerCase().indexOf(search.toLowerCase()) == -1 && detailValue.toLowerCase().indexOf(search.toLowerCase()) == -1) {
				return false;
			} else {
				return true;
			}
		}
	}
}