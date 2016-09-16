package;

import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import Std;

/**
 * Player Character
 * @author John Steigerwald
 */
class Player extends FlxSprite
{
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		this.loadGraphic(AssetPaths.sk8r__png,true, 25, 33);
		this.scale.set(2, 2);
		this.centerOrigin();
		this.updateHitbox();
		this.maxVelocity.set(200, 450);
		
		this.acceleration.y = 300;
		
		this.drag.x = this.maxVelocity.x * 4;	
		
		//Set up the animations for the player character
		setFacingFlip(FlxObject.LEFT, true,false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("lr", [0, 1, 2], 6, false);
		animation.add("idle", [7, 8], 2, true);
		animation.add("jump", [4, 5], 2, true);
	}
	
	override public function update(elapsed:Float):Void
	{
		
		
		this.acceleration.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			facing = FlxObject.LEFT;
			
			this.acceleration.x = -this.maxVelocity.x * ((this.isTouching(FlxObject.FLOOR)) ? 4 : 3);
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			
			facing = FlxObject.RIGHT;
			
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
		
		//Play the proper animation for the player
		if ( Math.abs(velocity.x) < .1 && !(touching == FlxObject.NONE))
		{
			animation.play("idle");
			
		}
		else if (!(touching == FlxObject.NONE))
		{
			animation.play("lr");
		}
		else
		{
			animation.play("jump");
		}
		
		//Prevent the player from falling off the sides of the screen horizontally
		if (x<0+width/2){
			x = width/2;
		}
		else if (x > FlxG.camera.width - width / 2 - 50)
		{
			x = FlxG.camera.width-width/2-50;
		}
		
		super.update(elapsed);
	}
}