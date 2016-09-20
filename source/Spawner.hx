package;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.FlxObject;
import haxe.Timer;

/**
 * Object used for spawning collectibles
 * @author John Steigerwald
 */
class Spawner extends FlxObject
{
	private var _xRange:Float; //The horizontal range the spawner will move after spawning a candy
	private var _player:Player;
	private var _RNG:FlxRandom;
	public var score:Float;
	
	public function new(X:Float, Y:Float, _p:Player) 
	{
		super(X, Y, 32, 32);
		_player = _p;
		_RNG = new FlxRandom(21);
		_xRange = 100;
	}

	public function moveSpawner() {
		var _x:Float = 0;

		do {
			_x = Math.min(_xRange + score / 5, 200) * _RNG.int( -1, 1, [0]);
			_x += this.x;
			
		} while (_x < 50 || _x > 590);
		
		this.setPosition( _x, Math.min(this.y, _player.y - 780));
	}
	
}