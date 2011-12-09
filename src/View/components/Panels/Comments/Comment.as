package View.components.Panels.Comments
{
//	import Model.Model_Annotation;
	
	import Controller.ERA.FileController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Model.Model_ERARoom;
	
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
	import mx.controls.Button;
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
		private var deleteButton:spark.components.Button;
		private var addFileReference:mx.controls.Button;
		private var addAnnotationReference:mx.controls.Button;
		private var mtime:Number;
		private var deleteUpdateTimer:Timer;
//		private var comment:Label;
		private var comment:Text;
		private var newComment:TextArea;
		private var saveButton:IDButton;
		
		private var editMode:Boolean = false;
		
		private var buttonHGroup:HGroup;
		
		private var username:Text;
		
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
		
		public function highlight():void {
			username.setStyle('fontStyle', 'italic');
			comment.setStyle('fontStyle', 'italic');
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
			
			username = new Text();
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
				
				comment = new Text();
				// If we are in reference mode, dont display the lniks are links
				// just display the title
				if(FileController.refMode) {
					comment.htmlText = IDGUI.getTitleHTML(commentText);
				} else {
					comment.htmlText = IDGUI.getLinkHTML(commentText);
				}
				
				comment.percentWidth = 100;
				usernameAndComment.addElement(comment);
				if(commentText == "Comment Removed") {
					comment.setStyle("fontStyle", "italic");
				}
				
				var timestamp:Text = new Text();
				timestamp.percentWidth = 100;
				timestamp.text = mtime + "";
				timestamp.setStyle('color', '0x888888');
				
				var currDate:Date = new Date(mtime); //timestamp_in_seconds*1000 - if you use a result of PHP time function, which returns it in seconds, and Flash uses milliseconds
				timestamp.text = (currDate.getHours() + ":" + currDate.getMinutes() + " - " + currDate.getDate() + "/" + (currDate.getMonth()+ 1) + "/" + currDate.getFullYear());
				
				usernameAndComment.addElement(timestamp);
			}
			
			// SET UP ALL THE COMMENT BUTTONS (and there are a lot)
			
			// Create a HGroup for the buttons
			buttonHGroup 	= new HGroup();
			buttonHGroup.percentWidth 	= 100;
			buttonHGroup.height = 34;
			buttonHGroup.paddingBottom 	= 5;
			buttonHGroup.paddingTop 	= 5;
			buttonHGroup.paddingLeft 	= 5;
			buttonHGroup.paddingRight 	= 5;
			usernameAndComment.addElement(buttonHGroup);
			
			if(editMode == true) {
				this.addEditModeButtons();
			} else if (FileController.refMode) {
				this.addRefModeButtons();
			} else {
				this.addStandardButtons();	
			}
			
			// Add a horizontal rule at the bottom of the comment
			var hLine:Line = new Line();
			hLine.percentWidth = 100;
			hLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			this.addElement(hLine);
		}
		
		private function addEditModeButtons() {
			saveButton = new IDButton("Save");
			saveButton.setStyle("cornerRadius", "10");
			saveButton.percentWidth = 100;
			buttonHGroup.addElement(saveButton);

			saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
				
			var cancelButton:spark.components.Button = new IDButton("Cancel");
			cancelButton.setStyle("cornerRadius", "10");
			cancelButton.percentWidth = 100;
			buttonHGroup.addElement(cancelButton);
			cancelButton.addEventListener(MouseEvent.CLICK, function(e:Event) {
				editMode = false;
				render();
				
				var addReferenceEvent:IDEvent = new IDEvent(IDEvent.CLOSE_REF_PANEL, true);
				dispatchEvent(addReferenceEvent);
			});
		}
		
		/* ====================== ADD REF MODE BUTTONS AND LISTENERS ========================== */
		/**
		 * Add the buttoms for a comments in ref mode 
		 * @return 
		 * 
		 */		
		private function addRefModeButtons() {
			trace("adding ref mode buttons");
			var selectComment:spark.components.Button 		= new spark.components.Button();
			selectComment.setStyle("cornerRadius", "10");
			selectComment.percentHeight 	= 100;
			selectComment.percentWidth 	= 100;
			selectComment.label 			= "Select Comment";
			buttonHGroup.addElement(selectComment);
			
			selectComment.addEventListener(MouseEvent.CLICK, selectCommentButtonClicked);
		}
		private function selectCommentButtonClicked(e:MouseEvent):void {
			// Create a new annotation ref saved event
			var event:IDEvent = new IDEvent(IDEvent.ERA_ANNOTATION_CHOSEN_FOR_REFERENCE, true);
			event.data.commentID = assetID;
			event.data.type = "comment";
			dispatchEvent(event);
		}
		
		/* ====================== END OF ADD REF MODE BUTTONS AND LISTENERS ========================== */
		
		/**
		 * Add the standard buttons for a comment 
		 * @return 
		 * 
		 */
		private function addStandardButtons() {
			// Add reply button if not repky		
			var replyButton:mx.controls.Button = new mx.controls.Button();
			replyButton.width = 60;
			replyButton.setStyle("cornerRadius", "10");
			replyButton.setStyle('icon', AssetLookup.reply_icon);
			replyButton.percentHeight = 100;
			replyButton.toolTip	= "Reply";
			if(!reply) {
				// Only add the button, if this isnt a reply
				// You cant reply to a reply.
				buttonHGroup.addElement(replyButton);
			}
				
			// If the current user is the author of this comment
			// then add an Edit and a Delete button
			if(creator == Auth.getInstance().getUsername() || Auth.getInstance().isSysAdmin()) {
				
				// Create a Delete button
				trace("Is sys-admin?", Auth.getInstance().isSysAdmin());
				
				if(commentText != "Comment Removed" || Auth.getInstance().isSysAdmin()) {
					
					var deleteButton:mx.controls.Button = new mx.controls.Button();
					deleteButton.width = 60;
					deleteButton.setStyle("cornerRadius", "10");
					deleteButton.setStyle('icon', AssetLookup.delete_comment_icon);
					deleteButton.percentHeight = 100;
					deleteButton.toolTip	= "Delete";

					buttonHGroup.addElement(deleteButton);
					
					if(!Auth.getInstance().isSysAdmin()) {
						// Not the sys admin, put the timer on the delete button
						deleteUpdateTimer = new Timer(1000);
						deleteUpdateTimer.addEventListener(TimerEvent.TIMER, updateDeleteButtonTime);
						deleteUpdateTimer.start();
					}
				}
					
				// only show the re button if we are in the evidence manager
				if(FileController.roomType == Model_ERARoom.EVIDENCE_ROOM) {
					// only in the evidence room, show the reference
					addFileReference = new mx.controls.Button();
					addFileReference.width = 60;
					addFileReference.setStyle("cornerRadius", "10");
					addFileReference.setStyle('icon', AssetLookup.add_file_ref_icon);
					addFileReference.percentHeight = 100;
					addFileReference.toolTip	= "Add File Reference";
					buttonHGroup.addElement(addFileReference);
					
					addAnnotationReference = new mx.controls.Button();
					addAnnotationReference.width = 60;
					addAnnotationReference.setStyle("cornerRadius", "10");
					addAnnotationReference.setStyle('icon', AssetLookup.add_ann_ref_icon);
					addAnnotationReference.percentHeight = 100;
					addAnnotationReference.toolTip	= "Add Annotation Reference";
					buttonHGroup.addElement(addAnnotationReference);
				}
			}
				
			/* ============ EVENT LISTENERS ================= */
		
			replyButton.addEventListener(MouseEvent.CLICK, replyButtonClicked, false, 0, true);
			if(addFileReference) {
				addFileReference.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					var addReferenceEvent:IDEvent = new IDEvent(IDEvent.OPEN_REF_PANEL_FILE, true);
					addReferenceEvent.data.commentID = assetID;
					addReferenceEvent.data.type = "comment";
					trace("dispatching event with data", assetID);
					dispatchEvent(addReferenceEvent);
					
					editMode = true;
					render();
				});
				
				addAnnotationReference.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					var addReferenceEvent:IDEvent = new IDEvent(IDEvent.OPEN_REF_PANEL_ANNOTATION, true);
					addReferenceEvent.data.commentID = assetID;
					addReferenceEvent.data.type = "comment";
					trace("dispatching event with data", assetID);
					dispatchEvent(addReferenceEvent);
					
					editMode = true;
					render();
				});
			}
			if(deleteButton) {
				deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked, false, 0, true);
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
		
		/**
		 * Adds a reference into the comment
		 * @param refAssetID
		 * @param refMediaTitle
		 * @param refAnnotation
		 * 
		 */		
		public function addReference(refAssetID:Number, refMediaTitle:String, refAnnotation:Number, refAnnotationType:String):void {
			if(!editMode) {
				editMode = true;
				this.render();
			}
			trace("comment ref", "file id", refAssetID, "title", refMediaTitle, "annotation", refAnnotation);
			if(refAnnotation > 0 && refAnnotationType != "") {
				newComment.text = newComment.text.substring(0, newComment.selectionBeginIndex) + "{" + refMediaTitle + ":" + refAssetID + ":" + refAnnotation + ":" + refAnnotationType + "}" + newComment.text.substring(newComment.selectionEndIndex);
			} else {
				newComment.text = newComment.text.substring(0, newComment.selectionBeginIndex) + "{" + refMediaTitle + ":" + refAssetID + "}" + newComment.text.substring(newComment.selectionEndIndex);
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