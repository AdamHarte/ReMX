package remx
{
	import flash.media.Sound;

	/**
	 */
	internal final class SoundRX extends ResourceRX
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var source:Sound = null;

		public var volume:Number    = 0.0;
		public var repeated:Boolean = false;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function SoundRX()
		{}

	}// EOC
}