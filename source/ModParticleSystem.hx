package;

import flixel.math.FlxMath;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxSprite;
/**
 * Generate a user defined particle effects at a location of _attachedObject, with velocity opposite of the current velocity.
 * @author John Steigerwald
 */
class ModParticleSystem extends FlxEmitter
{
	
	private var _cooldown:Int;
	private var _attachedObject:FlxSprite;
	private var _sysType:Int;
	
	/**
	 * Instantiate a new particle system at the location of _obj.
	 * @param	_obj: Object that the particle system will follow around the scene.
	 * @param   _fileName: Name of sprite to be used for the particle system
	 * @param   _sysType: 0 = Trail, 1 = No trail, manual calls with release particle system
	 */
	public function new( _obj:FlxSprite, _fileName:String, _sysT:Int) 
	{
		super(_obj.x, _obj.y);
		_cooldown = 0;
		_attachedObject = _obj;
		for (i in 1 ... 100) {
			var p = new FlxParticle();
			p.loadGraphic("assets/images/Collectibles/" + _fileName, false, 32, 32);
			p.exists = false;
			this.add(p);
		}
		this.lifespan.set(1, 1);
		this.alpha.set(1, 1,.2,.2);
		this.start(false, 1000); //So the documentation claims 0 will not release particles, this is not the case.
	}
	
	/**
	 * Emit particles in the direction opposite of the players current movement
	 */
	private function movementParticles():Void{
		_cooldown++;
		if (FlxMath.vectorLength(_attachedObject.velocity.x, _attachedObject.velocity.y) > 0 && _cooldown > 5) {	
			this.velocity.set( -1 * _attachedObject.velocity.x, -1 * _attachedObject.velocity.y,
							   -1 * _attachedObject.velocity.x, -1 * _attachedObject.velocity.y);		
			this.emitParticle();
			_cooldown = 0;
		}
	}
	
	/**
	 * Instantiate a new particle system at the location of _obj.
	 * @param	_obj: Object that the particle system will follow around the scene.
	*/
	public function releaseParticles(_count:Int):Void
	{
		this.start(false, .01, _count);
	}
	
	public override function update(elapsed:Float):Void
	{
		
		this.setPosition(_attachedObject.x + _attachedObject.width/2, _attachedObject.y + _attachedObject.height/2);
		
		if (_sysType == 0) movementParticles();
		
		super.update(elapsed);
	}
	
}