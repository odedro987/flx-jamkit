package examples.barber_pole;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class BarberPole extends FlxTypedGroup<FlxSprite>
{
	var bar:FlxSprite;
	var container:FlxSprite;

	var barShader:BarberPoleShader;
	var progress:Float;

	public function new(x:Float, y:Float)
	{
		super(2);

		bar = new FlxSprite(x + 2, y + 9);
		bar.makeGraphic(12, 56);
		barShader = new BarberPoleShader(0xffff0040, 0xff7700ff, 0xff76004d);
		// barShader
		// 	.setSize(12, 56)
		// 	.setQuality(16);
		bar.shader = barShader;
		add(bar);

		container = new FlxSprite(x, y, AssetPaths.barber_pole__png);
		add(container);

		progress = 0.5;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.UP)
		{
			progress += elapsed / 3;
		} else if (FlxG.keys.pressed.DOWN)
		{
			progress -= elapsed / 3;
		}

		barShader
			.updateProgress(progress)
			.updateTime(elapsed);
	}
}
