package View.Element {
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Model.Model_Collection;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.controls.Image;
	
	public class AssetPreviewCollection extends AssetPreview {
		
		// Sets up the asset preview
		public function AssetPreviewCollection(assetData:Model_Collection) {
			super(assetData);			
		}
		
		protected override function drawImageIcon():void {
			// Clear the current icon
			image.graphics.clear();
			// Set up the assets image
			var previewimagedata:BitmapData = AssetLookup.getAssetImage('collection');
			image.graphics.beginBitmapFill(previewimagedata);
			image.graphics.drawRect(0,0,imageSize,imageSize);
		}
		
		public override function matchesString(term:String):Boolean {
			term = term.toLowerCase();
			if(
				(_data as Model_Collection).meta_title.toLowerCase().indexOf(term) != -1 ||
				//(_data as Model_Collection).meta_keywords.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_authorcreated.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_othercontrib.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_sponsorfunder.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_creativeworktype.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_creativeworksubtype.toLowerCase().indexOf(term) != -1 ||
				//(_data as Model_Collection).type.toLowerCase().indexOf(term) != -1 ||
				//(_data as Model_Collection).meta_title.toLowerCase().indexOf(term) != -1 ||
				(_data as Model_Collection).meta_description.toLowerCase().indexOf(term) != -1
			) {
				return true;
			}
			return false;
		}
	}
}