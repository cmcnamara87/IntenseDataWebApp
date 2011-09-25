package View
{
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Text;
	
	import spark.components.BorderContainer;
	import spark.components.TextInput;
	import spark.components.VGroup;

	public class UserAdminView extends VGroup
	{
		public function UserAdminView()
		{
			super();
			
			var thingy:UserAdminViewMarkup = new UserAdminViewMarkup();
			this.addElement(thingy);
		}
	}
}