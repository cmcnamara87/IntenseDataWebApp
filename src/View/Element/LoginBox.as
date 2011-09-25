package View.Element {
	import Controller.IDEvent;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	
	public class LoginBox extends RecensioUIComponent {
		
		public var usernameBox:TextBox;
		public var passwordBox:TextBox;
		public var loginbutton:RoundButton;
		private var padding:Number = 10;
		private var textBoxHeight:Number = 50;
		private var notification:TextField;
		
		public function LoginBox() {
			super();
			//var myDropshadow:DropShadowFilter = new DropShadowFilter(3,90,0x999999);
			//this.filters = new Array(myDropshadow);
			setupTextFields();
			setupLoginButton();
		}
		
		// INIT
		override protected function init(e:Event):void {
			this.parent.addEventListener(MouseEvent.MOUSE_UP,loseLoginFocus);
			loginbutton.addEventListener(MouseEvent.MOUSE_UP,loginClicked);
			super.init(e);
		}
		
		// When the login box loses focus
		private function loseLoginFocus(e:MouseEvent):void {
			if(e.target == this.parent) {
				this.stage.focus = this;
			}
		}
		
		// Redraw/reposition
		override protected function draw():void {
			this.graphics.clear();
//			this.graphics.beginFill(0xdddddf);
//			this.graphics.lineStyle(1,0xc7c7c9);
//			this.graphics.drawRoundRect(0-width/2,0-height/2,width,height,12);
			usernameBox.width = this.width-padding*2;
			usernameBox.height = textBoxHeight;
			usernameBox.x = 0-this.width/2+padding;
			usernameBox.y = 0-this.height/2+padding;
			passwordBox.width = usernameBox.width;
			passwordBox.height = usernameBox.height;
			passwordBox.x = usernameBox.x;
			passwordBox.y = (0-this.height/2)+(padding*2+usernameBox.height);
			loginbutton.x = this.width/2-loginbutton.width/2-padding;
			loginbutton.y = this.height/2-loginbutton.height/2-padding;
			notification.x = 0-this.width/2+padding; 
			notification.y = this.height/2-notification.height;
		}
		
		// Sets up the username and password text fields (and the login button)
		private function setupTextFields():void {
			usernameBox = new TextBox();
			usernameBox.setDefaultText("username");
			this.addChild(usernameBox);
			passwordBox = new TextBox();
			passwordBox.setDefaultText("password");
			passwordBox.showAsPassword(true);
			this.addChild(passwordBox);
			usernameBox.addEventListener(KeyboardEvent.KEY_DOWN,textKeyPressed);
			passwordBox.addEventListener(KeyboardEvent.KEY_DOWN,textKeyPressed);
			notification = new TextField();
			notification.height = 41;
			notification.width = 300;
			notification.selectable = false;
			notification.embedFonts = true;
			this.addChild(notification);
		}
		
		// Shows a notification (error)
		public function setNotification(notificationString:String):void {
			notification.text = notificationString;
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Helvetica";
			textFormat.color = 0xFF0000;
			textFormat.size = 16;
			notification.setTextFormat(textFormat);
		}
		
		// Sets up the login button
		private function setupLoginButton():void {
			loginbutton = new RoundButton();
			loginbutton.width = 111;
			loginbutton.height = 41;
			loginbutton.text = "Login";
			addChild(loginbutton);
		}
		
		// Tab between boxes
		private function textKeyPressed(e:KeyboardEvent):void {
			if(e.keyCode == 9) {
				if(e.target.parent == usernameBox) {
					passwordBox.setTextFocus();
				} else if (e.target.parent == passwordBox) {
					usernameBox.setTextFocus();	
				}
			}
			if(e.keyCode == 13) {
				loginClick();
			}
		}
		
		// Called when login button is clicked
		private function loginClicked(e:MouseEvent):void {
			loginClick();
		}
		
		// Dispatches login notification
		private function loginClick():void {
			var e:IDEvent = new IDEvent(IDEvent.LOGIN_CLICKED);
			dispatchEvent(e);
		}
	}
}