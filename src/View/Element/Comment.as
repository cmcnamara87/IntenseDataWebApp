package View.Element {
	
	import Controller.RecensioEvent;
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	
	import mx.controls.TextInput;
	
	import spark.components.TextArea;
	
	public class Comment extends RecensioUIComponent {
		
		public static var commentWidth:Number = 100;
		public static var commentHeight:Number = 124;
		public var theHeight:Number = 124;
		private var menu:CommentMenu;
		private var rawData:Model_Commentary;
		private var commentText:TextField = new TextField();
		private var commentTextFormat:TextFormat = new TextFormat();
		private var commentTextInput:TextArea = new TextArea();
		private var dateText:TextField = new TextField();
		private var dateTextFormat:TextFormat = new TextFormat();
		private var authorText:TextField = new TextField();
		private var authorTextFormat:TextFormat = new TextFormat();
		private var _editMode:Boolean = false;
		public var newComment:Boolean = false;
		public var newCommentID:Number = 0;
		private var myComment:Boolean = false;
		private var isReply:Boolean = false;
		
		public function Comment(data:Model_Commentary) {
			newCommentID = Math.random()*999999;
			this.rawData = data;
			if(rawData.annotation_start > 0) {
				isReply = true;
			}
			if(rawData.meta_creator == Auth.getInstance().getUsername() || "manager" == Auth.getInstance().getUsername()) {
				menu = new CommentMenu(true,isReply);
			} else {
				menu = new CommentMenu(false,isReply);
			}
			setupTextAreas();
			draw();
			super();
		}
		
		// Return the timestamp for the comment (for sorting)
		public function get timestamp():String {
			return rawData.base_ctime;
		}
		
		// INIT
		override protected function init(e:Event):void {
			setTimeout(resize,200);
			menu.addEventListener(RecensioEvent.COMMENT_NAV_CLICKED,navClicked);
			addChild(menu);
		}
		
		// Get the ID of the comment
		public function getID():Number {
			return rawData.base_asset_id;
		}
		
		// Setup the comment view
		private function setupTextAreas():void {
			commentText.text = rawData.annotation_text;
			addChild(commentText);
			commentText.x = 10;
			commentTextInput.x = 0;
			if(isReply) {
				commentText.x = 20;
				commentTextInput.x = 10;
			}
			commentText.y = 10;
			commentText.multiline = true;
			commentText.wordWrap = true;
			commentText.embedFonts = true;
			commentTextFormat.font = "Helvetica";
			commentTextFormat.size = 16;
			commentText.setTextFormat(commentTextFormat);
			commentText.defaultTextFormat = commentTextFormat;
			
			commentTextInput.y = 0;
			commentTextInput.addEventListener(Event.ADDED_TO_STAGE,forceFocusWithDelay);
			commentTextInput.setStyle("fontSize",16);
			commentTextInput.setStyle("paddingTop",20);
			commentTextInput.setStyle("paddingLeft",11);
			commentTextInput.setStyle("borderColor","#2D5282");
			
			authorText.text = rawData.meta_creator.substr(0,1).toUpperCase()+rawData.meta_creator.substr(1);
			if(rawData.annotation_start > 0) {
				rawData.reply_id = rawData.annotation_start;
				authorText.appendText(" (reply)");
			}
			addChild(authorText);
			authorText.x = 10;
			if(isReply) {
				authorText.x = 20;
			}
			authorText.y = theHeight;
			authorText.embedFonts = true;
			authorTextFormat.color = 0x3B5998;
			authorTextFormat.font = "HelveticaBold";
			authorTextFormat.size = 16;
			authorTextFormat.align = TextFormatAlign.LEFT;
			authorText.setTextFormat(authorTextFormat);
			authorText.defaultTextFormat = authorTextFormat;
			
			dateText.text = ''+rawData.formatDate(rawData.getCreationDate(),"YYYY-MM-DD HH:NN:SS");
			addChild(dateText);
			dateText.x = 10;
			dateText.y = theHeight;
			dateText.embedFonts = true;
			dateTextFormat.color = 0x333333;
			dateTextFormat.font = "Helvetica";
			dateTextFormat.size = 10;
			dateTextFormat.align = TextFormatAlign.RIGHT;
			dateText.setTextFormat(dateTextFormat);
			dateText.defaultTextFormat = dateTextFormat;
		}
		
		// Force focus on the comment text input
		private function forceFocusWithDelay(e:Event):void {
			this.stage.focus = commentTextInput;
			flash.utils.setTimeout(forceFocus,100);
		}
		
		// Focus on the comment text input
		private function forceFocus():void {
			this.stage.focus = commentTextInput;
		}
		
		// Forces the comment to redraw
		public function forcedraw():void {
			draw();
			menu.forceResize();
		}
		
		// Redraw the comment
		override protected function draw():void {
			drawBackground();
			drawText();
			menu.x = 1;
			menu.y = theHeight - menu.height;
		}
		
		// Draws the comment text
		private function drawText():void {
			commentText.width = commentWidth-commentText.x-20;
			commentText.height = commentText.textHeight+10;
			theHeight = commentText.height+20+80;
			commentTextInput.width = commentWidth - 20;
			commentTextInput.height = theHeight - menu.height;
			dateText.width = commentWidth-dateText.x-20;
			authorText.width = commentWidth-authorText.x-20;
			
			authorText.y = 8;
			dateText.y = theHeight - 20 - menu.height;
			
			commentText.y = 30;
			commentTextInput.y = 0;
			
		}
		
		// Says whether the comment is a reply
		public function commentIsReply():Boolean {
			return this.isReply;
		}
		
		// Returns the reply ID
		public function getReplyID():Number {
			return rawData.reply_id;
		}
		
		// Draws the background for the comment
		private function drawBackground():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawRect(1,1,commentWidth-1,theHeight-1);
			this.graphics.lineStyle(1,0x929292);
			this.graphics.moveTo(0,theHeight);
			this.graphics.lineTo(commentWidth,theHeight);
			this.graphics.lineStyle(0,0x929292);
			if(rawData.reply_id > 0) {
				this.graphics.lineStyle(0,0x999999,0.1);
				this.graphics.beginFill(0xCCCCCC,1);
				this.graphics.drawRect(1,1,10,theHeight-1);
			}
		}
		
		// Sets whether the comment is in editing or viewing mode
		public function setEditMode(editing:Boolean):void {
			menu.setEditMode(editing);
			_editMode = editing;
			if(_editMode) {
				if(contains(commentText)) {
					removeChild(commentText);
				}
				addChild(commentTextInput);
				commentTextInput.text = rawData.annotation_text;
				if(this.stage) {
					this.stage.focus = commentTextInput;
				}
			} else {
				if(contains(commentTextInput)) {
					removeChild(commentTextInput);
				}
				addChild(commentText);
			}
		}
		
		// When the comment navigation is clicked (edit, save etc)
		private function navClicked(e:RecensioEvent):void {
			if(e.data.action == "Edit") {
				setEditMode(true);
			} else if (e.data.action == "Cancel") {
				//if replying or creating a comment, need to remove it, otherwise need to restore old data
				setEditMode(false);
			} else if (e.data.action == "Save") {
				//this is where we send it off for a save
				newComment = false;
				rawData.annotation_text = commentTextInput.text;
				commentText.text = commentTextInput.text;
				commentText.setTextFormat(commentTextFormat);
				setEditMode(false);
				draw();
			}
			var recEvent:RecensioEvent = new RecensioEvent(RecensioEvent.COMMENT_NAV_CLICKED);
			recEvent.data.action = e.data.action;
			recEvent.data.assetID = rawData.base_asset_id;
			recEvent.data.tmpID = newCommentID;
			recEvent.data.annotation_text = rawData.annotation_text;
			trace("The comments text is", recEvent.data.annotation_text);
			recEvent.data.reply_id = rawData.reply_id;
			recEvent.data.commentObject = this;
			this.dispatchEvent(recEvent);
		}
		
		// Called when the comment is saved (to update the comment ID in case of later editing)
		public function commentSaved(e:Event):void {
			rawData.base_asset_id = XML(e.target.data).reply.result.id;
			AppModel.getInstance().setAnnotationClass(e);
			var recEvent:RecensioEvent = new RecensioEvent(RecensioEvent.COMMENT_NAV_CLICKED);
			recEvent.data.action = "comment_id_set";
			this.dispatchEvent(recEvent);
		}
	}
}