package Module.ImageViewer
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.UIComponent;
	
	public class ImageProgress extends UIComponent {
		
		private var imagePercentage:Number = 0;
		private var percentText:TextField = new TextField();
		private var percentTextFormat:TextFormat = new TextFormat();
		
		public function ImageProgress() {
			super();
			this.width = 200;
			this.height = 80;
			setupBackground();
			setupText();
		}
		
		// Sets the percentage loaded of the progress bar text
		public function setPercentage(newPercentage:Number):void {
			imagePercentage = newPercentage;
			percentText.text = "Loading ("+imagePercentage+"%)";
		}
		
		// Draws the background of the progress bar
		private function setupBackground():void {
			this.graphics.beginFill(0x333333,0.8);
			this.graphics.drawRoundRect(0,0,this.width,this.height,12);
		}
		
		// Setup of the text for the progress bar
		private function setupText():void {
			percentText.text = "Loading ("+imagePercentage+"%)";
			percentText.width = 200;
			percentText.y = 25;
			percentTextFormat.color = 0xFFFFFF;
			percentTextFormat.size = 24;
			percentTextFormat.align = TextFormatAlign.CENTER;
			percentTextFormat.font = "Arial";
			percentText.setTextFormat(percentTextFormat);
			percentText.defaultTextFormat = percentTextFormat;
			addChild(percentText);
		}
	}
}