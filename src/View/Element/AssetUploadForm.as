package View.Element {
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	
	public class AssetUploadForm extends RecensioUIComponent {
		
		private var uploadArea:UploadButton = new UploadButton();
		private var mouseOverState:Boolean = false;
		private var uploadProgress:UploadProgress = new UploadProgress();
		private var _fileChosen:Boolean = false;
		private var _currentText:String = "";
		
		public function AssetUploadForm() {
			drawInterface();
			this.setButtonMode(true);
			super();
		}
		
		// Draws the interface for the upload area
		private function drawInterface():void {
			addChild(uploadArea);
			addChild(uploadProgress);
			uploadArea.x = 20;
			uploadArea.y = 20;
			uploadProgress.x = 160;
			uploadProgress.y = 50;
		}
		
		// Redraw
		override protected function draw():void {
			uploadProgress.width = this.width - uploadProgress.x - 20;
			this.graphics.clear();
			if(mouseOverState) {
				this.graphics.lineStyle(1,0x336699);
			} else {
				this.graphics.lineStyle(1,0xCCCCCC);
			}
			this.graphics.beginFill(0xEEEEEE,1);
			this.graphics.drawRoundRect(0,0,this.width,160,0);//16);
		}
		
		// Sets the progress of the upload
		public function setProgress(newText:String,percentage:String):void {
			if(newText != "") {
				// TODO CRAIG only matches last 3 characters, should relaly fix this up
				// for things like JPEG, only matches 'peg', which is fine, since no other allowed
				// file string has PEG in it.
				var extension:String =  newText.substr(newText.length-3).toLowerCase();
				trace("extension is", extension);
				var fileTypes:Array = AssetLookup.getFileTypes();
				var fileType:String = "";
				for(var i:Number=0; i<fileTypes.length; i++) {
					if((fileTypes[i] as FileFilter).extension.indexOf(extension) > -1) {
						fileType = AssetLookup.checkFileFilterType(fileTypes[i]);
					}
				}
				if(fileType != "") {
					_fileChosen = true;
					uploadArea.chosenFile();
					uploadArea.setIconData(AssetLookup.getAssetImage(fileType));
				}
				_currentText = newText;
			} else {
				newText = _currentText;
			}
			uploadProgress.setProgress(newText,percentage);
			dispatchEvent(new IDEvent(IDEvent.FORM_CHANGED));
			draw();
		}
		
		// Locks the upload area from choosing another file
		public function lock():void {
			this.setButtonMode(false);
			uploadProgress.setProgress("","uploading");
		}
		
		// Mouse Event
		private function setMouseOver(state:Boolean):void {
			mouseOverState = state;
			uploadArea.setMouseOver(state);
			uploadProgress.setMouseOver(state);
		}
		
		// Returns whether a file has been chosen
		public function validate():Boolean {
			return _fileChosen;
		}
		
		// Mouse Event
		override protected function mouseOver(e:MouseEvent):void {
			setMouseOver(true);
			draw();
		}
		
		// Mouse Event
		override protected function mouseOut(e:MouseEvent):void {
			setMouseOver(false);
			this.alpha = 1;
			draw();
		}
		
		// Mouse Event
		override protected function mouseDown(e:MouseEvent):void {
			this.alpha = 0.8;
		}
		
		// Mouse Event (upload button clicked)
		override protected function mouseUp(e:MouseEvent):void {
			this.alpha = 1;
			this.dispatchEvent(new IDEvent(IDEvent.UPLOAD_CLICKED));
		}
	}
}