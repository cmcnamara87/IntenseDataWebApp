package View.Element {
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Model.Model_Media;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.controls.Image;
	
	public class AssetPreviewMedia extends AssetPreview {
		
		// Sets up the asset preview
		public function AssetPreviewMedia(assetData:Model_Media) {
			super(assetData);			
		}
		
		protected override function drawImageIcon():void {
			// Clear the current icon
			image.graphics.clear();
			// Set up the assets image
			var previewimagedata:BitmapData = AssetLookup.getAssetImage((_data as Model_Media).type);
			image.graphics.beginBitmapFill(previewimagedata);
			image.graphics.drawRect(0,0,imageSize,imageSize);
		}
		
		public override function matchesString(term:String):Boolean {
			term = term.toLowerCase();
			if(
				(_data as Model_Media).meta_subject.toLowerCase().indexOf(term) != -1 ||
				(_data as Model_Media).meta_keywords.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_authorcreated.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_othercontrib.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_sponsorfunder.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_creativeworktype.toLowerCase().indexOf(term) != -1 ||
				//_data.meta_creativeworksubtype.toLowerCase().indexOf(term) != -1 ||
				(_data as Model_Media).type.toLowerCase().indexOf(term) != -1 ||
				(_data as Model_Media).meta_title.toLowerCase().indexOf(term) != -1 ||
				(_data as Model_Media).meta_description.toLowerCase().indexOf(term) != -1
			) {
				return true;
			}
			return false;
		}
	}
}