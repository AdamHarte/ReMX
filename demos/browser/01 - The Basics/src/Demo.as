package
{
	import remx.Game;
	import remx.GameConfig;

	/**
	 */
	public final class Demo extends Game
	{
		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Demo()
		{
			var config:GameConfig = new GameConfig();

			config.gameWidth     = 640;
			config.gameHeight    = 480;
			config.gameFrameRate = 40;
			config.debug         = false;

			config.registerScreen( "demo-screen", DemoScreen, true );

			config.registerResource( "demo-resource", "res/main.xml", true );

			super( config );
		}

	}// EOC
}