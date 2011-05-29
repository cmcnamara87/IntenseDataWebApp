package View.components
{
	import Controller.IDEvent;
	
	import Model.Model_Collection;
	import Model.Model_Media;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	public class Shelf extends BorderContainer
	{
		private var myAssetDisplayer:AssetDisplayer; // Displays the assets as tiles
		private var collectionTextInput:TextInput; // the collection name input
		/**
		 * The shelf is where items can be temporarily stored, and makes collections.
		 * Scrolls up from the bottom of the page. 
		 * Consists of a text entry box, and a assetdisplayer
		 */		
		public function Shelf()
		{
			super();
			
			// Setup the Layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			//this.borderStroke = new SolidColorStroke(0x999999, 1);
			this.setStyle("borderVisible", false);
			
			// Add the Collection Name Entry Box
			var collectionTitleBox:BorderContainer = new BorderContainer();
			// Setup its size			
			collectionTitleBox.percentWidth = 100;
			collectionTitleBox.height = 50;
			// Background colour
			var myFill:LinearGradient = new LinearGradient();
			myFill.rotation = 90;
			var myFillColor:GradientEntry = new GradientEntry(0xFFFF99);
			var myFillColor1:GradientEntry = new GradientEntry(0xFFFF00);
			myFill.entries=[myFillColor, myFillColor1];
			this.backgroundFill = myFill;
			collectionTitleBox.backgroundFill = myFill
			// Setup stroke color
			collectionTitleBox.borderStroke = new SolidColorStroke(0xDDDDDD,1, 1);
			//Layout
			var collectionTitleBoxLayout:HorizontalLayout = new HorizontalLayout();
			collectionTitleBoxLayout.verticalAlign = "middle";
			collectionTitleBoxLayout.paddingLeft = 10;
			collectionTitleBoxLayout.paddingRight = 10;
			collectionTitleBoxLayout.paddingTop = 10;
			collectionTitleBoxLayout.paddingBottom = 10;
			collectionTitleBox.layout = collectionTitleBoxLayout;
			this.addElement(collectionTitleBox);
			
			// Add the Text Entry to the Collection Name Entry Box
			collectionTextInput = new TextInput();
			collectionTextInput.percentWidth = 100;
			collectionTextInput.percentHeight = 100;
			collectionTitleBox.addElement(collectionTextInput);
			
			// Add 'Save' Button
			var saveButton:Button = new Button();
			saveButton.label = "Save Collection";
			saveButton.percentHeight = 100;
			collectionTitleBox.addElement(saveButton);
			
			// Add the Asset Displayer
			myAssetDisplayer = new AssetDisplayer(IDEvent.SHELF_MEDIA_CLICKED, true);
			// Setup the size
			myAssetDisplayer.percentHeight = 100;
			myAssetDisplayer.percentWidth = 100;
			this.addElement(myAssetDisplayer);
			
			// Listen for Save Button clicked
			saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
				
			
		}
		
		/**
		 * Add a media tile to the display 
		 * @param 	asset	A media object
		 * 
		 */	
		public function addMediaAsset(asset:Model_Media):void {
			myAssetDisplayer.addMediaAsset(asset);
		}
		
		public function removeMediaAsset(assetID:Number):void {
			myAssetDisplayer.removeMediaAsset(assetID);
		}
		
		/**
		 * Removes the current Assets being displayed 
		 */		
		public function clearMediaAssets():void {
			myAssetDisplayer.clearMediaAssets();
			collectionTextInput.text = "";
		}
		
		public function setCollectionName(name:String):void {
			collectionTextInput.text = name;
		}
		
		public function refreshMediaAssetsDisplay():void {
			myAssetDisplayer.refreshMediaAssetsDisplay();
		}
		
		/* ======================================== EVENT LISTENERS ======================================== */
		/**
		 * Called when save button is clicked. Sends the name of the collection to the controller 
		 * to make the collection. Doesn't need to send    
		 * @param e the mouse click event
		 * @return 
		 * 
		 */		
		private function saveButtonClicked(e:MouseEvent):void {
			trace("Save Button Clicked");
			// Only if a name has been given, save the collection
			if(collectionTextInput.text != "") {
				trace("with name", collectionTextInput.text);
				var clickEvent:IDEvent = new IDEvent(IDEvent.COLLECTION_SAVE, true);
				clickEvent.data.collectionTitle = collectionTextInput.text
					
				// Clear the 'collection name' entered (so its clear for next time :)
				collectionTextInput.text = "";
				this.dispatchEvent(clickEvent);
			}
			
		}
		
		
	}
}