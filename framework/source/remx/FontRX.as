package remx
{
	import flash.utils.Dictionary;

	/**
	 */
	internal final class FontRX extends GraphicRX
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var tracking:Number = 0.0;
		internal var leading:Number  = 0.0;

		internal var frameWidth:Number  = 0.0;
		internal var frameHeight:Number = 0.0;

		internal var frames:Dictionary = new Dictionary();

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function FontRX()
		{}

	}// EOC
}