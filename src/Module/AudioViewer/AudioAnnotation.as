package Module.AudioViewer
{
	import Lib.hybrid.ui.ToolTip;
	
	import Model.Model_Commentary;
	
	import View.ERA.components.TimelineAnnotation;
	import View.components.IDGUI;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.*;
	
	import mx.core.UIComponent;

	public class AudioAnnotation extends UIComponent {
		
		static private var annotationsArray:Array = new Array();
		static private var currentAnnotations:Array = new Array();
		static private var colours:Array = new Array(
			/*0xFF0000,0x0000FF,0x226666,0xC71585,0x009A9A,0xFF8C00,0x4B0082*/
			0xFF0000, 0xFF8800, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF
		);
		static private var colourChosen:Number = 0;
		static private var levelSpace:Number = -8;
		
		
		public static var isBeingMouseOvered:Boolean = false;
		
		
		static public function getColour():uint {
			var tmpcolour:Number = colourChosen;
			colourChosen++;
			if(colourChosen == colours.length) {
				colourChosen = 0;
			}
			return colours[tmpcolour];
		}
		
		static public function add(data:Model_Commentary,_interface:AudioTimeline):AudioAnnotation {
			var newAnnotation:AudioAnnotation = new AudioAnnotation(data,_interface);
			annotationsArray.push(newAnnotation);
			return newAnnotation;
		}
		
		// CRAIG FUNCTION
		// Clears all current annotations
		static public function clearAllAnnotations():void {
			annotationsArray = new Array();
			trace("Clearing all annotations");
		}
		static public function highlightAnnotations(theX:Number):void {
			for(var i:int=0; i<annotationsArray.length; i++) {
				(annotationsArray[i] as AudioAnnotation).checkCurrentAudioPosition(theX);
				(annotationsArray[i] as AudioAnnotation).timelineAnnotation.highlight = true;
			}
		}
		
		static public function redraw(audioLength:Number,interfaceWidth:Number,xOffset:Number=0,yOffset:Number=0):Number {
			currentAnnotations = new Array();
			var maxLevel:Number = 0;
			for(var i:int=0; i<annotationsArray.length; i++) {
				var yLevel:Number = 0;
				var foundLevel:Boolean = false;
				while(!foundLevel) {
					var foundOverlap:Boolean = false;
					for(var j:Number=0; j<currentAnnotations.length; j++) {
						//check if whats there is on the same level as were trying for
						if(currentAnnotations[j].yLevel == yLevel) {
							if((annotationsArray[i].start >= currentAnnotations[j].start && annotationsArray[i].start <= currentAnnotations[j].end) || (annotationsArray[i].end >= currentAnnotations[j].start && annotationsArray[i].end <= currentAnnotations[j].end)) {
								yLevel++;
								foundOverlap = true;
							}
						}
					}
					if(!foundOverlap) {
						foundLevel = true;
						if(yLevel > maxLevel) {
							maxLevel = yLevel;
						}
					}
				}
				annotationsArray[i].yLevel = yLevel;
				annotationsArray[i].draw(audioLength,interfaceWidth,xOffset, yOffset+yLevel*levelSpace);
				(annotationsArray[i] as DisplayObject).parent.setChildIndex(annotationsArray[i],0);
				currentAnnotations.push(annotationsArray[i]);
			}
			for(var lvl:Number=0; lvl<=maxLevel; lvl++) {
				for(var k:int=0; k<annotationsArray.length; k++) {
					if(annotationsArray[k].yLevel == lvl) {
						(annotationsArray[k] as DisplayObject).parent.setChildIndex(annotationsArray[k],0);
					}
				}
			}
			return maxLevel+1;
		}
		
		public var start:Number;
		public var end:Number;
		public var length:Number;
		public var text:String;
		public var yLevel:Number = 0;
		public var _annotationColour:uint = 0x336699;
		private var _hightlighted:Boolean = false;
		private var _audioLength:Number;
		private var _interfaceWidth:Number;
		private var _data:Model_Commentary;
		private var _interface:AudioTimeline;
		private var _mouseOverSprite:Sprite = new Sprite();
		
		// The new border container based timeline annotation
		// supports download button
		public var timelineAnnotation:TimelineAnnotation = new TimelineAnnotation();
		
		
		
		public function AudioAnnotation(data:Model_Commentary,_interface:AudioTimeline) {
			_annotationColour = AudioAnnotation.getColour();
			this._interface = _interface;
			setData(data);
			this.toolTip = data.text;
			addChild(_mouseOverSprite); 
			_mouseOverSprite.alpha = 0;
			
			timelineAnnotation.startTime = data.annotation_x;
			timelineAnnotation.endTime = data.annotation_y;
			
			try {
				timelineAnnotation.annotationID = (data as Model_Commentary).base_asset_id;
				trace("********* audio annotation ids", timelineAnnotation.annotationID);
				timelineAnnotation.videoID = (data as Model_Commentary).objectID;
				
				trace("********* audio annotation ids",timelineAnnotation.videoID);
			} catch (e:Error) {
				trace("some error");
			}
			
			
			this.addChild(timelineAnnotation);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,annotationClicked);
			this.addEventListener(MouseEvent.MOUSE_OVER,mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,mouseOut);
		}
		
		private function setData(data:Model_Commentary):void {
			_data = data;
			start = _data.annotation_x;
			end = _data.annotation_y;
			length = _data.annotation_y - data.annotation_x;
			text = _data.annotation_text;
		}
		
		public function draw(audioLength:Number,interfaceWidth:Number,xOffset:Number=0,yOffset:Number=0):void {
			_audioLength = audioLength;
			_interfaceWidth = interfaceWidth;
			var anWidth:Number = (length/_audioLength*_interfaceWidth);
			var anHeight:Number = 8*(yLevel+1);
			var barBorderWidth:Number = 2;
			/*_mouseOverSprite.graphics.clear();
			_mouseOverSprite.graphics.beginFill(_annotationColour);
			_mouseOverSprite.graphics.drawRect(0,0,anWidth,anHeight);*/
			this.graphics.clear();
			
			/*this.graphics.beginFill(_annotationColour,0.01);
			this.graphics.drawRect(0,0,anWidth,anHeight);*/
			/*this.graphics.beginFill(_annotationColour);
			this.graphics.drawRect(barBorderWidth,0,anWidth-barBorderWidth*2,barBorderWidth);
			this.graphics.drawRect(0,0,barBorderWidth,anHeight);
			this.graphics.drawRect(anWidth-barBorderWidth,0,barBorderWidth,anHeight);*/
			this.x = xOffset+(_interfaceWidth/audioLength*(start));
			this.y = yOffset;
			this.alpha = 0.25;
			this.width = (length/_audioLength*_interfaceWidth);
			
			timelineAnnotation.x = 0;
			timelineAnnotation.y = 0
			timelineAnnotation.annotationWidth = ((end - start)/audioLength * interfaceWidth);
			timelineAnnotation.annotationHeight = anHeight;
			timelineAnnotation.annotationColor = _annotationColour;
		}
		
		private function annotationClicked(e:MouseEvent):void {
			_interface.annotationClicked(this);
			e.stopImmediatePropagation();
		}
		
		public function forceResetHighlight(posX:Number):void {
			_hightlighted = false;
			checkCurrentAudioPosition(posX);
		}
		
		public function checkCurrentAudioPosition(posX:Number):void {
			if(posX > this.x && posX < this.x+this.width) {
				//trace(posX,this.x,this.x+this.width,"YES");
//				if(!_hightlighted) {
//					_interface.addAnnotationBubble(this);	
//				}
//				this.alpha = 0.9;
//				if(_mouseOverSprite.alpha > 0) {
//					_mouseOverSprite.alpha = 0.15;
//				}
//				_hightlighted = true;
				showAnnotationBubble();
			} else {
				//trace(posX,this.x,this.x+this.width,"NO");
				hideAnnotationBubble();
//				if(_hightlighted) {
//					_interface.removeAnnotationBubble(this);	
//				}
//				this.alpha = 0.25;
//				if(_mouseOverSprite.alpha > 0) {
//					_mouseOverSprite.alpha = 0.5;
//				}
//				_hightlighted = false;
			}
		}
		
		public function showAnnotationBubble():void {
			if(!_hightlighted) {
				_interface.addAnnotationBubble(this);	
			}
			this.alpha = 0.9;
			if(_mouseOverSprite.alpha > 0) {
				_mouseOverSprite.alpha = 0.15;
			}
			_hightlighted = true;	
		}
		
		public function hideAnnotationBubble():void {
			if(!isBeingMouseOvered) {
				if(_hightlighted) {
					_interface.removeAnnotationBubble(this);	
				}
				this.alpha = 0.25;
				if(_mouseOverSprite.alpha > 0) {
					_mouseOverSprite.alpha = 0.5;
				}
				_hightlighted = false;
			}
		}
		
		private function mouseOver(e:MouseEvent):void {
			_mouseOverSprite.alpha = 0.5;
			isBeingMouseOvered = true;
			this.showAnnotationBubble();
			
		}
		
		private function mouseOut(e:MouseEvent):void {
			_mouseOverSprite.alpha = 0;
			isBeingMouseOvered = false;
			this.hideAnnotationBubble();
		}
		
		public function getID():Number {
			return _data.base_asset_id;
		}
		
	}
	
}