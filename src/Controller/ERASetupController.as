package Controller
{
	import Model.AppModel;
	
	import View.ERASetupView;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	import spark.components.Label;

	public class ERASetupController extends AppController
	{
		private var eraSetupView:ERASetupView = new ERASetupView();
		public function ERASetupController()
		{
			view = eraSetupView;
			super();
		}
		
		override public function init():void {
			eraSetupView.createButton.addEventListener(MouseEvent.CLICK, createButtonClicked);
		}
		
		private function createButtonClicked(e:MouseEvent):void {
			Alert.show("Making ERA something");
			//DD-MMM-YYYY
			
			// Lets make the due date
			var date:String = eraSetupView.day.selectedItem + "/" + eraSetupView.month.selectedItem + "/" + eraSetupView.year.selectedItem;
			var packageSize:String = eraSetupView.packageSize.text;
			AppModel.getInstance().makeERAProject(	eraSetupView.day.selectedItem,
													eraSetupView.month.selectedItem,
													eraSetupView.year.selectedItem,
													packageSize);
		}
	}
}