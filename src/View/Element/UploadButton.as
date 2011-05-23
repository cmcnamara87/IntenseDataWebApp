package View.Element {
	
	import Controller.RecensioEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	public class UploadButton extends RecensioUIComponent {
		
		[Embed(source="Assets/Template/upload_icon.png")] 
		[Bindable] private var uploadIcon:Class;
		private var uploadIconData:BitmapData;
		
		private var uploadAreaIcon:RecensioUIComponent = new RecensioUIComponent();
		private var mouseOverState:Boolean = false;
		private var _chosenFile:Boolean = false;
		
		public function UploadButton() {
			uploadIconData = (new uploadIcon() as Bitmap).bitmapData;
			addChild(uploadAreaIcon);
			super();
		}
		
		// Called when a file has been chosen
		public function chosenFile():void {
			_chosenFile = true;
		}
		
		// Sets the icon of the upload area based on the media type
		public function setIconData(data:BitmapData):void {
			uploadIconData = data;
			draw();
		}
		
		// Sets the mouseover state for the button
		public function setMouseOver(state:Boolean):void {
			mouseOverState = state;
			draw();
		}
		
		// Redraws the upload button area
		override protected function draw():void {
			this.graphics.clear();
			var imgWidth:Number = 77;
			var imgHeight:Number = 100;
			if(_chosenFile) {
				this.graphics.lineStyle(1,0x999999);
				this.graphics.beginFill(0xFFFFFF,1);
				imgWidth = 112;//60;
				imgHeight = 112;//60;
				uploadAreaIcon.x = 4;//30;
				uploadAreaIcon.y = 4;//30;
			} else {
				if(mouseOverState) {
					this.graphics.beginFill(0x336699,1);
				} else {
					this.graphics.beginFill(0x999999,1);
				}
				uploadAreaIcon.x = 22;
				uploadAreaIcon.y = 10;
			}
			this.graphics.drawRoundRect(0,0,120,120,16);
			uploadAreaIcon.graphics.clear();
			uploadAreaIcon.graphics.beginBitmapFill(uploadIconData);
			uploadAreaIcon.graphics.drawRect(0,0,imgWidth,imgHeight);
		}
	}
}