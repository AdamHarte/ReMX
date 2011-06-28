package remx
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.setInterval;

	/**
	 */
	public final class GameProfiler extends GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// ASSETS
		//
		//------------------------------------------------------------------------------------------

		[Embed( source="/profiler/graphics.png" )]
		static private const GraphicsPNG:Class;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private const MB_BOLD:uint        = 0;
		private const MB_REGULAR:uint     = 1;
		private const HARDWARE:uint       = 2;
		private const SOFTWARE:uint       = 3;
		private const FRAME_RATE:uint     = 4;
		private const FRAME_TIME:uint     = 5;
		private const MEMORY:uint         = 6;
		private const RENDERING_MODE:uint = 7;

		private const BACKGROUND:uint = 0xE0000000;

		private var game:GameApp = null;

		private var digitsBold:Vector.<Rectangle>    = null;
		private var digitsRegular:Vector.<Rectangle> = null;
		private var textBlocks:Vector.<Rectangle>    = null;

		private var point:Point           = null;
		private var bitmap:Bitmap         = null;
		private var bitmapData:BitmapData = null;
		private var bitmapRect:Rectangle  = null;
		private var graphics:BitmapData   = null;

		private var updateCount:Number    = 0.0;
		private var fpsCount:Number       = 0.0;
		private var fpsTotal:Number       = 0.0;
		private var frameCount:Number     = 0.0;
		private var frameTime:Number      = 0.0;
		private var frameTimeTotal:Number = 0.0;
		private var peakMemory:Number     = 0.0;

		private var interval:uint = 0;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameProfiler()
		{}

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

			digitsBold = new <Rectangle>[
				new Rectangle(  0.0, 0.0, 6.0, 7.0 ),
				new Rectangle(  7.0, 0.0, 3.0, 7.0 ),
				new Rectangle( 11.0, 0.0, 6.0, 7.0 ),
				new Rectangle( 18.0, 0.0, 6.0, 7.0 ),
				new Rectangle( 25.0, 0.0, 7.0, 7.0 ),
				new Rectangle( 33.0, 0.0, 6.0, 7.0 ),
				new Rectangle( 40.0, 0.0, 6.0, 7.0 ),
				new Rectangle( 47.0, 0.0, 6.0, 7.0 ),
				new Rectangle( 54.0, 0.0, 6.0, 7.0 ),
				new Rectangle( 61.0, 0.0, 6.0, 7.0 )
			];

			digitsRegular = new <Rectangle>[
				new Rectangle(  0.0, 8.0, 5.0, 7.0 ),
				new Rectangle(  6.0, 8.0, 2.0, 7.0 ),
				new Rectangle(  9.0, 8.0, 5.0, 7.0 ),
				new Rectangle( 15.0, 8.0, 5.0, 7.0 ),
				new Rectangle( 21.0, 8.0, 6.0, 7.0 ),
				new Rectangle( 28.0, 8.0, 5.0, 7.0 ),
				new Rectangle( 34.0, 8.0, 5.0, 7.0 ),
				new Rectangle( 40.0, 8.0, 5.0, 7.0 ),
				new Rectangle( 46.0, 8.0, 5.0, 7.0 ),
				new Rectangle( 52.0, 8.0, 5.0, 7.0 )
			];

			textBlocks = new <Rectangle>[
				new Rectangle( 68.0,  0.0, 14.0,  7.0 ),
				new Rectangle( 58.0,  8.0, 11.0,  7.0 ),
				new Rectangle(  0.0, 16.0, 49.0,  7.0 ),
				new Rectangle(  0.0, 24.0, 49.0,  7.0 ),
				new Rectangle(  0.0, 32.0, 66.0, 19.0 ),
				new Rectangle(  0.0, 52.0, 63.0, 19.0 ),
				new Rectangle(  0.0, 72.0, 43.0, 19.0 ),
				new Rectangle(  0.0, 93.0, 90.0,  7.0 )
			];

			point      = new Point();
			bitmap     = new Bitmap();
			bitmapData = new BitmapData( game.width - 4, 39, true, BACKGROUND );
			bitmapRect = bitmapData.rect;
			graphics   = Bitmap(new GraphicsPNG()).bitmapData;

			bitmap.x = 2.0;
			bitmap.y = 2.0;
			bitmap.bitmapData = bitmapData;

			game.stage.addChild( bitmap );

			interval = setInterval( updateStats, 1000.0 );
		}

		/**
		 */
		internal override function update():void
		{
			fpsCount++;
			frameCount++;
		}

		/**
		 */
		internal function startPass( t:Number ):void
		{
			frameTime = t;
		}

		/**
		 */
		internal function endPass( t:Number ):void
		{
			frameTime = t - frameTime;
			frameTimeTotal += frameTime;
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function updateStats():void
		{
			updateCount++;

			bitmapData.fillRect( bitmapRect, BACKGROUND );

			draw(  10.0, 10.0, textBlocks[FRAME_RATE]     );
			draw( 113.0, 10.0, textBlocks[FRAME_TIME]     );
			draw( 213.0, 10.0, textBlocks[MEMORY]         );
			draw( 318.0, 10.0, textBlocks[RENDERING_MODE] );

			var memory:Number = System.totalMemoryNumber / 1024.0 / 1024.0;

			if( peakMemory < memory )
			{
				peakMemory = memory;
			}

			fpsTotal += fpsCount;

			drawDigits2( 80.0, 10.0, Math.round( fpsCount ), true );
			drawDigits2( 55.0, 22.0, Math.round( fpsTotal / updateCount ) );

			fpsCount = 0.0;

			drawDigits2( 180.0, 10.0, Math.round( frameTime ), true );
			drawDigits2( 158.0, 22.0, Math.round( frameTimeTotal / frameCount ) );

			drawDigits3( 260.0, 10.0, memory, true );
			drawDigits3( 240.0, 22.0, peakMemory );
			draw( 284.0, 10.0, textBlocks[MB_BOLD] );
			draw( 261.0, 22.0, textBlocks[MB_REGULAR] );

			if( game.context.driverInfo == "Software" )
			{
				draw( 318.0, 22.0, textBlocks[SOFTWARE] );
			}
			else
			{
				draw( 318.0, 22.0, textBlocks[HARDWARE] );
			}
		}

		/**
		 */
		private function draw( x:Number, y:Number, r:Rectangle ):void
		{
			point.x = x;
			point.y = y;
			bitmapData.copyPixels( graphics, r, point, null, null, true );
		}

		/**
		 */
		private function drawDigits2( x:Number, y:Number, d:int, bold:Boolean=false ):void
		{
			var s:String = String(d);
			var i:int;
			var r:Rectangle;

			if( d < 10 )
			{
				s = "0" + s;
			}

			i = int(s.charAt( 0 ));
			r = bold ? digitsBold[i] : digitsRegular[i];
			draw( x, y, r );

			x = x + r.width + 1.0;
			i = int(s.charAt( 1 ));
			r = bold ? digitsBold[i] : digitsRegular[i];
			draw( x, y, r );
		}

		/**
		 */
		private function drawDigits3( x:Number, y:Number, d:int, bold:Boolean=false ):void
		{
			var s:String = String(d);
			var i:int;
			var r:Rectangle;

			if( d < 10 )
			{
				s = "00" + s;
			}
			else if( d < 100 )
			{
				s = "0" + s;
			}

			i = int(s.charAt( 0 ));
			r = bold ? digitsBold[i] : digitsRegular[i];
			draw( x, y, r );

			x = x + r.width + 1.0;
			i = int(s.charAt( 1 ));
			r = bold ? digitsBold[i] : digitsRegular[i];
			draw( x, y, r );

			x = x + r.width + 1.0;
			i = int(s.charAt( 2 ));
			r = bold ? digitsBold[i] : digitsRegular[i];
			draw( x, y, r );
		}

	}// EOC
}