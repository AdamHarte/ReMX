package remx
{
	/**
	 */
	internal final class SpriteFrameset
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var animated:Boolean = false;
		internal var repeated:Boolean = false;

		internal var frameList:Vector.<SpriteFrame> = new Vector.<SpriteFrame>();
		internal var frameCount:int = 0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function SpriteFrameset()
		{}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function addFrame( frame:SpriteFrame ):void
		{
			frameList[frameCount++] = frame;
		}

	}// EOC
}