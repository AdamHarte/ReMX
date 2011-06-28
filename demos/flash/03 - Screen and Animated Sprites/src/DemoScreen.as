package
{
	import flash.geom.Point;

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
		private var robo:Sprite; // remx.Sprite
		private var points:Vector.<Point> = new Vector.<Point>();

		/**
		 * This method is called when the screen is constructed.
		 */
		protected override function onConstruct( game:GameApp ):void
		{
			this.game = game;

			// Sprite objects should not be created directly, the createSprite() method
			// should be used. Any sprite objects created directly will not be
			// provided with the information they need to be rendered.
			robo = game.resource.createSprite( "robo" );

			// For this demo a few Point objects with random x and y values are
			// created to represent the position of each sprite drawn to the screen.
			var i:int = 0;
			var n:int = 100;
			while( i < n )
			{
				points[i] = new Point( Math.random() * 600, Math.random() * 440 );
				i++;
			}
		}

		/**
		 * This method is called once per frame. Anything that needs to be
		 * updated must be updated when this method is called.
		 */
		protected override function onUpdate():void
		{}

		/**
		 * This method is called once per frame. Any graphics that need to be
		 * drawn to the screen must be drawn when this method is called.
		 */
		protected override function onRender():void
		{
			// For this demo a single sprite is drawn multiple times.
			var i:int = points.length;
			while( i-- )
			{
				robo.x = points[i].x;
				robo.y = points[i].y;

				// Draw the sprite at its new position.
				game.graphics.draw( robo );
			}
		}

	}// EOC
}