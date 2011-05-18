package Lib
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.rpc.xml.SimpleXMLEncoder;

	/**
	 * Stores a list of lines (made up of 2 x,y coordinate pairs) 
	 * @author cmcnamara87
	 * 
	 */	
	public class AnnotationCoordinateCollection
	{
		private var coordinateArray:Array;
		
		public function AnnotationCoordinateCollection()
		{
			this.coordinateArray = new Array();
		}
		
		public function addCoordinates(x1C:Number, y1C:Number, x2C:Number, y2C:Number):void {
			// We store it this way, so its easy to convert to a XML document using the simpleXMLEncoder
			// storing it in another array structure, creates many redundant xml elements
			var object:Object = new Object();
			object.x1 = x1C;
			object.x2 = x2C;
			object.y1 = y1C;
			object.y2 = y2C;
			//coordinateArray.push([{x1:x1C, y1:y1C, x2:x2C, y2:y2C}]);
			coordinateArray.push(object);
			// Example xml output
			//<root><item><x1>160</x1><x2>160</x2><y1>147</y1><y2>149</y2></item><item><x1>160</x1><x2>160</x2><y1>149</y1><y2>156</y2></item>
		}
		
		/**
		 * Gets the number of coordinate pairs saved 
		 * @return The number of coordinate pairs saved
		 * 
		 */		
		public function getCount():Number {
			return coordinateArray.length;
		}
		
		private function objectToXML(obj:Object):XML 
		{
			var qName:QName = new QName("root");
			var xmlDocument:XMLDocument = new XMLDocument();
			var simpleXMLEncoder:SimpleXMLEncoder = new SimpleXMLEncoder(xmlDocument);
			var xmlNode:XMLNode = simpleXMLEncoder.encodeValue(obj, qName, xmlDocument);
			var xml:XML = new XML(xmlDocument.toString());
			
			return xml;
		}
		
		/**
		 * Converts the coordinateArray to a String that can be then stored in the MediaFlux data
		 * 
		 * It takes all the fixed coordinate values in the current array, and makes them percentages so they
		 * can be scaled by the zoom command.
		 * 
		 * @param height	The height of the media when the annotation was made
		 * @param width		The width of the media, when the annotation was made
		 * @return 
		 * 
		 */		
		public function getString(height:Number, width:Number):String {
			// Scale all the coordinates
			trace("xml", objectToXML(coordinateArray).toXMLString());
			for(var i:Number = 0; i < coordinateArray.length; i++) {
				var item:Object = coordinateArray[i] as Object;
				item.x1 = item.x1 / width;
				item.x2 = item.x2 / width;
				item.y1 = item.y1 / height;
				item.y2 = item.y2 / height;
			}
			return objectToXML(coordinateArray).toXMLString();	
		}
	}
}