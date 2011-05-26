package View.components.Comments
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.accessibility.TextAccImpl;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.TextArea;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class NewComment extends VGroup
	{
		private var newComment:TextArea; // The textarea for typing the new comment.
		private var replyingToID:Number = 0; // The ID this is replying to. Is 0 when not a reply
		
		/**
		 * Creates a new comment (editable style) 
		 * @param reply	True is this is a reply, false otherwise.
		 * 
		 */		
		public function NewComment(replyingToID:Number = 0)
		{
			super();
			
			// The Comment this is replying to
			// If its not replying to any, its set to 0;
			this.replyingToID = replyingToID;
			trace("New Comment Created in Reply To", replyingToID);
			
			// Setup size
			this.percentWidth = 100;
			// Setup layout
			this.gap = 0;
			
			// Create a new HGroup for the 'reply bump' and the Username+comment
			var myHGroup:HGroup = new HGroup();
			myHGroup.percentWidth = 100;
			myHGroup.gap = 0;
			this.addElement(myHGroup);
			
			if(replyingToID > 0) {
				// its a reply, so add a little vertical strip
				// so the comment is slightly inset
				var replyInset:Canvas = new Canvas();
				replyInset.setStyle('backgroundColor', 0xAAAAAA);
				replyInset.width = 10;
				replyInset.percentHeight = 100;
				myHGroup.addElement(replyInset);
			}
			
			// Create a new VGroup for the Username and Text Input
			var usernameAndComment:VGroup = new VGroup();
			
			usernameAndComment.percentWidth = 100;
			// Setup layout
			usernameAndComment.paddingLeft = 10;
			usernameAndComment.paddingRight = 10;
			usernameAndComment.paddingTop = 10;
			usernameAndComment.paddingBottom = 10;
			myHGroup.addElement(usernameAndComment);

			var username:Label = new Label();
			// Get the Capitalised first letter of hte username (should be persons name, but whatever)
			username.text = Auth.getInstance().getUsername().substr(0,1).toUpperCase() + Auth.getInstance().getUsername().substr(1)
			username.percentWidth = 100;
			username.setStyle('color', 0x1F65A2);
			username.setStyle('fontWeight', 'bold');
			usernameAndComment.addElement(username);
			
			newComment = new TextArea();
			newComment.percentWidth = 100;
			newComment.height = 100;
			usernameAndComment.addElement(newComment);
			
			// Create a HGroup for the buttons
			var buttonHGroup:HGroup 	= new HGroup();
			buttonHGroup.percentWidth 	= 100;
			buttonHGroup.paddingBottom 	= 5;
			buttonHGroup.paddingTop 	= 5;
			buttonHGroup.paddingLeft 	= 5;
			buttonHGroup.paddingRight 	= 5;
			usernameAndComment.addElement(buttonHGroup);
			
			// Create the Save button
			var saveButton:Button 		= new Button();
			saveButton.percentHeight 	= 100;
			saveButton.percentWidth 	= 100;
			saveButton.label 			= "Save";
			buttonHGroup.addElement(saveButton);
			
			// Create the Edit Button
			var cancelButton:Button 	= new Button();
			cancelButton.percentHeight	= 100;
			cancelButton.percentWidth 	= 100;
			cancelButton.label			= "Cancel";
			buttonHGroup.addElement(cancelButton);

			// Add a horizontal rule.
			var hLine:Line = new Line();
			hLine.percentWidth = 100;
			hLine.stroke = new SolidColorStroke(0xEEEEEE,1,1);
			this.addElement(hLine);
			
			
			/* ======= SETUP EVENT LISTENERS ========== */
			saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			cancelButton.addEventListener(MouseEvent.CLICK, cancelButtonClicked);
			
		}
		
		/* ========== EVENT LISTENER FUCNTIONS =================== */
		/**
		 * Called when saved button is clicked. SEnds new comment to controller. 
		 * @param e
		 * 
		 */		
		private function saveButtonClicked(e:MouseEvent):void {
			trace('Save button clicked');
			var clickEvent:IDEvent = new IDEvent(IDEvent.COMMENT_SAVED, true);
			clickEvent.data.commentText = newComment.text;
			
			// Send the ID of the comment its replying to, 0 if not a reply.
			clickEvent.data.replyingToID = replyingToID;
			
			clickEvent.data.newCommentObject = this;
			this.dispatchEvent(clickEvent);
		}
		
		/**
		 * Called when cancel button is clicked. Caught by CommentsPanel 
		 * @param e
		 * 
		 */		
		private function cancelButtonClicked(e:MouseEvent):void {
			trace('Cancel button clicked');
			var clickEvent:IDEvent = new IDEvent(IDEvent.COMMENT_CANCELLED, true);
			clickEvent.data.newCommentObject = this;
			this.dispatchEvent(clickEvent);
		}
		
		/* ============== GETTERS/SETTERS =================== */
		public function getCommentText():String {
			return newComment.text;
		}
		
		public function isReply():Boolean {
			// The ID stored is 0 if not a reply, and otherwise, its a reply
			return (replyingToID > 0);
		}
	}
}