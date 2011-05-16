package View.components
{
	public interface LoadableContent
	{
		/**
		 * Changes how the Class dispalys when content is being loaded 
		 * 
		 */		
		function loadingContent():void;
		
		/**
		 * Reverts to regular appearance when content has finished loading. 
		 * 
		 */		
		function loadingContentComplete():void;
	}
}