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
	
	import mx.charts.chartClasses.NumericAxis;
	import mx.containers.VBox;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

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
		
		private var _bars:Sprite = new Sprite(); // I think this is the playhead bar for the waveform
		private var _newAnnotation:AudioNewAnnotation;
		
		// craigs variables
		private var numberOfSections:Number = 20;
		// lets try extracting a numberOfSections-th of a file, at a time
		private var extractLength:Number;
		private var currentExtractSegment:Number = 0;
		private var timeoutSegment:Number; 
		
		public function AudioAnnotateWave()
		{
			super();
			if(BrowserController.currentCollectionID != BrowserController.ALLASSETID) {
				// If we are looking at the original files, dont listen for drawing annotations
				this.addEventListener(MouseEvent.MOUSE_DOWN,startAnnotation);
			}
			this.addEventListener(Event.ADDED_TO_STAGE,loadView);
			this.addEventListener(Event.RESIZE,resize);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, stopExtracting);
			this.addEventListener(FlexEvent.HIDE, stopExtracting );
		}
		
		private function stopExtracting(e:Event = null):void {
			clearTimeout(timeoutSegment);
		}
		
		public function updateBarPosition(newPosition:Number):void {
			//trace(newPosition);
			//_bars.x = newPosition*(this.width-44)+20;
			_bars.x = newPosition*(this.width-44);
		}
		
		private function resize(e:Event):void {
			drawChannelBackground();
			updateWavePosition();
		}
		
		private function loadView(e:Event):void {
			this.addChild(soundWave);
			this.addChild(annotations);
			//soundWave.addChild(_bars);
			annotations.alpha = 0;
			//_bars.alpha = 0;
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
			//_bars.graphics.beginFill(0xFF0000);
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
			
			soundWave.addChild(_bars);
			//_bars.alpha = 0;
			
			_lBitmap.x = _waveOffset+2;
			_rBitmap.x = _waveOffset+2;
			trace("File Length", file.length, "Sample rate", _sampleRate);

			// lets work out how many hours long the audio file is
			var lengthInMinutes:Number = Math.floor(file.length / 1000 / 60); // its in useconds to minutes
			// for every hour, lets break it up into 300 segments (so for < 1hr, it just does it all in 1 go)
			if(lengthInMinutes < 30) {
				numberOfSections = 1;
			} else if (lengthInMinutes < 60) { // for 30-60 minutes
				numberOfSections = 150;
			} else if (lengthInMinutes < 150) {
				numberOfSections = 300; // not the same as doing it ever 30, as this would be 450 for 1hr50mins
			} else {
				numberOfSections = lengthInMinutes / 60 * 300; //minumum of 1 section
			}
//			numberOfSections = Math.max(lengthInHours * 300, 1); //minumum of 1 section
			trace("File is", lengthInMinutes, "segments", numberOfSections);
			
			// lets try extracting a numberOfSections-th of a file, at a time
			extractLength = file.length * _sampleRate / numberOfSections;

//			for(var i:Number = 0; i < numberOfSections; i++) {
//				trace("getting out", i, "extracting from", i * extractLength, "to", i * extractLength + extractLength, "in seconds:", i * extractLength / _sampleRate / 1000, i * (extractLength / 1000 / _sampleRate) + (extractLength / 1000 / _sampleRate));
//				var myBuffer:ByteArray = new ByteArray();
//				file.extract(myBuffer, extractLength, i * extractLength);
//				if(i == numberOfSections - 1) {
//					_audioBuffer = myBuffer;
//				}
//			} 
			//file.extract(_audioBuffer, file.length*_sampleRate, 0);
			//file.extract(_audioBuffer, (file.length / 2) * _sampleRate, 0);
//			file.extract(_audioBuffer, extractLength, 0);
			updateWavePosition();
			extractAudioSegment(file);
		}
		
		private function extractAudioSegment(file:Sound):void {
			trace("getting out", currentExtractSegment, "extracting from", currentExtractSegment * extractLength, "to", currentExtractSegment * extractLength + extractLength, "in seconds:", currentExtractSegment * extractLength / _sampleRate / 1000, currentExtractSegment * (extractLength / 1000 / _sampleRate) + (extractLength / 1000 / _sampleRate));
			var myBuffer:ByteArray = new ByteArray();

			file.extract(myBuffer, extractLength, currentExtractSegment * extractLength);

			
			// Draw the wave for this segment
			//setTimeout(drawWave, 1, myBuffer, currentExtractSegment);
			drawWave(myBuffer, currentExtractSegment);
			
			if(currentExtractSegment == numberOfSections - 1) {
				// we are on the last segment
				trace("last segment, updating wave position");
				
				return;
			}
			
			// We have to use this instead of a for loop, otherwise flash complains
			// about the loop taking more than 15 seconds to exec
			// because 'Sound.extract' takes so bloody long to work.
			// - so Move onto the next segment
			//currentExtractSegment++;
			currentExtractSegment++;
			timeoutSegment = setTimeout(extractAudioSegment, 2000, file);
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
		
		private function drawWave(audioBufferSegment:ByteArray, currentSegmentNumber:Number):void {
			var w:int = _lBitmap.bitmapData.width / numberOfSections;
			var h:int = _lBitmap.bitmapData.height / numberOfSections;
			var channelLength:Number = audioBufferSegment.length/8;
			trace("AudioAnnotateWave:drawWave", audioBufferSegment.length, channelLength);
			_numCondense = channelLength/w;
			_lBitmap.bitmapData.lock();
			_rBitmap.bitmapData.lock();
			audioBufferSegment.position = 0;
			
			setTimeout(drawWavePart, 1, audioBufferSegment, 0, currentSegmentNumber * _lBitmap.bitmapData.width / numberOfSections, new Point(0.5, -0.5), new Point(0.5, -0.5));
//			drawWavePart(audioBufferSegment, 0, currentSegmentNumber * _lBitmap.bitmapData.width / numberOfSections, new Point(1, -1), new Point(1, -1));
//			setTimeout(drawWavePart, 1, audioBufferSegment, );
			_lBitmap.bitmapData.unlock();
			_rBitmap.bitmapData.unlock();
		}
		
		// we take in a bit of the audio clip, in an audio buffer byte array
		// we need to know what area we are drawing
		// and we need to know, where on the actual stage, we should be drawing it
		private function drawWavePart(audioBufferSegment:ByteArray, bufferPos:Number, xPos:Number, leftPoints:Point, rightPoints:Point):void {
//			var startWavPost:int = bufferPos;
			var test:Number = bufferPos;
			
			for (var i:int = bufferPos; i < test + _loadSpeed; i++) {
				if(i%_numCondense == 0) {
					
					Raster.line(_lBitmap.bitmapData, xPos, _lBitmap.height*(leftPoints.x+1)/2, xPos, _lBitmap.height*(leftPoints.y+1)/2, _leftChan);
					Raster.line(_rBitmap.bitmapData, xPos, _rBitmap.height*(rightPoints.x+1)/2, xPos, _rBitmap.height*(rightPoints.y+1)/2, _rightChan);
					leftPoints = new Point(1, -1);
					rightPoints = new Point(1, -1);
					xPos ++;
				}
				if(audioBufferSegment.bytesAvailable) {
					var leftN:Number = audioBufferSegment.readFloat();
					var rightN:Number = audioBufferSegment.readFloat();
					leftPoints.x = leftPoints.x < leftN ? leftPoints.x : leftN;
					leftPoints.y = leftPoints.y > leftN ? leftPoints.y : leftN;
					rightPoints.x = rightPoints.x < rightN ? rightPoints.x : leftN;
					rightPoints.y = rightPoints.y > rightN ? rightPoints.y : leftN;
				}
				bufferPos++;
				if(bufferPos == audioBufferSegment.length/8) {
					break;
				}
//				trace("buffer pos", bufferPos, audioBufferSegment.length/8, _loadSpeed, bufferPos + _loadSpeed);
			}
			if(bufferPos < audioBufferSegment.length/8) {
//				drawWavePart(audioBufferSegment, bufferPos, xPos, new Point(1, -1), new Point(1, -1));
//				trace("running again");
				setTimeout(drawWavePart, 1, audioBufferSegment, bufferPos, xPos, leftPoints, rightPoints); 
//				drawWavePart(audioBufferSegment, xPos);
				//setTimeout(drawWavePart,1, xPos);
			}
		}
	}
}