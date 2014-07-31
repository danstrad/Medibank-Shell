package med.display {
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class VideoSlide extends Slide {

		protected var url:String;

		protected var nc:NetConnection;
		protected var ns:NetStream;
		protected var video:Video;
		
		
		public function VideoSlide(url:String, sourceWidth:Number, sourceHeight:Number) {
			showVideo(url, sourceWidth, sourceHeight);
		}

		public function dispose():void {
			if (ns) ns.close();
			if (video) {
				video.clear();
				video.attachNetStream(null);
			}
		}

		protected function showVideo(url:String, sourceWidth:Number, sourceHeight:Number):void {
			this.url = url;
			
			//Create a new Video object that display the video and add it to the stage display list, as shown in the following snippet:
			video = new Video();
			addChild(video);

			nc = new NetConnection();
			nc.connect(null);

			//Create a NetStream object, passing the NetConnection object as an argument to the constructor. The following snippet connects a NetStream object to the NetConnection instance and sets up the event handlers for the stream:
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.client = { onMetaData:function(obj:Object):void { } }
			
			video.attachNetStream(ns);
			ns.play(url);

			video.smoothing = true;
			video.height = VideoScreensMain.STAGE_HEIGHT;
			video.width = _width = VideoScreensMain.STAGE_HEIGHT * sourceWidth / sourceHeight;
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			if (event.info.code == "NetStream.Buffer.Empty") {
				ns.seek(0);
				ns.resume();
			}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void {
		}
		
		override protected function disable():void {
			super.disable();
			ns.pause();
		}
		override protected function enable():void {
			super.enable();
			ns.resume();
		}
	}

}