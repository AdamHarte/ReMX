package remx
{
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;

	/**
	 */
	public class DataOutput
	{
		//------------------------------------------------------------------------------------------
		//
		// STATIC - PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		static private var buffer:ByteArray = null;

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var owner:Data         = null;
		internal var stream:IDataOutput = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function DataOutput()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function writeU8( value:uint ):void
		{
			stream.writeByte( value );
		}

		/**
		 */
		public function writeU16( value:uint ):void
		{
			stream.writeByte( value );
		}

		/**
		 */
		public function writeU32( value:uint ):void
		{
			stream.writeUnsignedInt( value );
		}

		/**
		 */
		public function writeS8( value:int ):void
		{
			stream.writeByte( value );
		}

		/**
		 */
		public function writeS16( value:int ):void
		{
			stream.writeShort( value );
		}

		/**
		 */
		public function writeS32( value:int ):void
		{
			stream.writeInt( value );
		}

		/**
		 */
		public function writeFLOAT( value:Number ):void
		{
			stream.writeFloat( value );
		}

		/*

		public function writeFLOAT2( value:* ):void
		{}

		public function writeFLOAT3( value:* ):void
		{}

		public function writeFLOAT4( value:* ):void
		{}

		*/

		/**
		 */
		public function writeSTRING( value:String ):void
		{
			if( buffer == null )
			{
				buffer = new ByteArray();
			}

			buffer.writeUTFBytes( value );

			stream.writeUnsignedInt( buffer.length );
			stream.writeBytes( buffer );

			buffer.length = 0;
		}

		/**
		 */
		public function writeDATA( value:Data ):void
		{
			if( value == owner )
			{
				throw new Exception( "A data object cannot write itself to an output stream" );
			}

			value.save( stream );
		}

	}// EOC
}