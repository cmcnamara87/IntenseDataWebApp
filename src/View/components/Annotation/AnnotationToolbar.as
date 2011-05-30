package View.components.Annotation
{
	import Controller.IDEvent;
	
	import View.components.IDGUI;
	import View.components.MediaViewer.ImageViewer.ImageViewerOLD;
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.MediaViewerInterface;
	import View.components.SubToolbar;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.effects.Resize;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.ToggleButton;
	import spark.layouts.HorizontalLayout;
	import spark.primitives.Line;

	public class AnnotationToolbar extends SubToolbar
	{
		// Annotation Drawing Modes
		public static const NOTE:String = "note"; // The annotation toolbar is set to note placing mode
												// A note is identical to a box, but with a fixed width/height
		public static const BOX:String = "box"; // The annotation toolbar is set to box mode 
		public static const PEN:String = "pen"; // The annotation toolbar is set to PEN mode
		public static const HIGHLIGHT:String = "highlight"; // The annotation toolbar is set to highlight text mode
		
		// Annotation colors
		public static const RED:uint = 0xFF0000;
		public static const GREEN:uint = 0x00FF00;
		public static const BLUE:uint = 0x0000FF;
		
		public static var mode:String = BOX; // The Drawing mode we are in, box, pen etc (default is BOX) 
		private var color:uint = BLUE;
		
		// GUI elements
		private var freeDrawButton:ToggleButton;
		private var drawBoxButton:ToggleButton;
		private var textHighlightButton:ToggleButton;
		private var noteButton:ToggleButton;
		private var annotationTypeButtons:Array;
		
		// The elements for the free drawing tools
		private var clearButton:Button; // Clears any non-saved annotations from the screen (only for the free-draw tools)
		private var addTextButton:Button; // Makes the text overlay show, so the user can enter text for a free drawing
		private var freeDrawToolsEndLine:Line;
		// Add all the elements of the free draw tools to an array, so we can show/hide them easily
		private var freeDrawTools:Array = [clearButton, addTextButton, freeDrawToolsEndLine];
		
		private var imageViewer:MediaViewer;
		
		public function AnnotationToolbar(imageViewer:MediaViewer, mediaType:String)
		{
			// Save the media viewer we are attached to (most likely the iamge for now)
			this.imageViewer = imageViewer;
			
			this.hide();
			
			mode = BOX;
//			
			this.setStyle("borderVisible", false);
//			noteButton = IDGUI.makeToggleButton("Add Note");
//			this.addElement(noteButton);
			
			// Create the Box Button
			drawBoxButton = IDGUI.makeToggleButton("Draw Box", true);
			this.addElement(drawBoxButton);
			
			// Create the Pen Button
			freeDrawButton = IDGUI.makeToggleButton("Free Draw");
			this.addElement(freeDrawButton);
			
			textHighlightButton = IDGUI.makeToggleButton("Highlight Text");
			this.addElement(textHighlightButton);
			if(mediaType != MediaAndAnnotationHolder.MEDIA_PDF) {
				textHighlightButton.visible = false;
				textHighlightButton.includeInLayout = false;
			}
			
			annotationTypeButtons = [drawBoxButton, freeDrawButton, textHighlightButton];
			
			// Create the veritcal line, that sits after the 'free draw button'
			var optionsLine:Line = IDGUI.makeLine(0x000000)
			this.addElement(optionsLine);
			
			// Create the clear non-saved annotations Button
			this.addElement(clearButton = IDGUI.makeButton("Clear Drawings"));
			// Create the add text button for pen annotations
			this.addElement(addTextButton = IDGUI.makeButton("Add Text"));

			// Add a new Free draw end line
			this.addElement(freeDrawToolsEndLine = IDGUI.makeLine(0x000000));
			
			// Since we are in Box mode by default, hide the extra tools
			// That only come with free draw mode
			this.hideFreeDrawControls();
			
			
			// Create Instruction label
			var instructionLabel:Label = new Label();
			instructionLabel.percentHeight = 100;
			instructionLabel.percentWidth = 100;
			instructionLabel.text = '';
			this.addElement(instructionLabel);
			
			// Create Save Button
			var saveButton:Button = IDGUI.makeButton("Save Annotation");
			this.addElement(saveButton);
			
			// Create Cancel Button
			var cancelButton:Button = IDGUI.makeButton("Cancel Annotation");
			this.addElement(cancelButton);
			
			/* EVENT LISTENERS */
			cancelButton.addEventListener(MouseEvent.CLICK, cancelButtonClicked);
			saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			
			// Listen for button clicks for anntotating mode
			for(var i:Number = 0; i < annotationTypeButtons.length; i++) {
				(annotationTypeButtons[i] as ToggleButton).addEventListener(MouseEvent.CLICK, annotationTypeButtonClicked);
			}
			
			// THE FREE DRAW TOOLS
			// Listen for clear button clicked
			clearButton.addEventListener(MouseEvent.CLICK, clearButtonClicked);
			// Listne for Add text button click
			addTextButton.addEventListener(MouseEvent.CLICK, addTextButtonClicked);
		}
		
		/* =================== EVENT LISTENER FUNCTIONS ====================== */
		/**
		 * The cancel button was clicked, hide this toolbar. 
		 * @param e
		 * 
		 */		
		private function cancelButtonClicked(e:MouseEvent):void  {
			this.hide();
			var myEvent:Event = new Event(Event.CANCEL, true);
			this.dispatchEvent(myEvent);
		}
		
		/**
		 * The save button was clicked. Hide this toolbar
		 * and pass the save event up to @see ImageViewer to 
		 * take care of the actual saving. 
		 * @param e
		 * 
		 */		
		private function saveButtonClicked(e:MouseEvent):void {
			trace("Annotation Toolbar: Save Annotation Clicked");
			this.hide();
			imageViewer.saveNewAnnotation();
		}
		
		/**
		 * Clears any non-saved annotations off the screen 
		 * @param e	The mouse click event
		 * 
		 */		
		private function clearButtonClicked(e:MouseEvent):void {
			trace("Annotation Toolbar: Clear Annotations Clicked");
			imageViewer.clearNonSavedAnnotations();
		}
		
		/**
		 * A button to change the annotation type was clicked. 
		 * @param e
		 * 
		 */		
		private function annotationTypeButtonClicked(e:MouseEvent):void {
			trace("Annotation button clicked");
			
			for(var i:Number = 0; i < annotationTypeButtons.length; i++) {
				var button:ToggleButton = annotationTypeButtons[i] as ToggleButton;
				// Unselect all buttons except the current button
				if(button != e.target) {
					button.selected = false;
				}
			}
			
			// Since this is a toggle button, we cant let them click and tunr it off
			if((e.target as ToggleButton).selected == false) {
				(e.target as ToggleButton).selected = true;
			}
			
			// If the current button isnt the free draw button, hide the free draw tools
			if(e.target != freeDrawButton) {
				this.hideFreeDrawControls();
			} else {
				// Its the free draw button, show the extra free draw tools
				this.showFreeDrawControls();
			}
			
			if(e.target == drawBoxButton) {
				trace("Box draw mode");
				mode = BOX;
			} else if (e.target == freeDrawButton) {
				trace("pen draw mode");
				mode = PEN;
			} else if (e.target == textHighlightButton) {
				trace("text highlight mode");
				mode = HIGHLIGHT;
			} else if (e.target == noteButton) {
				trace("note button mode");
				mode = NOTE;
			}

			// Clear any non-saved annotations on the image viewer
			imageViewer.clearNonSavedAnnotations();
		}
		
		/**
		 * The Add text button was clicked. Make the Image Viewer show the text entry box. 
		 * @param e
		 * 
		 */		
		private function addTextButtonClicked(e:MouseEvent):void {
			imageViewer.showAnnotationTextOverlayTextEntryMode();
		}
		/* =================== PUBLIC FUNCTIONS ============================== */
		public function show():void {
			this.visible = true;
			this.height = SubToolbar.SUB_TOOLBAR_HEIGHT;
		}
		
		public function hide():void {
			this.visible = false;
			this.height = 0;
		}
		
		public function getAnnotationDrawingMode():String {
			return mode;
		}
		
		public function getSelectedColor():uint {
			return color;
		}
		
		/* =================== HELPER FUNCTIONS ============================= */
		private function hideFreeDrawControls():void {

			clearButton.includeInLayout = false;
			clearButton.visible = false;
			addTextButton.includeInLayout = false;
			addTextButton.visible = false;
			freeDrawToolsEndLine.includeInLayout = false;
			freeDrawToolsEndLine.visible = false;
			
		}
		
		private function showFreeDrawControls():void {
			//clearButton.visible = false;
			clearButton.includeInLayout = true;
			clearButton.visible = true;
			addTextButton.includeInLayout = true;
			addTextButton.visible = true;
			freeDrawToolsEndLine.includeInLayout = true;
			freeDrawToolsEndLine.visible = true;
		}
	}
}