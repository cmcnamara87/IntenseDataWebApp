package View
{
	import Controller.Dispatcher;
	import Controller.RecensioEvent;
	
	import Model.Model_Media;
	
	import Module.AudioViewer.AudioView;
	import Module.PDFViewer.PDF;
	import Module.PDFViewer.PDFViewer;
	import Module.Videoviewer.Videoview;
	
	import View.components.AnnotationList.AnnotationListPanel;
	import View.components.Comments.CommentsPanel;
	import View.components.Comments.NewComment;
	import View.components.EditDetails.EditDetailsPanel;
	import View.components.MediaViewer.AudioViewer;
	import View.components.MediaViewer.ImageViewer.ImageViewer;
	import View.components.MediaViewer.MediaViewer;
	import View.components.MediaViewer.VideoViewer.VideoViewer;
	import View.components.Panel;
	import View.components.Sharing.SharingPanel;
	import View.components.Toolbar;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Resize;
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
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;

	public class MediaView extends BorderContainer
	{
		private var myCommentsPanel:CommentsPanel;	// The Comments panel
		private var mySharingPanel:SharingPanel;	// The sharing panel
		private var myEditPanel:EditDetailsPanel; // The temporary edit panel
		private var myAnnotationListPanel:AnnotationListPanel;
		
		private var mediaViewer:MediaViewer;
		private var mediaData:Model_Media;	// The Media's Meta-data
		private var heading:Label;	// The title of the media

		private var backButton:Button;
		private var downloadButton:Button;
		private var addAnnotationButton:Button;
		private var hideShowAnnotationButton:Button;
		private var deleteAssetButton:Button;
		private var editDetailsButton:Button;
		private var shareButton:Button;
		private var annotationListButton:Button;
		private var commentsButton:Button;
		
		private var viewerAndPanels:HGroup;
		
		public static var saveAnnotationFunction:Function;
		
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
			
			// Setup layout
			var myLayout:VerticalLayout = new VerticalLayout();
			myLayout.gap = 0;
			this.layout = myLayout;
			
			// Add toolbar
			var myToolbar:Toolbar = new Toolbar();
			this.addElement(myToolbar);
			
			// Add a Back button
			backButton = new Button();
			backButton.label = 'Back';
			// Disable the back button until the asset has loaded (solves some deallocing problems)
			backButton.enabled = false;
			backButton.percentHeight = 100;
			myToolbar.addElement(backButton);
			
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
			addAnnotationButton = new Button();
			addAnnotationButton.percentHeight = 100;
			addAnnotationButton.label = 'Add Annotation';
			// Make the button invisible for now, we will only show it
			// if its the 'image' media type (this is done when the media is loaded below
			// TODO fix this when refactored
			addAnnotationButton.visible = false;
			addAnnotationButton.enabled = false;
			myToolbar.addElement(addAnnotationButton);
			
			// Add Hide Annotations Button
			hideShowAnnotationButton = new Button();
			hideShowAnnotationButton.percentHeight = 100;
			hideShowAnnotationButton.label = "Hide Annotations";
			// Make it not visible, same as above
			hideShowAnnotationButton.visible = false;
			hideShowAnnotationButton.enabled = false;
			myToolbar.addElement(hideShowAnnotationButton);
			
			var addAnnotationEditDetailsLine:Line = new Line();
			addAnnotationEditDetailsLine.percentHeight = 100;
			addAnnotationEditDetailsLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			myToolbar.addElement(addAnnotationEditDetailsLine);
			
			deleteAssetButton = new Button();
			deleteAssetButton.percentHeight = 100;
			deleteAssetButton.enabled = false;
			deleteAssetButton.label = 'Delete Asset';
			myToolbar.addElement(deleteAssetButton);
			
			var deleteAddLine:Line = new Line();
			deleteAddLine.percentHeight = 100;
			deleteAddLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			myToolbar.addElement(deleteAddLine);
			
			// Add Edit Details button
			editDetailsButton = new Button();
			editDetailsButton.enabled = false;
			editDetailsButton.percentHeight = 100;
			editDetailsButton.label = 'Edit Details';
			myToolbar.addElement(editDetailsButton);
			
			// Add Share buttons
			shareButton = new Button();
			shareButton.enabled = false;
			shareButton.percentHeight = 100;
			shareButton.label = 'Share';
			myToolbar.addElement(shareButton);
			
			// Add annotations button
			annotationListButton = new Button();
			annotationListButton.enabled = false;
			annotationListButton.percentHeight = 100;
			annotationListButton.label = 'Annotation List';
			myToolbar.addElement(annotationListButton);
			
			// Add comments button
			commentsButton = new Button();
			commentsButton.enabled = false;
			commentsButton.percentHeight = 100;
			commentsButton.label = 'Comments';
			myToolbar.addElement(commentsButton);
			
			
			var downloadLine:Line = new Line();
			downloadLine.percentHeight = 100;
			downloadLine.stroke = new SolidColorStroke(0xBBBBBB,1,1);
			myToolbar.addElement(downloadLine);
			
			downloadButton = new Button();
			downloadButton.enabled = false;
			downloadButton.percentHeight = 100;
			downloadButton.label = 'Download';
			myToolbar.addElement(downloadButton);
			
			
			// Group HGroup for Viewer and Panels
			viewerAndPanels = new HGroup();
			viewerAndPanels.gap = 0;
			viewerAndPanels.percentWidth = 100;
			viewerAndPanels.percentHeight = 100;
			this.addElement(viewerAndPanels);
			
			// Create the Panels
			this.addPanels(viewerAndPanels);
			
			// Add Event Listeners
			deleteAssetButton.addEventListener(MouseEvent.CLICK, deleteAssetButtonClicked);
			addAnnotationButton.addEventListener(MouseEvent.CLICK, addAnnotationButtonClicked);
			hideShowAnnotationButton.addEventListener(MouseEvent.CLICK, hideShowAnnotationButtonClicked);
			editDetailsButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			shareButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			annotationListButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			commentsButton.addEventListener(MouseEvent.CLICK, panelButtonClicked);
			// Listen for annotation list item mouseover
			this.addEventListener(RecensioEvent.ANNOTATION_LIST_ITEM_MOUSEOVER, annotationListItemMouseOver);
			this.addEventListener(RecensioEvent.ANNOTATION_LIST_ITEM_MOUSEOUT, annotationListItemMouseOut);
			
			backButton.addEventListener(MouseEvent.CLICK, backButtonClicked);
			downloadButton.addEventListener(MouseEvent.CLICK, downloadButtonClicked);
		}
		
		
		
		/* ============== INPUT FUNCTIONS CALLED BY CONTROLLER ================ */
		public function addMediaData(mediaData:Model_Media):void {
			trace("Media Data Loaded");
			this.mediaData = mediaData;
			
			setHeading(mediaData.meta_title);
			
			myEditPanel.addDetails(mediaData);
			
			// Check what kind of media it is
			trace("Media Type:", mediaData.type);
			trace("Media Title:", mediaData.meta_title);
			
			switch(mediaData.type) {
				case "image":
					mediaViewer = new ImageViewer();
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
					mediaViewer = new Module.PDFViewer.PDFViewer();
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
			downloadButton.enabled = true;
			trace("- File access permissions:", mediaData.access_modify);
			if(mediaData.access_modify) {
				deleteAssetButton.enabled = true;
				addAnnotationButton.enabled = true;
				editDetailsButton.enabled = true;
				hideShowAnnotationButton.enabled = true;
				shareButton.enabled = true;
				annotationListButton.enabled = true;
				commentsButton.enabled = true;
			}
		}
		
		/**
		 * Called by Controller when the sharing info for the asset has been loaded.
		 * Passes the data to the sharing panel. 
		 * @param	sharingData	An array of data with user+access information.
		 */		
		public function setupAssetsSharingInformation(sharingData:Array):void {
			mySharingPanel.setupAssetsSharingInformation(sharingData);
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
		}
		
		public function addAnnotations(annotationsArray:Array):void {
			trace("Adding Annotations...", annotationsArray.length);
			// Add annotations to annotations list
			myAnnotationListPanel.addAnnotations(annotationsArray);
			
			// Add annotation to viewer
			if(mediaViewer) {
				mediaViewer.addAnnotations(annotationsArray);
			}
		}
		
		/* ============== UPDATE FUNCTIONS CALLED BY CONTROLLER ================= */
		/**
		 * The comment has been saved, so tell the comments panel to make it appear
		 * as a regular comment, not a new one. 
		 * @param newCommentObject	The comment that has been saved.
		 * 
		 */		
		public function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void {
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
			Dispatcher.call("browse");
		}
		
		/**
		 * The delete asset button was clicked, tell the controller 
		 * @param e
		 * 
		 */		
		private function deleteAssetButtonClicked(e:MouseEvent):void {
			var myEvent:RecensioEvent = new RecensioEvent(RecensioEvent.MEDIA_ASSET_DELETE_BUTTON_CLICKED);
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
		
		private function annotationListItemMouseOver(e:RecensioEvent):void {
			trace("Caught List Item Mouseover");
			mediaViewer.highlightAnnotation(e.data.assetID);
		}
		
		private function annotationListItemMouseOut(e:RecensioEvent):void {
			trace("Caught List Item Mouseover");
			mediaViewer.unhighlightAnnotation(e.data.assetID);
			
		}
		
		/**
		 * The user clicked the download button, downlaod the current media asset 
		 * @param e
		 * 
		 */		
		private function downloadButtonClicked(e:MouseEvent):void {
			var url:String = mediaData.getDownloadURL();
			var req:URLRequest = new URLRequest(url);
			navigateToURL(req, 'Download');
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
		}
		
	}
}