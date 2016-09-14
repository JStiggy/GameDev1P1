package;

import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author John Steigerwald
 */
class Collectible extends FlxSprite {

	private var _killHeight:Float;
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		_killHeight = Y + 1200;
		this.loadGraphic(AssetPaths.candy_with_wrapper__png, false, 29, 29);
		this.maxVelocity.set(0, 100);
		this.acceleration.y = 50;
	}
	
	override public function update(elapsed:Float):Void
	{
		if ( _killHeight < this.y) alpha = 0;
		
		if (this.alpha < .05){
			this.kill();
		}
		super.update(elapsed);
	}
}