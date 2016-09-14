package;

import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
class Explode extends FlxSprite {
	private var count:Int=0;
	private var _RNG:FlxRandom;
	private var _killHeight:Float;
	public var _overlap:Bool=false;
	public function new(X:Float=0, Y:Float=0) 
	{
		count=_RNG.int(-1,1,[0]);
		super(X, Y);
		_killHeight = Y + 1200;
		this.makeGraphic(96, 16, FlxColor.ORANGE);
		
	}
	
	override public function update(elapsed:Float):Void
	{
		this.x+=0.15*count;
		super.update(elapsed);
	}
}