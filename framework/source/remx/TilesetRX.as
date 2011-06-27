package remx
{
	/**
	 */
	internal final class TilesetRX extends GraphicRX
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var frameWidth:Number  = 0.0;
		internal var frameHeight:Number = 0.0;

		internal var frameList:Vector.<TilesetFrame> = new Vector.<TilesetFrame>();
		internal var frameCount:int = 0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function TilesetRX()
		{}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function addFrame( frame:TilesetFrame ):void
		{
			frameList[frameCount++] = frame;
		}

	}// EOC
}