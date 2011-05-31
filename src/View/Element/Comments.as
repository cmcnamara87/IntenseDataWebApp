package View.Element {
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	import Controller.Utilities.UserPreferences;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.core.Container;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	
	public class Comments extends RecensioUIComponent {
		
		public static const LEFTPADDING:Number = 40;
		private var container:Container = new Container();
		private var commentsPadding:Number = 10;
		public static const TOPSPACE:Number = 40;
		private var commentsArray:Array = new Array();
		private var addCommentButton:SmallButton = new SmallButton("Add Comment",true);
		
		private var resizeStrip:RecensioUIComponent = new RecensioUIComponent();
		private var resizeOldX:Number;
		private var resizeTimer:Timer = new Timer(30);
		
		public function Comments() {
			this.width = 280;
			super();
			addChild(container);
			
			// Setup Button
			addCommentButton.toolTip = "Create a new comment on this media.";
			addCommentButton.addEventListener(MouseEvent.CLICK,addCommentClick);
			addChild(addCommentButton);
			
			addChild(resizeStrip);
			resizeStrip.addEventListener(MouseEvent.MOUSE_DOWN,beginResize);
			resizeTimer.addEventListener(TimerEvent.TIMER,doResize);
			
			container.x = LEFTPADDING + 1;
			container.y = TOPSPACE + 1;
			container.horizontalScrollPolicy = "off";
		}
		
		// INIT
		override protected function init(e:Event):void {
			super.init(e);
		}
		
		// Redraw
		override protected function draw():void {
			drawBackground();
			drawAddCommentButton();
		}
		
		// Starts resizing the comments panel
		private function beginResize(e:MouseEvent):void {
			resizeOldX = stage.mouseX;
			stage.addEventListener(MouseEvent.MOUSE_UP,stopResize);
			resizeTimer.start();
		}
		
		// Resize the comments pane
		private function doResize(e:TimerEvent):void {
			this.parent.width = this.parent.width+(resizeOldX-stage.mouseX);
			if(this.parent.width < 260) {
				this.parent.width = 260;
			}
			resizeOldX = stage.mouseX;
			draw();
			refreshView();
		}
		
		// Stops resizing the comments panel
		private function stopResize(e:MouseEvent):void {
			resizeTimer.stop();
			UserPreferences.commentsWidth = this.parent.width;
		}
		
		// Sets up the "add comment" button
		private function drawAddCommentButton():void {
			addCommentButton.width = 120;
			addCommentButton.height = 22;
			addCommentButton.y = 9;
			addCommentButton.x = this.width-addCommentButton.width-commentsPadding;
		}
		
		// Adds an array of comments
		public function addComments(comments:Array):void {
			for(var i:Number=0; i<comments.length; i++) {
				addComment(comments[i] as Model_Commentary);
			}
			setTimeout(refreshView,100);
		}
		
		// Adds a comment, then refreshes the view
		public function addComment(commentData:Model_Commentary):void {
			var tmpComment:Comment = new Comment(commentData);
			tmpComment.addEventListener(IDEvent.COMMENT_NAV_CLICKED,commentNavClicked);
			commentsArray.push(tmpComment);
			refreshView();
		}
		
		// Removes a comment
		private function removeComment(theComment:Comment):void {
			if(theComment.hasEventListener(IDEvent.COMMENT_NAV_CLICKED)) {
				theComment.removeEventListener(IDEvent.COMMENT_NAV_CLICKED,commentNavClicked);
			}
			commentsArray.splice(commentsArray.indexOf(theComment),1);
		}
		
		// Repositions all of the comments
		public function refreshView():void {
			trace("REFRESHING VIEW");
			sortComments();
			var yPosition:Number = 0;
			container.removeAllChildren();
			for(var i:Number=0; i<commentsArray.length; i++) {
				container.addChild(commentsArray[i]);
				commentsArray[i].y = yPosition;
				(commentsArray[i] as Comment).forcedraw();
				yPosition += (commentsArray[i] as Comment).theHeight;
			}
		}
		
		// Sorts the comments based on time descending
		private function sortComments():void {
			var sortReplies:Boolean = true;
			var tmpComments:Array = commentsArray;
			tmpComments.sortOn("timestamp",Array.DESCENDING);
			if(sortReplies) {
				var baseComments:Array = new Array();
				var replyComments:Array = new Array();
				for(var i:Number=tmpComments.length-1; i>-1; i--) {
					if((tmpComments[i] as Comment).commentIsReply()) {
						replyComments.push(tmpComments[i]);
					} else {
						baseComments.push(tmpComments[i]);
					}
				}
				baseComments.sortOn("timestamp",Array.DESCENDING);
				replyComments.sortOn("timestamp");
				for(var j:Number=replyComments.length-1; j>-1; j--) {
					for(var k:Number=baseComments.length-1; k>-1; k--) {
						if((baseComments[k] as Comment).getID() == (replyComments[j] as Comment).getReplyID()) {
							baseComments.splice(k+1,0,replyComments[j]);
							break;
						}
					}
				}
			}
			commentsArray = baseComments;
		}
		
		// Removes all comments
		public function removeComments():void {
			for(var i:Number=0; i<commentsArray.length; i++) {
				removeComment(commentsArray[i]);
			}
			container.removeAllChildren();
		}
		
		// Removes a specific comment by its asset ID
		public function removeCommentById(assetID:Number):void {
			for(var i:Number=0; i<commentsArray.length; i++) {
				if(assetID == (commentsArray[i] as Comment).getID()) {
					removeComment((commentsArray[i] as Comment));
				}
			}
			refreshView();
		}
		
		// Creates a new comment
		private function addCommentClick(e:MouseEvent):void {
			trace('creating comment');
			createComment();
		}
		
		// Sets up and adds a new comment in edit mode
		public function createComment(replyID:Number=0):void {
			var data:Model_Commentary = new Model_Commentary();
			data.base_asset_id = -1;
			data.annotation_text = "";
			data.reply_id = replyID;
			data.annotation_start = replyID;
			data.meta_creator = Auth.getInstance().getUsername();
			data.base_ctime = (new Date()).getTime()+"";
			var tmpComment:Comment = new Comment(data);
			tmpComment.addEventListener(IDEvent.COMMENT_NAV_CLICKED,commentNavClicked);
			commentsArray.reverse();
			commentsArray.push(tmpComment);
			tmpComment.newComment = true;
			tmpComment.setEditMode(true);
			commentsArray.reverse();
			refreshView();
			if(replyID==0) {
				container.verticalScrollPosition = 0;
			} else {
				if(tmpComment.y > 0) {
					container.verticalScrollPosition = tmpComment.y;
				}
			}
		}
		
		// Called when something in the comment menu is clicked
		private function commentNavClicked(e:IDEvent):void {
			if(e.data.action == "Cancel") {
				if((e.target as Comment).newComment) {
					removeComment((e.target as Comment));
					refreshView();
				}
			} else if(e.data.action == "Reply") {
				createComment(e.data.assetID);
			} else if(e.data.action == "comment_id_set") {
				this.refreshView();
			} else {
				var recEvent:IDEvent = new IDEvent(IDEvent.COMMENT_NAV_CLICKED);
				recEvent.data = e.data;
				this.dispatchEvent(recEvent);
			}
			refreshView();
		}
		
		// Redraws the comments area background
		private function drawBackground():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.lineStyle(1,0xb9b9bb);
			this.graphics.drawRoundRect(LEFTPADDING,0, this.width-LEFTPADDING,this.height,0);
			
			this.graphics.beginFill(0xdddddd,1);
			this.graphics.lineStyle(1,0xb9b9bb);
			this.graphics.drawRoundRect(LEFTPADDING, 0, this.width - LEFTPADDING, TOPSPACE, 0);
			
			container.width = this.width-LEFTPADDING - 2;
			container.height = this.height-TOPSPACE-1;
			Comment.commentWidth = this.width-LEFTPADDING - 1;
			
			resizeStrip.graphics.clear();
			// Draw a rectangle to the left of the comment box
			// people can click this for resizing
			resizeStrip.graphics.beginFill(0xFF0000,0.001);
			resizeStrip.graphics.drawRect(0, 0, LEFTPADDING, this.height);
		}
	}
}