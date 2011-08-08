package Model.Transactions
{
	import Controller.Utilities.Auth;
	
	import Model.AppModel;
	import Model.Utilities.Connection;
	
	import View.components.Panels.Sharing.SharingPanel;
	
	import flash.events.Event;

	public class Transaction_CloneMedia
	{
		private var connection:Connection; // The Mediaflux connection
		private var mediaID:Number; // THe ID of the media to clone
		private var callback:Function;
		private var clonedMediaID:Number;
		
		public function Transaction_CloneMedia(connection:Connection)
		{
			this.connection = connection;
		}
		
		/**
		 * Clones the media. Copies all data except comments/annotations 
		 * @param mediaID	The ID of them edit
		 * @param callback	The function to call when completed - callback(newMediaID:Number);
		 * 
		 */		
		public function cloneMedia(mediaID:Number, callback:Function):void {
			this.mediaID = mediaID;
			this.callback = callback;
			
			var args:Object = new Object();
			args.id = mediaID;
			connection.sendRequest(
				connection.packageRequest('asset.get', args, true), 
				copyMeta
			);
		}
		
		private function copyMeta(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("Transaction_CloneMedia:copyMeta - Failed to get asset", e.target.data);
				callback(-1);
				return;
			}
			
			var dataXML:XML = new XML(e.target.data);
			
			var args:Object = new Object();
			trace("Transaction_CloneMedia:copyMeta - New meta is ", args);
			
			var baseXML:XML = connection.packageRequest('asset.create', args, true);
			baseXML.service.args.clone.@version = 0;
			baseXML.service.args.clone.@meta = false;
			baseXML.service.args.clone.@content = true;
			baseXML.service.args.clone = mediaID;
			baseXML.service.args.namespace = dataXML.reply.result.asset.namespace;
			baseXML.service.args.type = dataXML.reply.result.asset.type;
			baseXML.service.args.meta.r_base = dataXML.reply.result.asset.meta.r_base;
			baseXML.service.args.meta.r_resource = dataXML.reply.result.asset.meta.r_resource;
			baseXML.service.args.meta.r_resource.clone = true;
			baseXML.service.args.meta.r_resource.clone_of_id = mediaID;
			baseXML.service.args.meta.r_media = dataXML.reply.result.asset.meta.r_media;
			connection.sendRequest(baseXML, assetCreated);
		}
		
		private function assetCreated(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("Transaction_CLoneMedia:assetCreated - Failed to clone asset", e.target.data);
				callback(-1);
				return;
			}

			clonedMediaID = XML(e.target.data).reply.result.id;
			
			var args:Object = new Object();
			var baseXML:XML = connection.packageRequest('asset.class.add',args,true);
			baseXML.service.args["scheme"] = "recensio";
			baseXML.service.args["class"] = "base/resource/media";
			baseXML.service.args["id"] = clonedMediaID;
			
			connection.sendRequest(baseXML, classSet);
		
		}
		
		private function classSet(e:Event):void {
			if(!AppModel.getInstance().callSuccessful(e)) {
				trace("Transaction_CLoneMedia:classSet - Failed to set class", clonedMediaID, e.target.data);
				callback(-1);
				return;
			}
			
			AppModel.getInstance().changeAccess(clonedMediaID, Auth.getInstance().getUsername(), "system", SharingPanel.READWRITE, false, function(e:Event):void {
				if(!AppModel.getInstance().callSuccessful(e)) {
					trace("Transaction_CLoneMedia:classSet - Failed to set creator access for", clonedMediaID, e.target.data);
					callback(-1);
					return;
				}
				
				trace("Transaction_CLoneMedia:classSet - Access set successfully", clonedMediaID, e.target.data);
				callback(clonedMediaID);
			});
		}
	}
}