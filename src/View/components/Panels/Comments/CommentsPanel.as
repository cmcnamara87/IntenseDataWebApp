package View.components.Panels.Comments
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import View.BrowserView;
	import View.components.Panels.Panel;
	import View.components.Toolbar;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.sampler.Sample;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;
	
	public class CommentsPanel extends Panel
	{
		// Inherits content:VGroup and toolbar:Toolbar
		
		private var expanded:Boolean = false; // Whether or not the panel is expanded.
		private var maxMinButton:Button;
		private var addCommentButton:Button;
		
		// Stores the comment we are editing
		private static var editingCommentID:Number;
		// Stores if we have finished rendering the comments
		private var finishedRendering:Boolean = false;
		
		/**
		 * The Comments Panel sits on the right side on the main asset browser 
		 * and shows all the comments a specific collection has.
		 * 
		 * Contains a Scroller, which has a group, where the comments live.
		 */		
		public function CommentsPanel()
		{
			super();
			
			this.setHeading("Comments");
			
			
			// Add 'Add Comment' Button
			addCommentButton = new Button();
			addCommentButton.label = "Add Comment";
			addCommentButton.percentHeight = 100;
			addCommentButton.setStyle('cornerRadius', 10);
			addCommentButton.setStyle("chromeColor", "0xFFFFFF");
			toolbar.addElement(addCommentButton);
			
			var addCommentMax:Line = new Line();
			addCommentMax.percentHeight = 100;
			addCommentMax.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			toolbar.addElement(addCommentMax);
			
			// Add the 'Expand/Contract' button for the panel.
			maxMinButton = new Button();
			maxMinButton.label = "Max";
			maxMinButton.width = 40;
			maxMinButton.percentHeight = 100;
			maxMinButton.setStyle('cornerRadius', 10);
			maxMinButton.setStyle("chromeColor", "0xFFFFFF");
			toolbar.addElement(maxMinButton);
			
			// Add the close button to the panel
			var closeButton:Button = new Button();
			closeButton.label = "X";
			closeButton.percentHeight = 100;
			closeButton.width = 30;
			closeButton.setStyle('cornerRadius', 10);
			closeButton.setStyle("chromeColor", "0xFFFFFF");
			toolbar.addElement(closeButton);
			
			// Event Listenrs
			addCommentButton.addEventListener(MouseEvent.CLICK, addCommentButtonClicked);
			
			// Dispatched by new comment when cancel button is clicked
			this.addEventListener(IDEvent.COMMENT_CANCELLED, commentCancelled);
			
			// Dispatched by comment when reply button is clicked
			this.addEventListener(IDEvent.COMMENT_REPLY, commentReplyButtonClicked);
			
			// Testing this out TODO remove this
			maxMinButton.addEventListener(MouseEvent.CLICK, maxMinButtonClicked);
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
			
			// Listen for someone wanting to add a reference to a comment
			// we have to save the ID of the current comment being edited, so when they give back the
			// annotation to add, we know who to add it to
			this.addEventListener(IDEvent.OPEN_REF_PANEL_FILE, openRefPanelCaught);
			this.addEventListener(IDEvent.OPEN_REF_PANEL_ANNOTATION, openRefPanelCaught);
		}
		
		public function showComment(annotationID:Number):void {
			if(finishedRendering) {
				
				for(var i:Number = 0; i < content.numElements; i++) {
					var comment:Comment = content.getElementAt(i) as Comment;
					if(comment.getID() == annotationID) {
						myScroller.verticalScrollBar.value = comment.y;	
						comment.highlight();
					}
				}
			} else {
				setTimeout(showComment, 1000, annotationID);
			}
		}
		
		private function openRefPanelCaught(e:IDEvent):void {
			trace("CAUGHT open ref panel event", e.data.commentID);
			editingCommentID = e.data.commentID;
			trace("saving thingy", editingCommentID);
		}
//		
		
		override public function setUserAccess(modify:Boolean):void {
			super.setUserAccess(modify);
			addCommentButton.enabled = modify;
		}
		
		/**
		 * Removes all comments being displayed. 
		 * 
		 */		
		public function clearComments():void {
			content.removeAllElements();
		}
		
		/**
		 * Add comments to the Comments panel.
		 * Clear current comments before adding new comments.
		 * @param commentArray	The array of comments (Model_Annotations) to add to the panel
		 * 
		 */		
		public function addComments(commentArray:Array):void {
			clearComments();
			
			for(var i:Number = 0; i < commentArray.length; i++) {
				var commentData:Model_Commentary = commentArray[i] as Model_Commentary;
				
				var myComment:Comment = null;
				// Check if this comment is a reply
				if(commentData.annotation_start > 0) {					
					// This comment is a reply
					// We need to find the comment its a reply to, and add this comment
					// after it.
					var commentIndex:Number = this.getCommentIndexFromAssetID(commentData.annotation_start)
						
					if(commentIndex != -1) {
						
						// We found it, now lets find the end of the replies after it
						// So we can put the comment, at the end of all the other replies that are already there
						var nonReplyIndex:Number = this.getNonReplyCommentIndexAfter(commentIndex);
						
						myComment = new Comment(commentData.base_asset_id, commentData.meta_creator, Number(commentData.base_mtime), 
							commentData.text, true);
						addPanelItemAtIndex(myComment, nonReplyIndex);
					} else {
						// We didnt find the comment, that this one is replying to.
						// Lets just insert it at the bottom, as not a reply
						myComment = new Comment(commentData.base_asset_id, commentData.meta_creator, Number(commentData.base_mtime), commentData.text, false);
						addPanelItem(myComment);
					}
				} else {
					myComment = new Comment(commentData.base_asset_id, commentData.meta_creator, Number(commentData.base_mtime), commentData.text, false)
					addPanelItem(myComment);
				}
			}
			
			if(myComment) {
				myComment.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void {
					finishedRendering = true;
				});	
			}
			
		}
		
		/**
		 * A comment has been saved, convert the 'NewComment' into a regular 'Comment'
		 * We passed the whole new comment object just cause it makes it easier to identify
		 * it in the comment list, so we can remove and replace it. 
		 * @param commentID			The Asset ID of the new comment
		 * @param commentText		The text in the comment
		 * @param newCommentObject	The new comment, that has been saved, and we will replace.
		 * 
		 */			
		public function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void {
			
			// Get out of the position of the new comment to replace
			var positionOfComment:Number = content.getElementIndex(newCommentObject);
			
			// get out the text of the new comment to replace
			var commentText:String = newCommentObject.getCommentText();
			
			// get out if it was a reply
			var isReply:Boolean = newCommentObject.isReply();
			
			// create a new comment (not a newcomment lol)
			addPanelItemAtIndex(new Comment(commentID, Auth.getInstance().getUsername(), (new Date()).getTime(), commentText, isReply), positionOfComment);
			
			// remove the old one.
			content.removeElement(newCommentObject);
		}
		
//		public function addReferenceTo(mediaData:Model_Media):void {
		public function addReferenceTo(fileID:Number, fileTitle:String, annotationID:Number, annotationType:String):void {
			if(finishedRendering) {
				trace("title of added asset is", fileTitle);
				var commentIndex:Number = this.getCommentIndexFromAssetID(editingCommentID);
				trace("found", editingCommentID, "at", commentIndex); 
				var comment:Comment = content.getElementAt(commentIndex) as Comment;
				trace("comments panel", "adding ref to", "file id", fileID, "file title", fileTitle, "anno", annotationID);
				comment.addReference(fileID, fileTitle, annotationID, annotationType);
			} else {
				trace("not ready yet");
				setTimeout(addReferenceTo, 1000, fileID, fileTitle, annotationID, annotationType);
			}
		}
		
		/* =========== EVENT LISTENER FUNCTIONS =================== */
		private function addCommentButtonClicked(e:MouseEvent):void {
			// If there is a current new comment, already being displayed, remove it
			// and add anotehr one (so we dont have like, 3 new comments in a row being displayed)
			removeAnyNewComments();
			
			trace('vertical' + myScroller.verticalScrollBar.maximum);
			
			var newComment:NewComment = new NewComment();
			addPanelItem(newComment);
			
			trace('vertical' + myScroller.verticalScrollBar.maximum);
			
			setTimeout(scrollToBottomOfComments, 200);
		}
		
		private function scrollToBottomOfComments():void {
			myScroller.verticalScrollBar.value = myScroller.verticalScrollBar.maximum
			
		}
		private function maxMinButtonClicked(e:MouseEvent):void {
			if(expanded) {
				this.width = Panel.DEFAULT_WIDTH;
				(e.target as Button).label = "Max";
				expanded = false;
			} else {
				this.width = Panel.EXPANDED_WIDTH;
				(e.target as Button).label = "Min";
				expanded = true;
			}
		}
		
		private function closeButtonClicked(e:MouseEvent):void {
			maxMinButton.label = "Max";
			this.width = 0;
		}

		
		private function commentReplyButtonClicked(e:IDEvent):void {
			trace("okay so this is working");
//			trace("Caught Reply Button Clicked");
			// If there is a current new comment, already being displayed, remove it
			// and add anotehr one (so we dont have like, 3 new comments in a row being displayed)
			removeAnyNewComments();
			
			// Get out the position of the comment we are replying too
			var replyingTo:Comment = e.data.replyToComment as Comment;
			var positionOfReplyingToComment:Number = content.getElementIndex(replyingTo);
			
			var newComment:NewComment = new NewComment(replyingTo.getID());
			
			var placeToPutComment:Number = getNonReplyCommentIndexAfter(positionOfReplyingToComment);
			
			/// Put the new comment, at the end of all the replies for the comment we are replying to
			addPanelItemAtIndex(newComment, placeToPutComment);
		}
		
		
		private function commentCancelled(e:IDEvent):void {
//			trace("Removing comment");
			content.removeElement(e.data.newCommentObject);
		}
		
		
		/* =============== HELPER FUNCTIONS =================== */
		
		/**
		 * Loop through all the comments, and check for a 'new comment'
		 * if there is one already, remove it.
		 * 
		 */		
		private function removeAnyNewComments():void {
			
			for(var i:Number = content.numElements - 1; i >= 0; i--) {
				// Get out class name of comment (so we can see if its a new comment)
				var commentClassName:String = flash.utils.getQualifiedClassName(content.getElementAt(i));
				// If the class of the element displayed is a 'New comment', remove it
				if(commentClassName == "View.components.Panels.Comments::NewComment") {
					content.removeElementAt(i);
				}
				
			}
		}
		
		/**
		 * Finds the Index of the Comment object being displayed, that matches a given ID. -1 if not found. 
		 * @param assetID
		 * @return 
		 * 
		 */
		private function getCommentIndexFromAssetID(assetID:Number):Number {
			
			for(var i:Number = content.numElements - 1; i >= 0; i--) { // Not sure why this isbackwards lol
				var currentComment:Comment = content.getElementAt(i) as Comment;
				if(currentComment.getID() == assetID) {
					return i;
				}
			}
			// We didn't find it, so retunr -1;
			return -1;
		}
		
		private function getNonReplyCommentIndexAfter(index:Number):Number {
			for(var i:Number = index + 1; i < content.numElements; i++) {
				var currentComment:Comment = content.getElementAt(i) as Comment;
				if(!currentComment.isReply()) {
					// This is not a reply, return this index.
					return i;
				}
			}
			return i;
		}
	}
}