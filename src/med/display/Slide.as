package med.display {
	import flash.display.Sprite;

	public class Slide extends Sprite {
		
		protected var _width:Number;
		public function getWidth():Number { return _width; }

		protected var _onScreen:Boolean;
		public function set onScreen(value:Boolean):void {
			if (_onScreen == value) return;
			_onScreen = value;
			visible = _onScreen;
			if (_onScreen) enable();
			else disable();
		}
		
		public function Slide() {
			
		}
		
		public function reset():void {
			
		}
		
		protected function enable():void {			
		}
		
		protected function disable():void {			
		}

	}

}