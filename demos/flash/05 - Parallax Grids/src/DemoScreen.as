package
{
	import remx.GameApp;
	import remx.GameScreen;
	import remx.Grid;
	import remx.GridData;

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
		private var floor:Grid;
		private var background:Grid;

		/**
		 * This method is called when the screen is constructed.
		 */
		protected override function onConstruct( game:GameApp ):void
		{
			this.game = game;

			// Grid objects should not be created directly, the createGrid() method
			// should be used. Any grid objects created directly will not be
			// provided with the information they need to be rendered.
			floor      = game.resource.createGrid( "floor.tiles" );
			background = game.resource.createGrid( "background.tiles" );

			// The grids now have the tilesets but they do not know how to
			// draw the tiles. In order to provide that information we will
			// manually create two GridData objects for this demo.
			floor.data = new GridData();
			// Specify the number of columns and rows for the tilemap.
			floor.data.columns = 8;
			floor.data.rows    = 4;
			// Populate the 8x4 tilemap with tile indices. The indices are
			// zero-based index values of the tiles within the tilesets that
			// were defined in the resource package descriptor.
			floor.data.tilemap = new <uint>[
				0, 1, 2, 3, 0, 1, 2, 3,
				1, 2, 3, 0, 1, 2, 3, 0,
				2, 3, 0, 1, 2, 3, 0, 1,
				3, 0, 1, 2, 3, 0, 1, 2
			];
			// Tell the grid to repeat the tilemap so it fills the entire screen.
			floor.repeat = true;

			// Repeat the process for the background grid. This is very simple because
			// it only contains one tile.
			background.data = new GridData();
			background.data.columns = 1;
			background.data.rows    = 1;
			background.data.tilemap = new <uint>[
				0
			];
			background.repeat = true;

			// We now tell the background grid not to track the movement
			// of the camera (see below) absolutely, we do that by
			// adjusting the following scaler properties. This can be
			// done to any graphic object.
			background.cameraScalerX = 0.5; // half of the tracking along the x axis
		}

		/**
		 * This method is called once per frame. Anything that needs to be
		 * updated must be updated when this method is called.
		 */
		protected override function onUpdate():void
		{
			// Increase the camera's x and y positions.
			// More information about the camera will be provided at a later date.
			game.graphics.cameraX += 1;
		}

		/**
		 * This method is called once per frame. Any graphics that need to be
		 * drawn to the screen must be drawn when this method is called.
		 */
		protected override function onRender():void
		{
			// Draw the grids to the screen.
			game.graphics.draw( background );
			game.graphics.draw( floor );
		}

	}// EOC
}