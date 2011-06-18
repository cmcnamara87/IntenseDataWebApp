package View.components.MediaViewer.VideoViewer
{
	import Controller.Dispatcher;
	import Controller.IDEvent;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.VideoEvent;
	
	import org.osmf.events.LoadEvent;
	
	import spark.components.Label;
	import spark.components.VideoDisplay;
	import spark.components.VideoPlayer;

	public class VideoMedia extends UIComponent
	{
		private var video:Video = new Video();
		private var _rtmpUri:String = "rtmp://recensio.dyndns.org/vod/";
		private var sourceURL:String = "";
		
		private var _netConnection:NetConnection;
		private var videoStream:NetStream;
		
		private var _metaData:Object = {duration:0, width: 0, height: 0 , videoKeyFrameFrequence:.5};
		
		private var videoPlayer:VideoDisplay;
		
		private var buffer:Label;
		public function VideoMedia(sourceURL:String) {
			super();

			trace("Video URL", sourceURL);
			this.sourceURL = sourceURL.substring(sourceURL.lastIndexOf("\\")+1, sourceURL.length);
			
			setupConnection();
		}
		
		/* ================================== SETTING UP THE CONNECTION ====================================== */
		/**
		 * Create the initial connection to the media. 
		 * 
		 */		
		private function setupConnection():void {
			// Setup the net connection
			_netConnection = new NetConnection();
			_netConnection.call("checkBandwidth", null);
			
			// A whole bunch of crap associated with the netconnection
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
			_netConnection.objectEncoding = ObjectEncoding.AMF3;
			_netConnection.client = this;
			
			// Listen for the net connection status to change (e.g. when its ready, or when its playing, its a lot of stuff)
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			
			// Connect to the stream
			_netConnection.connect( _rtmpUri, "model.logedinUser.username");
		}
		
		/**
		 * The connections status has been updated. 
		 * @param e
		 * 
		 */		
		private function onNetConnectionStatus(e:NetStatusEvent):void {
			var code:String = e.info.code;
//			trace("NETCONNECTION:"+code);
			switch(code) {
				case "NetStream.Play.Start": 
//					_playing = true;
					//playing=true;
					//doCloseSeekPopup();
					break;
				case "NetStream.Seek.Notify":
//					_playing = false;
					//playing=false;
					//doCloseSeekPopup();
					break;
				case "NetStream.Play.Stop":
//					_playing = false;
					//playing	=	false;
					//isComplete	=	true;
					//doCloseSeekPopup();
					break;
				case "NetStream.Pause.Notify":
//					_playing = false;
					//playing	=	false;
					break;
				case "NetStream.Unpause.Notify":
//					_playing = true;
					//playing	=	true;
					//doCloseSeekPopup();
					break;
				case "NetStream.Buffer.Empty":
					videoStream.bufferTime = 5;
//					bufferEmpty = true;
					//this.pause();
					//_playing = false;
					break;
				case "NetStream.Buffer.Full":
					videoStream.bufferTime = 0.5;
//					if(bufferEmpty) {
//						bufferEmpty = false;
//						this.play();
//						_playing = true;
//					}
					break;
				case "NetStream.Play.InsufficientBW":
					break;
				case "NetConnection.Connect.Success":
					connectVideoStream();
					break;
				case "NetConnection.Connect.Closed":
//					_playing = false;
					//playing	=	false;
					break;
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.InvalidApp":
				case "NetConnection.Connect.AppShutdown":
				case "NetStream.Play.Failed":
				case "NetStream.Play.StreamNotFound":
					trace("Media is currently being encoded, please try again later");
					Alert.show("Media is currently being encoded for display. It will become available shortly.");
					Dispatcher.call("browse");
					code = "Media is currently being encoded, please try again later";
//					delegate.playFailed(code);
					break;				
			}
		}
		
		/**
		 * Connects the netStream to the net connection that has been successfully made. 
		 * 
		 * Called when a video stream is connected after using @see setupConnection
		 * 
		 */		
		private function connectVideoStream():void {
			videoStream = new NetStream(_netConnection);
			// Listen for status events
			videoStream.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			
			// Set the default buffer time
			videoStream.bufferTime = 0.5;
			videoStream.inBufferSeek = true;
			
			// how many seconds we save in the buffer for rewinding (id like this to be a lot, we will see)
			videoStream.backBufferTime = 30;
			videoStream.client = this;

			this.addChild(video);
			
			video.attachNetStream(videoStream);
			video.visible = true;
			
			videoStream.play(sourceURL,0);
			
			test();	
		}
		
		private function test():void {
			
			var event:IDEvent = new IDEvent(IDEvent.PLAYHEAD_POSITION, true);
			// Send the current playhead position for the netstream
			event.data.time = videoStream.time;
			
			// And where that buffering starts from
			event.data.bufferStartTime = 0; // TODO WORK OUT HOW TO DO THIS
			// Also want to send how many seconds we have buffered
			event.data.bufferLength = videoStream.bufferLength;

			this.dispatchEvent(event);
//			trace("Buffer length", _netStream.bufferLength, "Buffer time", _netStream.bufferTime);
			setTimeout(test, 100);
		}
		
		/**
		 * Alert when an aysnc error is caught 
		 * @param e
		 * 
		 */		
		private function onAsyncError(e:AsyncErrorEvent):void {
			trace("Async Error", e);
			Alert.show("Async error occured on this video");
			Dispatcher.call("browse");
		}
		
		/**
		 * Alert when a security error is caught 
		 * @param e
		 * 
		 */		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace("Security Error Received", e);
			Alert.show("A Security Error has occured with this video.");
			Dispatcher.call("browse");
		}
		
		
		/* ======================= VIDEO CONTROLLING FUNCTIONS ============================= */
		/**
		 * Pause the video 
		 * 
		 */		
		public function pause():void {
			videoStream.pause();
		}
		
		/**
		 * Play the video
		 * 
		 */		
		public function play():void {
			videoStream.resume();
		}
		
		/**
		 * Seeks to a time in the net stream 
		 * @param time	The time in seconds
		 * 
		 */		
		public function seekTo(time:Number):void {
			trace("Seeking to", time);
			var seekMin:Number = 1;
			if(time > videoStream.time + seekMin ||
				time < videoStream.time - seekMin) {
				videoStream.seek(time);
			}
		}
		
		public function getPlayheadTime():Number {
			return videoStream.time;
		}
		
		/* ====================== NETSTREAM REQUIRED FUNCTIONS ============================ */
		public function onMetaData(info:Object):void {
			_metaData = info;
			video.width = info.width;
			video.height = info.height;
			
			
			this.height = video.height;
			this.width = video.width;
			
			// Set it so we can buffer the entire video
			videoStream.backBufferTime = info.duration;
			videoStream.bufferTime = 10;
	
			var event:IDEvent = new IDEvent(IDEvent.MEDIA_LOADED, true);
			event.data.duration = info.duration;
			dispatchEvent(event);
			
			var progressLoadEvent:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			progressLoadEvent.bytesTotal = 1;
			progressLoadEvent.bytesLoaded = 1;
			dispatchEvent(progressLoadEvent);
			//			delegate.setDuration(_metaData.duration);
			//			resize();
		}
		
		public function onBWDone(a:*=null,b:*=null,c:*=null,d:*=null):void {
			trace("THIS IS SOMETHING");
		}
		
		public function onBWCheck(a:*=null):Number {
			return 0;
		} 
		
		public function onPlayStatus(e:Object):void {
			var code:String = e.code;
			trace("Play status", code);
			if(code == "NetStream.Play.Complete") {
				trace("Video Finished Playing");
				trace("**********************");
			}
		}
	}
}


