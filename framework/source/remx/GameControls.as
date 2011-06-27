package remx
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.system.Capabilities;
	import flash.system.TouchscreenType;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;

	/**
	 */
	public final class GameControls extends GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public const MOUSE_BUTTON_LEFT:uint  = 0;
		public const MOUSE_BUTTON_RIGHT:uint = 1;

		public var mouseX:Number = 0.0;
		public var mouseY:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES - EVENTS
		//
		//------------------------------------------------------------------------------------------

		public var onKeyPress:Function           = null; // ( key:uint ):void
		public var onKeyRelease:Function         = null; // ( key:uint ):void
		public var onMouseButtonPress:Function   = null; // ( button:uint ):void
		public var onMouseButtonRelease:Function = null; // ( button:uint ):void

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		private var pressedKeys:Dictionary         = new Dictionary();
		private var pressedMouseButtons:Dictionary = new Dictionary();

		private var touchPointID:int = 0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameControls()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function pressKey( key:uint ):void
		{
			if( pressedKeys[key] == null )
			{
				pressedKeys[key] = key;
				broadcastKeyPress( key );
			}
		}

		/**
		 */
		public function releaseKey( key:uint ):void
		{
			if( pressedKeys[key] != null )
			{
				delete pressedKeys[key];
				broadcastKeyRelease( key );
			}
		}

		/**
		 */
		public function releaseKeys():void
		{
			for each( var key:uint in pressedKeys )
			{
				releaseKey( key );
			}
		}

		/**
		 */
		public function isKeyPressed( key:uint ):Boolean
		{
			return pressedKeys[key] != null;
		}

		/**
		 */
		public function pressMouseButton( button:uint=0 ):void
		{
			if( pressedMouseButtons[button] == null )
			{
				pressedMouseButtons[button] = button;
				broadcastMouseButtonPress( button );
			}
		}

		/**
		 */
		public function releaseMouseButton( button:uint=0 ):void
		{
			if( pressedMouseButtons[button] != null )
			{
				delete pressedMouseButtons[button];
				broadcastMouseButtonRelease( button );
			}
		}

		/**
		 */
		public function releaseMouseButtons():void
		{
			for each( var button:uint in pressedMouseButtons )
			{
				releaseMouseButton( button );
			}
		}

		/**
		 */
		public function isMouseButtonPressed( button:uint=0 ):Boolean
		{
			return pressedMouseButtons[button] != null;
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal override function initialize( game:GameApp ):void
		{
			this.game = game;

			game.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			game.stage.addEventListener( KeyboardEvent.KEY_UP,   onKeyUp   );

			if( Capabilities.touchscreenType == TouchscreenType.NONE )
			{
				game.stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
				game.stage.addEventListener( MouseEvent.MOUSE_UP,   onMouseUp   );

				RUNTIME::AIR
				{
					game.stage.addEventListener( MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown );
					game.stage.addEventListener( MouseEvent.RIGHT_MOUSE_UP,   onRightMouseUp   );
				}
			}
			else
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

				game.stage.addEventListener( TouchEvent.TOUCH_BEGIN, onTouchBegin );
				game.stage.addEventListener( TouchEvent.TOUCH_END,   onTouchEnd   );
			}
		}

		/**
		 */
		internal override function shutdown():void
		{
			game.stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			game.stage.removeEventListener( KeyboardEvent.KEY_UP,   onKeyUp   );

			if( Capabilities.touchscreenType == TouchscreenType.NONE )
			{
				game.stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
				game.stage.removeEventListener( MouseEvent.MOUSE_UP,   onMouseUp   );

				RUNTIME::AIR
				{
					game.stage.removeEventListener( MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown );
					game.stage.removeEventListener( MouseEvent.RIGHT_MOUSE_UP,   onRightMouseUp   );
				}
			}
			else
			{
				game.stage.removeEventListener( TouchEvent.TOUCH_BEGIN, onTouchBegin );
				game.stage.removeEventListener( TouchEvent.TOUCH_END,   onTouchEnd   );
			}
		}

		/**
		 */
		internal override function update():void
		{
			var x:Number = game.stage.mouseX;
			var y:Number = game.stage.mouseY;

			mouseX = x < 0.0 ? 0.0 : x >= game.width  ? game.width  - 1.0 : x;
			mouseY = y < 0.0 ? 0.0 : y >= game.height ? game.height - 1.0 : y;
		}

		/**
		 */
		internal override function reset():void
		{
			onKeyPress           = null;
			onKeyRelease         = null;
			onMouseButtonPress   = null;
			onMouseButtonRelease = null;

			releaseKeys();
			releaseMouseButtons();
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - BROADCASTERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function broadcastKeyPress( key:uint ):void
		{
			if( onKeyPress != null )
			{
				onKeyPress( key );
			}
		}

		/**
		 */
		private function broadcastKeyRelease( key:uint ):void
		{
			if( onKeyRelease != null )
			{
				onKeyRelease( key );
			}
		}

		/**
		 */
		private function broadcastMouseButtonPress( button:uint ):void
		{
			if( onMouseButtonPress != null )
			{
				onMouseButtonPress( button );
			}
		}

		/**
		 */
		private function broadcastMouseButtonRelease( button:uint ):void
		{
			if( onMouseButtonRelease != null )
			{
				onMouseButtonRelease( button );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - NATIVE EVENT LISTENERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function onKeyDown( event:KeyboardEvent ):void
		{
			pressKey( event.keyCode );
		}

		/**
		 */
		private function onKeyUp( event:KeyboardEvent ):void
		{
			releaseKey( event.keyCode );
		}

		/**
		 */
		private function onMouseDown( event:MouseEvent ):void
		{
			pressMouseButton( MOUSE_BUTTON_LEFT );
		}

		/**
		 */
		private function onMouseUp( event:MouseEvent ):void
		{
			releaseMouseButton( MOUSE_BUTTON_LEFT );
		}

		/**
		 */
		RUNTIME::AIR
		private function onRightMouseDown( event:MouseEvent ):void
		{
			pressMouseButton( MOUSE_BUTTON_RIGHT );
		}

		/**
		 */
		RUNTIME::AIR
		private function onRightMouseUp( event:MouseEvent ):void
		{
			releaseMouseButton( MOUSE_BUTTON_RIGHT );
		}

		/**
		 */
		private function onTouchBegin( event:TouchEvent ):void
		{
			if( touchPointID == 0 )
			{
				touchPointID = event.touchPointID;
				pressMouseButton( MOUSE_BUTTON_LEFT );
			}
		}

		/**
		 */
		private function onTouchEnd( event:TouchEvent ):void
		{
			if( touchPointID == event.touchPointID )
			{
				touchPointID = 0;
				releaseMouseButton( MOUSE_BUTTON_LEFT );
			}
		}

	}// EOC
}