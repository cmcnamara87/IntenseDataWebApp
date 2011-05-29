package View.components.MediaViewer
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Lib.AnnotationCoordinateCollection;
	import Lib.it.transitions.Tweener;
	
	import Model.Model_Commentary;
	
	import View.MediaView;
	import View.components.Annotation.AnnotationBox;
	import View.components.Annotation.AnnotationHighlight;
	import View.components.Annotation.AnnotationInterface;
	import View.components.Annotation.AnnotationPen;
	import View.components.Annotation.AnnotationTextOverlayBox;
	import View.components.Annotation.AnnotationToolbar;
	import View.components.MediaViewer.ImageViewer.ImageMedia;
	import View.components.Toolbar;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.effects.Resize;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.utils.NameUtil;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.HSlider;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.TileGroup;
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalAlign;
	import spark.layouts.VerticalLayout;
	
	public class Viewer extends MediaViewer implements MediaViewerInterface
	{
		private var annotationToolbar:AnnotationToolbar; // The box containing the annotation tools
		
		private var assetID:Number;
		
		
		private var scrollerContents:Group; // The contents of the scrollbar (the image and the annotations)
			
		private var annotationTextOverlayBox:AnnotationTextOverlayBox; // The box that houses the annotation text content
		
		private var scrollerAndOverlayGroup:Group;
		
		private var loadingLabel:Label; // Holds the 'Loading 25%' when loading
		
		
		private var startAnnotationMouseX:Number = -1; // THe X position of the mouse, when the user starts to draw an annotation
		private var startAnnotationMouseY:Number = -1; // The y position of the mouse when they start 
		private var finishAnnotationMouseX:Number = -1;  // the X position when they stop drawing
		private var finishAnnotationMouseY:Number = -1; // The Y position when they stop
		
		private var annotationCoordinates:AnnotationCoordinateCollection = new AnnotationCoordinateCollection(); 
		// The array that stores the annotation coordinates for when we are using
		// The free draw tool
		
		private var addAnnotationMode:Boolean = false;
		
		private var drawing:Boolean = false; // if we are in the process of drawing a new annotaiton
		
		private var actualImageWidth:Number = -1;
		private var actualImageHeight:Number = -1;
		
		private var resizeSlider:HSlider;
		
		[Embed(source="Assets/Template/closebutton.png")] 
		private var closeButtonImage:Class;
		private var closeButtonImageData:BitmapData = (new closeButtonImage as Bitmap).bitmapData;
		
		private var closeButton:Image;
		private var annotationMouseOverID:Number;
		
		private var mediaGroup:Group; // Holds the PDF and the annotations
		
		private var myScroller:Scroller; // The scroller that surrounds the content
		
		private var UITest:UIComponent;
		
		private var media:MediaAndAnnotationHolder;
		
		public function Viewer(mediaType:String)
		{
			super();
			
			// Setup the size
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			// Setup the layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Setup background
			this.backgroundFill = new SolidColor(0x000000);
			
			
			// Create the Annotation Tools toolbar
			// Will show 'Box tool', 'Pen Tool', 'Save' and 'Cancel' Buttons
			annotationToolbar = new AnnotationToolbar(this, mediaType);
			this.addElement(annotationToolbar);
			
			// Creatoe a group for the Image Scroller and the Annotation Text Overlay
			scrollerAndOverlayGroup = new Group();
			scrollerAndOverlayGroup.percentHeight = 100;
			scrollerAndOverlayGroup.percentWidth = 100;
			this.addElement(scrollerAndOverlayGroup);
			
			// Create scroller so we can scroll
			myScroller = new Scroller();
			myScroller.percentHeight = 100;
			myScroller.percentWidth = 100;
			
			// This group will contain the image
			// And this group is placed inside the scroller
			scrollerContents = new Group();
			scrollerContents.percentHeight = 100;
			scrollerContents.percentWidth = 100;
			
			// So we can align the image/annotations vertically
			var verticalAlignGroup:HGroup = new HGroup();
			verticalAlignGroup.percentHeight = 100;
			verticalAlignGroup.percentWidth = 100;
			verticalAlignGroup.verticalAlign = VerticalAlign.MIDDLE;
			scrollerContents.addElement(verticalAlignGroup);
			
			// So we can align the image/annotations horizontally.
			var horizontalAlignGroup:VGroup = new VGroup();
			horizontalAlignGroup.percentWidth = 100;
			horizontalAlignGroup.horizontalAlign = HorizontalAlign.CENTER;
			verticalAlignGroup.addElement(horizontalAlignGroup);
			
			// Adding the group to the scroller
			myScroller.viewport = scrollerContents;
			scrollerAndOverlayGroup.addElement(myScroller);
			
			// The group that will contain the Image and its Annotations
			mediaGroup = new Group();
			horizontalAlignGroup.addElement(mediaGroup);
			
			media = new MediaAndAnnotationHolder(mediaType);
			mediaGroup.addElement(media);
			
			// Now we are going to add a bordercontainer at the bottom
			// to have the slider/resizer
			var sliderResizerContainer:BorderContainer = new BorderContainer();
			sliderResizerContainer.percentWidth = 100;
			sliderResizerContainer.height = 40;
			
			// Set the resizers containers background and stroke
			sliderResizerContainer.backgroundFill = new SolidColor(0xDDDDDD, 1);
			sliderResizerContainer.borderStroke = new SolidColorStroke(0xDDDDDD,1,1);
			var bottomLayout:HorizontalLayout = new HorizontalLayout();
			bottomLayout.paddingRight = 10;
			bottomLayout.paddingLeft = 10;
			bottomLayout.paddingBottom = 10;
			bottomLayout.paddingTop = 10;
			bottomLayout.verticalAlign = "middle";
			bottomLayout.horizontalAlign = "right";
			sliderResizerContainer.layout = bottomLayout;
			
			var zoomOutLabel:Label = new Label();
			zoomOutLabel.text = "Zoom Out";
			sliderResizerContainer.addElement(zoomOutLabel);
			
			// Create the slider/resizer
			resizeSlider = new HSlider();
			resizeSlider.maximum = 200;
			resizeSlider.minimum = 10;
			resizeSlider.value = 100;
			//resizeSlider.liveDragging = true;
			//			slider.snapInterval = 1;
			sliderResizerContainer.addElement(resizeSlider);
			this.addElement(sliderResizerContainer);
			
			var zoomInLabel:Label = new Label();
			zoomInLabel.text = 'Zoom In';
			sliderResizerContainer.addElement(zoomInLabel);
			
			
			// Add 'Fit' button for the zoom
			var fitButton:spark.components.Button = new spark.components.Button();
			fitButton.percentHeight = 100;
			fitButton.label = "Fit";
			sliderResizerContainer.addElement(fitButton);
			
			// Add '100%' button for the zoom
			var percentButton:spark.components.Button = new spark.components.Button();
			percentButton.percentHeight = 100;
			percentButton.label = '100%';
			sliderResizerContainer.addElement(percentButton);
		
			annotationTextOverlayBox = new AnnotationTextOverlayBox();
			annotationTextOverlayBox.visible = false;
			scrollerAndOverlayGroup.addElement(annotationTextOverlayBox);
			
			
			// Event Listeners
			this.addEventListener(Event.CANCEL, cancelAnnotationButtonClicked);
			this.addEventListener(IDEvent.SHOW_ANNOTATION_TEXT_ENTRY, showAnnotationTextOverlayTextEntryMode);
			this.addEventListener(IDEvent.ANNOTATION_MOUSE_OVER, annotationMouseOver);
			this.addEventListener(IDEvent.ANNOTATION_MOUSE_OUT, annotationMouseOut);

			resizeSlider.addEventListener(Event.CHANGE, resizeImage);
			
			percentButton.addEventListener(MouseEvent.CLICK, percentButtonClicked);
			fitButton.addEventListener(MouseEvent.CLICK, fitButtonClicked);
		}
		
		/* ================ FUNCTIONS CALLED BY MEDIAVIEW ======================== */
		
		/**
		 * Loads an Image URL. Called by @see MediaView
		 * @param url	The URL of the image to load.
		 * 
		 */		
		override public function load(url:String):void {
			media.load(url);
		}
		
		/**
		 * Shows the annotation toolbar, listens for new annotations
		 * being drawn. Called when the 'Add Annotation'
		 * button is clicked in the MediaView.
		 * Starts listening for users drawing annotations 
		 * for cancelling, see @cancelAnnotationButtonClicked
		 * 
		 */		
		override public function enterNewAnnotationMode():void {
			if(!addAnnotationMode) {
				trace("Entering annotation mode");
				addAnnotationMode = true;
				annotationToolbar.show();
				
				
				// Hide the currently saved annotations
				// Just to make it easier for people to draw new ones
				media.hideAnnotations();
				media.listenForAnnotating();
				this.hideAnnotationTextOverlay();
			} else {
				trace("Already in add annotation mode");
			}
		}
		
		/**
		 * Removes all the current annotations 
		 */		
		public function clearAnnotations():void {
			media.removeAllAnnotations();
		}
		
		/**
		 * Removes all the non-saved annotations from the image viewer. 
		 * 
		 */		
		override public function clearNonSavedAnnotations():void {
			trace("Image Viewer: Removing all non-saved annotations");
			media.removeAllNonSavedAnnotations();
			hideAnnotationTextOverlay();
		}
		
		
		override public function addAnnotations(annotationsArray:Array):void {
			trace("Adding Annotatio");
			media.addAnnotations(annotationsArray);
		}
		
		override public function showAnnotations():void {
			// Hide the currently saved annotations
			media.showAnnotations();
		}
		
		override public function hideAnnotations():void {
			// Hide the currently saved annotations
			media.hideAnnotations();
		}
		
		/**
		 * Highlights an annotation. Called when an annotation in the annotation list is
		 * mouse overed. 
		 * @param assetID
		 * 
		 */		
		override public function highlightAnnotation(assetID:Number):void {
			if(!addAnnotationMode) {
				media.highlightAnnotation(assetID);
			}
		}
		
		/**
		 * Stop highlighting an annotation. 
		 * @param assetID
		 * 
		 */		
		override public function unhighlightAnnotation(assetID:Number):void {
			if(!addAnnotationMode) {
				media.unhighlightAnnotation(assetID);
				this.hideAnnotationTextOverlay();
			}
		}
		
		/* ===================== EVENT LISTENER FUNCTIONS ====================== */

		
		
		override public function saveNewAnnotation():void {
			trace("Save Button Clicked");
			media.saveNewAnnotation(annotationTextOverlayBox.getText());
			this.leaveNewAnnotationMode();
		}
		
		
		/**
		 * The cancel annotation button was clicked. 
		 * @param e
		 * 
		 */		
		private function cancelAnnotationButtonClicked(e:Event):void {
			trace("Cancel annotation button clicked");
			this.leaveNewAnnotationMode();
			
			// Exit annotation mode
			addAnnotationMode = false;
		}
		
		/**
		 * The annotation was hovered over (on the media), update the text overlay to
		 * show what the annotations author/text is. 
		 * 
		 */		
		private function annotationMouseOver(e:IDEvent):void {
			trace("Caught annotation mouse over");
			trace("author is", e.data.author);
			this.showAnnotationTextOverlayViewMode();
			annotationTextOverlayBox.setAuthor(e.data.author);
			annotationTextOverlayBox.setText(e.data.text);
			trace("**********************");
		}
		
		/**
		 * The annotation is no longer being hovered over (on the media), remove the overlay. 
		 * 
		 */		
		private function annotationMouseOut(e:IDEvent):void {
			trace("Caught annotation mouse out");
			this.hideAnnotationTextOverlay();
			trace("**********************");
		}
		
		/**
		 * Resizes the image when the slider is moved 
		 * @param e	The slider change event
		 * 
		 */		
		private function resizeImage(e:Event):void {
			trace("resizing", (e.target as HSlider).value);
			var resizeFactor:Number = (e.target as HSlider).value / 100; 
			
			// Resize the image by the scaling facotr
			media.scaleX = resizeFactor;
			media.scaleY = resizeFactor;
		}
		
		/**
		 * The resize to 100% button was clicked. Resize the image to
		 * its actual size. 
		 * @param e
		 * 
		 */		
		private function percentButtonClicked(e:MouseEvent):void {
			media.scaleX = 1;
			media.scaleY = 1;
		}
	
		/**
		 * The resize to fit the width of the screen button was clicked 
		 * @param e
		 * 
		 */		
		private function fitButtonClicked(e:MouseEvent):void {
			// This needs work lol TODO
			media.scaleX = scrollerAndOverlayGroup.width / media.width;
			media.scaleY = scrollerAndOverlayGroup.width / media.width;
		}
			
		/* ============= HELPER FUNCTIONS ============= */
		
		/**
		 * Leaves new annotation mode.  
		 * 
		 */		
		private function leaveNewAnnotationMode():void {
			// Clear any half/finished annotations
			addAnnotationMode = false;
			media.stopListeningForAnnotating();
			media.removeAllNonSavedAnnotations();
			media.showAnnotations();
			this.hideAnnotationTextOverlay();
		}
		/**
		 * Hide the annotayion text overlay box, and set it to read-only mode 
		 * 
		 */		
		private function hideAnnotationTextOverlay():void {
			// Hide the annotationtextoverlay
			annotationTextOverlayBox.enterReadOnlyMode();
			annotationTextOverlayBox.visible = false;
			annotationTextOverlayBox.setText("");
		}

		/**
		 * Shows hte text overlay in view mode. 
		 * 
		 */		
		private function showAnnotationTextOverlayViewMode():void {
			trace("Showing annotation text overlay");
			// The next 5 lines are to fix a bug
			// If you set the bottom, and then set the top on
			// displaying it for another annotation, it remmebers 
			// both, and becomes 100% height, so removing it, and making a new one
			// solves that problem.
			if(scrollerAndOverlayGroup.contains(annotationTextOverlayBox)) {
				scrollerAndOverlayGroup.removeElement(annotationTextOverlayBox);
			}
			annotationTextOverlayBox = new AnnotationTextOverlayBox();
			scrollerAndOverlayGroup.addElement(annotationTextOverlayBox);
			
			
			// Position the overlay at the top
			// if the mouse is in hte bottom half of the image
			// and in the bottom, if the mouse is in the top half
			if(scrollerAndOverlayGroup.mouseY > (scrollerAndOverlayGroup.height / 2)) {
				annotationTextOverlayBox.top = 0;
			} else {
				annotationTextOverlayBox.bottom = 0;
			}
			annotationTextOverlayBox.visible = true;
		}
		
		/**
		 * Show the annotation text overlay box, and set it to text entry mode 
		 * 
		 */		
		override public function showAnnotationTextOverlayTextEntryMode(e:IDEvent=null):void {
			// Setup the text input 
			// The text input box for the annotation
			// The next 5 lines are to fix a bug
			// If you set the bottom, and then set the top on
			// displaying it for another annotation, it remmebers 
			// both, and becomes 100% height, so removing it, and making a new one
			// solves that problem.
			if(scrollerAndOverlayGroup.contains(annotationTextOverlayBox)) {
				scrollerAndOverlayGroup.removeElement(annotationTextOverlayBox);
			}
			annotationTextOverlayBox = new AnnotationTextOverlayBox();
			scrollerAndOverlayGroup.addElement(annotationTextOverlayBox);
			
			// Put the Annotation Text Overlay in edit mode
			// So the user can write the text for their new annotation
			annotationTextOverlayBox.setAuthor(Auth.getInstance().getUsername());
			annotationTextOverlayBox.enterEditMode();
			
			// Position the entry for the text for an annotation
			// if the mouse finished in hte bottom half of the image have it at the top
			// and in the bottom, if the mouse is in the top half
			if(finishAnnotationMouseY > (scrollerAndOverlayGroup.height / 2)) {
				annotationTextOverlayBox.top = 0;
			} else {
				annotationTextOverlayBox.bottom = 0;
			}
			
			// Make the editable text overlay box appear
			annotationTextOverlayBox.visible = true;
		}
		
	}
}