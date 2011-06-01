package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Model_Commentary;
	import Model.Utilities.Connection;
	
	import View.components.Comments.NewComment;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class Transaction_SaveNewComment
	{
		private var callback:Function; // The function
		private var newCommentObject:NewComment; // the new comment to be replaced iwth an old comment
		private var commentText:String;
		private var replyingToID:Number; // The comment we are replying to, 0 if not a reply.
		private var _connection:Connection;
		private var commentID:Number; // The ID of the comment after it has been saved
		private var commentParentID:Number; // The ID of the asset we are commenting on.
		
		public function Transaction_SaveNewComment(_connection:Connection, commentText:String, commentParentID:Number, replyingToID:Number,
												   newCommentObject:NewComment, callback:Function):void
		{
			// Save the callback and newCommentObject
			this.callback = callback;
			this.newCommentObject = newCommentObject;
			this.replyingToID = replyingToID;
			this.commentText = commentText;
			this._connection = _connection;
			this.commentParentID = commentParentID;
			// Save the comment
			saveComment(commentText, commentParentID);
				
		}
		
		private function saveComment(commentText:String, commentParentID:Number):void {
			var args:Object = new Object();
			
			args.namespace = "recensio";
			var baseXML:XML = _connection.packageRequest('asset.create', args, true);
			
			// Set this comment, as a child of the collection/asset
			baseXML.service.args["related"]["to"] = commentParentID;
			baseXML.service.args["related"]["to"].@relationship = "is_child";
			
			// TODO find out what these mean
			baseXML.service.args["meta"]["r_base"]["obtype"] = "4";
			baseXML.service.args["meta"]["r_base"]["active"] = "true";
			
			// Set the Creator as the current user
			baseXML.service.args["meta"]["r_base"]["creator"] = Auth.getInstance().getUsername();
			
			// TODO find out what this is
			baseXML.service.args["meta"]["r_base"].@id = 2;
			
			// The title is either 'comment' or for a reply comment 'commentReply'
			if(replyingToID > 0) {
				baseXML.service.args["meta"]["r_resource"]["title"] = "commentReply";
			}  else {
				baseXML.service.args["meta"]["r_resource"]["title"] = "comment";
			}
			
			// TODO no description?
			baseXML.service.args["meta"]["r_resource"]["description"] = " ";
			
			// No X/Y coordinate, because its a comment, not an annotation
			baseXML.service.args["meta"]["r_annotation"]["x"] = "0";
			baseXML.service.args["meta"]["r_annotation"]["y"] = "0";
			
			// Annotation Start is to the ID of the comment this is a reply to
			// Either 0 (when not a reply) or the ID
			baseXML.service.args["meta"]["r_annotation"]["start"] = "" + replyingToID;
			
			// Set the annotation text
			baseXML.service.args["meta"]["r_annotation"]["text"] = commentText;
			
			// The type of the annotation (either COmment or Annotation)
			baseXML.service.args["meta"]["r_annotation"]["annotationType"] = Model_Commentary.COMMENT_TYPE_ID + "";
			
			// Its not transcoded, but its an annotation....so wathever :P lol
			baseXML.service.args["meta"]["r_media"]["transcoded"] = "false";
			
			trace("new comment stuff", baseXML);
			if(_connection.sendRequest(baseXML, setCommentClassifaction)) {
				//All good
			} else {
				Alert.show("Could not save comment");
			}
		}	
		
		/**
		 * Called when comment has finished saving in database. Converts the data returned
		 * to a Model_annotation. Calls @see BrowserController.commentSaved
		 * @param e
		 * 
		 */		
		private function setCommentClassifaction(e:Event):void {
			var dataXML:XML = XML(e.target.data);
			this.commentID = dataXML.reply.result.id;

			// Copy the ACLs from the parent asset, to the comment
			var transaction:Transaction_CopyAccess = new Transaction_CopyAccess(commentParentID, commentID, _connection);
			
			// Add the 'Annotation' Classification to the comment asset
			var args:Object = new Object();
			var baseXML:XML = _connection.packageRequest('asset.class.add',args,true);
			baseXML.service.args["scheme"] = "recensio";
			baseXML.service.args["class"] = "base/resource/annotation";
			baseXML.service.args["id"] = commentID;
			_connection.sendRequest(baseXML,null);
			
			// Sending Notification
			AppModel.getInstance().sendNotification(this.commentParentID, "add a comment", commentID);
			
			trace("Comment Saved");
			callback(commentID, commentText, newCommentObject);
		}
	}
}