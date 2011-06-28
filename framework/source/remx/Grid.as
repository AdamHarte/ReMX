package remx
{
	/**
	 */
	public class Grid extends Graphic
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var data:GridData  = null;
		public var repeat:Boolean = false;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		private var tilesetRX:TilesetRX = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Grid()
		{
			clipped = true;
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal override function construct( game:GameApp, rx:GraphicRX ):void
		{
			this.game = game;

			tilesetRX = rx as TilesetRX;

			width  = game.width;
			height = game.height;

			super.construct( game, rx );
		}

		/**
		 */
		internal override function render( mesh:GraphicMesh ):void
		{
			if( data == null || data.isValid() == false )
			{
				return;
			}

			var cx:Number = game.graphics.cameraX * cameraScalerX;
			var cy:Number = game.graphics.cameraY * cameraScalerY;

			var mc:int = data.columns;
			var mr:int = data.rows;
			var mx:int;
			var my:int = mesh.y / tilesetRX.frameHeight >> 0;
			var mi:int;
			var mn:int = data.tilemap.length;

			var gc:int = 1 + ( width  / tilesetRX.frameWidth  >> 0 );
			var gr:int = 1 + ( height / tilesetRX.frameHeight >> 0 );
			var gx:int;
			var gy:int = 0;

			var x1:Number;
			var y1:Number;
			var x2:Number;
			var y2:Number;
			var i:int;
			var j:int;
			var frame:TilesetFrame;

			while( gy < gr )
			{
				y1 = y + tilesetRX.frameHeight * gy;

				if( cy != 0.0 )
				{
					y1 -= cy % tilesetRX.frameHeight;
				}

				y2 = y1 + tilesetRX.frameHeight;

				mx = mesh.x / tilesetRX.frameWidth >> 0;
				gx = 0;

				while( gx < gc )
				{
					if( repeat )
					{
						mi = ( mx < mc ? mx : mx % mc )
						   + ( my < mr ? my : my % mr ) * mc;
					}
					else
					{
						if( mx >= mc || my >= mr )
						{
							mx++;
							gx++;
							continue;
						}

						mi = mx + my * mc;
					}

					if( data.tilemap[mi] >= tilesetRX.frameCount )
					{
						mx++;
						gx++;
						continue;
					}

					x1 = x + tilesetRX.frameWidth * gx;

					if( cx != 0.0 )
					{
						x1 -= cx % tilesetRX.frameWidth;
					}

					x2 = x1 + tilesetRX.frameWidth;

					frame = tilesetRX.frameList[ data.tilemap[mi] ];

					i = mesh.vertexCount;

					mesh.vertexList[i++] = x1;
					mesh.vertexList[i++] = y1;
					mesh.vertexList[i++] = frame.u1;
					mesh.vertexList[i++] = frame.v1;

					mesh.vertexList[i++] = x2;
					mesh.vertexList[i++] = y1;
					mesh.vertexList[i++] = frame.u2;
					mesh.vertexList[i++] = frame.v1;

					mesh.vertexList[i++] = x1;
					mesh.vertexList[i++] = y2;
					mesh.vertexList[i++] = frame.u1;
					mesh.vertexList[i++] = frame.v2;

					mesh.vertexList[i++] = x2;
					mesh.vertexList[i++] = y2;
					mesh.vertexList[i++] = frame.u2;
					mesh.vertexList[i++] = frame.v2;

					mesh.vertexCount = i;

					i >>= 2;

					j = mesh.indexCount;

					mesh.indexList[j++] = i - 1;
					mesh.indexList[j++] = i - 2;
					mesh.indexList[j++] = i - 3;
					mesh.indexList[j++] = i - 4;
					mesh.indexList[j++] = i - 3;
					mesh.indexList[j++] = i - 2;

					mesh.indexCount = j;

					mx++;
					gx++;
				}

				my++;
				gy++;
			}
		}

	}// EOC
}