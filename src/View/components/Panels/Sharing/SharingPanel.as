package View.components.Panels.Sharing
{
	import Controller.BrowserController;
	import Controller.IDEvent;
	
	import Model.Model_Commentary;
	
	import View.BrowserView;
	import View.components.Panels.Panel;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.sampler.Sample;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	
	public class SharingPanel extends Panel
	{		
		// has content and toolbar from parent
		
		private var sharingData:Array;
	
		public static var NOACCESS:String = 'no-access';
		public static var READ:String = 'read';
		public static var READWRITE:String = 'read-write';
		
		private var assetCreatorUsername:String;
		
		private var sharingPanelUsersWithAccessArray:Array = new Array();
		
		/**
		 * The Sharing Panel sits on the right side on the main asset browser 
		 * and shows all the comments a specific collection has.
		 * 
		 * Contains a Scroller, which has a group, where the comments live.
		 */		
		public function SharingPanel()
		{
			super();

			// Set heading on the panel
			setHeading("Add People");

			// Add the close button to the panel
			var closeButton:Button = new Button();
			closeButton.label = "X";
			closeButton.percentHeight = 100;
			closeButton.width = 30;
			toolbar.addElement(closeButton);
			
			
			// Event Listenrs
//			saveSharing.addEventListener(MouseEvent.CLICK, saveNewSharingInformation);
//			this.addEventListener(Event.CHANGE, checkBoxClicked);
			
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
			
			this.addEventListener(IDEvent.SHARING_CHANGED, lockUsers);
		}
		
		/**
		 * Takes the sharing data for the asset, and displays it using
		 * sharing panel user items.
		 *  
		 * @param sharingData 	The data containing which users have access etc
		 * 
		 */		
		public function setupAssetsSharingInformation(sharingData:Array, assetCreatorUsername:String):void {

			this.assetCreatorUsername = assetCreatorUsername;
			
			trace("SharingPanel:setupAssetsSharingInformation");
			content.removeAllElements();
			
			trace("SharingPanel setupAssetsSharingInformation: Creator", assetCreatorUsername);
			
			// Save the sharingData
			this.sharingData = sharingData;
			
			for each(var userSharingData:Array in sharingData) {
				var username:String = userSharingData[0];
				
				var access:String = userSharingData[1];
				//trace(userSharingData[1]);
				
				// Add a new Sharing Panel User to the content for the panel
				var sharingPanelUser:SharingPanelUser = new SharingPanelUser(username, access);
//				if(!modifyAccess) {
//					sharingPanelUser.enabled = false;
//				}
				
				if(assetCreatorUsername == username) {
					sharingPanelUser.enabled = false;
				} else {
				}
				if(access == 'none') {
					addPanelItem(sharingPanelUser);
				} else {
					sharingPanelUsersWithAccessArray.unshift(sharingPanelUser);
				}
			}
			for each(sharingPanelUser in sharingPanelUsersWithAccessArray) {
				addPanelItemAtIndex(sharingPanelUser, 0);
			}
		}

		public function lockUsers(e:Event=null):void {
			for(var i:Number = 0; i < content.numElements; i++) {
				(content.getElementAt(i) as SharingPanelUser).enabled = false;
			}
		}
		
		public function unlockUsers():void {
			trace("SharingPanel:unlockUsers - Should be unlocking users");
			setTimeout(function():void {
				for(var i:Number = 0; i < content.numElements; i++) {
					if((content.getElementAt(i) as SharingPanelUser).getUsername() == assetCreatorUsername) {
						(content.getElementAt(i) as SharingPanelUser).enabled = false;
					} else {
						(content.getElementAt(i) as SharingPanelUser).enabled = true;
					}
				}			
			}, 3000);
			
		}
		/**
		 * REMOVE THIS FUNCTION (DEPRECATED) Save button clicked on sharing panel. Send the change to the controller. 
		 * @param e
		 * 
		 */		
//		private function checkBoxClicked(e:Event):void {
//			trace("Saving sharing information");
//			var sharingSavedEvent:IDEvent = new IDEvent(IDEvent.SHARED_SAVED, true);
//			
//			var sharingInformationArray:Array =  
//				
//				
//				//getNewSharingInformation();
//			sharingSavedEvent.data.sharingInformationArray = sharingInformationArray;
//			
//			this.dispatchEvent(sharingSavedEvent);
//		}
		
		private function closeButtonClicked(e:MouseEvent):void {
			this.width = 0;
		}
		
		/* ================ HELPER FUNCTIONS ===================== */
		/**
		 * Gets the sharing information from each of the user items in this panel. 
		 * @return 
		 * 
		 */		
		private function getNewSharingInformation():Array {
			var sharingInformationArray:Array = new Array();
			
			for(var i:Number = 0; i < content.numElements; i++) {
				var currentSharingPanelUser:SharingPanelUser = content.getElementAt(i) as SharingPanelUser;
				
				var individualUserSharingInfo:Array = new Array();
				// Store the users username
				individualUserSharingInfo.push(currentSharingPanelUser.getUsername());
				// Store the users access 
				individualUserSharingInfo.push(currentSharingPanelUser.getAccessString());
					
				// Store this in the array of all information
				sharingInformationArray.push(individualUserSharingInfo);
			}
			
			return sharingInformationArray;
		}
		
//		/**
//		 * Removes all comments being displayed. 
//		 * 
//		 */		
//		public function clearComments():void {
//			content.removeAllElements();
//		}
//		
//		/**
//		 * Add comments to the Comments panel.
//		 * TODO should this clear the panel first? probably??? 
//		 * @param commentArray	The array of comments (Model_Annotations) to add to the panel
//		 * 
//		 */		
//		public function addComments(commentArray:Array):void {
//			clearComments();
//			for(var i:Number = 0; i < commentArray.length; i++) {
//				content.addElement(new Comment((commentArray[i] as Model_Annotation)));
//			}
//		}
//		
//		/* =========== EVENT LISTENER FUNCTIONS =================== */
//		private function addCommentButtonClicked(e:MouseEvent):void {
//			
//			removeAnyNewComments();
//			var newComment:NewComment = new NewComment();
//			content.addElement(newComment);
//		}
//		
//		/**
//		 * Loop through all the comments, and check for a 'new comment'
//		 * if there is one already, remove it.
//		 * 
//		 */		
//		private function removeAnyNewComments():void {
//			
//			for(var i:Number = content.numElements - 1; i >= 0; i--) {
//				// Get out class name of comment (so we can see if its a new comment)
//				var commentClassName:String = flash.utils.getQualifiedClassName(content.getElementAt(i));
//				if(commentClassName == "View.components::NewComment") {
//					content.removeElementAt(i);
//				}
//				
//			}
//		}
//		
//		private function commentCancelled(e:RecensioEvent):void {
//			trace("Removing comment");
//			content.removeElement(e.data.newCommentObject);
//		}
	}
}