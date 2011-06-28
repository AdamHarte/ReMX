package remx
{
	import flash.text.Font;

	/**
	 */
	public class Text extends Graphic
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var maxWidth:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		private var fontRX:FontRX = null;

		private var text:String = "";
		private var characters:Vector.<TextCharacter> = new Vector.<TextCharacter>();

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Text()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function getText():String
		{
			return text;
		}

		/**
		 */
		public function setText( value:String ):void
		{
			width  = 0.0;
			height = 0.0;
			text   = value;

			var i:int = 0;
			var n:int = value.length;

			characters.length = n;

			if( n == 0 )
			{
				return;
			}

			var max:Number = maxWidth;

			if( max <= 0.0 || max > game.width )
			{
				max = game.width;
			}

			var x:Number = 0.0;
			var y:Number = 0.0;
			var word:int = 0;
			var code:int = 0;
			var char:TextCharacter;

			while( i < n )
			{
				width  = x > width ? x : width;
				height = y;

				code = value.charCodeAt( i );

				if( code == 10 )
				{
					x    = 0.0;
					y   += fontRX.frameHeight + fontRX.leading;
					word = 0;

					characters[i] = null;
					i++;
					continue;
				}
				else if( code == 32 )
				{
					code = i != 0 ? value.charCodeAt( i - 1 ) : 0;

					if( code != 44 && code != 46 && code != 58 && code != 59 )
					{
						x += fontRX.frameWidth + fontRX.tracking;

						if( x > max )
						{
							x  = 0.0;
							y += fontRX.frameHeight + fontRX.leading;
						}
					}

					word = 0;

					characters[i] = null;
					i++;
					continue;
				}
				else if( fontRX.frames[code] == null )
				{
					if( code > 96 && code < 123 )
					{
						code -= 32;

						if( fontRX.frames[code] == null )
						{
							characters[i] = null;
							i++;
							continue;
						}
					}
					else
					{
						characters[i] = null;
						i++;
						continue;
					}
				}

				char = characters[i];

				if( char == null )
				{
					char = new TextCharacter();
				}

				char.x     = x;
				char.y     = y;
				char.frame = fontRX.frames[code];

				characters[i] = char;
				word++;

				x += fontRX.frameWidth + fontRX.tracking;

				if( x > max )
				{
					x = 0.0;

					if( y != 0.0 )
					{
						y += fontRX.frameHeight + fontRX.leading;
					}

					var j:int = 0;

					while( j < word )
					{
						char   = characters[ i - ( word - j - 1 ) ];
						char.x = x;
						char.y = y;

						x += fontRX.frameWidth + fontRX.tracking;
						j++;
					}

					if( x > max )
					{
						max = x;
					}
				}

				i++;
			}

			width  += fontRX.frameWidth;
			height += fontRX.frameHeight;
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

			fontRX = rx as FontRX;

			super.construct( game, rx );
		}

		/**
		 */
		internal override function render( mesh:GraphicMesh ):void
		{
			var x1:Number;
			var y1:Number;
			var x2:Number;
			var y2:Number;
			var i:int;
			var j:int;
			var c:TextCharacter;

			var ci:int = 0;
			var cn:int = characters.length;

			while( ci < cn )
			{
				c = characters[ci];

				if( c == null )
				{
					ci++;
					continue;
				}

				x1 = c.x + mesh.x;
				y1 = c.y + mesh.y;
				x2 = x1 + fontRX.frameWidth;
				y2 = y1 + fontRX.frameHeight;

				i = mesh.vertexCount;

				mesh.vertexList[i++] = x1;
				mesh.vertexList[i++] = y1;
				mesh.vertexList[i++] = c.frame.u1;
				mesh.vertexList[i++] = c.frame.v1;

				mesh.vertexList[i++] = x2;
				mesh.vertexList[i++] = y1;
				mesh.vertexList[i++] = c.frame.u2;
				mesh.vertexList[i++] = c.frame.v1;

				mesh.vertexList[i++] = x1;
				mesh.vertexList[i++] = y2;
				mesh.vertexList[i++] = c.frame.u1;
				mesh.vertexList[i++] = c.frame.v2;

				mesh.vertexList[i++] = x2;
				mesh.vertexList[i++] = y2;
				mesh.vertexList[i++] = c.frame.u2;
				mesh.vertexList[i++] = c.frame.v2;

				mesh.vertexCount = i;

				i >>= 2;

				j = mesh.indexCount;

				mesh.indexList[j++] = i - 4;
				mesh.indexList[j++] = i - 3;
				mesh.indexList[j++] = i - 2;
				mesh.indexList[j++] = i - 3;
				mesh.indexList[j++] = i - 1;
				mesh.indexList[j++] = i - 2;

				mesh.indexCount = j;

				ci++;
			}
		}

	}// EOC
}