package remx
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	RUNTIME::AIR
	{
		import flash.filesystem.File;
		import flash.filesystem.FileMode;
		import flash.filesystem.FileStream;
	}

	RUNTIME::FLASH
	{
		import flash.net.SharedObject;
		import flash.utils.ByteArray;
	}

	/**
	 */
	public final class GameStorage extends GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		private var encodedCache:Dictionary = new Dictionary();

		RUNTIME::AIR
		private var file:File = new File();

		RUNTIME::AIR
		private var stream:FileStream = new FileStream();

		RUNTIME::FLASH
		private var so:SharedObject = SharedObject.getLocal( "remx.storage" );

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameStorage()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		RUNTIME::AIR
		public function hasData( id:String ):Boolean
		{
			file.url = game.DATA_DIRECTORY + "/" + encodeID( id );
			return file.exists;
		}

		/**
		 */
		RUNTIME::AIR
		public function getData( id:String ):*
		{
			file.url = game.DATA_DIRECTORY + "/" + encodeID( id );

			if( file.exists == false )
			{
				return null;
			}

			stream.open( file, FileMode.READ );

			var dataClass:Class = getDefinitionByName( stream.readUTF() ) as Class;

			var data:Data = new dataClass();
			data.restore( stream );

			stream.close();

			return data;
		}

		/**
		 */
		RUNTIME::AIR
		public function setData( id:String, data:Data ):Boolean
		{
			file.url = game.DATA_DIRECTORY + "/" + encodeID( id );

			stream.open( file, FileMode.WRITE );
			stream.writeUTF( getQualifiedClassName( data ) );

			data.save( stream );

			stream.close();

			return true;
		}

		/**
		 */
		RUNTIME::AIR
		public function deleteData( id:String ):Boolean
		{
			file.url = game.DATA_DIRECTORY + "/" + encodeID( id );

			if( file.exists )
			{
				file.deleteFile();
				return true;
			}

			return false;
		}

		/**
		 */
		RUNTIME::AIR
		public function clear():Boolean
		{
			file.url = game.DATA_DIRECTORY;

			try
			{
				file.deleteDirectory( true );
				return true;
			}
			catch( error:Error )
			{}

			return false;
		}

		/**
		 */
		RUNTIME::FLASH
		public function hasData( id:String ):Boolean
		{
			return so.data[encodeID( id )] != null;
		}

		/**
		 */
		RUNTIME::FLASH
		public function getData( id:String ):*
		{
			var bytes:ByteArray = so.data[encodeID( id )];

			if( bytes == null )
			{
				return null;
			}

			bytes.position = 0;

			var dataClass:Class = getDefinitionByName( bytes.readUTF() ) as Class;

			var data:Data = new dataClass();
			data.restore( bytes );

			return data;
		}

		/**
		 */
		RUNTIME::FLASH
		public function setData( id:String, data:Data ):Boolean
		{
			var bytes:ByteArray = new ByteArray();

			bytes.writeUTF( getQualifiedClassName( data ) );

			data.save( bytes );

			so.data[encodeID( id )] = bytes;

			return true;
		}

		/**
		 */
		RUNTIME::FLASH
		public function deleteData( id:String ):Boolean
		{
			var bytes:ByteArray = so.data[encodeID( id )];

			if( bytes != null )
			{
				bytes.length = 0;
				delete so.data[encodeID( id )];
				return true;
			}

			return false;
		}

		/**
		 */
		RUNTIME::FLASH
		public function clear():Boolean
		{
			var bytes:ByteArray;

			for( var id:String in so.data )
			{
				bytes = so.data[id];
				bytes.length = 0;
				delete so.data[id];
			}

			return true;
		}

		//------------------------------------------------------------------------------------------
		//
		// INTERNAL METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		internal override function initialize( game:GameApp ):void
		{
			this.game = game;
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function encodeID( id:String ):String
		{
			if( encodedCache[id] != null )
			{
				return encodedCache[id];
			}

			var i:int   = id.length;
			var a:Array = new Array( i );

			while( i-- )
			{
				a[i] = id.charCodeAt( i ).toString( 16 );
			}

			return encodedCache[id] = a.join( "" );
		}

	}// EOC
}