package
{
	import remx.GameApp;
	import remx.GameScreen;
	import remx.Sprite;

	/**
	 */
	public final class DemoScreen extends GameScreen
	{
		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp;
		private var robo:Sprite;

		//------------------------------------------------------------------------------------------
		//
		// PROTECTED METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		protected override function onConstruct( game:GameApp ):void
		{
			this.game = game;
			robo = game.resource.createSprite( "robo" );
		}

		/**
		 */
		protected override function onUpdate():void
		{
			robo.x += 0.1 * ( game.controls.mouseX - robo.x );
			robo.y += 0.1 * ( game.controls.mouseY - robo.y );
		}

		/**
		 */
		protected override function onRender():void
		{
			game.graphics.draw( robo );
		}

	}// EOC
}