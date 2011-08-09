package Module.AudioViewer {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class AudioFileLoader extends EventDispatcher {
		
		public var duration:Number = -1;
		public var time:Number = 0;
		private var _url:String = "";
		private var _audioFile:Sound = new Sound();
		private var _audioURLRequest:URLRequest;
		private var _audioChannel:SoundChannel;
		private var _audioTimer:Timer = new Timer(30);
		
		private var _audioTransform:SoundTransform;
		private var _isPlaying:Boolean = false;
		
		public function AudioFileLoader(url:String) {
			_url = url;
			_audioURLRequest = new URLRequest(_url);
			_audioFile.addEventListener(Event.COMPLETE,audioLoaded);
			_audioFile.load(_audioURLRequest);
			_audioTimer.addEventListener(TimerEvent.TIMER,audioUpdated);
			//play();
		}
		
		public function dealloc():void {
			try {
				_audioFile.close();
				_audioFile = null;
			} catch (e:Error) {
				trace("STREAM ALREADY CLOSED"+e.message);
			}
		}
		
		public function getAudioFile():Sound {
			return _audioFile;
		}
		
		private function audioLoaded(e:Event):void {
			duration = _audioFile.length/1000;
			trace("Audio loaded here", duration);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function audioUpdated(e:TimerEvent):void {
			time = _audioChannel.position/1000;
			this.dispatchEvent(new Event("AUDIOPROGRESSUPDATE"));
			//trace("UPADED");
		}
		
		public function play():void {
			trace("AudioFileLoader:play - Now playing AUDIO!!!!!!!!");
			_audioChannel = _audioFile.play(time*1000);
			_audioTimer.start();
			_isPlaying = true;
		}
		
		public function stop():void {
			_audioTimer.stop();
			try {
				_audioChannel.stop();
			} catch (e:Error) {
				trace("Error: Could not stop audio");
			}
			_isPlaying = false;
		}
		
		public function scanTo(newPosition:Number):void {
			var playing:Boolean = false;
			if(_isPlaying) {
				stop();
				playing = true;
			}
			time = newPosition*duration;
			if(playing) {
				play();
			}
		}
		
		public function setVolume(newVolume:Number):void {
			try {
				_audioTransform = _audioChannel.soundTransform;
				_audioTransform.volume = newVolume;
				_audioChannel.soundTransform = _audioTransform;
			} catch(e:Error) {
				trace("Cannot change volume");
			}
		}
		
		
	}
}