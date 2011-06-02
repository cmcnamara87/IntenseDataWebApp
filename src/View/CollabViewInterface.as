package View
{
	import View.components.Comments.NewComment;

	public interface CollabViewInterface
	{
		function commentSaved(commentID:Number, commentText:String, newCommentObject:NewComment):void;	
	}
}