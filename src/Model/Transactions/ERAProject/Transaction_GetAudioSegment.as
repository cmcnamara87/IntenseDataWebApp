package Model.Transactions.ERAProject
{
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import flash.events.Event;
	
	public class Transaction_GetAudioSegment
	{
		private var audioID:Number;
		private var startTime:Number;
		private var length:Number;
		private var connection:Connection;
		private var callback:Function;
		
		/**
		 * Instructs mediaflux to use ffmpeg to extract out a given video segment and place it in the extract folder and return its location
		 * @param audioID			The ID of the audio asset
		 * @param startTime			The time to start the extraction at (in seconds)
		 * @param length			The length of the segment to extract (in seconds)
		 * @param connection		The connection to mediaflux
		 * @param callback			The callback when complete
		 * 
		 */
		public function Transaction_GetAudioSegment(audioID:Number, startTime:Number, length:Number, connection:Connection, callback:Function)
		{
			this.audioID = audioID;
			this.startTime = Math.floor(startTime);
			this.length = Math.ceil(length);
			this.connection = connection;
			this.callback = callback;
			
			trace("get video segments!!!!!!");
			
			extractAudioSegment();
		}
		
		private function extractAudioSegment():void {
			var baseXML:XML = connection.packageRequest("id.asset.audio.extract", new Object(), true);
			var argsXML:XMLList = baseXML.service.args;
			
			argsXML.id = this.audioID;
			argsXML.start = this.startTime;
			argsXML.length = this.length;
			
			trace("audio extraction request", baseXML);
			connection.sendRequest(baseXML, videoExtracted);
		}
		
		private function videoExtracted(e:Event):void {
			var data:XML;
			if((data = AppModel.getInstance().getData("audio segment extract", e)) == null) {
				callback(false);
				return;
			}
			trace("video extracted!!!!!", data);
			
			var videoLocation:String = data.reply.result.video;
			
			callback(true, videoLocation);
			
			
		}
	}
}