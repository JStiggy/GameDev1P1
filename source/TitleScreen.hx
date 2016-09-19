package;

import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.math.FlxMath;

/**
 * Contains anything needed for the title screen, when the player gets the candy, the title screen is erased
 * @author John Steigerwald
 */
class TitleScreen extends FlxObject
{
	
	public var player:Player;
	public var creep:FlxSprite;
	public var storySection:Int = 0;
	private var spBubble:FlxSprite;
	private var _titleSplash:FlxSprite; //Title card for the game

	public function new(X:Float=0, Y:Float=0, Width:Float=0, Height:Float=0) 
	{
		super(X, Y, Width, Height);
		_titleSplash = new FlxSprite(0, 0);
		_titleSplash.loadGraphic(AssetPaths.title__png, 400, 200);
		_titleSplash.screenCenter();
		_titleSplash.y -= 25;
		FlxG.state.add(_titleSplash);
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		
		
		if (storySection == 2 && FlxG.keys.anyJustReleased([SPACE]))
		{
			storySection = 3;
			FlxTween.tween(_titleSplash, {alpha: 0}, .5);
			player.canMove = true;
			spBubble.destroy();
		}
		
		if (storySection == 1 && FlxG.keys.anyJustReleased([SPACE]))
		{
			storySection = 2;
			spBubble.loadGraphic(AssetPaths.dialogue_bubble02__png, false);
			spBubble.setPosition(player.x+20, player.y - 70);
		}
		
		if (storySection == 0 && FlxMath.isDistanceWithin(player, creep, 150))
		{
			trace(FlxMath.distanceBetween(player, creep));
			storySection = 1;
			player.canMove = false;
			player.animation.play("idle");
			spBubble = new FlxSprite(creep.x - 100, creep.y - 100);
			spBubble.loadGraphic(AssetPaths.dialogue_bubble01__png, false);
			FlxG.state.add(spBubble);
		}
		
		super.update(elapsed);
	}
}