package Module.Videoviewer {
	
	import Model.Model_Commentary;
	import Model.Model_Media;
	
	import View.ERA.components.TimelineAnnotation;
	import View.components.IDGUI;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.UIComponent;
	
	public class VideoAnnotation extends UIComponent {
		
		static private var annotationsArray:Array = new Array();
		
		static public function resetAnnotations(_videoAnnotations:Sprite = null):void {
//			killAll = true;
			while(annotationsArray.length > 0) {
				(annotationsArray.pop() as VideoAnnotation).destroyYourself();
			}
		}
		
		static public function add(data:*,_interface:VideoTimeline,_annotationColor:uint=0x336699):VideoAnnotation {
			var newAnnotation:VideoAnnotation = new VideoAnnotation(data,_interface,_annotationColor);
			annotationsArray.push(newAnnotation);
			return newAnnotation;
		}
		
		static public function showhide(newPosition:Number):void {
			for(var i:Number=0; i<annotationsArray.length; i++) {
				annotationsArray[i].showhide(newPosition);
			}
		}
		
		/**
		 * Highlights an annotation in the timeline (Only in the timeline, does not
		 * display actual annotaiton drawing.)
		 * 
		 * Changes the opacity of the fill to be more solid. 
		 * @param annotatationID	The ID of the annotation to highlight
		 * 
		 */		
		public static function highlightAnnotation(annotatationID:Number):void {
			for each(var videoAnnotation:VideoAnnotation in annotationsArray) {
				if ((videoAnnotation._data as Model_Commentary).base_asset_id == annotatationID) {
//					videoAnnotation._timelineGraphicFill.alpha = 0.8;
					videoAnnotation.timelineAnnotation.highlight = true;
					break;
				}
			}
		}
		
		/**
		 * Removes the highlight on an annotation in the timeline
		 * 
		 * Changes the opacity of the fill to be more transparent. 
		 * @param annotatationID	The ID annotation to unhighlight
		 * 
		 */		
		public static function unhighlightAnnotation(annotatationID:Number):void {
			for each(var videoAnnotation:VideoAnnotation in annotationsArray) {
				if ((videoAnnotation._data as Model_Commentary).base_asset_id == annotatationID) {
//					videoAnnotation._timelineGraphicFill.alpha = 0.1;
					videoAnnotation.timelineAnnotation.highlight = false;
					break;
				}
			}
		}
		
		static public function redraw(newTimelineWidth:Number,duration:Number,videoDimensions:Rectangle):Number {
			var forceMaxedLevel:Number = 3;
			var maxXLevel:Number = 1;
			var doneAnnotations:Array = new Array();
			
			annotationsArray.sortOn("startTime",Array.NUMERIC);
			for(var i:Number=0; i<annotationsArray.length; i++) {
				var xLevel:Number = 1;
				for(var j:Number=0; j<doneAnnotations.length; j++) {
					if(
						annotationsArray[i].startTime > doneAnnotations[j].startTime &&
						annotationsArray[i].startTime < doneAnnotations[j].endTime) {
						if(doneAnnotations[j].xLevel+1 > xLevel && xLevel - doneAnnotations[j].xLevel > -2) {
							if(xLevel > forceMaxedLevel) {
								xLevel = forceMaxedLevel;
							}
							xLevel = doneAnnotations[j].xLevel+1;
						}
					}
				}
				if(xLevel > maxXLevel) {
					maxXLevel = xLevel;
				}
				
				(annotationsArray[i] as VideoAnnotation).redrawGraphics(newTimelineWidth,duration,videoDimensions,xLevel);
				
				doneAnnotations.push(annotationsArray[i]);
			}
			return maxXLevel;
		}
		
		private var xPercentage:Number = 0;
		private var yPercentage:Number = 0;
		private var widthPercentage:Number = 0;
		private var heightPercentage:Number = 0;
		public var startTime:Number = 0;
		public var endTime:Number = 0;
		private var _data:Object = null;
		private var _interface:VideoTimeline;
		
		private var defaultWidth:Number = 0.01;
		private var defaultHeight:Number = 0.01;
		
		private var _timelineGraphic:Sprite = new Sprite();
		private var _videoGraphic:Sprite = new Sprite();
		
		public var timelineAnnotation:TimelineAnnotation = new TimelineAnnotation();
		
		private var _timelineGraphicBorder:Sprite = new Sprite();
		private var _timelineGraphicFill:Sprite = new Sprite();
		private var _videoGraphicOverlay:Sprite = new Sprite();
		private var _videoGraphicTextContainer:Sprite = new Sprite();
		private var _videoGraphicTextField:TextField = new TextField();
		private var _videoGraphicTextFormat:TextFormat = new TextFormat();
		private var annotationColor:uint = 0x336699;
		private var textfieldPadding:Number = 4;
		private var graphicHeight:Number = 10;
		public var xLevel:Number = 1;
		
		private var fuckingOverlay:Sprite;
		
		
		public function VideoAnnotation(data:*,_interface:VideoTimeline,annotationColor:uint) {
			this._interface = _interface;
			this.annotationColor = annotationColor;
			this._data = data;
			//check for invalid vars
			if(data.end == -1) { data.end = data.start+2; }
			if(data.width == -1 || data.width == 0) { data.width = defaultWidth; } else { data.width = data.width/100 }
			if(data.height == -1 || data.height == 0) { data.height = defaultHeight; }  else { data.height = data.height/100 }
			//set the variables
			this.xPercentage = data.x;
			this.yPercentage = data.y;
			this.startTime = data.start;
			this.endTime = data.end;
			trace("Displaying annotation at:", startTime, endTime);
			this.widthPercentage = data.width;
			this.heightPercentage = data.height;
			this.toolTip = data.text;
			if(widthPercentage == 0) {
				widthPercentage = defaultWidth;
			}
			if(heightPercentage == 0) {
				heightPercentage = defaultHeight;
			}
			
			timelineAnnotation.startTime = data.start;
			timelineAnnotation.endTime = data.end;
			
			try {
				timelineAnnotation.annotationID = (data as Model_Commentary).base_asset_id;
				timelineAnnotation.videoID = (data as Model_Commentary).objectID;
			} catch (e:Error) {
				trace("some error");
			}
			
			
			//draw the graphics
			addChildren();
		}
		
		public function showhide(xTest:Number):void {
			if(_timelineGraphic.x < xTest && (_timelineGraphic.x+_timelineGraphic.width) > xTest) {
				_videoGraphic.alpha = 1;
			} else {
				_videoGraphic.alpha = 0;
			}
		}
		
		private function addChildren():void {
			
			//this.addChild(_timelineGraphic);
			_timelineGraphic.addChild(_timelineGraphicFill);
			_timelineGraphic.addChild(_timelineGraphicBorder);
			_timelineGraphicFill.alpha = 0.1;
			this.addChild(timelineAnnotation);
			setupVideoGraphics();
		}
		
		public function addOverlay(screenOverlay:Sprite):void {
			fuckingOverlay = screenOverlay;
			screenOverlay.addChild(_videoGraphic);
		}
		
		public function redrawGraphics(newTimelineWidth:Number,duration:Number,videoDimensions:Rectangle,_xLevel:Number=1):void {
//			trace("**** REDRAWING ANNOTATIONS ****");

			xLevel = _xLevel;
			try {
				var variablegraphicHeight:Number = graphicHeight*(xLevel);
				if(variablegraphicHeight == 0) {
					//variablegraphicHeight = graphicHeight;
				}
				var minusY:Number = -1*(graphicHeight*(xLevel-1));
				_timelineGraphic.x = startTime/duration*newTimelineWidth;
				
				timelineAnnotation.x = startTime/duration * newTimelineWidth;
				timelineAnnotation.y = minusY;
				timelineAnnotation.annotationWidth = ((endTime-startTime)/duration*newTimelineWidth);
				timelineAnnotation.annotationHeight = variablegraphicHeight;
				timelineAnnotation.annotationColor = annotationColor;
				
				
				//endTime = startTime+10; /* DELETE */
				var newLength:Number = ((endTime-startTime)/duration*newTimelineWidth);
				resetVideoGraphic(videoDimensions);
				_timelineGraphicFill.graphics.clear();
				_timelineGraphicFill.graphics.beginFill(annotationColor,1);
				_timelineGraphicFill.graphics.drawRect(0,minusY,newLength,variablegraphicHeight);
				_timelineGraphicBorder.graphics.clear();
				_timelineGraphicBorder.graphics.lineStyle(2,annotationColor,1);
				_timelineGraphicBorder.graphics.moveTo(0,variablegraphicHeight-1+minusY);
				_timelineGraphicBorder.graphics.lineTo(0,minusY);
				_timelineGraphicBorder.graphics.lineTo(newLength,minusY);
				_timelineGraphicBorder.graphics.lineTo(newLength,variablegraphicHeight-1+minusY);
			} catch (e:Error) {
				trace("Unknown video error: "+e.message);
			}
		}
		
		private function setupVideoGraphics():void {
			_videoGraphic.addChild(_videoGraphicOverlay);
			_videoGraphicTextContainer.addChild(_videoGraphicTextField);
			_videoGraphic.addChild(_videoGraphicTextContainer);
			
			
			
			timelineAnnotation.addEventListener(MouseEvent.MOUSE_OVER,graphicMouseOver);
			timelineAnnotation.addEventListener(MouseEvent.MOUSE_OUT,graphicMouseOut);
			timelineAnnotation.annotationBox.addEventListener(MouseEvent.MOUSE_UP,annotationClick);
			_timelineGraphic.mouseChildren = false;
			
//			_videoGraphicTextField.text = _data.text;
			_videoGraphicTextField.htmlText = IDGUI.getLinkHTML(_data.text, "#000000");
			_videoGraphicTextFormat.align = TextFormatAlign.CENTER;
			_videoGraphicTextFormat.size = 16;
			_videoGraphicTextFormat.font = "Arial";
			_videoGraphicTextField.setTextFormat(_videoGraphicTextFormat);
			_videoGraphicTextField.selectable = true;
			_videoGraphicTextField.autoSize = TextFieldAutoSize.LEFT;
			_videoGraphicTextField.height = _videoGraphicTextField.textHeight;
			_videoGraphicTextField.width = _videoGraphicTextField.textWidth + 20;
			_videoGraphicTextField.wordWrap = true;
		}
		
		private function graphicMouseOver(e:MouseEvent):void {
//			_timelineGraphicFill.alpha = 0.5;
			timelineAnnotation.highlight = true;
			trace("WTFBBQ");
		}
		
		private function graphicMouseOut(e:MouseEvent):void {
			timelineAnnotation.highlight = false;
//			_timelineGraphicFill.alpha = 0.1;
		}
		
		private function annotationClick(e:MouseEvent):void {
			trace(startTime,endTime);
			_interface.annotationClicked(_timelineGraphic.x);
		}
		
		private function resetVideoGraphic(videoDimensions:Rectangle):void {
			var xOffset:Number = 0;
			var yOffset:Number = 20;
			_videoGraphic.graphics.clear();
			_videoGraphicTextContainer.graphics.clear();
			_videoGraphicOverlay.graphics.clear();
			_videoGraphic.x = videoDimensions.width*xPercentage;
			_videoGraphic.y = videoDimensions.height*yPercentage;
			//_videoGraphic.x = _data.x;
			//_videoGraphic.y = _data.y;
			_videoGraphicOverlay.graphics.lineStyle(1,annotationColor,1);
			_videoGraphicOverlay.graphics.beginFill(0x000000,0.2);
			_videoGraphicOverlay.graphics.drawRect(0,0,videoDimensions.width*widthPercentage,videoDimensions.height*heightPercentage);
			//_videoGraphicOverlay.graphics.drawRect(0,0,_data.width,_data.height);
			if(_videoGraphic.x < 20) {
				xOffset = 20;
			}
			if(_videoGraphic.x > videoDimensions.width-20) {
				xOffset = -20;
			}
			if(_videoGraphic.y > videoDimensions.height-20) {
				yOffset = -20;
			}
			_videoGraphicTextField.width = Math.min(videoDimensions.width - _videoGraphicTextField.x, _videoGraphicTextField.width); 
			_videoGraphicTextContainer.x = Math.max(0-_videoGraphicTextContainer.width/2+xOffset+_videoGraphicOverlay.width/2+textfieldPadding, 0 - _videoGraphic.x);
			_videoGraphicTextContainer.y = 0-_videoGraphicTextContainer.height/2+yOffset+_videoGraphicOverlay.height/2+(textfieldPadding*2);
			_videoGraphicTextContainer.graphics.lineStyle(2,annotationColor,1);
			_videoGraphicTextContainer.graphics.beginFill(0xFFFFFF,0.8);
			_videoGraphicTextContainer.graphics.drawRoundRect(_videoGraphicTextField.x-textfieldPadding,_videoGraphicTextField.y-textfieldPadding,_videoGraphicTextField.width+(textfieldPadding*2),_videoGraphicTextField.height+(textfieldPadding*2),14);
			_videoGraphic.graphics.endFill();
			_videoGraphic.graphics.lineStyle(2,annotationColor,1);
			_videoGraphic.graphics.moveTo(_videoGraphicOverlay.width/2,_videoGraphicOverlay.height/2);
			_videoGraphic.graphics.lineTo(_videoGraphicTextContainer.x+_videoGraphicTextContainer.width/2-(textfieldPadding/2),_videoGraphicTextContainer.y+_videoGraphicTextContainer.height/2);
		}
		
		private function destroyYourself():void {
			if(_videoGraphic.parent) {
				_videoGraphic.parent.removeChild(_videoGraphic);
			}
			if(_timelineGraphic.parent) {
				_timelineGraphic.parent.removeChild(_timelineGraphic);
			}
		}
	}
}