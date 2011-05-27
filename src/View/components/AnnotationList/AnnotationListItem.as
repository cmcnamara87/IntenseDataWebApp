package View.components.AnnotationList
{
	//	import Model.Model_Annotation;
	
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import View.components.PanelElement;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
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
		/**
		 * Creates a comment 
		 * @param assetID		The ID of the comment in the database
		 * @param creator		The creator of the comment
		 * @param commentText	The text for the comment
		 * @param reply			True/false if the comment is a reply or not.
		 * 
		 */		
		public function AnnotationListItem(assetID:Number, creator:String, annotationType:String, annotationText:String)
		{
			super();
			this.assetID = assetID;
			this.annotationText = annotationText;
			this.creator = creator;
			
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
			
			var username:spark.components.Label = new spark.components.Label();
			// Get the Capitalised first letter of hte username (should be persons name, but whatever)
			username.text = creator.substr(0,1).toUpperCase() + creator.substr(1) + "(" + annotationType + ")";
			username.percentWidth = 100;
			username.setStyle('color', 0x1F65A2);
			username.setStyle('fontWeight', 'bold');
			this.addElement(username);
			
			var comment:spark.components.Label = new spark.components.Label();
			comment.text = annotationText;
			comment.percentWidth = 100;
			this.addElement(comment);
			
			// Create a HGroup for the buttons
			var buttonHGroup:HGroup 	= new HGroup();
			buttonHGroup.percentWidth 	= 100;
			buttonHGroup.paddingBottom 	= 5;
			buttonHGroup.paddingTop 	= 5;
			buttonHGroup.paddingLeft 	= 5;
			buttonHGroup.paddingRight 	= 5;
			this.addElement(buttonHGroup);
			
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
				deleteButton.percentHeight 	= 100;
				deleteButton.percentWidth	= 100;
				deleteButton.label			= "Delete";
				buttonHGroup.addElement(deleteButton);
				
				deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonClicked);
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
		
		/* ============ EVENT LISTENER FUNCTIONS ===================== */
		private function annotationMouseOver(e:MouseEvent):void {
			trace("List Item Mouse Over", assetID);
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_LIST_ITEM_MOUSEOVER, true);
			myEvent.data.assetID = assetID;
			this.dispatchEvent(myEvent);
		}
		
		private function annotationMouseOut(e:MouseEvent):void {
			trace("List Item Mouse Out", assetID);
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_LIST_ITEM_MOUSEOUT, true);
			myEvent.data.assetID = assetID;
			this.dispatchEvent(myEvent);
			
		}
		
		private function deleteButtonClicked(e:MouseEvent):void {
			trace("Annotation Deletion Clicked", assetID);
			this.height = 0;
			this.visible = false;
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_DELETED, true);
			myEvent.data.assetID = assetID;
			this.dispatchEvent(myEvent);
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