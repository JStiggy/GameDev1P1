package;

import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.util.FlxSave;
/**
 * Game over state, loops back to the main polay state
 * @author John Steigerwald
 */
class GameOverState extends FlxState
{
	private var _startDisplay:Bool = true;
	private var _yourScoreText:FlxText;
	private var _GameOverSplash:FlxSprite;
	private var _scoreText:FlxText;
	private var _hScoreText:FlxText;
	private var _gameSave:FlxSave;
	private var _sysObj1:FlxObject;
	private var _sysObj2:FlxObject;
	private var _particleSys1:ModParticleSystem;
	private var _particleSys2:ModParticleSystem;
	private var _musicPlayer:FlxSound;
	
	override public function create():Void
	{
		FlxG.camera.fade(FlxColor.BLACK,1,true);
		_gameSave = new FlxSave();
		_gameSave.bind("HighScore"); 
		_musicPlayer = new FlxSound();
		_musicPlayer.loadEmbedded(AssetPaths.slow_candy__ogg, true);
		_musicPlayer.play();
		_musicPlayer.fadeIn(1.5, 0, .5);
		
		var _baseBackground:FlxSprite = new FlxSprite(0, 0);
		_baseBackground.loadGraphic(AssetPaths.background01__png, false, 640, 1308);
		_baseBackground.scale.set(2.05787, 2.05787);
		_baseBackground.setPosition(165, -500);
		add(_baseBackground);
		
		_GameOverSplash = new FlxSprite(0, 0);
		_GameOverSplash.loadGraphic(AssetPaths.game_over__png, 400, 200);
		_GameOverSplash.screenCenter();
		_GameOverSplash.y -= 400;
		add(_GameOverSplash);
		
		
		_yourScoreText = new FlxText(240, 227, 400, "Your Score", 18);
		_hScoreText = new FlxText(240, 293, 400, "New High Score!", 18);
		_scoreText = new FlxText(240, 260, 400, Std.string(_gameSave.data.score), 18);
		_yourScoreText.setFormat(null, 18, FlxColor.BLACK);
		_yourScoreText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		_hScoreText.setFormat(null, 18, FlxColor.BLACK);
		_hScoreText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		_scoreText.setFormat(null, 18, FlxColor.BLACK);
		_scoreText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		/*
		_sysObj1 = new FlxObject(200, 293);
		_sysObj2 = new FlxObject(400, 293);
		add(_sysObj1);
		add(_sysObj2);
		_particleSys1 = new ModParticleSystem(_sysObj1, "candy_particle.png", 0);
		_particleSys2 = new ModParticleSystem(_sysObj2, "candy_particle.png", 0);
		add(_particleSys1);
		add(_particleSys2);
		*/
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		FlxTween.tween(_GameOverSplash, {y: 50}, .5, {ease: FlxEase.bounceOut});
		if (FlxG.keys.anyJustPressed([SPACE]) && _scoreText.alpha > .9)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1, false, switchScene);
		}
		/*
		if (_hScoreText.alpha > .9)
		{
			_particleSys1.releaseParticles(.03, 3);
			_particleSys2.releaseParticles(.03, 3);
		}
		*/
		
		if (_GameOverSplash.y == 50 && _startDisplay)
		{
			_startDisplay = false;
		
			_yourScoreText.alpha = 0;
			add(_yourScoreText);
		
			_scoreText.alpha = 0;
			add(_scoreText);
		
			if (_gameSave.data.score == _gameSave.data.hScore)
			{
				_hScoreText.alpha = 0;
				add(_hScoreText);
			}
		}
		if (!_startDisplay)
		{
			FlxTween.tween(_yourScoreText, {alpha:1}, 1);
			FlxTween.tween(_scoreText, {alpha:1}, 1);
			if (_gameSave.data.score == _gameSave.data.hScore)
			{
				FlxTween.tween(_hScoreText, {alpha:1}, 1);
			}
		}
		
		super.update(elapsed);
	}
	
	private function switchScene():Void
	{
		_musicPlayer.destroy();
		FlxG.switchState(new PlayState());
	}
	
}