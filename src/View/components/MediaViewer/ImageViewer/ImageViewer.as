package View.components.MediaViewer.ImageViewer
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Lib.AnnotationCoordinateCollection;
	import Lib.it.transitions.Tweener;
	
	import Model.Model_Commentary;
	
	import View.MediaView;
	import View.components.Annotation.AnnotationBox;
	import View.components.Annotation.AnnotationInterface;
	import View.components.Annotation.AnnotationPen;
	import View.components.Annotation.AnnotationTextOverlayBox;
	import View.components.Annotation.AnnotationToolbar;
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
	import mx.effects.Resize;
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
	
	public class ImageViewer extends MediaViewer implements MediaViewerInterface
	{
		private var image:Image; // The Image object to display
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
		
		public function ImageViewer()
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
			annotationToolbar = new AnnotationToolbar(this);
			this.addElement(annotationToolbar);
			
			// Creatoe a group for the Image Scroller and the Annotation Text Overlay
			scrollerAndOverlayGroup = new Group();
			scrollerAndOverlayGroup.percentHeight = 100;
			scrollerAndOverlayGroup.percentWidth = 100;
			this.addElement(scrollerAndOverlayGroup);
			
			// Create scroller so we can scroll
			var myScroller:Scroller = new Scroller();
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
			var imageAndAnnotationsGroup:Group = new Group();
			horizontalAlignGroup.addElement(imageAndAnnotationsGroup);
			
			// The image
			image = new Image();
			image.percentWidth = 100;
			image.percentHeight = 100;
			imageAndAnnotationsGroup.addElement(image);
			
			// Where we are going to put the annotations
			annotationsGroup = new Group();
			annotationsGroup.percentHeight = 100;
			annotationsGroup.percentWidth = 100;
			imageAndAnnotationsGroup.addElement(annotationsGroup);
			
			loadingLabel = new Label();
			loadingLabel.text = 'Loading...';
			loadingLabel.setStyle('color', 'white');
			loadingLabel.setStyle('fontSize', 16);
			imageAndAnnotationsGroup.addElement(loadingLabel);
			
			// Create New annotations group
			// This is where the temporary place where we are drawing 
			// the new annotations (while they are being drawn)
			// once they are saved, they go to the annotationsGroup
			newAnnotationsGroup = new Group();
			newAnnotationsGroup.percentHeight = 100;
			newAnnotationsGroup.percentWidth = 100;
			newAnnotationsGroup.mouseChildren = false;
			imageAndAnnotationsGroup.addElement(newAnnotationsGroup);
			
			
			
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
			
			// Setup annotation close button
//			closeButton = new Image();
//			closeButton.source = closeButtonImage;
//			closeButton.visible = true;
//				
			// Create the Black Semi-transparent box that appears
			// at the bottom/top of the screen
			// and shows the contents of the annotations
			// The box moves depending on if the annotation highlighted is in the top/bottom
			annotationTextOverlayBox = new AnnotationTextOverlayBox();
			annotationTextOverlayBox.visible = false;
			scrollerAndOverlayGroup.addElement(annotationTextOverlayBox);
			
			
			// Event Listeners
			image.addEventListener(Event.COMPLETE, sourceLoaded);
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
			trace("Loading Image...", url);
			// Save the URL
			sourceURL = url;
			
			trace("Adding Image:", sourceURL);
			// Load the Image from the URL
			image.source = sourceURL;
			
			// Listen for loading progress (to display hte loading graphics)
			image.addEventListener(ProgressEvent.PROGRESS, progressUpdate);
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
				trace("Showing annotation toolbar");
				addAnnotationMode = true;
				annotationToolbar.show();
				
				// Hide the currently saved annotations
				// Just to make it easier for people to draw new ones
				annotationsGroup.visible = false;
				
				// Put the Annotation Text Overlay in edit mode
				// So the user can write the text for their new annotation
				annotationTextOverlayBox.setAuthor(Auth.getInstance().getUsername());
				annotationTextOverlayBox.enterEditMode();
				
				// Listen for users to start drawing
				newAnnotationsGroup.addEventListener(MouseEvent.MOUSE_DOWN, startDrawingNewAnnotation);
				newAnnotationsGroup.addEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
				// Listen for users to stop drawing
				newAnnotationsGroup.addEventListener(MouseEvent.MOUSE_UP, stopDrawingNewAnnotation);
			} else {
				trace("Already in add annotation mode");
			}
		}
		
		/**
		 * Removes all the current annotations 
		 */		
		public function clearAnnotations():void {
			annotationsGroup.removeAllElements();
		}
		
		/**
		 * Removes all the non-saved annotations from the image viewer. 
		 * 
		 */		
		override public function clearNonSavedAnnotations():void {
			trace("Image Viewer: Removing all non-saved annotations");
			// Remove the visual part
			newAnnotationsGroup.removeAllElements();
			// Get rid of any saved paths
			annotationCoordinates = new AnnotationCoordinateCollection();
			hideAnnotationTextOverlay();
		}
		
		
		override public function addAnnotations(annotationsArray:Array):void {
			trace("Adding Annotatio");
			this.annotationsArray = annotationsArray;
			
			// Sorts the array of annotations so that the
			// bigger annotations are first, so they are added to the screen first
			// and the smaller annotations sit on top (so you can still get to them)
			this.annotationsArray.sortOn('annotationArea', Array.DESCENDING | Array.NUMERIC);
			
			// Set the annotations to loaded
			annotationsAreLoaded = true;
			
			if(isImageLoaded) {
				// This image is loaded, add the annotations now
				this.addAnnotationsToView();
			}
		}
		
		override public function showAnnotations():void {
			// Hide the currently saved annotations
			annotationsGroup.visible = true;
		}
		
		override public function hideAnnotations():void {
			// Hide the currently saved annotations
			annotationsGroup.visible = false;
		}
		
		
		override public function highlightAnnotation(assetID:Number):void {
			trace("Finding annotation to highlight", assetID);

			
			for(var i:Number = 0; i < annotationsGroup.numElements; i++) {
				var annotation:AnnotationInterface = annotationsGroup.getElementAt(i) as AnnotationInterface;
				trace("Looking at", annotation.getID());
				if(annotation.getID() == assetID) {
					annotation.highlight();
					
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
					
					annotationTextOverlayBox.visible = true;
					annotationTextOverlayBox.bottom = 0;
					annotationTextOverlayBox.setAuthor(annotation.getAuthor());
					annotationTextOverlayBox.setText(annotation.getText());
					return;
				}
			}
		}

		override public function unhighlightAnnotation(assetID:Number):void {
			trace("Finding annotation to unhighlight");
			for(var i:Number = 0; i < annotationsGroup.numElements; i++) {
				var annotation:AnnotationInterface = annotationsGroup.getElementAt(i) as AnnotationInterface;
				if(annotation.getID() == assetID) {
					annotation.unhighlight();
					annotationTextOverlayBox.visible = false;
					return;
				}
			}		
		}
		
		/* ===================== EVENT LISTENER FUNCTIONS ====================== */
		
		/**
		 * The image's loading has progressed. Updates the 'loading' display. 
		 * @param e	The progress updated event.
		 * 
		 */		
		private function progressUpdate(e:ProgressEvent):void {
			var percentLoaded:Number = Math.round(e.bytesLoaded / e.bytesTotal * 100);
			loadingLabel.text = 'Loading... ' + percentLoaded + '%';
		}
		/**
		 * The image to display has been loaded.
		 * If the image is bigger than the container, make it fit
		 * Otherwise, let it be its regular size. 
		 * @param e
		 * 
		 */
		private function sourceLoaded(e:Event):void {
			
			// Hide the loading label
			loadingLabel.visible = false;
			
			// Save the actual size of the image (used when we resize the image)
			actualImageHeight = image.contentHeight;
			actualImageWidth = image.contentWidth;
			
			
			// If the image is bigger than the current space (i.e. will need the scrollers to appear)
			// we want to initially set the zoom, so it all fits on the page
			// We need to work out which side - height or width is the most out of bounds
			var widthOutOfBounds:Number = scrollerAndOverlayGroup.width - actualImageWidth;
			var heightOutOfBounds:Number = scrollerAndOverlayGroup.height - actualImageHeight;
			trace("Out of bounds", widthOutOfBounds, heightOutOfBounds);
			
			// The more negative, the more out of bounds
			if(widthOutOfBounds < 0 || heightOutOfBounds < 0) {
				// At least one side is out of the bounds of the box	
				trace("At least one side is out of the bounds of the box");
				if(widthOutOfBounds < 0 && heightOutOfBounds >= 0) {
					trace("Only the width is out of bounds");
					// The width is out of bounds, so we scale it so it fits within the bounds
					var scalePercent:Number = Math.max(scrollerAndOverlayGroup.width / image.contentWidth, 0.1);
					image.width = image.contentWidth * scalePercent;
					image.height = image.contentHeight * scalePercent;
					resizeSlider.value = scalePercent * 100;
				} else if (widthOutOfBounds >= 0 && heightOutOfBounds < 0) {
					// Now make the height fit with the new scaled width
					trace("Only the height is out of bounds");
					scalePercent = Math.max(scrollerAndOverlayGroup.height / image.contentHeight, 0.1);
					image.width = image.contentWidth * scalePercent;
					image.height = image.contentHeight * scalePercent;
					resizeSlider.value = scalePercent * 100;
				} else if (widthOutOfBounds < 0 && heightOutOfBounds < 0) {
					if(widthOutOfBounds < heightOutOfBounds) {
						trace("width out of bounds more");
						// This means the width is more out of bounds, so we can scale it by the width
						// We set it to have a min value of 10, because our resize slider stops at 10 percent
						scalePercent = Math.max(scrollerAndOverlayGroup.width / image.contentWidth, 0.1);
						image.width = image.contentWidth * scalePercent;
						image.height = image.contentHeight * scalePercent;
						
						heightOutOfBounds = scrollerAndOverlayGroup.height - image.height;
						if(heightOutOfBounds < 0) {
							trace("Image content height", image.contentHeight, "actual hieght", actualImageHeight, image.height);
							// Now make the height fit with the new scaled width
							scalePercent = Math.max(scrollerAndOverlayGroup.height / image.contentHeight, 0.1);
							image.width = image.contentWidth * scalePercent;
							image.height = image.contentHeight * scalePercent;
						}
						resizeSlider.value = scalePercent * 100;
					} else {
						// The height is more out of bounds
						trace("the height is more out of bounds");
						// So scale it
						scalePercent = Math.max(scrollerAndOverlayGroup.height / image.contentHeight, 0.1);
						image.width = image.contentWidth * scalePercent;
						image.height = image.contentHeight * scalePercent;
						
						widthOutOfBounds = scrollerAndOverlayGroup.width - image.width;
						if(widthOutOfBounds < 0) {
							trace("the width is still out of bounds, scale it to fit");
							// Now scale the width so it fits in with the new height
							scalePercent = Math.max(scrollerAndOverlayGroup.width / image.contentWidth, 0.1);
							image.width = image.contentWidth * scalePercent;
							image.height = image.contentHeight * scalePercent;
						}
						resizeSlider.value = scalePercent * 100;
					}
				}
			} else {
				// Set the dimensions of the image to be the dimensions of its image conent
				image.width = image.contentWidth;
				image.height = image.contentHeight;
			}
			
			
			
			isImageLoaded = true;
			
			// Load/Reload the annotations (because the image's size may have changed if its been reloaded)
			// or if its the first load, its going to change a lot :P (from 0 to something :P)
			if(annotationsAreLoaded) {
				trace("image is loaded, now adding the annotations");
				this.addAnnotationsToView();
			}
		}
		

		public function saveAnnotation():void {
			trace("Save Button Clicked");

			// Check what drawing mode we are in
			var drawingMode:String = annotationToolbar.getAnnotationDrawingMode();
			
			// We are drawing a box (not using the pen tool)
			if(drawingMode == AnnotationToolbar.BOX) {
				
				// Check they have drawn a box and not just hit save
				if(Math.abs(startAnnotationMouseX - finishAnnotationMouseX) < 2 &&
				 	Math.abs(startAnnotationMouseY -finishAnnotationMouseY) < 2) {
					Alert.show("No annotation drawn");
					this.leaveNewAnnotationMode();
					return;
				} else if (annotationTextOverlayBox.getText() == "") {
					Alert.show("No text given");
					this.leaveNewAnnotationMode();
					return;
				}
				
				// Work out the X, Y, width and height as percentages
				// So that this will work, when scaling

				// Just a reminder, percentX is < 0, e.g. like 0.5 is 50%
				// And the widths/heights are like, 50 for 50%
				// Because the DB stores percentX as a float, and widths/height as an Integer
				var percentX:Number = Math.min(startAnnotationMouseX, finishAnnotationMouseX) / image.width;
				var percentY:Number = Math.min(startAnnotationMouseY, finishAnnotationMouseY) / image.height;
				var percentWidth:Number = Math.abs(finishAnnotationMouseX - startAnnotationMouseX) / image.width * 100;
				var percentHeight:Number = Math.abs(finishAnnotationMouseY - startAnnotationMouseY) / image.height * 100;
				var annotationText:String = annotationTextOverlayBox.getText();
				
				// Send the event
				var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_BOX, true);
				myEvent.data.percentX = percentX;
				myEvent.data.percentY = percentY;
				myEvent.data.percentWidth = percentWidth;
				myEvent.data.percentHeight = percentHeight;
				myEvent.data.annotationText = annotationText;
				this.dispatchEvent(myEvent);
				
				// Add this as an annotation to the view
				// This is done temporarily, and will be reloaded once the controller
				// has finished saving the annotation
				var annotation:AnnotationBox = new AnnotationBox(
					-1,
					Auth.getInstance().getUsername(), 
					annotationText,
					percentHeight, 
					percentWidth, 
					percentX,
					percentY,
					image.width,
					image.height
				);
				
				annotationsGroup.addElement(annotation);
				
				// Listen for this annotation being mouse-overed
				annotation.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
				annotation.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
			} else if (drawingMode == AnnotationToolbar.PEN) {
				
				// Test the user has drawn a path
				if(annotationCoordinates.getCount() == 0) {
					Alert.show("No annotation drawn");
					this.leaveNewAnnotationMode();
					return;
				}
				
				myEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_PEN, true);
				
				myEvent.data.path = annotationCoordinates.getString(image.height, image.width);
				myEvent.data.text = annotationTextOverlayBox.getText();
				
				trace("XML for drawing path", myEvent.data.path);
				
				this.dispatchEvent(myEvent);
				
				var annotationPen:AnnotationPen = new AnnotationPen(
					-1,
					Auth.getInstance().getUsername(),
					myEvent.data.path,
					image.height,
					image.width,
					annotationTextOverlayBox.getText()
				);
				annotationsGroup.addElement(annotationPen);
				
				annotationPen.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
				annotationPen.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
			}
			
			this.leaveNewAnnotationMode();
		}
		
		
		/**
		 * The cancel annotation button was clicked. 
		 * @param e
		 * 
		 */		
		private function cancelAnnotationButtonClicked(e:Event):void {
			// Stop listening for drawings
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawingNewAnnotation);
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_UP, stopDrawingNewAnnotation);
			
			// Clear any half/finished annotations
			newAnnotationsGroup.removeAllElements();
			
			// Hide the annotationtextoverlay
			annotationTextOverlayBox.enterReadOnlyMode();
			annotationTextOverlayBox.visible = false;
			
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
			annotationTextOverlayBox.visible = false;
			
			// Start drawing the box
			drawing = true;
			
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
			}
		}
		
		private function drawingNewAnnotation(e:MouseEvent):void {
			// We are drawing
			
			if(drawing) {
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
					
					
				}
			
			}
		}
		private function stopDrawingNewAnnotation(e:MouseEvent):void {
			trace("stop drawing new annotation", e.target.mouseX, e.target.mouseY);
		
			// Stop drawing
			drawing = false;
			
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
			}
		}
		
		/**
		 * Resizes the image when the slider is moved 
		 * @param e	The slider change event
		 * 
		 */		
		private function resizeImage(e:Event):void {
			trace("resizing");
			trace((e.target as HSlider).value);
			var resizeFactor:Number = (e.target as HSlider).value / 100; 
			
			trace("Actual image size", image.contentWidth, image.contentHeight);
			
			// Resize the image by the scaling facotr
			image.width = actualImageWidth * resizeFactor;
			image.height = actualImageHeight * resizeFactor;
			
			// Reposition the annotations based on the new image size
			for(var i:Number = 0; i < annotationsGroup.numElements; i++) {
				var annotation:AnnotationInterface = annotationsGroup.getElementAt(i) as AnnotationInterface;
				annotation.readjust(image.width, image.height);
			}
		}
		
		/**
		 * The resize to 100% button was clicked. Resize the image to
		 * its actual size. 
		 * @param e
		 * 
		 */		
		private function percentButtonClicked(e:MouseEvent):void {
			image.width = actualImageWidth;
			image.height = actualImageHeight;
			resizeSlider.value = 100;
			
			// Reposition the annotations based on the new image size
			for(var i:Number = 0; i < annotationsGroup.numElements; i++) {
				var annotation:AnnotationInterface = annotationsGroup.getElementAt(i) as AnnotationInterface;
				annotation.readjust(image.width, image.height);
			}
		}
		
		private function fitButtonClicked(e:MouseEvent):void {
			// If the image is bigger than the current space (i.e. will need the scrollers to appear)
			// we want to initially set the zoom, so it all fits on the page
			// We need to work out which side - height or width is the most out of bounds
			var widthOutOfBounds:Number = scrollerAndOverlayGroup.width - actualImageWidth;
			var heightOutOfBounds:Number = scrollerAndOverlayGroup.height - actualImageHeight;
			trace("Out of bounds", widthOutOfBounds, heightOutOfBounds);
			
			if(widthOutOfBounds < 0 || heightOutOfBounds < 0) {
				// At least one side is out of the bounds of the box	
				trace("At least one side is out of the bounds of the box");
				if(widthOutOfBounds < 0 && heightOutOfBounds >= 0) {
					trace("Only the width is out of bounds");
					// The width is out of bounds, so we scale it so it fits within the bounds
					var scalePercent:Number = Math.max(scrollerAndOverlayGroup.width / image.contentWidth, 0.1);
					image.width = image.contentWidth * scalePercent;
					image.height = image.contentHeight * scalePercent;
					resizeSlider.value = scalePercent * 100;
				} else if (widthOutOfBounds >= 0 && heightOutOfBounds < 0) {
					// Now make the height fit with the new scaled width
					trace("Only the height is out of bounds");
					scalePercent = Math.max(scrollerAndOverlayGroup.height / image.contentHeight, 0.1);
					image.width = image.contentWidth * scalePercent;
					image.height = image.contentHeight * scalePercent;
					resizeSlider.value = scalePercent * 100;
				} else if (widthOutOfBounds < 0 && heightOutOfBounds < 0) {
					if(widthOutOfBounds < heightOutOfBounds) {
						trace("width out of bounds more");
						// This means the width is more out of bounds, so we can scale it by the width
						// We set it to have a min value of 10, because our resize slider stops at 10 percent
						scalePercent = Math.max(scrollerAndOverlayGroup.width / image.contentWidth, 0.1);
						image.width = image.contentWidth * scalePercent;
						image.height = image.contentHeight * scalePercent;
						
						heightOutOfBounds = scrollerAndOverlayGroup.height - image.height;
						if(heightOutOfBounds < 0) {
							trace("Image content height", image.contentHeight, "actual hieght", actualImageHeight, image.height);
							// Now make the height fit with the new scaled width
							scalePercent = Math.max(scrollerAndOverlayGroup.height / image.contentHeight, 0.1);
							image.width = image.contentWidth * scalePercent;
							image.height = image.contentHeight * scalePercent;
						}
						resizeSlider.value = scalePercent * 100;
					} else {
						// The height is more out of bounds
						// So scale it
						scalePercent = Math.max(scrollerAndOverlayGroup.height / image.contentHeight, 0.1);
						image.width = image.contentWidth * scalePercent;
						image.height = image.contentHeight * scalePercent;
						
						widthOutOfBounds = scrollerAndOverlayGroup.width - image.width;
						if(widthOutOfBounds < 0) {
							// Now scale the width so it fits in with the new height
							scalePercent = Math.max(scrollerAndOverlayGroup.width / image.contentWidth, 0.1);
							image.width = image.contentWidth * scalePercent;
							image.height = image.contentHeight * scalePercent;
						}
						resizeSlider.value = scalePercent * 100;
					}
				}
			} else {
				// Set the dimensions of the image to be the dimensions of its image conent
				image.width = scrollerAndOverlayGroup.width;
				image.height = scrollerAndOverlayGroup.height;
				
				if(widthOutOfBounds < heightOutOfBounds) {
					// The width is closest to the bounds
					// so lets scale the width up
					scalePercent = Math.max(scrollerAndOverlayGroup.width / image.contentWidth, 0.1);
					image.width = image.contentWidth * scalePercent;
					image.height = image.contentHeight * scalePercent;
					resizeSlider.value = scalePercent * 100;
					
				} else {
					scalePercent = Math.max(scrollerAndOverlayGroup.height / image.contentHeight, 0.1);
					image.width = image.contentWidth * scalePercent;
					image.height = image.contentHeight * scalePercent;
					resizeSlider.value = scalePercent * 100;
				}
			}
			
			// Reposition the annotations based on the new image size
			for(var i:Number = 0; i < annotationsGroup.numElements; i++) {
				var annotation:AnnotationInterface = annotationsGroup.getElementAt(i) as AnnotationInterface;
				annotation.readjust(image.width, image.height);
			}
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

			// Even though this is called once the image has 'loaded'
			// The image may not have actually appeared on the stage yet
			// so its width/height == 0; We just need to wait for it to 
			// be loaded on the stage.
			if(image.width == 0) {
				setTimeout(addAnnotationsToView, 1000);
				return;
			}
			
			clearAnnotations();
			
			trace("image dimensions:", image.width, image.height);
			
			// Go through all the annotations
			for(var i:Number = 0; i < annotationsArray.length; i++) {
				
				var annotationData:Model_Commentary = annotationsArray[i] as Model_Commentary;
				
				if(annotationData.annotationType == Model_Commentary.ANNOTATION_BOX_TYPE_ID) {
					// Its a annotation box
					
					// Make a new annotation box
					var annotation:AnnotationBox = new AnnotationBox(
						annotationData.base_asset_id,
						annotationData.meta_creator, 
						annotationData.annotation_text,
						annotationData.annotation_height, 
						annotationData.annotation_width, 
						annotationData.annotation_x,
						annotationData.annotation_y,
						image.width,
						image.height
					);

					annotationsGroup.addElement(annotation);
					
					// Listen for this annotation being mouse-overed
					annotation.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
					annotation.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
				} else if (annotationData.annotationType == Model_Commentary.ANNOTATION_PEN_TYPE_ID) {
					var annotationPen:AnnotationPen = new AnnotationPen(
						annotationData.base_asset_id,
						annotationData.meta_creator,
						annotationData.path,
						image.height,
						image.width,
						annotationData.annotation_text
					);
					
					trace(annotationPen);
					annotationsGroup.addElement(annotationPen);
					
					// Listen for this annotation being mouse-overed
					annotationPen.addEventListener(MouseEvent.MOUSE_OVER, annotationMouseOver);
					annotationPen.addEventListener(MouseEvent.MOUSE_OUT, annotationMouseOut);
				}
				
				
				
			}
		}
		
		/* ============= HELPER FUNCTIONS ============= */
		
		/**
		 * Leaves new annotation mode.  
		 * 
		 */		
		private function leaveNewAnnotationMode():void {
			// Stop listening for drawings
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawingNewAnnotation);
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
			newAnnotationsGroup.removeEventListener(MouseEvent.MOUSE_UP, stopDrawingNewAnnotation);
			
			// Clear any half/finished annotations
			newAnnotationsGroup.removeAllElements();
			
			hideAnnotationTextOverlay();
			
			addAnnotationMode = false;
			
			// Show the current saved annotations again
			annotationsGroup.visible = true;
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