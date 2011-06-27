package remx
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	/**
	 */
	internal final class ResourcePackage
	{
		//------------------------------------------------------------------------------------------
		//
		// INTERNAL PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		internal var id:String   = null;
		internal var path:String = null;

		internal var images:Dictionary = new Dictionary();

		internal var data:Dictionary     = new Dictionary();
		internal var fonts:Dictionary    = new Dictionary();
		internal var music:Dictionary    = new Dictionary();
		internal var sounds:Dictionary   = new Dictionary();
		internal var sprites:Dictionary  = new Dictionary();
		internal var tilesets:Dictionary = new Dictionary();
		internal var widgets:Dictionary  = new Dictionary();

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function ResourcePackage()
		{}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal function dispose():void
		{
			for each( var image:BitmapData in images )
			{
				image.dispose();
			}

			images   = null;
			data     = null;
			fonts    = null;
			music    = null;
			sounds   = null;
			sprites  = null;
			tilesets = null;
			widgets  = null;
		}

	}// EOC
}