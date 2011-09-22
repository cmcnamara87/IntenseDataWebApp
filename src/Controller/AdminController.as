package Controller
{
	import mx.controls.Text;
	
	import spark.components.Label;

	public class AdminController extends AppController
	{
		public function AdminController()
		{
			var someText:Text = new Text();
			someText.text = "this is the admin panel";
			view = someText;
			
			super();
		}
	}
}