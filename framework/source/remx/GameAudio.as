package remx
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
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

		public var musicXFadeTime:Number = 0.0;

		//------------------------------------------------------------------------------------------
		//
		// PUBLIC PROPERTIES - EVENTS
		//
		//------------------------------------------------------------------------------------------

		public var onMusicStart:Function    = null; // ( musicID:String ):void
		public var onMusicComplete:Function = null; // ( musicID:String ):void
		public var onMusicProgress:Function = null; // ( musicID:String, progress:Number ):void

		//------------------------------------------------------------------------------------------
		//
		// PRIVATE PROPERTIES
		//
		//------------------------------------------------------------------------------------------

		private var game:GameApp = null;

		private var soundRegister:Dictionary = new Dictionary();
		private var musicRegister:Dictionary = new Dictionary();

		private var nextChannelID:uint  = 1;
		private var channels:Dictionary = new Dictionary();

		private var musicRX:MusicRX           = null;
		private var musicPlayer:Sound         = null;
		private var musicChannel:SoundChannel = null;

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
				throw new Exception( "Sound resource '%1' does not exist", soundID );
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
		public function updateSound( channelID:uint, volume:Number, balance:Number ):void
		{
			var channel:SoundChannel = channels[channelID];

			if( channel == null )
			{
				return;
			}

			transform = channel.soundTransform;

			if( isNaN(volume) == false )
			{
				transform.volume = volume * masterSoundVolume;
			}

			if( isNaN(balance) == false )
			{
				transform.pan = balance;
			}

			channel.soundTransform = transform;
		}

		/**
		 */
		public function playMusic( musicID:String ):void
		{}

		/**
		 */
		public function stopMusic():void
		{}

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
		internal override function reset():void
		{
			onMusicStart    = null;
			onMusicComplete = null;
			onMusicProgress = null;
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
		// PRIVATE METHODS - BROADCASTERS
		//
		//------------------------------------------------------------------------------------------

		/**
		 */
		private function broadcastMusicStart( musicID:String ):void
		{
			if( onMusicStart != null )
			{
				onMusicStart( musicID );
			}
		}

		/**
		 */
		private function broadcastMusicComplete( musicID:String ):void
		{
			if( onMusicComplete != null )
			{
				onMusicComplete( musicID );
			}
		}

		/**
		 */
		private function broadcastMusicProgress( musicID:String, progress:Number ):void
		{
			if( onMusicProgress != null )
			{
				onMusicProgress( musicID, progress );
			}
		}

	}// EOC
}