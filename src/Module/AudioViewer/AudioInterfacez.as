package Module.AudioViewer
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;

	public class AudioInterfacez extends UIComponent {
		
		private var _scroller:Sprite = new Sprite();
		private var _playButton:Sprite = new Sprite();
		private var _scrollHead:Sprite = new Sprite();
		private var _scrollHeadTimer:Timer = new Timer(30);
		private var _scrollOverGraphic:Sprite = new Sprite();
		private var _viewer:AudioView;
		
		private var _interfaceTopPadding:Number = 50;
		private var _theWidth:Number;
		private var _theHeight:Number;
		private var _interfaceHeight:Number;
		private var _padding:Number;
		private var _channelSize:Number;
		
		private var _wave1Gradient:Shape = new Shape();
		private var _wave2Gradient:Shape = new Shape();
		
		private var _annotationArea:Sprite = new Sprite();
		private var _annotationBubblesArea:Sprite = new Sprite();
		
		private var _textAudioPosition:TextField = new TextField();
		
		public function AudioInterfacez(viewer:AudioView,theWidth:Number=400,theHeight:Number=400,interfaceHeight:Number=50,padding:Number=20,channelSize:Number=80) {
			_channelSize = channelSize;
			_theWidth = theWidth;
			_theHeight = theHeight;
			_interfaceHeight = interfaceHeight;
			_padding = padding;
			drawBackground();
			_viewer = viewer;
			drawScroll();
			drawPlayButton();
			setPositions(theHeight-interfaceHeight+_interfaceTopPadding);
			addAnnotationArea();
			addInteraction();
		}
		
		public function addAnnotations(annotations:Array):void {
			for(var i:int=0; i<annotations.length; i++) {
				var newAnnotation:AudioAnnotation = AudioAnnotation.add(annotations[i],this);
				this._annotationArea.addChild(newAnnotation);
			}
			AudioAnnotation.redraw(_viewer.audioLength,(_theWidth-_padding*2),_padding,_theHeight-_interfaceHeight+2+_interfaceTopPadding);
		}
		
		private function drawBackground():void {
			this.graphics.lineStyle(2,0x333333,1);
			this.graphics.beginFill(0xEEEEEE,1);
			this.graphics.drawRoundRect(-1,_theHeight-_interfaceHeight+20,_theWidth+2,_interfaceHeight+_interfaceTopPadding-20,10);
		}
		
		private function addAnnotationArea():void {
			_annotationArea.graphics.beginFill(0xFF0000,0.01);
			_annotationArea.graphics.drawRect(0,0,_theWidth,_theHeight-_interfaceHeight);
			addChild(_annotationArea);
			_annotationArea.addChild(_annotationBubblesArea);
		}
		
		private function addInteraction():void {
			_playButton.addEventListener(MouseEvent.CLICK,togglePlay);
			_scrollHead.addEventListener(MouseEvent.MOUSE_DOWN,startHeadDrag);
			_scroller.addEventListener(MouseEvent.MOUSE_DOWN,moveHead);
			_scrollHeadTimer.addEventListener(TimerEvent.TIMER,doHeadDrag);
			_annotationArea.addEventListener(MouseEvent.MOUSE_DOWN,annotationDown);
		}
		
		private function annotationDown(e:MouseEvent):void {
			trace("ANNOTATION IS DOWN");
			removeExistingBubbles();
			_viewer.stopPlay();
			_scrollHeadTimer.start();
			this.stage.addEventListener(MouseEvent.MOUSE_UP,stopHeadDrag);
		}
		
		private function togglePlay(e:MouseEvent):void {
			_viewer.togglePlay();
		}
		
		private function setPositions(playbarPosition:Number):void {
			_playButton.y = playbarPosition+_scroller.height+10;
			_textAudioPosition.y = playbarPosition+_scroller.height+10;
			_scroller.y = playbarPosition-10;
			_scrollHead.y = playbarPosition-10;
			_scrollHead.x = _padding;
		}
		
		private function drawScroll():void {
			_scroller.graphics.lineStyle(2,0x000000,1);
			_scroller.graphics.beginFill(0xFFFFFF,0.5);
			_scroller.graphics.drawRoundRect(0+_padding/2,(_interfaceHeight-20)/2,_theWidth-_padding,20,10);
			this.addChild(_scroller);
			drawScrollhead();
		}
		
		private function drawScrollhead():void {
			var waves:Array = _viewer.getWaveGraphics();
			_scrollHead.graphics.beginFill(0x000000,1);
			_scrollHead.graphics.drawRect(0,(_interfaceHeight-20)/2+2,2,16);
			this.addChild(_scrollHead);
			_scrollOverGraphic.graphics.beginFill(0x990000,0.5);
			var channelSpace:Number = ((_theHeight-_interfaceHeight)-_channelSize*2)/3;
			var y1:Number = 0-(_theHeight-_interfaceHeight)+channelSpace-_interfaceTopPadding+10;
			var y2:Number = 0-(_theHeight-_interfaceHeight)+channelSpace*2+_channelSize-_interfaceTopPadding+10;
			_scrollOverGraphic.graphics.drawRect(2,y1,1,_channelSize);
			_scrollOverGraphic.graphics.drawRect(2,y2,1,_channelSize);
			_scrollHead.addChild(_scrollOverGraphic);
			
			var unselectedAlpha:Number = 0.4;
			var gradMat:Matrix = new Matrix();
			gradMat.createGradientBox(_channelSize/2,_channelSize/2,0);
			var gradMat2:Matrix = new Matrix();
			gradMat2.createGradientBox(_channelSize/2,_channelSize/2,0,0-_channelSize/2);
			_wave1Gradient.graphics.beginGradientFill('linear',[0xFF0000,0x0000FF],[1,unselectedAlpha],[0x00,0xFF],gradMat);
			_wave1Gradient.graphics.drawRect(3,channelSpace,_theWidth,_channelSize);
			_wave1Gradient.graphics.beginGradientFill('linear',[0x0000FF,0xFF0000],[unselectedAlpha,1],[0x00,0xFF],gradMat2);
			_wave1Gradient.graphics.drawRect(3-_theWidth,channelSpace,_theWidth,_channelSize);
			_wave1Gradient.graphics.endFill();
			_wave1Gradient.cacheAsBitmap = true;
			_wave2Gradient.graphics.beginGradientFill('linear',[0xFF0000,0x0000FF],[1,unselectedAlpha],[0x00,0xFF],gradMat);
			_wave2Gradient.graphics.drawRect(3,channelSpace*2+_channelSize,_theWidth,_channelSize);
			_wave2Gradient.graphics.beginGradientFill('linear',[0x0000FF,0xFF0000],[unselectedAlpha,1],[0x00,0xFF],gradMat2);
			_wave2Gradient.graphics.drawRect(3-_theWidth,channelSpace*2+_channelSize,_theWidth,_channelSize);
			_wave2Gradient.graphics.endFill();
			_wave2Gradient.cacheAsBitmap = true;
			
			waves[2].addChild(_wave1Gradient);
			waves[2].addChild(_wave2Gradient);
			waves[0].mask = _wave1Gradient;
			waves[1].mask = _wave2Gradient;
			
			updateGradientPosition();
		}
		
		private function updateGradientPosition():void {
			_wave1Gradient.x = _scrollHead.x;
			_wave2Gradient.x = _scrollHead.x;
		}
		
		private function drawPlayButton(isPlaying:Boolean=false):void {
			_playButton.graphics.clear();
			if(isPlaying) {
				_playButton.graphics.beginFill(0x00FF00);
				updateAnnotationsDisplay();
			} else {
				_playButton.graphics.beginFill(0xFF0000);
			}
			_playButton.graphics.drawRoundRect((_theWidth-50)/2,2,50,20,10);
			this.addChild(_playButton);
			this.addChild(_textAudioPosition);
		}
		
		private function moveHead(e:MouseEvent):void {
			_scrollHead.x = this.mouseX;
			this.updateAudio();
			startHeadDrag(e);
		}
		
		private function startHeadDrag(e:MouseEvent):void {
			if(e) {
				if(e.target == _scrollOverGraphic) {
				} else {
					_scrollHeadTimer.start();
					this.stage.addEventListener(MouseEvent.MOUSE_UP,stopHeadDrag);					
				}
			}
		}
		
		private function stopHeadDrag(e:MouseEvent):void {
			_scrollHeadTimer.stop();
		}
		
		private function doHeadDrag(e:TimerEvent):void {
			moveAudioPosition(this.mouseX);
		}
		
		private function moveAudioPosition(newX:Number):void {
			if(newX > _padding) {
				if(newX < (_theWidth-_padding)) {
					_scrollHead.x = newX;
				} else {
					_scrollHead.x = (_theWidth-_padding);
				}
			} else {
				_scrollHead.x = _padding;
			}
			this.updateAudio();
			updateGradientPosition();
		}
		
		private function updateTextPosition():void {
			_textAudioPosition.text = ""+totime(_viewer.getAudioPosition())+" / "+totime(_viewer.audioLength);
		}
		
		private function totime(time:Number):String {
			var timeString:String = "";
			time = Math.round(time);
			var seconds:Number = time%60;
			var minutes:Number = Math.floor(time/60);
			if(minutes < 10) {
				timeString = "0"+minutes+":";
			} else {
				timeString = minutes+":";
			}
			if(seconds < 10) {
				timeString = timeString+"0"+seconds;
			} else {
				timeString = timeString+seconds+":";
			}
			return timeString;
		}
		
		public function updateScrollHead(newPositionPercentage:Number):void {
			if(!_scrollHeadTimer.running) {
				var range:Number = (_theWidth-_padding*2);
				_scrollHead.x = Math.round(_padding + range*newPositionPercentage);
				updateGradientPosition();
			}
			updateAnnotationsDisplay();
			updateTextPosition();
		}
		
		private function updateAnnotationsDisplay():void {
			AudioAnnotation.highlightAnnotations(_scrollHead.x);
		}
		
		private function updateAudio():void {
			var range:Number = (_theWidth-_padding*2);
			var position:Number = _scrollHead.x - _padding;
			var percentage:Number = position/range;
			_viewer.updateAudio(percentage);
		}
		
		public function setPlay(isPlaying:Boolean):void {
			drawPlayButton(isPlaying);
		}
		
		public function getHeadPosition():Number {
			return _scrollHead.x;
		}
		
		public function annotationClicked(annotation:DisplayObject):void {
			moveAudioPosition(annotation.x);
		}
		
		public function addAnnotationBubble(annotation:AudioAnnotation):void {
			var alreadyExists:Boolean = false;
			for(var i:Number=0; i<_annotationBubblesArea.numChildren; i++) {
				if((_annotationBubblesArea.getChildAt(i) as AnnotationBubble).theAnnotation == annotation) {
					alreadyExists = true;
					break;
				}
			}
			if(!alreadyExists) {
				var newBubble:AnnotationBubble = new AnnotationBubble(annotation,this);
				_annotationBubblesArea.addChild(newBubble);
				newBubble.x = Math.floor(annotation.x);
				newBubble.y =  (3-annotation.yLevel)*64+15;
			}
		}
		
		private function removeExistingBubbles():void {
			for(var i:Number=_annotationBubblesArea.numChildren-1; i>-1; i--) {
				_annotationBubblesArea.removeChildAt(i);
			}
		}
		
		public function removeAnnotationBubble(annotation:AudioAnnotation):void {
			for(var i:Number=0; i<_annotationBubblesArea.numChildren; i++) {
				if((_annotationBubblesArea.getChildAt(i) as AnnotationBubble).theAnnotation == annotation) {
					_annotationBubblesArea.removeChildAt(i);
					break;
				}
			}
			trace("removing annotation"+annotation.text);	
		}
		
	}
	
}