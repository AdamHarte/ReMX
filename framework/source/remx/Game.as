package remx
{
	import flash.display.Sprite;

	/**
	 */
	public class Game extends Sprite
	{
		//------------------------------------------------------------------------------------------
		//
		// STATIC - PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		static private var instance:Game = null;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp      = null;
		private var config:GameConfig = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function Game( config:GameConfig )
		{
			this.config = config;

			if( Object(this).constructor == null )
			{
				throw new Exception( "Game class must be extended" );
			}

			if( instance != null )
			{
				throw new Exception( "Game instance cannot be constructed" );
			}

			instance = this;

			if( stage != null )
			{
				initialize();
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function initialize():void
		{
			if( game == null )
			{
				GameApp.constructorLocked = false;
				game = new GameApp();
				GameApp.constructorLocked = true;

				game.run( stage, config );
			}
		}

	}// EOC
}