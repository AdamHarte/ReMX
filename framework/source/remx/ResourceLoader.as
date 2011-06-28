package remx
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/**
	 */
	internal final class ResourceLoader
	{
		//------------------------------------------------------------------------------------------
		//
		// STATIC - PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		static private const ERR_ASSET_NOT_FOUND:String =
			"Resource library class '%1' does not exist";

		static private const ERR_ASSET_TYPE_INVALID:String =
			"Resource library class '%1' must extend the '%2' class";

		static private const ERR_ELEMENT_REQUIRED:String =
			"Resource <%1> elements must contain at least one <%2> element";

		static private const ERR_ATTRIBUTE_REQUIRED:String =
			"Resource <%1> elements must have a '%2' attribute";

		static private const ERR_ATTRIBUTE_EMPTY:String =
			"Resource <%1> elements cannot have an empty '%2' attribute";

		static private const ERR_ATTRIBUTE_OUT_OF_RANGE:String =
			"Resource <%1> elements must have a '%2' attribute within the range %3-%4";

		static private const CHAR:String     = "char";
		static private const DATA:String     = "data";
		static private const FONT:String     = "font";
		static private const FRAME:String    = "frame";
		static private const FRAMESET:String = "frameset";
		static private const MUSIC:String    = "music";
		static private const SOUND:String    = "sound";
		static private const SPRITE:String   = "sprite";
		static private const STATE:String    = "state";
		static private const TILE:String     = "tile";
		static private const TILESET:String  = "tileset";
		static private const WIDGET:String   = "widget";

		static private const ANIMATED:String  = "animated";
		static private const CODE:String      = "code";
		static private const FLAGS:String     = "flags";
		static private const FRAMERATE:String = "framerate";
		static private const HEIGHT:String    = "height";
		static private const ID:String        = "id";
		static private const LEADING:String   = "leading";
		static private const REPEATED:String  = "repeated";
		static private const SOURCE:String    = "source";
		static private const TRACKING:String  = "tracking";
		static private const VOLUME:String    = "volume";
		static private const WIDTH:String     = "width";
		static private const X:String         = "x";
		static private const Y:String         = "y";
		static private const EMPTY:String     = "";

		static private const POW2:Dictionary = new Dictionary();
		{
			POW2[1]    = 0;
			POW2[2]    = 1;
			POW2[4]    = 2;
			POW2[8]    = 3;
			POW2[16]   = 4;
			POW2[32]   = 5;
			POW2[64]   = 6;
			POW2[128]  = 7;
			POW2[256]  = 8;
			POW2[512]  = 9;
			POW2[1024] = 10;
		}

		static private const MIN_PX:Number = 0.0;
		static private const MAX_PX:Number = 1024.0;

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var progress:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var resource:ResourcePackage = null;

		private var descriptor:XML      = null;
		private var descriptorIndex:int = 0;
		private var descriptorCount:int = 0;

		private var loadingDescriptor:Boolean = false;
		private var loadingLibrary:Boolean    = false;
		private var loadingData:Boolean       = false;
		private var descriptorLoaded:Boolean  = false;
		private var libraryLoaded:Boolean     = false;
		private var dataLoaded:Boolean        = false;
		private var injectDataLength:Boolean  = false;

		private var stream:URLStream = null;
		private var buffer:ByteArray = null;
		private var loader:Loader    = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function ResourceLoader()
		{}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function load( resource:ResourcePackage ):void
		{
			this.resource = resource;

			progress = 0.0;

			loadDescriptor();
		}

		/**
		 */
		internal function abort():void
		{
			resource = null;

			descriptor      = null;
			descriptorIndex = 0;
			descriptorCount = 0;

			loadingDescriptor = false;
			loadingLibrary    = false;
			loadingData       = false;
			descriptorLoaded  = false;
			libraryLoaded     = false;
			dataLoaded        = false;

			try
			{
				stream.close();
				stream.removeEventListener( Event.COMPLETE,         onStreamComplete );
				stream.removeEventListener( ProgressEvent.PROGRESS, onStreamProgress );
				stream.removeEventListener( IOErrorEvent.IO_ERROR,  onStreamIOError  );
			}
			catch( error:Error )
			{}

			try
			{
				buffer.length = 0;
			}
			catch( error:Error )
			{}

			try
			{
				loader.close();
				loader.contentLoaderInfo.removeEventListener( Event.INIT,            onLoaderInit    );
				loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderIOError );
			}
			catch( error:Error )
			{}

			try
			{
				loader.unload();
			}
			catch( error:Error )
			{}

			stream = null;
			buffer = null;
			loader = null;
		}

		/**
		 */
		internal function update():void
		{
			if( loadingDescriptor )
			{
				if( descriptorLoaded )
				{
					loadingDescriptor = false;
					descriptorLoaded  = false;

					descriptor      = XML(buffer);
					descriptorIndex = 0;
					descriptorCount = descriptor.children().length();

					buffer.length = 0;

					loadLibrary();
				}

				return;
			}



			if( loadingLibrary )
			{
				var info:LoaderInfo = loader.contentLoaderInfo;

				progress = 0.75 * ( info.bytesLoaded / info.bytesTotal );

				if( libraryLoaded )
				{
					loadingLibrary = false;
					libraryLoaded  = false;
				}

				return;
			}

			var element:XML = descriptor.child( descriptorIndex )[0];

			if( loadingData )
			{
				if( dataLoaded )
				{
					loadingData = false;
					dataLoaded  = false;

					processData( element );
					descriptorIndex++;
				}

				return;
			}

			progress = 0.75 + 0.25 * ( descriptorIndex / descriptorCount );

			if( progress >= 1.0 )
			{
				progress = 1.0;
				abort();
				return;
			}

			switch( String(element.name()) )
			{
				case DATA:
				{
					var file:String = element.attribute( SOURCE );

					if( file == EMPTY )
					{
						throw new Exception( ERR_ATTRIBUTE_REQUIRED, DATA, SOURCE );
					}

					loadData( file );
					return;
				}

				case FONT:
				{
					processFont( element );
					break;
				}

				case MUSIC:
				{
					processMusic( element );
					break;
				}

				case SOUND:
				{
					processSound( element );
					break;
				}

				case SPRITE:
				{
					processSprite( element );
					break;
				}

				case TILESET:
				{
					processTileset( element );
					break;
				}

				case WIDGET:
				{
					processWidget( element );
					break;
				}
			}

			descriptorIndex++;
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function loadFile( path:String ):void
		{
			if( stream == null )
			{
				stream = new URLStream();
			}

			if( buffer == null )
			{
				buffer = new ByteArray();
			}

			if( loadingDescriptor == false )
			{
				switch( path.substr( path.lastIndexOf( "." ) + 1 ) )
				{
					case "json":
					case "txt":
					case "xml":
					{
						buffer.writeUnsignedInt( 0 );
						injectDataLength = true;
						break;
					}
				}
			}

			stream.addEventListener( Event.COMPLETE,         onStreamComplete );
			stream.addEventListener( ProgressEvent.PROGRESS, onStreamProgress );
			stream.addEventListener( IOErrorEvent.IO_ERROR,  onStreamIOError  );

			try
			{
				stream.load( new URLRequest( path ) );
			}
			catch( error:Error )
			{
				throw new Exception( error.message );
			}
		}

		/**
		 */
		private function loadDescriptor():void
		{
			loadingDescriptor = true;
			loadFile( getDescriptorPath() );
		}

		/**
		 */
		private function loadLibrary():void
		{
			if( loader == null )
			{
				loader = new Loader();
			}

			loader.contentLoaderInfo.addEventListener( Event.INIT,            onLoaderInit    );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoaderIOError );

			loadingLibrary = true;

			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = new ApplicationDomain();

			try
			{
				loader.load( new URLRequest( getLibraryPath() ), context );
			}
			catch( error:Error )
			{
				throw new Exception( error.message );
			}
		}

		/**
		 */
		private function loadData( file:String ):void
		{
			loadingData = true;
			loadFile( getFilePath( file ) );
		}

		/**
		 */
		RUNTIME::AIR
		private function getDescriptorPath():String
		{
			return "app:/" + resource.path;
		}

		/**
		 */
		RUNTIME::FLASH
		private function getDescriptorPath():String
		{
			return "./" + resource.path;
		}

		/**
		 */
		private function getLibraryPath():String
		{
			return getDescriptorPath().replace( /\.xml$/, ".swf" );
		}

		/**
		 */
		private function getFilePath( file:String ):String
		{
			return getDescriptorPath().replace( /\/([^\/]+)$/, "/" + file );
		}

		/**
		 */
		private function getImageAsset( className:String ):BitmapData
		{
			var image:BitmapData = resource.images[className];

			if( image == null )
			{
				var imageClass:Class;

				try
				{
					imageClass = loader.contentLoaderInfo.applicationDomain.getDefinition( className ) as Class;
				}
				catch( error:Error )
				{
					throw new Exception( ERR_ASSET_NOT_FOUND, className );
				}

				try
				{
					image = new imageClass( 0, 0 );
				}
				catch( error:Error )
				{
					throw new Exception( ERR_ASSET_TYPE_INVALID, className, "flash.display.BitmapData" );
				}

				resource.images[className] = image;
			}

			return image;
		}

		/**
		 */
		private function getSoundAsset( className:String ):Sound
		{
			var sound:Sound;
			var soundClass:Class;

			try
			{
				soundClass = loader.contentLoaderInfo.applicationDomain.getDefinition( className ) as Class;
			}
			catch( error:Error )
			{}

			if( soundClass == null )
			{
				throw new Exception( ERR_ASSET_NOT_FOUND, className );
			}

			try
			{
				sound = new soundClass();
			}
			catch( error:Error )
			{
				throw new Exception( ERR_ASSET_TYPE_INVALID, className, "flash.media.Sound" );
			}

			return sound;
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - PROCESSORS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function hasRequiredAttributes( element:XML, ...attributes ):Boolean
		{
			for each( var attribute:String in attributes )
			{
				if( element.attribute( attribute ).length() != 0 == false )
				{
					throw new Exception( ERR_ATTRIBUTE_REQUIRED, element.name(), attribute );
				}
			}

			return true;
		}

		/**
		 */
		private function isWithinRange( value:Number, min:Number, max:Number ):Boolean
		{
			return ( value >= min && value <= max && isNaN(value) == false );
		}

		/**
		 */
		private function processData( element:XML ):void
		{
			var dataID:String; // required

			hasRequiredAttributes( element, ID );

			dataID = element.attribute( ID );

			if( dataID == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, DATA, ID );
			}

			var data:DataRX = new DataRX();

			data.id    = dataID;
			data.bytes = buffer;
			buffer = null;

			resource.data[dataID] = data;
		}

		/**
		 */
		private function processFont( element:XML ):void
		{
			var fontID:String;       // required
			var fontSource:String;   // required
			var fontWidth:Number;    // required
			var fontHeight:Number;   // required
			var fontTracking:Number; // optional - default 0.0
			var fontLeading:Number;  // optional - default 0.0

			hasRequiredAttributes( element, ID, SOURCE, X, Y, WIDTH, HEIGHT );

			fontID     = element.attribute( ID );
			fontSource = element.attribute( SOURCE );

			if( fontID == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, FONT, ID );
			}

			if( fontSource == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, FONT, SOURCE );
			}

			fontWidth  = element.attribute( WIDTH );
			fontHeight = element.attribute( HEIGHT );

			if( isWithinRange( fontWidth, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, FONT, WIDTH, MIN_PX, MAX_PX );
			}

			if( isWithinRange( fontHeight, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, FONT, HEIGHT, MIN_PX, MAX_PX );
			}

			fontTracking = 0.0;
			fontLeading  = 0.0;

			if( element.attribute( TRACKING ).length() != 0 )
			{
				fontTracking = element.attribute( TRACKING );

				if( isNaN(fontTracking) )
				{
					fontTracking = 0.0;
				}
			}

			if( element.attribute( LEADING ).length() != 0 )
			{
				fontLeading = element.attribute( LEADING );

				if( isNaN(fontLeading) )
				{
					fontLeading = 0.0;
				}
			}

			var font:FontRX = new FontRX();

			font.id          = fontID;
			font.image       = getImageAsset( fontSource );
			font.tracking    = fontTracking;
			font.leading     = fontLeading;
			font.frameWidth  = fontWidth;
			font.frameHeight = fontHeight;

			var imageWidth:Number   = font.image.width;
			var imageHeight:Number  = font.image.height;
			var imageScalerX:Number = 1.0 / imageWidth;
			var imageScalerY:Number = 1.0 / imageHeight;

			var frameElements:XMLList = element.child( CHAR );
			if( frameElements.length() == 0 )
			{
				throw new Exception( ERR_ELEMENT_REQUIRED, FONT, CHAR );
			}

			for each( var frameElement:XML in frameElements )
			{
				var frameX:Number; // required
				var frameY:Number; // required
				var frameCode:int; // required

				hasRequiredAttributes( frameElement, X, Y, CODE );

				frameX    = frameElement.attribute( X );
				frameY    = frameElement.attribute( Y );
				frameCode = frameElement.attribute( CODE );

				if( isWithinRange( frameX, MIN_PX, MAX_PX ) == false )
				{
					throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, FRAME, X, MIN_PX, MAX_PX );
				}

				if( isWithinRange( frameY, MIN_PX, MAX_PX ) == false )
				{
					throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, FRAME, Y, MIN_PX, MAX_PX );
				}

				var frame:FontFrame = new FontFrame();

				frame.u1 = frameX * imageScalerX;
				frame.v1 = frameY * imageScalerY;
				frame.u2 = frame.u1 + fontWidth  * imageScalerX;
				frame.v2 = frame.v1 + fontHeight * imageScalerY;

				font.frames[frameCode] = frame;
			}

			resource.fonts[fontID] = font;
		}

		/**
		 */
		private function processMusic( element:XML ):void
		{
			var musicID:String;        // required
			var musicSource:String;    // required
			var musicRepeated:Boolean; // optional - default false

			hasRequiredAttributes( element, ID, SOURCE );

			musicID     = element.attribute( ID );
			musicSource = element.attribute( SOURCE );

			if( musicID == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, MUSIC, ID );
			}

			if( musicSource == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, MUSIC, SOURCE );
			}

			musicRepeated = false;

			if( element.attribute( REPEATED ).length() != 0 )
			{
				musicRepeated = element.attribute( REPEATED ) == "yes";
			}

			var music:MusicRX = new MusicRX();

			music.id       = musicID;
			music.path     = getFilePath( musicSource );
			music.repeated = musicRepeated;

			resource.music[musicID] = music;
		}

		/**
		 */
		private function processSound( element:XML ):void
		{
			var soundID:String;        // required
			var soundSource:String;    // required
			var soundRepeated:Boolean; // optional - default false

			hasRequiredAttributes( element, ID, SOURCE );

			soundID     = element.attribute( ID );
			soundSource = element.attribute( SOURCE );

			if( soundID == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, SOUND, ID );
			}

			if( soundSource == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, SOUND, SOURCE );
			}

			soundRepeated = false;

			if( element.attribute( REPEATED ).length() != 0 )
			{
				soundRepeated = element.attribute( REPEATED ) == "yes";
			}

			var sound:SoundRX = new SoundRX();

			sound.id       = soundID;
			sound.source   = getSoundAsset( soundSource );
			sound.repeated = soundRepeated;

			resource.sounds[soundID] = sound;
		}

		/**
		 */
		private function processSprite( element:XML ):void
		{
			var spriteID:String;     // required
			var spriteSource:String; // required
			var spriteWidth:Number;  // required
			var spriteHeight:Number; // required
			var spriteFPS:Number;    // optional - default 0.0

			hasRequiredAttributes( element, ID, SOURCE, WIDTH, HEIGHT );

			spriteID     = element.attribute( ID );
			spriteSource = element.attribute( SOURCE );

			if( spriteID == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, SPRITE, ID );
			}

			if( spriteSource == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, SPRITE, SOURCE );
			}

			spriteWidth  = element.attribute( WIDTH );
			spriteHeight = element.attribute( HEIGHT );

			if( isWithinRange( spriteWidth, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, SPRITE, WIDTH, MIN_PX, MAX_PX );
			}

			if( isWithinRange( spriteHeight, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, SPRITE, HEIGHT, MIN_PX, MAX_PX );
			}

			spriteFPS = 0.0;

			if( element.attribute( FRAMERATE ).length() != 0 )
			{
				spriteFPS = element.attribute( FRAMERATE );

				if( isWithinRange( spriteFPS, 0.0, 60.0 ) == false )
				{
					throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, SPRITE, FRAMERATE, 0.0, 60.0 );
				}
			}

			var sprite:SpriteRX = new SpriteRX();

			sprite.id          = spriteID;
			sprite.image       = getImageAsset( spriteSource );
			sprite.frameWidth  = spriteWidth;
			sprite.frameHeight = spriteHeight;
			sprite.frameTime   = spriteFPS != 0.0 ? 1000.0 / spriteFPS : 0.0;

			var imageWidth:Number   = sprite.image.width;
			var imageHeight:Number  = sprite.image.height;
			var imageScalerX:Number = 1.0 / imageWidth;
			var imageScalerY:Number = 1.0 / imageHeight;

			var framesetElements:XMLList = element.child( FRAMESET );
			if( framesetElements.length() == 0 )
			{
				throw new Exception( ERR_ELEMENT_REQUIRED, SPRITE, FRAMESET );
			}

			for each( var framesetElement:XML in framesetElements )
			{
				var framesetAnimated:Boolean; // optional - default TRUE if spriteFPS != 0.0
				var framesetRepeated:Boolean; // optional - default TRUE if spriteFPS != 0.0

				framesetAnimated = spriteFPS != 0.0;
				framesetRepeated = spriteFPS != 0.0;

				if( framesetElement.( ANIMATED ) )
				{
					framesetAnimated = String(framesetElement.attribute( ANIMATED )) != "no";
				}

				if( framesetElement.( REPEATED ) )
				{
					framesetRepeated = String(framesetElement.attribute( REPEATED )) != "no";
				}

				var frameset:SpriteFrameset = new SpriteFrameset();

				frameset.animated = framesetAnimated;
				frameset.repeated = framesetRepeated;

				var frameElements:XMLList = framesetElement.child( FRAME );
				if( frameElements.length() == 0 )
				{
					throw new Exception( ERR_ELEMENT_REQUIRED, FRAMESET, FRAME );
				}

				for each( var frameElement:XML in frameElements )
				{
					var frameX:Number; // required
					var frameY:Number; // required

					hasRequiredAttributes( element, X, Y );

					frameX = frameElement.attribute( X );
					frameY = frameElement.attribute( Y );

					if( isWithinRange( frameX, MIN_PX, MAX_PX ) == false )
					{
						throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, FRAME, X, MIN_PX, MAX_PX );
					}

					if( isWithinRange( frameY, MIN_PX, MAX_PX ) == false )
					{
						throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, FRAME, Y, MIN_PX, MAX_PX );
					}

					var frame:SpriteFrame = new SpriteFrame();

					frame.u1 = frameX * imageScalerX;
					frame.v1 = frameY * imageScalerY;
					frame.u2 = frame.u1 + spriteWidth  * imageScalerX;
					frame.v2 = frame.v1 + spriteHeight * imageScalerY;

					frameset.addFrame( frame );
				}

				sprite.addFrameset( frameset );
			}

			resource.sprites[spriteID] = sprite;
		}

		/**
		 */
		private function processTileset( element:XML ):void
		{
			var tilesetID:String;     // required
			var tilesetSource:String; // required
			var tilesetWidth:Number;  // required
			var tilesetHeight:Number; // required

			hasRequiredAttributes( element, ID, SOURCE, WIDTH, HEIGHT );

			tilesetID = element.attribute( ID );
			tilesetSource = element.attribute( SOURCE );

			if( tilesetID == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, TILESET, ID );
			}

			if( tilesetSource == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, TILESET, SOURCE );
			}

			tilesetWidth  = element.attribute( WIDTH );
			tilesetHeight = element.attribute( HEIGHT );

			if( isWithinRange( tilesetWidth, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, TILESET, WIDTH, MIN_PX, MAX_PX );
			}

			if( isWithinRange( tilesetHeight, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, TILESET, HEIGHT, MIN_PX, MAX_PX );
			}

			var tileset:TilesetRX = new TilesetRX();

			tileset.id          = tilesetID;
			tileset.image       = getImageAsset( tilesetSource );
			tileset.frameWidth  = tilesetWidth;
			tileset.frameHeight = tilesetHeight;

			var imageWidth:Number   = tileset.image.width;
			var imageHeight:Number  = tileset.image.height;
			var imageScalerX:Number = 1.0 / imageWidth;
			var imageScalerY:Number = 1.0 / imageHeight;

			var frameElements:XMLList = element.child( TILE );
			if( frameElements.length() == 0 )
			{
				throw new Exception( ERR_ELEMENT_REQUIRED, TILESET, FRAME );
			}

			for each( element in frameElements )
			{
				var frameX:Number;   // required
				var frameY:Number;   // required
				var frameFlags:uint; // optional - default 0

				hasRequiredAttributes( element, X, Y );

				frameX = element.attribute( X );
				frameY = element.attribute( Y );

				if( isWithinRange( frameX, MIN_PX, MAX_PX ) == false )
				{
					throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, TILE, X, MIN_PX, MAX_PX );
				}

				if( isWithinRange( frameY, MIN_PX, MAX_PX ) == false )
				{
					throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, TILE, Y, MIN_PX, MAX_PX );
				}

				frameFlags = 0;

				if( element.attribute( FLAGS ).length() != 0 )
				{
					frameFlags = element.attribute( FLAGS );
				}

				var frame:TilesetFrame = new TilesetFrame();

				frame.u1    = frameX * imageScalerX;
				frame.v1    = frameY * imageScalerY;
				frame.u2    = frame.u1 + tilesetWidth  * imageScalerX;
				frame.v2    = frame.v1 + tilesetHeight * imageScalerY;
				frame.flags = frameFlags;

				tileset.addFrame( frame );
			}

			resource.tilesets[tilesetID] = tileset;
		}

		/**
		 */
		private function processWidget( element:XML ):void
		{
			var widgetID:String;     // required
			var widgetSource:String; // required
			var widgetWidth:Number;  // required
			var widgetHeight:Number; // required

			hasRequiredAttributes( element, ID, SOURCE, WIDTH, HEIGHT );

			widgetID     = element.attribute( ID );
			widgetSource = element.attribute( SOURCE );

			if( widgetID == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, WIDGET, ID );
			}

			if( widgetSource == EMPTY )
			{
				throw new Exception( ERR_ATTRIBUTE_EMPTY, WIDGET, SOURCE );
			}

			widgetWidth  = element.attribute( WIDTH );
			widgetHeight = element.attribute( HEIGHT );

			if( isWithinRange( widgetWidth, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, WIDGET, WIDTH, MIN_PX, MAX_PX );
			}

			if( isWithinRange( widgetHeight, MIN_PX, MAX_PX ) == false )
			{
				throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, HEIGHT, WIDTH, MIN_PX, MAX_PX );
			}

			var widget:WidgetRX = new WidgetRX();

			widget.id          = widgetID;
			widget.image       = getImageAsset( widgetSource );
			widget.frameWidth  = widgetWidth;
			widget.frameHeight = widgetHeight;

			var imageWidth:Number   = widget.image.width;
			var imageHeight:Number  = widget.image.height;
			var imageScalerX:Number = 1.0 / imageWidth;
			var imageScalerY:Number = 1.0 / imageHeight;

			var frameElements:XMLList = element.child( STATE );
			if( frameElements.length() == 0 )
			{
				throw new Exception( ERR_ELEMENT_REQUIRED, WIDGET, STATE );
			}

			for each( element in frameElements )
			{
				var frameX:Number;     // required
				var frameY:Number;     // required
				var frameSound:String; // optional - default NULL

				hasRequiredAttributes( element, X, Y );

				frameX = element.attribute( X );
				frameY = element.attribute( Y );

				if( isWithinRange( frameX, MIN_PX, MAX_PX ) == false )
				{
					throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, STATE, X, MIN_PX, MAX_PX );
				}

				if( isWithinRange( frameY, MIN_PX, MAX_PX ) == false )
				{
					throw new Exception( ERR_ATTRIBUTE_OUT_OF_RANGE, STATE, Y, MIN_PX, MAX_PX );
				}

				if( element.attribute( SOUND ).length() != 0 )
				{
					frameSound = element.attribute( SOUND );

					if( frameSound == EMPTY )
					{
						throw new Exception( ERR_ATTRIBUTE_EMPTY, STATE, SOUND );
					}
				}

				var frame:WidgetFrame = new WidgetFrame();

				frame.u1    = frameX * imageScalerX;
				frame.v1    = frameY * imageScalerY;
				frame.u2    = frame.u1 + widgetWidth  * imageScalerX;
				frame.v2    = frame.v1 + widgetHeight * imageScalerY;
				frame.sound = frameSound;

				widget.addFrame( frame );
			}

			resource.widgets[widgetID] = widget;
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - NATIVE EVENT LISTENERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function onStreamComplete( event:Event ):void
		{
			stream.removeEventListener( Event.COMPLETE,         onStreamComplete );
			stream.removeEventListener( ProgressEvent.PROGRESS, onStreamProgress );
			stream.removeEventListener( IOErrorEvent.IO_ERROR,  onStreamIOError  );

			if( injectDataLength )
			{
				injectDataLength = false;
				buffer.writeUnsignedInt( buffer.length - 4 );
				buffer.position = 0;
			}

			if( loadingDescriptor )
			{
				descriptorLoaded = true;
				return;
			}

			if( loadingData )
			{
				dataLoaded = true;
				return;
			}
		}

		/**
		 */
		private function onStreamProgress( event:ProgressEvent ):void
		{
			stream.readBytes( buffer, buffer.length );
		}

		/**
		 */
		private function onStreamIOError( event:IOErrorEvent ):void
		{
			throw new Exception( event.text );
		}

		/**
		 */
		private function onLoaderInit( event:Event ):void
		{
			loader.contentLoaderInfo.removeEventListener( Event.INIT,            onLoaderInit    );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderIOError );

			libraryLoaded = true;
		}

		/**
		 */
		private function onLoaderIOError( event:IOErrorEvent ):void
		{
			throw new Exception( event.text );
		}

	}// EOC
}