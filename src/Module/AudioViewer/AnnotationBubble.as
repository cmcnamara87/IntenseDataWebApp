package Module.AudioViewer
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class AnnotationBubble extends Sprite {
		
		public var theAnnotation:AudioAnnotation;
		private var annotationTextField:TextField = new TextField();
		private var annotationTextFormat:TextFormat = new TextFormat();
		private var _interface:AudioTimeline;
		
		public function AnnotationBubble(_theAnnotation:AudioAnnotation,_interface:AudioTimeline) {
			this._interface = _interface;
			theAnnotation = _theAnnotation;
			setupGraphics();
			this.mouseEnabled = false;
		}
		
		private function setupGraphics():void {
			var padding:int = 6;
			annotationTextField.text = theAnnotation.text;
			annotationTextField.selectable = false;
			annotationTextField.autoSize = TextFieldAutoSize.LEFT;
			annotationTextFormat.color = theAnnotation._annotationColour;
			annotationTextFormat.font = "Arial";
			annotationTextFormat.size = 16;
			annotationTextField.setTextFormat(annotationTextFormat);
			this.addChild(annotationTextField);
			this.graphics.beginFill(0xFFFFFF,0.8);
			this.graphics.lineStyle(2,theAnnotation._annotationColour,1);
			this.graphics.drawRoundRect(-1*padding,-1*padding,this.width+padding*2,this.height+padding*2,14);
		}
	}
}