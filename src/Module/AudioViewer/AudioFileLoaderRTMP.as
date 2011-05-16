// ActionScript file

package Module.AudioViewer {
	import flash.events.*;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;

	public class AudioFileLoaderRTMP extends EventDispatcher {
		
		public var time:Number = 0;
		public var duration:Number = 0;
		
		private var _source:String = '';
		private var _protocol:String = 'http';
		private var _rtmpConnection:NetConnection;
		private var _rtmpStream:NetStream;
		private var _rtmpServer:String = '';
		private var _rtmpFile:String = '';
		private var _audioTimer:Timer = new Timer(30);
		private var _audioVolumeTransform:SoundTransform = new SoundTransform();
		private var _ispaused:Boolean = true;
		private var _pausedTime:Number = 0;
		private var _changedTime:Boolean = false;
		private var _prepausedVolume:Number = 1;
		private var _restarting:Boolean = false;
		
		public function AudioFileLoaderRTMP(source:String) {
			_audioTimer.addEventListener(TimerEvent.TIMER,audioUpdate);
			_source = source;
			_protocol = _source.substr(0,4);
			trace(_protocol+"::"+_source);
			switch(_protocol) {
				case 'http':
					break;
				case 'rtmp':
					_rtmpServer = _source.substr(0,_source.lastIndexOf("/"));
					_rtmpFile = _source.substr(_source.lastIndexOf("/")+1);
					setupNetConnection();
					break;
				default:
					trace("Undefined protocol, not loading");
			}
		}
		
		public function stop():void {
			_ispaused = true;
			_changedTime = false;
			_pausedTime = time;
			_prepausedVolume = _audioVolumeTransform.volume;
		}
		
		public function play():void {
			if(_ispaused && !_changedTime) {
				this.scanTo(_pausedTime/duration);
			}
			_ispaused = false;
			setVolume(_prepausedVolume);
		}
		
		public function setVolume(volume:Number):void {
			if(_ispaused && volume != 0) {
				_prepausedVolume = volume;
			} else {
				_audioVolumeTransform.volume = volume;
				_rtmpStream.soundTransform = _audioVolumeTransform;
			}
		}
		
		public function scanTo(newPositionPercentage:Number):void {
			try {
				trace("scanning to "+newPositionPercentage);
				_rtmpStream.seek(newPositionPercentage*duration);
				if(_ispaused) {
					_changedTime = true;
				}
			} catch (e:Error) {
				trace("NOT YET LOADED");
			}
		}
		
		private function setupNetConnection():void {
			NetConnection.prototype.onBWDone = function(p_bw:*) {};
			_rtmpConnection = new NetConnection();
			_rtmpConnection.connect(_rtmpServer);
			_rtmpConnection.addEventListener(NetStatusEvent.NET_STATUS,setupNetStream);
		}
		
		private function setupNetStream(event:NetStatusEvent):void { 
			if (event.info.code == "NetConnection.Connect.Success") {
				_rtmpStream = new NetStream(_rtmpConnection,NetStream.CONNECT_TO_FMS);
				_rtmpStream.client = new CustomClient(); 
				_rtmpStream.bufferTime = 5;
				var vid:Video = new Video(320,240);
				vid.attachNetStream(_rtmpStream);
				_rtmpStream.client.addEventListener("metadatacomplete",netStreamMetadataLoaded);
				_rtmpStream.play(_rtmpFile);
				stop();
				_audioTimer.start();
			} 
		}
		
		private function netStreamMetadataLoaded(e:Event):void {
			this.duration = _rtmpStream.client.getDuration();
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function audioUpdate(e:TimerEvent):void {
			if(_ispaused) {
				setVolume(0);
			} else {
				if(duration - _rtmpStream.time < 5) {
					if(!_restarting) {
						restart();
					}
				} else {
					this.time = _rtmpStream.time;
				}
				//trace(_rtmpStream.bufferTime+"K"+_rtmpStream.bufferLength);
				this.dispatchEvent(new Event("AUDIOPROGRESSUPDATE"));
			}
		}
		
		private function restart():void {
			trace("RESTARTING");
			//_restarting = true;
			_rtmpStream.seek(0);
			scanTo(0.1);
			this.time = _rtmpStream.time;
		}
		
	}
	
	
}

import flash.display.Sprite;
import flash.events.Event;

class CustomClient extends Sprite{ 
	
	private var _duration:Number = -1;
	private var _width:Number = -1;
	private var _height:Number = -1;
	private var _framerate:Number = -1;
	
	public function CustomClient() {} 
	public function onPlayStatus(info:Object):void {}
	public function onCuePoint(info:Object):void {}
	 
    public function onMetaData(info:Object):void { 
        _duration = info.duration;
        _width = info.width;
        _height = info.height;
        _framerate = info.framerate;
        this.dispatchEvent(new Event("metadatacomplete")); 
    } 
    public function getDuration():Number {
    	return _duration;
    }
 } 