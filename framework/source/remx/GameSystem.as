package remx
{
	/**
	 */
	internal class GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// STATIC - INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		static internal var constructorLocked:Boolean = true;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameSystem()
		{
			if( constructorLocked )
			{
				throw new Exception( "GameSystem instance cannot be constructed" );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function initialize( game:GameApp ):void {}

		/**
		 */
		internal function shutdown():void {}

		/**
		 */
		internal function update():void {}

		/**
		 */
		internal function reset():void {}

	}// EOC
}