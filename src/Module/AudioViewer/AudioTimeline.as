package Module.AudioViewer {
	
	import Model.Model_Commentary;
	
	import Module.AudioViewer.AudioAnnotateWave;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;

	public class AudioTimeline extends UIComponent {
		
		public var backgroundColor:uint = 0xFFFFFF;
		public var borderColor:uint = 0xFF0000;
		public var cornerRadius:Number = 10;
		
		private var _timeline:Sprite = new Sprite();
		private var _timelineHead:Sprite = new Sprite();
		public var _annotationArea:UIComponent = new UIComponent();
		
		private var _audioView:AudioView;
		private var _annotaterView:AudioAnnotateWave;
		
		private var _maxLevel:Number = 4;
		
		public function AudioTimeline():void {
			this.addEventListener(Event.ADDED_TO_STAGE,setupTimeline);
			this.addEventListener(Event.RESIZE,resize);
			addObjects();
		}
		
		public function setView(audioView:AudioView):void {
			_audioView = audioView;
		}
		
		private function setupTimeline(e:Event=null):void {
			resize();
		}
		
		public function setAnnotationView(annotaterView:AudioAnnotateWave):void {
			_annotaterView = annotaterView;
		}
		
		public function resize(e:Event=null):void {
			this.graphics.clear();
			this.graphics.lineStyle(1,borderColor,1);
			this.graphics.beginFill(backgroundColor,1);
			this.graphics.drawRoundRect(0,0,this.width,this.height,cornerRadius);
			
			_timeline.graphics.clear();
			_timeline.graphics.lineStyle(1,borderColor,1);
			_timeline.graphics.beginFill(0xFFFFFF,0.1);
			_timeline.graphics.drawRect(0,0,this.width-20,20);
			_timeline.x = 10;
			_timeline.y = this.height-30;
			redrawAnnotations();
			redrawBubbles();
		}
		
		private function addObjects():void {
			this.addChild(_annotationArea);
			_annotationArea.x = 10;
			this.addChild(_timeline);
			_timeline.addEventListener(MouseEvent.MOUSE_DOWN,startMovePosition);
			_timeline.addEventListener(MouseEvent.MOUSE_UP,stopMovePosition);
			_timeline.addEventListener(MouseEvent.MOUSE_OUT,stopMovePosition);
			_timeline.addChild(_timelineHead);
			drawTimelineHead();
		}
		
		private function drawTimelineHead():void {
			_timelineHead.graphics.beginFill(0x000000,1);
			_timelineHead.graphics.drawRect(0,0,4,20);
			_timelineHead.mouseEnabled = false;
		}
		
		public function updateHeadPosition(newPercentage:Number):void {
			_timelineHead.x = newPercentage*(this.width-24);
			AudioAnnotation.highlightAnnotations(_timelineHead.x);
		}
		
		private function startMovePosition(e:MouseEvent):void {
			_timeline.addEventListener(MouseEvent.MOUSE_MOVE,updateMovePosition);
			//_audioView.togglePlay(true,false);
			movePos(_timeline.mouseX-2);
		}
		
		private function updateMovePosition(e:MouseEvent):void {
			movePos(_timeline.mouseX-2);
		}
		
		private function movePos(newPosition:Number):void {
			_timelineHead.x = newPosition;
			_audioView.scanTo(newPosition/(this.width-24));
		}
		
		private function stopMovePosition(e:MouseEvent):void {
			//_audioView.togglePlay(true,true);
			_timeline.removeEventListener(MouseEvent.MOUSE_MOVE,updateMovePosition);
		}
		
		public function addAnnotation(annotation:Model_Commentary):void {
			trace("Adding 1 annotation");
			var newAnnotation:AudioAnnotation = AudioAnnotation.add(annotation,this);
			this._annotationArea.addChild(newAnnotation);
			redrawAnnotations();
		}
		
		public function addAnnotations(annotations:Array):void {
			// Clear all anntoations first
			trace("Adding ALL annotations", annotations.length);
			//if(annotations.length != 1) {
				trace("Removing all annotations");
				AudioAnnotation.clearAllAnnotations();
				for(var j:Number = 0; j < this._annotationArea.numChildren; j++) {
					trace("Removing annotation", j);
					this._annotationArea.removeChildAt(j);
				}
				this.removeChild(_annotationArea);
				_annotationArea = new UIComponent();
				this.addChild(_annotationArea);
				_annotationArea.x = 10;
				//redrawAnnotations();
			//}
			
			try {
				for(var i:int=0; i<annotations.length; i++) {
					var newAnnotation:AudioAnnotation = AudioAnnotation.add(annotations[i],this);
					this._annotationArea.addChild(newAnnotation);
				}
			} catch (e:Error) {
				trace("FIX ME");
			}
			redrawAnnotations();
		}
		
		public function redrawAnnotations():void {
			if(_audioView) {
				var maxLevel:Number = AudioAnnotation.redraw(_audioView.getDuration(),_timeline.width,0,_timeline.y-8);
				this._maxLevel = maxLevel;
				AudioAnnotation.redraw(_audioView.getDuration(),_timeline.width,0,_timeline.y-8);
				_audioView.changeTimelineSize(maxLevel);
			}
			redrawBubbles();
		}
		
		public function annotationClicked(annotation:DisplayObject):void {
			movePos(annotation.x);
		}
		
		public function addAnnotationBubble(annotation:AudioAnnotation):void {
			//trace("ADDING A ANNOTATION BUBBLE"+annotation);
			var alreadyExists:Boolean = false;
			if(_annotaterView.annotations.numChildren > 0) {
				for(var i:Number=0; i<_annotaterView.annotations.numChildren; i++) {
					if((_annotaterView.annotations.getChildAt(i) as AnnotationBubble).theAnnotation == annotation) {
						alreadyExists = true;
						break;
					}
				}
			}
			if(!alreadyExists) {
				var newBubble:AnnotationBubble = new AnnotationBubble(annotation,this);
				_annotaterView.annotations.addChild(newBubble);
				newBubble.x = Math.floor(annotation.x)+_timeline.x+this.x;
				newBubble.y =  _annotaterView.getYLevelHeight(annotation.yLevel,_maxLevel)+10;
			}
		}
		
		public function removeExistingBubbles():void {
			if(_annotaterView) {
				for(var i:Number=_annotaterView.annotations.numChildren-1; i>-1; i--) {
					_annotaterView.annotations.removeChildAt(i);
				}
			}
		}
		
		public function redrawBubbles(maxLevel:Number=4):void {
			//_maxLevel = maxLevel;
			removeExistingBubbles();
			for(var i:Number=0; i<this._annotationArea.numChildren; i++) {
				(this._annotationArea.getChildAt(i) as AudioAnnotation).forceResetHighlight(_timelineHead.x);
			}
		}
		
		public function removeAnnotationBubble(annotation:AudioAnnotation):void {
			for(var i:Number=0; i<_annotaterView.annotations.numChildren; i++) {
				if((_annotaterView.annotations.getChildAt(i) as AnnotationBubble).theAnnotation == annotation) {
					_annotaterView.annotations.removeChildAt(i);
					break;
				}
			}
		}
	}
}