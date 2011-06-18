package View.components.MediaViewer.VideoViewer
{
	import Controller.IDEvent;
	
	import Model.Model_Commentary;
	
	import View.components.Annotation.AnnotationBox;
	import View.components.Annotation.AnnotationHighlight;
	import View.components.Annotation.AnnotationPen;
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	import View.components.MediaViewer.PDFViewer.PDFMedia;

	public class VideoAndAnnotationHolder extends MediaAndAnnotationHolder
	{

		public function VideoAndAnnotationHolder()
		{
			super(MEDIA_VIDEO);

		}
		
		public function play():void {
			(media as VideoMedia).play();
		}
		
		public function pause():void {
			(media as VideoMedia).pause();
		}
		
		public function seekTo(time:Number):void {
			(media as VideoMedia).seekTo(time);
		}
		public function getPlayheadTime():Number {
			return (media as VideoMedia).getPlayheadTime();
		}
		
		/**
		 * Adds the annotations to the display. Called ever tick of the timeline.
		 * It will not add annotations until the annotations and media have loaded. 
		 * 
		 */		
		public function readdAnnotationsToDisplay():void {
			if(annotationsLoaded && mediaLoaded) {
				addAnnotationsToDisplay();
			}
		}
		
		private function removeAnnotationsTime():void {
			var newAnnotations:Array = new Array();
			for(var i:Number = 0; i < annotations.length; i++) {
				try {
					var annotation:AnnotationBox = annotations[i] as AnnotationBox;
				
					if(annotation.getStartTime() < (media as VideoMedia).getPlayheadTime() &&
						annotation.getEndTime() > (media as VideoMedia).getPlayheadTime()) {
						// If we should still be displaying this annotation, keep it in the array
						newAnnotations.push(annotation);
					} else {
						this.removeChild(annotation);
					}
				} catch (e:Error) {
					trace("constantly erroring");
					// Not an annotation box, fix this later TODO
				}
			}
			annotations = newAnnotations;
		}
		
		override protected function addAnnotationsToDisplay():void {
			this.removeAnnotationsTime();

			// Go through all the annotations
			for(var i:Number = 0; i < annotationsData.length; i++) {
				
				var annotationData:Model_Commentary = annotationsData[i] as Model_Commentary;
				
				if (annotationData.start > (media as VideoMedia).getPlayheadTime() ||
					annotationData.end < (media as VideoMedia).getPlayheadTime()) {
					event = new IDEvent(IDEvent.HIDE_ANNOTATATION, true);
					event.data.id = annotationData.base_asset_id;
					this.dispatchEvent(event);
					continue;
				}
				
				var annotationAlreadyDisplayed:Boolean = false;
				for(var j:Number = 0; j < annotations.length; j++) {
					try {
						if((annotations[i] as AnnotationBox).getID() == annotationData.base_asset_id) {
							annotationAlreadyDisplayed = true;
						}
					} catch(e:Error) {
						// probalby not a box annotation
					}
				}
				
				if(!annotationAlreadyDisplayed && 
					annotationData.start < (media as VideoMedia).getPlayheadTime() &&
					annotationData.end > (media as VideoMedia).getPlayheadTime()) {
					
					
//					trace("annotation matches current time");
					if(annotationData.annotationType == Model_Commentary.ANNOTATION_BOX_TYPE_ID) {
						// Its a annotation box
//						trace("Adding box annotation", annotationData.annotation_x, annotationData.annotation_y);
						// Make a new annotation box
						var annotation:AnnotationBox = new AnnotationBox(
							annotationData.base_asset_id,
							annotationData.meta_creator, 
							annotationData.annotation_text,
							annotationData.annotation_height, 
							annotationData.annotation_width, 
							annotationData.annotation_x,
							annotationData.annotation_y,
							annotationData.start,
							annotationData.end
						);
//						trace("Added at", annotation.x, annotation.y);
						
						this.addChild(annotation);
						annotations.push(annotation);
						var event:IDEvent = new IDEvent(IDEvent.SHOW_ANNOTATION, true);
						event.data.id = annotationData.base_asset_id;
						event.data.author = annotationData.meta_creator;
						event.data.x = annotation.x;
						event.data.y = annotation.y;
						event.data.width = annotationData.annotation_width;
						event.data.text = annotationData.annotation_text;
						this.dispatchEvent(event);
						
						
					} else if (annotationData.annotationType == Model_Commentary.ANNOTATION_PEN_TYPE_ID) {
//						trace("Adding pen annotation");
						var annotationPen:AnnotationPen = new AnnotationPen(
							annotationData.base_asset_id,
							annotationData.meta_creator,
							annotationData.path,
							annotationData.annotation_text
						);
						
						this.addChild(annotationPen);
						annotations.push(annotationPen);
					} else if (annotationData.annotationType == Model_Commentary.ANNOTATION_HIGHLIGHT_TYPE_ID) {
//						trace("Adding an highlight annotation");
						var annotationHighlight:AnnotationHighlight = new AnnotationHighlight(
							annotationData.base_asset_id,
							annotationData.meta_creator,
							annotationData.annotation_text,
							annotationData.annotation_x,
							annotationData.annotation_y,
							annotationData.annotation_linenum,
							annotationData.annotation_start,
							annotationData.annotation_end,
							media as PDFMedia
						);
						//TODO make this work with scaling, it wont
						
						this.addChild(annotationHighlight);
						annotations.push(annotationHighlight);
					} else {
//						trace("Unknown annotation");
					}
				} 
			}
		}
		
	}
}