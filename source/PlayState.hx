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
	private var _floorGroup:FlxGroup; //Used for the starting floor
	private var _collectibleGroup:FlxTypedGroup<Collectible>; //Used fo collsion detection of all collectibles
	private var _floor:FlxSprite; //Floor used for at start
	private var _cameraOffset:Int = 300; //Offset for postioning the camera in reagrds to the player
	private var _playerParticleSys:ModParticleSystem; //Particle system used when getting a collectible
	private var _RNG:FlxRandom; //Random number generator
	private var _scoreText:FlxText; //If a hud is created this shhould be moved into that class
	
	private var _killHeight:Float = 1000; //When the player falls to this height, the player will lose the current round
	
	private var bgSF:Float = 2.05787; //The scaling factor needed for backgrounds to fit on the screen
	private var _baseBackground:FlxSprite;
	
	private var _bottomScrollBackground:FlxSprite;
	private var _middleScrollBackground:FlxSprite;
	private var _topScrollBackground:FlxSprite;
	
	//Can be compartmentalized into own class using FlxG.state.add
	private var _spawner:Spawner; //Used to spawn collectibles
	private var _timer:FlxTimer; //Time between spawns
	
	override public function create():Void
	{
		//Disable the mouse
		FlxG.mouse.visible = false;
	
		//Backgrounds
		_baseBackground = new FlxSprite(0, 0);
		_baseBackground.loadGraphic(AssetPaths.background01__png, false, 640, 1308);
		
		_baseBackground.scale.set(bgSF,bgSF);
		_baseBackground.setPosition(165,-500);
		add(_baseBackground);
		
		_bottomScrollBackground = new FlxSprite(0, 0);
		_bottomScrollBackground.loadGraphic(AssetPaths.repeating_sky01__png, false, 640, 1308);
		_middleScrollBackground = new FlxSprite(0, 0);
		_middleScrollBackground.loadGraphic(AssetPaths.repeating_sky01__png, false, 640, 1308);
		_topScrollBackground = new FlxSprite(0, 0);
		_topScrollBackground.loadGraphic(AssetPaths.repeating_sky01__png, false, 640, 1308);
		
		_bottomScrollBackground.scale.set(bgSF,bgSF);
		_bottomScrollBackground.setPosition(165,-500-944);
		add(_bottomScrollBackground);
		
		_middleScrollBackground.scale.set(bgSF,bgSF);
		_middleScrollBackground.setPosition(165,-500-944*2);
		add(_middleScrollBackground);
		
		_topScrollBackground.scale.set(bgSF,bgSF);
		_topScrollBackground.setPosition(165,-500-944*3);
		add(_topScrollBackground);
		
		//Set up a testing floor
		_floorGroup = new FlxGroup();
		_floor = new FlxSprite(10, FlxG.height - 25);
		_floor.makeGraphic(FlxG.width - 20, 20, FlxColor.TRANSPARENT);
		_floor.immovable = true;
		_floor.solid = true;
		_floor.elasticity = 0.8;
		_floorGroup.add(_floor);
		add(_floorGroup);
		add(_floor);
		
		//Create the player and particle system actor
		_player = new Player(FlxG.width/2, _floor.y-64);
		_spawner = new Spawner(FlxG.width/2, 0, _player);
		_playerParticleSys = new ModParticleSystem(_player, "particle_test.png", 0);
		add(_playerParticleSys); //Particle system is added first so renders after the System
		add(_spawner);
		add(_player);
		
		FlxG.watch.add(_player, "y");
		
		//Create a group to conatain all the collectibles, used for collsion detection
		_collectibleGroup = new FlxTypedGroup<Collectible>();
		add(_collectibleGroup);
		
		//Setup the display for the score, Scrollfactor is set to zero
		_scoreText = new FlxText(10, 10, 50, Std.string(_score), 18);
		_scoreText.scrollFactor.x = _scoreText.scrollFactor.y = 0;
		add(_scoreText);
		
		_timer = new FlxTimer();
		_timer.start(.5, spawnCollectible, 0);
		
		//Sys.time wont work
		_RNG = new FlxRandom(12);
		
		//Start the camera off at the player
		FlxG.camera.scroll.y = _player.y - _cameraOffset;
		//FlxG.camera.follow(_player, PLATFORMER);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		
		scoreTally(elapsed);
		
		_killHeight = Math.min(_killHeight, _player.y + 570);
		if (_killHeight <= _player.y){
			FlxG.switchState(new PlayState());
		}
		//Will be enabled after testing, for now the camera does not scroll
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, _player.y-_cameraOffset, .45);
		FlxG.collide(_player, _floorGroup);
		//FlxG.overlap(_player, _collectibleGroup, playerCollectibleOverlap);
		//FlxG.overlap is not accurate enough when rotation and speed are 
		for (_c in _collectibleGroup)
		{
			if (FlxG.pixelPerfectOverlap(_player, _c, 255))
			{
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
		
		//Possible Juice: Change the candy sprite to a wrapper
		
		//Give the fading away collectible a random velocity, release particles, and play a sound
		collectible.angularVelocity = _RNG.float(45,90) * _RNG.int(-1,1,[0]);
		_playerParticleSys.releaseParticles(5);
		FlxG.sound.play(AssetPaths.infringement__wav);
	
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
	
	private function spawnCollectible(t:FlxTimer):Void
	{
		_spawner.moveSpawner();
		var _c:Collectible = new Collectible(_spawner.x,_spawner.y);
		_collectibleGroup.add(_c);
		_c.angularVelocity = _RNG.float(20,65) * _RNG.int(-1,1,[0]);
		add(_c);
	}
}