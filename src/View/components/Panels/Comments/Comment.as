package View.components.Panels.Comments
{
//	import Model.Model_Annotation;
	
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import View.Layout;
	import View.components.PanelElement;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;

	public class Comment extends VGroup implements PanelElement
	{
		private var assetID:Number;
		private var reply:Boolean;
		private var creator:String;
		private var commentText:String;
		private var deleteButton:Button;	
		
		private var comment:Label;
		/**
		 * Creates a comment 
		 * @param assetID		The ID of the comment in the database
		 * @param creator		The creator of the comment
		 * @param commentText	The text for the comment
		 * @param reply			True/false if the comment is a reply or not.
		 * 
		 */		
		public function Comment(assetID:Number, creator:String, commentText:String, reply:Boolean)
		{
			super();

			this.assetID = assetID;
			this.reply = reply;
			this.creator = creator;
			this.commentText = commentText;
			
			// Setup size
			this.percentWidth = 100;
			
			// Setup layout
			this.gap = 0;
			
			// Create a new HGroup for the 'reply bump' and the Username+comment
			var myHGroup:HGroup = new HGroup();
			myHGroup.percentWidth = 100;
			myHGroup.gap = 0;
			this.addElement(myHGroup);
			
			if(reply) {
				// its a reply, so add a little vertical strip
				// so the comment is slightly inset
				var replyInset:Canvas = new Canvas();
				replyInset.setStyle('backgroundColor', 0xAAAAAA);
				replyInset.width = 10;
				replyInset.percentHeight = 100;
				myHGroup.addElement(replyInset);
			}
			
			// Create a new VGroup for the Username and Comment text
			var usernameAndComment:VGroup = new VGroup();
			usernameAndComment.percentWidth = 100;
			// Setup layout
			usernameAndComment.gap = 5;
			usernameAndComment.paddingLeft = 10;
			usernameAndComment.paddingRight = 10;
			usernameAndComment.paddingTop = 10;
			usernameAndComment.paddingBottom = 10;
			myHGroup.addElement(usernameAndComment);
			
			var username:spark.components.Label = new spark.components.Label();
			// Get the Capitalised first letter of hte username (should be persons name, but whatever)
			username.text = creator.substr(0,1).toUpperCase() + creator.substr(1)
			username.percentWidth = 100;
			username.setStyle('color', 0x1F65A2);
			username.setStyle('fontWeight', 'bold');
			usernameAndComment.addElement(username);
			
			comment = new spark.components.Label();
			comment.text = commentText;
			comment.percentWidth = 100;
			usernameAndComment.addElement(comment);
			if(commentText == "Comment Removed") {
				comment.setStyle("fontStyle", "italic");
			}
			
			// Create a HGroup for the buttons
			var buttonHGroup:HGroup 	= new HGroup();
			buttonHGroup.percentWidth 	= 100;
			buttonHGroup.paddingBottom 	= 5;
			buttonHGroup.paddingTop 	= 5;
			buttonHGroup.paddingLeft 	= 5;
			buttonHGroup.paddingRight 	= 5;
			usernameAndComment.addElement(buttonHGroup);
			
			// Create the reply button
			var replyButton:Button 		= new Button();
			replyButton.percentHeight 	= 100;
			replyButton.percentWidth 	= 100;
			replyButton.label 			= "Reply";
			if(!reply) {
				// Only add the button, if this isnt a reply
				// You cant reply to a reply.
				buttonHGroup.addElement(replyButton);
			}
			
			// If the current user is the author of this comment
			// then add an Edit and a Delete button
			if(creator == Auth.getInstance().getUsername() || Auth.getInstance().isSysAdmin()) {
				// Create the Edit Button
				var editButton:Button 		= new Button();
				editButton.percentHeight	= 100;
				editButton.percentWidth 	= 100;
				editButton.label			= "Edit";
				buttonHGroup.addElement(editButton);
				editButton.visible = false;
				editButton.includeInLayout = false;
				
				// Create a Delete button
				trace("Is sys-admin?", Auth.getInstance().isSysAdmin());
				if(commentText != "Comment Removed" || Auth.getInstance().isSysAdmin()) {
					deleteButton		= new Button();
					deleteButton.percentHeight 	= 100;
					deleteButton.percentWidth	= 100;
					deleteButton.label			= "Delete";
					buttonHGroup.addElement(deleteButton);
				}
			}
			
			// Add a horizontal rule at the bottom of the comment
			var hLine:Line = new Line();
			hLine.percentWidth = 100;
			hLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			this.addElement(hLine);
			
			
			/* ============ EVENT LISTENERS ================= */
			replyButton.addEventListener(MouseEvent.CLICK, replyButtonClicked);
			if(deleteButton) {
				deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked);
			}
		}
		
		/* ============ EVENT LISTENER FUNCTIONS ===================== */
		/**
		 * Called when reply button is clicked. Stores this comment, and sends it to @see CommentsPanel
		 * @param e	The click event.
		 * 
		 */		
		private function replyButtonClicked(e:MouseEvent):void {
			trace("Reply button clicked");
			var myEvent:IDEvent = new IDEvent(IDEvent.COMMENT_REPLY, true);
			// Store this comment in the event, so @see CommentPanel can play the reply comment
			// after this one.
			myEvent.data.replyToComment = this;
			
			this.dispatchEvent(myEvent);
		}
		
		private function deleteButtonClicked(e:MouseEvent):void {
			trace("Delete Button Clicked");
			//(view as AssetView).navbar.deselectButtons();
			var myAlert:Alert = Alert.show("Are you sure you want to delete this comment?", "Delete Comment", Alert.OK | Alert.CANCEL, null, 
				deleteButtonOkay, null, Alert.CANCEL);
			
			myAlert.height=100;
			myAlert.width=300;
		}
		
		private function deleteButtonOkay(e:CloseEvent):void {
			if (e.detail == Alert.OK) {
				var myEvent:IDEvent = new IDEvent(IDEvent.COMMENT_DELETE, true);
				myEvent.data.assetID = this.assetID;
				this.dispatchEvent(myEvent);
				
				comment.text = "Comment Removed";
				comment.setStyle("fontStyle", "italic");
				deleteButton.includeInLayout = false;
				deleteButton.visible = false;
//				this.visible = false;
//				this.height = 0;
			}
		}
		
		/* GETTERS/SETTERS */
		public function getID():Number {
			return assetID;
		}
		
		public function isReply():Boolean {
			return reply;
		}
		
		public function searchMatches(search:String):Boolean {
			if(creator.toLowerCase().indexOf(search.toLowerCase()) == -1 && commentText.toLowerCase().indexOf(search.toLowerCase()) == -1) {
				return false;
			} else {
				return true;
			}
		}
	}
}