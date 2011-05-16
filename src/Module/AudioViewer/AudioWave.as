package Module.AudioViewer
{
	
	import Lib.gfx.Raster;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.*;
	
	import mx.core.UIComponent;

	public class AudioWave extends UIComponent
	{
		
		private var _audioFile:Sound;
		private var _audioChannel:SoundChannel;
		private var _audioBuffer:ByteArray = new ByteArray();
		private var _sampleRate:Number = 44.1;
		private var _lBitmap:Bitmap = new Bitmap();
		private var _rBitmap:Bitmap = new Bitmap();
		private var _theWidth:Number;
		private var _theHeight:Number;
		private var _waveOffset:Number;
		private var _wavePositionI:Number = 0;
		private var _numCondense:int;
		private var _leftPoints:Point = new Point(1, -1);
		private var _rightPoints:Point = new Point(1, -1);
		private var _x:int = 0;
		private var _loadSpeed:int = 20000;
		private var _channelSize:Number = 80;
		private var _channelPadding:Number = 10;
		private var _channel1Y:Number = 100;
		private var _channel2Y:Number = 200;
		private var _leftChan:uint = 0xFF00FF00;
		private var _rightChan:uint = 0xFF0000FF;
		
		public function AudioWave(audioFile:Sound,theWidth:Number=430,theHeight:Number=400,waveOffset:Number=0,channelSize:Number=80) {
			_channelSize = channelSize;
			_theWidth = theWidth;
			_theHeight = theHeight;
			_waveOffset = waveOffset;
			//drawBounds();
			drawChannelBackground();
			_audioFile = audioFile;
			this.addEventListener(Event.RESIZE,resizeWave);
		}
		
		private function resizeWave(e:Event):void {
			trace("RESIZING WAVE");
		}
		
		public function load():void {
			_audioBuffer.position = 0;
			_lBitmap.bitmapData = new BitmapData(_theWidth-_waveOffset*2, _channelSize-_channelPadding*2, true, 0x00000000);
			_rBitmap.bitmapData = new BitmapData(_theWidth-_waveOffset*2, _channelSize-_channelPadding*2, true, 0x00000000);
			_lBitmap.y = _channel1Y+_channelPadding;
			_rBitmap.y = _channel2Y+_channelPadding;
			addChild(_lBitmap);
			addChild(_rBitmap);
			_lBitmap.x = _waveOffset+2;
			_rBitmap.x = _waveOffset+2;
			_audioFile.extract(_audioBuffer,_audioFile.length*_sampleRate,0);
			drawWave();
			this.graphics.beginFill(0xFF0000);
			this.graphics.drawRect(0,0,100,100);
			trace("DRAWING WAVE");
		}
		
		public function getWaveGraphics():Array {
			_lBitmap.cacheAsBitmap = true;
			_rBitmap.cacheAsBitmap = true;
			return [_lBitmap,_rBitmap,this];
		}
		
		private function drawChannelBackground():void {
			_channel1Y = (_theHeight-2*_channelSize)/3;
			_channel2Y = _channel1Y*2 + _channelSize;
			this.graphics.lineStyle(0,0xFFFFFF,0.1);
			this.graphics.beginFill(0xFFFFFF,0.85);
			this.graphics.drawRect(0,_channel1Y,_theWidth,_channelSize);
			this.graphics.drawRect(0,_channel2Y,_theWidth,_channelSize);
			this.graphics.lineStyle(1,0x333333,1);
			this.graphics.moveTo(0,_channel1Y);
			this.graphics.lineTo(_theWidth,_channel1Y);
			this.graphics.moveTo(0,_channel2Y);
			this.graphics.lineTo(_theWidth,_channel2Y);
			this.graphics.moveTo(0,_channel1Y+_channelSize);
			this.graphics.lineTo(_theWidth,_channel1Y+_channelSize);
			this.graphics.moveTo(0,_channel2Y+_channelSize);
			this.graphics.lineTo(_theWidth,_channel2Y+_channelSize);
		}
		
		private function drawBounds():void {
			this.graphics.lineStyle(1,0x00FF00,1);
			this.graphics.drawRect(0,0,_theWidth,_theHeight);
		}
		
		private function drawWave():void {
			var w:int = _lBitmap.bitmapData.width;
			var h:int = _lBitmap.bitmapData.height;
			var channelLength:Number = _audioBuffer.length/8;
			_numCondense = channelLength/w;
			_lBitmap.bitmapData.lock();
			_rBitmap.bitmapData.lock();
			_audioBuffer.position = 0;
			setTimeout(drawWavePart,1);
			_lBitmap.bitmapData.unlock();
			_rBitmap.bitmapData.unlock();
		}
		
		private function drawWavePart():void {
			var startWavPost:int = _wavePositionI;
			for (var i:int =startWavPost; i < startWavPost+_loadSpeed; i++) {
				if(i%_numCondense == 0) {
					Raster.line(_lBitmap.bitmapData, _x, _lBitmap.height*(_leftPoints.x+1)/2, _x, _lBitmap.height*(_leftPoints.y+1)/2, _leftChan);
					Raster.line(_rBitmap.bitmapData, _x, _rBitmap.height*(_rightPoints.x+1)/2, _x, _rBitmap.height*(_rightPoints.y+1)/2, _rightChan);
					_leftPoints = new Point(1, -1);
					_rightPoints = new Point(1, -1);
					_x++;
				}
				if(_audioBuffer.bytesAvailable) {
					var leftN:Number = _audioBuffer.readFloat();
					var rightN:Number = _audioBuffer.readFloat();
					_leftPoints.x = _leftPoints.x < leftN ? _leftPoints.x : leftN;
					_leftPoints.y = _leftPoints.y > leftN ? _leftPoints.y : leftN;
					_rightPoints.x = _rightPoints.x < rightN ? _rightPoints.x : leftN;
					_rightPoints.y = _rightPoints.y > rightN ? _rightPoints.y : leftN;
				}
				_wavePositionI++;
				if(_wavePositionI == _audioBuffer.length/8) {
					break;
				}
			}
			if(_wavePositionI < _audioBuffer.length/8) {
				setTimeout(drawWavePart,1);
			}
		}
	}
}