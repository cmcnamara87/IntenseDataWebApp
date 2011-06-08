package View.components.MediaViewer.VideoViewer
{
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	import View.components.MediaViewer.SpaceViewer;

	public class VideoViewer extends SpaceViewer
	{
		public function VideoViewer()
		{
			super(MediaAndAnnotationHolder.MEDIA_VIDEO);
		}
		
		override protected function makeMedia():MediaAndAnnotationHolder {
			return new MediaAndAnnotationHolder(MediaAndAnnotationHolder.MEDIA_VIDEO); 
		}
		
		override protected function makeBottomToolbar():void {
			var zoomOutLabel:Label = new Label();
			zoomOutLabel.text = "Zoom Out";
			sliderResizerContainer.addElement(zoomOutLabel);
		}
	}
}