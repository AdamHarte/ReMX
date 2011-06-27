package remx
{
	/**
	 */
	internal final class GraphicMesh
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var x:Number = 0.0;
		internal var y:Number = 0.0;

		internal var vertexList:Vector.<Number> = new Vector.<Number>();
		internal var vertexCount:int = 0;

		internal var indexList:Vector.<uint> = new Vector.<uint>();
		internal var indexCount:int = 0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GraphicMesh()
		{}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function reset():void
		{
			x = 0.0;
			y = 0.0;

			vertexCount       = 0;
			vertexList.length = 0;

			indexCount       = 0;
			indexList.length = 0;
		}

	}// EOC
}