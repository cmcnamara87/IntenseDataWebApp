package View.components.Annotation
{
	import Controller.RecensioEvent;
	
	import View.components.SubToolbar;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.effects.Resize;
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.ToggleButton;
	import spark.layouts.HorizontalLayout;

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
		
		public function AnnotationToolbar()
		{
			this.hide();
			
			// Create the Box Button
			drawBoxButton = new ToggleButton();
			drawBoxButton.label = "Draw Box";
			drawBoxButton.percentHeight = 100;
			// Select this button
			drawBoxButton.selected = true;
			this.addElement(drawBoxButton);
			
			// Create the Pen Button
			freeDrawButton = new ToggleButton();
			freeDrawButton.label = "Free Draw";
			freeDrawButton.enabled = true;
			freeDrawButton.percentHeight = 100;
			this.addElement(freeDrawButton);
			
			// Create Instruction label
			var instructionLabel:Label = new Label();
			instructionLabel.percentHeight = 100;
			instructionLabel.percentWidth = 100;
			instructionLabel.text = '';
			this.addElement(instructionLabel);
			
			// Create Save Button
			var saveButton:Button = new Button();
			saveButton.label = "Save Annotation";
			saveButton.percentHeight = 100;
			this.addElement(saveButton);
			
			// Create Cancel Button
			var cancelButton:Button = new Button();
			cancelButton.label = "Cancel Annotation";
			cancelButton.percentHeight = 100;
			this.addElement(cancelButton);
			
			/* EVENT LISTENERS */
			cancelButton.addEventListener(MouseEvent.CLICK, cancelButtonClicked);
			saveButton.addEventListener(MouseEvent.CLICK, saveButtonClicked);
			
			// Listen for draw box button click
			drawBoxButton.addEventListener(MouseEvent.CLICK, drawBoxButtonClicked);
			// Listen for free draw (pen tool) button click
			freeDrawButton.addEventListener(MouseEvent.CLICK, freeDrawButtonClicked);
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
		
		private function drawBoxButtonClicked(e:MouseEvent):void {
			trace("Draw button clicked");
			// Unclick the free draw button
			freeDrawButton.selected = false;
			mode = BOX;
		}
		
		private function freeDrawButtonClicked(e:MouseEvent):void {
			// Unclick the draw box button
			drawBoxButton.selected = false;
			mode = PEN;
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
	}
}