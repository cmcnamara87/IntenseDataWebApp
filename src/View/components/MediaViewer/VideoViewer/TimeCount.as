package View.components.MediaViewer.VideoViewer
{
	import spark.components.Label;
	
	public class TimeCount extends Label
	{
		private var duration:Number; 
		
		public function TimeCount() {
			super();
			setDuration(0);
			setTime(0);
		}
		
		public function setDuration(seconds:Number):void {
			this.duration = seconds;
		}
		public function setTime(seconds:Number):void {
			this.text = secondsToTime(seconds) + "/" + secondsToTime(duration);  
		}
		
		public static function secondsToTime(seconds:Number):String {
			var minutesText:Number = Math.floor(seconds / 60);
			var secondsText:Number = Math.floor(seconds - (minutesText * 60));
			if(secondsText < 10) {
				return minutesText + ":0" + secondsText;
			} else {
				return minutesText + ":" + secondsText;
			}
		}
	}
}