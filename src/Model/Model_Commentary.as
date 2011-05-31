package Model {
	
	public class Model_Commentary extends Model_Base {
		
		public static const ANNOTATION_BOX_TYPE_ID:Number = 2;
		public static const ANNOTATION_PEN_TYPE_ID:Number = 5;
		public static const ANNOTATION_HIGHLIGHT_TYPE_ID:Number = 6;
		public static const COMMENT_TYPE_ID:Number = 3;
		
		public var type:String = "";
		public var commontype:String;
		public var meta_user_id:Number;
		public var meta_obtype:String;
		public var meta_active:Boolean;
		public var meta_creator:String;
		public var annotation_x:Number;
		public var annotation_y:Number;
		public var annotation_width:Number;
		public var annotation_height:Number;
		public var annotation_start:Number;
		public var annotation_end:Number;
		public var annotation_text:String = "";
		public var annotation_path:String = "";
		public var annotation_linenum:Number;
		public var annotation_type:Number; // Either ANNOTATION_TYPE_ID or COMMENT_TYPE_ID
		
		public var reply_id:Number; // ONLY USE THESE WITH DEKKERS CODE
		public var parentID:Number = 0; // ONLY USE THESE WITH DEKKERS CODE
		
		public function Model_Commentary() {
			super();
		}
		
		public function isAnnotation():Boolean {
			if(type == "Annotation") {
				return true;
			} else {
				return false;
			}
		}
		
		/*
			Getters and setters to deal with annotation modules having different ways of setting/getting annotation and comment information
		*/
		
		public function get x():Number {
			return annotation_x;
		}
		
		public function get y():Number {
			return annotation_y;
		}
		
		public function get width():Number {
			return annotation_width;
		}
		
		public function get height():Number {
			return annotation_height;
		}
		
		public function get start():Number {
			return annotation_start;
		}
		
		public function get end():Number {
			return annotation_end;
		}
		
		public function get text():String {
			return annotation_text;
		}
		
		public function get path():String {
			return annotation_path;
		}
		
		public function get annotationType():Number {
			return annotation_type;
		}
		
		public function set x(newX:Number):void {
			annotation_x = newX;
		}
		
		public function set y(newY:Number):void {
			annotation_y = newY;
		}
		
		public function set width(newWidth:Number):void {
			annotation_width = newWidth;
		}
		
		public function set height(newHeight:Number):void {
			annotation_height = newHeight;
		}
		
		public function set start(newStart:Number):void {
			annotation_start = newStart;
		}
		
		public function set end(newEnd:Number):void {
			annotation_end = newEnd;
		}
		
		public function set text(newText:String):void {
			annotation_text = newText;
		}
		
		public function set path(newPath:String):void {
			annotation_path = newPath;
		}
		
		public function set annotationType(newAnnotationType:Number):void {
			annotation_type = newAnnotationType;
		}
		
		/**
		 * Gets out the percentWidth * percentHeight of hte annotation,
		 * to give the area the annotation takes up.
		 * Used in @see ImageViewer to sort the annotations by size,
		 * to make sure no larger annotations appear on top of smaller ones. 
		 * @return 
		 * 
		 */		
		public function get annotationArea():Number {
			return annotation_width * annotation_height
		} 
			
		// Sets the specific data for the comment/annotation type
		override protected function setSpecificData():void {
			commontype = rawData.meta.r_resource.title;
			meta_user_id = rawData.meta["mf-revision-history"].user.@id;
			meta_obtype = rawData.meta.r_base.obtype;
			meta_active = stringToBool(rawData.meta.r_base.active);
			meta_creator = rawData.meta.r_base.creator;
			annotation_x = rawData.meta.r_annotation.x;
			annotation_y = rawData.meta.r_annotation.y;
			annotation_width = rawData.meta.r_annotation.width;
			annotation_height = rawData.meta.r_annotation.height;
			annotation_start = rawData.meta.r_annotation.start;
			annotation_end = rawData.meta.r_annotation.end;
			annotation_text = rawData.meta.r_annotation.text;
			annotation_path = rawData.meta.r_annotation.path;
			annotation_type = rawData.meta.r_annotation.annotationType;
			annotation_linenum = rawData.meta.r_annotation.lineNum;
			//Figure out whether an annotation or a comment
			switch(annotation_type) {
				case ANNOTATION_BOX_TYPE_ID:
					type = "Annotation";
					break;
				case COMMENT_TYPE_ID:
					type = "Comment";
					break;
				case ANNOTATION_PEN_TYPE_ID:
					type = 'Pen Annotation';
					break;
				case ANNOTATION_HIGHLIGHT_TYPE_ID:
					type = 'Highlight Annotation';
					break;
				default:
					throw new Error(this.base_asset_id+" IS NOT A COMMENT OR AN ANNOTATION");
			}
		}
	}
}