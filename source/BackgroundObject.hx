package;

import flixel.math.FlxRandom;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * Objects that appear in Background
 * @author John Steigerwald
 */
class BackgroundObject extends FlxSprite {
	
	
	public function new(_p:Player) 
	{
		var rng:FlxRandom = new FlxRandom();
		super(-100, _p.y - 400);
		if (rng.bool())
		{
			loadGraphic(AssetPaths.unicorn_sprite__png, true, 112, 77);
			animation.add("play", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 9);
		}
		else
		{
			loadGraphic(AssetPaths.flying_van__png, true, 300, 100);
			animation.add("play", [0, 1], 3);
		}
		this.animation.play("play");
		
		this.velocity.x = 160;
	}
	
}