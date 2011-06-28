package
{
	import remx.GameApp;
	import remx.GameScreen;
	import remx.Widget;

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
		private var widget:Widget;

		/**
		 * This method is called when the screen is constructed.
		 */
		protected override function onConstruct( game:GameApp ):void
		{
			this.game = game;

			// Widgets objects should not be created directly, the createWidget() method
			// should be used. Any widget objects created directly will not be
			// provided with the information they need to be rendered.
			widget = game.resource.createWidget( "roboButton" );

			// For this demo this widget is simply positioned in the middle of the screen.
			widget.x = game.width  - widget.width  >> 1;
			widget.y = game.height - widget.height >> 1;

			// Add a onClick listener, this will be called when the widget is clicked.
			widget.onClick = onWidgetClick;
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
			// Draw the widget to the screen.
			game.graphics.draw( widget );
		}

		/**
		 */
		private function onWidgetClick( widget:Widget ):void
		{
			// Disable the widget.
			widget.enabled = false;
		}

	}// EOC
}