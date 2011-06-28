package remx
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display.BitmapData;
	import flash.display.ShaderParameterType;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 */
	public final class GameGraphics extends GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// STATIC - PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		static private const ASSEMBLER:AGALMiniAssembler = new AGALMiniAssembler();

		static private const FRAGMENT_SHADER:String = Context3DProgramType.FRAGMENT;
		static private const VERTEX_SHADER:String   = Context3DProgramType.VERTEX;

		static private const BLEND_SOURCE:String      = Context3DBlendFactor.SOURCE_ALPHA;
		static private const BLEND_DESTINATION:String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

		static private const DEPTH_TEST:String = Context3DCompareMode.NEVER;

		static private const BGRA:String   = Context3DTextureFormat.BGRA;
		static private const FLOAT2:String = ShaderParameterType.FLOAT2;
		static private const FLOAT3:String = ShaderParameterType.FLOAT3;
		static private const FLOAT4:String = ShaderParameterType.FLOAT4;

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var cameraX:Number = 0.0;
		public var cameraY:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private const standardVertexShader:ByteArray =
			ASSEMBLER.assemble(
				VERTEX_SHADER,
				"m44 op, va0, vc0 \n" +
				"mov v0, va1"
			);

		private const standardFragmentShader:ByteArray =
			ASSEMBLER.assemble(
				FRAGMENT_SHADER,
				"tex ft0, v0, fs0 <2d,clamp,nearest> \n" +
				"mov oc, ft0"
			);

		private const projectionMatrix:Vector.<Number> =
			new <Number>[
				1.0, 0.0, 0.0, -1.0,
				0.0, 1.0, 0.0,  1.0,
				0.0, 0.0, 1.0,  0.0,
				0.0, 0.0, 0.0,  1.0
			];

		private var game:GameApp      = null;
		private var program:Program3D = null;

		private var imageRegister:Dictionary = new Dictionary();
		private var imageTextures:Dictionary = new Dictionary();

		private var graphicMesh:GraphicMesh = null;
		private var graphicImage:BitmapData = null;

		private var currentUIGraphic:Graphic = null;
		private var pendingUIGraphic:Graphic = null;

		private var drawTrianglesCount:int = 0;

		private var clipRect:Rectangle    = new Rectangle();
		private var usingClipRect:Boolean = false;

		private var backgroundR:Number = 0.0;
		private var backgroundG:Number = 0.0;
		private var backgroundB:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameGraphics()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function draw( graphic:Graphic, absolute:Boolean=false ):void
		{
			if( cameraX < 0.0 )
			{
				cameraX = 0.0;
			}

			if( cameraY < 0.0 )
			{
				cameraY = 0.0;
			}

			if( graphic.graphicRX == null )
			{
				return;
			}

			if( graphicImage != graphic.graphicRX.image )
			{
				drawMesh();
				graphicImage = imageRegister[graphic.graphicRX.image];

				if( graphicImage == null )
				{
					return;
				}
			}

			if( graphic.width < 0.0 || graphic.height < 0.0 )
			{
				return;
			}

			if( graphic.clipped )
			{
				clipRect.x      = graphic.x;
				clipRect.y      = graphic.y;
				clipRect.width  = graphic.width;
				clipRect.height = graphic.height;

				usingClipRect = true;
				game.context.setScissorRectangle( clipRect );
			}
			else if( usingClipRect )
			{
				usingClipRect = false;
				game.context.setScissorRectangle( null );
			}

			var x:Number;
			var y:Number;
			var r:Number;
			var b:Number;

			if( graphic.clipped )
			{
				x = cameraX * graphic.cameraScalerX;
				y = cameraY * graphic.cameraScalerY;
			}
			else
			{
				x = graphic.x - ( absolute ? 0.0 : cameraX * graphic.cameraScalerX );
				y = graphic.y - ( absolute ? 0.0 : cameraY * graphic.cameraScalerY );

				if( x > game.width || y > game.height )
				{
					return;
				}

				r = x + graphic.width;
				b = y + graphic.height;

				if( r < 0.0 || b < 0.0 )
				{
					return;
				}
			}

			if( graphic.interactive )
			{
				var px:Number = game.controls.mouseX;
				var py:Number = game.controls.mouseY;

				if( px >= x && py >= y && px < r && py < b )
				{
					pendingUIGraphic = graphic;
				}
			}

			graphicMesh.x = x;
			graphicMesh.y = y;

			graphic.render( graphicMesh );
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal override function initialize( game:GameApp ):void
		{
			this.game = game;

			projectionMatrix[0] =  2.0 / game.width;
			projectionMatrix[5] = -2.0 / game.height;

			backgroundR = ( 1.0 / 255.0 ) * ( game.config.gameBackground >> 16 & 255 );
			backgroundG = ( 1.0 / 255.0 ) * ( game.config.gameBackground >>  8 & 255 );
			backgroundB = ( 1.0 / 255.0 ) * ( game.config.gameBackground >>  0 & 255 );

			reboot();
		}

		/**
		 */
		internal override function update():void
		{
			game.context.clear( backgroundR, backgroundG, backgroundB );

			drawTrianglesCount = 0;

			if( pendingUIGraphic == null )
			{
				if( currentUIGraphic == null )
				{
					return;
				}

				currentUIGraphic.mouseLeave();
				currentUIGraphic = null;
				return;
			}

			if( pendingUIGraphic == currentUIGraphic )
			{
				currentUIGraphic.mouseHover();
				pendingUIGraphic = null;
				return;
			}

			if( currentUIGraphic != null )
			{
				currentUIGraphic.mouseLeave();
			}

			currentUIGraphic = pendingUIGraphic;
			currentUIGraphic.mouseEnter();

			pendingUIGraphic = null;
		}

		/**
		 */
		internal override function reset():void
		{
			graphicMesh.reset();

			graphicImage     = null;
			currentUIGraphic = null;
			pendingUIGraphic = null;
		}

		/**
		 */
		internal function reboot():void
		{
			program = game.context.createProgram();
			program.upload(
				standardVertexShader,
				standardFragmentShader
			);

			game.context.setProgram( program );
			game.context.setProgramConstantsFromVector( VERTEX_SHADER, 0, projectionMatrix );

			game.context.setBlendFactors( BLEND_SOURCE, BLEND_DESTINATION );
			game.context.setDepthTest( false, DEPTH_TEST );

			game.context.configureBackBuffer( game.width, game.height, 0, false );

			for each( var image:BitmapData in imageRegister )
			{
				registerImage( image );
			}

			graphicMesh  = new GraphicMesh();
			graphicImage = null;
		}

		/**
		 */
		internal function present():void
		{
			drawMesh();
			game.context.present();
		}

		/**
		 */
		internal function registerImage( image:BitmapData ):void
		{
			if( game.context == null )
			{
				imageRegister[image] = image;
				return;
			}

			var texture:Texture = imageTextures[image];

			if( texture != null )
			{
				texture.dispose();
			}

			texture = game.context.createTexture( image.width, image.height, BGRA, false );
			texture.uploadFromBitmapData( image );

			imageRegister[image] = image;
			imageTextures[image] = texture;
		}

		/**
		 */
		internal function unregisterImage( image:BitmapData ):void
		{
			var texture:Texture = imageTextures[image];

			if( texture != null )
			{
				texture.dispose();
			}

			delete imageRegister[image];
			delete imageTextures[image];
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function drawMesh():void
		{
			if( graphicImage == null || graphicMesh.vertexCount == 0 )
			{
				return;
			}

			var vc:int;
			var ic:int;
			var vb:VertexBuffer3D;
			var ib:IndexBuffer3D;
			var tx:Texture;

			vc = graphicMesh.vertexCount >> 2;
			ic = graphicMesh.indexCount;

			vb = game.context.createVertexBuffer( vc, 4 );
			ib = game.context.createIndexBuffer( ic );

			vb.uploadFromVector( graphicMesh.vertexList, 0, vc );
			ib.uploadFromVector( graphicMesh.indexList,  0, ic );

			tx = imageTextures[graphicImage];

			game.context.setTextureAt( 0, tx );
			game.context.setVertexBufferAt( 0, vb, 0, FLOAT2 );
			game.context.setVertexBufferAt( 1, vb, 2, FLOAT2 );

			game.context.drawTriangles( ib );

			vb.dispose();
			ib.dispose();

			graphicMesh.reset();
			graphicImage = null;

			if( ++drawTrianglesCount == 65 )
			{
				throw new Exception( "The number of graphic meshes rendered during this frame has exceeded 64" );
			}
		}

	}// EOC
}