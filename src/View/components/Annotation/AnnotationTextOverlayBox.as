package View.components.Annotation
{
	import mx.controls.Text;
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.layouts.VerticalLayout;
	
	public class AnnotationTextOverlayBox extends BorderContainer
	{
		private var annotationCreator:Label;
		private var annotationText:Text;
		private var annotationTextInput:TextArea;
		
		private var editMode:Boolean = false; 	// When True, the text is not show, and an
												// text area is shown
		
		/**
		 * Creates the Black semi-transparent box that appears at the bottom of the media
		 * asset view and contains the text content of the annotation.  
		 * 
		 */		
		public function AnnotationTextOverlayBox()
		{
			super();
			
			// Setup the size
			this.percentWidth = 100;
			
			// Setup layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.paddingBottom = 10;
			myLayout.paddingLeft = 10;
			myLayout.paddingRight = 10;
			myLayout.paddingTop = 10;
			this.layout = myLayout;
			
			// Setup background
			this.backgroundFill = new SolidColor(0x000000, 0.8);

			// Add Creator label
			annotationCreator = new Label();
			annotationCreator.percentWidth = 100;
			annotationCreator.text = "";
			annotationCreator.setStyle('fontWeight', 'bold');
			annotationCreator.setStyle('color', 0xFFFFFF);
			this.addElement(annotationCreator);
			
			// Add Content label
			annotationText = new Text();
			annotationText.setStyle('color', 0xFFFFFF);
			annotationText.percentWidth = 100;
			annotationText.text = "";
			this.addElement(annotationText);
			
			// Add Content Entry box
			annotationTextInput = new TextArea();
			annotationTextInput.percentWidth = 100;
		}
		
		/* ==== PUBLIC FUNCTIONS ===== */
		public function enterEditMode():void {
			trace("Entering Edit Mode");
			if(this.contains(annotationText)) {
				trace("Removing annotation text");
				this.removeElement(annotationText);
			}
			if(this.contains(annotationTextInput)) {
				trace("Removing annotation input");
				this.removeElement(annotationTextInput);
			}
			trace("Adding Text Input");
			this.addElement(annotationTextInput);
		}
		
		public function enterReadOnlyMode():void {
			//trace("Entering Read Only Mode");
			if(this.contains(annotationText)) {
				//trace("Removing annotation text");
				this.removeElement(annotationText);
			}
			if(this.contains(annotationTextInput)) {
				//trace("Removing annotation input");
				annotationTextInput.text = "";
				this.removeElement(annotationTextInput);
			}
			//trace("Adding Text");
			this.addElement(annotationText);
		}
		
		/**
		 * Set the text for the author part of the annotation 
		 * @param text	The authors name
		 * 
		 */		
		public function setAuthor(text:String):void {
			annotationCreator.text = text;
		}
		
		/**
		 * Set the text for the content of the annotation 
		 * @param text	The text contained in the annotation
		 * 
		 */		
		public function setText(text:String):void {
			var newCommentText:String = text;
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
				var replacementString = "(" + mediaTitle + ")";
				newCommentText = newCommentText.substring(0, startRefLocation) + replacementString + newCommentText.substring(endRefLocation + 1);
				
				startRefLocation = newCommentText.indexOf("{", startRefLocation + replacementString);
			}
			annotationText.htmlText = newCommentText;
//			annotationText.text = text;
		}
		
		public function getText():String {
			if(this.contains(annotationText)) {
				return annotationText.text;
			}
			if(this.contains(annotationTextInput)) {
				return annotationTextInput.text;
			}
			return "";
		}
	}
}