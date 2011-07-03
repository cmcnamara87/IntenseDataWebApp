package Module.AudioViewer
{
	import Controller.BrowserController;
	
	import Lib.gfx.Raster;
	
	import Module.AudioViewer.AudioNewAnnotation;
	import Module.AudioViewer.AudioView;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.*;
	
	import mx.containers.VBox;
	import mx.core.UIComponent;

	public class AudioAnnotateWave extends VBox
	{
		
		public var viewer:AudioView;
		
		public var annotations:UIComponent = new UIComponent();
		public var soundWave:UIComponent = new UIComponent();
		
		private var _defaultWidth:Number = 800;
		private var _defaultHeight:Number = 100;
		private var _channel1Y:Number = 100;
		private var _channel2Y:Number = 200;
		private var _channelSize:Number = 80;
		private var _padding:Number = 10;
		private var _channelPadding:Number = 0;
		private var _waveOffset:Number = 0;
		private var _audioBuffer:ByteArray = new ByteArray();
		private var _sampleRate:Number = 44.1;
		private var _lBitmap:Bitmap = new Bitmap();
		private var _rBitmap:Bitmap = new Bitmap();
		
		private var _numCondense:int;
		private var _wavePositionI:Number = 0;
		private var _leftPoints:Point = new Point(1, -1);
		private var _rightPoints:Point = new Point(1, -1);
		private var _x:int = 0;
		private var _loadSpeed:int = 20000;
		private var _leftChan:uint = 0xFF00FF00;
		private var _rightChan:uint = 0xFF0000FF;
		
		private var _leftAnnotateMask:Sprite = new Sprite();
		private var _rightAnnotateMask:Sprite = new Sprite();
		private var _firstAnnotateX:Number = 0;
		private var _lastAnnotateX:Number = 0;
		
		private var _bars:Sprite = new Sprite();
		private var _newAnnotation:AudioNewAnnotation;
		
		public function AudioAnnotateWave()
		{
			super();
			if(BrowserController.currentCollectionID != BrowserController.ALLASSETID) {
				// If we are looking at the original files, dont listen for drawing annotations
				this.addEventListener(MouseEvent.MOUSE_DOWN,startAnnotation);
			}
			this.addEventListener(Event.ADDED_TO_STAGE,loadView);
			this.addEventListener(Event.RESIZE,resize);
		}
		
		
		
		public function updateBarPosition(newPosition:Number):void {
			//trace(newPosition);
			_bars.x = newPosition*(this.width-44)+20;
		}
		
		private function resize(e:Event):void {
			drawChannelBackground();
			updateWavePosition();
		}
		
		private function loadView(e:Event):void {
			this.addChild(soundWave);
			this.addChild(annotations);
			soundWave.addChild(_bars);
			annotations.alpha = 0;
			_bars.alpha = 0;
			drawChannelBackground();
			soundWave.mouseEnabled = false;
		}
		
		public function showAnnotationBars():void {
			annotations.alpha = 1;
			_bars.alpha = 1;
		}
		
		private function startAnnotation(e:MouseEvent):void {
			this.dispatchEvent(new Event("STARTINGANNOTATION"));
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.MOUSE_MOVE,moveAnnotationMasks);
			this.addEventListener(MouseEvent.MOUSE_UP,stopAnnotationMasks);
			this.addEventListener(MouseEvent.MOUSE_OUT,stopAnnotationMasks);
			_firstAnnotateX = this.mouseX;
			if(_firstAnnotateX < 20) {
				_firstAnnotateX = 20;
			} else if (_firstAnnotateX > this.width-20) {
				_firstAnnotateX = this.width-20;
			}
			_lastAnnotateX = this.mouseX;
			redrawMasks();
			soundWave.addChild(_leftAnnotateMask);
			soundWave.addChild(_rightAnnotateMask);
			removeNewAnnotation();
		}
		
		private function moveAnnotationMasks(e:MouseEvent):void {
			_lastAnnotateX = this.mouseX;
			if(_lastAnnotateX < 20) {
				_lastAnnotateX = 20;
			} else if (_lastAnnotateX > this.width-20) {
				_lastAnnotateX = this.width-20;
			}
			redrawMasks();
		}
		
		private function stopAnnotationMasks(e:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_MOVE,moveAnnotationMasks);
			this.removeEventListener(MouseEvent.MOUSE_UP,stopAnnotationMasks);
			this.removeEventListener(MouseEvent.MOUSE_OUT,stopAnnotationMasks);
			createAnnotation(_firstAnnotateX,_lastAnnotateX);
			if(soundWave.contains(_leftAnnotateMask)) {
				soundWave.removeChild(_leftAnnotateMask);
			}
			if(soundWave.contains(_rightAnnotateMask)) {
				soundWave.removeChild(_rightAnnotateMask);
			}
		}
		
		private function createAnnotation(firstPos:Number,lastPos:Number):void {
			var firstPercentage:Number = (firstPos-20)/(this.width-40);
			var lastPercentage:Number = (lastPos-20)/(this.width-40);
			if(Math.abs(firstPos-lastPos) > 0) {
				this.mouseChildren = true;
				_newAnnotation = new AudioNewAnnotation(viewer,firstPercentage,lastPercentage,firstPos,lastPos,this.height/2-30,Math.abs(firstPos-lastPos));
				this.addChild(_newAnnotation);
			}
		}
		
		public function removeNewAnnotation():void {
			if(_newAnnotation && this.contains(_newAnnotation)) {
				this.removeChild(_newAnnotation);
			}
		}
		
		private function redrawMasks():void {
			_leftAnnotateMask.graphics.clear();
			_leftAnnotateMask.graphics.beginFill(0xFFFFFF,0.8);
			_rightAnnotateMask.graphics.clear();
			_rightAnnotateMask.graphics.beginFill(0xFFFFFF,0.8
			);
			if(_firstAnnotateX < _lastAnnotateX) {
				_leftAnnotateMask.graphics.drawRect(10,-20,_firstAnnotateX-10,this.height+10);
				_rightAnnotateMask.graphics.drawRect(_lastAnnotateX,-20,this.width-_lastAnnotateX-10,this.height+10);
			} else {
				_leftAnnotateMask.graphics.drawRect(10,-20,_lastAnnotateX-10,this.height+10);
				_rightAnnotateMask.graphics.drawRect(_firstAnnotateX,-20,this.width-_firstAnnotateX-10,this.height+10);
			}
			_leftAnnotateMask.graphics.beginFill(0x333333,1);
			_rightAnnotateMask.graphics.beginFill(0x333333,1);
			if(_firstAnnotateX < _lastAnnotateX) {
				_leftAnnotateMask.graphics.drawRect(_firstAnnotateX,-20,1,this.height+10);
				_rightAnnotateMask.graphics.drawRect(_lastAnnotateX,-20,1,this.height+10);
			} else {
				_leftAnnotateMask.graphics.drawRect(_lastAnnotateX,-20,1,this.height+10);
				_rightAnnotateMask.graphics.drawRect(_firstAnnotateX,-20,1,this.height+10);
			}
		}
		
		public function getYLevelHeight(yLevel:Number,maxYLevel:Number):Number {
			var thenumber:Number = -20;
			thenumber += this.height-this.height*((yLevel+1)/maxYLevel);
			return thenumber;
		}
		
		private function drawChannelBackground():void {
			this.graphics.clear();
			_channel1Y = (this.height-2*_channelSize*1.5)/3+4;
			_channel2Y = _channel1Y*2 + _channelSize*1.5;
			this.graphics.lineStyle(0,0xFFFFFF,0.1);
			this.graphics.beginFill(0xFFFFFF,0.85);
			this.graphics.drawRect(_padding+1,_channel1Y,this.width-_padding*2-1,_channelSize);
			this.graphics.drawRect(_padding+1,_channel2Y,this.width-_padding*2-1,_channelSize);
			this.graphics.lineStyle(1,0xb9b9bb,1);
			this.graphics.moveTo(_padding,_channel1Y);
			this.graphics.lineTo(this.width-_padding,_channel1Y);
			this.graphics.moveTo(_padding,_channel2Y);
			this.graphics.lineTo(this.width-_padding,_channel2Y);
			this.graphics.moveTo(_padding,_channel1Y+_channelSize);
			this.graphics.lineTo(this.width-_padding,_channel1Y+_channelSize);
			this.graphics.moveTo(_padding,_channel2Y+_channelSize);
			this.graphics.lineTo(this.width-_padding,_channel2Y+_channelSize);
			_bars.graphics.clear();
			_bars.graphics.beginFill(0xFF0000);
//			_bars.graphics.drawRect(0, _channel1Y, 1, _channelSize);
//			_bars.graphics.drawRect(0, _channel2Y, 1, _channelSize);
			_bars.graphics.drawRect(20, _channel1Y, 1, _channelSize);
			_bars.graphics.drawRect(20, _channel2Y, 1, _channelSize);
		}
		
		public function loadSoundWave(file:Sound):void {
			trace("AudioAnnotateWave:loadSoundWave", file);
			_audioBuffer.position = 0;
			_lBitmap.bitmapData = new BitmapData(_defaultWidth-_waveOffset*2, _channelSize-_channelPadding*2, true, 0x00000000);
			_rBitmap.bitmapData = new BitmapData(_defaultWidth-_waveOffset*2, _channelSize-_channelPadding*2, true, 0x00000000);
			soundWave.addChild(_lBitmap);
			soundWave.addChild(_rBitmap);
			_lBitmap.x = _waveOffset+2;
			_rBitmap.x = _waveOffset+2;
			file.extract(_audioBuffer,file.length*_sampleRate,0);
			drawWave();
			updateWavePosition();
		}
		
		private function updateWavePosition():void {
			_lBitmap.x = 20;
			_rBitmap.x = 20;
			_lBitmap.y = _channel1Y;
			_rBitmap.y = _channel2Y;
			_lBitmap.smoothing = true;
			_rBitmap.smoothing = true;
			_lBitmap.scaleX = (this.width-42)/_defaultWidth;
			_rBitmap.scaleX = (this.width-42)/_defaultWidth;
		}
		
		private function drawWave():void {
			var w:int = _lBitmap.bitmapData.width;
			var h:int = _lBitmap.bitmapData.height;
			var channelLength:Number = _audioBuffer.length/8;
			trace("AudioAnnotateWave:drawWave", _audioBuffer.length, channelLength);
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