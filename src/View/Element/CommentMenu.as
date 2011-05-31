package View.Element {
	
	import Controller.IDEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	public class CommentMenu extends RecensioUIComponent {
		
		[Embed(source="Assets/Template/commentmenu_bg.png")] 
		private var backgroundImage:Class;
		private var backgroundImageData:BitmapData;
		
		private var replyButton:SmallButton = new SmallButton("Reply");
		private var editButton:SmallButton = new SmallButton("Edit");
		private var deleteButton:SmallButton = new SmallButton("Delete");
		
		private var saveButton:SmallButton = new SmallButton("Save");
		private var cancelButton:SmallButton = new SmallButton("Cancel");
		
		private var _editMode:Boolean = false;
		private var _owner:Boolean = false;
		private var _reply:Boolean = false;
		
		public function CommentMenu(owner:Boolean=false,reply:Boolean=false) {
			_reply = reply;
			_owner = owner;
			super();
			backgroundImageData = (new backgroundImage as Bitmap).bitmapData; 
			this.width = 220;
			this.height = 24;
			addButtons();
		}
		
		// Add the menu buttons for a comment
		private function addButtons():void {
			replyButton.addEventListener(MouseEvent.MOUSE_UP,buttonClicked);
			replyButton.toolTip = "Reply to this comment";
			replyButton.width = 70;
			replyButton.height = this.height-1;
			replyButton.x = 8;
			replyButton.y = 1;
			
			editButton.addEventListener(MouseEvent.MOUSE_UP,buttonClicked);
			editButton.toolTip = "Edit this comment";
			editButton.width = 60;
			editButton.height = this.height-1;
			editButton.x = replyButton.x+replyButton.width;
			editButton.y = 1;
			
			deleteButton.addEventListener(MouseEvent.MOUSE_UP,buttonClicked);
			deleteButton.toolTip = "Permanently delete this comment and all replies";
			deleteButton.width = 80;
			deleteButton.height = this.height-1;
			deleteButton.x = editButton.x+editButton.width;
			deleteButton.y = 1;
			
			saveButton.addEventListener(MouseEvent.MOUSE_UP,buttonClicked);
			saveButton.toolTip = "Update this comment";
			saveButton.width = 60;
			saveButton.height = this.height-1;
			saveButton.x = 8;
			saveButton.y = 1;
			
			cancelButton.addEventListener(MouseEvent.MOUSE_UP,buttonClicked);
			cancelButton.toolTip = "Revert this comment";
			cancelButton.width = 60;
			cancelButton.height = this.height-1;
			cancelButton.x = saveButton.x+saveButton.width;
			cancelButton.y = 1;
			
			setEditMode(false);
		}
		
		// Sets the buttons to show or hide depending on whether the comment is in editing mode
		public function setEditMode(editing:Boolean):void {
			this.removeAllChildren();
			_editMode = editing;
			if(_editMode) {
				addChild(saveButton);
				addChild(cancelButton);
			} else {
				if(!_reply) {
					addChild(replyButton);
				}
				if(_owner) {
					addChild(editButton);
					addChild(deleteButton);
				}
			}
		}
		
		// Called when a menu button is clicked
		private function buttonClicked(e:MouseEvent):void {
			var buttonClickEvent:IDEvent = new IDEvent(IDEvent.COMMENT_NAV_CLICKED);
			buttonClickEvent.data.action = e.target.getText();
			this.dispatchEvent(buttonClickEvent);
		}
		
		// Redraw
		override protected function draw():void {
			drawBackground();
		}
		
		// Redraw the menu
		private function drawBackground():void {
			this.width = Comment.commentWidth;
			this.graphics.clear();
			this.graphics.beginBitmapFill(backgroundImageData);
			this.graphics.drawRect(0,0,this.width,this.height);
			this.graphics.lineStyle(1,0xd4d4d4);
			this.graphics.moveTo(0,0);
			this.graphics.lineTo(this.width,0);
			this.graphics.lineStyle(0,0xd4d4d4);
		}
	}
}