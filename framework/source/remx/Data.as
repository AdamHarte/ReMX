package remx
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	/**
	 */
	public class Data
	{
		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var input:DataInput   = null;
		private var output:DataOutput = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Data()
		{
			if( Object(this).constructor == Data )
			{
				throw new Exception( "Data class must be extended" );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function construct( rx:DataRX ):void
		{
			var p:uint = rx.bytes.position;

			restore( rx.bytes, true );

			rx.bytes.position = p;
		}

		/**
		 */
		internal function save( stream:IDataOutput ):void
		{
			if( output == null )
			{
				output       = new DataOutput();
				output.owner = this;
			}

			output.stream = stream;
			onSave( output );
			output.stream = null;
		}

		/**
		 */
		internal function restore( stream:IDataInput, resourceData:Boolean=false ):void
		{
			if( input == null )
			{
				input       = new DataInput();
				input.owner = this;
			}

			input.stream = stream;
			onRestore( input, resourceData );
			input.stream = null;
		}

		//------------------------------------------------------------------------------------------
		//
		// PROTECTED METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		protected function onSave( output:DataOutput ):void {}

		/**
		 */
		protected function onRestore( input:DataInput, resourceData:Boolean ):void {}

	}// EOC
}