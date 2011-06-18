package View.components.MediaViewer.PDFViewer
{
	import View.components.MediaViewer.MediaAndAnnotationHolder;
	
	public class PDFAndAnnotationHolder extends MediaAndAnnotationHolder
	{
		public function PDFAndAnnotationHolder(mediaType:String)
		{
			super(mediaType);
		}
		
		/**
		 * Searches for text in the media. Should only be used ofr PDFs 
		 * @param text	The string to search for.
		 * @return The y-pos of the first match
		 * 
		 */		
		public function searchForText(text:String):Array {
			// This should only be used for the pdfs whatever!!!!
			// this should alll be extended into another class, ill do it later, on a deadline atm TODO!!!
			return (media as PDFMedia).searchForText(text);
		}
		
		public function getFitHeightSize():Number {
//			if(mediaType == MEDIA_PDF) {
			return (media as PDFMedia).getPageHeight();
//			} else if (mediaType == MEDIA_IMAGE) {
//				return media.height;
//			} else {
//				return -1;
//			}
		}
	}
}