package View.components.Panels.AnnotationList
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import View.BrowserView;
	import View.components.Annotation.Annotation;
	import View.components.Panels.Comments.Comment;
	import View.components.Panels.Comments.NewComment;
	import View.components.Panels.Panel;
	import View.components.Toolbar;
	
	import flash.events.MouseEvent;
	import flash.sampler.Sample;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.controls.Button;
	import mx.events.FlexEvent;
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
		
		private static var editingAnnotationID:Number;
		// Stores if we have finished rendering the comments
		private var finishedRendering:Boolean = false;
		
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
			
			
			this.addEventListener(IDEvent.OPEN_REF_PANEL_FILE, openRefPanelCaught);
			this.addEventListener(IDEvent.OPEN_REF_PANEL_ANNOTATION, openRefPanelCaught);
		}
		
		public function showAnnotation(annotationID:Number):void {
			trace("showing annotation");
			if(finishedRendering) {
				trace("finsihed rendering, finding annotation", annotationID);
				trace("stuff in content", content.numElements);
				for(var i:Number = 0; i < content.numElements; i++) {
					var annotationListItem:AnnotationListItem = content.getElementAt(i) as AnnotationListItem;
					if(annotationListItem.getID() == annotationID) {
						trace("annotation found, highlighting");
						myScroller.verticalScrollBar.value = annotationListItem.y;	
						annotationListItem.highlight();
					}
				}
			} else {
				trace("annottion not ready");
				setTimeout(showAnnotation, 1000, annotationID);
			}
		}
		
		private function openRefPanelCaught(e:IDEvent):void {
			trace("CAUGHT open ref panel event", e.data.commentID);
			editingAnnotationID = e.data.commentID;
			trace("saving thingy", editingAnnotationID);
		}
		
		public function addReferenceTo(fileID:Number, fileTitle:String, annotationID:Number, annotationType:String):void {
			if(finishedRendering) {
				trace("title of added asset is", fileTitle);
				for(var i = 0; i < content.numElements; i++) {
					var annotation:AnnotationListItem = content.getElementAt(i) as AnnotationListItem;
					if(editingAnnotationID == annotation.getID()) {
						annotation.addReference(fileID, fileTitle, annotationID, annotationType);
						return;
					}
				}
			} else {
				trace("not ready yet");
				setTimeout(addReferenceTo, 1000, fileID, fileTitle, annotationID, annotationType);
			}
			
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

			var annotationListItem:AnnotationListItem = null;
			for(var i:Number = 0; i < annotationArray.length; i++) {
				var annotationData:Model_Commentary = annotationArray[i] as Model_Commentary;

				if(annotationData.annotation_type == Model_Commentary.ANNOTATION_BOX_TYPE_ID) {
					// Lets make an annotation
					annotationListItem = new AnnotationListItem(annotationData.base_asset_id, annotationData.meta_creator, Number(annotationData.base_mtime), "box", annotationData.text);
					addPanelItem(annotationListItem);
				} else if (annotationData.annotation_type == Model_Commentary.ANNOTATION_PEN_TYPE_ID) {
					annotationListItem = new AnnotationListItem(annotationData.base_asset_id, annotationData.meta_creator, Number(annotationData.base_mtime), "free draw", annotationData.text);
					addPanelItem(annotationListItem);
				} else {
					annotationListItem = new AnnotationListItem(annotationData.base_asset_id, annotationData.meta_creator, Number(annotationData.base_mtime), "highlight", annotationData.text);
					addPanelItem(annotationListItem);
				}
			}
			
			if(annotationListItem) {
				annotationListItem.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void {
					finishedRendering = true;
				});	
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