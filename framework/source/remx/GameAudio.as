package remx
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 */
	public final class GameAudio extends GameSystem
	{
		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		public var masterSoundVolume:Number = 1.0;
		public var masterMusicVolume:Number = 1.0;

		public var musicFadeTime:Number = 2.0;

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private const ERR_RESOURCE_NOT_FOUND:String =
			"%1 resource '%2' does not exist";

		private var game:GameApp = null;

		private var soundRegister:Dictionary = new Dictionary();
		private var musicRegister:Dictionary = new Dictionary();

		private var nextChannelID:uint  = 1;
		private var channels:Dictionary = new Dictionary();

		private var musicRX:MusicRX           = null;
		private var musicRX2:MusicRX          = null;
		private var musicPlayer:Sound         = null;
		private var musicChannel:SoundChannel = null;
		private var musicFading:Boolean       = false;
		private var musicFadeStep:Number      = 0.0;
		private var musicFadeVolume:Number    = 0.0;

		private var transform:SoundTransform = new SoundTransform();

		//------------------------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function GameAudio()
		{}

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		public function playSound( soundID:String, volume:Number=1.0, balance:Number=0.0 ):uint
		{
			var sound:SoundRX = soundRegister[soundID];

			if( sound == null )
			{
				throw new Exception( ERR_RESOURCE_NOT_FOUND, "Sound", soundID );
			}

			transform.volume = volume * masterSoundVolume;
			transform.pan    = balance;

			if( sound.repeated )
			{
				channels[nextChannelID] = sound.source.play( 0.0, int.MAX_VALUE, transform );
				return nextChannelID++;
			}

			sound.source.play( 0.0, 0, transform );
			return 0;
		}

		/**
		 */
		public function stopSound( channelID:uint ):void
		{
			var channel:SoundChannel = channels[channelID];

			if( channel == null )
			{
				return;
			}

			channel.stop();
			delete channels[channelID];
		}

		/**
		 */
		public function stopSounds():void
		{
			for( var id:* in channels )
			{
				SoundChannel(channels[id]).stop();
				delete channels[id];
			}
		}

		/**
		 */
		public function setSoundVolume( channelID:uint, volume:Number ):void
		{
			var channel:SoundChannel = channels[channelID];

			if( channel == null )
			{
				return;
			}

			transform        = channel.soundTransform;
			transform.volume = volume * masterSoundVolume;

			channel.soundTransform = transform;
		}

		/**
		 */
		public function setSoundBalance( channelID:uint, balance:Number ):void
		{
			var channel:SoundChannel = channels[channelID];

			if( channel == null )
			{
				return;
			}

			transform     = channel.soundTransform;
			transform.pan = balance;

			channel.soundTransform = transform;
		}

		/**
		 */
		public function playMusic( musicID:String ):void
		{
			var music:MusicRX = musicRegister[musicID];

			if( music == null )
			{
				throw new Exception( ERR_RESOURCE_NOT_FOUND, "Music", musicID );
			}

			stopMusic();

			if( musicFading )
			{
				musicRX2 = music;
				return;
			}

			musicRX = music;
			startMusic();
		}

		/**
		 */
		public function stopMusic():void
		{
			musicRX2 = null;

			if( musicRX == null || musicFading )
			{
				return;
			}

			if( musicFadeTime > 0.0 )
			{
				musicFadeVolume = musicChannel.soundTransform.volume;
				musicFadeStep   = musicFadeVolume / ( musicFadeTime * game.config.gameFrameRate );
				musicFading     = true;
				return;
			}

			musicChannel.removeEventListener( Event.SOUND_COMPLETE, onMusicComplete );
			musicChannel.stop();

			try
			{
				musicPlayer.removeEventListener( IOErrorEvent.IO_ERROR, onMusicIOError );
				musicPlayer.close();
			}
			catch( error:Error )
			{}

			musicRX     = null;
			musicPlayer = null;
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
		internal override function update():void
		{
			if( musicFading == false )
			{
				return;
			}

			musicFadeVolume -= musicFadeStep * game.timeDelta;

			if( musicFadeVolume > 0.0 )
			{
				transform.volume = musicFadeVolume;
				transform.pan    = 0.0;
				musicChannel.soundTransform = transform;
				return
			}

			musicChannel.removeEventListener( Event.SOUND_COMPLETE, onMusicComplete );
			musicChannel.stop();

			try
			{
				musicPlayer.removeEventListener( IOErrorEvent.IO_ERROR, onMusicIOError );
				musicPlayer.close();
			}
			catch( error:Error )
			{}

			musicRX     = musicRX2;
			musicRX2    = null;
			musicPlayer = null;
			musicFading = false;

			startMusic();
		}

		/**
		 */
		internal function registerSound( sound:SoundRX ):void
		{
			soundRegister[sound.id] = sound;
		}

		/**
		 */
		internal function unregisterSound( sound:SoundRX ):void
		{
			delete soundRegister[sound.id];
		}

		/**
		 */
		internal function registerMusic( music:MusicRX ):void
		{
			musicRegister[music.id] = music;
		}

		/**
		 */
		internal function unregisterMusic( music:MusicRX ):void
		{
			delete musicRegister[music.id];
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function startMusic():void
		{
			if( musicRX == null )
			{
				return;
			}

			musicPlayer = new Sound();
			musicPlayer.addEventListener( IOErrorEvent.IO_ERROR, onMusicIOError );

			try
			{
				musicPlayer.load( new URLRequest( musicRX.path ) );
			}
			catch( error:Error )
			{
				throw new Exception( error.message );
			}

			transform.volume = masterMusicVolume;
			transform.pan    = 0.0;

			musicChannel = musicPlayer.play( 0.0, 0, transform );
			musicChannel.addEventListener( Event.SOUND_COMPLETE, onMusicComplete );
		}

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE METHODS - NATIVE EVENT LISTENERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function onMusicComplete( event:Event ):void
		{
			musicChannel.removeEventListener( Event.SOUND_COMPLETE, onMusicComplete );

			try
			{
				musicPlayer.removeEventListener( IOErrorEvent.IO_ERROR, onMusicIOError );
				musicPlayer.close();
			}
			catch( error:Error )
			{}

			if( musicRX.repeated )
			{
				startMusic();
				return;
			}

			musicRX     = null;
			musicPlayer = null;
		}

		/**
		 */
		private function onMusicIOError( event:IOErrorEvent ):void
		{
			throw new Exception( event.text );
		}

	}// EOC
}