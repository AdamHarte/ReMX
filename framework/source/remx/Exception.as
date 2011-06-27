package remx
{
	import flash.system.Capabilities;

	RUNTIME::AIR
	{
		import flash.filesystem.File;
		import flash.filesystem.FileMode;
		import flash.filesystem.FileStream;
	}

	/**
	 */
	public final class Exception extends Error
	{
		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Exception( message:String, ...tokens )
		{
			var i:int = tokens.length;

			while( i-- )
			{
				message = message.replace( "%" + ( i + 1 ), tokens[i] );
			}

			if( Capabilities.isDebugger == false )
			{
				log( message );
			}

			super( message );
		}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function toString():String
		{
			return "ReMX Error: " + message;
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		RUNTIME::AIR
		private function log( message:String ):void
		{
			var file:File         = new File( "app-storage:/exceptions" );
			var stream:FileStream = new FileStream();

			try
			{
				stream.open( file, FileMode.APPEND );
			}
			catch( error:Error )
			{
				return;
			}

			stream.writeUTFBytes( message + "\n" );
			stream.close();
		}

		/**
		 */
		RUNTIME::FLASH
		private function log( message:String ):void
		{}

	}// EOC
}