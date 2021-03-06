package View
{
	import Controller.BrowserController;
	import Controller.Dispatcher;
	import Controller.IDEvent;
	import Controller.Utilities.Auth;
	
	import Model.Model_Media;
	
	import Module.AudioViewer.AudioView;
	import Module.PDFViewer.PDF;
	import Module.PDFViewer.PDFViewer;
	import Module.Videoviewer.Videoview;
	
	import View.components.AssetTile.AssetTile;
	import View.components.GoodBorderContainer;
	import View.components.IDButton;
	import View.components.IDGUI;
	import View.components.MediaViewer.AudioViewer;
	import View.components.MediaViewer.ImageViewer.ImageViewerOLD;
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.VideoViewer.VideoViewer;
	import View.components.MediaViewer.Viewer;
	import View.components.Panels.AnnotationList.AnnotationListPanel;
	import View.components.Panels.Comments.CommentsPanel;
	import View.components.Panels.Comments.NewComment;
	import View.components.Panels.EditDetails.EditDetailsPanel;
	import View.components.Panels.MediaLinkPanel;
	import View.components.Panels.Panel;
	import View.components.Panels.People.PeoplePanel;
	import View.components.Panels.Sharing.SharingPanel;
	import View.components.Toolbar;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.effects.Resize;
	import mx.events.CloseEvent;
	import mx.events.ItemClickEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.modules.Module;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.ButtonBarButton;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;

	public class MediaView extends BorderContainer
	{
		private var myCommentsPanel:CommentsPanel;	// The Comments panel
		private var mySharingPanel:SharingPanel;	// The sharing panel
		private var myEditPanel:EditDetailsPanel; // The temporary edit panel
		private var myAnnotationListPanel:AnnotationListPanel;
		private var myPeoplePanel:PeoplePanel;
		private var myMediaLinkPanel:MediaLinkPanel;
		
		private var mediaViewer:MediaViewer;
		private var mediaData:Model_Media;	// The Media's Meta-data
		private var heading:Label;	// The title of the media

		private var backButton:Button;
		private var downloadButton:Button;
		private var addAnnotationButton:Button;
		private var hideShowAnnotationButton:Button;
		private var deleteAssetButton:IDButton;
		private var editDetailsButton:Button;
		private var shareButton:Button;
		private var viewsButton:IDButton;
		private var annotationListButton:Button;
		private var commentsButton:Button;
		
		private var viewerAndPanels:HGroup;
		
		public static var saveAnnotationFunction:Function;
		
		private var currentlyAddingRefTo:String;
		
		private var commentCount:Number = 0;
		
		// Can remove the save annotation function after redoing the modules, only there for dekkers code
		public function MediaView(saveAnnotationFunction:Function)
		{
			MediaView.saveAnnotationFunction = saveAnnotationFunction;
			// Lets outline the parts of the image view
			// There is
			// 1) Big toolbar all the way across the top
			// 2) in an hgroup: the image, sharing, comments, annotations panels, edit details
			
			// Setup size
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.setStyle('borderVisible', false);
			
			// Setup layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Add toolbar
			var myToolbar:Toolbar = new Toolbar();
			this.addElement(myToolbar);
			
			// Add a Back button
			myToolbar.addElement(backButton = IDGUI.makeButton("Back"));
			// Disable the back button until the asset has loaded (solves some deallocing problems)
			backButton.enabled = false;
			
			// Create a heading for the toolbar
			heading = new Label();
			heading.text = "Loading...";
			heading.setStyle('fontWeight', 'bold');
			heading.setStyle('textAlign', 'left');
			heading.setStyle('color', 0x999999);
			heading.setStyle('fontSize', 16);
			heading.percentWidth = 100;
			myToolbar.addElement(heading);
			
			
			// Add Add Annotation button
			addAnnotationButton = IDGUI.makeButton("Add Annotation");
			// Make the button invisible for now, we will only show it
			// if its the 'image' media type (this is done when the media is loaded below
			// TODO fix this when refactored
			addAnnotationButton.visible = false;
			addAnnotationButton.enabled = false;
			myToolbar.addElement(addAnnotationButton);
			
			// Add Hide Annotations Button
			hideShowAnnotationButton = IDGUI.makeButton("Hide Annotations");
			// Make it not visible, same as above
			hideShowAnnotationButton.visible = false;
			hideShowAnnotationButton.enabled = false;
			myToolbar.addElement(hideShowAnnotationButton);
			
			var addAnnotationEditDetailsLine:Line = IDGUI.makeLine()
			myToolbar.addElement(addAnnotationEditDetailsLine);
			
			deleteAssetButton = new IDButton("Delete File", false, false);
			deleteAssetButton.enabled = false;
			
			myToolbar.addElement(deleteAssetButton);
			
			var deleteAddLine:Line = IDGUI.makeLine();
//			myToolbar.addElement(deleteAddLine);
			
			// ADD THE PANELS
			// Add Edit Details button
			editDetailsButton = IDGUI.makeButton('Edit Details');
			editDetailsButton.enabled = false;
			myToolbar.addElement(editDetailsButton);
			
			// Add Share buttons
			shareButton = IDGUI.makeButton('Share');
//			shareButton.enabled = false;
//			myToolbar.addElement(shareButton);
			
			viewsButton = new IDButton('Participants');
			viewsButton.enabled = false;
			myToolbar.addElement(viewsButton);
			
			// Add annotations button
			annotationListButton = IDGUI.makeButton('Annotation List');
			annotationListButton.enabled = false;
			myToolbar.addElement(annotationListButton);
			
			// Add comments button
			commentsButton = IDGUI.makeButton('Comments');
			commentsButton.enabled = false;
			myToolbar.addElement(commentsButton);
			
			
			var downloadLine:Line = IDGUI.makeLine();
			myToolbar.addElement(downloadLine);
			
			downloadButton = IDGUI.makeButton('Download');
			downloadButton.enabled = false;
			myToolbar.addElement(downloadButton);
			
			
			// Group HGroup for Viewer and Panels
			viewerAndPanels = new HGroup();
			viewerAndPanels.gap = 0;
			viewerAndPanels.percentWidth = 100;
			viewerAndPanels.percentHeight = 100;
			this.addElement(viewerAndPanels);
			
			// Create the Panels
			this.addPanels(viewerAndPanels);
			
			myMediaLinkPanel = new MediaLinkPanel();
			myMediaLinkPanel.addMedia(BrowserController.currentCollectionAssets);
			this.addElement(myMediaLinkPanel);
			
			if(BrowserController.currentCollectionID == BrowserController.ALLASSETID) {
				this.hideButtonsForPureAssetView();	
			}
			// Add Event Listeners
			deleteAssetButton.addEventListener(MouseEvent.CLICK, deleteAssetButtonClicked);
			addAnnotationButton.addEventListener(MouseEvent.CLICK, addAnnotationButtonClicked);
			hideShowAnnotationButton.addEventListener(MouseEvent.CLICK, hideShowAnnotationButtonClicked);
			editDetailsButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			shareButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			annotationListButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			commentsButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			// Listen for annotation list item mouseover
			this.addEventListener(IDEvent.ANNOTATION_LIST_ITEM_MOUSEOVER, annotationListItemMouseOver);
			this.addEventListener(IDEvent.ANNOTATION_LIST_ITEM_MOUSEOUT, annotationListItemMouseOut);
			
			backButton.addEventListener(MouseEvent.CLICK, backButtonClicked);
			downloadButton.addEventListener(MouseEvent.CLICK, downloadButtonClicked);
			
			viewsButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			
			
			// Asset Ref Code
			this.addEventListener(IDEvent.OPEN_REF_PANEL, function(e:IDEvent):void {
				currentlyAddingRefTo = e.data.type;
				myMediaLinkPanel.show();
			});
			
			this.addEventListener(IDEvent.CLOSE_REF_PANEL, function(e:IDEvent):void {
				myMediaLinkPanel.hide();
			});
			
			this.addEventListener(IDEvent.ASSET_ADD_AS_REF_COMMENT, function(e:IDEvent):void {
				if(currentlyAddingRefTo == 'comment') {
					myCommentsPanel.addReferenceTo(e.data.assetData);
				} else if (currentlyAddingRefTo == 'annotation') {
					myAnnotationListPanel.addReferenceTo(e.data.assetData);
//					myCommentsPanel.addReferenceTo(e.data.assetData);
				}
			})
			
			this.addEventListener(IDEvent.COMMENT_EDITED, function(e:IDEvent):void {
				myMediaLinkPanel.hide();
			});
		}
		
		
		
		/* ============== INPUT FUNCTIONS CALLED BY CONTROLLER ================ */
		public function addMediaData(mediaData:Model_Media):void {
			trace("MediaView:addMediaData Adding data", mediaData);
			trace("Media Data Loaded");
			this.mediaData = mediaData;
			
			setHeading(mediaData.meta_title);
			
			myEditPanel.addDetails(mediaData);
				
			// Check what kind of media it is
			trace("Media Type:", mediaData.type);
			trace("Media Title:", mediaData.meta_title);
			
			switch(mediaData.type) {
				case "image":
//					mediaViewer = new ImageViewer();
					mediaViewer = Viewer.getViewer(MediaAndAnnotationHolder.MEDIA_IMAGE);
					addAnnotationButton.visible = true;
					hideShowAnnotationButton.visible = true;
					break;
				case "audio":
					mediaViewer = new AudioView();
					break;
				case "video":
					mediaViewer = new Videoview();
					break;
				case "document":
//					mediaViewer = new Module.PDFViewer.PDFViewer();
					mediaViewer = Viewer.getViewer(MediaAndAnnotationHolder.MEDIA_PDF);
					addAnnotationButton.visible = true;
					hideShowAnnotationButton.visible = true;
//					mediaViewer = new Module.PDFViewer.PDFViewer();
					break;
				default:
					mediaViewer = new MediaViewer();
			}
//			mediaViewer = new MediaViewer();
			
			mediaViewer.percentHeight = 100;
			mediaViewer.percentWidth = 100;
			mediaViewer.setStyle("resizeEffect", new mx.effects.Resize());
			viewerAndPanels.addElementAt(mediaViewer, 0);
			
			// Load image URL
			trace("MediaView Loading:",mediaData.generateMediaURL()); 
			mediaViewer.load(mediaData.generateMediaURL());
			
			
			// Enable the back button 
			backButton.enabled = true;
			
			// If we are the author, then the button should say 'delete'
			// otherwise it will say remove
			if(mediaData.base_creator_username == Auth.getInstance().getUsername()) {
				deleteAssetButton.label = "Delete File";
			} else {
				deleteAssetButton.label = "Remove File";
			}
			
			setupButtonsAccess();
			if(BrowserController.currentCollectionID == BrowserController.ALLASSETID) {
				this.hideButtonsForPureAssetView();	
			}
		}
		
		private function hideButtonsForPureAssetView():void {
			// If we are looking through the 'your files' in the browser controller
			// we only show the asset, no features, like annoattions etc
			addAnnotationButton.visible = false;
			addAnnotationButton.includeInLayout = false;
			hideShowAnnotationButton.visible = false;
			hideShowAnnotationButton.includeInLayout = false;
			editDetailsButton.visible = false;
			editDetailsButton.includeInLayout = false;			
			shareButton.visible = false;
			shareButton.includeInLayout = false;
			annotationListButton.visible = false;
			annotationListButton.includeInLayout = false;
			commentsButton.visible = false;
			commentsButton.includeInLayout = false;
			viewsButton.visible = false;
			viewsButton.includeInLayout = false;
			
			deleteAssetButton.visible = true;
			deleteAssetButton.includeInLayout = true;
			deleteAssetButton.enabled = true;
			
			if(mediaData && mediaData.base_asset_id == BrowserController.USERS_MANUAL_ASSET_ID) {
				trace("**************************** YOYO", BrowserController.USERS_MANUAL_ASSET_ID);
				deleteAssetButton.visible = false;
				deleteAssetButton.includeInLayout = false;
			}
		}
		
		
		private function setupButtonsAccess():void {
			// Enable all the buttons since we have loaded the data now
			editDetailsButton.enabled = true;
			hideShowAnnotationButton.enabled = true;
//			shareButton.enabled = true;
			shareButton.includeInLayout = false;
			shareButton.visible = false;
			annotationListButton.enabled = true;
			commentsButton.enabled = true;
			viewsButton.enabled = true;
			
			trace("- File access permissions:", mediaData.access_modify_content);
			if(mediaData.access_modify_content) {
				// We have modify access to the file, so we enable adding annotations
				addAnnotationButton.enabled = true;
				downloadButton.enabled = true;
			}
			
			// The delete button should be enabled, provided its been shared via the asset
			// and not via the collection 
			if(mediaData.meta_media_access_level == SharingPanel.READWRITE || 
				mediaData.meta_media_access_level == SharingPanel.READ) {
				// We have read-write or read access to the file itself
				// not through a collection
				deleteAssetButton.enabled = true;
			} 
			
			//			}
			
			mySharingPanel.setUserAccess(mediaData.access_modify_content);
			myAnnotationListPanel.setUserAccess(mediaData.access_modify_content);
			myEditPanel.setUserAccess(mediaData.access_modify_content);
			myCommentsPanel.setUserAccess(mediaData.access_modify_content);
		}
		
		/**
		 * Called by Controller when the sharing info for the asset has been loaded.
		 * Passes the data to the sharing panel. 
		 * @param	sharingData	An array of data with user+access information.
		 */		
		public function setupAssetsSharingInformation(sharingData:Array, assetCreatorUsername:String):void {
			mySharingPanel.setupAssetsSharingInformation(sharingData, assetCreatorUsername);
		}
		
		public function addPeople(peopleCollection:Array):void {
			myPeoplePanel.addPeople(peopleCollection, mediaData.base_asset_id);	
		}
		
		public function setHeading(text:String):void {
			// Set heading
			this.heading.text = text;
		}
		
		
		/**
		 * Adds the comments for the collection clicked to the comment panel
		 * Also sets the Comment(0) <-- that number, to be the number of comments 
		 * @param annotationnsArray
		 * 
		 */		
		public function addComments(commentsArray:Array):void {
			trace("Adding Comments...");
			myCommentsPanel.addComments(commentsArray);
			setCommentCount(commentsArray.length);
		}
		private function setCommentCount(count:Number):void {
			this.commentCount = count;
			commentsButton.label = "Comments (" + count + ")";
		}
		
		public function addAnnotations(annotationsArray:Array):void {
			trace("Adding Annotations...", annotationsArray.length);
			// Add annotations to annotations list
			myAnnotationListPanel.addAnnotations(annotationsArray);
			annotationListButton.label = "Annotation List (" + annotationsArray.length + ")";
			// Add annotation to viewer
			if(mediaViewer && BrowserController.currentCollectionID != BrowserController.ALLASSETID) {
				mediaViewer.addAnnotations(annotationsArray);
			}
		}
		
		public function unlockSharingPanelUsers():void {
			mySharingPanel.unlockUsers();
		}
		
		/* ============== UPDATE FUNCTIONS CALLED BY CONTROLLER ================= */
		/**
		 * The comment has been saved, so tell the comments panel to make it appear
		 * as a regular comment, not a new one. 
		 * @param newCommentObject	The comment that has been saved.
		 * 
		 */		
		public function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void {
			setCommentCount(commentCount + 1);
			myCommentsPanel.commentSaved(commentID, commentText, newCommentObject);
		}
		
		public function detailsSaved(success:Boolean, msg:String = ""):void {
			myEditPanel.detailsSaved(success, msg);
			if(success) {
				// We saved it successfully, lets get the new title out of the panel
				// And set it as the heading
				this.setHeading(myEditPanel.getTitle());
			}
		}
		
		
		/* ============== EVENT LISTENER FUNCTIONS ================ */
		private function backButtonClicked(e:MouseEvent):void {
			// Go back to the Browser Controller
			if(mediaViewer) {
				viewerAndPanels.removeElement(mediaViewer);
				mediaViewer = null;
			}
			if(BrowserController.mediaIDHistoryArray.length == 0) {
				Dispatcher.call("browse");	
			} else {
				var previousMediaID:Number = BrowserController.mediaIDHistoryArray.pop();
				trace("---------- GOING BACK TO", previousMediaID);
				Dispatcher.call("view/" + previousMediaID);
			}
		}
		
		/**
		 * The delete asset button was clicked, tell the controller 
		 * @param e
		 * 
		 */		
		private function deleteAssetButtonClicked(e:MouseEvent):void {
			var myEvent:IDEvent = new IDEvent(IDEvent.MEDIA_ASSET_DELETE_BUTTON_CLICKED);
			this.dispatchEvent(myEvent);
		}
		
		/**
		 * The Add Annotation button was clicked. Tell the media viewer module
		 * to switch into 'new annotation' mode. 
		 * @param e
		 * 
		 */		
		private function addAnnotationButtonClicked(e:MouseEvent):void {
			trace("Add Annotation Button Clicked");
			mediaViewer.enterNewAnnotationMode();
		}
		
		private function hideShowAnnotationButtonClicked(e:MouseEvent):void {
			if(hideShowAnnotationButton.label == "Hide Annotations") {
				// Hide the annotations
				mediaViewer.hideAnnotations();
				hideShowAnnotationButton.label = "Show Annotations";
			} else {
				// Show the annotations
				mediaViewer.showAnnotations();
				hideShowAnnotationButton.label = "Hide Annotations"
			}
		}
		
		private function panelButtonClicked(event:MouseEvent):void {
			
			// Get out the button taht was clicked
			var button:Button = event.target as Button;
			
			// Hide all the panels
			hideAllPanels();

			
			// Only show the panel we want,
			// based on what button has been clicked
			switch(button) {
				case addAnnotationButton:
					trace("add annotation button clicked");
					mediaViewer.enterNewAnnotationMode();
					break;
				case editDetailsButton:
					trace('edit button clicked');
					myEditPanel.width = Panel.DEFAULT_WIDTH;
					myEditPanel.visible = true;
					break;
				case shareButton:
					trace("share button clicked");
					mySharingPanel.width = Panel.DEFAULT_WIDTH;
					mySharingPanel.visible = true;
					break;
				case viewsButton:
					myPeoplePanel.width = Panel.DEFAULT_WIDTH;
					myPeoplePanel.visible = true;
					break;
				case annotationListButton:
					trace("annotation list button clicked");
					myAnnotationListPanel.width = Panel.DEFAULT_WIDTH;
					myAnnotationListPanel.visible = true;
					break;
				case commentsButton:
					trace("comments button clicked");
					myCommentsPanel.width = Panel.DEFAULT_WIDTH;
					myCommentsPanel.visible = true;
				default:
					break;
			}

		}
		
		private function annotationListItemMouseOver(e:IDEvent):void {
//			trace("Caught List Item Mouseover");
			mediaViewer.highlightAnnotation(e.data.assetID);
		}
		
		private function annotationListItemMouseOut(e:IDEvent):void {
//			trace("Caught List Item Mouseover");
			mediaViewer.unhighlightAnnotation(e.data.assetID);
			
		}
		
		/**
		 * The user clicked the download button, downlaod the current media asset 
		 * @param e
		 * 
		 */		
		private function downloadButtonClicked(e:MouseEvent):void {
			var myAlert:Alert = Alert.show("Are you sure you wish to download this file?", "Download File", 
					Alert.OK | Alert.CANCEL, null, 
					function(e:CloseEvent):void {
						if(e.detail == Alert.OK) {
							var url:String = mediaData.getDownloadURL();
							var req:URLRequest = new URLRequest(url);
							navigateToURL(req, 'Download');
						}
					}, 
					null, Alert.CANCEL);
			myAlert.height=100;
			myAlert.width=300;
		}
		
		/*========================== HELPER FUNCTIONS ======================= */
	
		/**
		 * Alls all the panels to the view 
		 */		
		private function addPanels(viewerAndPanels:Group):void {
			// Add the Temporary Edit Panel
			myEditPanel = new EditDetailsPanel();
			myEditPanel.width = 0;
			myEditPanel.visible = false;
			viewerAndPanels.addElement(myEditPanel);
			
			myAnnotationListPanel = new AnnotationListPanel();
			myAnnotationListPanel.width = 0;
			myAnnotationListPanel.visible = false;
			viewerAndPanels.addElement(myAnnotationListPanel);
			
			// Lets add the Sharing Panel
			mySharingPanel = new SharingPanel();
			mySharingPanel.width = 0;
			mySharingPanel.visible = false;
			viewerAndPanels.addElement(mySharingPanel);
			
			myPeoplePanel = new PeoplePanel();
			myPeoplePanel.width = 0;
			myPeoplePanel.visible = false;
			viewerAndPanels.addElement(myPeoplePanel);
			
			// Lets add the Comments Panel
			myCommentsPanel = new CommentsPanel();
			myCommentsPanel.width = 0;
			myCommentsPanel.visible = false;
			viewerAndPanels.addElement(myCommentsPanel);
		}
		
		
		
		/**
		 * Hides the panels from the view 
		 */		
		private function hideAllPanels():void {
			// Set all the panels to have a width of 0
			// So they aren't shown
			myEditPanel.visible = false;
			myEditPanel.width = 0;
			myCommentsPanel.visible = false;
			myCommentsPanel.width = 0;
			mySharingPanel.visible = false;
			mySharingPanel.width = 0;
			myAnnotationListPanel.width = 0;
			myAnnotationListPanel.visible = false;
			myPeoplePanel.width = 0;
			myPeoplePanel.visible = false;
		}
		
	}
}