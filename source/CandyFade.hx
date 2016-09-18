package;

import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * Candy that plays animation
 * @author John Steigerwald
 */

 
class CandyFade extends FlxSprite
{
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		this.loadGraphic(AssetPaths.candy_squish__png, true, 70, 40);
		animation.add("fade", [0, 1, 2, 3, 4], 4, false);
		animation.play("fade");
	}
	
}