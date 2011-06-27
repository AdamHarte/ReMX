package remx
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	/**
	 */
	public final class GameResource extends GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES - EVENTS
		//
		//------------------------------------------------------------------------------------------

		public var onLoadStart:Function    = null; // ( resourceID:String ):void
		public var onLoadComplete:Function = null; // ( resourceID:String ):void
		public var onLoadProgress:Function = null; // ( resourceID:String, progress:Number ):void

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private const ERR_RESOURCE_NOT_FOUND:String =
			"Resource package '%1' has not been registered";

		private const ERR_RESOURCE_RX_NOT_FOUND:String =
			"%1 resource '%2' does not exist";

		private const DATA:String    = "Data";
		private const FONT:String    = "Font";
		private const SPRITE:String  = "Sprite";
		private const TILESET:String = "Tileset";
		private const WIDGET:String  = "Widget";

		//
		private var game:GameApp = null;

		//
		private var resources:Dictionary = new Dictionary();

		//
		private var queue:Vector.<ResourcePackage> = new Vector.<ResourcePackage>();

		//
		private var loader:ResourceLoader = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameResource()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function load( resourceID:String ):Boolean
		{
			if( resources[resourceID] != null )
			{
				return false;
			}

			var resource:ResourcePackage;

			for each( resource in queue )
			{
				if( resource.id == resourceID )
				{
					return false;
				}
			}

			var resourcePath:String = game.config.resourcePaths[resourceID];

			if( resourcePath == null )
			{
				throw new Exception( ERR_RESOURCE_NOT_FOUND, resourceID );
			}

			resource      = new ResourcePackage();
			resource.id   = resourceID;
			resource.path = resourcePath;

			if( queue.push( resource ) == 1 )
			{
				loadResource();
			}

			return true;
		}

		/**
		 */
		public function unload( resourceID:String ):Boolean
		{
			var resource:ResourcePackage = resources[resourceID];

			if( resource != null )
			{
				for each( var image:BitmapData in resource.images )
				{
					game.graphics.unregisterImage( image );
				}

				for each( var sound:SoundRX in resource.sounds )
				{
					game.audio.unregisterSound( sound );
				}

				for each( var music:MusicRX in resource.music )
				{
					game.audio.unregisterMusic( music );
				}

				resource.dispose();
				delete resources[resourceID];
				return true;
			}

			var i:int = 1;
			var n:int = queue.length;

			while( i < n )
			{
				if( queue[i].id == resourceID )
				{
					queue.splice( i, 1 );
					return true;
				}
			}

			return false;
		}

		/**
		 */
		public function createData( dataID:String, dataClass:Class ):*
		{
			var rx:DataRX;

			for each( var resource:ResourcePackage in resources )
			{
				if( ( rx = resource.data[dataID] ) != null )
				{
					break;
				}
			}

			if( rx == null )
			{
				throw new Exception( ERR_RESOURCE_RX_NOT_FOUND, DATA, dataID );
			}

			var data:Data = new dataClass();
			data.construct( rx );

			return data;
		}

		/**
		 */
		public function createGrid( tilesetID:String, gridClass:Class=null ):*
		{
			var rx:TilesetRX;

			for each( var resource:ResourcePackage in resources )
			{
				if( ( rx = resource.tilesets[tilesetID] ) != null )
				{
					break;
				}
			}

			if( rx == null )
			{
				throw new Exception( ERR_RESOURCE_RX_NOT_FOUND, TILESET, tilesetID );
			}

			var grid:Grid = gridClass == null ? new Grid() : new gridClass();
			grid.construct( game, rx );

			return grid;
		}

		/**
		 */
		public function createSprite( spriteID:String, spriteClass:Class=null ):*
		{
			var rx:SpriteRX;

			for each( var resource:ResourcePackage in resources )
			{
				if( ( rx = resource.sprites[spriteID] ) != null )
				{
					break;
				}
			}

			if( rx == null )
			{
				throw new Exception( ERR_RESOURCE_RX_NOT_FOUND, SPRITE, spriteID );
			}

			var sprite:Sprite = spriteClass == null ? new Sprite() : new spriteClass();
			sprite.construct( game, rx );

			return sprite;
		}

		/**
		 */
		public function createText( fontID:String, textClass:Class=null ):*
		{
			var rx:FontRX;

			for each( var resource:ResourcePackage in resources )
			{
				if( ( rx = resource.fonts[fontID] ) != null )
				{
					break;
				}
			}

			if( rx == null )
			{
				throw new Exception( ERR_RESOURCE_RX_NOT_FOUND, FONT, fontID );
			}

			var text:Text = textClass == null ? new Text() : new textClass();
			text.construct( game, rx );

			return text;
		}

		/**
		 */
		public function createWidget( widgetID:String, widgetClass:Class=null ):*
		{
			var rx:WidgetRX;

			for each( var resource:ResourcePackage in resources )
			{
				if( ( rx = resource.widgets[widgetID] ) != null )
				{
					break;
				}
			}

			if( rx == null )
			{
				throw new Exception( ERR_RESOURCE_RX_NOT_FOUND, WIDGET, widgetID );
			}

			var widget:Widget = widgetClass == null ? new Widget() : new widgetClass();
			widget.construct( game, rx );

			return widget;
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
		}

		/**
		 */
		internal override function shutdown():void
		{
			if( loader != null )
			{
				loader.abort();
			}
		}

		/**
		 */
		internal override function update():void
		{
			if( loader == null )
			{
				return;
			}

			loader.update();

			if( loader.progress != 1.0 )
			{
				broadcastLoadProgress( queue[0].id, loader.progress );
				return;
			}

			loader = null;

			var resource:ResourcePackage = queue.shift();
			resources[resource.id] = resource;

			for each( var image:BitmapData in resource.images )
			{
				game.graphics.registerImage( image );
			}

			for each( var sound:SoundRX in resource.sounds )
			{
				game.audio.registerSound( sound );
			}

			for each( var music:MusicRX in resource.music )
			{
				game.audio.registerMusic( music );
			}

			broadcastLoadComplete( resource.id );

			if( queue.length != 0 && loader == null )
			{
				loadResource();
			}
		}

		/**
		 */
		internal override function reset():void
		{
			if( queue.length > 1 )
			{
				queue.length = 1;
			}

			onLoadStart    = null;
			onLoadComplete = null;
			onLoadProgress = null;
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function loadResource():void
		{
			var resource:ResourcePackage = queue[0];

			loader = new ResourceLoader();
			loader.load( resource );

			broadcastLoadStart( resource.id );
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - BROADCASTERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function broadcastLoadStart( resourceID:String ):void
		{
			if( onLoadStart != null )
			{
				onLoadStart( resourceID );
			}
		}

		/**
		 */
		private function broadcastLoadComplete( resourceID:String ):void
		{
			if( onLoadComplete != null )
			{
				onLoadComplete( resourceID );
			}
		}

		/**
		 */
		private function broadcastLoadProgress( resourceID:String, progress:Number ):void
		{
			if( onLoadProgress != null )
			{
				onLoadProgress( resourceID, progress );
			}
		}

	}// EOC
}