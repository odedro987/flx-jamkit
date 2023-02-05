package jamkit.components.emitter;

import flixel.FlxG;
import flixel.util.FlxColor;
import jamkit.components.emitter.Types;

class EmitterLibrary
{
	public static function SpaceEmitter(x:Float, y:Float, size:Int = 20000)
	{
		return new CustomEmitter(x, y, size)
			.addStraightEmit(0, 10)
			.setMultiShoot(4)
			.setEmitterSpin(360)
			.setSizeRangeBounds(0.1, 0.4, 1, 1.2)
			.setLifespanRange(1.5)
			.setSpeedRangeBounds(300, 400, 600, 800)
			.setColorRange(FlxColor.BLACK, FlxColor.WHITE);
	}

	public static function RainEmitter(x:Float, y:Float, size:Int = 20000)
	{
		return new CustomEmitter(x, y, size)
			.addStraightEmit(12.0 + EmitAngle.DOWN, 3)
			.setEmitterSize(FlxG.width + 64, 0)
			.setSizeRangeBounds(0.4, 0.6, 1, 1)
			.setLifespanRange(2)
			.setSpeedRangeBounds(600, 800, 1200, 1400)
			.setColorRange(0xFF274EC4, 0xFF5598F7);
	}

	public static function SmokeEmitter(x:Float, y:Float)
	{
		return new CustomEmitter(x, y, 200)
			.addStraightEmit(EmitAngle.UP, 30)
			.setColorRange(FlxColor.WHITE, FlxColor.BLACK)
			.setSizeRangeBounds(1, 2, 3, 4)
			.setAlphaRange(0.7, 0)
			.setEmitterSize(8, 2)
			.setAngularVelocityRangeBounds(-360, 360, -360, 360)
			.setLifespanRange(2);
	}

	public static function FireEmitter(x:Float, y:Float)
	{
		return new CustomEmitter(x, y, 200)
			.addStraightEmit(EmitAngle.UP, 30)
			.setColorRangeBounds(FlxColor.YELLOW, FlxColor.ORANGE, FlxColor.RED, FlxColor.RED)
			.setSizeRangeBounds(0.5, 1, 2, 2.5)
			.setAlphaRange(1, 0.2)
			.setEmitterSize(8, 0)
			.setAngularVelocityRangeBounds(-360, 360, -360, 360)
			.setLifespanRange(1.5);
	}
}
