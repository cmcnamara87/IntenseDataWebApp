package View.Element {
	import Controller.RecensioEvent;
	import Controller.Utilities.AssetLookup;
	
	import Model.Model_Commentary;
	import Model.Model_Collection;
	import Model.Model_Media;
	
	import flash.events.MouseEvent;
	
	
	public class AssetOptions extends RecensioUIComponent {
		
		public var optionsForm:AssetOptionsForm = new AssetOptionsForm();
		private var inset:Number = 10;
		
		public function AssetOptions() {
			super();
			this.addChild(optionsForm);
			optionsForm.meta_creativeworktype.dataProvider = AssetLookup.creativeworktypeLookup;
			optionsForm.meta_creativeworksubtype.dataProvider = AssetLookup.creativeworksubtypeLookup;
			optionsForm.meta_creativeworktype.selectedIndex = 0;
			optionsForm.meta_creativeworksubtype.selectedIndex = 0;
			optionsForm.updateAssetInformation.addEventListener(MouseEvent.CLICK,updateInformation);
		}
		
		// Dispatches an event containing the form information
		private function updateInformation(e:MouseEvent):void {
			var rec:RecensioEvent = new RecensioEvent(RecensioEvent.ASSET_UPDATE);
			rec.data.meta_title = optionsForm.meta_title.text;
			rec.data.meta_description = optionsForm.meta_description.text;
			rec.data.meta_datepublished = optionsForm.meta_datepublished.text;
			rec.data.meta_subject = optionsForm.meta_subject.text;
			rec.data.meta_keywords = optionsForm.meta_keywords.text;
			rec.data.meta_othercontrib = optionsForm.meta_othercontrib.text;
			rec.data.meta_sponsorfunder = optionsForm.meta_sponsorfunder.text;
			rec.data.meta_creativeworksubtype = optionsForm.meta_creativeworksubtype.selectedItem;
			rec.data.meta_creativeworktype = optionsForm.meta_creativeworktype.selectedItem;
			dispatchEvent(rec);
		}
		
		// Sets the form information based on model values
		public function setFormValuesMedia(data:Model_Media):void {
			optionsForm.meta_title.text = data.meta_title;
			optionsForm.meta_description.text = data.meta_description;
			optionsForm.meta_datepublished.text = data.meta_datepublished+"";
			optionsForm.meta_subject.text = data.meta_subject;
			optionsForm.meta_keywords.text = data.meta_keywords;
			optionsForm.meta_othercontrib.text = data.meta_othercontrib;
			optionsForm.meta_sponsorfunder.text = data.meta_sponsorfunder;
			optionsForm.meta_creativeworksubtype.selectedItem = data.meta_creativeworksubtype;
			optionsForm.meta_creativeworktype.selectedItem = data.meta_creativeworktype;
		}
		// Sets the form information based on model values
		public function setFormValuesCollection(data:Model_Collection):void {
			optionsForm.meta_title.text = data.meta_title;
			optionsForm.meta_description.text = data.meta_description;
			optionsForm.meta_datepublished.enabled = false;
			optionsForm.meta_subject.enabled = false;
			optionsForm.meta_keywords.enabled = false;
			optionsForm.meta_othercontrib.enabled = false;
			optionsForm.meta_sponsorfunder.enabled = false;
			optionsForm.meta_creativeworksubtype.enabled = false;
			optionsForm.meta_creativeworktype.enabled = false;
		}
		
		// Redraw (and reposition of the form)
		override protected function draw():void {
			drawBackground();
			optionsForm.y = inset*2+15;
		}
		
		// Redraws the background
		private function drawBackground():void {
			this.graphics.clear();
			this.graphics.beginFill(0xdddddd,1);
			this.graphics.lineStyle(1,0xb9b9bb);
			var theHeight:Number = this.height-40;
			var innerHeight:Number = theHeight-inset*2;
			if(theHeight < 0) {
				theHeight = 0;
				innerHeight = 0;
			}
			this.graphics.drawRoundRect(0,40,this.width,theHeight,12);
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawRoundRect(inset,40+inset,this.width-inset*2,innerHeight,12);
		}
	}
}