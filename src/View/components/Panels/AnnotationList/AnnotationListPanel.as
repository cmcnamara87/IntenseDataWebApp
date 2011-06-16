package View.components.Panels.AnnotationList
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Model.Model_Commentary;
	
	import View.BrowserView;
	import View.components.Panels.Comments.Comment;
	import View.components.Panels.Comments.NewComment;
	import View.components.Panels.Panel;
	import View.components.Toolbar;
	
	import flash.events.MouseEvent;
	import flash.sampler.Sample;
	import flash.utils.getQualifiedClassName;
	
	import mx.controls.Button;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	
	public class AnnotationListPanel extends Panel
	{
		// Inherits toolbar and content
		private var expanded:Boolean = false; // Whether or not the panel is expanded.
		
		private var maxMinButton:Button;
		
		/**
		 * The Annotations Panel sits on the right side on the media viewer
		 * and shows all the annotations a specific media has
		 * 
		 * Contains a Scroller, which has a group, where the annotations live.
		 */		
		public function AnnotationListPanel()
		{
			super();
			
			this.setHeading("Annotations");
			
			// Add the 'Expand/Contract' button for the panel.
			maxMinButton = new Button();
			maxMinButton.label = "Max";
			maxMinButton.width = 40;
			maxMinButton.percentHeight = 100;
			toolbar.addElement(maxMinButton);
			
			// Add the close button to the panel
			var closeButton:Button = new Button();
			closeButton.label = "X";
			closeButton.percentHeight = 100;
			closeButton.width = 30;
			toolbar.addElement(closeButton);

			// Event Listenrs
			maxMinButton.addEventListener(MouseEvent.CLICK, maxMinButtonClicked);
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
		}
		
		/**
		 * Removes all comments being displayed. 
		 * 
		 */		
		public function clearAnnotations():void {
			content.removeAllElements();
		}
		
		/**
		 * Add comments to the Comments panel.
		 * Clear current comments before adding new comments.
		 * @param commentArray	The array of comments (Model_Annotations) to add to the panel
		 * 
		 */		
		public function addAnnotations(annotationArray:Array):void {
			this.enabled = true;
			clearAnnotations();

			for(var i:Number = 0; i < annotationArray.length; i++) {
				var annotationData:Model_Commentary = annotationArray[i] as Model_Commentary;

				if(annotationData.annotation_type == Model_Commentary.ANNOTATION_BOX_TYPE_ID) {
					// Lets make an annotation
					addPanelItem(new AnnotationListItem(annotationData.base_asset_id, annotationData.meta_creator,"box", annotationData.text));
				} else if (annotationData.annotation_type == Model_Commentary.ANNOTATION_PEN_TYPE_ID) {
					addPanelItem(new AnnotationListItem(annotationData.base_asset_id, annotationData.meta_creator, "free draw", annotationData.text));
				} else {
					addPanelItem(new AnnotationListItem(annotationData.base_asset_id, annotationData.meta_creator, "highlight", annotationData.text));
				}
			}
		}
		
		/* =========== EVENT LISTENER FUNCTIONS =================== */
		
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
	}
}