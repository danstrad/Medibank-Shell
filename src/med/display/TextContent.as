package med.display {
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextContent extends _TextContent {
		
		protected static const TEXT_SCALE:Number = 1;// 0.4;
		protected static const NATURAL_SIZE:Number = 86;
		public static const MARGIN:Number = ((100 - 86) / 2) * TEXT_SCALE;
		//static public const MARGIN:Number = 7;
		//static public const WIDTH:Number = 86;
		//static public const HEIGHT:Number = 86;

		public static const TYPE_CHAPTER_HEADER:String = "Chapter Header";
		static public const TYPE_STORY_HEADER:String = "Story Header";
		public static const TYPE_QUOTE:String = "Quote";
		public static const TYPE_CONTENT:String = "Content";
		public static const TYPE_LABEL:String = "Label";
		
		protected static var chapterHeaderFormat:TextFormat;
		protected static var storyHeaderFormat:TextFormat;
		protected static var quoteFormat:TextFormat;
		protected static var contentFormat:TextFormat;
		protected static var contentBoldFormat:TextFormat;
		protected static var contentNewlineFormat:TextFormat;
		protected static var labelFormat:TextFormat;
		

		protected function createTextFormats():void {
			var format:TextFormat;			
			chapterHeaderFormat = format = new TextFormat("DINCond-Black", 15);
			format.leading = -5;
			format.letterSpacing = -0.35;
			storyHeaderFormat = format = new TextFormat("DIN Bold", 13);
			format.leading = -1;
			format.letterSpacing = -0.35;
			quoteFormat = format = new TextFormat("DIN Bold", 20);// 11);
			format.leading = -2;
			format.letterSpacing = -0.35;
			contentFormat = format = new TextFormat("DIN", 11);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentBoldFormat = format = new TextFormat("DIN Bold", 11);
			format.leading = 0;//-2;
			format.letterSpacing = -0.1;
			contentNewlineFormat = format = new TextFormat("DIN", 0);
			format.leading = 0;
			labelFormat = format = new TextFormat("DIN Bold", 27);
			format.leading = -2;
			format.letterSpacing = -0.35;
			format.align = TextFormatAlign.CENTER;
		}

		
		
		protected static const MOMENTUM_FALLOFF:Number = 0.4;
		protected static const INITIAL_WAIT:Number = 5000;
		protected static const TOUCH_WAIT:Number = 2000;
		protected static const END_WAIT:Number = 3000;
		protected static const AUTO_SCROLL:Number = 3;
		
		protected var min:Number;
		protected var max:Number;
		protected var dragY:Number;
		protected var mouseInteractor:DisplayObjectContainer;
		protected var momentum:Number;
		protected var dragging:Boolean;
		protected var autoWait:Number;
		protected var autoIncrease:Boolean;
		protected var scrollY:Number;
		
		protected var scrollBar:Shape;
		
		public function get isScroller():Boolean { return (scrollBar != null); }

		public function TextContent(text:String, textType:String, textScale:Number, subtext:String, subtextScale:Number, width:Number, height:Number) {
			if (!chapterHeaderFormat) createTextFormats();
			
			textMask.visible = false;
			subtextField.visible = false;
			max = 0;

			if (textType == TYPE_LABEL) textField.autoSize = TextFieldAutoSize.CENTER;
			else textField.autoSize = TextFieldAutoSize.LEFT;

			text = text.replace(/\n\r/ig, '\n');
			text = text.replace(/\r\n/ig, '\n');
			text = text.replace(/\r/ig, '\n');

			if (textType == TYPE_CONTENT) {
				
				textField.text = "";
				var carat:int = 0
				var len:int;
				var i:int = 0;
				var boldStart:int;
				var boldEnd:int;
				while(true) {
					boldStart = text.indexOf("[b]", i);
					boldEnd = text.indexOf("[/b]", boldStart);
					if ((boldStart >= 0) && (boldEnd >= 0)) {
						len = boldStart - i;
						if (len > 0) {
							textField.appendText(text.substr(i, len));
							textField.setTextFormat(contentFormat, carat, carat + len);
							carat += len;
						}
						len = boldEnd - boldStart - 3;
						if (len > 0) {
							textField.appendText(text.substr(boldStart + 3, len));
							textField.setTextFormat(contentBoldFormat, carat, carat + len);
							carat += len;
						}
					} else {
						len = text.length - i;
						if (len > 0) {
							textField.appendText(text.substr(i, len));
							textField.setTextFormat(contentFormat, carat, carat + len);
							carat += len;
						}
						break;
					}
					i = boldEnd + 4;
				};
				var tft:String = textField.text;
				for (i = tft.lastIndexOf('\r'); i >= 0; i = tft.lastIndexOf('\r', i - 1)) {
					textField.replaceText(i, i, '\n');
					textField.setTextFormat(contentNewlineFormat, i, i + 1);					
				}
				textField.width = width;
				textField.height = height;
				textField.x = Math.round(-textField.width / 2);
				textField.y = Math.round(-height / 2);

				setupScrolling(width, height);
				
			} else {
				switch(textType) {
					case TYPE_CHAPTER_HEADER: textField.defaultTextFormat = chapterHeaderFormat; break;
					default:
					case TYPE_STORY_HEADER: textField.defaultTextFormat = storyHeaderFormat; break;
					case TYPE_QUOTE: textField.defaultTextFormat = quoteFormat; break;
					case TYPE_LABEL: textField.defaultTextFormat = labelFormat; break;
				}
				
				
				textField.text = text;
				
				var scale:Number = Math.min(width, height) / NATURAL_SIZE * textScale;
				textField.scaleX = textField.scaleY = scale;
				textField.width = width / scale;
				textField.height = height / scale;
				
				switch(textType) {
					case TYPE_LABEL:
						textField.x = -textField.width / 2;
						textField.y = -textField.height / 2 - 2 * TEXT_SCALE;
						break;
					case TYPE_QUOTE:
						while (textField.height > height) {
							scale -= 0.05;
							textField.scaleX = textField.scaleY = scale;
							textField.width = width / textField.scaleX;
							textField.height = height / textField.scaleY;
						}
						textField.x = Math.round(-width / 2);
						textField.y = -height / 2 - 4 * TEXT_SCALE;
						break;
					default:
						textField.x = Math.round(-width / 2);
						textField.y = -height / 2 - 4 * TEXT_SCALE;
						break;
				}
				
				if (subtext) {
					subtextField.autoSize = TextFieldAutoSize.LEFT;
					subtextField.visible = true;
					subtextField.defaultTextFormat = contentFormat;
					subtextField.text = subtext;
					subtextField.scaleX = subtextField.scaleY = Math.min(width, height) / NATURAL_SIZE * subtextScale;
					subtextField.x = textField.x;
					subtextField.y = 0;
					subtextField.width = textField.width / subtextField.scaleX;
					subtextField.height = height / 2;
				}
			}
			
		}
		
		protected function setupScrolling(width:Number, height:Number):void {
			if (textField.height > height) {
				textField.width -= 10;
				
				scrollY = textField.y;
				min = textField.y - (textField.height - height);
				max = textField.y;
				momentum = 0;
				autoIncrease = false;
				textMask.width = textField.width;
				textMask.height = height;
				textMask.x = textField.x +  textField.width / 2;
				textField.mask = textMask;
				
				autoWait = INITIAL_WAIT;
				
				scrollBar = new Shape();
				scrollBar.graphics.beginFill(0xFFFFFF, 0.3);
				scrollBar.graphics.drawRect(0, 0, 2, height * (height / textField.height));
				scrollBar.graphics.endFill();
				addChild(scrollBar);
				scrollBar.x = width / 2 - 2;
				
				scrollTo(0);
				
				addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			}
		}
		
		
		protected function handleAddedToStage(event:Event):void {
			for (mouseInteractor = this; mouseInteractor != null; mouseInteractor = mouseInteractor.parent) {
				if (!mouseInteractor.mouseChildren) {
					break;
				} else if (mouseInteractor == stage) {
					mouseInteractor = this;
					break;
				}
			}
			if (!mouseInteractor) return;
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, 0, true);
			mouseInteractor.addEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false, 0, true);			
		}
		protected function handleRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			mouseInteractor.removeEventListener(MouseEvent.MOUSE_DOWN, handleBeginDrag, false);			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp, false);
			dragging = false;
		}

		
		protected function handleBeginDrag(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleUp, false, 0, true);
			dragY = scrollY - mouseInteractor.mouseY;
			dragging = true;
		}
		protected function handleUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp, false);
			dragging = false;
		}
		protected function handleMove(event:MouseEvent):void {
			var target:Number = mouseInteractor.mouseY + dragY;
			var current:Number = scrollY;
			scrollTo(target);
			momentum += (target - current);
			autoWait = TOUCH_WAIT;
			if (target > current) autoIncrease = true;
			if (target < current) autoIncrease = false;
		}
		
		public function animate(dTime:Number):void {
			if (max == 0) return;
			momentum *= (1 - MOMENTUM_FALLOFF);
			if (!dragging) {
				if (momentum < 0) {
					scrollTo(scrollY + momentum);
					if (momentum > -1) momentum = 0;				
					if (scrollY == min) {
						momentum = 0;
						autoIncrease = true;
						autoWait = Math.max(autoWait, END_WAIT);
					}
				} else if (momentum > 0) {
					scrollTo(scrollY + momentum);
					if (momentum < 1) momentum = 0;				
					if (scrollY == max) {
						momentum = 0;
						autoIncrease = false;
						autoWait = Math.max(autoWait, END_WAIT);
					}
				} else {
					if (autoWait > 0) {
						autoWait = Math.max(0, autoWait - dTime);
					} else {
						var scroll:Number = dTime / 1000 * AUTO_SCROLL;
						if (autoIncrease) {
							if (scrollY + scroll >= max) {
								scrollTo(max);
								autoIncrease = false;
								autoWait = END_WAIT;
							} else {
								scrollTo(scrollY + scroll);
							}
						} else {
							if (scrollY - scroll <= min) {
								scrollTo(min);
								autoIncrease = true;
								autoWait = END_WAIT;
							} else {
								scrollTo(scrollY - scroll);
							}
						}
					}
				}
			}
		}
		
		protected function scrollTo(y:Number):void {
			textField.y = scrollY = Math.max(min, Math.min(max, y));
			scrollBar.y = textMask.y - textMask.height / 2 + (textMask.height - scrollBar.height) * ((scrollY - max) / (min - max));
		}
		
				

	}

}