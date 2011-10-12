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
	
	import flashx.textLayout.formats.BackgroundColor;
	
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
		protected var mediaType:String;
		
		private var annotationToolbar:AnnotationToolbar; // The box containing the annotation tools
		
		private var assetID:Number;
		
		
		private var scrollerContents:Group; // The contents of the scrollbar (the image and the annotations)
			
		private var annotationTextOverlayBox:AnnotationTextOverlayBox; // The box that houses the annotation text content
		
		protected var scrollerAndOverlayGroup:Group;
		
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
		
		protected var resizeSlider:HSlider;
		
		[Embed(source="Assets/Template/closebutton.png")] 
		private var closeButtonImage:Class;
		private var closeButtonImageData:BitmapData = (new closeButtonImage as Bitmap).bitmapData;
		
		private var closeButton:Image;
		private var annotationMouseOverID:Number;
		
		private var mediaGroup:Group; // Holds the PDF and the annotations
		
		protected var myScroller:Scroller; // The scroller that surrounds the media
		
		private var UITest:UIComponent;
		
		protected var media:MediaAndAnnotationHolder;
		
		protected var sliderResizerContainer:BorderContainer;
		
		public function Viewer(mediaType:String)
		{
			super();
			this.mediaType = mediaType;
			
			// Setup the size
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			// Setup the layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Setup background
			this.backgroundFill = new SolidColor(0xEEEEEE);
			this.setStyle('borderVisible', false);
			
			
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
			
			loadingLabel = new Label();
			loadingLabel.text = "Loading...";
			loadingLabel.setStyle('fontSize', 20);
			loadingLabel.setStyle('color', 0x888888);
			loadingLabel.setStyle('fontWeight', 'bold');
			loadingLabel.setStyle('textAlign', 'center');
			loadingLabel.visible = true;
			
			mediaGroup.addElement(loadingLabel);
			
			
			// Create the Annotation Tools toolbar
			// Will show 'Box tool', 'Pen Tool', 'Save' and 'Cancel' Buttons
			annotationToolbar = new AnnotationToolbar(this, mediaType);
			annotationToolbar.setColor(0x222222);
			this.addElement(annotationToolbar);
			
			// Now we are going to add a bordercontainer at the bottom
			// to have the slider/resizer
			sliderResizerContainer = new BorderContainer();
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
		
			makeBottomToolbar();
			
			annotationTextOverlayBox = new AnnotationTextOverlayBox();
			annotationTextOverlayBox.visible = false;
			scrollerAndOverlayGroup.addElement(annotationTextOverlayBox);
			
			
			// Event Listeners
			this.addEventListener(Event.CANCEL, cancelAnnotationButtonClicked);
			this.addEventListener(IDEvent.SHOW_ANNOTATION_TEXT_ENTRY, showAnnotationTextOverlayTextEntryMode);
			this.addEventListener(IDEvent.ANNOTATION_MOUSE_OVER, annotationMouseOver);
			this.addEventListener(IDEvent.ANNOTATION_MOUSE_OUT, annotationMouseOut);
			
			media.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
//				trace("got a progress event");
				loadingLabel.text = "Loading " + Math.round((e.bytesLoaded / e.bytesTotal * 100)) + "%";
				if(e.bytesLoaded == e.bytesTotal) {
					loadingLabel.visible = false;
					loadingLabel.includeInLayout = false;
				}
			});
			media.addEventListener(IDEvent.PAGE_LOADED, function(e:IDEvent):void {
				loadingLabel.visible = true;
				loadingLabel.includeInLayout = true;
				loadingLabel.text = "Loading Page " + e.data.page;// + " of " + e.data.totalPages;
				if(e.data.page == e.data.totalPages) {
					loadingLabel.visible = false;
					loadingLabel.includeInLayout = false;
				}
			});
			
			this.addEventListener(IDEvent.SCROLL_TO_ANNOTATION, function(e:IDEvent):void {
				trace("Showing annotation from annotation list");
				scrollToPoint(e.data.xCoor - 10, e.data.yCoor - 10);
			});
		}
		
		/**
		 * Creates a new Viewer based on hte media type 
		 * @param mediaType	The type of the media e.g. PDF image etc
		 * @return A viewer
		 * 
		 */		
		public static function getViewer(mediaType:String):Viewer {
			switch(mediaType) {
				case MediaAndAnnotationHolder.MEDIA_PDF:
					trace("Creating PDF viewr");
					return new PDFViewer(mediaType);
					break;
				case MediaAndAnnotationHolder.MEDIA_IMAGE:
					trace("Creating image viewer");
					return new ImageViewer(mediaType);
					break;
				default:
					trace("Unknown Viewer type");
			}
			return null;
		}
		
		/**
		 * Constructs the toolbar at the bottom of the viewer. Often has a HSlider and
		 * other zoom buttons.
		 * 
		 */		
		protected function makeBottomToolbar():void {
			trace("Viewer:makeBottomToolbar Should be overwritten");
		}
		
		/**
		 * Scrolls the media to a certain X and Y coordinate (used when we rollover annotations
		 * in the annotation list, or when we click Next/Prev page for the pdf etc) 
		 * @param xCoor	The X Coordinate to scroll to
		 * @param yCoor	The Y Coordinate to scroll to
		 * 
		 */		
		protected function scrollToPoint(xCoor:Number, yCoor:Number):void {
			// Try and scroll the vertical scroll bar (try/catch incase it doesnt exist)
			try {
				Tweener.addTween(myScroller.verticalScrollBar,{'value': yCoor * media.scaleY, 'time': 1});
			} catch (e:Error) {}
			// Try and scroll the horizontal scroll bar (try/catch in case the scrollbar doesnt exist)
			try {
				Tweener.addTween(myScroller.horizontalScrollBar,{'value': xCoor * media.scaleX, 'time': 1});
			} catch (e:Error) {}
		}
		
		/**
		 * Scales the media (and annotation container) 
		 * @param scaleX
		 * @param scaleY
		 * 
		 */		
		protected function scaleMedia(scaleX:Number, scaleY:Number):void {
			// save the scrollbars current value
			var scrollX:Number = myScroller.horizontalScrollBar.value  / media.scaleX;
			var scrollY:Number = myScroller.verticalScrollBar.value / media.scaleY;
			Tweener.addTween(media, {'scaleX': scaleX, 'scaleY': scaleY, 'time': 1, 'onUpdate': function():void {
//				trace("scaling is currently", scaleX, scaleY);
				myScroller.horizontalScrollBar.value = scrollX * media.scaleX;
				myScroller.verticalScrollBar.value = scrollY * media.scaleY;
			}});
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
			trace("*********** ADDING ANNOTATIONS");
			media.addAnnotations(annotationsArray);
			this.hideAnnotationTextOverlay();
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
			if(e.data.bottom && e.data.bottom == true) {
				// Only show the annotaton overlay at the bottom
				// this is when the request comes from the annotaiton list panel
				// and not from an actual annotation being mouse overed
				this.showAnnotationTextOverlayViewMode(true);
			} else {
				this.showAnnotationTextOverlayViewMode();
			}
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
		private function showAnnotationTextOverlayViewMode(bottom:Boolean=false):void {
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
			
			
			if(bottom) {
				// We always want to show the overlay at hte bottom
				// this is for when we highlight annotations in the annotaiton list panel
				annotationTextOverlayBox.bottom = 0;
			} else {
				// Position the overlay at the top
				// if the mouse is in hte bottom half of the image
				// and in the bottom, if the mouse is in the top half
				
				if(scrollerAndOverlayGroup.mouseY > (scrollerAndOverlayGroup.height / 2)) {
					annotationTextOverlayBox.top = 0;
				} else {
					annotationTextOverlayBox.bottom = 0;
				}
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