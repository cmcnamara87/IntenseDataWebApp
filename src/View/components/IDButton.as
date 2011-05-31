package View.components
{
	import spark.components.Button;
	
	/**
	 * A Spark button with the added benefit of being able to hide/show the button, which
	 * updates its includeInLayout and Visible variables 
	 * @author cmcnamara87
	 * 
	 */	
	public class IDButton extends Button
	{
		/**
		 * Creates an IDButton 
		 * @param label				The text shown on the button
		 * @param visible			If the button is shown by default (defaults to true)
		 * @param includeInLayout	If the button is included in the layout (defaults to true)
		 * 
		 */		
		public function IDButton(label:String, visible:Boolean = true, includeInLayout:Boolean = true)
		{
			super();
			this.label = label;
			this.percentHeight = 100;
			this.visible = visible;
			this.includeInLayout = includeInLayout;
		}
		
		/**
		 * Hide the button in the layout 
		 * 
		 */		
		public function hide():void {
			this.visible = false;
			this.includeInLayout = false;
		}
		
		/**
		 * Show the button in the layout 
		 * 
		 */		
		public function show():void {
			this.visible = true;
			this.includeInLayout = true;
		}
	}
}