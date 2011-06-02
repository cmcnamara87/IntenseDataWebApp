package Controller
{
	import Model.AppModel;
	
	import View.CollabViewInterface;
	import View.components.Comments.NewComment;

	public class CollaborationController extends AppController
	{
		public static var currentAssetID:Number; // The current ID for either media or collection
		
		public function CollaborationController(currentAssetID:Number)
		{
			super();
			
			CollaborationController.currentAssetID = currentAssetID;
			
			setupCollabListeners(); 
			
		}
		
		private function setupCollabListeners():void {
			// Listen for "Save Comment" button being clicked.
			view.addEventListener(IDEvent.COMMENT_SAVED, saveComment);
			// Listen for 'Delete Comment' button being clicked.
			view.addEventListener(IDEvent.COMMENT_DELETE, deleteComment);
		}
		
		/**
		 * Saves a comment 
		 * @param e	e.data.commentText - Contains the comment text, e.data.newCommentObject=the
		 * actual comment view object
		 * 
		 */		
		private function saveComment(e:IDEvent):void {
			trace('Saving comment: ', e.data.commentText, 'in reply to asset:', currentAssetID, 'reply to comment:',
				e.data.replyingToID);
			
			AppModel.getInstance().saveNewComment(	e.data.commentText, currentAssetID, e.data.replyingToID,
				e.data.newCommentObject, commentSaved);
		}
		
		/**
		 * Deletes a comment 
		 * @param e
		 * 
		 */		
		private function deleteComment(e:IDEvent):void {
			trace("Deleting a comment:", e.data.assetID);
			AppModel.getInstance().deleteComment(e.data.assetID);
		}
		
		/**
		 * The comment has been saved. 
		 * @param commentID			The ID for the saved comment
		 * @param commentText		The text for the saved comment
		 * @param newCommentObject	The NewCommentObject that is to be replaced by a regular comment.
		 * 
		 */		
		public function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void {
			trace("new comment object is", newCommentObject);
			(view as CollabViewInterface).commentSaved(commentID, commentText, newCommentObject);
		}
	}
}