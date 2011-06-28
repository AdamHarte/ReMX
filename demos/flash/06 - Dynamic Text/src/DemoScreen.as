package
{
	import remx.GameApp;
	import remx.GameScreen;
	import remx.Grid;
	import remx.GridData;
	import remx.Text;

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
		private var text:Text;
		private var string:String;

		/**
		 * This method is called when the screen is constructed.
		 */
		protected override function onConstruct( game:GameApp ):void
		{
			this.game = game;

			// Text objects should not be created directly, the createText() method
			// should be used. Any text objects created directly will not be
			// provided with the information they need to be rendered.
			text = game.resource.createText( "chunky" );
		}

		/**
		 * This method is called once per frame. Anything that needs to be
		 * updated must be updated when this method is called.
		 */
		protected override function onUpdate():void
		{
			// Add a random character to the string.
			if( Math.random() > 0.9 )
			{
				string += " ";
			}
			else if( Math.random() > 0.9 )
			{
				string += "\n";
			}
			else
			{
				string += String.fromCharCode( 65 + ( 16 * Math.random() >> 0 ) );
			}

			// Update the text.
			text.setText( string );

			// Center the text.
			text.x = game.width  - text.width  >> 1;
			text.y = game.height - text.height >> 1;

			// Limit the string length.
			if( string.length == 200 )
			{
				string = "";
			}
		}

		/**
		 * This method is called once per frame. Any graphics that need to be
		 * drawn to the screen must be drawn when this method is called.
		 */
		protected override function onRender():void
		{
			// Draw the text to the screen.
			game.graphics.draw( text );
		}

	}// EOC
}