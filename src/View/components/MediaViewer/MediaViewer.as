package View.components.MediaViewer
{
	import spark.components.BorderContainer;
	
	public class MediaViewer extends BorderContainer
	{
		public function MediaViewer()
		{
			super();
			
			// Setup the size
			this.percentHeight = 100;
			this.percentWidth = 100;
		}
		
		public function addAnnotations(annotationsArray:Array):void {
//			throw new Error("addAnnotations in MediaViewer: Should be overwritten");
		}
		
		public function hideAnnotations():void {
//			throw new Error("hideAnnotations in MediaViewer: Should be overwritten");
		}
		
		public function showAnnotations():void {
//			throw new Error("showAnnotations in MediaViewer: Should be overwritten");
		}
		
		public function load(url:String):void {
//			throw new Error("load in MediaViewer: Should be overwritten");
		}
		
		public function enterNewAnnotationMode():void {
//			throw new Error("enterNewAnnotationMode in MediaViewer: Should be overwritten");
		}
		
		public function highlightAnnotation(assetID:Number):void {
			//throw new Error("highlightAnnotation in MediaViewer: Should be overwritten");
//			trace("Error: highlightAnnotation in MediaViewer: Should be overwritten");
		}
		
		public function unhighlightAnnotation(assetID:Number):void {
			//throw new Error("unhighlightAnnotation in MediaViewer: Should be overwritten");
//			trace("unhighlightAnnotation in MediaViewer: Should be overwritten");
		}
		
		public function clearNonSavedAnnotations():void {
			
		}
		
		public function saveNewAnnotation():void {
			trace("Should have run the child of this");	
		}
		
		public function showAnnotationTextOverlayTextEntryMode():void {
			
		}
	}
}