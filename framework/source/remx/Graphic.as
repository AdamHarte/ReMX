package remx
{
	/**
	 */
	public class Graphic
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var x:Number      = 0.0;
		public var y:Number      = 0.0;
		public var width:Number  = 0.0;
		public var height:Number = 0.0;

		public var cameraScalerX:Number = 1.0;
		public var cameraScalerY:Number = 1.0;

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var graphicRX:GraphicRX = null;

		internal var interactive:Boolean = false;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Graphic()
		{
			if( Object(this).constructor == Graphic )
			{
				throw new Exception( "Graphic class must be extended" );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function construct( game:GameApp, rx:GraphicRX ):void
		{
			this.game = game;
			graphicRX = rx;

			onConstruct();
		}

		/**
		 */
		internal function render( mesh:GraphicMesh ):void {}

		/**
		 */
		internal function mouseEnter():void {}

		/**
		 */
		internal function mouseHover():void {}

		/**
		 */
		internal function mouseLeave():void {}

		//------------------------------------------------------------------------------------------
		//
		// PROTECTED METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		protected function onConstruct():void {}

	}// EOC
}