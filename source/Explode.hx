package;

import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
class Explode extends FlxSprite {
	
	private var t:Bool=false;
	private var _Ox:Float=0;
	private var _Oy:Float=0;
	private var _killHeight:Float;
	public var _overlap:Bool=false;
	public function new(X:Float=0, Y:Float=0) 
	{
		
		_Ox=X;
		_Oy=Y;
		super(X, Y);
		_killHeight = Y + 1200;
		this.makeGraphic(96, 16, FlxColor.ORANGE);
		
	}
	
	override public function update(elapsed:Float):Void
	{
		if (this.x-_Ox>=60){t=true;}
		else if (_Ox-x>=60){t=false;}
		if (t){this.x-=0.4;}
		if (!t){this.x+=0.4;}
		super.update(elapsed);
	}
}