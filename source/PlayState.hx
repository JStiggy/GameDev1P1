package;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.util.FlxSave;

class PlayState extends FlxState
{
	private var _incre:Float=0;
	private var _EGroup:FlxTypedGroup<Explode>;
	
	private var _hScore:Float; //High Score fp the current session
	private var _score:Float = 0; //Actual hard score value, used with _DisplayScore for lerp
	private var _displayScore:Float = 0; //Score that is being displayed on screen
	private var _player:Player; 
	private var _collectibleGroup:FlxTypedGroup<Collectible>; //Used fo collsion detection of all collectibles
	private var _floor:FlxSprite; //Floor used for at start
	private var _cameraOffset:Int = 300; //Offset for postioning the camera in reagrds to the player
	private var _playerParticleSys:ModParticleSystem; //Particle system used when getting a collectible
	private var _RNG:FlxRandom; //Random number generator
	private var _scoreText:FlxText;
	private var _hScoreText:FlxText;
	private var _killHeight:Float = 1000; //When the player falls to this height, the player will lose the current round
	private var _bgSF:Float = 2.05787; //The scaling factor needed for backgrounds to fit on the screen
	private var _baseBackground:FlxSprite; //Background after collecting a collectible
	private var _tripBackground:TripBackground; //Transitional background used before _baseBackground
	private var _scrollbackgroundGroup:FlxTypedGroup<FlxSprite>; //Contains all the scrolling backgrounds
	private var _spawner:Spawner; //Used to spawn collectibles
	private var _timer:FlxTimer; //Time between spawns
	private var _musicPlayer:FlxSound; //Used to play music, has the ability to fade the music in and out
	private var _title:TitleScreen; //Handle all intro content
	private var _creepRain:CreepRain;
	
	override public function create():Void
	{
		//Load HigfhScore data
		var _gameSave:FlxSave = new FlxSave();
		_gameSave.bind("HighScore"); 
		//This verion allows Highscores to save between playthroughs
		_gameSave.data.hScore = Math.max (0, _gameSave.data.hScore);
		//This version wipes HighScpores between rounds, useful for demoing
		//_gameSave.data.hScore = 0;
		_gameSave.flush();
		_hScore = _gameSave.data.hScore;
		//Disable the mouse
		FlxG.mouse.visible = false;
	
		//Prevent the player from softlocking the game by pausing right as they die
		FlxG.timeScale = 1;

		_RNG = new FlxRandom();
		//Backgrounds
		_baseBackground = new FlxSprite(0, 0);
		_baseBackground.loadGraphic(AssetPaths.background01__png, false, 640, 1308);
		_baseBackground.scale.set(_bgSF, _bgSF);
		_baseBackground.setPosition(165, -500);
		add(_baseBackground);
		_baseBackground.kill();
		_tripBackground = new TripBackground();
		add(_tripBackground);
		
		//Set up the titlescreen
		_title = new TitleScreen(0, 0);
		add(_title);
		
		//Add the creepy candy dealer to the scene
		var _creep:FlxSprite = new FlxSprite(570, 395);
		_creep.loadGraphic(AssetPaths.candyman__png,false);
		_creep.scale.set(2.5, 2.5);
		add(_creep);
		
		//Intialize the scrolling backgrounds for game play
		_scrollbackgroundGroup = new FlxTypedGroup<FlxSprite>();
		add(_scrollbackgroundGroup);
		for (i in 1 ... 4)
		{
			var _bg:FlxSprite = new FlxSprite(0, 0);
			_bg.loadGraphic("assets/images/Backgrounds/repeating_sky" + Std.string(_RNG.int(1, 1)) + ".png", false, 640, 1308);
			_bg.scale.set(_bgSF, _bgSF);
			_bg.setPosition(165, -450 - 944 * i);
			add(_bg);
			_scrollbackgroundGroup.add(_bg);
		}
		
		//Set up a floor
		_floor = new FlxSprite(10, FlxG.height - 25);
		_floor.makeGraphic(FlxG.width - 20, 20, FlxColor.TRANSPARENT);
		_floor.immovable = true;
		_floor.solid = true;
		_floor.elasticity = 0.8;
		add(_floor);
		
		_player = new Player(FlxG.width/2, _floor.y-64);
		_creepRain = new CreepRain(_player);
		add(_creepRain);
		
		//Create the player and particle system actor
		_spawner = new Spawner(FlxG.width/2, 0, _player);
		_playerParticleSys = new ModParticleSystem(_player, "particle.png", 0);
		add(_playerParticleSys); //Particle system is added first so renders after the System
		add(_spawner);
		add(_player);
		
		//Create a group to conatain all the collectibles, used for collsion detection
		_collectibleGroup = new FlxTypedGroup<Collectible>();
		add(_collectibleGroup);
		
		_EGroup = new FlxTypedGroup<Explode>();
		add(_EGroup);
		
		//Setup the display for the score, Scrollfactor is set to zero
		_scoreText = new FlxText(10, 10, 400, Std.string(_score), 18);
		_scoreText.scrollFactor.x = _scoreText.scrollFactor.y = 0;
		_scoreText.setFormat(null, 18, FlxColor.BLACK);
		_scoreText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);

		_hScoreText = new FlxText(10, 30, 400, Std.string(_score), 18);
		_hScoreText.scrollFactor.x = _hScoreText.scrollFactor.y = 0;
		_hScoreText.text = "High Score: " + Std.string(_hScore);
		_hScoreText.setFormat(null, 18, FlxColor.BLACK);
		_hScoreText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		
		
		//Create a timer that spawns a collectible every .5 seconds
		_timer = new FlxTimer();
		
		//Start the music for the scene
		_musicPlayer = new FlxSound();
		_musicPlayer.loadEmbedded(AssetPaths.slow_candy__ogg, true);
		_musicPlayer.play();
		_musicPlayer.fadeIn(1.5, 0, .5);
		
		_title.player = _player;
		_title.creep = _creep;
		
		//Start the camera off at the player
		FlxG.camera.scroll.y = _player.y - _cameraOffset;
		FlxG.camera.fade(FlxColor.BLACK, 2, true);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		scoreTally(elapsed);
		
		//Pressing H is just for demoing purposes
		if (FlxG.keys.anyJustPressed([H]) || (_score % 420 == 0 && _score > 0))
		{
			_creepRain.startRain();
			_score += 100;
		}
		
		//This will only occur for a single update after the player has gained the start candy
		if (_title.storySection == 3){
			add(_scoreText);
			add(_hScoreText);
			_tripBackground.beginFade();
			_musicPlayer.loadEmbedded(AssetPaths.rock_candy__ogg, true);
			_musicPlayer.play();
			_baseBackground.reset(165, -450);
			_title.storySection = 4;
			_timer.start(.5, spawnCollectible, 0);
		}
		//Prevents the camera from scrolling until the star candy has been collected
		if(_title.storySection >= 4)
		{
			//Lerp the camer to the player location using a predefined offset
			FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, _player.y-_cameraOffset, .45);
		}
		
		//Check to see if the player has reached a certain threshold before moving the background up to it's next position
		for (_bg in _scrollbackgroundGroup)
		{
			if (_player.y < _bg.y-944*1.5)
			{
				var bgNumber = _RNG.int(1, Std.int( Math.min( 10, 1 + _score % 200 )));
				_bg.loadGraphic("assets/images/Backgrounds/repeating_sky" + Std.string (bgNumber) + ".png", true, 311, 459);
				if (bgNumber == 5)
				{
					_bg.animation.add("anim", [0, 1, 2], 5, true);
					_bg.animation.play("anim");
				}
				else
				{
					_bg.animation.stop();
				}

				_bg.scale.set(_bgSF,_bgSF);
				_bg.setPosition(_bg.x, _bg.y - 944 * 3);
				
				spawnBackgroundObject();
				
			}
		}
		
		
		//Kill the player should they fall to  acertain heigh threshold
		_killHeight = Math.min(_killHeight, _player.y + 480);
		if (_killHeight <= _player.y && _timer.time == .5){
			_title.storySection++;
			_timer.start(1, switchScene, 1);
			_musicPlayer.fadeOut(.5, 0);
			FlxG.camera.fade(FlxColor.BLACK, .5, false);
		}
		
		FlxG.collide(_player, _floor);
		
		//FlxG.overlap is not accurate enough when rotation and speed are used, instead pixel perfect overlap is used
		for (_c in _collectibleGroup)
		{
			//If the collectible is considered dead remove from the group and destroy, 
			//does not call the collision code in this case
			if (!_c.alive){
				
				_collectibleGroup.remove(_c);
				_c.destroy();
				continue;
			}
			
			if (_title.storySection  >= 6)
			{
				FlxTween.tween(_c, {alpha: 0}, .25);
				continue;
			}
			
			//Check for overlap between the collectible and player
			if (FlxG.pixelPerfectOverlap(_player, _c, 255))
			{
				if (_title.storySection == 4)
				{
					_title.storySection++;
				}
				
				playerCollectibleOverlap(_player, _c);
			}
		}
		
		
		for (_e in _EGroup)
		{
			if (_title.storySection  >= 6)
			{
				FlxTween.tween(_e, {alpha: 0}, .25);
				continue;
			}
			
			if (FlxG.pixelPerfectOverlap(_player, _e, 255)==false)
			{
				_e._overlap=false;
			}
			if (_e._overlap==true){continue;}
			
			if (FlxG.pixelPerfectOverlap(_player, _e, 255) && _player.velocity.y<0)
			{
				_e._overlap=true;
				_player.velocity.y += 1000;
				FlxG.sound.play(AssetPaths.platformhit__wav, .5);

			}
			
			else if (FlxG.pixelPerfectOverlap(_player, _e, 255)&&_player.velocity.y>=0)
			{
				_e._overlap=true;
				_player.velocity.y -= 1000;
				FlxG.sound.play(AssetPaths.platformhit__wav, .5);
			}
		}
		
		super.update(elapsed);
	}
	
	/**
	* Give the player vertical momentum on overlap with a collectible, the collectible loses collision and fades away.
	*
	* @param    player: The current Player actor in the scene
	* @param    colectible: The current collectible object being collided with
	*/
	private function playerCollectibleOverlap(player:Player, collectible:Collectible):Void
	{	
		_score += 10;
		_player.velocity.y = -player.maxVelocity.y * 1.4;
		
		//Give the collectible a random horizontal and vertical velocity, and decrease the alpha of the collectible
		FlxTween.tween(collectible, { alpha: 0, x: collectible.x + _RNG.float( -20, 20), y: collectible.y + _RNG.float( -2, -20)}, .75);
		
		//Give the fading away collectible a random velocity, release particles, and play a sound
		collectible.angularVelocity = _RNG.float(45,90) * _RNG.int(-1,1,[0]);
		_playerParticleSys.releaseParticles(.1 ,5);
		collectible.loadGraphic(AssetPaths.empty_wrapper__png, false, 29, 29);
		FlxG.sound.play(AssetPaths.candyget__wav,.25);
		//Remove collision from the collectible so that Overlap is not triggered
		collectible.solid = false;
	}
	
	/**
	* Increase the display score to be equal to the actual score using linear interpolation
	*
	* @param    elapsed: The time between frames
	*/
	private function scoreTally(elapsed:Float):Void
	{
		_displayScore =  Math.ceil(FlxMath.lerp(_displayScore, _score, .25 * elapsed));
		_scoreText.text = "Score: " + Std.string(_displayScore);
	}
	
	/**
	* Spawn a collectible at the position of the spawner after a certain time frame
	*
	* @param    t: Functions that are called by a timer need a timer as an arg
	* */
	private function spawnCollectible(t:FlxTimer):Void
	{
		_spawner.score = _score;
		_spawner.moveSpawner();
		var _c:Collectible = new Collectible(_spawner.x,_spawner.y);
		_collectibleGroup.add(_c);
		_c.angularVelocity = _RNG.float(20,65) * _RNG.int(-1,1,[0]);
		add(_c);
		
		if(_spawner.y - _incre<=-500){
			var _e:Explode = new Explode(_spawner.x + _RNG.int(-1,1,[0])*65,_spawner.y);
			
			_incre=_spawner.y;
			_EGroup.add(_e);
			
			add(_e);
		}
	}
	
	/**
	* Roll to spawn an object in the background
	* */
	private function spawnBackgroundObject():Void
	{
		var _roll = _RNG.int(0, 100);
		if (_roll > 90)
		{
			//Creep rain
			var _bgo:BackgroundObject = new BackgroundObject(_player);
			add(_bgo);
		}
		else if (_roll >65)
		{
			//Background Objects
			var _bgo:BackgroundObject = new BackgroundObject(_player);
			add(_bgo);
		}
	}
	
	/**
	* Reload scene after a set time
	*
	* @param    t: Functions that are called by a timer need a timer as an arg
	* */
	private function switchScene(t:FlxTimer):Void
	{
		var _gameSave:FlxSave = new FlxSave(); 
		_gameSave.bind("HighScore"); 
		_gameSave.data.hScore = Math.max (_score, _hScore );
		_gameSave.data.score = _score;
		_gameSave.flush();
		_musicPlayer.destroy();
		FlxG.switchState(new GameOverState());
	}	
}