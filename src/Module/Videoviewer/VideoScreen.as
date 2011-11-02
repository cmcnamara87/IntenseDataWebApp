package Module.Videoviewer {
	
	import Controller.Dispatcher;
	import Controller.ERA.FileController;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class VideoScreen extends UIComponent {
		
		public var delegate:Videoview;
		
		public var backgroundColor:uint = 0x000000;
		public var borderColor:uint = 0xFF0000;
		public var cornerRadius:Number = 10;
		
		private var _viewer:Sprite = new Sprite();
		private var _videoPlayer:Video = new Video();
		
		private var _bufferSprite:Sprite = new Sprite();
		private var _bufferSpriteText:TextField = new TextField();
		private var _bufferSpriteTextFormat:TextFormat = new TextFormat();
		
		private var _videoPlayerMask:Sprite = new Sprite();
		private var _videoAnnotationMask:Sprite = new Sprite();
		
		public var autoplay:Boolean = false;
		private var bufferEmpty:Boolean = false;
		
		private var _video:*;
		//private var _rtmpUri:String = "rtmp://demo.recensio.com.au/oflaDemo";
//		private var _rtmpUri:String = "rtmp://recensio.dyndns.org/vod/";

		private var _rtmpUri:String = "rtmp://" + Recensio_Flex_Beta.serverAddress + "/vod/";
		private var _fileName:String = "";
		private var _metaData:Object = { duration:0, width: 0, height: 0 ,videoKeyFrameFrequence:.5};
		
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _connected:Boolean = false;
		//private var _playing:Boolean = false;
		private var _playing:Boolean = true;
		private var _buffering:Boolean = false;
		
		private var _maxedSize:Boolean = false;
		
		private var _tickTimer:Timer = new Timer(30);
		
		private var _videoAnnotations:Sprite = new Sprite();
		
		private var _videoWidth:Number = 400;
		private var _videoHeight:Number = 400;
		
		public function VideoScreen():void {
			this.addEventListener(Event.ADDED_TO_STAGE,setupScreen);
			this.addEventListener(Event.RESIZE,resize);
		}
		
		public function load(video:Object):void {
			_video = video;
			trace("Loading: ", video);
			loadVideo(_video);
			startTimer();
			setupBufferSprite();
		}
		
		private function setupMask():void {
			addChild(_videoPlayerMask);
			addChild(_videoAnnotationMask);
			addChild(_videoAnnotations);
		}
		
		private function setupBufferSprite():void {
			_bufferSprite.graphics.beginFill(0x333333,0.8);
			_bufferSprite.graphics.drawRoundRect(-120,-30,240,60,12);
			_bufferSpriteText.text = "Loading 0%";
			_bufferSpriteText.width = 240;
			_bufferSpriteText.x = -120;
			_bufferSpriteText.y = -10;
			_bufferSpriteText.selectable = false;
			_bufferSpriteTextFormat.font = "Arial";
			_bufferSpriteTextFormat.size = 18;
			_bufferSpriteTextFormat.color = 0xFFFFFF;
			_bufferSpriteTextFormat.align = TextFormatAlign.CENTER;
			_bufferSpriteText.setTextFormat(_bufferSpriteTextFormat);
			_bufferSprite.addChild(_bufferSpriteText);
		}
		
		public function maxsizeclicked():void {
			if(_maxedSize) {
				_maxedSize = false;
			} else {
				_maxedSize = true;
			}
			resize();
		}
		
		private function startTimer():void {
			_tickTimer.addEventListener(TimerEvent.TIMER,tick);
			_tickTimer.start();
		}
		
		private function tick(e:TimerEvent):void {
			if(_connected) {
				checkBuffer();
				delegate.setVideoTime(_netStream.time);
				if(!_buffering) {
				}
			}
			try {
				
			} catch (e:Error) {
				trace("NO VIDEO YET");
			}
		}
		
		private function checkBuffer():void {
			if(_netStream.bufferLength < _netStream.bufferTime) {
				_buffering = true;
				if(!this.contains(_bufferSprite)) {
					this.addChild(_bufferSprite);
				}
				_bufferSpriteText.text = "Loading "+Math.round(_netStream.bufferLength/_netStream.bufferTime*100)+"%";
				_bufferSpriteText.setTextFormat(_bufferSpriteTextFormat);
			} else {
				if(this.contains(_bufferSprite)) {
					this.removeChild(_bufferSprite);
				}
				_buffering = false;
			}
			if(!_playing && this.contains(_bufferSprite)) {
				this.removeChild(_bufferSprite);
			}
			delegate.updateBuffer(_netStream.bufferLength);
			if(delegate.nearEnd() && this.contains(_bufferSprite)) {
				this.removeChild(_bufferSprite);
			}
		}
		
		public function scrubTo(newTime:Number):void {
			///if(Math.abs(Math.round(newTime) - _netStream.time) > 0.5) {
			if(Math.abs(Math.round(newTime) - _netStream.time) > 0.25) {
				// You have to move at least 2 seconds ahead. who cares!!!
				_netStream.bufferTime = 0.5;
				_netStream.seek(Math.round(newTime));
			}
		}
		
		private function loadVideo(contentUri:String):void {
			trace("video content uri", contentUri);
			_fileName =	contentUri.substring(contentUri.lastIndexOf("\\")+1,contentUri.length);
			trace("filename", _fileName);
			_netConnection = new NetConnection();
			_netConnection.call("checkBandwidth", null);
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus );
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
			_netConnection.objectEncoding = ObjectEncoding.AMF3;
			_netConnection.client = this;
			
			trace("RTMP********", _rtmpUri);
			_netConnection.connect( _rtmpUri, "model.logedinUser.username");
		}
		
		public function playpause():void {
			if(_playing) {
				trace("VideoScreen:playpause - was playing, now pausing");
//				_playing = false;
				pause();
			} else {
//				_playing = true;
				play();
				trace("VideoScreen:playpause - was paused, now playing");
			}
		}
		
		/**
		 * Pause the netstream 
		 * 
		 */		
		public function pause():void {
			_playing = false;
			delegate.isPaused(true);
			trace("VideoScreen:pause - Pausing netstream");
			_netStream.pause();
		}
		
		/**
		 * Play the netstream 
		 * 
		 */		
		public function play():void {
			_playing = true;
			delegate.isPaused(false);
			trace("VideoScreen:play - Playing netstream");
			_netStream.resume();
		}
		
		
		public function setVolume(newVolume:Number):void {
			_netStream.soundTransform = new SoundTransform(newVolume);
		}
		
		private function setupScreen(e:Event=null):void {
			_videoPlayer.x = 10;
			_videoPlayer.y = 10;
			this.addChild(_videoPlayer);
			setupMask();
			_videoPlayer.mask = _videoPlayerMask;
			_videoAnnotations.mask = _videoAnnotationMask;
			resize();
		}
		
		private function connectVideoStream():void {
			if(_netConnection) {
				_netStream = new NetStream(_netConnection);
				_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
				_netStream.bufferTime = 5;
				_netStream.inBufferSeek = true;
				_netStream.backBufferTime = 30;
				_netStream.client = this;
				_videoPlayer.attachNetStream(_netStream);
				_videoPlayer.visible = true;
				trace("Playing***********", _fileName);
				_netStream.play(_fileName,0);
				if(!autoplay) {
					//pause();
					delegate.isPaused(true);
				} else {
					delegate.isPaused(false);
				}
				_connected = true;
			}
		}
		
		public function stop():void {
			try {
				_netStream.pause();
			} catch(e:Error) {
				trace("Error: Could not stop");
			}
		}
		

		
		public function getVideoDimensions():Rectangle {
			return new Rectangle(_videoPlayer.x,_videoPlayer.y,_videoPlayer.width,_videoPlayer.height);
		}
		
		public function getOverlay():Sprite {
			return this._videoAnnotations;
		}
		
		public function clearOverlay():void {
			//this.removeChild(this._videoAnnotations);
			//this._videoAnnotations = new Sprite();
			//this.addChild(_videoAnnotations);
			for(var i:Number = 0; i < _videoAnnotations.numChildren; i++) {
				_videoAnnotations.removeChildAt(i);//_videoAnnotations.getChildAt(i);
			}
			
			_videoAnnotations.graphics.clear();
			_videoAnnotations.graphics.beginFill(0x0000ff,0);
			_videoAnnotations.graphics.drawRect(0,0,_videoPlayer.width,_videoPlayer.height);
			
			
			//resize();
		}
		public function getDrawableArea():Sprite {
			return this._videoAnnotations;
		}
		
		public function clearDrawableArea():void {
			_videoAnnotations.graphics.clear();
			_videoAnnotations.graphics.beginFill(0x0000ff,0);
			_videoAnnotations.graphics.drawRect(0,0,_videoPlayer.width,_videoPlayer.height);
		}
		
		public function getVideo():Video {
			return this._videoPlayer;
		}
		
		public function fullscreen():void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState=StageDisplayState.FULL_SCREEN;
			} else {
				stage.displayState=StageDisplayState.NORMAL;
			}
		}
		
		public function resize(e:Event=null):void {
			this.graphics.clear();
			this.graphics.lineStyle(1,borderColor,1);
			this.graphics.beginFill(backgroundColor,1);
			this.graphics.drawRoundRect(0,0,this.width,this.height,cornerRadius);
			_videoPlayer.width = this.width-20;
			_videoPlayer.height = this.height-20;
			if(!_maxedSize) {
				if(_videoPlayer.width/_videoPlayer.height > _videoWidth/_videoHeight) {
					_videoPlayer.width = (_videoWidth/_videoHeight)*_videoPlayer.height;
					_videoPlayer.x = 10+((this.width-20)-_videoPlayer.width)/2;
					_videoPlayer.y = 10+((this.height-20)-_videoPlayer.height)/2;
				} else {
					_videoPlayer.height = (_videoHeight/_videoWidth)*_videoPlayer.width;
					_videoPlayer.x = 10+((this.width-20)-_videoPlayer.width)/2;
					_videoPlayer.y = 10+((this.height-20)-_videoPlayer.height)/2;
				}
			} else {
				if(_videoPlayer.width/_videoPlayer.height < _videoWidth/_videoHeight) {
					_videoPlayer.width = (_videoWidth/_videoHeight)*_videoPlayer.height;
					_videoPlayer.x = 10+((this.width-20)-_videoPlayer.width)/2;
					_videoPlayer.y = 10+((this.height-20)-_videoPlayer.height)/2;
					trace("MAXED SIZE WITH X");
				} else {
					_videoPlayer.height = (_videoHeight/_videoWidth)*_videoPlayer.width;
					_videoPlayer.x = 10+((this.width-20)-_videoPlayer.width)/2;
					_videoPlayer.y = 10+((this.height-20)-_videoPlayer.height)/2;
					trace("MAXED SIZE WITH Y");
				}
			}
			_videoAnnotations.x = _videoPlayer.x;
			_videoAnnotations.y = _videoPlayer.y;
			_videoPlayerMask.graphics.clear();
			_videoPlayerMask.graphics.beginFill(0xFF0000,1);
			_videoPlayerMask.graphics.drawRect(10,10,this.width-20,this.height-20);
			_videoAnnotationMask.graphics.clear();
			_videoAnnotationMask.graphics.beginFill(0xFF0000,1);
			_videoAnnotationMask.graphics.drawRect(10,10,this.width-20,this.height-20);
			_bufferSprite.x = this.width/2;
			_bufferSprite.y = this.height/2;
			_videoAnnotations.graphics.clear();
			_videoAnnotations.graphics.beginFill(0x0000ff,0);
			_videoAnnotations.graphics.drawRect(0,0,_videoPlayer.width,_videoPlayer.height);
		}
		
		public function getVideoPlayerWidth():Number {
			return _videoPlayer.width;
		}
		
		public function getVideoPlayerHeight():Number {
			return _videoPlayer.height;
		}
		
		public function onMetaData(info:Object):void {
			if(!autoplay) {
				pause();
			}
			_metaData = info;
			_videoWidth = info.width;
			_videoHeight = info.height;
			delegate.setDuration(_metaData.duration);
			_netStream.backBufferTime = _metaData.duration;
			resize();
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
//					delegate.isPaused(true);
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
					bufferEmpty = true;
					//this.pause();
					//_playing = false;
					break;
				case "NetStream.Buffer.Full":
					_netStream.bufferTime = 0.5;
					if(bufferEmpty) {
						bufferEmpty = false;
						this.play();
//						_playing = true;
					}
					break;
				case "NetConnection.Connect.Success":
					connectVideoStream();
					break;
				case "NetConnection.Connect.Closed":
					_playing = false;
					//playing	=	false;
					break;
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.InvalidApp":
				case "NetConnection.Connect.AppShutdown":
				case "NetStream.Play.Failed":
				case "NetStream.Play.StreamNotFound":
					trace("Media is currently being encoded, please try again later");
					Alert.show("This Media is currently being transcoded. It will become available shortly.");
					Dispatcher.call('case/' + FileController.caseID + "/" + FileController.roomType);
//					code = "Media is currently being encoded, please try again later";
//					delegate.playFailed(code);
					break;				
			}
		}
		
		private function onAsyncError(e:AsyncErrorEvent):void {
			trace("SOME ERROR #1");
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace("SOME ERROR #2");
		}
		
		public function onBWCheck(a:*=null):Number {
			return 0;
		} 
		
		public function onBWDone(a:*=null,b:*=null,c:*=null,d:*=null):void {
			trace("THIS IS SOMETHING");
		}
		
		public function onPlayStatus(e:Object):void {
			var code:String = e.code;
			trace("PLAY STATUS"+code);
			switch(code) {
				case "NetStream.Play.Complete":
					//dispatchEvent( new playCompleteEvent( playCompleteEvent.playComplete ) );
					trace("SOMETHING FINISHED");
					break;
			}
			
		}
		
		public function dealloc():void {
			_tickTimer.removeEventListener(TimerEvent.TIMER,tick);
			_tickTimer.stop();
			_tickTimer = null;
			if(_netStream) {
				_netStream.pause();
			}
			if(_netConnection && _netConnection.connected) {
				_netConnection.close();
			}
			_netStream = null;
			_netConnection = null;
			_connected = false;
			_playing = false;
			_buffering = false;
			_videoWidth = 400;
			_videoHeight = 400;
			_video = null;
			if(contains(_bufferSprite)) {
				removeChild(_bufferSprite);
			}
			_bufferSprite = null;
			if(contains(_viewer)) {
				removeChild(_viewer);
			}
			_viewer = null;
			if(contains(_videoPlayer)) {
				removeChild(_videoPlayer);
			}
			_videoPlayer = null;
		}

	}
}