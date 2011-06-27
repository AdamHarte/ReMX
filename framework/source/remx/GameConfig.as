package remx
{
	import flash.system.Capabilities;
	import flash.utils.Dictionary;

	/**
	 */
	public final class GameConfig
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var gameUID:uint       = 0;
		public var gameWidth:uint     = 0;
		public var gameHeight:uint    = 0;
		public var gameFrameRate:uint = 40;

		public var debug:Boolean   = Capabilities.isDebugger;
		public var profile:Boolean = false;

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var primaryScreenID:String   = null;
		internal var primaryResourceID:String = null;

		internal var screenClasses:Dictionary = new Dictionary();
		internal var resourcePaths:Dictionary = new Dictionary();

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameConfig()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function registerScreen( screenID:String, screenClass:Class, primary:Boolean=false ):void
		{
			if( primary )
			{
				primaryScreenID = screenID;
			}

			screenClasses[screenID] = screenClass;
		}

		/**
		 */
		public function registerResource( resourceID:String, resourcePath:String, primary:Boolean=false ):void
		{
			if( primary )
			{
				primaryResourceID = resourceID;
			}

			resourcePaths[resourceID] = resourcePath.replace( /^\/{1,}/, "" );
		}

	}// EOC
}