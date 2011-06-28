package remx
{
	/**
	 */
	public class Sprite extends Graphic
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var flipHorizontal:Boolean = false;
		public var flipVertical:Boolean   = false;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		private var spriteRX:SpriteRX             = null;
		private var spriteFrame:SpriteFrame       = null;
		private var spriteFrameset:SpriteFrameset = null;

		private var frameIndex:int    = 0;
		private var framesetIndex:int = 0;

		private var timeStamp:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Sprite()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public final function getFrame():int
		{
			return frameIndex;
		}

		/**
		 */
		public final function setFrame( index:int ):void
		{
			if( spriteFrameset.animated )
			{
				return;
			}

			if( index < 0 )
			{
				index = 0;
			}
			else if( index >= spriteFrameset.frameCount )
			{
				index = spriteFrameset.frameCount;
			}

			if( frameIndex != index )
			{
				frameIndex  = index;
				spriteFrame = spriteFrameset.frameList[index];
			}
		}

		/**
		 */
		public final function getFrameset():int
		{
			return framesetIndex;
		}

		/**
		 */
		public final function setFrameset( index:int ):void
		{
			if( index < 0 )
			{
				index = 0;
			}
			else if( index >= spriteRX.framesetCount )
			{
				index = spriteRX.framesetCount - 1;
			}

			if( framesetIndex != index )
			{
				framesetIndex  = index;
				spriteFrameset = spriteRX.framesetList[index];

				frameIndex  = 0;
				spriteFrame = spriteFrameset.frameList[0];

				timeStamp = 0.0;
			}
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

			spriteRX       = rx as SpriteRX;
			spriteFrameset = spriteRX.framesetList[0];
			spriteFrame    = spriteFrameset.frameList[0];

			width  = spriteRX.frameWidth;
			height = spriteRX.frameHeight;

			super.construct( game, rx );
		}

		/**
		 */
		internal override function render( mesh:GraphicMesh ):void
		{
			if( spriteFrameset.animated )
			{
				var index:int = 0;

				if( timeStamp == 0.0 )
				{
					timeStamp = game.timeTotal;
				}
				else
				{
					index = ( game.timeTotal - timeStamp ) / spriteRX.frameTime;

					if( index < 0 )
					{
						index = 0;
					}
					else if( index >= spriteFrameset.frameCount )
					{
						if( spriteFrameset.repeated )
						{
							index %= spriteFrameset.frameCount;
						}
						else
						{
							index = spriteFrameset.frameCount - 1;
						}
					}
				}

				if( frameIndex != index )
				{
					frameIndex  = index;
					spriteFrame = spriteFrameset.frameList[index];
				}
			}

			var x1:Number = mesh.x;
			var y1:Number = mesh.y;
			var x2:Number = x1 + width;
			var y2:Number = y1 + height;

			var i:int = mesh.vertexCount;

			mesh.vertexList[i++] = x1;
			mesh.vertexList[i++] = y1;
			mesh.vertexList[i++] = flipHorizontal ? spriteFrame.u2 : spriteFrame.u1;
			mesh.vertexList[i++] = flipVertical   ? spriteFrame.v2 : spriteFrame.v1;

			mesh.vertexList[i++] = x2;
			mesh.vertexList[i++] = y1;
			mesh.vertexList[i++] = flipHorizontal ? spriteFrame.u1 : spriteFrame.u2;
			mesh.vertexList[i++] = flipVertical   ? spriteFrame.v2 : spriteFrame.v1;

			mesh.vertexList[i++] = x1;
			mesh.vertexList[i++] = y2;
			mesh.vertexList[i++] = flipHorizontal ? spriteFrame.u2 : spriteFrame.u1;
			mesh.vertexList[i++] = flipVertical   ? spriteFrame.v1 : spriteFrame.v2;

			mesh.vertexList[i++] = x2;
			mesh.vertexList[i++] = y2;
			mesh.vertexList[i++] = flipHorizontal ? spriteFrame.u1 : spriteFrame.u2;
			mesh.vertexList[i++] = flipVertical   ? spriteFrame.v1 : spriteFrame.v2;

			mesh.vertexCount = i;

			i >>= 2;

			var j:int = mesh.indexCount;

			mesh.indexList[j++] = i - 1;
			mesh.indexList[j++] = i - 2;
			mesh.indexList[j++] = i - 3;
			mesh.indexList[j++] = i - 4;
			mesh.indexList[j++] = i - 3;
			mesh.indexList[j++] = i - 2;

			mesh.indexCount = j;
		}

	}// EOC
}