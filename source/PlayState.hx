package;

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

class PlayState extends FlxState
{
	private var _score:Float = 0; //Actual hard score value, used with _DisplayScore for lerp
	private var _displayScore:Float = 0; //Score that is being displayed on screen
	private var _player:Player; 
	private var _floorGroup:FlxGroup; //Used for the starting floor, MAY NOT NEED IN FINAL VERSION
	private var _collectibleGroup:FlxGroup; //Used fo collsion detection of all collectibles
	private var _floor:FlxSprite; //Floor used for testing, REMOVE FOR FINAL VERSION
	private var _cameraOffset:Int = 300; //Offset for postioning the camera in reagrds to the player
	private var _playerParticleSys:ModParticleSystem; //Particle system used when getting a collectible
	private var _RNG:FlxRandom; //Random number generator
	private var _scoreText:FlxText; //If a hud is created this shhould be moved into that class
		
	
	override public function create():Void
	{
		//Disable the mouse
		FlxG.mouse.visible = false;
		
		//Set up a testing floor
		_floorGroup = new FlxGroup();
		_floor = new FlxSprite(10, FlxG.height - 25);
		_floor.makeGraphic(FlxG.width - 20, 20, FlxColor.GRAY);
		_floor.immovable = true;
		_floor.solid = true;
		_floor.elasticity = 0.8;
		_floorGroup.add(_floor);
		add(_floorGroup);
		add(_floor);
		
		//Create the player and particle system actor
		_player = new Player(FlxG.width/2, _floor.y-64);
		_playerParticleSys = new ModParticleSystem(_player, "particle_test.png", 0);
		add(_playerParticleSys); //Particle system is added first so renders after the System
		add(_player);
		
		
		//Create a group to conatain all the collectibles, used for collsion detection
		_collectibleGroup = new FlxGroup();
		add(_collectibleGroup);
		
		//Setup the display for the score, Scrollfactor is set to zero
		_scoreText = new FlxText(10, 10, 50, Std.string(_score), 18);
		_scoreText.scrollFactor.x = _scoreText.scrollFactor.y = 0;
		add(_scoreText);
		
		//Sys.time wont work
		_RNG = new FlxRandom(12);
		
		//Start the camera off at the player
		FlxG.camera.scroll.y = _player.y - _cameraOffset;
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		//Spawn a collectible
		if (FlxG.keys.anyJustPressed([P])){
			var _c:Collectible = new Collectible(FlxG.height / 2, FlxG.width / 2);
			_collectibleGroup.add(_c);
			_c.angularVelocity = _RNG.float(20,65);
			add(_c);
		}
		
		scoreTally(elapsed);
		
		//Will be enabled after testing, for now the camera does not scroll
		//FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, _player.y-_cameraOffset, .45);
		FlxG.collide(_player, _floorGroup);
		FlxG.overlap(_player, _collectibleGroup, playerCollectibleOverlap);
		
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
		collectible.angularVelocity = _RNG.float(45,90);
		_playerParticleSys.releaseParticles(20);
		FlxG.sound.play(AssetPaths.infringement__wav);
	
		//Remove collision from the collectible so that Overlap is not triggered
		collectible.solid = false;
	}
	
	/**
	* Increase the display score to be equal to the actual score using linear interpolation
	*
	* @param    elapsed: The time between frames
	*/
	private function scoreTally(elapsed:Float)
	{
		_displayScore =  Math.ceil(FlxMath.lerp(_displayScore, _score, .25 * elapsed));
		_scoreText.text = Std.string(_displayScore);
	}
}