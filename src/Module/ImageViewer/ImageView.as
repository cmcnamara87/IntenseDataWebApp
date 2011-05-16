package Module.ImageViewer {
	
	import Lib.it.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;

	public class ImageView extends UIComponent {
		
		public var annotationSave:Function;
		public var annotationDelete:Function;
		private var _UI:ImageUI;
		private var _source:String = "";
		private var _annotationEnabled:Boolean = false;
		private var _loaded:Boolean = false;
		private var _mouseMoveTimer:Timer = new Timer(30);
		private var lastMouseX:Number = 0;
		private var lastMouseY:Number = 0;
		private var annotations:Array = new Array();
		private var newAnnotation:NewImageAnnotation;
		private var progressbar:ImageProgress = new ImageProgress();
		private var firstX:Number = 0;
		private var firstY:Number = 0;
		
		// Setup event listeners
		public function ImageView() {
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			this.addEventListener(Event.RESIZE,resize);
		}
		
		// Loads an image url
		public function load(url:String):void {
			_source = url;
			if(_UI && !_loaded) {
				loadImageSource();
			}
		}
		
		// Initialiser to load the UI
		private function init(e:Event):void {
			setupUI();
		}
		
		// Adds the UI and sets the width and height
		private function setupUI():void {
			this.percentHeight = 100;
			this.percentWidth = 100;
			_UI = new ImageUI();
			addChild(_UI);
			_UI.viewButton.addEventListener(MouseEvent.CLICK,switchMode);
			_UI.annotateButton.addEventListener(MouseEvent.CLICK,switchMode);
			_UI.showAnnotationButton.addEventListener(MouseEvent.CLICK,toggleAnnotations);
			_UI.listAnnotationButton.addEventListener(MouseEvent.CLICK,toggleSidebar);
			_UI.zoomScroller.addEventListener(Event.CHANGE,zoomChanged);
			_UI.fullSizeButton.addEventListener(MouseEvent.CLICK,zoomFull);
			_UI.fitScreenButton.addEventListener(MouseEvent.CLICK,zoomFit);
			_UI.viewButton.selected = true;
			if(_source != "" && !_loaded) {
				loadImageSource();
			}
		}
		
		// Loads the image and sets up event listeners for it
		private function loadImageSource():void {
			_UI.img.source = _source;
			_UI.addElement(progressbar);
			_UI.img.addEventListener(ProgressEvent.PROGRESS,progressUpdate);
			_UI.img.addEventListener(Event.COMPLETE,sourceLoaded);
			_loaded = true;
		}
		
		// Adds multiple annotations
		public function addAnnotations(annotations:Array):void {
			for(var i:Number=0; i<annotations.length; i++) {
				addAnnotation(annotations[i]);
			}
		}
		
		// Updates the progress bar loading
		private function progressUpdate(e:ProgressEvent):void {
			var percentLoaded:Number = Math.round(e.bytesLoaded / e.bytesTotal * 100);
			progressbar.setPercentage(percentLoaded);
		}
		
		// Image loaded callback, removes the progress bar and sets up mouse listeners
		private function sourceLoaded(e:Event):void {
			if(_UI.contains(progressbar)) {
				_UI.removeElement(progressbar);
			}
			_mouseMoveTimer.addEventListener(TimerEvent.TIMER,mouseMove);
			_UI.img.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
			setZoom(100);
		}
		
		// Adds an annotation to the array and calls redraw
		private function addAnnotation(data:Object):void {
			var tmpAnnotation:ImageAnnotation = new ImageAnnotation(data);
			tmpAnnotation.addEventListener(Event.UNLOAD,deleteAnnotation);
			tmpAnnotation.redraw();
			annotations.push(tmpAnnotation);
			redrawAnnotations();
		}
		
		// Deletes the annotation
		private function deleteAnnotation(e:Event):void {
			annotations.splice(annotations.indexOf(e.target),1);
			annotationDelete((e.target as ImageAnnotation).getID());
			redrawAnnotations();
		}
		
		// Redraws all the annotations on screen
		private function redrawAnnotations():void {
			for(var i:Number=_UI.annotationarea.numChildren-1; i>-1; i--) {
				_UI.annotationarea.removeChildAt(i);
			}
			for(var j:Number=0; j<annotations.length; j++) {
				_UI.annotationarea.addChild(annotations[j]);
				(annotations[j] as ImageAnnotation).redraw();
				annotations[j].x = annotations[j].data.x*_UI.annotationarea.width;
				annotations[j].y = annotations[j].data.y*_UI.annotationarea.height;
			}
		}
		
		// For Scrolling
		private function mouseDown(e:MouseEvent):void {
			_mouseMoveTimer.start();
			lastMouseX = _UI.imagearea.mouseX;
			lastMouseY = _UI.imagearea.mouseY;
			_UI.img.addEventListener(MouseEvent.MOUSE_OUT,mouseUp);
			_UI.img.addEventListener(MouseEvent.MOUSE_UP,mouseUp);
			if(!_UI.viewButton.selected) {
				firstX = _UI.annotationarea.mouseX;
				firstY = _UI.annotationarea.mouseY;
			}
		}
		
		// For Scrolling and adding a new annotation
		private function mouseUp(e:MouseEvent):void {
			_UI.annotationarea.graphics.clear();
			if(_UI.img.hasEventListener(MouseEvent.MOUSE_OUT)) {
				_UI.img.removeEventListener(MouseEvent.MOUSE_OUT,mouseUp);
			}
			if(_UI.img.hasEventListener(MouseEvent.MOUSE_UP)) {
				_UI.img.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
			}
			_mouseMoveTimer.stop();
			if(!_UI.viewButton.selected) {
				createAnnotation();
			}
		}
		
		// Removes an incomplete annotation
		private function clearNewAnnotation():void {
			if(newAnnotation) {
				if(_UI.annotationarea.contains(newAnnotation)) {
					_UI.annotationarea.removeChild(newAnnotation);
				}
				if(newAnnotation.hasEventListener(Event.COMPLETE)) {
					newAnnotation.removeEventListener(Event.COMPLETE,annotationSaved);
				}
			}
			newAnnotation = null;
		}
		
		// Starts the creation of a new annotation
		private function createAnnotation():void {
			clearNewAnnotation();
			var annWidth:Number = Math.abs(firstX-_UI.annotationarea.mouseX);
			var annHeight:Number = Math.abs(firstY-_UI.annotationarea.mouseY);
			newAnnotation = new NewImageAnnotation(annWidth,annHeight);
			newAnnotation.addEventListener(Event.COMPLETE,annotationSaved);
			_UI.annotationarea.addChild(newAnnotation);
			newAnnotation.x = (_UI.annotationarea.mouseX+firstX)/2;
			newAnnotation.y = (_UI.annotationarea.mouseY+firstY)/2;
		}
		
		// Sends the annotation to the controller and adds it to the annotations array
		private function annotationSaved(e:Event):void {
			var dataArray:Array = new Array();
			var data:Object = new Object();
			data.x = newAnnotation.x/_UI.img.width;
			data.y = newAnnotation.y/_UI.img.height;
			data.width = newAnnotation.annotationWidth;
			data.height = newAnnotation.annotationHeight;
			data.path = "";
			data.text = newAnnotation.getText();
			dataArray.push(data);
			annotationSave(dataArray);
			clearNewAnnotation();
			addAnnotation(data);
		}
		
		// For scrolling
		private function mouseMove(e:TimerEvent):void {
			if(_UI.viewButton.selected) {
				dragImage();
			} else {
				var annWidth:Number = (firstX-_UI.annotationarea.mouseX)*-1;
				var annHeight:Number = (firstY-_UI.annotationarea.mouseY)*-1;
				_UI.annotationarea.graphics.clear();
				_UI.annotationarea.graphics.lineStyle(1,0xFFFFFF);
				_UI.annotationarea.graphics.beginFill(0xFF0000,0.4);
				_UI.annotationarea.graphics.drawRect(firstX,firstY,annWidth,annHeight);
			}
		}
		
		// For scrolling
		private function dragImage():void {
			var xDiff:Number = _UI.imagearea.mouseX-lastMouseX;
			var yDiff:Number = _UI.imagearea.mouseY-lastMouseY;
			if(_UI.img.width > _UI.imagearea.width-18) {
				_UI.imagearea.horizontalScrollPosition -= xDiff;
			}
			if(_UI.img.height > _UI.imagearea.height-18) {
				_UI.imagearea.verticalScrollPosition -= yDiff;
			}
			lastMouseX = _UI.imagearea.mouseX;
			lastMouseY = _UI.imagearea.mouseY;
		}
		
		// Switches between scrolling and annotation mode
		private function switchMode(e:MouseEvent):void {
			if(e.target == _UI.viewButton) {
				clearNewAnnotation();
				_UI.viewButton.selected = true;
				_UI.annotateButton.selected = false;
				_annotationEnabled = false;
			} else {
				_UI.viewButton.selected = false;
				_UI.annotateButton.selected = true;
				_annotationEnabled = true;
			}
		}
		
		//This toggles whether annotations show up
		private function toggleAnnotations(e:MouseEvent):void {
			if(_UI.showAnnotationButton.label == "Show Annotations") {
				_UI.showAnnotationButton.label = "Hide Annotations";
				_UI.annotationarea.alpha = 1;
			} else {
				_UI.showAnnotationButton.label = "Show Annotations";
				_UI.annotationarea.alpha = 0;
			}
		}
		
		//Shows and hides the annotation list
		private function toggleSidebar(e:MouseEvent):void {
			if(_UI.annotationsidebar.width > 0) {
				_UI.listAnnotationButton.label = "Show Annotations List";
				Tweener.addTween(_UI.annotationsidebar,{width:0,time:1,onUpdate:resize});
			} else {
				_UI.listAnnotationButton.label = "Hide Annotations List";
				Tweener.addTween(_UI.annotationsidebar,{width:200,time:1,onUpdate:resize});
			}
			setZoom(_UI.zoomScroller.value);
			setZoom(100);
		}
		
		//Set the zoom level to 100%
		private function zoomFull(e:MouseEvent):void {
			setZoom(100);
		}
		
		//Set the zoom level to fit the screen
		private function zoomFit(e:MouseEvent):void {
			var widthPercent:Number = (_UI.imagearea.width-18)/(_UI.img.content.width);
			var heightPercent:Number = (_UI.imagearea.height-18)/(_UI.img.content.height);
			if(widthPercent < heightPercent) {
				setZoom(widthPercent*100);
			} else {
				setZoom(heightPercent*100);
			}
		}
		
		// Change the zoom level based on e.value
		private function zoomChanged(e:Event):void {
			setZoom(_UI.zoomScroller.value,false);
		}
		
		// Sets the zoom level of the image
		private function setZoom(percentage:Number,updateSlider:Boolean=true):void {
			_UI.img.width = _UI.img.content.width*(percentage/100);
			_UI.img.height = _UI.img.content.height*(percentage/100);
			if(_UI.img.width < _UI.imagearea.width-18) {
				_UI.img.x = (_UI.imagearea.width-_UI.img.width)/2;
			} else {
				_UI.img.x = 0;
			}
			if(_UI.img.height < _UI.imagearea.height-18) {
				_UI.img.y = (_UI.imagearea.height-_UI.img.height)/2;
			} else {
				_UI.img.y = 0;
			}
			_UI.annotationarea.x = _UI.img.x;
			_UI.annotationarea.y = _UI.img.y;
			_UI.annotationarea.width = _UI.img.width;
			_UI.annotationarea.height = _UI.img.height;
			if(updateSlider) {
				_UI.zoomScroller.value = percentage;
			}
			redrawSidebar();
			redrawAnnotations();
		}
		
		// Redraws the sidebar
		private function redrawSidebar():void {
			trace("REDRAWING");
			_UI.annotationsidebar.removeAllElements();
			for(var i:Number=0; i<annotations.length; i++) {
				_UI.annotationsidebar.addChild((annotations[i] as ImageAnnotation).annotationSideLabel);
				//(annotations[i] as ImageAnnotation).redrawSidebarLabel();
			}
		}
		
		// Resizes the module
		private function resize(e:Event=null):void {
			_UI.width = this.width;
			_UI.height = this.height;
			progressbar.x = _UI.width/2 - progressbar.width/2;
			progressbar.y = _UI.height/2 - progressbar.height/2;
			if(_UI.img.width < _UI.imagearea.width-18) {
				_UI.img.x = (_UI.imagearea.width-_UI.img.width)/2;
			} else {
				_UI.img.x = 0;
			}
			if(_UI.img.height < _UI.imagearea.height-18) {
				_UI.img.y = (_UI.imagearea.height-_UI.img.height)/2;
			} else {
				_UI.img.y = 0;
			}
			_UI.annotationarea.x = _UI.img.x;
			_UI.annotationarea.y = _UI.img.y;
		}
	}
}