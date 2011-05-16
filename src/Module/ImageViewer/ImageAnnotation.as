package Module.ImageViewer {
	
	import Model.Model_Commentary;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.containers.HBox;
	import mx.controls.Image;
	import mx.core.UIComponent;
	
	public class ImageAnnotation extends UIComponent {
		
		public var data:Object;
		private var _mouseOvered:Boolean = false;
		private var annotationDetail:Sprite = new Sprite();
		private var annotationTextField:TextField = new TextField();
		private var annotationTextFormat:TextFormat = new TextFormat();
		public var annotationSideLabel:UIComponent = new UIComponent();
		private var annotationDelete:UIComponent = new UIComponent();
		private var annotationSideLabelTextField:TextField = new TextField();
		private var annotationSideLabelTextFormat:TextFormat = new TextFormat();
		private var annotationWidth:Number = 20;
		private var annotationHeight:Number = 20;
		
		[Embed(source="Assets/Template/deleteannotation.png")] 
		private static var Delete_icon:Class;
		private static var Delete_icon_data:BitmapData = (new Delete_icon as Bitmap).bitmapData;
		[Embed(source="/Assets/Fonts/Helvetica.ttf", fontFamily="Helvetica", embedAsCFF="false")]
		public var textfieldFont:String;
		
		public function ImageAnnotation(_data:Object) {
			data = _data;
			this.addEventListener(MouseEvent.MOUSE_OVER,showAnnotation);
			this.addEventListener(MouseEvent.MOUSE_OUT,hideAnnotation);
			super();
			setupText();
			if(data.width > 0) {
				annotationWidth = data.width;
			}
			if(data.height > 0) {
				annotationHeight = data.height;
			}
			setupSidebarLabel();
		}
		
		// Sets up the label for the sidebar
		private function setupSidebarLabel():void {
			annotationSideLabel.height = 40;
			annotationSideLabel.addEventListener(MouseEvent.MOUSE_OVER,showAnnotation);
			annotationSideLabel.addEventListener(MouseEvent.MOUSE_OUT,hideAnnotation);
			annotationSideLabel.addEventListener(Event.ADDED_TO_STAGE,sidebarStartResize);
			annotationSideLabel.addEventListener(Event.REMOVED_FROM_STAGE,sidebarStopResize);
			annotationSideLabel.addChild(annotationSideLabelTextField);
			annotationSideLabelTextFormat.font = "Helvetica";
			annotationSideLabelTextField.embedFonts = true;
			annotationSideLabelTextField.selectable = false;
			annotationSideLabelTextField.y = 10;
			annotationSideLabelTextField.x = 10;
			annotationSideLabelTextFormat.size = 14;
			annotationSideLabelTextField.setTextFormat(annotationSideLabelTextFormat);
			annotationSideLabelTextField.defaultTextFormat = annotationSideLabelTextFormat;
		}
		
		private function sidebarStartResize(e:Event):void {
			annotationSideLabel.parent.addEventListener(flash.events.Event.RESIZE,resizeSidebar);
		}
		
		private function sidebarStopResize(e:Event):void {
			annotationSideLabel.parent.removeEventListener(flash.events.Event.RESIZE,resizeSidebar);
		}
		
		private function resizeSidebar(e:Event):void {
			annotationSideLabelTextField.text = annotationTextField.text;
			redrawSidebarLabel();
		}
		
		// Redraws the sidebar label
		public function redrawSidebarLabel():void {
			annotationSideLabel.graphics.clear();
			annotationSideLabel.graphics.beginFill(0xF9F9F9,1);
			annotationSideLabel.graphics.drawRect(0,0,annotationSideLabel.parent.width-2,annotationSideLabel.height);
			annotationSideLabel.graphics.lineStyle(1,0xb9b9bb,1);
			annotationSideLabel.graphics.moveTo(0,annotationSideLabel.height);
			annotationSideLabel.graphics.lineTo(annotationSideLabel.parent.width-2,annotationSideLabel.height);
			annotationSideLabelTextField.width = annotationSideLabel.parent.width - 20;
		}
		
		// Sets up the text of the annotation
		private function setupText():void {
			annotationTextField.embedFonts = true;
			annotationTextField.text = data.text;
			annotationTextField.selectable = false;
			annotationTextField.mouseEnabled = false;
		
			annotationTextField.antiAliasType = AntiAliasType.ADVANCED;
			annotationTextField.setTextFormat(annotationTextFormat)
			annotationTextField.width = annotationTextField.textWidth+20;
			annotationTextField.height = annotationTextField.textHeight;
			annotationTextField.y = 7;
		
			annotationTextFormat.size = 18;
			annotationTextFormat.color = 0xFFFFFF;
			annotationTextFormat.align = TextFormatAlign.CENTER;
			annotationTextFormat.font = "Helvetica";
			annotationTextField.defaultTextFormat = annotationTextFormat;
			
			annotationDetail.addChild(annotationTextField);
			annotationDetail.mouseEnabled = false;
			annotationDetail.mouseChildren = false;
			
			annotationDelete.graphics.beginBitmapFill(Delete_icon_data);
			annotationDelete.graphics.drawRect(0,0,20,20);
			annotationDelete.addEventListener(MouseEvent.MOUSE_UP,deleteAnnotation);
			this.addChild(annotationDelete);
		}
		
		// Redraws the annotation background highlight
		public function redraw():void {
			this.graphics.clear();
			this.graphics.lineStyle(1,0xFFFFFF,1);
			if(_mouseOvered) {
				this.graphics.beginFill(0xFF0000,1);
				annotationDelete.alpha = 1;
				annotationDelete.mouseEnabled = true;
				annotationDelete.x = annotationWidth/2-10;
				annotationDelete.y = 0-annotationHeight/2-10;
			} else {
				annotationDelete.alpha = 0;
				annotationDelete.mouseEnabled = false;
				this.graphics.beginFill(0x000000,0.2);
			}
			this.graphics.drawRect(0-annotationWidth/2,0-annotationHeight/2,annotationWidth,annotationHeight);
			annotationDetail.x = 0-(annotationTextField.textWidth+20)/2;
			annotationDetail.y = -70;
			annotationDetail.graphics.clear();
			annotationDetail.graphics.lineStyle(1,0xFFFFFF,1);
			annotationDetail.graphics.beginFill(0x000000);
			annotationDetail.graphics.drawRect(0,0,annotationTextField.textWidth+20,40);
		}
		
		// Returns the annotation ID
		public function getID():Number {
			return data.base_asset_id;
		}
		
		// Calls to delete the annotation
		private function deleteAnnotation(e:MouseEvent):void {
			this.dispatchEvent(new Event(Event.UNLOAD));
		}
		
		// Shows the text for the annotation
		private function showAnnotation(e:MouseEvent):void {
			this.parent.setChildIndex(this,this.parent.numChildren-1);
			_mouseOvered = true;
			addChild(annotationDetail);
			redraw();
		}
		
		// Hides the text for the annotation
		private function hideAnnotation(e:MouseEvent):void {
			_mouseOvered = false;
			if(contains(annotationDetail)) {
				removeChild(annotationDetail);
			}
			redraw();
		}
	}
}