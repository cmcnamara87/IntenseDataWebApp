package View.components.Annotation
{
	import Controller.RecensioEvent;
	
	import View.components.IDGUI;
	import View.components.MediaViewer.ImageViewer.ImageViewer;
	import View.components.MediaViewer.MediaViewerInterface;
	import View.components.SubToolbar;
	
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
		public static const BOX:String = "box"; // The annotation toolbar is set to box mode 
		public static const PEN:String = "pen"; // The annotation toolbar is set to PEN mode
		
		// Annotation colors
		public static const RED:uint = 0xFF0000;
		public static const GREEN:uint = 0x00FF00;
		public static const BLUE:uint = 0x0000FF;
		
		private var mode:String = BOX; // The Drawing mode we are in, box, pen etc (default is BOX) 
		private var color:uint = BLUE;
		
		// GUI elements
		private var freeDrawButton:ToggleButton;
		private var drawBoxButton:ToggleButton;
		// The elements for the free drawing tools
		private var clearButton:Button; // Clears any non-saved annotations from the screen (only for the free-draw tools)
		private var addTextButton:Button; // Makes the text overlay show, so the user can enter text for a free drawing
		
		private var imageViewer:ImageViewer;
		
		public function AnnotationToolbar(imageViewer:ImageViewer)
		{
			// Save the media viewer we are attached to (most likely the iamge for now)
			this.imageViewer = imageViewer;
			
			this.hide();
			
			// Create the Box Button
			drawBoxButton = IDGUI.makeToggleButton("Draw Box", true);
			this.addElement(drawBoxButton);
			
			// Create the Pen Button
			freeDrawButton = IDGUI.makeToggleButton("Free Draw");
			this.addElement(freeDrawButton);
			
			var optionsLine:Line = IDGUI.makeLine(0xBBBB00);
			this.addElement(optionsLine);
			
			// Create the clear non-saved annotations Button
			clearButton = IDGUI.makeButton("Clear Drawings");
			this.addElement(clearButton);
			
			addTextButton = IDGUI.makeButton("Add Text");
			this.addElement(addTextButton);
			
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
			
			// Listen for draw box button click
			drawBoxButton.addEventListener(MouseEvent.CLICK, drawBoxButtonClicked);
			// Listen for free draw (pen tool) button click
			freeDrawButton.addEventListener(MouseEvent.CLICK, freeDrawButtonClicked);
			
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
			var myEvent:RecensioEvent = new RecensioEvent(RecensioEvent.ANNOTATION_SAVE_CLICKED, true);
			this.dispatchEvent(myEvent);
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
		
		private function drawBoxButtonClicked(e:MouseEvent):void {
			trace("Draw button clicked");
			// Unclick the free draw button
			freeDrawButton.selected = false;
			// Hide the extra controls that come with the free draw button
			this.hideFreeDrawControls();
			mode = BOX;
			
			// Since this is a toggle button, we cant let them click and tunr it off
			if((e.target as ToggleButton).selected == false) {
				(e.target as ToggleButton).selected = true;
			}
			// Clear any non-saved annotations on the image viewer
			imageViewer.clearNonSavedAnnotations();
		}
		
		private function freeDrawButtonClicked(e:MouseEvent):void {
			// Unclick the draw box button
			drawBoxButton.selected = false;
			mode = PEN;
			
			// Show the special free draw buttons
			this.showFreeDrawControls();
			
			// Since this is a toggle button, we cant let them click and tunr it off
			if((e.target as ToggleButton).selected == false) {
				(e.target as ToggleButton).selected = true;
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
			//clearButton.visible = false;
			clearButton.includeInLayout = false;
			clearButton.visible = false;
			addTextButton.includeInLayout = false;
			addTextButton.visible = false;
		}
		
		private function showFreeDrawControls():void {
			//clearButton.visible = false;
			clearButton.includeInLayout = true;
			clearButton.visible = true;
			addTextButton.includeInLayout = true;
			addTextButton.visible = true;
		}
	}
}