package View.components.Panels.Comments
{
//	import Model.Model_Annotation;
	
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import View.Layout;
	import View.components.IDButton;
	import View.components.IDGUI;
	import View.components.PanelElement;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.core.UIComponent;
	import mx.effects.effectClasses.AddRemoveEffectTargetFilter;
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
		private var addReferenceButton:Button;
		private var mtime:Number;
		private var deleteUpdateTimer:Timer;
//		private var comment:Label;
		private var comment:Text;
		private var newComment:TextArea;
		private var saveButton:IDButton;
		
		private var editMode:Boolean = false;
		
		/**
		 * Creates a comment gui item	 
		 * @param assetID		The asset id for the comment
		 * @param creator		The creator of the comment
		 * @param mtime			The last time the comment was modified
		 * @param commentText	The text for the comment
		 * @param reply			Is the comment a reply or not
		 * 
		 */		
		public function Comment(assetID:Number, creator:String, mtime:Number, commentText:String, reply:Boolean)
		{
			super();

			this.assetID = assetID;
			trace("comment created with asset id", assetID);
			this.reply = reply;
			this.creator = creator;
			this.commentText = commentText;
			this.mtime = mtime;
			
			// Setup size
			this.percentWidth = 100;
			
			// Setup layout
			this.gap = 0;
			
			render();
		}
		
		private function render():void {
			this.removeAllElements();
			
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
			
			var username:Text = new Text();
			// Get the Capitalised first letter of hte username (should be persons name, but whatever)
			username.text = creator.substr(0,1).toUpperCase() + creator.substr(1)
			username.percentWidth = 100;
			username.setStyle('color', 0x1F65A2);
			username.setStyle('fontWeight', 'bold');
			usernameAndComment.addElement(username);
			
			if(editMode == true) {
				trace("rendering in edit mode");
				newComment = new TextArea();
				newComment.percentWidth = 100;
				newComment.height = 100;
				newComment.text = commentText;
				usernameAndComment.addElement(newComment);
			} else {
				trace("rendering in regular mode");
	//			comment = new spark.components.Label();
				comment = new Text();
				
				var newCommentText:String = commentText;
				var startRefLocation:Number = newCommentText.indexOf("{");
				while(startRefLocation != -1) {
					trace("{ found at", startRefLocation);
					var endRefLocation:Number = newCommentText.indexOf("}", startRefLocation);
						
					if(endRefLocation == -1) {
						break;	
					}
					
					trace("} found at", endRefLocation);
					
					var colonLocation:Number = newCommentText.indexOf(":", startRefLocation);
					
					if(colonLocation == -1) {
						break;
					}
					
					trace(": found at", colonLocation);
					
					// we have everything we need
					var refAssetID:String = newCommentText.substring(colonLocation + 1, endRefLocation);
					var mediaTitle:String = newCommentText.substring(startRefLocation + 1, colonLocation);
					
					
					trace("ref ID", refAssetID);
					trace("mediaTitle", mediaTitle);
					
					// for tomorrow, get out the length of the first part, after the </a> is put in, and start seraching from there
					var replacementString = "<font color='#0000FF'><a href='#go/" + refAssetID + "'>" + mediaTitle + "</a></font>";
					newCommentText = newCommentText.substring(0, startRefLocation) + replacementString + newCommentText.substring(endRefLocation + 1);
				
					startRefLocation = newCommentText.indexOf("{", startRefLocation + replacementString);
				}
				comment.htmlText = newCommentText;
				comment.percentWidth = 100;
				usernameAndComment.addElement(comment);
				if(commentText == "Comment Removed") {
					comment.setStyle("fontStyle", "italic");
				}
			}
				
			// Create a HGroup for the buttons
			var buttonHGroup:HGroup 	= new HGroup();
			buttonHGroup.percentWidth 	= 100;
			buttonHGroup.paddingBottom 	= 5;
			buttonHGroup.paddingTop 	= 5;
			buttonHGroup.paddingLeft 	= 5;
			buttonHGroup.paddingRight 	= 5;
			usernameAndComment.addElement(buttonHGroup);
			
			if(editMode == true) {
				saveButton = new IDButton("Save");
				saveButton.percentWidth = 100;
				buttonHGroup.addElement(saveButton);

				saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
				
				var cancelButton:Button = new IDButton("Cancel");
				cancelButton.percentWidth = 100;
				buttonHGroup.addElement(cancelButton);
				cancelButton.addEventListener(MouseEvent.CLICK, function(e:Event) {
					editMode = false;
					render();
				});
				
			} else {
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
					// DEPRECATED THE EDIT BUTTON
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
						
						if(!Auth.getInstance().isSysAdmin()) {
							// Not the sys admin, put the timer on the delete button
							deleteUpdateTimer = new Timer(1000);
							deleteUpdateTimer.addEventListener(TimerEvent.TIMER, updateDeleteButtonTime);
							deleteUpdateTimer.start();
						}
					}
					
					addReferenceButton = new Button();
					addReferenceButton.percentHeight = 100;
					addReferenceButton.percentWidth = 100;
					addReferenceButton.label = "Add Ref";
					buttonHGroup.addElement(addReferenceButton);
				}
				
				// Add a horizontal rule at the bottom of the comment
				var hLine:Line = new Line();
				hLine.percentWidth = 100;
				hLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
				this.addElement(hLine);
			
			
			/* ============ EVENT LISTENERS ================= */
			
				replyButton.addEventListener(MouseEvent.CLICK, replyButtonClicked);
				if(addReferenceButton) {
					addReferenceButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
						var addReferenceEvent:IDEvent = new IDEvent(IDEvent.OPEN_REF_PANEL, true);
						addReferenceEvent.data.commentID = assetID;
						trace("dispatching event with data", assetID);
						dispatchEvent(addReferenceEvent);
						
						editMode = true;
						render();
					});
				}
				if(deleteButton) {
					deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked);
				}
			}
		}
		
		private function updateDeleteButtonTime(e:TimerEvent):void {
			var timeSinceCreated:Number = ((new Date()).getTime() - mtime) / 1000;
			var minutes:Number = Math.floor(timeSinceCreated / 60);
			
			if(minutes <= 14) {
				var seconds:Number = 60 - Math.floor(timeSinceCreated - (60 * minutes));
				
				if(seconds < 10) {
					deleteButton.label = "Delete (" + (14-minutes) + ":0" + seconds + ")";	
				} else {
					deleteButton.label = "Delete (" + (14-minutes) + ":" + seconds + ")";
				}
			} else {
				deleteButton.includeInLayout = false;
				deleteButton.visible = false;
				deleteUpdateTimer.stop();
			}
		}
		
		/* ============ EVENT LISTENER FUNCTIONS ===================== */
		
		private function saveButtonClicked(e:MouseEvent):void {
//			var myEvent:IDEvent = new
			trace("save button clicked");
			editMode = false;
			commentText = newComment.text;
			render();
			
			var myEvent:IDEvent = new IDEvent(IDEvent.COMMENT_EDITED, true);
			myEvent.data.commentID = assetID;
			myEvent.data.commentText = commentText;
			this.dispatchEvent(myEvent);
		}
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
		
		public function addReference(refAssetID:Number, refMediaTitle:String):void {
			newComment.text = newComment.text.substring(0, newComment.selectionBeginIndex) + "{" + refMediaTitle + ":" + refAssetID + "}" + newComment.text.substring(newComment.selectionEndIndex); 
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