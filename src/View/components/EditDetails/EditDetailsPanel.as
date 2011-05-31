package View.components.EditDetails
{
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import Model.Model_Media;
	
	import View.components.Panel;
	import View.components.SubToolbar;
	
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.Button;
	import mx.controls.Label;
	
	import spark.components.Group;

	public class EditDetailsPanel extends Panel
	{
		private var assetID:Number;
		private var metaTitle:DetailListItem;
		private var metaDescription:DetailListItem;
		private var metaDatePublished:DetailListItem;
		private var metaSubject:DetailListItem;
		private var metaKeywords:DetailListItem;
		private var metaOtherContrib:DetailListItem;
		private var metaCreativeWorkType:DetailListItem;
		private var metaCreativeWorkSubType:DetailListItem;
		private var metaSponsorFunder:DetailListItem;
		
		
		private var subToolbarLabel:Label;
	
		public function EditDetailsPanel()
		{
			super();
			
			// Set heading on the panel
			setHeading("Edit Details");
			
			// Add 'Add Comment' Button to toolbar
			var saveDetailsButton:Button = new Button();
			saveDetailsButton.label = "Save";
			saveDetailsButton.percentHeight = 100;
			toolbar.addElement(saveDetailsButton);
			
			// Add the close button to the panel
			var closeButton:Button = new Button();
			closeButton.label = "X";
			closeButton.percentHeight = 100;
			closeButton.width = 30;
			toolbar.addElement(closeButton);

			subToolbarLabel = new Label();
			subToolbarLabel.setStyle('fontWeight', 'bold');
			subToolbarLabel.setStyle('textAlign', 'left');
			subToolbarLabel.setStyle('color', 0x000000);
			subToolbarLabel.setStyle('fontSize', 14);
			subToolbarLabel.percentWidth = 100;
			subToolbar.addElement(subToolbarLabel);
			
			// Event Listenrs
			saveDetailsButton.addEventListener(MouseEvent.CLICK, saveDetails);
			
			
			///this.addEventListener(Event.CHANGE, checkBoxClicked);
			
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
		}
		
		
		/* ===================== PUBLIC FUNCTIONS USED BY CONTROLER ========================== */
		
		public function addDetails(mediaData:Model_Media):void {
			
			assetID = mediaData.base_asset_id;
			
			trace("Adding Details to Edit Details Panel");
			metaTitle = new DetailListItem("Title", mediaData.meta_title);
			content.addElement(metaTitle);
			
			metaDescription = new DetailListItem("Description", mediaData.meta_description);
			content.addElement(metaDescription);
			
			metaDatePublished = new DetailListItem("Date Published", mediaData.meta_datepublished,"date");
			content.addElement(metaDatePublished);
			
			metaSubject = new DetailListItem("Subject", mediaData.meta_subject);
			content.addElement(metaSubject);

			metaKeywords = new DetailListItem("Keywords", mediaData.meta_keywords);
			content.addElement(metaKeywords);
			
			metaOtherContrib = new DetailListItem("Other Contributors", mediaData.meta_othercontrib);
			content.addElement(metaOtherContrib);
			
			metaCreativeWorkType = new DetailListItem("Creative Work Type", mediaData.meta_creativeworktype,"dropdown",AssetLookup.creativeworktypeLookup);
			content.addElement(metaCreativeWorkType);
			
			metaCreativeWorkSubType = new DetailListItem("Creative Work Subtype", mediaData.meta_creativeworksubtype,"dropdown",AssetLookup.creativeworksubtypeLookup);
			content.addElement(metaCreativeWorkSubType);

			metaSponsorFunder = new DetailListItem("Sponsor/Funder", mediaData.meta_sponsorfunder);
			content.addElement(metaSponsorFunder);
		}
		
		public function detailsSaved(success:Boolean, msg:String=""):void {
			if(success) {
				this.showSubToolbar(SubToolbar.GREEN, "Saved.");
			} else {
				this.showSubToolbar(SubToolbar.RED, "Failed.");
			}
			setTimeout(hideSubToolbar, 1000);
		}
		
		public function getTitle():String {
			return metaTitle.getValue();
		}
		
		/* ======== EVENT LISTENER FUNCTIONS ======================= */
		private function closeButtonClicked(e:MouseEvent):void {
			this.width = 0;
		}
		
		private function saveDetails(e:MouseEvent):void {
			trace("Trying to save details");
			var myEvent:IDEvent = new IDEvent(IDEvent.ASSET_UPDATE, true);
			var data:Object = myEvent.data;
			data.assetID = assetID;
			data.meta_title = metaTitle.getValue(); 
			data.meta_description = metaDescription.getValue(); 
			data.meta_datepublished = metaDatePublished.getValue(); 
			data.meta_subject = metaSubject.getValue(); 
			data.meta_keywords = metaKeywords.getValue(); 
			data.meta_othercontrib = metaOtherContrib.getValue(); 
			data.meta_creativeworktype = metaCreativeWorkType.getValue(); 
			data.meta_creativeworksubtype = metaCreativeWorkSubType.getValue(); 
			data.meta_sponsorfunder = metaSponsorFunder.getValue();
			
			
			this.dispatchEvent(myEvent);
			
			this.showSubToolbar(SubToolbar.YELLOW, "Saving...");
		}
		
		private function showSubToolbar(color:uint, text:String = ""):void {
			subToolbar.setColor(color);
			subToolbarLabel.visible = true;
			subToolbarLabel.text = text;	
			subToolbar.height = SubToolbar.SUB_TOOLBAR_HEIGHT;
			subToolbar.visible = true;
		}
		
		private function hideSubToolbar():void {
			subToolbar.height = 0;
			subToolbarLabel.visible = false;
		}

	}
}