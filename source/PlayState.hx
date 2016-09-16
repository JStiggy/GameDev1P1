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

class PlayState extends FlxState
{
	private var _score:Float = 0; //Actual hard score value, used with _DisplayScore for lerp
	private var _displayScore:Float = 0; //Score that is being displayed on screen
	private var _player:Player; 
	private var _collectibleGroup:FlxTypedGroup<Collectible>; //Used fo collsion detection of all collectibles
	private var _floor:FlxSprite; //Floor used for at start
	private var _cameraOffset:Int = 300; //Offset for postioning the camera in reagrds to the player
	private var _playerParticleSys:ModParticleSystem; //Particle system used when getting a collectible
	private var _RNG:FlxRandom; //Random number generator
	private var _scoreText:FlxText; //If a hud is created this shhould be moved into that class
	
	private var _killHeight:Float = 1000; //When the player falls to this height, the player will lose the current round
	
	private var bgSF:Float = 2.05787; //The scaling factor needed for backgrounds to fit on the screen
	private var _baseBackground:FlxSprite;
	private var _tripBackground:TripBackground;
	
	private var _scrollbackgroundGroup:FlxTypedGroup<FlxSprite>;
	
	//Can be compartmentalized into own class using FlxG.state.add
	private var _spawner:Spawner; //Used to spawn collectibles
	private var _timer:FlxTimer; //Time between spawns
	
	override public function create():Void
	{
		//Disable the mouse
		FlxG.mouse.visible = false;
	
		//Prevent the player from softlocking the game by pausing right as they die
		FlxG.timeScale = 1;

		_RNG = new FlxRandom();
		
		//Backgrounds
		_baseBackground = new FlxSprite(0, 0);
		_baseBackground.loadGraphic(AssetPaths.background01__png, false, 640, 1308);
		_baseBackground.scale.set(bgSF, bgSF);
		_baseBackground.setPosition(165, -500);
		add(_baseBackground);
		_baseBackground.kill();
		
		_tripBackground = new TripBackground();
		add(_tripBackground);
		

		
		_scrollbackgroundGroup = new FlxTypedGroup<FlxSprite>();
		add(_scrollbackgroundGroup);
		
		for (i in 1 ... 4)
		{
			_score+= i;
			var _bg:FlxSprite = new FlxSprite(0, 0);
			_bg.loadGraphic("assets/images/Backgrounds/repeating_sky0" + Std.string(_RNG.int(1, 1)) + ".png", false, 640, 1308);
			_bg.scale.set(bgSF, bgSF);
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
		
		//Create the player and particle system actor
		_player = new Player(FlxG.width/2, _floor.y-64);
		_spawner = new Spawner(FlxG.width/2, 0, _player);
		_playerParticleSys = new ModParticleSystem(_player, "candy_particle.png", 0);
		add(_playerParticleSys); //Particle system is added first so renders after the System
		add(_spawner);
		add(_player);
		
		//Create a group to conatain all the collectibles, used for collsion detection
		_collectibleGroup = new FlxTypedGroup<Collectible>();
		add(_collectibleGroup);
		
		//Setup the display for the score, Scrollfactor is set to zero
		_scoreText = new FlxText(10, 10, 50, Std.string(_score), 18);
		_scoreText.scrollFactor.x = _scoreText.scrollFactor.y = 0;
		add(_scoreText);
		
		//Create a timer that spawns a collectible every .5 seconds
		_timer = new FlxTimer();
		_timer.start(.5, spawnCollectible, 0);
		
		//Start the music for the scene
		FlxG.sound.playMusic(AssetPaths.rock_candy__ogg, .01, true);
		
		//Start the camera off at the player
		FlxG.camera.scroll.y = _player.y - _cameraOffset;
		FlxG.camera.fade(FlxColor.WHITE, 2, true);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		
		scoreTally(elapsed);
		
		for (_bg in _scrollbackgroundGroup)
		{
			if (_player.y < _bg.y-944*1.5)
			{
				_bg.loadGraphic("assets/images/Backgrounds/repeating_sky0" + Std.string(_RNG.int(1, 2)) + ".png", false, 640, 1308);
				_bg.scale.set(bgSF,bgSF);
				_bg.setPosition(_bg.x, _bg.y - 944 * 3);
			}
		}
		
		_killHeight = Math.min(_killHeight, _player.y + 480);
		if (_killHeight <= _player.y && _timer.time == .5){
			_timer.start(1, reloadScene, 1);
			FlxG.camera.fade(FlxColor.WHITE, 1, false);
			//FlxG.switchState(new PlayState());
		}
		
		//Lerp the camer to the player location using a predefined offset
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, _player.y-_cameraOffset, .45);
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
			
			//Check for overlap between the collectible and player
			if (FlxG.pixelPerfectOverlap(_player, _c, 255))
			{
				if (!_baseBackground.alive)
				{	
					_tripBackground.beginFade();
					_baseBackground.reset(165, -450);
				}
				playerCollectibleOverlap(_player, _c);
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
		FlxTween.tween(collectible, { alpha: 0, x: collectible.x + _RNG.float(-20,20), y: collectible.y + _RNG.float(-2,-20)}, .75);
		
		//Give the fading away collectible a random velocity, release particles, and play a sound
		collectible.angularVelocity = _RNG.float(45,90) * _RNG.int(-1,1,[0]);
		_playerParticleSys.releaseParticles(5);
		collectible.loadGraphic(AssetPaths.empty_wrapper__png, false, 29, 29);
		FlxG.sound.play(AssetPaths.collectible__wav);
		
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
		_scoreText.text = Std.string(_displayScore);
	}
	
	/**
	* Spawn a collectible at the position of the spawner after a certain time frame
	*
	* @param    t: Functions that are called by a timer need a timer as an arg
	* */
	private function spawnCollectible(t:FlxTimer):Void
	{
		_spawner.moveSpawner();
		var _c:Collectible = new Collectible(_spawner.x,_spawner.y);
		_collectibleGroup.add(_c);
		_c.angularVelocity = _RNG.float(20,65) * _RNG.int(-1,1,[0]);
		add(_c);
	}
	
	/**
	* Spawn a collectible at the position of the spawner after a certain time frame
	*
	* @param    t: Functions that are called by a timer need a timer as an arg
	* */
	private function reloadScene(t:FlxTimer):Void
	{
		FlxG.switchState(new PlayState());
	}	
}