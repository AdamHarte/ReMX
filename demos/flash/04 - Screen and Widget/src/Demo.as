package
{
	import remx.Game;
	import remx.GameConfig;

	/**
	 * The main SWF document class. This is where you configure the
	 * game and register the game screens and resource packages.
	 */
	public final class Demo extends Game
	{
		/**
		 */
		public function Demo()
		{
			// CREATE A GAME CONFIG OBJECT
			var config:GameConfig = new GameConfig();

			// SET THE GAME WIDTH AND HEIGHT (THE FRAME RATE IS OPTIONAL)
			config.gameWidth     = 640;
			config.gameHeight    = 480;
			config.gameFrameRate = 40; // This is the default value.

			// OVERRIDE THE DEBUG MODE (OPTIONAL)
			// This value will default to TRUE if the SWF is running in a debug version of
			// the Flash Player or AIR Runtime, otherwise is will default to FALSE.
			// Setting this value to FALSE will improve rendering times.
			config.debug = false;

			// REGISTER THE GAME SCREENS
			// The screen ID "main" MUST be used to register a primary screen which
			// is the first screen that gets constructed when the game is initialized.
			config.registerScreen( "main", DemoScreen );

			// REGISTER THE RESOURCE PACKAGES
			// The package ID "main" CAN be used to register a primary resource package.
			// If a primary resource package is registered it will be loaded BEFORE the
			// primary screen is constructed.
			config.registerResourcePackage( "main", "res/demo.xml" );

			// SEND THE CONFIG OBJECT TO THE SUPER CONSTRUCTOR
			super( config );
		}

	}// EOC
}