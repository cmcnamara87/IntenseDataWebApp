package View.components
{
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Lib.AnnotationCoordinateCollection;
	
	import Model.Model_Commentary;
	
	import View.components.Annotation.AnnotationBox;
	import View.components.Annotation.AnnotationHighlight;
	import View.components.Annotation.AnnotationInterface;
	import View.components.Annotation.AnnotationPen;
	import View.components.Annotation.AnnotationToolbar;
	import View.components.MediaViewer.PDFViewer.PDF;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class MediaType extends UIComponent
	{
		public static const MEDIA_PDF:String = "pdf";
		
		private var mediaType:String; // The type of media we are using
		private var sourceURL:String; // The URL of the media we are using
		
		private var media:UIComponent; // The actual loaded media we are dispalyed
		
		private var annotationsData:Array; // The data for each annotation (all model_commentaries)
		private var annotations:Array; // All the current annotations saved and added to the media (annotation objects0
		private var newAnnotationSpace:Sprite; // The space where we can draw new annotations
		private var annotationCoordinates:AnnotationCoordinateCollection; // Stores the coordiante pairs for using the pen tool
		
		private var mediaLoaded:Boolean; // Stores whether the media has finish loading
		private var annotationsLoaded:Boolean; // Stores whether the annotations have loaded
		
		private var startAnnotationMouseX:Number = -1; // THe X position of the mouse, when the user starts to draw an annotation
		private var startAnnotationMouseY:Number = -1; // The y position of the mouse when they start 
		private var finishAnnotationMouseX:Number = -1;  // the X position when they stop drawing
		private var finishAnnotationMouseY:Number = -1; // The Y position when they stop
		
		
		public function MediaType(mediaType:String)
		{
			super();
			
			this.mediaType = mediaType;
		}
		
		public function load(url:String):void {
			trace("Loading ", mediaType, "...", url);
			// Save the URL
			sourceURL = url;
			
			annotations = new Array();
			newAnnotationSpace = new Sprite();
			annotationCoordinates = new AnnotationCoordinateCollection();
			
			
			if(mediaType == MEDIA_PDF) {
				media = new PDF(sourceURL);
			}
			
			trace("media issss", media);
			// Listen for the media to have finished loaded, and then to have added to the display
			media.addEventListener(IDEvent.PDF_LOADED, sourceLoaded);
			
			
			media.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				var percentLoaded:Number = Math.round(e.bytesLoaded / e.bytesTotal * 100);
				trace("Loaded", percentLoaded);
			});
		}
		
		private function sourceLoaded(e:IDEvent):void {
			// We have finished loading hte media
			// Add it to the display (now that its loaded)
			this.addChild(media);
			this.addChild(newAnnotationSpace);
			// Set this width, to match the media (so the viewer can center this media)
			this.width = media.width;
			this.height = media.height;
			
			mediaLoaded = true;
			if(annotationsLoaded) {
				this.addAnnotationsToDisplay();
			}
		}
		
		/* ================== ANNOTATION FUNCTION =================== */
		
		/**
		 * Saves the array of annotations and (if the media has finsihedl oading) gets them to display. 
		 * @param annotationsArray 	An array of annotations
		 * 	
		 */		
		public function addAnnotations(annotationsArray:Array):void {
			trace("Adding annotations");
			this.annotationsData = annotationsArray;

			// Sorts the array of annotations so that the
			// bigger annotations are first, so they are added to the screen first
			// and the smaller annotations sit on top (so you can still get to them)
			this.annotationsData.sortOn('annotationArea', Array.DESCENDING | Array.NUMERIC);
			
			// Set the annotations to loaded
			annotationsLoaded = true;
			
			if(mediaLoaded) {
				// This image is loaded, add the annotations now
				this.addAnnotationsToDisplay();
			}
		}
		
		/**
		 * Shows the annotations currently on the media 
		 * 
		 */		
		public function showAnnotations():void {
			for(var i:Number = 0; i < annotations.length; i++) {
				var annotation:UIComponent = annotations[i] as UIComponent;
				annotation.includeInLayout = true;
				annotation.visible = true;
			}
		}
		
		/**
		 * Hides the annotations currently on the media 
		 * 
		 */		
		public function hideAnnotations():void {
			for(var i:Number = 0; i < annotations.length; i++) {
				var annotation:UIComponent = annotations[i] as UIComponent;
				annotation.includeInLayout = false;
				annotation.visible = false;
			}
		}
		
		/**
		 * Removes/deletes all the annotations from the current media. 
		 * 
		 */		
		public function removeAllAnnotations():void {
			while(annotations.length) {
				var annotation:UIComponent = annotations.pop();
				this.removeChild(annotation);
			}
		}
		
		/**
		 * Removes/deletes all the new temp annotations 
		 * 
		 */		
		public function removeAllNonSavedAnnotations():void {
//			while(newAnnotations.length) {
//				var annotation:UIComponent = newAnnotations.pop();
//				this.removeChild(annotation);
//			}
			newAnnotationSpace.graphics.clear();
			annotationCoordinates = new AnnotationCoordinateCollection();
		}
		
		/**
		 * Highlight an annotation 
		 * @param assetID
		 * 
		 */		
		public function highlightAnnotation(assetID:Number):void {
			trace("Finding annotation to highlight", assetID);

			for(var i:Number = 0; i < annotations.length; i++) {
				var annotation:AnnotationInterface = annotations[i] as AnnotationInterface;
				trace("Looking at", annotation.getID());
				if(annotation.getID() == assetID) {
					annotation.highlight();
					break;
				}
			}
		}
		
		/**
		 * Unhighlight annotation 
		 * @param assetID	The ID of the annotation to unhighlight
		 * 
		 */		
		public function unhighlightAnnotation(assetID:Number):void {
			trace("Finding annotation to unhighlight");
			for(var i:Number = 0; i < annotations.length; i++) {
				var annotation:AnnotationInterface = annotations[i] as AnnotationInterface;
				trace("Looking at", annotation.getID());
				if(annotation.getID() == assetID) {
					annotation.unhighlight();
					break;
				}
			}
		}
		
		/**
		 * Adds the annotations boxes to the image.
		 *  
		 * Clears all current annotations before re-adding annotations saved in the 
		 * annotations Array. 
		 * 
		 */		
		private function addAnnotationsToDisplay():void {
			trace("Adding annotations to view");
			
			this.removeAllAnnotations();
			
			trace("image dimensions:", media.width, media.height);
			
			trace("Adding", annotationsData.length, "annotations");
			
			// Go through all the annotations
			for(var i:Number = 0; i < annotationsData.length; i++) {
				
				var annotationData:Model_Commentary = annotationsData[i] as Model_Commentary;

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
						this.scaleX,
						this.scaleY
					);
					trace("Added at", annotation.x, annotation.y);
					
					this.addChild(annotation);
					annotations.push(annotation);
				} else if (annotationData.annotationType == Model_Commentary.ANNOTATION_PEN_TYPE_ID) {
					trace("Adding pen annotation");
					var annotationPen:AnnotationPen = new AnnotationPen(
						annotationData.base_asset_id,
						annotationData.meta_creator,
						annotationData.path,
						media.height * this.scaleY,
						media.width * this.scaleX,
						annotationData.annotation_text
					);
					
					this.addChild(annotationPen);
					annotations.push(annotationPen);
					
					// Listen for this annotation being mouse-overed
					annotationPen.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { trace("# mosue overed"); });
					annotationPen.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { trace("# mosue outted"); });
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
						media as PDF
					);
					//TODO make this work with scaling, it wont
					
					this.addChild(annotationHighlight);
					annotations.push(annotationHighlight);
					
					// Listen for this annotation being mouse-overed
					annotationHighlight.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { trace("# mosue overed"); });
					annotationHighlight.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { trace("# mosue outted"); });
					
				} else {
					trace("Unknown annotation");
				}
			}
			trace("*****************");
		}
		
		
		public function listenForAnnotating():void {
			trace("listening for annotations")
			trace("***********************");
			// Listen for users to start drawing
			this.addEventListener(MouseEvent.MOUSE_DOWN,  startDrawingNewAnnotation);
			// Listen for users to stop drawing
			this.addEventListener(MouseEvent.MOUSE_UP,  stopDrawingNewAnnotation);
		}	
		
		public function stopListeningForAnnotating():void {
			trace("stopping listening for annotations");
			trace("*****************************");
			// Listen for users to start drawing
			this.removeEventListener(MouseEvent.MOUSE_DOWN, null);
			// Listen for users to stop drawing
			this.removeEventListener(MouseEvent.MOUSE_UP,  null);
		}
		
		
		/**
		 * We are starting to drawn an annotation 
		 * @param e
		 * 
		 */		
		private function startDrawingNewAnnotation(e:MouseEvent):void {
			trace("started drawing", e.target.mouseX, e.target.mouseY);
			
			// Check what drawing mode we are in
			var drawingMode:String = AnnotationToolbar.BOX//annotationToolbar.getAnnotationDrawingMode();
			
			trace("Starting to draw in Mode", drawingMode);
			// Clear the annotations values from previous draw
			startAnnotationMouseX = e.target.mouseX;
			startAnnotationMouseY = e.target.mouseY;
			finishAnnotationMouseX = -1;
			finishAnnotationMouseY  = -1;
			
			// Make the editable text overlay box disappear
//			hideAnnotationTextOverlay();
			
			if(drawingMode == AnnotationToolbar.PEN) {
				// For the box, we want to make a new box, everytime 
				// you click (erases old boxes)
				// Clear any of the previous annotations
				this.removeAllNonSavedAnnotations();
				
//			} else if (drawingMode == AnnotationToolbar.PEN) {
////				if(!canvas || !newAnnotationsGroup.contains(canvas)) {
////					// If we havent already got a canvas
////					// Create one, and put it in the new annotations group
////					canvas = new Group();
////					canvas.percentWidth = 100;
////					canvas.percentHeight = 100;
////					newAnnotationsGroup.addElement(canvas);
////				}
//			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
//				// We are highlighting some text
//				trace("drawing a highlight");
//				trace("Starting to draw annotation at", startAnnotationMouseX, startAnnotationMouseY);
//				
//				pdf.highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, startAnnotationMouseX, startAnnotationMouseY);
//			} else if (drawingMode == AnnotationToolbar.NOTE) {
//				trace("Placing a note");
//				// For the box, we want to make a new note, everytime 
//				// you click (erases old boxes)
//				// Clear any of the previous annotations
//				newAnnotationsGroup.removeAllElements();
//				
//				startAnnotationMouseX = e.target.mouseX - 2;
//				startAnnotationMouseY = e.target.mouseY - 2;
//				canvas = new Group();
//				canvas.percentWidth = 100;
//				canvas.percentHeight = 100;
//				newAnnotationsGroup.addElement(canvas);
			}
			
			// Listen for the cursor being moved
			this.addEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
		}
		
		/**
		 * Called when a user moves their mouse after they have started drawing an annotation. 
		 * @param e
		 * 
		 */		
		private function drawingNewAnnotation(e:MouseEvent):void {
			// We are drawing
			// Check what drawing mode we are in
			var drawingMode:String = AnnotationToolbar.PEN;//annotationToolbar.getAnnotationDrawingMode();
			
			trace("drawing annotation", e.target.mouseX, e.target.mouseY);
			if(drawingMode == AnnotationToolbar.BOX) {
				// We are drawing a box
				
				var width:Number = e.target.mouseX - startAnnotationMouseX;
				var height:Number = e.target.mouseY - startAnnotationMouseY;
				
				
				
				newAnnotationSpace.graphics.clear();
				//this.graphics.lineStyle(1, annotationToolbar.getSelectedColor(), 1);
				newAnnotationSpace.graphics.lineStyle(1, 0xFFFF00, 1);
				//this.graphics.beginFill(annotationToolbar.getSelectedColor(), 0.5);
				newAnnotationSpace.graphics.beginFill(0xFFFF00, 0.5);
				
				newAnnotationSpace.graphics.drawRect(startAnnotationMouseX, startAnnotationMouseY, width, height);
				trace("Drawing", startAnnotationMouseX, startAnnotationMouseY, width, height);
				
			} else if (drawingMode == AnnotationToolbar.PEN) {
				// We are using the PEN TOOL
				// The Straight line tool in flash, draws a line from the current pos
				// to a finish pos
				
				// Only save the values if it has been a significant change
				// Otherwise it becomes too intensive to draw all the points
				// Push values into array here
				var distanceThreshold:Number = 10;
				if(Math.abs(startAnnotationMouseX - e.target.mouseX) > distanceThreshold ||
					Math.abs(startAnnotationMouseY - e.target.mouseY) > distanceThreshold) {
					
					// We have moved enough distance, lets draw a line
					newAnnotationSpace.graphics.lineStyle(3, 0xFFFF00, 1);
					newAnnotationSpace.graphics.beginFill(0xFFFF00, 0.5);
					
					newAnnotationSpace.graphics.moveTo(startAnnotationMouseX, startAnnotationMouseY); 
					newAnnotationSpace.graphics.lineTo(e.target.mouseX, e.target.mouseY);
					
					trace("drawing", startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
					
					trace("saving point");
					annotationCoordinates.addCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
					
					startAnnotationMouseX = e.target.mouseX;
					startAnnotationMouseY = e.target.mouseY;
					
				} else {
					trace("not saving point");
				}
//			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
//				trace("Adding an text highlight stuff");
//				pdf.clearHighlight();
//				pdf.highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
			} 
			
		}
		
		private function stopDrawingNewAnnotation(e:MouseEvent):void {
			trace("stop drawing new annotation", e.target.mouseX, e.target.mouseY);
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
			
			// Check what drawing mode we are in
			var drawingMode:String = AnnotationToolbar.PEN;//annotationToolbar.getAnnotationDrawingMode();
			
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
				newAnnotationSpace.graphics.clear();
				newAnnotationSpace.graphics.lineStyle(1, 0x00FF00, 1);//annotationToolbar.getSelectedColor(), 1);
				newAnnotationSpace.graphics.beginFill(0x00FF00, 0.5);
				newAnnotationSpace.graphics.drawRect(startAnnotationMouseX, startAnnotationMouseY, width, height);
				
				// Show the annotation text overlay in text entry mode
//				showAnnotationTextOverlayTextEntryMode();
//				
			} else if (drawingMode == AnnotationToolbar.PEN) {
				// We are using the PEN TOOL
				// The Straight line tool in flash, draws a line from the current pos
				// to a finish pos
				newAnnotationSpace.graphics.lineStyle(3, 0x00FF00, 1);
				newAnnotationSpace.graphics.beginFill(0x00FF00, 0.5);
				
				newAnnotationSpace.graphics.moveTo(startAnnotationMouseX, startAnnotationMouseY); 
				newAnnotationSpace.graphics.lineTo(e.target.mouseX, e.target.mouseY);
				
				// Push values into array here
				annotationCoordinates.addCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
				
				startAnnotationMouseX = e.target.mouseX;
				startAnnotationMouseY = e.target.mouseY;
//			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
//				trace("highlighting some text");
//				pdf.highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, e.target.mouseX, e.target.mouseY);
//				
//				// Show the annotation text overlay in text entry mode
//				showAnnotationTextOverlayTextEntryMode();
//				
//			} else if (drawingMode == AnnotationToolbar.NOTE) {
//				
//				// Save the stopping coordinates
//				finishAnnotationMouseX = startAnnotationMouseX + 5;
//				finishAnnotationMouseY = startAnnotationMouseY + 5;
//				
//				
//				// create a box for the drawing
//				canvas.graphics.clear();
//				canvas.graphics.lineStyle(1, annotationToolbar.getSelectedColor(), 1);
//				canvas.graphics.beginFill(annotationToolbar.getSelectedColor(), 0.5);
//				canvas.graphics.drawRect(startAnnotationMouseX, startAnnotationMouseY, 5, 5);
//				
//				// Show the annotation text overlay in text entry mode
//				showAnnotationTextOverlayTextEntryMode();
			}
		}
		
		public function saveNewAnnotation():void {
			trace("Save Button Clicked");
			
			// Check what drawing mode we are in
			var drawingMode:String = AnnotationToolbar.BOX;//annotationToolbar.getAnnotationDrawingMode();
			
			
			if(drawingMode == AnnotationToolbar.BOX || drawingMode == AnnotationToolbar.NOTE)  {
				// We are drawing a box (not using the pen tool)	
				// Check they have drawn a box and not just hxit save (its at least 2px x 2px)
				if(Math.abs(startAnnotationMouseX - finishAnnotationMouseX) < 2 &&
					Math.abs(startAnnotationMouseY -finishAnnotationMouseY) < 2) {
					Alert.show("No annotation drawn");
					this.removeAllNonSavedAnnotations();
					this.stopListeningForAnnotating();
					return;
				}
//				} else if (annotationTextOverlayBox.getText() == "") {
//					Alert.show("No text given");
//					this.stopListeningForAnnotating();
//					return;
//				}
				
				// Remove any of the temporary drawn annotations
				this.removeAllNonSavedAnnotations();
				
				// Add this as an annotation to the view
				// This is annotation object temporarily, and will be reloaded once the controller
				// has finished saving the annotation
				var annotation:AnnotationBox = new AnnotationBox(
					-1,
					Auth.getInstance().getUsername(), 
					"yipeee",
					Math.abs(finishAnnotationMouseY - startAnnotationMouseY),// / this.scaleY, 
					Math.abs(finishAnnotationMouseX - startAnnotationMouseX),// / this.scaleX, 
					Math.min(startAnnotationMouseX, finishAnnotationMouseX),// / this.scaleX,
					Math.min(startAnnotationMouseY, finishAnnotationMouseY),// / this.scaleY,
					this.scaleX,
					this.scaleY
				);
				
				this.addChild(annotation);
				annotations.push(annotation); // Keep it in our list of annotations on the page
				annotation.save();
				
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
//				//				var event:IDEvent = new IDEvent(IDEvent.ANNOTATION_SAVE_HIGHLIGHT, true);
//				//				this.dispatchEvent(event);
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
			}
		}
	}
}