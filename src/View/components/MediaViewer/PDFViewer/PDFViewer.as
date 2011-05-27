package View.components.MediaViewer.PDFViewer
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
	import View.components.MediaType;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.MediaViewerInterface;
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
	
	public class PDFViewer extends MediaViewer implements MediaViewerInterface
	{
		private var pdf:PDF; // The Image object to display
		private var sourceURL:String; // The URL to the image's source
		
		private var annotationToolbar:AnnotationToolbar; // The box containing the annotation tools
		
		private var assetID:Number;
		
		
		private var scrollerContents:Group; // The contents of the scrollbar (the image and the annotations)
		private var annotationsGroup:Group; // THe group containing the annotations
		private var newAnnotationsGroup:Group; // Where we put the new annotation while we are drawing them
		private var canvas:Group; // inside the new annotations group, we actually draw on this
		
		private var isImageLoaded:Boolean = false; // True when an image has been loaded
		private var annotationsAreLoaded:Boolean = false; // True when the annotations have been loaded
		
		private var annotationsArray:Array; // The array of the annotations for this image
		
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
		
		private var imageAndAnnotationsGroup:Group; // Holds the PDF and the annotations
		
		private var myScroller:Scroller; // The scroller that surrounds the content
		
		private var UITest:UIComponent;
		
		private var media:MediaType;
		
		public function PDFViewer()
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
			annotationToolbar = new AnnotationToolbar(this, true);
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
			imageAndAnnotationsGroup = new Group();
			horizontalAlignGroup.addElement(imageAndAnnotationsGroup);
			
			media = new MediaType(MediaType.MEDIA_PDF);
			imageAndAnnotationsGroup.addElement(media);
			
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
//			pdf.addEventListener(Event.COMPLETE, sourceLoaded);
			this.addEventListener(Event.CANCEL, cancelAnnotationButtonClicked);
			//this.addEventListener(RecensioEvent.ANNOTATION_SAVE_CLICKED, saveAnnotationButtonClicked);
			//			this.addEventListener(RecensioEvent.ANNOTATION_CLEAR_CLICKED, clearAnnotationButtonClicked);
			resizeSlider.addEventListener(Event.CHANGE, resizeImage);
			
			annotationTextOverlayBox.addEventListener(MouseEvent.MOUSE_OVER, textOverlayMouseOver);
			annotationTextOverlayBox.addEventListener(MouseEvent.MOUSE_OUT, textOverlayMouseOut);
			
			percentButton.addEventListener(MouseEvent.CLICK, percentButtonClicked);
			fitButton.addEventListener(MouseEvent.CLICK, fitButtonClicked);
			
			//			closeButton.addEventListener(MouseEvent.CLICK, closeAnnotationButtonClicked);
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
				
				// Put the Annotation Text Overlay in edit mode
				// So the user can write the text for their new annotation
				annotationTextOverlayBox.setAuthor(Auth.getInstance().getUsername());
				annotationTextOverlayBox.enterEditMode();
				
				media.listenForAnnotating();
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
		
		
		override public function highlightAnnotation(assetID:Number):void {
			media.highlightAnnotation(assetID);
		}
		
		override public function unhighlightAnnotation(assetID:Number):void {
			media.unhighlightAnnotation(assetID);		
		}
		
		/* ===================== EVENT LISTENER FUNCTIONS ====================== */

		
		
		override public function saveNewAnnotation():void {
			trace("Save Button Clicked");
			media.saveNewAnnotation();
//			
//			// Check what drawing mode we are in
//			var drawingMode:String = annotationToolbar.getAnnotationDrawingMode();
//			
//			if(drawingMode == AnnotationToolbar.BOX || drawingMode == AnnotationToolbar.NOTE)  {
//				// We are drawing a box (not using the pen tool)	
//				// Check they have drawn a box and not just hxit save (its at least 2px x 2px)
//				if(Math.abs(startAnnotationMouseX - finishAnnotationMouseX) < 2 &&
//					Math.abs(startAnnotationMouseY -finishAnnotationMouseY) < 2) {
//					Alert.show("No annotation drawn");
//					this.leaveNewAnnotationMode();
//					return;
//				} else if (annotationTextOverlayBox.getText() == "") {
//					Alert.show("No text given");
//					this.leaveNewAnnotationMode();
//					return;
//				}
//				
//				// Work out the X, Y, width and height as percentages
//				// So that this will work, when scaling
//				
//				// Just a reminder, percentX is < 0, e.g. like 0.5 is 50%
//				// And the widths/heights are like, 50 for 50%
//				// Because the DB stores percentX as a float, and widths/height as an Integer
//				var percentX:Number = Math.min(startAnnotationMouseX, finishAnnotationMouseX) / (pdf.width * pdf.scaleX);
//				var percentY:Number = Math.min(startAnnotationMouseY, finishAnnotationMouseY) / (pdf.height * pdf.scaleY);
//				// Have to x 10,000 as its 100x100, the first 100 is to get it as a percentage, the second 100 is because we cant
//				// store numbers with significant detail in the database since the type of 'width/height' is set to Integer
//				// and when the pdf is really long, the annotations break
//				var percentWidth:Number = Math.abs(finishAnnotationMouseX - startAnnotationMouseX) / (pdf.width * pdf.scaleX) * 100 * 10000000;
//				var percentHeight:Number = Math.abs(finishAnnotationMouseY - startAnnotationMouseY) / (pdf.height * pdf.scaleY) *100 * 10000000;
//				var annotationText:String = annotationTextOverlayBox.getText();
//				
//				trace("percents", percentWidth, percentHeight);
//				// Add this as an annotation to the view
//				// This is done temporarily, and will be reloaded once the controller
//				// has finished saving the annotation
//				var annotation:AnnotationBox = new AnnotationBox(
//					-1,
//					Auth.getInstance().getUsername(), 
//					annotationText,
//					percentHeight, 
//					percentWidth, 
//					percentX,
//					percentY,
//					pdf.width * pdf.scaleX,
//					pdf.height * pdf.scaleY
//				);
//				annotationsGroup.addElement(annotation);
//				annotation.save();
//
//				// Listen for this annotation being mouse-overed
//				annotation.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
//				annotation.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
//			} else if (drawingMode == AnnotationToolbar.PEN) {
//				
//				// Test the user has drawn a path
//				if(annotationCoordinates.getCount() == 0) {
//					Alert.show("No annotation drawn");
//					this.leaveNewAnnotationMode();
//					return;
//				}
//				
//				// Create a new annotation
//				var annotationPen:AnnotationPen = new AnnotationPen(
//					-1,
//					Auth.getInstance().getUsername(),
//					annotationCoordinates.getString(pdf.height * pdf.scaleY, pdf.width * pdf.scaleX),
//					pdf.height * pdf.scaleY,
//					pdf.width * pdf.scaleX,
//					annotationTextOverlayBox.getText()
//				);
//				annotationsGroup.addElement(annotationPen);
//				// Send this new annotation to the database (via the controller)
//				annotationPen.save();
//				
//				
//				
//				annotationPen.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
//				annotationPen.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
//			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
//				
//				if(pdf.getStartTextIndex() == pdf.getEndTextIndex()) {
//					Alert.show("No text highlighted");
//					this.leaveNewAnnotationMode();
//					return;
//				} else if (annotationTextOverlayBox.getText() == "") {
//					Alert.show("No text given");
//					this.leaveNewAnnotationMode();
//					return;
//				}
//				
////				var event:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_HIGHLIGHT, true);
////				this.dispatchEvent(event);
//				// Work out the X, Y, width and height as percentages
//				// So that this will work, when scaling
//				
//				// Just a reminder, percentX is < 0, e.g. like 0.5 is 50%
//				if(startAnnotationMouseY < finishAnnotationMouseY) {
//					percentX = (startAnnotationMouseX / pdf.scaleX) / pdf.width;
//					percentY = (startAnnotationMouseY / pdf.scaleY) / pdf.height;
//				} else if (startAnnotationMouseY > finishAnnotationMouseY) {
//					percentX = (finishAnnotationMouseX / pdf.scaleX) / pdf.width;
//					percentY = (finishAnnotationMouseY / pdf.scaleY) / pdf.height;
//				} else {
//					// They must be equal
//					if(startAnnotationMouseX < finishAnnotationMouseX) {
//						percentX = (startAnnotationMouseX / pdf.scaleX) / pdf.width;
//						percentY = (startAnnotationMouseY / pdf.scaleY) / pdf.height;
//					} else {
//						percentX = (finishAnnotationMouseX / pdf.scaleX) / pdf.width;
//						percentY = (finishAnnotationMouseY / pdf.scaleY) / pdf.height;
//					}					
//				}
//				
//				
//				var annotationHighlight:AnnotationHighlight = new AnnotationHighlight(
//					-1,
//					Auth.getInstance().getUsername(),
//					annotationTextOverlayBox.getText(),
//					percentX,
//					percentY,
//					pdf.getSelectionPage(),
//					pdf.getStartTextIndex(),
//					pdf.getEndTextIndex(),
//					pdf
//				);
//				annotationsGroup.addElement(annotationHighlight);
//				annotationHighlight.save();
//				
//				pdf.clearHighlight();
//			}
			
			this.leaveNewAnnotationMode();
		}
		
		
		/**
		 * The cancel annotation button was clicked. 
		 * @param e
		 * 
		 */		
		private function cancelAnnotationButtonClicked(e:Event):void {
			trace("Cancel annotation button clicked");
			// Stop listening for drawings
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawingNewAnnotation);
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_UP, stopDrawingNewAnnotation);
			
			// Clear any half/finished annotations
			newAnnotationsGroup.removeAllElements();
			
			// Hide the annotationtextoverlay
			this.hideAnnotationTextOverlay();
			
			// Show the current saved annotations again
			annotationsGroup.visible = true;
			
			// Exit annotation mode
			addAnnotationMode = false;
		}
		
		/**
		 * The annotation was hovered over, update the text overlay to
		 * show what the annotations author/text is. 
		 * @param e	The mouse over event
		 * 
		 */		
		private function annotationMouseOver(e:MouseEvent):void {
			// Get out the annotation
			trace("Mouse overed", e.target);
			var annotation:AnnotationInterface = (e.target as AnnotationInterface);
			
			// Highlight this annotation
			annotation.highlight();
			
			this.showAnnotationTextOverlayViewMode();
			annotationTextOverlayBox.setAuthor(annotation.getAuthor());
			annotationTextOverlayBox.setText(annotation.getText());
		}
		
		/**
		 * The annotation is no longer being hovered over, remove the overlay. 
		 * @param e
		 * 
		 */		
		private function annotationMouseOut(e:MouseEvent):void {
			
			// Get out the annotation
			var annotation:AnnotationInterface = (e.target as AnnotationInterface);
			
			// Highlight this annotation
			annotation.unhighlight();
			
			this.hideAnnotationTextOverlay();
		}
		
		private function closeAnnotationButtonClicked(e:MouseEvent):void {
			// Get out the annotation
			var annotation:AnnotationBox = (e.target as AnnotationBox);
			annotation.visible = false;
			trace("Annotation Deletion Clicked", assetID);
			var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_DELETED, true);
			myEvent.data.assetID = annotation.getID();
			this.dispatchEvent(myEvent);
		}
		
		/**
		 * We are starting to drawn an annotation 
		 * @param e
		 * 
		 */		
		private function startDrawingNewAnnotation(e:MouseEvent):void {
			trace("started drawing", e.target.mouseX, e.target.mouseY);
			
			// Check what drawing mode we are in
			var drawingMode:String = annotationToolbar.getAnnotationDrawingMode();
			
			trace("Starting to draw in Mode", drawingMode);
			// Clear the annotations values from previous draw
			startAnnotationMouseX = -1;
			startAnnotationMouseY = -1;
			finishAnnotationMouseX = -1;
			finishAnnotationMouseY  = -1;
			
			// Save the starting coordinates
			startAnnotationMouseX = e.target.mouseX;
			startAnnotationMouseY = e.target.mouseY;
			
			// Make the editable text overlay box disappear
			hideAnnotationTextOverlay();
			
			if(drawingMode == AnnotationToolbar.BOX) {
				// For the box, we want to make a new box, everytime 
				// you click (erases old boxes)
				// Clear any of the previous annotations
				newAnnotationsGroup.removeAllElements();
				// Create a new stop for the annotations
				canvas = new Group();
				canvas.percentWidth = 100;
				canvas.percentHeight = 100;
				newAnnotationsGroup.addElement(canvas);
			} else if (drawingMode == AnnotationToolbar.PEN) {
				if(!canvas || !newAnnotationsGroup.contains(canvas)) {
					// If we havent already got a canvas
					// Create one, and put it in the new annotations group
					canvas = new Group();
					canvas.percentWidth = 100;
					canvas.percentHeight = 100;
					newAnnotationsGroup.addElement(canvas);
				}
			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
				// We are highlighting some text
				trace("drawing a highlight");
				trace("Starting to draw annotation at", startAnnotationMouseX, startAnnotationMouseY);
				
				pdf.highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, startAnnotationMouseX, startAnnotationMouseY);
			} else if (drawingMode == AnnotationToolbar.NOTE) {
				trace("Placing a note");
				// For the box, we want to make a new note, everytime 
				// you click (erases old boxes)
				// Clear any of the previous annotations
				newAnnotationsGroup.removeAllElements();
				
				startAnnotationMouseX = e.target.mouseX - 2;
				startAnnotationMouseY = e.target.mouseY - 2;
				canvas = new Group();
				canvas.percentWidth = 100;
				canvas.percentHeight = 100;
				newAnnotationsGroup.addElement(canvas);
			}
			
			// Listen for the cursor being moved
			newAnnotationsGroup.addEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
		}
		
		/**
		 * Called when a user moves their mouse after they have started drawing an annotation. 
		 * @param e
		 * 
		 */		
		private function drawingNewAnnotation(e:MouseEvent):void {
			// We are drawing
			// Check what drawing mode we are in
			var drawingMode:String = annotationToolbar.getAnnotationDrawingMode();
			
			if(drawingMode == AnnotationToolbar.BOX) {
				// We are drawing a box
				
				var width:Number = e.target.mouseX - startAnnotationMouseX;
				var height:Number = e.target.mouseY - startAnnotationMouseY;
				
				canvas.graphics.clear();
				canvas.graphics.lineStyle(1, annotationToolbar.getSelectedColor(), 1);
				canvas.graphics.beginFill(annotationToolbar.getSelectedColor(), 0.5);
				
				canvas.graphics.drawRect(startAnnotationMouseX, startAnnotationMouseY, width, height);					
				
			} else if (drawingMode == AnnotationToolbar.PEN) {
				// We are using the PEN TOOL
				// The Straight line tool in flash, draws a line from the current pos
				// to a finish pos
				
				// Only save the values if it has been a significant change
				// Otherwise it becomes too intensive to draw all the points
				// Push values into array here
				var distanceThreshold:Number = 10;
				if(Math.abs(startAnnotationMouseX - e.target.mouseX) > distanceThreshold || Math.abs(startAnnotationMouseY - e.target.mouseY) > distanceThreshold) {
					canvas.graphics.lineStyle(3, annotationToolbar.getSelectedColor(), 1);
					canvas.graphics.beginFill(annotationToolbar.getSelectedColor(), 0.5);
					
					canvas.graphics.moveTo(startAnnotationMouseX, startAnnotationMouseY); 
					canvas.graphics.lineTo(e.target.mouseX, e.target.mouseY);
					
					trace("drawing", startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
					
					trace("saving point");
					annotationCoordinates.addCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
					
					startAnnotationMouseX = e.target.mouseX;
					startAnnotationMouseY = e.target.mouseY;
					
				} else {
					trace("not saving point");
				}
			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
				trace("Adding an text highlight stuff");
				pdf.clearHighlight();
				pdf.highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
			} 
			
		}
		private function stopDrawingNewAnnotation(e:MouseEvent):void {
			trace("stop drawing new annotation", e.target.mouseX, e.target.mouseY);
			
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
			
			// Check what drawing mode we are in
			var drawingMode:String = annotationToolbar.getAnnotationDrawingMode();
			
			// Save the stopping coordinates
			finishAnnotationMouseX = e.target.mouseX;
			finishAnnotationMouseY = e.target.mouseY;
			
			if(drawingMode == AnnotationToolbar.BOX) {
				// 
				var width:Number = finishAnnotationMouseX - startAnnotationMouseX;
				var height:Number = finishAnnotationMouseY - startAnnotationMouseY;
				
				// Check if they havent drawn a box (i.e. the width/heihgt are zero)
				if(width == 0 && height == 0) {
					// Clear the annotations values
					startAnnotationMouseX = -1;
					startAnnotationMouseY = -1;
					finishAnnotationMouseX = -1;
					finishAnnotationMouseY  = -1;
					
					return;
				}	
				
				trace('X', startAnnotationMouseX, finishAnnotationMouseX);
				trace('Y', startAnnotationMouseY, finishAnnotationMouseY);
				
				// create a box for the drawing
				canvas.graphics.clear();
				canvas.graphics.lineStyle(1, annotationToolbar.getSelectedColor(), 1);
				canvas.graphics.beginFill(annotationToolbar.getSelectedColor(), 0.5);
				canvas.graphics.drawRect(startAnnotationMouseX, startAnnotationMouseY, width, height);
				
				// Show the annotation text overlay in text entry mode
				showAnnotationTextOverlayTextEntryMode();
				
			} else if (drawingMode == AnnotationToolbar.PEN) {
				// We are using the PEN TOOL
				// The Straight line tool in flash, draws a line from the current pos
				// to a finish pos
				canvas.graphics.lineStyle(3, annotationToolbar.getSelectedColor(), 1);
				canvas.graphics.beginFill(annotationToolbar.getSelectedColor(), 0.5);
				
				canvas.graphics.moveTo(startAnnotationMouseX, startAnnotationMouseY); 
				canvas.graphics.lineTo(e.target.mouseX, e.target.mouseY);
				
				// Push values into array here
				annotationCoordinates.addCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
				
				startAnnotationMouseX = e.target.mouseX;
				startAnnotationMouseY = e.target.mouseY;
			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
				trace("highlighting some text");
				pdf.highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
				
				// Show the annotation text overlay in text entry mode
				showAnnotationTextOverlayTextEntryMode();
				
			} else if (drawingMode == AnnotationToolbar.NOTE) {

				// Save the stopping coordinates
				finishAnnotationMouseX = startAnnotationMouseX + 5;
				finishAnnotationMouseY = startAnnotationMouseY + 5;
				
				
				// create a box for the drawing
				canvas.graphics.clear();
				canvas.graphics.lineStyle(1, annotationToolbar.getSelectedColor(), 1);
				canvas.graphics.beginFill(annotationToolbar.getSelectedColor(), 0.5);
				canvas.graphics.drawRect(startAnnotationMouseX, startAnnotationMouseY, 5, 5);
				
				// Show the annotation text overlay in text entry mode
				showAnnotationTextOverlayTextEntryMode();
			}
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
		
		private function fitButtonClicked(e:MouseEvent):void {
			// This needs work lol TODO
			media.scaleY = scrollerAndOverlayGroup.height / media.height;
		}
		
		/**
		 * When the user mouses over the text overlay box, dont make it disappear
		 * this will stop it flickering when an annotation is underneath the box. 
		 * @param e
		 * 
		 */		
		private function textOverlayMouseOver(e:MouseEvent):void {
			trace("DING");
			
		}
		
		private function textOverlayMouseOut(e:MouseEvent):void {
			trace("DONG");
		}
		/* ==================================== HELPER FUNCTIONS ========================= */
		/**
		 * Adds the annotations boxes to the image.
		 *  
		 * Clears all current annotations before re-adding annotations saved in the 
		 * annotations Array. 
		 * 
		 */		
		private function addAnnotationsToView():void {
			trace("Adding annotations to view");
			// Even though this is called once the image has 'loaded'
			// The image may not have actually appeared on the stage yet
			// so its width/height == 0; We just need to wait for it to 
			// be loaded on the stage.
			if(pdf.width == 0) {
				setTimeout(addAnnotationsToView, 1000);
				return;
			}
			
			clearAnnotations();
			
			trace("image dimensions:", pdf.width, pdf.height);
			
			trace("Adding", annotationsArray.length, "annotations");
			
			// Go through all the annotations
			for(var i:Number = 0; i < annotationsArray.length; i++) {
				
				var annotationData:Model_Commentary = annotationsArray[i] as Model_Commentary;
				
				if(annotationData.annotationType == Model_Commentary.ANNOTATION_BOX_TYPE_ID) {
					// Its a annotation box
					trace("Adding box annotation", annotationData.annotation_x, annotationData.annotation_y);
					// Make a new annotation box
					var annotation:AnnotationBox = new AnnotationBox(
						annotationData.base_asset_id,
						annotationData.meta_creator, 
						annotationData.annotation_text,
						annotationData.annotation_height, 
						annotationData.annotation_width, 
						annotationData.annotation_x,
						annotationData.annotation_y,
						pdf.width * pdf.scaleX,
						pdf.height * pdf.scaleY
					);
					trace("Added at", annotation.x, annotation.y);
					
					annotationsGroup.addElement(annotation);
					// Listen for this annotation being mouse-overed
					annotation.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
					annotation.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
				} else if (annotationData.annotationType == Model_Commentary.ANNOTATION_PEN_TYPE_ID) {
					trace("Adding pen annotation");
					var annotationPen:AnnotationPen = new AnnotationPen(
						annotationData.base_asset_id,
						annotationData.meta_creator,
						annotationData.path,
						pdf.height * pdf.scaleY,
						pdf.width * pdf.scaleX,
						annotationData.annotation_text
					);
					
					trace(annotationPen);
					annotationsGroup.addElement(annotationPen);
					
					// Listen for this annotation being mouse-overed
					annotationPen.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
					annotationPen.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
				} else if (annotationData.annotationType == Model_Commentary.ANNOTATION_HIGHLIGHT_TYPE_ID) {
					trace("Adding an highlight annotation");
					var annotationHighlight:AnnotationHighlight = new AnnotationHighlight(
						annotationData.base_asset_id,
						annotationData.meta_creator,
						annotationData.annotation_text,
						annotationData.annotation_x,
						annotationData.annotation_y,
						annotationData.annotation_linenum,
						annotationData.annotation_start,
						annotationData.annotation_end,
						pdf
					);

					trace(annotationHighlight);
					annotationsGroup.addElement(annotationHighlight);
					
					// Listen for this annotation being mouse-overed
					annotationHighlight.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
					annotationHighlight.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
				} else {
					trace("Unknown annotation");
				}
			}
			trace("*****************");
		}
		
		/* ============= HELPER FUNCTIONS ============= */
		
		/**
		 * Leaves new annotation mode.  
		 * 
		 */		
		private function leaveNewAnnotationMode():void {
//			// Stop listening for drawings
//			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawingNewAnnotation);
//			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
//			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_UP, stopDrawingNewAnnotation);
//			
//			// Clear any half/finished annotations
//			newAnnotationsGroup.removeAllElements();
//			
//			hideAnnotationTextOverlay();
//			
//			addAnnotationMode = false;
//			
//			// Show the current saved annotations again
//			annotationsGroup.visible = true;
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
		override public function showAnnotationTextOverlayTextEntryMode():void {
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