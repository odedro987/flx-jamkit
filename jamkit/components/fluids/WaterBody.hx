package jamkit.components.fluids;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import jamkit.components.fluids.WaterSpringSegment;

typedef WaterBodyOptions =
{
	/**
		*	How much the background blends with the water color.
			Values between `0.0` and `1.0`.
	**/
	var ?blendIntensity:Float;

	/**
		*	How fast the waves spread to adjacent springs.
			Values between `0.0` and `0.5`.
	**/
	var ?spreadFactor:Float;

	/**
		*	How much the springs pull onto adjacent springs.
			Higher tension means higher springiness.
	**/
	var ?tensionFactor:Float;

	/**
		*	How much fast the waves stop.
			Higher tension means waves stop faster.
	**/
	var ?dampeningFactor:Float;

	/**
		*	If `true` vertices move in sync, keeping pixel grid.
			If `false` vertices move in separately, looking more fluid.
	**/
	var ?snapToGrid:Bool;
}

var DefaultOptions:WaterBodyOptions = {
	blendIntensity: 0.5,
	dampeningFactor: 0.025,
	tensionFactor: 0.01,
	spreadFactor: 0.25,
	snapToGrid: true,
}

class WaterBody extends FlxTypedGroup<WaterSpringSegment>
{
	var offsets:Array<Float>;
	var springSpeeds:Array<Float>;
	var lDeltas:Array<Float>;
	var rDeltas:Array<Float>;

	var segmentWidth:Int;
	var targetY:Float;

	var snapToGrid:Bool;

	var spread:Float;
	var tension:Float;
	var dampening:Float;

	public function new(x:Float, y:Float, width:Int, height:Int, color:FlxColor, quality:Int, ?options:WaterBodyOptions)
	{
		var count = Math.floor(width / quality);
		super(count);

		if (options == null)
		{
			options = DefaultOptions;
		} else
		{
			if (options.blendIntensity == null)
				options.blendIntensity = DefaultOptions.blendIntensity;
			if (options.dampeningFactor == null)
				options.dampeningFactor = DefaultOptions.dampeningFactor;
			if (options.spreadFactor == null)
				options.spreadFactor = DefaultOptions.spreadFactor;
			if (options.tensionFactor == null)
				options.tensionFactor = DefaultOptions.tensionFactor;
			if (options.snapToGrid == null)
				options.snapToGrid = DefaultOptions.snapToGrid;
		}

		this.targetY = y;
		this.segmentWidth = quality;
		this.springSpeeds = [];
		this.offsets = [];
		this.lDeltas = [];
		this.rDeltas = [];
		this.dampening = options.dampeningFactor;
		this.spread = options.spreadFactor;
		this.tension = options.tensionFactor;
		this.snapToGrid = options.snapToGrid;

		for (i in 0...count)
		{
			var segment = add(new WaterSpringSegment(x + i * segmentWidth, y, segmentWidth, height, color, options.snapToGrid, options.blendIntensity));
			segment.setIndex(i, count);
			this.springSpeeds.push(0);
			this.lDeltas.push(0);
			this.rDeltas.push(0);
			this.offsets.push(y);
		}
	}

	public function updateCamBuffer(buffer:FlxSprite)
	{
		forEach(segment -> segment.updateCamBuffer(buffer));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (i in 0...members.length)
		{
			var diff = targetY - offsets[i];
			this.springSpeeds[i] += this.tension * diff - this.springSpeeds[i] * this.dampening;
			this.offsets[i] += this.springSpeeds[i];
			if (snapToGrid)
			{
				this.offsets[i] = Math.round(this.offsets[i] * 100) / 100;
			}

			members[i].updateOffsetY(true, this.offsets[i]);
			members[i].updateOffsetY(false, this.offsets[i]);
			if (!snapToGrid && i > 0)
			{
				members[i - 1].updateOffsetY(false, this.offsets[i]);
			}
		}

		for (_ in 0...4)
		{
			for (i in 0...members.length)
			{
				if (i > 0)
				{
					this.lDeltas[i] = this.spread * (this.offsets[i] - this.offsets[i - 1]);
					this.springSpeeds[i - 1] += this.lDeltas[i];
				}

				if (i < members.length - 1)
				{
					this.rDeltas[i] = this.spread * (this.offsets[i] - this.offsets[i + 1]);
					this.springSpeeds[i + 1] += this.rDeltas[i];
				}
			}

			for (i in 0...members.length)
			{
				if (i > 0)
				{
					this.offsets[i - 1] += this.lDeltas[i];
				}

				if (i < members.length - 1)
				{
					this.offsets[i + 1] += this.rDeltas[i];
				}
			}
		}

		if (FlxG.keys.justReleased.SPACE)
		{
			springSpeeds[Math.floor(members.length / 2)] = 10.0;
			springSpeeds[Math.floor(members.length / 2) - 1] = 10.0;
			springSpeeds[Math.floor(members.length / 2) + 1] = 10.0;
		}
	}
}
