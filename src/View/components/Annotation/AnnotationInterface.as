package View.components.Annotation
{
	public interface AnnotationInterface
	{
		function save():void;
		
		
		function readjust(imageWidth:Number, imageHeight:Number):void;
		
		function highlight():void;
		
		function unhighlight():void;
		
		function getID():Number;
		
		function isInLowerHalf():Boolean;
		
		function getAuthor():String;
		
		function getText():String;
	}
}