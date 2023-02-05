package jamkit.components.emitter;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import jamkit.components.emitter.Types;

class CustomEmitter extends FlxEmitter
{
	/**
	 *	The type of the emitter.
	**/
	private var _type:EmitterType;

	/**
	 *	The type of the emitter's path.
	**/
	private var _pathType:EmitterPath;

	// Variables for emitting behaviors

	/**
	 *	Describes the emit behavior, takes `elapsed` as argument.
	**/
	private var _emitBehavior:(elapsed:Float) -> Void;

	/**
	 * The maximal spread for straight emit, in pixels. Range is `[-_maxSpread, _maxSpread]`.
	**/
	private var _maxSpread:Int;

	/**
	 *	The speed of the emitter's rotation, in degrees. `360` means one full rotation.
	**/
	private var _spinSpeed:Int;

	/**
	 *	The current angle of the emitter.
	**/
	private var _currEmitAngle:Float;

	/**
	 *	Whether the emitter is spinning.
	**/
	private var _isSpinning:Bool;

	/**
	 *	Describes the emit spin behavior, takes `elapsed` as argument.
	**/
	private var _emitterSpin:(elapsed:Float) -> Void;

	/**
	 *	Whether the emitter is emitting from multiple angles.
	**/
	private var _isMultiShoot:Bool;

	/**
	 *	The angle of the multishoot.
	**/
	private var _multiShootAngle:Float;

	/**
	 *	Describes the emit multishoot behavior, takes `elapsed` as argument.
	**/
	private var _emitterMultiShoot:(elapsed:Float) -> Void;

	// Variables for emitter paths

	/**
	 *	Describes the emit path behavior, takes `elapsed` as argument.
	**/
	private var _emitterPath:(elapsed:Float) -> Void;

	/**
	 *	The origin position of the emitter.
	**/
	private var _originPos:FlxPoint;

	/**
	 *	The moving speed along the path.
	**/
	private var _pathWalkSpeed:Int;

	/**
	 *	An array of points for the path to transition between.
	**/
	private var _pathPoints:Array<FlxPoint>;

	/**
	 *	The index of the current point in the path.
	**/
	private var _currPathPoint:Int;

	/**
	 *	The current path angle. Used for Circular and Elliptic paths.
	**/
	private var _currPathAngle:Float;

	/**
	 *	Whether the particles position is relative to the emitter.
	**/
	private var _isRelativeParticles:Bool;

	/**
	 * Creates a new `CustomEmitter` object at a specific position.
	 *
	 * @param   x      		  The X position of the emitter.
	 * @param   y      		  The Y position of the emitter.
	 * @param   size   		  Specifies a maximum capacity for this emitter.
	 * @param   initialColor  The particle color, default set to white.
	 */
	public function new(x:Float, y:Float, size:Int, initialColor:FlxColor = FlxColor.WHITE)
	{
		super(x, y, size);
		_originPos = FlxPoint.get();
		_originPos.set(x, y);
		_pathPoints = [];

		// Temporary particles
		makeParticles(4, 4, initialColor, size);
	}

	/**
		* Starts continuously emitting particles with a given frequency. 
		*
		* @param   frequency   `frequency` is how often to emit a particle.
		`0` = never emit, `0.1` = 1 particle every 0.1 seconds, `5` = 1 particle every 5 seconds.
	 */
	public function emit(frequency:Float = 0.1)
	{
		start(false, frequency);
	}

	override public function update(elapsed:Float)
	{
		if (_isMultiShoot)
			_emitterMultiShoot(elapsed);
		if (_isSpinning)
			_emitterSpin(elapsed);
		if (_emitBehavior != null)
			_emitBehavior(elapsed);
		if (_emitterPath != null)
			_emitterPath(elapsed);
		super.update(elapsed);
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_emitBehavior = null;
		_emitterPath = null;
		_emitterMultiShoot = null;
		_emitterSpin = null;

		FlxDestroyUtil.put(_originPos);

		for (point in _pathPoints)
		{
			FlxDestroyUtil.put(point);
		}
	}

	/**
	 * Sets the emitter size. Particles can be randomly generated from anywhere within this box.
	 *
	 * @param   width  The width of this emitter.
	 * @param   height The height of this emitter. Optional, will be set to `width` if ignored.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setEmitterSize(width:Float, ?height:Float):CustomEmitter
	{
		this.width = width;
		this.height = height == null ? width : height;
		return this;
	}

	/**
		* Handy function to set the the beginning and ending range of values for an emitter's particles lifespan in one line.
		*
		* @param   start  The minimum value of this lifespan for particles launched from this emitter.
		* @param   end    The maximum value of this lifespan for particles launched from this emitter. 
		Optional, will be set to equal `start` if ignored.
		* @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setLifespanRange(start:Float, ?end:Float):CustomEmitter
	{
		end = end == null ? start : end;
		this.lifespan.set(start, end);
		return this;
	}

	/**
		* Handy function to set the the beginning and ending range of values for an emitter's alpha in one line.
		*
		* @param   start  The minimum value of this alpha for particles launched from this emitter.
		* @param   end    The maximum value of this alpha for particles launched from this emitter. 
		Optional, will be set to equal `start` if ignored.
		* @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setAlphaRange(start:Float, ?end:Float):CustomEmitter
	{
		end = end == null ? start : end;
		this.alpha.set(start, end);
		return this;
	}

	/**
		* Handy function to set the the beginning and ending range of values for an emitter's particles color in one line.
		*
		* @param   start  The minimum value of this color for particles launched from this emitter.
		* @param   end    The maximum value of this color for particles launched from this emitter. 
		Optional, will be set to equal `start` if ignored.
		* @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setColorRange(start:FlxColor, ?end:FlxColor):CustomEmitter
	{
		end = end == null ? start : end;
		this.color.set(start, start, end, end);
		return this;
	}

	/**
	 * Handy function to set the the beginning and ending range of values for an emitter's particles color in one line.
	 *
	 * @param   startMin  The minimum possible initial value of this color for particles launched from this emitter.
	 * @param   startMax  The maximum possible initial value of this color for particles launched from this emitter.
	 * @param   endMin    The minimum possible final value of this color for particles launched from this emitter.
	 * @param   endMax    The maximum possible final value of this color for particles launched from this emitter.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setColorRangeBounds(startMin:FlxColor, startMax:FlxColor, endMin:FlxColor, endMax:FlxColor):CustomEmitter
	{
		this.color.set(startMin, startMax, endMin, endMax);
		return this;
	}

	/**
		* Handy function to set the the beginning and ending range of values for an emitter's particles size in one line.
		*
		* @param   start  The minimum value of this size for particles launched from this emitter.
		* @param   end    The maximum value of this size for particles launched from this emitter. 
		Optional, will be set to equal `start` if ignored.
		* @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setSizeRange(start:Float, ?end:Float):CustomEmitter
	{
		end = end == null ? start : end;
		this.scale.set(start, start, start, start, end, end, end, end);
		return this;
	}

	/**
	 * Handy function to set the the beginning and ending range of values for an emitter's particles size in one line.
	 *
	 * @param   startMin  The minimum possible initial value of this size for particles launched from this emitter.
	 * @param   startMax  The maximum possible initial value of this size for particles launched from this emitter.
	 * @param   endMin    The minimum possible final value of this size for particles launched from this emitter.
	 * @param   endMax    The maximum possible final value of this size for particles launched from this emitter.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setSizeRangeBounds(startMin:Float, startMax:Float, endMin:Float, endMax:Float):CustomEmitter
	{
		this.scale.set(startMin, startMin, startMax, startMax, endMin, endMin, endMax, endMax);
		return this;
	}

	/**
		* Handy function to set the the beginning and ending range of values for an emitter's particles angular velocity in one line.
		*
		* @param   start  The minimum value of this angular velocity for particles launched from this emitter.
		* @param   end    The maximum value of this angular velocity for particles launched from this emitter. 
		Optional, will be set to equal `start` if ignored.
		* @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setAngularVelocityRange(start:Float, ?end:Float):CustomEmitter
	{
		end = end == null ? start : end;
		this.angularVelocity.set(start, start, end, end);
		return this;
	}

	/**
	 * Handy function to set the the beginning and ending range of values for an emitter's particles angular velocity in one line.
	 *
	 * @param   startMin  The minimum possible initial value of this angular velocity for particles launched from this emitter.
	 * @param   startMax  The maximum possible initial value of this angular velocity for particles launched from this emitter.
	 * @param   endMin    The minimum possible final value of this angular velocity for particles launched from this emitter.
	 * @param   endMax    The maximum possible final value of this angular velocity for particles launched from this emitter.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setAngularVelocityRangeBounds(startMin:Float, startMax:Float, endMin:Float, endMax:Float):CustomEmitter
	{
		this.angularVelocity.set(startMin, startMax, endMin, endMax);
		return this;
	}

	/**
		* Handy function to set the the beginning and ending range of values for an emitter's particles speed in one line.
		*
		* @param   start  The minimum value of this speed for particles launched from this emitter.
		* @param   end    The maximum value of this speed for particles launched from this emitter. 
		Optional, will be set to equal `start` if ignored.
		* @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setSpeedRange(start:Float, ?end:Float):CustomEmitter
	{
		end = end == null ? start : end;
		trace(end);
		this.speed.set(start, start, end, end);
		return this;
	}

	/**
	 * Handy function to set the the beginning and ending range of values for an emitter's particles speed in one line.
	 *
	 * @param   startMin  The minimum possible initial value of this speed for particles launched from this emitter.
	 * @param   startMax  The maximum possible initial value of this speed for particles launched from this emitter.
	 * @param   endMin    The minimum possible final value of this speed for particles launched from this emitter.
	 * @param   endMax    The maximum possible final value of this speed for particles launched from this emitter.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 */
	public function setSpeedRangeBounds(startMin:Float, startMax:Float, endMin:Float, endMax:Float):CustomEmitter
	{
		this.speed.set(startMin, startMax, endMin, endMax);
		return this;
	}

	//-- Builder functions for adding emitting behaviors --//

	/**
	 * This function gives the emitter a constant spin.
	 *
	 * @param spinSpeed 	How many degrees to spin every second.
	 *						`360` means one full revolution per second.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setEmitterSpin(spinSpeed:Int):CustomEmitter
	{
		if (_type != null)
		{
			_isSpinning = true;
			this._spinSpeed = spinSpeed;
			_emitterSpin = function(elapsed:Float)
			{
				_currEmitAngle += _spinSpeed * elapsed;

				if (_currEmitAngle > 360)
					_currEmitAngle = _currEmitAngle % 360;
			}
		}

		return this;
	}

	/**
	 * This function gives the illusion of shooting from different angles.
	 * In reality each update tick it adds to the launch angle proportionatly
	 * to the number of given directions.
	 *
	 * **NOTE:** Works nicer with high frequency emits and fast speeds.
	 *
	 * @param directionNumber 	How many directions should the emitter shoot from.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setMultiShoot(directionNumber:Int):CustomEmitter
	{
		if (_type != null)
		{
			_isMultiShoot = true;
			_multiShootAngle = 360 / directionNumber;
			_emitterMultiShoot = function(elapsed:Float)
			{
				_currEmitAngle += _multiShootAngle;

				if (_currEmitAngle > 360)
					_currEmitAngle = _currEmitAngle % 360;
			}
		}
		return this;
	}

	/**
	 * This function sets a basic emitter behavior. Emits at a straight line with an optional given `startAngle` 
	 * with an optional `maxSpread`.
	 *
	 * @param startAngle 	Starting angle for the emitter.
	 * 						Default value is `0` = right.
	 *						Can be paired with 
	 * @param maxSpread 	How far can the particles spread. 
	 * 						Used evenly from `-maxSpread` to `maxSpread`.
	 *						Default value sets at `0` for no spread.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 * @see Types#EmitterAngle
	**/
	public function addStraightEmit(startAngle:Float = 0, maxSpread:Int = 0):CustomEmitter
	{
		_type = EmitterType.STRAIGHT;
		_currEmitAngle = startAngle;
		this._maxSpread = maxSpread;
		_emitBehavior = function(elapsed:Float)
		{
			launchAngle.set(_currEmitAngle - _maxSpread, _currEmitAngle + _maxSpread);
		}
		return this;
	}

	//-- Builder functions for adding emitter paths --//s

	/**
	 * This function makes the particles' position relative to the emitter's position 
	 *
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setRelativeParticles():CustomEmitter
	{
		_isRelativeParticles = true;
		return this;
	}

	/**
	 * This function sets a path made of an array of points for the emitter to loop through.
	 *
	 * @param points 	Array of `FlxPoint` to loop through.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addPolygonPath(points:Array<FlxPoint>, speed:Int, type:EmitterPath = EmitterPath.POLYGON):CustomEmitter
	{
		_pathType = type;
		_pathPoints.push(_originPos);
		for (point in points)
		{
			_pathPoints.push(point);
		}
		_currPathPoint = 0;
		_pathWalkSpeed = speed;
		_emitterPath = function(elapsed:Float)
		{
			moveTowardsNextPoint(elapsed);
		}
		return this;
	}

	/**
	 * This function sets a path made of an array of points for the emitter to loop through.
	 *
	 * @param points 	Array of `FlxPoint` to loop through.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addPolygonalPath(points:Array<FlxPoint>, speed:Int):CustomEmitter
	{
		return addPolygonPath(points, speed);
	}

	/**
	 * This function sets a line path for the emitter to loop through.
	 *
	 * @param x 		Distance in the x-axis relative to emitter's position.
	 * @param y 		Distance in the y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addLinePath(x:Float, y:Float, speed:Int):CustomEmitter
	{
		return addPolygonPath([FlxPoint.get(_originPos.x + x, _originPos.y + y)], speed, EmitterPath.LINE);
	}

	/**
	 * This function sets a triangular path for the emitter to loop through.
	 * Starts at the emitter's original position.
	 *
	 * @param pointB 	The 2nd point of the triangle. Coordinations are absolute, not relative. 
	 * @param pointC 	The 3rd point of the triangle. Coordinations are absolute, not relative.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addTrianglePath(pointB:FlxPoint, pointC:FlxPoint, speed:Int):CustomEmitter
	{
		return addPolygonPath([pointB, pointC], speed, EmitterPath.TRIANGLE);
	}

	/**
	 * This function sets a rectangular path for the emitter to loop through.
	 *
	 * @param width 	Distance in the x-axis relative to emitter's position.
	 * @param height 	Distance in the y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addRectanglePath(width:Float, height:Float, speed:Int, type:EmitterPath = EmitterPath.RECTANGLE):CustomEmitter
	{
		return addPolygonPath([
			FlxPoint.get(_originPos.x + width, _originPos.y),
			FlxPoint.get(_originPos.x + width, _originPos.y + height),
			FlxPoint.get(_originPos.x, _originPos.y + height)
		], speed, type);
	}

	/**
	 * This function sets a rectangular path for the emitter to loop through.
	 *
	 * @param width 	Distance in the x-axis relative to emitter's position.
	 * @param height 	Distance in the y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addRectangularPath(width:Float, height:Float, speed:Int):CustomEmitter
	{
		return addRectanglePath(width, height, speed);
	}

	/**
	 * This function sets a square path for the emitter to loop through.
	 *
	 * @param length 	Distance in the x-axis and y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addSquarePath(length:Float, speed:Int):CustomEmitter
	{
		return addRectanglePath(length, length, speed, EmitterPath.SQUARE);
	}

	/**
	 * This function sets a elliptical path for the emitter to loop through.
	 * The ellipse is relative to the emitter's original position.
	 *
	 * @param width 	Radius of the major axis.
	 * @param height 	Radius of the minor axis.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addEllipsePath(width:Float, height:Float, speed:Int, type:EmitterPath = EmitterPath.ELLIPSE):CustomEmitter
	{
		_pathType = type;
		var center = FlxPoint.get(_originPos.x + width, _originPos.y);
		_currPathAngle = 0;
		_emitterPath = function(elapsed:Float)
		{
			_currPathAngle += elapsed * speed;
			if (_currPathAngle > 360)
				_currPathAngle = 0;

			var newX = (center.x + Math.cos(_currPathAngle) * width) - x;
			var newY = (center.y + Math.sin(_currPathAngle) * height) - y;
			x += newX;
			y += newY;

			if (_isRelativeParticles)
			{
				moveParticles(newX, newY);
			}
		}
		return this;
	}

	/**
	 * This function sets a elliptical path for the emitter to loop through.
	 * The ellipse is relative to the emitter's original position.
	 *
	 * @param width 	Radius of the major axis.
	 * @param height 	Radius of the minor axis.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addEllipticalPath(width:Float, height:Float, speed:Int):CustomEmitter
	{
		return addEllipsePath(width, height, speed, EmitterPath.ELLIPSE);
	}

	/**
	 * This function sets a circular path for the emitter to loop through.
	 * The circle is relative to the emitter's original position.
	 *
	 * @param radius 	Radius of circle.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addCirclePath(radius:Int, speed:Int):CustomEmitter
	{
		return addEllipsePath(radius, radius, speed, EmitterPath.CIRCLE);
	}

	//-- Helper functions --//

	/**
	 * This function moves the emitter towards the next point in `pathPoints`.
	 * If `isRelativeParticles` set to `true` the function will move the particles as well.
	 *
	 * This function only affects paths that use `pathPoints` (i.e ploygonal paths).
	 * @param elapsed Delta of `update` function.
	 * @see addPolygonalPath
	**/
	private function moveTowardsNextPoint(elapsed:Float)
	{
		var nextPoint = _currPathPoint < _pathPoints.length - 1 ? _currPathPoint + 1 : 0;
		var dx = _pathPoints[nextPoint].x - _pathPoints[_currPathPoint].x;
		var dy = _pathPoints[nextPoint].y - _pathPoints[_currPathPoint].y;
		var angle = Math.atan2(dy, dx);
		var newX = _pathWalkSpeed * elapsed * Math.cos(angle);
		var newY = _pathWalkSpeed * elapsed * Math.sin(angle);
		x += newX;
		y += newY;

		if (_isRelativeParticles)
		{
			moveParticles(newX, newY);
		}

		if (distanceTo(_pathPoints[nextPoint]) <= 1)
		{
			_currPathPoint = nextPoint;
		}
	}

	/**
	 * This function loops through all living particles and moves them by given amounts.
	 * Used for moving particles relative to the emitter's position.
	 *
	 * @param x The amount of pixels to move in the x-axis.
	 * @param y The amount of pixels to move in the y-axis.
	**/
	private function moveParticles(x:Float, y:Float)
	{
		forEachAlive(function(particle:FlxParticle)
		{
			particle.x += x;
			particle.y += y;
		});
	}

	/**
	 * This function calculates the distance from the emitter's current postion to an FlxPoint.
	 *
	 * @param destination The `FlxPoint` to calculate the distance from.
	 * @return The distance from the emitter's current position.
	**/
	private function distanceTo(destination:FlxPoint):Float
	{
		return Math.sqrt(Math.pow((x - destination.x), 2) + Math.pow((y - destination.y), 2));
	}
}
