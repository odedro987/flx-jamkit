package examples.barber_pole;

import flixel.FlxState;

class BarScene extends FlxState
{
	override public function create()
	{
		super.create();

		add(new BarberPole(10, 10));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
