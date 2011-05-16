package View.Element {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	
	public class RecensioUIComponent extends UIComponent {
		
		[Embed(source="/Assets/Fonts/Helvetica.ttf", fontFamily="Helvetica", embedAsCFF="false")]
		public var textfieldFont:String;
		
		[Embed(source="/Assets/Fonts/Helvetica.ttf", fontFamily="HelveticaEmbed", embedAsCFF="true")]
		public var textfieldFontEmbed:String;
		
		[Embed(source="/Assets/Fonts/HelveticaBold.ttf", fontFamily="HelveticaBold", fontWeight='bold', embedAsCFF="false")]
		public var textfieldFontBold:String;
		
		protected var button:Boolean = false;
		
		// Sets up the event listeners for adding and removing from stage
		public function RecensioUIComponent() {
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,init);
			this.addEventListener(Event.REMOVED_FROM_STAGE,dealloc);
		}
		
		// Sets up the display object to act like a button
		protected function setButtonMode(newButtonMode:Boolean):void {
			this.button = newButtonMode;
			if(!newButtonMode) {
				if(this.hasEventListener(MouseEvent.MOUSE_OVER)) {
					this.removeEventListener(MouseEvent.MOUSE_OVER,mouseOver);
				}
				if(this.hasEventListener(MouseEvent.MOUSE_OUT)) {
					this.removeEventListener(MouseEvent.MOUSE_OUT,mouseOut);
				}
				if(this.hasEventListener(MouseEvent.MOUSE_DOWN)) {
					this.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
				}
				if(this.hasEventListener(MouseEvent.MOUSE_UP)) {
					this.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
				}
			}
		}
		
		// Called when added to stage (sets up button if appropriate, and listens for resizes)
		protected function init(e:Event):void {
			this.stage.addEventListener(Event.RESIZE,resize);
			this.parent.addEventListener(Event.RESIZE,resize);
			if(button) {
				this.addEventListener(MouseEvent.MOUSE_OVER,mouseOver);
				this.addEventListener(MouseEvent.MOUSE_OUT,mouseOut);
				this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
				this.addEventListener(MouseEvent.MOUSE_UP,mouseUp);
			}
			setTimeout(resize,50);
		}
		
		// Called when removed from stage
		protected function dealloc(e:Event):void {
			this.stage.removeEventListener(Event.RESIZE,resize);
			this.parent.removeEventListener(Event.RESIZE,resize);
			if(button) {
				this.removeEventListener(MouseEvent.MOUSE_OVER,mouseOver);
				this.removeEventListener(MouseEvent.MOUSE_OUT,mouseOut);
				this.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
				this.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
			}
		}
		
		// Called when buttonMode is set (should be overridden)
		protected function mouseOver(e:MouseEvent):void {
			
		}
		
		// Called when buttonMode is set (should be overridden)
		protected function mouseOut(e:MouseEvent):void {
			
		}
		
		// Called when buttonMode is set (should be overridden)
		protected function mouseDown(e:MouseEvent):void {
			
		}
		
		// Called when buttonMode is set (should be overridden)
		protected function mouseUp(e:MouseEvent):void {
			
		}
		
		// Called when the screen size has changed (calls draw)
		protected function resize(e:Event=null):void {
			draw();
		}
		
		// Force calls draw
		public function forceResize():void {
			draw();
		}
		
		// Calls the draw (should be overriden)
		protected function draw():void {
			
		}
		
		// Removes all children of the display object
		public function removeAllChildren():void {
			for(var i:Number=this.numChildren-1; i>=0; i--) {
				try {
					this.removeChildAt(i);
				} catch (e:Error) {
				}
			}
		}
	}
}