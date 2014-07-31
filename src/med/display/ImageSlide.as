package med.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;

	public class ImageSlide extends Slide {

		protected var loader:Loader;
		protected var bitmap:Bitmap;

		public function ImageSlide(url:String, sourceWidth:Number, sourceHeight:Number) {			
			_width = sourceWidth * (VideoScreensMain.STAGE_HEIGHT / sourceHeight);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleImageLoaded);
			loader.load(new URLRequest(url));
		}		
		protected function handleImageLoaded(event:Event):void {
			var info:LoaderInfo = event.target as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, handleImageLoaded);
			var image:BitmapData = (info.content as Bitmap).bitmapData;
			
			var bitmap:Bitmap = new Bitmap(image);
			bitmap.smoothing = true;
			bitmap.height = VideoScreensMain.STAGE_HEIGHT;
			bitmap.scaleX = bitmap.scaleY;
			addChild(bitmap);
			
			cacheAsBitmap = true;			
		}

	}

}