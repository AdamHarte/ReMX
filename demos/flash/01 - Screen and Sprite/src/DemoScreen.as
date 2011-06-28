package
{
	import remx.GameApp;
	import remx.GameScreen;
	import remx.Sprite;

	/**
	 * This is the primary (main) game screen, it is the first screen to be
	 * constructed when the game is initialized.
	 *
	 * Because a primary (main) resource package was registered this screen can access the
	 * resources in that package as soon as the onConstruct() method is called.
	 */
	public class DemoScreen extends GameScreen
	{
		private var game:GameApp;
		private var sprite:Sprite; // remx.Sprite

		/**
		 * This method is called when the screen is constructed.
		 */
		protected override function onConstruct( game:GameApp ):void
		{
			this.game = game;

			// Sprite objects should not be created directly, the createSprite() method
			// should be used. Any sprite objects created directly will not be
			// provided with the information they need to be rendered.
			sprite = game.resource.createSprite( "demoSprite" );

			// For this demo the sprite is simply positioned in the middle of the screen.
			sprite.x = game.width  - sprite.width  >> 1;
			sprite.y = game.height - sprite.height >> 1;
		}

		/**
		 * This method is called once per frame. Anything that needs to be
		 * updated must be updated when this method is called.
		 */
		protected override function onUpdate():void
		{}

		/**
		 * This method is called once per frame. Any graphics that need to be
		 * rendered must be rendered when this method is called.
		 */
		protected override function onRender():void
		{
			// All graphics are rendered using the graphics.draw() method.
			game.graphics.draw( sprite );
		}

	}// EOC
}