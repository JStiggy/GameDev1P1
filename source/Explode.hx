package;

import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
class Explode extends FlxSprite {

	private var _killHeight:Float;
	public var _overlap:Bool=false;
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		_killHeight = Y + 1200;
		this.makeGraphic(96, 16, FlxColor.ORANGE);
		
	}
	
	override public function update(elapsed:Float):Void
	{
		
		super.update(elapsed);
	}
}