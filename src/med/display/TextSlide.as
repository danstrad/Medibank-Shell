package med.display {

	public class TextSlide extends Slide {
		
		protected var content:TextContent;

		public function TextSlide() {
			
			var text:String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse leo nisl, consequat non metus ut, lobortis dignissim nisl. Mauris feugiat ornare sodales. Aliquam semper orci sit amet pulvinar pulvinar.";
			content = new TextContent(text, TextContent.TYPE_QUOTE, 1, null, 1, 3000, 3000);
			
			_width = VideoScreensMain.STAGE_HEIGHT;
			addChild(content);
			content.x = _width / 2;
			content.y = VideoScreensMain.STAGE_HEIGHT / 2;
			
			cacheAsBitmap = true;
		}

	}

}