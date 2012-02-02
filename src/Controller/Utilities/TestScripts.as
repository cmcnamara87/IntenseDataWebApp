package Controller.Utilities
{
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Model_ERACase;
	import Model.Model_ERAConversation;
	import Model.Model_ERAFile;
	import Model.Model_ERALogItem;
	import Model.Model_ERANotification;
	import Model.Model_ERARoom;
	import Model.Transactions.ERAProject.Transaction_CreateAllCases;
	import Model.Transactions.ERAProject.Transaction_CreateAllResearchers;
	import Model.Transactions.ERAProject.Transaction_RemoveAllFileApprovals;

	public class TestScripts
	{
		public function TestScripts()
		{
		}
		
		public static function sendAllNotifications() {
			
			var test:Model_ERANotification = new Model_ERANotification();
			test.eraCase = new Model_ERACase();
			test.eraCase.rmCode = "123456789";
			test.eraCase.title = "Test Case";
			test.fullName = "John Smith";
			test.file = new Model_ERAFile();
			test.file.title = "Test File";
			test.room = new Model_ERARoom();
			test.room.roomTitle = "Test Room";
			test.comment_room = new Model_ERAConversation();
			test.comment_room.text = "Test Comment";
			test.comment_file = new Model_Commentary();
			test.comment_file.annotation_text = "Test Comment";
			test.logItem = new Model_ERALogItem();
			test.logItem.title = "Test Log Item Title";
			
			for each(var notificationType:String in Model_ERANotification.NOTIFICATION_TYPE_ARRAY) {
			test.type = notificationType;
			var emailObjectStaff:Object = Model_ERANotification.getEmailMessage(test, true, false);
			AppModel.getInstance().sendEmail("mark@intensedata.com.au", emailObjectStaff.subject, emailObjectStaff.body);
			var emailObjectStaff:Object = Model_ERANotification.getEmailMessage(test, false, true);
			AppModel.getInstance().sendEmail("mark@intensedata.com.au", emailObjectStaff.subject, emailObjectStaff.body);
			}			
		}
		
		public static function addResearchersFromText() {
			
			var test:Transaction_CreateAllResearchers = new Transaction_CreateAllResearchers();
		}
		
		public static function addCasesFromText() {
			var test:Transaction_CreateAllCases = new Transaction_CreateAllCases();
		}
	}
}