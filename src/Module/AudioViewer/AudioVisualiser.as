package Module.AudioViewer {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import mx.core.UIComponent;

	public class AudioVisualiser extends UIComponent {
		
		public var mode:String;
		public var quality:Number = 128;
		public var backgroundColor:uint = 0xFFFFFF;
		public var borderColor:uint = 0xFF0000;
		public var cornerRadius:Number = 10;
		
		private var _audioByteArray:ByteArray = new ByteArray();
		private var _myBitmap:Bitmap = new Bitmap();
		private var _visualisation:Sprite = new Sprite();
		private var _visualisationMask:Sprite = new Sprite();
		
		private var _theWidth:Number=400;
		private var _theHeight:Number=400;
		private var _updateTimer:Timer = new Timer(30);
		
		public function AudioVisualiser() {
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			this.addEventListener(Event.RESIZE,resize);
		}
		
		private function init(e:Event):void {
			setupMode();
			this.addChild(_visualisation);
			_visualisation.alpha = 0.1;
			setMask();
			_updateTimer.addEventListener(TimerEvent.TIMER,updateTimer);
			resize();
		}
		
		public function stop():void {
			_updateTimer.stop();
		}
		
		public function start():void {
			_updateTimer.start();
		}
		
		private function resize(e:Event=null):void {
			_theWidth = this.width-10;
			_theHeight = this.height-10;
			this.x = 10;
			this.y = 10;
			setupMode();
			_visualisation.scaleX = _theWidth/(quality*2);
			_visualisation.scaleY = _theWidth/(quality*2);
			setMask();
		}
		
		private function setMask():void {
			_visualisationMask.graphics.clear();
			_visualisationMask.graphics.beginFill(0xFF0000,1);
			_visualisationMask.graphics.drawRect(0,0,_theWidth,_theHeight);
			this.addChild(_visualisationMask);
			_visualisation.mask = _visualisationMask;
			this.graphics.clear();
			this.graphics.lineStyle(1,borderColor,1);
			this.graphics.beginFill(backgroundColor,1);
			this.graphics.drawRoundRect(0,0,_theWidth,_theHeight,cornerRadius);
		}
		
		private function setupMode():void {
			switch(mode) {
				/*case 'line':
					_visualisation.addChild(_myBitmap);
					_myBitmap.bitmapData = new BitmapData(_theWidth,_theHeight, true, 0x00000000);
					_myBitmap.y = _theWidth/2;
					_myBitmap.x = _theHeight/2;
					break;*/
				case 'circle':
					_visualisation.y = _theHeight/2;
					_visualisation.x = _theWidth/2;
					break;
			}
		}
		
		private function updateTimer(e:TimerEvent):void {
			update();
		}
		
		public function update():void {
			switch(mode) {
				/*case 'line':
					lineRender();
					break;*/
				case 'circle':
					circleRender();
					break;
			}
		}
		
		private var _countByte:Number = 0;
		private function circleRender():void {
			_countByte = 0;
			_visualisation.graphics.clear();
			if(!SoundMixer.areSoundsInaccessible()) {
				try {
					SoundMixer.computeSpectrum(_audioByteArray,true,0);
					for(var i:int=0; i<quality; i=i+8) {
						_countByte = _audioByteArray.readFloat();
						var num:Number = _countByte*360;
						_visualisation.graphics.lineStyle(num/15,0x99CCFF|(num << 8));
						_visualisation.graphics.drawCircle(0,0,i);
					}
				} catch (e:Error) {
					trace("CANT GET SOUND");
				}
			} else {
				trace("CANT GET SOUND");
			}
		}
		
		/*private function lineRender():void {
			SoundMixer.computeSpectrum(_audioByteArray,true,0);
			var i:int;  	
			Raster.rectangle(_myBitmap.bitmapData,0,0,512,200,0,0x66FF0000,0x00FFFFFF);
			this.graphics.beginFill(0xFF0000,0.5);	  	
			var w:int = 2;  	
			for (i=0; i<512; i+=w) {  		
				var t:Number = _audioByteArray.readFloat();  		
				var n:Number = (t * 100); 
				Raster.rectangle(_myBitmap.bitmapData,i,100-n,w,n,4,0xFF0000FF,0xFF00FF00);
			}
		}*/
	}
}