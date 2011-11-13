package View.components.Panels.AnnotationList
{
	//	import Model.Model_Annotation;
	
	import Controller.ERA.FileController;
	import Controller.IDEvent;
	import Controller.Utilities.AssetLookup;
	import Controller.Utilities.Auth;
	
	import Model.Model_ERARoom;
	
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
	import mx.controls.Image;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.events.CloseEvent;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class AnnotationListItem extends VGroup implements PanelElement
	{
		private var assetID:Number;
		
		private var deleteButton:Button; // The delete button on the annotation
		private var annotationText:String;
		private var creator:String;
		private var annotationType:String
		private var mTime:Number;
		private var deleteUpdateTimer:Timer;
		private var editMode:Boolean = false;
		private var newComment:TextArea;
		/**
		 * Creates a comment 
		 * @param assetID		The ID of the comment in the database
		 * @param creator		The creator of the comment
		 * @param commentText	The text for the comment
		 * @param reply			True/false if the comment is a reply or not.
		 * 
		 */		
		public function AnnotationListItem(assetID:Number, creator:String, mTime:Number, annotationType:String, annotationText:String)
		{
			
			super();
			this.assetID = assetID;
			this.annotationText = annotationText;
			this.annotationType = annotationType;
			this.creator = creator;
			this.mTime = mTime;
			
			// Setup size
			this.percentWidth = 100;
			
			// Setup layout
			this.gap = 0;
		
			// Setup layout
			this.gap = 5;
			this.paddingLeft = 10;
			this.paddingRight = 10;
			this.paddingTop = 10;
			this.paddingBottom = 10;
			
			render();
			
		}
		
		private function render() {
			this.removeAllElements();
			
			var usernameAndIcon:HGroup = new HGroup();
			usernameAndIcon.percentWidth = 100;
			this.addElement(usernameAndIcon);
			
			var username:spark.components.Label = new spark.components.Label();
			// Get the Capitalised first letter of hte username (should be persons name, but whatever)
			username.text = creator.substr(0,1).toUpperCase() + creator.substr(1);
			username.percentWidth = 100;
			username.setStyle('color', 0x1F65A2);
			username.setStyle('fontWeight', 'bold');
			usernameAndIcon.addElement(username);
			
			if(annotationType == "highlight") {
				var icon:Image = new Image();
				icon.source = AssetLookup.getPostItIconClass();
				icon.height = 15;
				icon.width = 15;
				usernameAndIcon.addElement(icon);
			} else {
				var annotationTypeLabel:spark.components.Label = new Label();
				annotationTypeLabel.text = annotationType.substr(0,1).toUpperCase() + annotationType.substr(1);
				annotationTypeLabel.setStyle('color', 0x1F65A2);
				annotationTypeLabel.setStyle('fontWeight', 'bold');
				usernameAndIcon.addElement(annotationTypeLabel);
			}
			
			if(editMode) {
				trace("edit mode is on");
				newComment = new TextArea();
				newComment.percentWidth = 100;
				newComment.height = 100;
				newComment.text = annotationText;
				this.addElement(newComment);
			} else {
				trace('edit mode is off');
				var comment:Text = new Text();
				comment.htmlText = IDGUI.getLinkHTML(annotationText);
				comment.percentWidth = 100;
				this.addElement(comment);
				
				var timestamp:Text = new Text();
				timestamp.setStyle('color', '0x888888');
				timestamp.percentWidth = 100;

				var currDate:Date = new Date(mTime); //timestamp_in_seconds*1000 - if you use a result of PHP time function, which returns it in seconds, and Flash uses milliseconds
				timestamp.text = (currDate.getHours() + ":" + currDate.getMinutes() + " - " + currDate.getDate() + "/" + (currDate.getMonth()+ 1) + "/" + currDate.getFullYear());
				
				this.addElement(timestamp);
			}
			
			// Create a HGroup for the buttons
			var buttonHGroup:HGroup 	= new HGroup();
			buttonHGroup.percentWidth 	= 100;
			buttonHGroup.paddingBottom 	= 5;
			buttonHGroup.paddingTop 	= 5;
			buttonHGroup.paddingLeft 	= 5;
			buttonHGroup.paddingRight 	= 5;
			this.addElement(buttonHGroup);
			
			if(editMode) {
				var saveButton:IDButton = new IDButton("Save");
				saveButton.setStyle("cornerRadius", "10");
				saveButton.setStyle("chromeColor", "0xFFFFFF");
				
				buttonHGroup.addElement(saveButton);
				saveButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					editMode = false;
					annotationText = newComment.text;
					render();
					
					var myEvent:IDEvent = new IDEvent(IDEvent.COMMENT_EDITED, true);
					myEvent.data.commentID = assetID;
					myEvent.data.commentText = annotationText;
					dispatchEvent(myEvent);
				});
				
				var cancelButton:IDButton = new IDButton("Cancel");
				cancelButton.setStyle("cornerRadius", "10");
				cancelButton.setStyle("chromeColor", "0xFFFFFF");
				
				buttonHGroup.addElement(cancelButton);
				cancelButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					editMode = false;	
					render();
					
					var addReferenceEvent:IDEvent = new IDEvent(IDEvent.CLOSE_REF_PANEL, true);
					dispatchEvent(addReferenceEvent);
				});
				
			} else {
				// If the current user is the author of this annotation
				// Or if the current user is a sys-admin
				// then add an Edit and a Delete button
				if(creator == Auth.getInstance().getUsername() || Auth.getInstance().isSysAdmin()) {
	//				// Create the Edit Button
	//				var editButton:Button 		= new Button();
	//				editButton.percentHeight	= 100;
	//				editButton.percentWidth 	= 100;
	//				editButton.label			= "Edit";
	//				buttonHGroup.addElement(editButton);
	//				
	//				// Create a Delete button
					trace("Creating delete button");
					deleteButton		= new Button();
					deleteButton.setStyle("cornerRadius", "10");
					
					deleteButton.percentHeight 	= 100;
					deleteButton.percentWidth	= 100;
					deleteButton.label			= "Delete";
					buttonHGroup.addElement(deleteButton);
					
					deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked);
					
					if(!Auth.getInstance().isSysAdmin()) {
						// Not the system admin, so put the timer on the delete button
						deleteButton.visible = false;
						deleteButton.includeInLayout = false;
						
						deleteUpdateTimer = new Timer(1000);
						deleteUpdateTimer.addEventListener(TimerEvent.TIMER, updateDeleteButtonTime);
						deleteUpdateTimer.start();
					}
				}
				
				if(FileController.roomType == Model_ERARoom.EVIDENCE_ROOM) {
					var addRefButton:IDButton = new IDButton("Add Ref");
					addRefButton.setStyle("cornerRadius", "10");
					
					addRefButton.percentWidth = 100;
					
					addRefButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
						var addRefEvent:IDEvent = new IDEvent(IDEvent.OPEN_REF_PANEL, true);
						addRefEvent.data.commentID = assetID;
						addRefEvent.data.type = "annotation";
						dispatchEvent(addRefEvent);
						editMode = true;
						render();
					});
					
					buttonHGroup.addElement(addRefButton);
				}
				
				
				
			}
			
			// Add a horizontal rule at the bottom of the comment
			var hLine:Line = new Line();
			hLine.percentWidth = 100;
			hLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			this.addElement(hLine);
			
			
			/* ============ EVENT LISTENERS ================= */
			this.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
			
			
		}
		
		public function addReference(refAssetID:Number, refMediaTitle:String):void {
			newComment.text = newComment.text.substring(0, newComment.selectionBeginIndex) + "{" + refMediaTitle + ":" + refAssetID + "}" + newComment.text.substring(newComment.selectionEndIndex); 
		}
		
		
		/* ============ EVENT LISTENER FUNCTIONS ===================== */
		private function updateDeleteButtonTime(e:TimerEvent):void {
			var timeSinceCreated:Number = ((new Date()).getTime() - mTime) / 1000;
			var minutes:Number = Math.floor(timeSinceCreated / 60);
			
			if(minutes <= 14) {
				// Show a delete button if < 15 mins
				deleteButton.includeInLayout = true;
				deleteButton.visible = true;
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
		
		private function annotationMouseOver(e:MouseEvent):void {
//			trace("List Item Mouse Over", assetID);
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_LIST_ITEM_MOUSEOVER, true);
			myEvent.data.assetID = assetID;
			myEvent.data.fromAnnotationList = true;
			this.dispatchEvent(myEvent);
		}
		
		private function annotationMouseOut(e:MouseEvent):void {
//			trace("List Item Mouse Out", assetID);
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_LIST_ITEM_MOUSEOUT, true);
			myEvent.data.assetID = assetID;
			this.dispatchEvent(myEvent);
			
		}
		
		private function deleteButtonClicked(e:MouseEvent):void {
			trace("Delete Button Clicked");
			//(view as AssetView).navbar.deselectButtons();
			var myAlert:Alert = Alert.show("Are you sure you want to delete this annotation?", "Delete Annotation", Alert.OK | Alert.CANCEL, null, 
				deleteButtonOkay, null, Alert.CANCEL);
			myAlert.height=100;
			myAlert.width=300;
		}
		
		private function deleteButtonOkay(e:CloseEvent):void {
			if (e.detail == Alert.OK) {
				trace("Annotation Deletion Clicked", assetID);
				this.height = 0;
				this.visible = false;
				var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_DELETED, true);
				myEvent.data.assetID = assetID;
				this.dispatchEvent(myEvent);
			}
		}
		
		/* GETTERS/SETTERS */
		public function getID():Number {
			return assetID;
		}
		
		public function searchMatches(search:String):Boolean {
			if(creator.toLowerCase().indexOf(search.toLowerCase()) == -1 && annotationText.toLowerCase().indexOf(search.toLowerCase()) == -1) {
				return false;
			} else {
				return true;
			}
		}
	}
}