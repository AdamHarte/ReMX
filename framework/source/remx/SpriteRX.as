package remx
{
	/**
	 */
	internal final class SpriteRX extends GraphicRX
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var frameTime:Number   = 0.0;
		internal var frameWidth:Number  = 0.0;
		internal var frameHeight:Number = 0.0;

		internal var framesetList:Vector.<SpriteFrameset> = new Vector.<SpriteFrameset>();
		internal var framesetCount:int = 0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function SpriteRX()
		{}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function addFrameset( frameset:SpriteFrameset ):void
		{
			framesetList[framesetCount++] = frameset;
		}

	}// EOC
}