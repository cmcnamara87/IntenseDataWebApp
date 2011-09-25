package View
{
	import mx.controls.Text;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VGroup;
	
	public class EraCreatorView extends VGroup
	{
		public function EraCreatorView()
		{
			var label:Label = new Label();
			label.text = "ERA CREATOR VIEW";
			view = label;
			super();
			
			
		}
	}
}