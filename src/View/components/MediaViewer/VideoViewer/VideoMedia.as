package View.components.MediaViewer.VideoViewer
{
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
	
	import mx.core.UIComponent;
	import mx.events.VideoEvent;
	
	import org.osmf.events.LoadEvent;
	
	import spark.components.Label;
	import spark.components.VideoDisplay;
	import spark.components.VideoPlayer;

	public class VideoMedia extends UIComponent
	{
		private var video:Video = new Video();
		private var sourceURL:String;
		
		
		private var _rtmpUri:String = "rtmp://recensio.dyndns.org/vod/";
		private var _fileName:String = "";
		
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		
		private var _metaData:Object = { duration:0, width: 0, height: 0 ,videoKeyFrameFrequence:.5};
		
		
		public function VideoMedia(sourceURL:String) {
			super();
			
			var videoPlayer:VideoPlayer = new VideoPlayer();
			videoPlayer.source = _rtmpUri + sourceURL;//"rtmp://fmsexamples.adobe.com/vod/mp4:_cs4promo_1000.f4v";
			trace(videoPlayer.source);
			//"rtmp://fmsexamples.adobe.com/vod/mp4:_cs4promo_1000.f4v";
			videoPlayer.height = 300;
			videoPlayer.width = 400;
			this.addChild(videoPlayer);
			
			this.height = videoPlayer.height;
			this.width = videoPlayer.width;
			
			setTimeout(function():void {
				var event:IDEvent = new IDEvent(IDEvent.MEDIA_LOADED, true);
				dispatchEvent(event);
				
				videoPlayer.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
					trace("loaded asdfasdfadsfasdfasdfasdfasdfadsf ", e.bytesLoaded, e.bytesTotal);
				});
				
			}, 1000);
			
			videoPlayer.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				trace("loaded asdfasdfadsfasdfasdfasdfasdfadsf", e.bytesLoaded, e.bytesTotal);
			});
			
			
			videoPlayer.addEventListener(VideoEvent.COMPLETE, function(e:VideoEvent):void {
				trace("is complete loading");
				this.height = videoPlayer.height;
				this.width = videoPlayer.width;
				var event:IDEvent = new IDEvent(IDEvent.MEDIA_LOADED, true);
				dispatchEvent(event);
			});
			
//			trace("video content uri", sourceURL);
//			
//			_fileName =	sourceURL.substring(sourceURL.lastIndexOf("\\")+1, sourceURL.length);
//			trace("filename", _fileName);
//			_netConnection = new NetConnection();
//			_netConnection.call("checkBandwidth", null);
//			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus );
//			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
//			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
//			_netConnection.objectEncoding = ObjectEncoding.AMF3;
//			_netConnection.client = this;
//			
//			_netConnection.connect( _rtmpUri, "model.logedinUser.username");
//			
//			// Listen for loading progress (to display hte loading graphics)
//			video.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
//				trace("loading event (video)", e.bytesLoaded, e.bytesTotal);
//				dispatchEvent(e);
//			});
		}
		
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
		
		
		private function connectVideoStream():void {
			_netStream = new NetStream(_netConnection);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
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
			
			_netStream.play(_fileName,0);
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
			trace("SOME ERROR #1");
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace("SOME ERROR #2");
		}
		
		public function onBWDone(a:*=null,b:*=null,c:*=null,d:*=null):void {
			trace("THIS IS SOMETHING");
		}
		
		public function onBWCheck(a:*=null):Number {
			return 0;
		} 
		
	}
}