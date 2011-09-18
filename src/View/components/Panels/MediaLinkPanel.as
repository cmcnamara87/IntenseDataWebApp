package View.components.Panels
{
	import Controller.IDEvent;
	
	import Model.Model_Media;
	
	import View.components.AssetTile.AssetTile;
	import View.components.GoodBorderContainer;
	
	import spark.components.HGroup;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	
	public class MediaLinkPanel extends GoodBorderContainer
	{
		private var contents:HGroup;
		private const EXPANDED_SIZE:Number = 160;
		
		public function MediaLinkPanel()
		{
			super(0xDDDDDD, 1, 0x555555, 1);
			this.percentWidth = 100;
			this.height = 0;
			
			var scrollTest:Scroller = new Scroller();
			scrollTest.percentHeight = 100;
			scrollTest.percentWidth = 100;
			this.addElement(scrollTest);
//			
//			// Lets make a panel so we can stick all the media in it, and keep it centered
//			var centeringGroup:VGroup = new VGroup();
//			centeringGroup.horizontalAlign = HorizontalAlign.CENTER;
//			centeringGroup.percentWidth = 100;
//			scrollTest.viewport = centeringGroup;
			
			contents = new HGroup();
			scrollTest.viewport = contents;
//			this.addElement(contents);
		}
		
		public function hide():void {
			this.height = 0;
		}
		
		public function show():void {
			this.height = 160;
		}
		
		public function addMedia(modelMediaArray:Array):void {
			for each(var something:Model_Media in modelMediaArray) {
				var tile:AssetTile = new AssetTile(something, IDEvent.ASSET_ADD_AS_REF_COMMENT);
				contents.addElement(tile);
			}
		
		}
	}
}