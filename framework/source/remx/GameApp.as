package remx
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	RUNTIME::AIR
	{
		import flash.desktop.NativeApplication;
		import flash.display.NativeWindow;
		import flash.display.StageAspectRatio;
		import flash.filesystem.File;
		import flash.filesystem.FileMode;
		import flash.filesystem.FileStream;
	}

	/**
	 */
	public final class GameApp
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		static internal var constructorLocked:Boolean = true;

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var audio:GameAudio       = null;
		public var controls:GameControls = null;
		public var graphics:GameGraphics = null;
		public var network:GameNetwork   = null;
		public var profiler:GameProfiler = null;
		public var resource:GameResource = null;
		public var server:GameServer     = null;
		public var storage:GameStorage   = null;

		public var timeDelta:Number = 0.0;
		public var timeTotal:Number = 0.0;
		public var timeScale:Number = 1.0;
		public var timeStamp:Number = 0.0;

		public var width:Number  = 0.0;
		public var height:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		RUNTIME::AIR
		{
			internal const CACHE_DIRECTORY:String      = "app-storage:/cache";
			internal const CORE_DIRECTORY:String       = "app-storage:/core";
			internal const DATA_DIRECTORY:String       = "app-storage:/data";
			internal const DOWNLOADS_DIRECTORY:String  = "app-storage:/downloads";
			internal const EXTENSIONS_DIRECTORY:String = "app-storage:/extensions";
		}

		internal var stage:Stage       = null;
		internal var surface:Stage3D   = null;
		internal var context:Context3D = null;

		internal var config:GameConfig = null;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var initialized:Boolean  = false;
		private var rebooting:Boolean    = false;
		private var deactivated:Boolean  = false;
		private var screenLocked:Boolean = false;

		private var screen:GameScreen = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameApp()
		{
			if( constructorLocked )
			{
				throw new Exception( "GameApp instance cannot be constructed" );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function setScreen( screenID:String ):void
		{
			if( screenLocked )
			{
				throw new Exception( "Screens cannot be set during screen construction or deconstruction" );
			}

			screenLocked = true;

			if( screen != null )
			{
				screen.deconstruct();

				audio   .reset();
				controls.reset();
				graphics.reset();
				network .reset();
				profiler.reset();
				resource.reset();
				server  .reset();
				storage .reset();

				screen = null;
			}

			if( screenID == null )
			{
				screenLocked = false;
				return;
			}

			var screenClass:Class = config.screenClasses[screenID];

			if( screenClass == null )
			{
				throw new Exception( "Screen '" + screenID + "' has not been registered" );
			}

			screen = new screenClass();
			screen.construct( this );

			screenLocked = false;
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function run( stage:Stage, config:GameConfig ):void
		{
			this.stage  = stage;
			this.config = config;

			width  = config.gameWidth;
			height = config.gameHeight;

			stage.align         = StageAlign.TOP_LEFT;
			stage.quality       = StageQuality.LOW;
			stage.scaleMode     = StageScaleMode.NO_SCALE;
			stage.mouseChildren = false;

			RUNTIME::AIR
			{
				var application:NativeApplication = NativeApplication.nativeApplication;

				application.autoExit = true;
				application.addEventListener( Event.EXITING,    onApplicationExiting    );
				application.addEventListener( Event.ACTIVATE,   onApplicationActivate   );
				application.addEventListener( Event.DEACTIVATE, onApplicationDeactivate );

				if( NativeWindow.isSupported )
				{
					if( config.gameFrameRate > 60 )
					{
						stage.frameRate = 60;
					}
					else
					{
						stage.frameRate = config.gameFrameRate;
					}

					stage.stageWidth  = width;
					stage.stageHeight = height;

					restoreWindowPosition();

					stage.nativeWindow.activate();
					stage.nativeWindow.addEventListener( Event.CLOSING, onWindowClosing );
				}
				else
				{
					if( config.gameFrameRate > 40 )
					{
						stage.frameRate = 40;
					}
					else
					{
						stage.frameRate = config.gameFrameRate;
					}

					stage.autoOrients = false;

					if( width > height )
					{
						stage.setAspectRatio( StageAspectRatio.LANDSCAPE );
					}
					else
					{
						stage.setAspectRatio( StageAspectRatio.PORTRAIT );
					}

					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}
			}

			RUNTIME::FLASH
			{
				if( config.gameFrameRate > 60 )
				{
					stage.frameRate = 60;
				}
				else
				{
					stage.frameRate = config.gameFrameRate;
				}

				stage.showDefaultContextMenu = false;

				stage.addEventListener( Event.ACTIVATE,   onStageActivate   );
				stage.addEventListener( Event.DEACTIVATE, onStageDeactivate );
			}

			surface = stage.stage3Ds[0];

			try
			{
				Object(surface).x = 0.0;
				Object(surface).y = 0.0;
				Object(surface).visible = true;
			}
			catch( error:Error )
			{
				Object(surface).viewPort = new Rectangle( 0.0, 0.0, width, height );
			}

			surface.addEventListener( Event.CONTEXT3D_CREATE, onContextCreate );
			surface.requestContext3D();

			stage.addEventListener( Event.ENTER_FRAME, onStageEnterFrame );
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function initialize():void
		{
			if( initialized )
			{
				return;
			}

			GameSystem.constructorLocked = false;

			audio    = new GameAudio();
			controls = new GameControls();
			graphics = new GameGraphics();
			network  = new GameNetwork();
			profiler = new GameProfiler();
			resource = new GameResource();
			server   = new GameServer();
			storage  = new GameStorage();

			GameSystem.constructorLocked = true;

			audio   .initialize( this );
			controls.initialize( this );
			graphics.initialize( this );
			network .initialize( this );
			profiler.initialize( this );
			resource.initialize( this );
			server  .initialize( this );
			storage .initialize( this );

			initialized = true;

			if( config.primaryResourceID != null )
			{
				resource.onLoadComplete = onResourceLoadComplete;
				resource.onLoadProgress = onResourceLoadProgress;
				resource.load( config.primaryResourceID );
				return;
			}

			setScreen( config.primaryScreenID );
		}

		/**
		 */
		private function shutdown():void
		{
			if( initialized )
			{
				setScreen( null );

				audio   .shutdown();
				controls.shutdown();
				graphics.shutdown();
				network .shutdown();
				profiler.shutdown();
				resource.shutdown();
				server  .shutdown();
				storage .shutdown();

				audio    = null;
				controls = null;
				graphics = null;
				network  = null;
				profiler = null;
				resource = null;
				server   = null;
				storage  = null;

				initialized = false;
			}

			RUNTIME::AIR
			{
				clearCache();

				try
				{
					NativeApplication.nativeApplication.exit();
				}
				catch( error:Error )
				{}
			}
		}

		/**
		 */
		private function update():void
		{
			if( initialized == false )
			{
				return;
			}

			context = surface.context3D;

			if( context == null )
			{
				rebooting = true;
				return;
			}

			if( rebooting )
			{
				graphics.reboot();

				rebooting = false;
				return;
			}

			var time:Number = getTimer();

			if( timeStamp == 0.0 )
			{
				timeStamp = time;
			}
			else
			{
				if( timeScale < 0.0 )
				{
					timeScale = 0.0;
				}

				var tt:Number = time - timeStamp;
				var td:Number = tt / ( 1000.0 / stage.frameRate );

				timeTotal += tt * timeScale;
				timeDelta  = td * timeScale;
				timeStamp  = time;
			}

			var activeScreen:GameScreen = screen;

			try
			{
				audio   .update();
				controls.update();
				graphics.update();
				network .update();
				profiler.update();
				resource.update();
				server  .update();
				storage .update();

				if( screen != null )
				{
					if( screen == activeScreen )
					{
						screen.update();
					}

					screen.render();
				}

				graphics.present();
			}
			catch( error:Error )
			{
				if( initialized )
				{
					throw error;
				}
			}
		}

		/**
		 */
		private function activate():void
		{
			if( initialized && deactivated )
			{
				if( screen != null )
				{
					screen.activate();
				}

				deactivated = false;
			}
		}

		/**
		 */
		private function deactivate():void
		{
			if( initialized && deactivated == false )
			{
				if( screen != null )
				{
					screen.deactivate();
				}

				deactivated = true;
			}
		}

		/**
		 */
		RUNTIME::AIR
		private function clearCache():void
		{
			var file:File = new File( CACHE_DIRECTORY );

			try
			{
				file.deleteDirectory( true );
			}
			catch( error:Error )
			{}
		}

		/**
		 */
		RUNTIME::AIR
		private function saveWindowPosition():void
		{
			var file:File         = new File( CORE_DIRECTORY + "/window" );
			var stream:FileStream = new FileStream();

			try
			{
				stream.open( file, FileMode.WRITE );
			}
			catch( error:Error )
			{
				return;
			}

			stream.writeShort( stage.nativeWindow.x );
			stream.writeShort( stage.nativeWindow.y );
			stream.close();
		}

		/**
		 */
		RUNTIME::AIR
		private function restoreWindowPosition():void
		{
			var file:File         = new File( CORE_DIRECTORY + "/window" );
			var stream:FileStream = new FileStream();

			try
			{
				stream.open( file, FileMode.READ );
			}
			catch( error:Error )
			{
				return;
			}

			stage.nativeWindow.x = stream.readShort();
			stage.nativeWindow.y = stream.readShort();
			stream.close();
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - EVENT LISTENERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function onResourceLoadComplete( resourceID:String ):void
		{
			resource.onLoadComplete = null;
			resource.onLoadProgress = null;

			setScreen( config.primaryScreenID );
		}

		/**
		 */
		private function onResourceLoadProgress( resourceID:String, progress:Number ):void
		{}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - NATIVE EVENT LISTENERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		RUNTIME::AIR
		private function onApplicationExiting( event:Event ):void
		{
			var application:NativeApplication = NativeApplication.nativeApplication;

			application.autoExit = true;
			application.addEventListener( Event.EXITING,    onApplicationExiting    );
			application.addEventListener( Event.ACTIVATE,   onApplicationActivate   );
			application.addEventListener( Event.DEACTIVATE, onApplicationDeactivate );

			shutdown();
		}

		/**
		 */
		RUNTIME::AIR
		private function onApplicationActivate( event:Event ):void
		{
			activate();
		}

		/**
		 */
		RUNTIME::AIR
		private function onApplicationDeactivate( event:Event ):void
		{
			deactivate();
		}

		/**
		 */
		RUNTIME::AIR
		private function onWindowClosing( event:Event ):void
		{
			stage.nativeWindow.removeEventListener( Event.CLOSING, onWindowClosing );

			saveWindowPosition();
		}

		/**
		 */
		RUNTIME::FLASH
		private function onStageActivate( event:Event ):void
		{
			activate();
		}

		/**
		 */
		RUNTIME::FLASH
		private function onStageDeactivate( event:Event ):void
		{
			deactivate();
		}

		/**
		 */
		private function onStageEnterFrame( event:Event ):void
		{
			update();
		}

		/**
		 */
		private function onContextCreate( event:Event ):void
		{
			context = surface.context3D;

			if( config.debug )
			{
				context.enableErrorChecking = true;
			}

			initialize();
		}

	}// EOC
}