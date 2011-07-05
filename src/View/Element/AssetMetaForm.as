package View.Element {
	
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	public class AssetMetaForm extends RecensioUIComponent {
		
		private var optionsArea:AssetOptionsForm = new AssetOptionsForm();
		
		// Sets up the options form content
		public function AssetMetaForm() {
			super();
			addChild(optionsArea);
			optionsArea.width = 960;
			optionsArea.updateAssetInformation.visible = false;
			optionsArea.meta_creativeworktype.dataProvider = AssetLookup.creativeworktypeLookup;
			optionsArea.meta_creativeworksubtype.dataProvider = AssetLookup.creativeworksubtypeLookup;
			optionsArea.meta_creativeworktype.selectedIndex = 0;
			optionsArea.meta_creativeworksubtype.selectedIndex = 0;
		}
		
		// INIT
		override protected function init(e:Event):void {
			super.init(e);
			setTimeout(initialresize,100);
			setupFormEventListeners();
		}
		
		// Listens for changes in the form
		private function setupFormEventListeners():void {
			optionsArea.meta_file_title.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_description.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_datepublished.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_subject.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_keywords.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_othercontrib.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_sponsorfunder.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_creativeworktype.addEventListener(Event.CHANGE,check); 
			optionsArea.meta_creativeworksubtype.addEventListener(Event.CHANGE,check);
		}
		
		// Tells the listener that the form has changed
		private function check(e:Event):void {
			dispatchEvent(new IDEvent(IDEvent.FORM_CHANGED));
		}
		
		// Initial resize of stage once the form has loaded
		private function initialresize():void {
			this.stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		// Draws the form area
		override protected function draw():void {
			if(this.width > optionsArea.width) {
				optionsArea.x = (this.width - optionsArea.width)/2;
			}
			optionsArea.y = 5;
			this.graphics.clear();
			this.graphics.lineStyle(1,0xCCCCCC);
			this.graphics.beginFill(0xEEEEEE,1);
			this.graphics.drawRoundRect(0,0,this.width,150, 0);//,16);
		}
		
		// Checks whether valid information has been entered into the form (required fields only)
		public function validate():Boolean {
			if(
				optionsArea.meta_file_title.text != "" //&& 
//				optionsArea.meta_description.text != "" && 
//				optionsArea.meta_datepublished.text != "" && 
//				optionsArea.meta_subject.text != "" && 
//				optionsArea.meta_keywords.text != "" && 
//				optionsArea.meta_othercontrib.text != "" && 
//				optionsArea.meta_sponsorfunder.text != "" && 
//				optionsArea.meta_creativeworktype.selectedItem != "" && 
//				optionsArea.meta_creativeworksubtype.selectedItem != "" 
			) {
				return true;
			} else {
				return false;
			}
		}
		
		// Locks the form from editing
		public function lock():void {
			optionsArea.meta_file_title.enabled = false; 
			optionsArea.meta_description.enabled = false; 
			optionsArea.meta_datepublished.enabled = false; 
			optionsArea.meta_subject.enabled = false; 
			optionsArea.meta_keywords.enabled = false; 
			optionsArea.meta_othercontrib.enabled = false; 
			optionsArea.meta_creativeworktype.enabled = false; 
			optionsArea.meta_creativeworksubtype.enabled = false; 
			optionsArea.meta_sponsorfunder.enabled = false;
		}
		
		// Gets all data from the form
		public function getData():Object {
			var data:Object = new Object();
			data.meta_file_title = optionsArea.meta_file_title.text; 
			data.meta_description = optionsArea.meta_description.text; 
			data.meta_datepublished = optionsArea.meta_datepublished.text; 
			data.meta_subject = optionsArea.meta_subject.text; 
			data.meta_keywords = optionsArea.meta_keywords.text; 
			data.meta_othercontrib = optionsArea.meta_othercontrib.text; 
			data.meta_creativeworktype = optionsArea.meta_creativeworktype.selectedItem; 
			data.meta_creativeworksubtype = optionsArea.meta_creativeworksubtype.selectedItem; 
			data.meta_sponsorfunder = optionsArea.meta_sponsorfunder.text;
			return data;
		}
	}
}