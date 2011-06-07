package View.components.MediaViewer
{
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;

	public class VideoViewer extends SpaceViewer
	{
		public function VideoViewer()
		{
			super(MediaAndAnnotationHolder.MEDIA_VIDEO);
		}
		
		override protected function makeMedia():MediaAndAnnotationHolder {
			return new MediaAndAnnotationHolder(MediaAndAnnotationHolder.MEDIA_VIDEO); 
		}
		
	}
}