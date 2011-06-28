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

		internal var hasMainScreen:Boolean   = false;
		internal var hasMainResource:Boolean = false;

		internal var screenClasses:Dictionary   = new Dictionary();
		internal var descriptorPaths:Dictionary = new Dictionary();

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
		public function registerScreen( screenID:String, screenClass:Class ):void
		{
			if( screenClasses[screenID] != null )
			{
				throw new Exception( "Parameter 'screenID' must be a unique screen identifier" );
			}

			if( screenID == "main" )
			{
				hasMainScreen = true;
			}

			screenClasses[screenID] = screenClass;
		}

		/**
		 */
		public function registerResourcePackage( packageID:String, descriptorPath:String ):void
		{
			if( descriptorPaths[packageID] != null )
			{
				throw new Exception( "Parameter 'packageID' must be a unique resource package identifier" );
			}

			if( packageID == "main" )
			{
				hasMainResource = true;
			}

			descriptorPaths[packageID] = descriptorPath.replace( /^\/{1,}/, "" );
		}

	}// EOC
}