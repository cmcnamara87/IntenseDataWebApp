package View.components.MediaViewer
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
	import View.components.MediaViewer.ImageViewer.ImageMedia;
	import View.components.MediaViewer.PDFViewer.PDF;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class MediaAndAnnotationHolder extends UIComponent
	{
		public static const MEDIA_PDF:String = "pdf";
		public static const MEDIA_IMAGE:String = "image";
		
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
		
		
		public function MediaAndAnnotationHolder(mediaType:String)
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
			} else if (mediaType == MEDIA_IMAGE) {
				media = new ImageMedia(sourceURL);
			}
			media.visible = false;
			this.addChild(media);
			
			trace("media issss", media);
			// Listen for the media to have finished loaded, and then to have added to the display
			media.addEventListener(IDEvent.MEDIA_LOADED, sourceLoaded);
			
			
			media.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				var percentLoaded:Number = Math.round(e.bytesLoaded / e.bytesTotal * 100);
				dispatchEvent(e);
				trace("Loaded", percentLoaded);
			});
		}
		
		private function sourceLoaded(e:IDEvent=null):void {
			trace("Finished loading media");
			// We have finished loading hte media
			// Now show it
			media.visible = true;
			this.addChild(newAnnotationSpace);
			// Set this width, to match the media (so the viewer can center this media)
			this.width = media.width;
			this.height = media.height;
			
			mediaLoaded = true;
			if(annotationsLoaded) {
				this.addAnnotationsToDisplay();
			}
		}
		
		/**
		 * Searches for text in the media. Should only be used ofr PDFs 
		 * @param text	The string to search for.
		 * @return The y-pos of the first match
		 * 
		 */		
		public function searchForText(text:String):Number {
			// This should only be used for the pdfs whatever!!!!
			// this should alll be extended into another class, ill do it later, on a deadline atm TODO!!!
			if(mediaType == MEDIA_PDF) {
				return (media as PDF).searchForText(text);
			} else {
				throw new Error("Only to be run on PDFs");
			}
		}
		
		public function getFitHeightSize():Number {
			if(mediaType == MEDIA_PDF) {
				return (media as PDF).getPageHeight();
			} else if (mediaType == MEDIA_IMAGE) {
				return media.height;
			} else {
				return -1;
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
			
			if(mediaType == MEDIA_PDF) {
				(media as PDF).clearHighlight();
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
			try{
				(media as PDF).clearHighlight();
			} catch(error:Error) {}
			annotationCoordinates = new AnnotationCoordinateCollection();
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
					
					// tell the viewer to display the overlay to go with this
					var myEvent:IDEvent = new IDEvent(IDEvent.ANNOTATION_MOUSE_OVER, true);
					myEvent.data.text = annotation.getText();
					myEvent.data.author = annotation.getAuthor();
					dispatchEvent(myEvent);
					
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
			
			trace("media dimensions:", media.width, media.height);
			
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
						annotationData.annotation_y
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
						annotationData.annotation_text
					);
					
					this.addChild(annotationPen);
					annotations.push(annotationPen);
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
			this.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawingNewAnnotation);
			// Listen for users to stop drawing
			this.removeEventListener(MouseEvent.MOUSE_UP,  stopDrawingNewAnnotation);
			
			if(this.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				this.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
			}
		}
		
		
		/**
		 * We are starting to drawn an annotation 
		 * @param e
		 * 
		 */		
		private function startDrawingNewAnnotation(e:MouseEvent):void {
			trace("******************************");
			trace("started drawing", e.target.mouseX, e.target.mouseY);

			// Clear the annotations values from previous draw
			startAnnotationMouseX = e.target.mouseX;
			startAnnotationMouseY = e.target.mouseY;
			finishAnnotationMouseX = -1;
			finishAnnotationMouseY  = -1;
			
			// Make the editable text overlay box disappear
//			hideAnnotationTextOverlay();
			
			if(AnnotationToolbar.mode == AnnotationToolbar.BOX) {
				// For the box, we want to make a new box, everytime 
				// you click (erases old boxes)
				// Clear any of the previous annotations
				this.removeAllNonSavedAnnotations();
				
			} else if (AnnotationToolbar.mode == AnnotationToolbar.PEN) {
				
			} else if (AnnotationToolbar.mode == AnnotationToolbar.HIGHLIGHT) {
				this.removeAllNonSavedAnnotations();
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
			trace("drawing annotation", e.target.mouseX, e.target.mouseY);
			
			try {
				(media as PDF).clearHighlight();
			} catch (error:Error) {
				trace("couldnt claer the annotation cause its not a pdf");
			}
			
			if(AnnotationToolbar.mode == AnnotationToolbar.BOX) {
				// We are drawing a box
				// Get out the width and height of the box				
				var width:Number = e.target.mouseX - startAnnotationMouseX;
				var height:Number = e.target.mouseY - startAnnotationMouseY;

				newAnnotationSpace.graphics.clear();
				newAnnotationSpace.graphics.lineStyle(1, 0xFFFF00, 1);
				newAnnotationSpace.graphics.beginFill(0xFFFF00, 0.5);
				
				newAnnotationSpace.graphics.drawRect(startAnnotationMouseX, startAnnotationMouseY, width, height);
				trace("Drawing", startAnnotationMouseX, startAnnotationMouseY, width, height);
				
			} else if (AnnotationToolbar.mode == AnnotationToolbar.PEN) {
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
					
					
					annotationCoordinates.addCoordinates(startAnnotationMouseX, startAnnotationMouseY,
															e.target.mouseX, e.target.mouseY);
					
					trace("Point count", annotationCoordinates.getCount());
					startAnnotationMouseX = e.target.mouseX;
					startAnnotationMouseY = e.target.mouseY;
					
				} else {
					//trace("not saving point");
				}
			} else if (AnnotationToolbar.mode == AnnotationToolbar.HIGHLIGHT) {
				trace("Adding an text highlight stuff");
				(media as PDF).clearHighlight();
				(media as PDF).highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, 
														e.target.mouseX, e.target.mouseY);
			} 
			
		}
		
		private function stopDrawingNewAnnotation(e:MouseEvent):void {
			trace("stop drawing new annotation", e.target.mouseX, e.target.mouseY);
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE, drawingNewAnnotation);
			
			// Check what drawing mode we are in
			var drawingMode:String = AnnotationToolbar.mode;//annotationToolbar.getAnnotationDrawingMode();
			
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
				
				// tell the viewer to show the text input box
				trace("Throwing Show Annotation Text Entry Event");
				this.dispatchEvent(new IDEvent(IDEvent.SHOW_ANNOTATION_TEXT_ENTRY, true));

			} else if (drawingMode == AnnotationToolbar.PEN) {
				// We are using the PEN TOOL
				// The Straight line tool in flash, draws a line from the current pos
				// to a finish pos
				newAnnotationSpace.graphics.lineStyle(3, 0xFFFF00, 1);
				newAnnotationSpace.graphics.beginFill(0xFFFF00, 0.5);
				
				newAnnotationSpace.graphics.moveTo(startAnnotationMouseX, startAnnotationMouseY); 
				newAnnotationSpace.graphics.lineTo(e.target.mouseX, e.target.mouseY);
				
				// Push values into array here
				annotationCoordinates.addCoordinates(startAnnotationMouseX, startAnnotationMouseY, 
													e.target.mouseX, e.target.mouseY);
				
				startAnnotationMouseX = e.target.mouseX;
				startAnnotationMouseY = e.target.mouseY;
				
				trace("Point count", annotationCoordinates.getCount());
				
			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
				trace("highlighting some text");
				if(startAnnotationMouseX == finishAnnotationMouseX && startAnnotationMouseY == finishAnnotationMouseY) {
					// Clear the annotations values
					startAnnotationMouseX = -1;
					startAnnotationMouseY = -1;
					finishAnnotationMouseX = -1;
					finishAnnotationMouseY  = -1;
					(media as PDF).clearHighlight();	
					
					return;
				}	
				
				(media as PDF).highlightFromCoordinates(startAnnotationMouseX, startAnnotationMouseY, 
														e.target.mouseX, e.target.mouseY);
				
				// tell the viewer to show the text input box
				trace("Throwing Show Annotation Text Entry Event");
				this.dispatchEvent(new IDEvent(IDEvent.SHOW_ANNOTATION_TEXT_ENTRY, true));
			}
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
//			}
			trace("***************************");
		}

		
		public function saveNewAnnotation(annotationText:String):void {
			trace("Save Button Clicked");
			
			trace("Point count", annotationCoordinates.getCount());
			
			// Check what drawing mode we are in
			var drawingMode:String = AnnotationToolbar.mode;//annotationToolbar.getAnnotationDrawingMode();
			
			
			if(drawingMode == AnnotationToolbar.BOX || drawingMode == AnnotationToolbar.NOTE)  {
				this.saveBoxAnnotation(annotationText);
			} else if (drawingMode == AnnotationToolbar.PEN) {
				this.savePenAnnotation(annotationText);
			} else if (drawingMode == AnnotationToolbar.HIGHLIGHT) {
				this.saveHighlightAnnotation(annotationText);
			}
			
			// Remove any of the temporary drawn annotations
			this.removeAllNonSavedAnnotations();
			
			
			trace("*************************");
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
//			}
		}
		
		/**
		 * Saves a new box annotation 
		 * @param annotationText	The text for the box annotation. Not allowed to be ""
		 * 
		 */		
		private function saveBoxAnnotation(annotationText:String):void {
			trace("Saving box annotation");
			// We are drawing a box (not using the pen tool)	
			// Check they have drawn a box and not just hxit save (its at least 2px x 2px)
			if(Math.abs(startAnnotationMouseX - finishAnnotationMouseX) < 2 &&
				Math.abs(startAnnotationMouseY -finishAnnotationMouseY) < 2) {
				Alert.show("No annotation drawn");
				this.removeAllNonSavedAnnotations();
				this.stopListeningForAnnotating();
				return;
			} else if (annotationText == "") {
				Alert.show("No text given");
				this.removeAllNonSavedAnnotations();
				this.stopListeningForAnnotating();
				return;
			}
			
			// Add this as an annotation to the view
			// This is annotation object temporarily, and will be reloaded once the controller
			// has finished saving the annotation
			var annotation:AnnotationBox = new AnnotationBox(
				-1, // we dont have an assetID# for hte annotation get
				Auth.getInstance().getUsername(), 
				annotationText,
				Math.abs(finishAnnotationMouseY - startAnnotationMouseY),// / this.scaleY, 
				Math.abs(finishAnnotationMouseX - startAnnotationMouseX),// / this.scaleX, 
				Math.min(startAnnotationMouseX, finishAnnotationMouseX),// / this.scaleX,
				Math.min(startAnnotationMouseY, finishAnnotationMouseY)// / this.scaleY,
			);
			
			this.addChild(annotation);
			annotations.push(annotation); // Save the annotation in an array
			// so we can keep track of it (i.e. remove it easily)
			annotation.save();			  // Save the annotation in the database
		}
		
		private function savePenAnnotation(annotationText:String):void {
			trace("Saving a pen annotation");
			trace("coordinate count is", annotationCoordinates.getCount());
			// Test the user has drawn a path
			if(annotationCoordinates.getCount() == 0) {
				
				Alert.show("No annotation drawn");
				this.removeAllNonSavedAnnotations();
				this.stopListeningForAnnotating();
				return;
			}
			
			// Create a new annotation
			var annotationPen:AnnotationPen = new AnnotationPen(
				-1,
				Auth.getInstance().getUsername(),
				annotationCoordinates.getString(),
				annotationText
			);
			this.addChild(annotationPen);
			annotations.push(annotationPen);
			annotationPen.save();
		}
		
		private function saveHighlightAnnotation(annotationText:String):void {
			if((media as PDF).getStartTextIndex() == (media as PDF).getEndTextIndex()) {
				Alert.show("No text highlighted");
				this.removeAllNonSavedAnnotations();
				this.stopListeningForAnnotating();
				return;
			} else if (annotationText == "") {
				Alert.show("No text given");
				this.removeAllNonSavedAnnotations();
				this.stopListeningForAnnotating();
				return;
			}

			// Just a reminder, percentX is < 0, e.g. like 0.5 is 50%
			if(startAnnotationMouseY < finishAnnotationMouseY) {
				var xCoor:Number = startAnnotationMouseX;
				var yCoor:Number = startAnnotationMouseY;
			} else if (startAnnotationMouseY > finishAnnotationMouseY) {
				xCoor = finishAnnotationMouseX;
				yCoor = finishAnnotationMouseY;
			} else {
				// They must be equal
				if(startAnnotationMouseX < finishAnnotationMouseX) {
					xCoor = startAnnotationMouseX;
					yCoor = startAnnotationMouseY;
				} else {
					xCoor = finishAnnotationMouseX;
					yCoor = finishAnnotationMouseY;
				}					
			}
			
			
			var annotationHighlight:AnnotationHighlight = new AnnotationHighlight(
				-1,
				Auth.getInstance().getUsername(),
				annotationText,
				xCoor,
				yCoor,
				(media as PDF).getSelectionPage(),
				(media as PDF).getStartTextIndex(),
				(media as PDF).getEndTextIndex(),
				(media as PDF)
			);
			this.addChild(annotationHighlight);
			annotations.push(annotationHighlight);
			annotationHighlight.save();
			
			(media as PDF).clearHighlight();
		}
		
	}
}