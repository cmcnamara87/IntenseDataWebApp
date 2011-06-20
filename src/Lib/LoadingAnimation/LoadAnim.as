/*
http://todepoint.com/blog/2010/07/22/spinning_animation-as3/
*/

package Lib.LoadingAnimation {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.core.UIComponent;
	
	public class LoadAnim extends UIComponent{
		
		private static var _instance:LoadAnim;
		private static var _parent:*;
		
		private var _anim		:Sprite;
		private var _rotate		:Number = 0;
		private var _animTimer	:Timer;
		private var _animColor	:Number;
		private var _zoom		:Number = 1;
		
		public static function show(parent:*,xPos:Number=0,yPos:Number=0,color:Number=0x000000,zoom:Number=0):void {
			if(_instance) {
				_instance._animColor = color;
			} else {
				_instance = new LoadAnim(color,new SingletonEnforcer());
			}
			_parent = parent;
			_instance._zoom = zoom;
			_instance.x = xPos;
			_instance.y = yPos;
			_parent.addElement(_instance);
			trace("LoadAnim:show - Adding element");
//			if(parent.addElement) {
//				trace("LoadAnim:show - Adding element");
//				_parent.addElement(_instance);
//			} else {
//				_parent.addChild(_instance);
//			}
		}
		
		public static function hide():void {
			if(_instance) {
				if(_parent) {
					if(_parent.addElement) {
						_parent.removeElement(_instance);
					} else {
						_parent.removeChild(_instance);
					}
					_parent = null;
				}
			}
		}
		
		public function LoadAnim(color:Number = 0xFFFFFF,singletonEnforcer:SingletonEnforcer=null) 
		{
			if(!singletonEnforcer) {
				trace("ERROR BAD SINGLETON ON ANIMATION");
			} else {
				_animColor = color;
				_anim = new Sprite();
				addChild(_anim);
				makeAnim();
			}
		}
		public function stopAnim():void
		{
			removeChild(_anim);
			_animTimer.removeEventListener(TimerEvent.TIMER, rotateMe);
			_animTimer.stop();
		}
		private function makeAnim():void
		{
			renderAnime();
			
			_animTimer = new Timer(70);
			_animTimer.addEventListener(TimerEvent.TIMER, rotateMe);
			_animTimer.start();
			
		}
		private function rotateMe(evt:TimerEvent):void
		{
			
			_rotate = _rotate + 30;
			if(_rotate == 360)_rotate = 0;
			//trace("timer " + _rotate);
			renderAnime(_rotate);
		}
		private function renderAnime(startAng:Number = 0):void
		{
			clearAnim();
			var theStar:Sprite = new Sprite()
			for(var i:uint = 0; i <= 12; i++){
				var theShape:Sprite = getShape();
				theShape.rotation = (i * 30) + startAng;
				theShape.alpha = 0 + (1/12 * i);
				theStar.addChild(theShape);
			}
			_anim.addChild(theStar);
		}
		private function clearAnim():void
		{
			if( _anim.numChildren == 0 ) return;
			_anim.removeChildAt(0);
		}
		private function getShape():Sprite
		{
			var shape:Sprite = new Sprite();
			shape.graphics.beginFill(_animColor, 1);
			shape.graphics.moveTo(-1*_zoom, -12*_zoom);
			shape.graphics.lineTo(2*_zoom, -12*_zoom);
			shape.graphics.lineTo(1*_zoom, -5*_zoom);
			shape.graphics.lineTo(0*_zoom, -5*_zoom);
			shape.graphics.lineTo(-1*_zoom, -12*_zoom);
			shape.graphics.endFill();
			return shape;
		}
	}
}

class SingletonEnforcer { }