package remx
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 */
	public class DataInput
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

		internal var owner:Data        = null;
		internal var stream:IDataInput = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function DataInput()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function readU8():uint
		{
			return stream.readUnsignedByte();
		}

		/**
		 */
		public function readU16():uint
		{
			return stream.readUnsignedShort();
		}

		/**
		 */
		public function readU32():uint
		{
			return stream.readUnsignedInt();
		}

		/**
		 */
		public function readS8():int
		{
			return stream.readByte();
		}

		/**
		 */
		public function readS16():int
		{
			return stream.readShort();
		}

		/**
		 */
		public function readS32():int
		{
			return stream.readInt();
		}

		/**
		 */
		public function readFLOAT():Number
		{
			return stream.readFloat();
		}

		/*

		public function readFLOAT2():*
		{}

		public function readFLOAT3():*
		{}

		public function readFLOAT4():*
		{}

		*/

		/**
		 */
		public function readSTRING():String
		{
			return stream.readUTFBytes( stream.readUnsignedInt() );
		}

		/**
		 */
		public function readDATA( dataClass:Class ):*
		{
			var data:Data = new dataClass();
			data.restore( stream );
			return data;
		}

	}// EOC
}