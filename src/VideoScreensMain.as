package {
	import com.gskinner.utils.Rndm;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.GestureEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Multitouch;
	import flash.utils.getTimer;
	import med.display.ImageSlide;
	import med.display.Slide;
	import med.display.TextContent;
	import med.display.TextSlide;
	import med.display.VideoSlide;

	public class VideoScreensMain extends MovieClip {
		
		//5400 x 3840
		static public var STAGE_WIDTH:Number = 5400;
		static public var STAGE_HEIGHT:Number = 3840;

		protected var xmlLoader:URLLoader;
		protected var loadedXML:XML;
		
		protected var lastFrameTime:Number;
		
		protected var slides:Vector.<Slide>;
		

		public function VideoScreensMain() {
			scaleX = scaleY = 0.1;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}

		protected function handleAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			init();
		}

		protected function init():void {
			
			new _FontDump();

			//xmlLoader = new URLLoader();
			//xmlLoader.addEventListener(Event.COMPLETE, handleXMLLoaded);
			//xmlLoader.load(new URLRequest("BoxesData.XML"));

			stage.addEventListener(MouseEvent.CLICK, handleFullScreenClick);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenChange);
			
			begin();
		}

		/*
		protected function handleXMLLoaded(event:Event):void {
			loadedXML = new XML(xmlLoader.data);

			xmlLoader.removeEventListener(Event.COMPLETE, handleXMLLoaded);
			xmlLoader = null;

			StorySetup.preloadImages(loadedXML)

			addEventListener(Event.ENTER_FRAME, handleCheckImagesLoaded);
		}
		
		protected function handleCheckImagesLoaded(event:Event):void {
			if (AssetManager.isLoading) return;
			removeEventListener(Event.ENTER_FRAME, handleCheckImagesLoaded);			

			StorySetup.readStorySet(loadedXML);

			begin();
		}
		*/
		
		
		protected function clear():void {
			//removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			removeEventListener(Event.ENTER_FRAME, handleAnimate);
		}



		protected function begin():void {			
			
			graphics.beginFill(0x345678);
			graphics.drawRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
			graphics.endFill();
			
			
			slides = new Vector.<Slide>();
			
			/*
			addSlide(new VideoSlide("assets/MVI_0080.MOV", 1920, 1088));
			addSlide(new ImageSlide("assets/TestImage.jpg", 1152, 2048));
			addSlide(new VideoSlide("assets/MVI_0074.MOV", 1920, 1088));
			addSlide(new TextSlide());
			addSlide(new VideoSlide("assets/MVI_0106.MOV", 1920, 1088));
			*/
			
			addSlide(new VideoSlide("assets/MVI_0074.MOV", 1920, 1088));
			addSlide(new ImageSlide("assets/TestImage.jpg", 1152, 2048));
			addSlide(new TextSlide());
			addSlide(new ImageSlide("assets/TestImage.jpg", 1152, 2048));
			addSlide(new TextSlide());
			
			
			//addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			addEventListener(Event.ENTER_FRAME, handleAnimate);			
			
			lastFrameTime = getTimer();
		}

		protected function addSlide(slide:Slide):void {
			var x:Number = 0;
			if (slides.length > 0) {
				var last:Slide = slides[slides.length - 1];
				x = last.x;
			}
			x -= slide.getWidth();
			slide.x = Math.ceil(x);
			addChild(slide);
			slides.push(slide);
		}

		protected function handleAnimate(event:Event):void {
			var i:int;
			var time:Number = getTimer();
			var dTime:Number = time - lastFrameTime;
			
			var speed:Number = 500;
			//var dx:Number = speed * dTime / 1000;
			var dx:Number = speed * 1 / stage.frameRate;
			dx = Math.round(dx);
			dx = Math.round(speed / stage.frameRate);
			
			for (i = slides.length - 1; i >= 0; i--) {
				var slide:Slide = slides[i];
				slide.x += dx;
				
				if (slide.x > STAGE_WIDTH) {
					slides.splice(i, 1);
					if (slide.parent) slide.parent.removeChild(slide);
					
					slide.reset();
					addSlide(slide);
				}
				
				var right:Number = slide.x + slide.getWidth();
				slide.onScreen = (right > 0);
				
			}
			
			
			lastFrameTime = time;
		}
		

		protected function handleFullScreenClick(event:MouseEvent):void {
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.removeEventListener(MouseEvent.CLICK, handleFullScreenClick);
		}
		protected function handleFullScreenChange(event:FullScreenEvent):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.addEventListener(MouseEvent.CLICK, handleFullScreenClick);
			}
		}
		
		
		
		
		
			
		
		







	}

}