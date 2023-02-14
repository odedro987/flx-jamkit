package examples.fluids;

import examples.fluids.shaders.UnderwaterShader;
import examples.fluids.shaders.WaterSpringShader;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

class WaterSpringSegment extends FlxTypedGroup<FlxSprite>
{
	var waterShader:WaterSpringShader;
	var underwaterShader:UnderwaterShader;
	var segment:FlxSprite;
	var buffer:FlxSprite;

	public function new(x:Float, y:Float, width:Int, height:Int, color:FlxColor, snapToGrid:Bool = true, blendIntensity:Float = 0.5)
	{
		super(2);

		buffer = new FlxSprite(x, y);
		buffer.makeGraphic(width, height, color);
		this.underwaterShader = new UnderwaterShader(x, y, color, blendIntensity);
		buffer.shader = underwaterShader;
		add(buffer);

		segment = new FlxSprite(x, y);
		segment.makeGraphic(width, height, color);
		this.waterShader = new WaterSpringShader(color, snapToGrid, blendIntensity);
		this.segment.shader = this.waterShader;
		add(segment);
	}

	public function setIndex(index:Int, segmentCount:Int)
	{
		this.underwaterShader.setIndex(index, segmentCount);
	}

	public function updateOffsetY(isLeft:Bool, offset:Float)
	{
		this.waterShader.updateOffsetY(isLeft, offset);
	}

	public function updateCamBuffer(buffer:FlxSprite)
	{
		this.underwaterShader.updateCamBuffer(buffer.graphic.bitmap);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		this.underwaterShader.updateTime(elapsed);
	}
}
