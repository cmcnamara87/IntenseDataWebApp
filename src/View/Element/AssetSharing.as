package View.Element
{
	import Controller.IDEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.AdvancedDataGrid;

	public class AssetSharing extends RecensioUIComponent {
		
		public var sharingForm:AssetSharingForm = new AssetSharingForm(); // The asset sharing form
		private var inset:Number = 10; // the padding??
		private var _shared:Array = new Array();
		private var userlist:Array = new Array();
		
		private var updateSharedAccessButton:SmallButton = new SmallButton("Update Shared Access",true);
		
		public function AssetSharing() {
			super();

			// Setup Button
			updateSharedAccessButton.toolTip = "Save Shared Access";
			updateSharedAccessButton.addEventListener(MouseEvent.CLICK,saveAccess);
			addChild(updateSharedAccessButton);
			
			sharingForm.y = Comments.TOPSPACE + 10;
			this.addChild(sharingForm);
		}
		
		// INIT
		override protected function init(e:Event):void {
			super.init(e);
			//sharingForm.saveShareButton.addEventListener(MouseEvent.MOUSE_UP,saveAccess);
		}
		
		// Packages up the updated shared information and dispatches it
		private function saveAccess(e:MouseEvent):void {
			var access:Array = getNewAccessLevels();
			var saveEvent:IDEvent = new IDEvent(IDEvent.SHARED_SAVED);
			saveEvent.data.access = access;
			this.dispatchEvent(saveEvent);
		}
		
		/**
		 * Hides the 'Update Shared Access' button
		 * 
		 * Called when the Sharing panel is taken off the screen because
		 * the button hangs around and is annoying, so we will manually hide it. 
		 * 
		 */		
		public function hideButton():void {
			updateSharedAccessButton.enabled = false;
		}
		
		/**
		 * Shows the 'Update Shared Access' button
		 * 
		 * Called when the Sharing panel is made visible @see hideButton() for why its being hidden.
		 * 
		 */		
		public function showButton():void {
			updateSharedAccessButton.enabled = true;
		}
		
		// Returns the changed access levels after user interaction
		private function getNewAccessLevels():Array {
			var access:Array = new Array();
			for each(var user:AssetSharingItem in userlist) {
				access.push([user.getUsername(),user.getAccess()]);
			}
			return access;
		}
		
		// Redraw
		override protected function draw():void {
			drawBackground();
			drawUpdateAccessButton();
			if(this.width < 10) {
				updateSharedAccessButton.visible = false;
			} else {
				updateSharedAccessButton.visible = true;
			}
		}
		
		// Sets up the "add comment" button
		private function drawUpdateAccessButton():void {
			updateSharedAccessButton.width = 180;
			updateSharedAccessButton.height = 22;
			updateSharedAccessButton.y = 9;
			updateSharedAccessButton.x = this.width - updateSharedAccessButton.width - 10; // need to find //commentsPadding;
		}
		
		// Creates and draws each of the rows
		private function drawNames():void {
			sharingForm.sharetable.removeAllElements();
			for each(var details:Array in _shared) {
				var tmpItem:AssetSharingItem = new AssetSharingItem(details[0],details[1]);
				sharingForm.sharetable.addElement(tmpItem);
				userlist.push(tmpItem);
			}
		}
		
		// Updates the shared information (users and their access)
		public function setShared(shared:Array):void {
			_shared = shared;
			drawNames();
		}
		
		// Redraws the shared menu
		private function drawBackground():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.lineStyle(1,0xb9b9bb);
			this.graphics.drawRoundRect(Comments.LEFTPADDING,0, this.width-Comments.LEFTPADDING,this.height,0);
			
			this.graphics.beginFill(0xdddddd,1);
			this.graphics.lineStyle(1,0xb9b9bb);
			this.graphics.drawRoundRect(Comments.LEFTPADDING, 0, this.width - Comments.LEFTPADDING, Comments.TOPSPACE, 0);
			
			//resizeStrip.graphics.clear();
			// Draw a rectangle to the left of the comment box
			// people can click this for resizing
		//	resizeStrip.graphics.beginFill(0xFF0000,0.001);
		//	resizeStrip.graphics.drawRect(0, 0, Comments.LEFTPADDING, this.height);
		
			
			sharingForm.sharetable.width = this.width-40-15;
			sharingForm.sharetable.height = this.height-28-47;
				
			/*this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF,1);
			//this.graphics.beginFill(0xdddddd,1);
			this.graphics.lineStyle(1,0xb9b9bb);
			
			var theHeight:Number = this.height;
			var innerHeight:Number = theHeight-inset*2;
			if(theHeight < 0) {
				theHeight = 0;
				innerHeight = 0;
			}
			this.graphics.drawRoundRect(40,0,this.width-40,theHeight,12);
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawRoundRect(40+inset,inset,this.width-inset*2-40,innerHeight,12);
			sharingForm.sharetable.width = this.width-inset*2-40-8;
			sharingForm.sharetable.height = innerHeight-28-22;*/
		}
	}
}