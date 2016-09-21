package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxRandom;
/**
 * ...
 * @author ...
 */
class CreepRain extends FlxObject
{
	private var particleSystemL:FlxEmitter;
	private var particleSystemLM:FlxEmitter;
	private var particleSystemM:FlxEmitter;
	private var particleSystemMR:FlxEmitter;
	private var particleSystemR:FlxEmitter;
	private var _player:Player;
	
	public function new(_p:Player) 
	{
		super(FlxG.width/2, 0);
		
		_player = _p;
		
		var _RNG:FlxRandom = new FlxRandom();
		
		particleSystemL = new FlxEmitter();
		particleSystemM = new FlxEmitter();
		particleSystemR = new FlxEmitter();
		particleSystemLM = new FlxEmitter();
		particleSystemMR = new FlxEmitter();
		
		for (i in 1 ... 51) {
			var p = new FlxParticle();
			p.loadGraphic(AssetPaths.candyman__png, false, 32, 32);
			p.scale.set(2, 2);
			p.exists = false;
			particleSystemL.add(p);
		}
		for (i in 1 ... 51) {
			var p = new FlxParticle();
			p.loadGraphic(AssetPaths.candyman__png, false, 32, 32);
			p.scale.set(2, 2);
			p.exists = false;
			particleSystemLM.add(p);
		}
		for (i in 1 ... 51) {
			var p = new FlxParticle();
			p.loadGraphic(AssetPaths.candyman__png, false, 32, 32);
			p.exists = false;
			p.scale.set(2, 2);
			particleSystemM.add(p);
		}
		for (i in 1 ... 51) {
			var p = new FlxParticle();
			p.loadGraphic(AssetPaths.candyman__png, false, 32, 32);
			p.scale.set(2, 2);
			p.exists = false;
			particleSystemMR.add(p);
		}
		for (i in 1 ... 51) {
			var p = new FlxParticle();
			p.loadGraphic(AssetPaths.candyman__png, false, 32, 32);
			p.exists = false;
			p.scale.set(2, 2);
			particleSystemR.add(p);
		}
		
		particleSystemL.acceleration.set(0, 200, 0, 400);
		particleSystemR.acceleration.set(0, 200, 0, 400);
		particleSystemM.acceleration.set(0, 200, 0, 400);
		particleSystemLM.acceleration.set(0, 200, 0, 400);
		particleSystemMR.acceleration.set(0, 200, 0, 400);
		
		
		particleSystemL.velocity.set(200, 100, 500, 100);
		particleSystemLM.velocity.set(-50, 100, 350, 100);
		particleSystemM.velocity.set( -200, 100, 200, 100);
		particleSystemMR.velocity.set(-350, 200, 50, 400);
		particleSystemR.velocity.set(-500, 100, -200, 100);
		
		particleSystemL.angularVelocity.set(_RNG.float(0, 90) * _RNG.int( -1, 1, [0]));
		particleSystemM.angularVelocity.set(_RNG.float(0, 90) * _RNG.int( -1, 1, [0]));
		particleSystemR.angularVelocity.set(_RNG.float(0, 90) * _RNG.int( -1, 1, [0]));
		particleSystemMR.angularVelocity.set(_RNG.float(0, 90) * _RNG.int( -1, 1, [0]));
		particleSystemLM.angularVelocity.set(_RNG.float(0, 90) * _RNG.int( -1, 1, [0]));
		
		particleSystemL.lifespan.set(6);
		particleSystemM.lifespan.set(6);
		particleSystemR.lifespan.set(6);
		particleSystemMR.lifespan.set(6);
		particleSystemLM.lifespan.set(6);
		
		FlxG.state.add(particleSystemL);
		FlxG.state.add(particleSystemM);
		FlxG.state.add(particleSystemR);
		FlxG.state.add(particleSystemLM);
		FlxG.state.add(particleSystemMR);
	}
	
	public function startRain()
	{
		particleSystemL.start(false, .1, 50);
		particleSystemM.start(false, .1, 50);
		particleSystemR.start(false, .1, 50);
		particleSystemLM.start(false, .1, 50);
		particleSystemMR.start(false, .1, 50);
	}
	
	override public function update(elapsed:Float):Void
	{
		particleSystemL.setPosition(0, _player.y - 450);
		particleSystemM.setPosition(FlxG.width/2, _player.y - 450);
		particleSystemR.setPosition(FlxG.width, _player.y - 450);
		particleSystemMR.setPosition(FlxG.width*.75, _player.y - 450);
		particleSystemLM.setPosition(FlxG.width*.25, _player.y - 450);
		super.update(elapsed);
	}
	
}