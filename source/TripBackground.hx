package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;

import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;

/**
 * Two backgrounds used to make a trippy transition to the main gameplay loop.
 * @author John Steigerwald
 */
class TripBackground extends FlxSprite
{

	private var _effectSprite:FlxEffectSprite;
	private var _rainbow:FlxRainbowEffect;
	//private var _glitch:FlxGlitchEffect;
	private var _startEffect:Bool = false;
	
	public function new() 
	{
		super(0, 0);
		//Set up the normal world background
		this.loadGraphic(AssetPaths.background00__png, false, 640, 1308);
		this.scale.set(2.05787, 2.05787);
		this.setPosition(165, -502);
		
		
		//I dont really like the glitch effect that much, unless someone else REALLY likes it, it stays out.
		//_glitch = new FlxGlitchEffect(3, 4, .05, HORIZONTAL);
		//Set up an effect spriyte that has a cue 
		_rainbow = new FlxRainbowEffect(.5, .4, 20);
		_effectSprite = new FlxEffectSprite(this, [_rainbow]);
		_effectSprite.scale.set(2.05787, 2.05787);
	}
	
	
	/**
    * Start the transition to the main gameplay state with a background transition
	* this occurs when the player collects the first candy
    */
	public function beginFade()
	{
		_startEffect = true;
		_effectSprite.setPosition(165, -502);
		FlxG.state.add(_effectSprite);
		this.alpha = 0;
	}
	
	override public function update(elapsed:Float){
		//Activate a fade out when the player has collected a candy
		if (_startEffect){
				FlxTween.tween(_effectSprite, {alpha: 0}, 1.25);
		}	
		super.update(elapsed);
	}
	
}