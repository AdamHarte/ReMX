package remx
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 */
	public final class GameNetwork extends GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES - EVENTS
		//
		//------------------------------------------------------------------------------------------

		public var onRequestSent:Function = null; // ( requestID:uint ):void
		public var onResponse:Function    = null; // ( requestID:uint, data:Data ):void

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private const REQUEST_METHOD:String       = URLRequestMethod.POST;
		private const REQUEST_CONTENT_TYPE:String = "application/x-remx-data";

		private var game:GameApp = null;

		private var queue:Vector.<NetworkRequest> = new Vector.<NetworkRequest>();

		private var stream:URLStream = null;

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameNetwork()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function sendRequest( uri:String, data:Data=null ):uint
		{
			var bytes:ByteArray = new ByteArray();

			bytes.writeUnsignedInt( game.config.gameUID );

			if( data != null )
			{
				bytes.writeUTF( getQualifiedClassName( data ) );
				data.save( bytes );
			}
			else
			{
				bytes.writeShort( 0 );
			}

			var nr:NetworkRequest = new NetworkRequest();

			nr.request.data        = bytes;
			nr.request.method      = REQUEST_METHOD;
			nr.request.contentType = REQUEST_CONTENT_TYPE;

			if( queue.push( nr ) == 1 )
			{
				sendNextRequest();
			}

			return nr.id;
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

		/**
		 */
		internal override function shutdown():void
		{
			try
			{
				stream.close();
			}
			catch( error:Error )
			{}
		}

		/**
		 */
		internal override function reset():void
		{
			onRequestSent = null;
			onResponse    = null;

			try
			{
				stream.close();
				stream.removeEventListener( Event.OPEN,            onStreamOpen     );
				stream.removeEventListener( Event.COMPLETE,        onStreamComplete );
				stream.removeEventListener( IOErrorEvent.IO_ERROR, onStreamIOError  );
				stream = null;
			}
			catch( error:Error )
			{}
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function sendNextRequest():void
		{
			stream = new URLStream();

			stream.addEventListener( Event.OPEN,            onStreamOpen     );
			stream.addEventListener( Event.COMPLETE,        onStreamComplete );
			stream.addEventListener( IOErrorEvent.IO_ERROR, onStreamIOError  );

			try
			{
				stream.load( queue[0].request );
			}
			catch( error:Error )
			{
				throw new Exception( error.message );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - BROADCASTERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function broadcastRequestSent( requestID:uint ):void
		{
			if( onRequestSent != null )
			{
				onRequestSent( requestID );
			}
		}

		/**
		 */
		private function broadcastResponse( requestID:uint, data:Data ):void
		{
			if( onResponse != null )
			{
				onResponse( requestID, data );
			}
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - NATIVE EVENT LISTENERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function onStreamOpen( event:Event ):void
		{
			broadcastRequestSent( queue[0].id );
		}

		/**
		 */
		private function onStreamComplete( event:Event ):void
		{
			stream.removeEventListener( Event.OPEN,            onStreamOpen     );
			stream.removeEventListener( Event.COMPLETE,        onStreamComplete );
			stream.removeEventListener( IOErrorEvent.IO_ERROR, onStreamIOError  );

			var data:Data = null;

			if( stream.bytesAvailable != 0 )
			{
				var dataClass:Class = getDefinitionByName( stream.readUTF() ) as Class;

				data = new dataClass();
				data.restore( stream );
			}

			stream = null;

			broadcastResponse( queue.shift().id, data );

			if( queue.length != 0 && stream == null )
			{
				sendNextRequest();
			}
		}

		/**
		 */
		private function onStreamIOError( event:IOErrorEvent ):void
		{
			throw new Exception( event.text );
		}

	}// EOC
}

import flash.net.URLRequest;

/**
 */
final class NetworkRequest
{
	static private var nextID:uint = 1;

	public const id:uint = nextID++;
	public const request:URLRequest = new URLRequest();
}