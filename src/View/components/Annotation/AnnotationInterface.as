package View.components.Annotation
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public interface AnnotationInterface
	{
		function save():void;

		function highlight():void;
		
		function unhighlight():void;
		
		function getID():Number;
		
		function isInLowerHalf():Boolean;
		
		function getAuthor():String;
		
		function getText():String;
		
		function getX():Number;
		
		function getY():Number;
		
		function getHeight():Number;
		
		function localToLocal(containerFrom:DisplayObject, containerTo:DisplayObject, origin:Point):Point;
	}
}