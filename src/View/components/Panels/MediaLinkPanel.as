package View.components.Panels
{
	import Controller.IDEvent;
	
	import Model.AppModel;
	import Model.Model_ERAFile;
	import Model.Model_Media;
	
	import View.ERA.components.FileTile;
	import View.components.AssetTile.AssetTile;
	import View.components.GoodBorderContainer;
	
	import spark.components.HGroup;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	
	public class MediaLinkPanel extends GoodBorderContainer
	{
		private var contents:HGroup;
		private const EXPANDED_SIZE:Number = 180;
		
		public function MediaLinkPanel()
		{
			super(0x333333, 1, 0x555555, 1);
			this.percentWidth = 100;
			this.height = 0;
			
			var scrollTest:Scroller = new Scroller();
			scrollTest.percentHeight = 100;
			scrollTest.percentWidth = 100;
			this.addElement(scrollTest);
			
//			// Lets make a panel so we can stick all the media in it, and keep it centered
			var centeringGroup:VGroup = new VGroup();
			centeringGroup.horizontalAlign = HorizontalAlign.CENTER;
			centeringGroup.percentWidth = 100;
			centeringGroup.percentHeight = 100;
			
			
			contents = new HGroup();
			contents.paddingLeft = 10;
			contents.paddingTop = 10;
			centeringGroup.addElement(contents);
			
			
			scrollTest.viewport = contents;
			
//			this.addElement(contents);
		}
		
		public function hide():void {
			this.height = 0;
		}
		
		public function show():void {
			this.height = 160;
		}
		
		public function addFiles(filesArray:Array):void {
			contents.removeAllElements();
			for each(var file:Model_ERAFile in filesArray) {
				var tile:FileTile = new FileTile();
				tile.fileData = file;
				tile.fileLabel.setStyle('color', '0xFFFFFF');
				contents.addElement(tile);
				/*
				var tile:AssetTile = new AssetTile(something, IDEvent.ASSET_ADD_AS_REF_COMMENT, "0xFFFFFF");
				contents.addElement(tile); */
			}
		}
		
		public function addMedia(modelMediaArray:Array):void {
			contents.removeAllElements();
			for each(var something:Model_Media in modelMediaArray) {
				var tile:AssetTile = new AssetTile(something, IDEvent.ASSET_ADD_AS_REF_COMMENT, "0xFFFFFF");
				contents.addElement(tile);
			}
		
		}
	}
}