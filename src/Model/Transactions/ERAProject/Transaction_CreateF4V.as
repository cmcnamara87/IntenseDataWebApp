package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_CreateF4V
	{
		private var fileID:Number;
		private var connection:Connection;
		
		public function Transaction_CreateF4V(fileID:Number, connection:Connection)
		{
			this.fileID = fileID;
			this.connection = connection;
			
			createF4V();
		}
		
		private function createF4V():void {
			// now we will just run a transcation to convert the video to a playable MP4
			var baseXML:XML = connection.packageRequest("id.asset.video.transcode", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			argsXML.id = fileID;
			connection.sendRequest(baseXML, fileTranscoded);
		}
		
		private function fileTranscoded(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("video transcoding", e)) == null) {
				trace("FAILED TO TRANSCODE", data);
				return;
			} else {
				trace("TRANSCODED", data);
			}
		}
	}
}