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
class Player extends FlxSprite
{
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		this.makeGraphic(32, 64, FlxColor.RED);

		this.maxVelocity.set(200, 450);
		
		this.acceleration.y = 300;
		
		this.drag.x = this.maxVelocity.x * 4;

	}
	
	override public function update(elapsed:Float):Void
	{
		
		
		this.acceleration.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			this.acceleration.x = -this.maxVelocity.x * ((this.isTouching(FlxObject.FLOOR)) ? 4 : 3);
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
		this.acceleration.x = this.maxVelocity.x * ((this.isTouching(FlxObject.FLOOR)) ? 4 : 3);
		}
		
		//Allows the user to pause the game
		if (FlxG.keys.anyJustPressed([P])){
			FlxG.timeScale = 1 - FlxG.timeScale;
		}
		
		//Jump
		if (FlxG.keys.anyJustPressed([SPACE, W, UP]) && this.isTouching(FlxObject.FLOOR) && this.acceleration.y > 0)
		{
			
			this.velocity.y = -this.maxVelocity.y * 0.8;
		}
		else if (FlxG.keys.anyPressed([S, DOWN]) && this.isTouching(FlxObject.CEILING) && this.acceleration.y < 0)
		{
			this.velocity.y = this.maxVelocity.y / 2;
		}
		super.update(elapsed);
	}
}