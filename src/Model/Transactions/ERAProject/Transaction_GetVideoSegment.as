package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;

	public class Transaction_GetVideoSegment
	{
		private var videoID:Number;
		private var startTime:Number;
		private var length:Number;
		private var connection:Connection;
		private var callback:Function;
		
		/**
		 * Instructs mediaflux to use ffmpeg to extract out a given video segment and place it in the extract folder and return its location
		 * @param videoID			The ID of the video asset
		 * @param startTime			The time to start the extraction at (in seconds)
		 * @param length			The length of the segment to extract (in seconds)
		 * @param connection		The connection to mediaflux
		 * @param callback			The callback when complete
		 * 
		 */
		public function Transaction_GetVideoSegment(videoID:Number, startTime:Number, length:Number, connection:Connection, callback:Function)
		{
			this.videoID = videoID;
			this.startTime = Math.floor(startTime);
			this.length = Math.ceil(length);
			this.connection = connection;
			this.callback = callback;
			
			trace("get video segments!!!!!!");
			
			extractVideoSegment();
		}
		
		private function extractVideoSegment():void {
			var baseXML:XML = connection.packageRequest("id.asset.video.extract", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = this.videoID;
			argsXML.start = this.startTime;
			argsXML.length = this.length;

			connection.sendRequest(baseXML, videoExtracted);
		}
		
		private function videoExtracted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("video segment extract", e)) == null) {
				callback(false);
				return;
			}
			trace("video extracted!!!!!", data);
			
			var videoLocation:String = data.reply.result.video;
			
			callback(true, videoLocation);
			
			
		}
	}
}