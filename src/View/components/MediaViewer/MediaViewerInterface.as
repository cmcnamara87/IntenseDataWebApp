package View.components.MediaViewer
{
	public interface MediaViewerInterface
	{
		function addAnnotations(annotationsArray:Array):void;
		
		function load(url:String):void;
		
		function enterNewAnnotationMode():void;
		
		function highlightAnnotation(assetID:Number, showText:Boolean=true):void;
		
		function unhighlightAnnotation(assetID:Number):void;
		
		function hideAnnotations():void;
		
		function showAnnotations():void;
	}
}