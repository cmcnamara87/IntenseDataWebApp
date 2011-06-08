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
		private var _netStream:NetStream;
		
		private var _metaData:Object = { duration:0, width: 0, height: 0 ,videoKeyFrameFrequence:.5};
		
		private var videoPlayer:VideoDisplay;
		
		public function VideoMedia(sourceURL:String) {
			super();
			trace("Video URL", sourceURL);
			this.sourceURL = sourceURL.substring(sourceURL.lastIndexOf("\\")+1, sourceURL.length);
			
			// Setup the net connection
			_netConnection = new NetConnection();
			_netConnection.call("checkBandwidth", null);
			// Listen for the net connection status to change (e.g. when its ready, or when its playing, its a lot of stuff)
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			
			// A whole bunch of crap associated with the netconnection
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
			_netConnection.objectEncoding = ObjectEncoding.AMF3;
			_netConnection.client = this;
			
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
			trace("NETCONNECTION:"+code);
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
					_netStream.bufferTime = 5;
//					bufferEmpty = true;
					//this.pause();
					//_playing = false;
					break;
				case "NetStream.Buffer.Full":
					_netStream.bufferTime = 0.5;
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
					code = "Media is currently being encoded, please try again later";
//					delegate.playFailed(code);
					break;				
			}
		}
		
		/**
		 * Connects the netStream to the net connection that has been successfully made. 
		 * 
		 */		
		private function connectVideoStream():void {
			_netStream = new NetStream(_netConnection);
			// Listen for status events
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			
			// Set the default buffer time
			_netStream.bufferTime = 5;
			_netStream.inBufferSeek = true;
			_netStream.backBufferTime = 30;
			_netStream.client = this;

			this.addChild(video);
			
			if(this.contains(video)) {
				trace("the video has been added, why canti  see it!");
			} else {
				trace("video not added, wtf");
			}
			
			video.attachNetStream(_netStream);
			video.visible = true;
			
			_netStream.play(sourceURL,0);
		}
		
		public function onMetaData(info:Object):void {
			_metaData = info;
			video.width = info.width;
			video.height = info.height;
			
			
			this.height = video.height;
			this.width = video.width;
			
			var event:IDEvent = new IDEvent(IDEvent.MEDIA_LOADED, true);
			dispatchEvent(event);
			
//			delegate.setDuration(_metaData.duration);
//			resize();
		}
		
		
		private function onAsyncError(e:AsyncErrorEvent):void {
			trace("Async Error", e);
			Alert.show("Async error occured on this video");
			Dispatcher.call("browse");
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace("Security Error Received", e);
			Alert.show("A Security Error has occured with this video.");
			Dispatcher.call("browse");
		}
		
		
		/* ====================== NETSTREAM REQUIRED FUNCTIONS ============================ */
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


