package View.Element {
	import Controller.RecensioEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import spark.components.TextInput;
	
	public class CollectionTitlebar extends RecensioUIComponent {
		
		[Embed(source="Assets/Template/assetpreview_bg.png")] 
		private var backgroundAssetImage:Class;
		private var backgroundAssetImageData:BitmapData;
		
		private var collectionTitle:TextField = new TextField();
		private var collectionTitleFormat:TextFormat = new TextFormat();
		private var editButton:SmallButton = new SmallButton("Edit",true);
		
		private var deleteButton:SmallButton = new SmallButton("Delete",true);
		private var saveButton:SmallButton = new SmallButton("Save",true);
		private var cancelButton:SmallButton = new SmallButton("Cancel",true);
		private var createButton:SmallButton = new SmallButton("Create",true);
		private var createCancelButton:SmallButton = new SmallButton("Cancel ",true);
		private var mouseOverToggle:Boolean = false;
		private var collectionEditTitle:TextInput = new TextInput();
		private var _editmode:Boolean = false;
		private var _newCollection:Boolean = false;
		
		public function CollectionTitlebar() {
			super();
			backgroundAssetImageData = (new backgroundAssetImage as Bitmap).bitmapData;
			setButtonMode(true);			
		}
		
		// Sets the title of the collection
		public function setTitle(newTitle:String):void {
			collectionTitle.text = newTitle;
			collectionTitle.type = TextFieldType.INPUT;
			collectionEditTitle.text = collectionTitle.text;
		}
		
		// Sets whether the collection is being edited
		public function titleEditing(isEditing:Boolean):void {
			if(isEditing) {
				collectionEditTitle.text = collectionTitle.text;
				addChild(collectionEditTitle);
			} else {
				if(contains(collectionEditTitle)) {
					removeChild(collectionEditTitle);
				}
			}
		}
		
		// Whether its a new collection or not
		public function setNewMode(isNew:Boolean):void {
			_newCollection = isNew;
			showSaveButton(false);
		}
		
		public function showSaveButton(shown:Boolean):void {
			if(shown) {
				createButton.visible = true;
			} else {
				createButton.visible = false;
			}
		}
		
		// Setup the buttons for the titlebar
		override protected function init(e:Event):void {
			super.init(e);
			setupText();
			
			editButton.width = 60;
			editButton.height = 20;
			editButton.y = (Collection.titlebarHeight-editButton.height)/2;
			editButton.addEventListener(MouseEvent.MOUSE_UP,titleButtonClicked);
			
			deleteButton.width = 80;
			deleteButton.height = 20;
			deleteButton.y = (Collection.titlebarHeight-deleteButton.height)/2;
			deleteButton.addEventListener(MouseEvent.MOUSE_UP,titleButtonClicked);
			
			saveButton.width = 40;
			saveButton.height = 20;
			saveButton.y = (Collection.titlebarHeight-editButton.height)/2;
			saveButton.addEventListener(MouseEvent.MOUSE_UP,titleButtonClicked);
			
			cancelButton.width = 60;
			cancelButton.height = 20;
			cancelButton.y = (Collection.titlebarHeight-deleteButton.height)/2;
			cancelButton.addEventListener(MouseEvent.MOUSE_UP,titleButtonClicked);
			
			createButton.width = 54;
			createButton.height = 20;
			createButton.y = (Collection.titlebarHeight-editButton.height)/2;
			createButton.addEventListener(MouseEvent.MOUSE_UP,titleButtonClicked);
			
			createCancelButton.width = 60;
			createCancelButton.height = 20;
			createCancelButton.y = (Collection.titlebarHeight-deleteButton.height)/2;
			createCancelButton.addEventListener(MouseEvent.MOUSE_UP,titleButtonClicked);
			
			setEditMode(false);
		}
		
		// Setup the titlebar
		private function setupText():void {
			
			collectionEditTitle.width = 200;
			collectionEditTitle.height = Collection.titlebarHeight;
			collectionEditTitle.setStyle("fontSize","16");
			collectionEditTitle.setStyle("paddingLeft","11");
			collectionEditTitle.setStyle("paddingTop","6");
			
			collectionTitleFormat.size = 16;
			collectionTitle.x = 10;
			collectionTitle.y = 10;
			collectionTitle.embedFonts = true;
			collectionTitle.selectable = false;
			collectionTitle.mouseEnabled = false;
			collectionTitleFormat.font = "Helvetica";
			collectionTitleFormat.color = 0x444444;
			collectionTitle.defaultTextFormat = collectionTitleFormat;
			collectionTitle.setTextFormat(collectionTitleFormat);
			addChild(collectionTitle);
			collectionTitle.height = Collection.titlebarHeight - collectionTitle.y;
		}
		
		// Redraw the titlebar
		override protected function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFF0000,0.5);
			this.graphics.beginBitmapFill(backgroundAssetImageData);
			if(mouseOverToggle) {
				this.graphics.lineStyle(1,0x2c78bf,1);
				collectionTitleFormat.color = 0x2c78bf;
				collectionTitle.setTextFormat(collectionTitleFormat);
			} else {
				this.graphics.lineStyle(1,0xb5b8ba,1);
				collectionTitleFormat.color = 0x444444;
				collectionTitle.setTextFormat(collectionTitleFormat);
			}
			this.graphics.drawRect(0,0,Collection.theWidth,Collection.titlebarHeight);
			collectionTitle.width = Collection.theWidth-200;
			collectionEditTitle.width = collectionTitle.width;
			deleteButton.x = Collection.theWidth - deleteButton.width - deleteButton.y*2;
			editButton.x = deleteButton.x - editButton.width - editButton.y;
			
			cancelButton.x = Collection.theWidth - cancelButton.width - cancelButton.y*2;
			saveButton.x = deleteButton.x - saveButton.width - saveButton.y;
			createCancelButton.x = Collection.theWidth - createCancelButton.width - createCancelButton.y*2;
			createButton.x = createCancelButton.x - createButton.width - createButton.y;
		}
		
		// New collection 
		public function newMode(newmode:Boolean):void {
			titleEditing(true);
			addChild(createButton);
			addChild(createCancelButton);
			if(this.stage) {
				this.stage.focus = collectionEditTitle;
			}
		}
		
		// Sets whether the collection titlebar is in edit or viewing mode
		public function setEditMode(editmode:Boolean):void {
			if(!_newCollection) { 
				_editmode = editmode;
				titleEditing(editmode);
				if(editmode) {
					if(contains(editButton)) {
						removeChild(editButton);
					}
					if(contains(deleteButton)) {
						removeChild(deleteButton);
					}
					addChild(saveButton);
					addChild(cancelButton);
				} else {
					if(contains(saveButton)) {
						removeChild(saveButton);
					}
					if(contains(cancelButton)) {
						removeChild(cancelButton);
					}
					addChild(editButton);
					addChild(deleteButton);
				}
			} else {
				newMode(true);
			}
		}
		
		// Force redraw
		public function forceDraw():void {
			draw();
		}
		
		// Mouse event
		override protected function mouseOver(e:MouseEvent):void {
			if(!_editmode) {
				mouseOverToggle = true;
				draw();
			}
		}
		
		// Mouse event
		override protected function mouseOut(e:MouseEvent):void {
			if(!_editmode) {
				mouseOverToggle = false;
				draw();
			}
		}
		
		// Mouse event
		override protected function mouseDown(e:MouseEvent):void {
			if(!_editmode) {
				alpha = 0.8;
			}
		}
		
		// Mouse event
		override protected function mouseUp(e:MouseEvent):void {
			alpha = 1;
			if(!_editmode && !_newCollection) {
				this.dispatchEvent(new RecensioEvent(RecensioEvent.COLLECTION_CLICKED));
			}
		}
		
		// When the title button for the collection is clicked
		private function titleButtonClicked(e:MouseEvent):void {
			var rec:RecensioEvent = new RecensioEvent(RecensioEvent.COLLECTION_NAV_CLICKED);
			rec.data.buttonName = (e.target as SmallButton).getText();
			if(rec.data.buttonName == "Save" || rec.data.buttonName == "Create") {
				rec.data.updatedTitle = collectionEditTitle.text;
			}
			dispatchEvent(rec);
		}
	}
}