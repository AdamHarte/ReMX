package remx
{
	/**
	 */
	public final class GridData extends Data
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var rows:uint    = 0;
		public var columns:uint = 0;
		public var tilemap:Vector.<uint> = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GridData()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function isValid():Boolean
		{
			if( rows == 0 || columns == 0 || tilemap == null )
			{
				return false;
			}

			return ( rows * columns == tilemap.length );
		}

		//------------------------------------------------------------------------------------------
		//
		// PROTECTED METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		protected override function onSave( output:DataOutput ):void
		{
			output.writeU16( rows );
			output.writeU16( columns );

			if( tilemap == null )
			{
				output.writeU16( 0 );
				return;
			}

			var i:int = 0;
			var n:int = tilemap.length;

			output.writeU16( n );

			while( i < n )
			{
				output.writeU16( tilemap[i] );
				i++;
			}
		}

		/**
		 */
		protected override function onRestore( input:DataInput, resourceData:Boolean ):void
		{
			rows    = input.readU16();
			columns = input.readU16();

			var i:int = 0;
			var n:int = input.readU16();

			if( n == 0 )
			{
				return;
			}

			tilemap = new Vector.<uint>( n );

			while( i < n )
			{
				tilemap[i] = input.readU16();
				i++;
			}
		}

	}// EOC
}