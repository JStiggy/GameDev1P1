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

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		this.makeGraphic(32, 32, FlxColor.GREEN);
		this.maxVelocity.set(0, 200);
		this.acceleration.y = 100;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (this.alpha < .05){
			this.kill();
		}
		super.update(elapsed);
	}
}