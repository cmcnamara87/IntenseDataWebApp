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
		//public static const ANNOTATION_TOOLBAR_HEIGHT:Number = 40; // The hiehgt of the Annotation Toolbar
		
		public function AnnotationToolbar()
		{
			this.hide();
			
			// Create the Box Button
			var drawBoxButton:ToggleButton = new ToggleButton();
			drawBoxButton.label = "Draw Box";
			drawBoxButton.percentHeight = 100;
			// Select this button
			drawBoxButton.selected = true;
			this.addElement(drawBoxButton);
			
			// Create the Pen Button
			var freeDrawButton:ToggleButton = new ToggleButton();
			freeDrawButton.label = "Free Draw";
			freeDrawButton.enabled = false;
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
		
		
		/* =================== PUBLIC FUNCTIONS ============================== */
		public function show():void {
			this.visible = true;
			this.height = SubToolbar.SUB_TOOLBAR_HEIGHT;
		}
		
		public function hide():void {
			this.visible = false;
			this.height = 0;
		}
	}
}