package remx
{
	/**
	 */
	public class Widget extends Graphic
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var enabled:Boolean = true;

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES - EVENTS
		//
		//------------------------------------------------------------------------------------------

		public var onClick:Function   = null; // ( widget:Widget ):void
		public var onPress:Function   = null; // ( widget:Widget ):void
		public var onRelease:Function = null; // ( widget:Widget ):void

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		private var widgetRX:WidgetRX       = null;
		private var widgetFrame:WidgetFrame = null;

		private var pressed:Boolean  = false;
		private var hasMouse:Boolean = false;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Widget()
		{
			interactive = true;
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal override function construct( game:GameApp, rx:GraphicRX ):void
		{
			this.game = game;

			widgetRX    = rx as WidgetRX;
			widgetFrame = widgetRX.frameList[0];

			width  = widgetRX.frameWidth;
			height = widgetRX.frameHeight;

			super.construct( game, rx );
		}

		/**
		 */
		internal override function render( mesh:GraphicMesh ):void
		{
			var x1:Number = mesh.x;
			var y1:Number = mesh.y;
			var x2:Number = x1 + width;
			var y2:Number = y1 + height;

			var i:int = mesh.vertexCount;

			mesh.vertexList[i++] = x1;
			mesh.vertexList[i++] = y1;
			mesh.vertexList[i++] = widgetFrame.u1;
			mesh.vertexList[i++] = widgetFrame.v1;

			mesh.vertexList[i++] = x2;
			mesh.vertexList[i++] = y1;
			mesh.vertexList[i++] = widgetFrame.u2;
			mesh.vertexList[i++] = widgetFrame.v1;

			mesh.vertexList[i++] = x1;
			mesh.vertexList[i++] = y2;
			mesh.vertexList[i++] = widgetFrame.u1;
			mesh.vertexList[i++] = widgetFrame.v2;

			mesh.vertexList[i++] = x2;
			mesh.vertexList[i++] = y2;
			mesh.vertexList[i++] = widgetFrame.u2;
			mesh.vertexList[i++] = widgetFrame.v2;

			mesh.vertexCount = i;

			i >>= 2;

			var j:int = mesh.indexCount;

			mesh.indexList[j++] = i - 4;
			mesh.indexList[j++] = i - 3;
			mesh.indexList[j++] = i - 2;
			mesh.indexList[j++] = i - 3;
			mesh.indexList[j++] = i - 1;
			mesh.indexList[j++] = i - 2;

			mesh.indexCount = j;
		}

		/**
		 */
		internal override function mouseEnter():void
		{
			pressed  = game.controls.isMouseButtonPressed();
			hasMouse = true;

			if( pressed )
			{
				broadcastPress();
			}

			updateFrame();
		}

		/**
		 */
		internal override function mouseHover():void
		{
			if( pressed == game.controls.isMouseButtonPressed() )
			{
				return;
			}

			pressed = game.controls.isMouseButtonPressed();

			if( pressed )
			{
				broadcastPress();
			}
			else
			{
				broadcastRelease();
				broadcastClick();
			}

			updateFrame();
		}

		/**
		 */
		internal override function mouseLeave():void
		{
			hasMouse = false;

			if( pressed )
			{
				pressed = false;
				broadcastRelease();
			}

			updateFrame();
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function updateFrame():void
		{
			var index:int = enabled == false ? 3 : pressed ? 2 : hasMouse ? 1 : 0;

			if( index > widgetRX.frameCount )
			{
				index = widgetRX.frameCount;
			}

			widgetFrame = widgetRX.frameList[index];
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - BROADCASTERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function broadcastClick():void
		{
			if( enabled && onClick != null )
			{
				onClick( this );
			}
		}

		/**
		 */
		private function broadcastPress():void
		{
			if( enabled && onPress != null )
			{
				onPress( this );
			}
		}

		/**
		 */
		private function broadcastRelease():void
		{
			if( enabled && onRelease != null )
			{
				onRelease( this );
			}
		}

	}// EOC
}