package remx
{
	/**
	 */
	public class GameScreen
	{
		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var deactivated:Boolean = true;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameScreen()
		{
			if( Object(this).constructor == GameScreen )
			{
				throw new Exception( "GameScreen class must be extended" );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function construct( game:GameApp ):void
		{
			onConstruct( game );
		}

		/**
		 */
		internal function deconstruct():void
		{
			onDeconstruct();
		}

		/**
		 */
		internal function update():void
		{
			onUpdate();
		}

		/**
		 */
		internal function render():void
		{
			onRender();
		}

		/**
		 */
		internal function activate():void
		{
			if( deactivated )
			{
				onActivate();
				deactivated = false;
			}
		}

		/**
		 */
		internal function deactivate():void
		{
			if( deactivated == false )
			{
				onDeactivate();
				deactivated = true;
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// PROTECTED METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		protected function onConstruct( game:GameApp ):void {}

		/**
		 */
		protected function onDeconstruct():void {}

		/**
		 */
		protected function onUpdate():void {}

		/**
		 */
		protected function onRender():void {}

		/**
		 */
		protected function onActivate():void {}

		/**
		 */
		protected function onDeactivate():void {}

	}// EOC
}