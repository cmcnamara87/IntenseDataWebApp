package View.Element {
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class UploadProgress extends RecensioUIComponent {
		
		private var progressHeight:Number = 60;
		private var percentDone:Number = 0;
		private var progressText:TextField = new TextField();
		private var progressTextFormat:TextFormat = new TextFormat();
		private var mouseOverState:Boolean = false;
		
		public function UploadProgress() {
			setupText();
			super();
		}
		
		// Toggles the mouse over
		public function setMouseOver(state:Boolean):void {
			mouseOverState = state;
			draw();
		}
		
		// Sets up the progress bar text
		private function setupText():void {
			progressText.y = 10;
			progressText.text = "Click here to select a media file";
			progressText.selectable = false;
			progressText.embedFonts = true;
			progressText.mouseEnabled = false;
			progressText.antiAliasType = AntiAliasType.ADVANCED;
			progressTextFormat.font = "HelveticaBold";
			progressTextFormat.size = 30;
			progressTextFormat.color = 0x333333;
			progressTextFormat.align = TextFormatAlign.CENTER;
			
			progressText.setTextFormat(progressTextFormat);
			progressText.defaultTextFormat = progressTextFormat;
			addChild(progressText);
		}
		
		// Changes the text for the progress bar
		public function setProgress(newText:String,percentage:String):void {
			var extra:String = "";
			if(percentage == "notready") {
				extra = "";
			} else if(percentage == "ready") {
				extra = " (ready)";
			} else if(percentage == "uploading") {
				extra = " (uploading)";
			} else {
				if(Number(percentage) > 100) {
					trace("OVER 100%!!!");
					percentage = "100";
				}
				extra = " ("+percentage+"%)";
				setPercentage(percentage);
			}
			progressText.text = newText+extra;
			progressText.setTextFormat(progressTextFormat);
		}
		
		// Sets the percentage done of the file upload for the redraw 
		private function setPercentage(percentage:String):void {
			percentDone = Number(percentage);
			draw();
		}
		
		// Redraw the progress bar
		override protected function draw():void {
			this.graphics.clear();
			if(mouseOverState) {
				this.graphics.lineStyle(1,0x336699);
				progressTextFormat.color = 0x336699;
			} else {
				this.graphics.lineStyle(1,0x999999);
				progressTextFormat.color = 0x333333;
			}
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0,0,this.width,progressHeight);
			if(percentDone > 0) {
				this.graphics.beginFill(0xDDDDFF);
				this.graphics.lineStyle(0,0x000000,0.001);
				this.graphics.drawRect(1,1,this.width*(percentDone/100)-1,progressHeight-1);
			}
			progressText.width = this.width;
			progressText.setTextFormat(progressTextFormat);
		}
	}
}