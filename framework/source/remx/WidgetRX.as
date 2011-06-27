package remx
{
	/**
	 */
	internal final class WidgetRX extends GraphicRX
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var frameWidth:Number  = 0.0;
		internal var frameHeight:Number = 0.0;

		internal var frameList:Vector.<WidgetFrame> = new Vector.<WidgetFrame>();
		internal var frameCount:int = 0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function WidgetRX()
		{}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function addFrame( frame:WidgetFrame ):void
		{
			frameList[frameCount++] = frame;
		}

	}// EOC
}