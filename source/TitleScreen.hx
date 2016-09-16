package;

import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.FlxG;
/**
 * Contains anything needed for the title screen, when the player gets the candy, the title screen is erased
 * @author John Steigerwald
 */
class TitleScreen extends FlxObject
{
	
	private var _fadeOut:Bool; //Determines whether the title objects should fade out
	private var _titleSplash:FlxSprite; //Title card for the game
	private var _guideButton:FlxButton; //Should we add a How to play section this button will be used

	public function new(X:Float=0, Y:Float=0, Width:Float=0, Height:Float=0) 
	{
		super(X, Y, Width, Height);
		_titleSplash = new FlxSprite(0, 0);
		_titleSplash.makeGraphic(400, 200);
		_titleSplash.screenCenter();
		_titleSplash.y -= 25;
		FlxG.state.add(_titleSplash);
		
	}
	/*
	* Start fading so the gameplay can take over;
	*/ 
	public function startDestroy()
	{
		_fadeOut = true;
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (_fadeOut)
		{
			FlxTween.tween(_titleSplash, {alpha: 0}, .5);	
		}
		
		super.update(elapsed);
		
		if (_titleSplash.alpha == 0)
		{
			this.destroy();
		}
	}
	override public function destroy():Void 
	{
		_titleSplash.destroy();
		super.destroy();
	}
}