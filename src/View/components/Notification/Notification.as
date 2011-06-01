package View.components.Notification
{
	import Controller.Dispatcher;
	
	import View.components.IDGUI;
	
	import flash.events.MouseEvent;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.primitives.Line;
	
	public class Notification extends VGroup
	{
		private var notificationOn:Number;
		public function Notification(username:String, message:String, notificationOn:Number, notificationOnTitle:String, 
									 notificationOf:Number, notificationOfTitle:String) {
			super();
			this.notificationOn = notificationOn;
			
			var details:HGroup = new HGroup();
			this.addElement(details);
			
			var usernameLabel:Label = new Label();
			//usernameLabel.setStyle('color', 0x336699);
			usernameLabel.setStyle('fontWeight', 'bold');
			usernameLabel.setStyle('color', 0x555555);
			usernameLabel.text = username;
			details.addElement(usernameLabel);
			
			var messageLabel:Label = new Label();
			messageLabel.setStyle('color', 0x555555);
			messageLabel.text = message + " on ";
			details.addElement(messageLabel);
			
			var notificationOnTitleLabel:Label = new Label();
			notificationOnTitleLabel.setStyle('color', 0x336699);
			notificationOnTitleLabel.setStyle('fontWeight', 'bold');
			notificationOnTitleLabel.text = notificationOnTitle;
			details.addElement(notificationOnTitleLabel);
			
			notificationOnTitleLabel.useHandCursor = true;
			notificationOnTitleLabel.buttonMode = true;
			
			
			notificationOnTitleLabel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				Dispatcher.call('view/' + notificationOn);
			});
			
			if(notificationOfTitle != "") {
				var notificationOfTitleLabel:Label = new Label();
				notificationOfTitleLabel.text = "\"" + notificationOfTitle + "\"";
				notificationOfTitleLabel.setStyle('fontStyle', 'italic');
				notificationOfTitleLabel.setStyle('color', 0x555555);
				this.addElement(notificationOfTitleLabel);
			}
		}
	}
}